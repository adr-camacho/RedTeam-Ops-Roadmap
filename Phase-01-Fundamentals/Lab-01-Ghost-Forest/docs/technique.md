# Technique — Lab-01 Ghost Forest

> **Capability (eje didáctico):** Primera kill-chain AD limpia — AS-REP/Kerberoasting → DCSync → Domain Admin.
> **Bloque CRTO:** Kerberos Authentication · Credential Theft (AS-REP, Kerberoasting, DCSync).
> **Adversario (escenario):** APT29 — ver [`emulation.md`](emulation.md).

---

## 1. Active Directory — Arquitectura y modelo de confianza


### ¿Qué es Active Directory?

Active Directory (AD) es un servicio de directorio de Microsoft que gestiona **identidades** (usuarios, equipos, grupos) y **políticas** (contraseñas, accesos, configuraciones) en un entorno Windows corporativo.

El concepto fundamental es el **dominio** — una unidad administrativa con un nombre DNS (`atackcorp.local`) y un **Domain Controller** que actúa como autoridad central de autenticación y autorización.

### Por qué AD es el objetivo principal de un Red Teamer

AD es el corazón de la mayoría de infraestructuras corporativas. Comprometer el Domain Controller significa:

1. **Control total de identidades** — cualquier usuario, cualquier equipo
2. **Acceso a todos los recursos** — shares, bases de datos, aplicaciones
3. **Persistencia indefinida** — Golden Ticket, certificados, shadow credentials
4. **Movimiento lateral sin límites** — cualquier sistema del dominio

La pregunta no es *si* se puede comprometer AD — es *cuánto tiempo lleva* encontrar el path.

### Objetos clave en AD

| Objeto | Descripción | Por qué interesa al atacante |
|--------|-------------|------------------------------|
| **Usuario** | Cuenta de persona o servicio | Credenciales, SPNs, ACLs |
| **Equipo** | Cuenta de máquina (DC$, WKSTN-01$) | TGTs, delegación, lateral movement |
| **Grupo** | Colección de objetos | Domain Admins, Administrators, grupos con ACLs |
| **OU** | Unidad organizativa | Scope de GPOs |
| **GPO** | Group Policy Object | Configuración que se aplica a OUs enteras |
| **ACE/DACL** | Access Control Entry / List | Permisos sobre objetos AD |
| **SPN** | Service Principal Name | Target de Kerberoasting |

### Modelo de privilegios — Tier Model

Microsoft recomienda el **Tier Model** para proteger AD:

```
Tier 0: Domain Controllers, AD infrastructure (máximo privilegio)
Tier 1: Servidores de aplicaciones, servicios críticos
Tier 2: Workstations, usuarios finales
```

Como atacante, el objetivo es siempre **Tier 0**. El camino suele ir de Tier 2 → Tier 1 → Tier 0.

---

## 2. Kerberos — El protocolo de autenticación de AD


Kerberos es el protocolo de autenticación principal de AD desde Windows 2000. Entenderlo a fondo es imprescindible — la mayoría de los ataques AD abusan de Kerberos.

### Flujo de autenticación Kerberos

```
Cliente                    KDC (DC-01)                    Servicio
   |                           |                              |
   |--AS-REQ (usuario)-------->|                              |
   |<-AS-REP (TGT)-------------|                              |
   |                           |                              |
   |--TGS-REQ (TGT + SPN)----->|                              |
   |<-TGS-REP (TGT de servicio)|                              |
   |                           |                              |
   |--AP-REQ (TGS)-------------|----------------------------->|
   |<-AP-REP (acceso)----------|------------------------------|
```

### Componentes clave

**TGT (Ticket Granting Ticket)**
- Emitido por el KDC tras la autenticación inicial
- Cifrado con el hash de **krbtgt** — la cuenta más crítica del dominio
- Válido 10 horas por defecto (renovable hasta 7 días)
- Prueba de identidad del usuario ante el KDC

**TGS (Ticket Granting Service)**
- Emitido por el KDC en respuesta a una solicitud de acceso a un servicio
- Cifrado con el hash de la **cuenta de servicio** (SPN)
- Contiene la identidad del usuario y sus privilegios (PAC)
- Solo el servicio destino puede descifrarlo

