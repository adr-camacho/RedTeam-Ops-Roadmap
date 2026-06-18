# Detection — C2 (Black Beacon)

> **Lab-08 · C2 Foundations**  
> Enfoque: Blue team. Cómo detecta un defensor que hay un C2 activo, cómo caza sesiones, qué telemetría observa.  
> Propósito: Entender **la otra cara de la moneda** para operar sin activar alarmas en CRTO.

---

## 1. La Premisa

**En el examen CRTO, Defender está ACTIVO y monitoreado.**

Para operar sin perder tu beacon en 5 minutos, debes entender:
- Qué comportamiento es observable
- Qué tools generan ruido
- Cuándo un defensor ve tu beacon

Este documento es el **"enemigo"** que debes evitar.

---

## 2. Detección de Tráfico C2 (Red Level)

### 2.1 JA3 / JARM Fingerprinting

**¿Qué es?**

JA3 es un fingerprint de **TLS client** basado en los parámetros que envía el cliente HTTPS.

Cada herramienta (navegador, beacon, malware) tiene una "firma TLS" única:
- Versión TLS
- Cipher suites soportados
- Extensions en order específico
- Parámetros de elliptic curves

**Ejemplo:**
```
# JA3 de Chrome 120
9fa2b6d44be47584e87e6f346d6b5b05

# JA3 de Cobalt Strike beacon default
17c3107d73e06e7b2a7f8a3c4d1e2f9b
```

Defender/EDR almacena fingerprints de **herramientas conocidas** (incluido Cobalt Strike).

**Detección:**
```
TLS traffic detected from beacon.exe
JA3: 17c3107d73e06e7b2a7f8a3c4d1e2f9b
MATCH: Cobalt Strike signature ⚠️
```

**JARM** es lo mismo pero para **TLS server** (tu listener).

### 2.2 Patrón de Beaconing

Un beacon **no navega como un usuario humano**. Sus conexiones son mecánicas:

**Patrón observable:**
- Conexión cada 30-60 segundos (con jitter)
- Tamaño de request similar (payload pequeño)
- Tamaño de response similar (output comprimido)
- Horario consistente (no duerme a las 2 AM como usuario)
- URLs repetidas exactamente
- User-Agent idéntico en todas las requests

**Ejemplo EDR detects:**
```
[Anomalous Traffic Pattern]
Host: WKSTN-01
Process: svchost.exe (spoofed, real parent unknown)
Destination: 10.0.2.15:443

Behavior:
- Connection every 32 ± 2 seconds for 2 hours
- POST /static/...png every time
- Response always 4 KB
- No human user interaction preceding requests
- User-Agent: Mozilla/5.0 ... (pero proceso is svchost, no browser)

VERDICT: Command & Control detected
```

**Cómo evitarlo:**
- Jitter mayor (±50% or more)
- Occasional larger transfers (simular usuario descargando)
- URLs variadas (rotar entre legítimas)
- Sleep más largo durante horarios no-trabajo

### 2.3 Certificate Pinning / Certificate Analysis

Si el beacon usa HTTPS self-signed:

```
TLS Certificate Analysis:
Subject: CN=beacon.local
Issuer: CN=beacon.local (self-signed)
Valid: 2024-01-01 to 2026-01-01
⚠️ Self-signed certificate (uncommon for legitimate traffic)
⚠️ No revocation checks (suspicious)
VERDICT: Likely C2
```