**KDC (Key Distribution Center)**
- Componente del Domain Controller
- Dos partes: AS (Authentication Service) y TGS (Ticket Granting Service)
- Toda la confianza del dominio pasa por él

**PAC (Privilege Attribute Certificate)**
- Estructura dentro de los tickets que contiene grupos del usuario
- Firmado por el KDC con la clave de krbtgt
- Permite que el servicio de destino verifique los privilegios sin contactar el KDC

### Pre-autenticación Kerberos

La pre-autenticación es un mecanismo de seguridad que exige que el cliente demuestre que conoce su contraseña **antes** de que el KDC emita el TGT.

Sin pre-autenticación:
1. El cliente envía solo su nombre de usuario
2. El KDC responde con un TGT cifrado con el hash del usuario
3. **Cualquiera puede solicitar ese TGT y crackearlo offline**

Este es el fundamento del **AS-REP Roasting**.

---

## 3. AS-REP Roasting — Por qué funciona


### Condición necesaria

La cuenta objetivo debe tener habilitado `DONT_REQUIRE_PREAUTH` en `userAccountControl`. Este atributo existe por compatibilidad con sistemas legados que no soportaban pre-autenticación.

### Flujo del ataque

```
1. Atacante → KDC: AS-REQ con username (sin pre-auth, sin contraseña)
2. KDC → Atacante: AS-REP con TGT cifrado con hash NT del usuario
3. Atacante: hashcat/john offline → contraseña en claro
```

### Por qué el KDC responde

El KDC no puede distinguir entre un cliente legítimo sin pre-auth y un atacante. Si la cuenta tiene `DONT_REQUIRE_PREAUTH`, simplemente cumple el protocolo y responde.

### Formato del hash

```
$krb5asrep$23$usuario@DOMINIO:...
```

El `$23$` indica RC4-HMAC — el cifrado más débil y el más fácil de crackear.

### Defensa

- **Nunca** habilitar `DONT_REQUIRE_PREAUTH` salvo necesidad absoluta
- Monitorizar Event ID 4768 con `Pre-authentication Type: 0`
- Usar contraseñas largas y aleatorias en cuentas con este flag

### Variantes del ataque

| Variante | Condición | Herramienta |
|----------|-----------|-------------|
| Sin credenciales | Lista de usuarios conocidos | `GetNPUsers.py -no-pass -usersfile` |
| Con credenciales | Acceso LDAP al dominio | `GetNPUsers.py -request` |
| Desde Windows | Acceso al dominio | `Rubeus.exe asreproast` |

---

## 4. Kerberoasting — Por qué funciona


### Condición necesaria

La cuenta objetivo debe tener un **SPN (Service Principal Name)** registrado. Los SPNs identifican instancias de servicios (SQL Server, IIS, etc.) y son necesarios para la autenticación Kerberos de servicios.

### Flujo del ataque

```
1. Atacante (autenticado) → KDC: TGS-REQ para SPN/servicio
2. KDC → Atacante: TGS cifrado con el hash NT de la cuenta de servicio
3. Atacante: hashcat/john offline → contraseña de la cuenta de servicio
```

### Por qué el KDC responde con el TGS

El protocolo Kerberos **requiere** que el KDC emita un TGS a cualquier usuario autenticado que lo solicite para un SPN válido. El KDC no verifica si el solicitante realmente necesita acceder al servicio — simplemente emite el ticket.

### La debilidad fundamental

Las cuentas de servicio suelen tener contraseñas:
1. **Predecibles** — `Nombre_del_servicio + año + !`
2. **Sin rotación automática** — pueden llevar años sin cambiar
3. **Gestionadas por humanos** — no por MSAS (Managed Service Accounts)

### Diferencia con AS-REP Roasting

| | AS-REP Roasting | Kerberoasting |
|--|-----------------|---------------|
| **Credenciales requeridas** | No (con flag) | Sí (cualquier usuario del dominio) |
| **Target** | Usuarios con `DONT_REQUIRE_PREAUTH` | Cuentas con SPNs |
| **Hash tipo** | `$krb5asrep$23$` | `$krb5tgs$23$` |
| **Detectabilidad** | Menor | Mayor (TGS-REQ por cuenta no habitual) |

### Targeted Kerberoasting (se ejecuta en profundidad en Lab-04 · ACL abuse)

Con **GenericWrite** sobre una cuenta, podemos añadirle un SPN arbitrario y convertirla en objetivo de Kerberoasting bajo demanda. Esto permite atacar cuentas que normalmente no serían Kerberoasteables.

```
GenericWrite → Set servicePrincipalName → TGS-REQ → crack offline
```

### Defensa

- Usar **Managed Service Accounts (MSA)** o **Group Managed Service Accounts (gMSA)** — contraseñas de 240 caracteres rotadas automáticamente
- Contraseñas de +25 caracteres aleatorios en SPNs que no pueden usar gMSA
- Monitorizar Event ID 4769 con Ticket Encryption Type RC4 (0x17)

---

## 5. Pass-the-Hash y Pass-the-Ticket


### Pass-the-Hash (PtH)

Windows almacena las contraseñas como hashes NT en SAM (local) o NTDS.dit (AD). El protocolo NTLM acepta directamente el hash NT para autenticación — **no necesita la contraseña en claro**.

```
hash NT → autenticación NTLM directa → acceso
```

**Por qué funciona:** NTLM es un protocolo challenge-response. El servidor envía un reto, el cliente responde con `HMAC-MD5(hash_NT, reto)`. Con el hash NT se puede calcular esa respuesta sin conocer la contraseña.

**Limitación:** Solo funciona con NTLM. Si el entorno requiere Kerberos exclusivamente, PtH no funciona.

### Pass-the-Ticket (PtT)

Los tickets Kerberos (TGT o TGS) son credenciales de sesión válidas. Si los extraemos de memoria, podemos importarlos en otra sesión y autenticarnos como el usuario propietario.

```
TGT en memoria → extracción → importación → autenticación Kerberos
```

**Por qué funciona:** El KDC no puede distinguir entre el usuario legítimo usando su TGT y un atacante que lo robó. El ticket es la prueba de identidad.

**Ventaja sobre PtH:** Genera eventos Kerberos (menos sospechosos) en lugar de eventos NTLM.

### Overpass-the-Hash (OtH)

Convierte un hash NT en un TGT Kerberos.

```
hash NT → solicitar TGT al KDC (usando el hash como credencial) → TGT → autenticación Kerberos
```

**Por qué funciona:** El AS-REQ puede usar el hash NT directamente como clave de cifrado para la pre-autenticación.

---

## 6. DCSync — Replicación como arma


### Fundamento técnico

Los Domain Controllers replican entre sí los datos de AD usando el protocolo **MS-DRSR (Directory Replication Service Remote Protocol)**. El mecanismo principal es **DRSGetNCChanges** — una función que devuelve todos los cambios desde una fecha dada, incluyendo hashes de contraseñas.

### ¿Por qué puede usarlo un atacante?

DRSGetNCChanges requiere permisos de replicación sobre el objeto dominio:
- `DS-Replication-Get-Changes` (00299570-246d-11d0-a768-00aa006e0529)
- `DS-Replication-Get-Changes-All` (1131f6ad-9c07-11d1-f79f-00c04fc2dcd2)

Por defecto estos permisos solo los tienen los Domain Controllers, Domain Admins y Enterprise Admins. Pero si un atacante consigue estos permisos (via WriteDACL, por ejemplo), puede ejecutar DCSync.

### Diferencia con extraer NTDS.dit

| | DCSync | NTDS.dit |
|--|--------|----------|
| **Método** | Protocolo de replicación | Acceso directo al archivo |
| **Requiere acceso físico al DC** | No | Sí |
| **Detectabilidad** | Event ID 4662 (replicación desde IP no-DC) | Muy ruidoso (Shadow Copy) |
| **Selectividad** | Puede pedir hashes individuales | Todo o nada |