**Cobalt Strike mitigación:** Usar certificados válidos (Let's Encrypt válido, o ingeniería social para obtener cert legítimo).

---

## 3. Detección a Nivel de Host (Proceso/Comportamiento)

### 3.1 Anomalías de Proceso

**Indicador: Proceso anómalo abre conexión de red**

```
[Process Anomaly]
Process: calc.exe (sospechoso: calculadora no debería hablar a red)
Network: TCP/443 a 10.0.2.15:443
Parent Process: explorer.exe (esperado) o desconocido (muy sospechoso)
Privileges: SYSTEM (injected beacon, elevated)
VERDICT: Probable beacon or malware
```

**Event ID (Windows):**
- **3 (Sysmon):** Network connection detected
- **5156 (Windows Security):** Outbound connection allowed
- **4688 (Windows Security):** Process created

**Ejemplo Sysmon Event 3:**
```
<Event>
  <System>
    <EventID>3</EventID> <!-- Network Connection -->
  </System>
  <EventData>
    <Image>C:\Windows\System32\svchost.exe</Image>
    <DestinationPort>443</DestinationPort>
    <DestinationIp>10.0.2.15</DestinationIp>
    <InitiatingUser>SYSTEM</InitiatingUser>
  </EventData>
</Event>
```

**Por qué es sospechoso:**
- svchost (sistema) no debería iniciar conexiones externas (excepto Windows Update)
- El DestinationIp es una IP interna de atacante, no Microsoft

### 3.2 Inyección de Procesos (Process Injection)

Muchos beacons se inyectan en procesos benignos para evadir:
- `svchost.exe`
- `explorer.exe`
- `msiexec.exe`

**Detección:**

Sysmon Event **8 (CreateRemoteThread)** o **11 (Image Loaded)**:

```
<Event>
  <EventID>8</EventID> <!-- CreateRemoteThread -->
  <SourceImage>C:\Users\user\Desktop\payload.exe</SourceImage>
  <TargetImage>C:\Windows\System32\svchost.exe</TargetImage>
  <TargetThreadId>3456</TargetThreadId>
</Event>

INDICATOR: Suspicious process (payload.exe) injected into system process (svchost)
```

**OPSEC:** Direct execution (sin injection) en proceso legitimado (msiexec) es más silencioso.

### 3.3 Acceso a LSASS (Credential Dumping)

Si el beacon intenta dumpar credenciales vía MiniDump:

```
Event 10 (Sysmon - Process Access):
SourceImage: beacon.exe (o injected parent)
TargetImage: C:\Windows\System32\lsass.exe
GrantedAccess: 0x1410 (PROCESS_VM_READ | PROCESS_QUERY_INFORMATION)

DETECTION: Unauthorized process accessing LSASS
ACTION: Block + Alert
```

**OPSEC:** Evitar MiniDump si LSASS tiene PPL activado; usar alternativas como DPAPI/registry dumping.

---

## 4. Detección de Ejecución de Comandos

### 4.1 PowerShell Logging (Event 4104)

Si el beacon ejecuta PowerShell:

```
Event 4104 (PowerShell Script Block Logging):
Message: PowerShell script detected:
Command: whoami ; ipconfig /all ; tasklist

DETECTION: Suspicious command sequence (recon indicators)
```

**Signature patterns:**
```
(whoami) AND (ipconfig) AND (net group)
→ Domain reconnaissance
VERDICT: Operator activity, not user
```

**OPSEC:** 
- Usar `cmd.exe` en lugar de PowerShell cuando sea posible
- Si PowerShell es necesario, ofuscar comandos
- En CRTO con defensa alta, expect que todo PowerShell es logged

### 4.2 Process Execution Monitoring (Event 1 / Sysmon Event 1)

```
Event 1 (Sysmon - Process Create):
Image: C:\Windows\System32\cmd.exe
CommandLine: cmd.exe /c whoami
ParentImage: ??? (desconocido, sospechoso)
User: SYSTEM
Initiated: 14:32:15 (fuera de horas de trabajo, sospechoso)

DETECTION: Unusual process execution
```

**Patrón a buscar:**
```
Parent: svchost.exe → Child: cmd.exe
VERDICT: Suspicious (svchost no debería lanzar cmd)
```

---

## 5. Detección de Persistencia (Más adelante, pero relevante)

Una vez que el beacon tiene persistencia, **genera más traces:**

```
Registry Persistence:
HKLM\Software\Microsoft\Windows\CurrentVersion\Run
Value: "Updates" = "C:\Temp\malware.exe"

DETECTION: Registry modification for persistence
ACTION: Block execution + Quarantine
```

```
Scheduled Task Persistence:
Task: "WindowsUpdate"
Trigger: Every 5 minutes
Action: "C:\Temp\beacon.exe"

DETECTION: Suspicious scheduled task (non-Microsoft)
ACTION: Delete task + Investigate
```

---

## 6. Sigma Rules / KQL (Ejemplos)

### 6.1 Detección de Beacon HTTPS Beaconing

**SIGMA Rule (pseudo):**
```yaml
title: Suspicious HTTPS Beaconing
detection:
  selection:
    - Network_Connection:
        DestinationPort: 443
        Image:
          - svchost.exe
          - explorer.exe
          - msiexec.exe
        Frequency: Every 30-60 seconds
        Jitter: Small variance
  condition: selection
action: Alert + Monitor
```

### 6.2 Sysmon Event 3 + Pattern

```
event.code:3
AND
(process.name: svchost.exe OR process.name: explorer.exe)
AND
(destination.port: 443 OR destination.port: 8080)
AND
timespan: 30 to 60 seconds between connections
AND
NOT (destination.ip: Microsoft.* OR destination.ip: Windows-Update.*)

→ Likely C2 Beacon
```

---

## 7. Indicadores de Detección (IoCs)

Un defensor busca estos **indicadores concretos:**

| IoC Type | Ejemplo | Contexto |
|----------|---------|---------|
| IP Destination | 10.0.2.15 (listener) | C2 server IP |
| JA3 Hash | 17c3107d73e06e7b | Cobalt Strike TLS sig |
| Domain/URL | evil.com/static/image.png | Beacon C2 domain |
| Process Name | svchost.exe (injected) | Anomalous parent/context |
| Registry Key | HKLM\..\Run\Malware | Persistence |
| Scheduled Task | WindowsUpdate (suspicious) | Persistence |
| File Hash (MD5) | d41d8cd98f00b204e9800998ecf8427e | Known malware |

---

## 8. EDR / Defender Telemetry en CRTO

### En el examen:

**Defender está ACTIVO:**
- Real-time protection: ON
- Tamper Protection: ON
- Cloud-delivered protection: ON (reports to Microsoft)
- Script-based detection: ON
- Behavioral analysis: ON

**Lo que Defender monitorea:**
- File creation/modification
- Registry changes
- Network connections
- Process creation
- PowerShell commands (4104 logging)
- Memory injection attempts

**Esperar delays:**
- Initial detection: 30-60 segundos (local)
- Cloud analysis: 1-5 minutos (hash analysis)
- Action taken: 2-10 minutos (puede fallar beacon)

**OPSEC implication:** Operar rápido en los primeros minutos (priv-esc, lateral) antes de que Defender se dé cuenta. Persistencia es crítica.

---

## 9. MITRE ATT&CK (Detección)

| Técnica | Indicador | Data Source |
|---------|-----------|-------------|
| T1105 (Ingress Tool Transfer) | Descarga de archivo + ejecución | File monitoring, Process execution |
| T1071.001 (HTTP/HTTPS traffic) | Conexión a puerto 443 | Network monitoring, Sysmon 3 |
| T1573 (Encrypted channel) | TLS handshake análisis | JA3 fingerprinting |
| T1059.001 (PowerShell) | Script execution | Event 4104 logging |
| T1053.005 (Scheduled Task) | Task creation/modification | Event 4698 (Task scheduled) |
| T1547.001 (Registry Run) | Registry modification | Event 4657 (Registry modified) |

---

## 10. Resumen: Cómo No Ser Detectado

| Aspecto | Qué evitar | Qué hacer |
|--------|-----------|-----------|
| **Tráfico** | Sleep 5s, user-agent default, TLS sig obvio | Sleep 45-60s, user-agent legítimo, cert válido o Malleable C2 |
| **Proceso** | Inyección en svchost sin contexto | Ejecutar en proceso legítimo (msiexec) o usuario creíble |
| **Commands** | PowerShell en masa, whoami/ipconfig seguidos | Espaciar commands, usar cmd.exe, ocultar intención |
| **Persistencia** | Registry Run valores obvios, scheduled tasks "Malware" | Nombres creíbles (WindowsUpdate, SvcHostUpdate) |
| **Timing** | Reconocimiento a las 2 AM (usuario offline) | Simular comportamiento de usuario (horario trabajo) |

---

*Detection · Lab-08 Black Beacon · 18/06/2026*