### Por qué krbtgt es el hash más valioso

Con el hash de `krbtgt` se pueden forjar **Golden Tickets** — TGTs válidos para cualquier usuario, con cualquier privilegio, sin contactar el KDC. La única mitigación efectiva es resetear el hash de krbtgt **dos veces** (por la replicación de DCs).

---

## Comandos de referencia

> El operator log paso a paso vive en `execution/`. Aquí, los comandos núcleo de cada técnica.

### AS-REP Roasting

```bash
# Con PowerView
Get-DomainUser -UACFilter DONT_REQ_PREAUTH

# Resultado: lista de usuarios donde PreAuthNotRequired=True
```

```bash
# Con Impacket GetNPUsers.py
python3 GetNPUsers.py -dc-ip 10.0.2.10 -usersfile users.txt ATACKCORP/ -format john -outputfile hashes.txt

# Crack con John
john --wordlist=wordlist.txt hashes.txt
```

### Kerberoasting

```bash
# Enumerar SPNs
python3 GetUserSPNs.py -dc-ip 10.0.2.10 ATACKCORP/user:pass

# Pedir TGS y guardar
python3 GetUserSPNs.py -dc-ip 10.0.2.10 ATACKCORP/user:pass -request

# Crack
hashcat -m 13100 tgs.txt wordlist.txt
```

### DCSync

```bash
# Con Impacket secretsdump.py (desde cuenta con permisos Replicate)
python3 secretsdump.py -dc-ip 10.0.2.10 ATACKCORP/admin:pass@10.0.2.10

# Output: todos los hashes, incluyendo krbtgt
```

## Equivalencia CS ↔ Sliver

| Operación | Cobalt Strike | Sliver | Notas |
|-----------|---|---|---|
| **AS-REP Roasting** | Impacket via CS | `GetNPUsers.py` (Sliver shell) | Ambos usan Impacket |
| **Kerberoasting** | `shell GetUserSPNs.py` | `GetUserSPNs.py` | Mismo comando |
| **DCSync** | `dcsync` (builtin CS) | `shell secretsdump.py` | CS integrado; Sliver via Python |
| **Crack hashes** | John/Hashcat | John/Hashcat | Same tools |
| **Pass-the-Hash** | `pth` command | `pth` equivalent | Different syntax |

---

## MITRE ATT&CK

| Táctica | Técnica | ID | Lab-01 |
|---------|---------|----|----|
| Credential Access | OS Credential Dumping | T1003.006 | DCSync |
| Credential Access | Steal or Forge Kerberos Tickets | T1558 | Kerberoasting, AS-REP |
| Lateral Movement | Use Alternate Authentication Material | T1550 | Pass-the-Hash, Pass-the-Ticket |
| Persistence | Forged Web Credentials | T1606 | Golden Ticket |

---

## Golden Ticket — Por qué falla en entornos modernos


### Fundamento

El TGT está cifrado con el hash de `krbtgt`. Si conocemos ese hash, podemos **forjar** un TGT para cualquier usuario, con cualquier grupo, con cualquier SID, sin contactar el KDC.

```
krbtgt hash + usuario + grupos → TGT forjado → acceso como DA
```

### Por qué falló en este lab

Windows Server 2016+ implementa **PAC Validation** — el servicio de destino contacta al KDC para verificar el PAC del ticket antes de conceder acceso. Si el ticket fue forjado offline, el KDC detecta inconsistencias.

**Específicamente:** El KDC verifica que el `LogonTime` y otros campos del PAC sean consistentes con lo que él emitió. Un ticket forjado con campos incorrectos falla la validación.

### Mitigaciones modernas

- **PAC Validation** (Windows Server 2016+) — verifica tickets con el KDC
- **Protected Users Security Group** — deshabilita RC4, requiere AES256
- **KRBTGT AES keys** — hace el cracking del hash mucho más difícil
- **Credential Guard** — protege los hashes en memoria con Hyper-V

### Alternativas al Golden Ticket

| Técnica | Requisito | Detectabilidad |
|---------|-----------|----------------|
| Diamond Ticket | krbtgt hash | Baja (modifica PAC existente) |
| Sapphire Ticket | krbtgt hash | Muy baja (copia PAC real) |
| Certificado DA (ADCS) | CA comprometida | Baja |
| Shadow Credentials | GenericWrite | Baja |

---

## Tradecraft & OPSEC — Principios para operar en AD


### Regla 1: Kali antes que Windows

Siempre priorizar operaciones desde Kali sobre ejecutar binarios en el objetivo. `bloodhound-python` desde Kali genera solo tráfico LDAP legítimo. `SharpHound.exe` en el DC genera eventos de proceso y puede ser detectado por AV/EDR.

### Regla 2: LOLBins antes que herramientas externas

Antes de subir Mimikatz, intentar con `reg save HKLM\SAM`. Antes de subir PowerView, intentar con `net user /domain` y `nltest`.

### Regla 3: Entender qué logs genera cada comando

| Acción | Event ID | Log |
|--------|----------|-----|
| Autenticación correcta | 4624 | Security |
| Autenticación fallida | 4625 | Security |
| TGT emitido | 4768 | Security (DC) |
| TGS emitido | 4769 | Security (DC) |
| DCSync (DRSGetNCChanges) | 4662 | Security (DC) |
| Nuevo proceso | 4688 / Sysmon 1 | Security / Sysmon |
| Acceso a objeto AD | 4662 | Security (DC) |
| Cambio en DACL | 4670 | Security |
| Miembro añadido a grupo | 4728/4732 | Security |
| GPO modificada | 5136 | Security |

### Regla 4: Limpiar artefactos

- Eliminar binarios subidos al objetivo
- Eliminar SPNs añadidos para Targeted Kerberoasting
- Eliminar tareas GPO añadidas
- Eliminar archivos en SYSVOL
- Limpiar historial de PowerShell (`Clear-History`, `Remove-Item (Get-PSReadlineOption).HistorySavePath`)

### Regla 5: Timing

- Operar durante horario de negocio si el objetivo tiene alertas fuera de horario
- Operar fuera de horario si el objetivo tiene más monitorización durante el día
- Espaciar solicitudes de tickets para evitar patrones anómalos

---

### OPSEC por técnica

### AS-REP Roasting
- **Sigiloso:** Solicitudes TGT sin preauth son normales (usuarios sin smartcard)
- **Riesgo:** Volume de requests anómalo es detectable

### Kerberoasting
- **Sigiloso:** Cualquier usuario puede pedir TGS (comportamiento normal)
- **Riesgo:** Múltiples TGS para mismo SPN en poco tiempo → sospechoso

### DCSync
- **Sigiloso:** Si tienes permisos legítimos, es invisible
- **Riesgo:** Sin permisos, replication requests generan alertas (Event 4662, Replication Change Notification)

---

## Key Takeaways

1. **Kerberos no es magia:** Es un sistema de tickets intercambiables. Hashes = poder.
2. **PreAuthNotRequired es peligro:** AS-REP es crackeabilidad garantizada.
3. **Cualquier usuario puede Kerberoast:** No necesitas privilegios, solo autenticación.
4. **DCSync = game over:** Krbtgt hash permite Golden Tickets, persistencia indefinida.
5. **Equivalencia CS/Sliver:** Mismas herramientas (Impacket), sintaxis diferente.

---

*Theory · Lab-01 Ghost Forest · Kerberos Foundation*

## Referencias


- [MS-KILE: Kerberos Protocol Extensions](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-kile)
- [MS-DRSR: Directory Replication Service Remote Protocol](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-drsr)
- [MITRE ATT&CK — APT29](https://attack.mitre.org/groups/G0016/)
- [SpecterOps BloodHound Documentation](https://bloodhound.readthedocs.io/)
- [Harmj0y — The Most Important BloodHound Update Ever](https://blog.harmj0y.net/)
- [Sean Metcalf — Kerberos & Attacks 101](https://adsecurity.org/)

---

*Operación GHOST FOREST — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*

---

*Technique · Lab-01 Ghost Forest · fusión theory+tradecraft (anatomía v3.1)*