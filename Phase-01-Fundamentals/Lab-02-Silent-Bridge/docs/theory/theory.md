# Theory — Web RCE, Pivoting & C2 Over Tunnel

> **Lab-02 · Silent Bridge**  
> Bloque CRTO: External Recon, Initial Compromise (Web RCE), Pivoting, C2

---

## 1. Web Application as Entry Point

Lab-02 comienza **fuera del dominio** (externa): enumeras una aplicación web (Webmin), identificas RCE, obtienes foothold en un servidor Windows interno.

**Flujo:**
1. Recon externo: descubres Webmin en puerto 10000
2. RCE: Webmin tiene vulnerabilidad explotable sin autenticación
3. Foothold: reverse shell en servidor Windows
4. Pivotaje: servidor Windows puede alcanzar otras máquinas internas
5. C2: Sliver beacon a través del pivote

---

## 2. Webmin RCE Vulnerability

### ¿Qué es Webmin?

Herramienta de administración de Linux vía web. Si no está patcheada, tiene vulnerabilidades de RCE que permiten ejecutar comandos del SO directamente.

### Explotación

```bash
# Ejemplo: Command injection en parámetro de Webmin
curl "http://target:10000/cgi/rpc.cgi?action=...&cmd=id"

# O vía Metasploit/custom exploit
# Resultado: salida de comando ejecutado como usuario webmin (often root)
```

### Impacto

RCE sin autenticación = acceso inmediato al SO. Desde aquí, instalas beacon o shell reversa.

---

## 3. Tunneling & Pivoting: From External to Internal

### El Problema

Una vez que tienes RCE en servidor Windows, **no puedes alcanzar directamente el dominio** (DC, WKSTN, etc.) desde tu máquina de ataque externa.

**Solución:** Tunelado (SOCKS proxy) a través del servidor comprometido.

### Tipos de Tunneling

| Tipo | Protocolo | Use Case | OPSEC |
|------|-----------|----------|-------|
| **SOCKS5** | TCP | Proxificar tráfico cualquiera | Detectable (puerto abierto) |
| **SSH Tunnel** | SSH (22) | Tunelado sobre SSH | Bueno si SSH legítimo |
| **DNS Tunnel** | DNS (53) | Covert channel | Muy sigiloso |
| **HTTP/HTTPS Tunnel** | HTTP/443 | Imitar navegación | Bueno si puerto 443 permitido |

### Ligolo-ng (usado en Lab-02)

Ligolo-ng es un tunneler moderno que:
- Ejecuta agente en servidor comprometido
- Abre SOCKS5 proxy en tu máquina
- Propaga tráfico del agente a través del tunnel
- Permite atacar red interna sin enrutamiento

**Flujo:**
```
Tu Kali → Ligolo Agent (Windows) → DC/WKSTN/DNS (red interna)
        └─ SOCKS5 proxy 127.0.0.1:1080
```

---

## 4. C2 Through Tunnel

Una vez que tienes tunnel SOCKS5, puedes **dirigir Sliver beacon a través del proxy**:

```bash
# En Kali, listener escucha en localhost
sliver > https -l 127.0.0.1 -p 8443

# Payload generado apunta a 127.0.0.1:8443 (que es tunelado a través de Ligolo)
sliver > generate --https 127.0.0.1:8443

# Ejecutas payload en servidor Windows comprometido
# Beacon conecta a 127.0.0.1:8443 (que es tu Kali)
# Pero el tráfico de red real va:
# Windows Beacon → Ligolo Agent → Ligolo Server (tu Kali) → Sliver C2
```

---

## 5. Equivalencia CS ↔ Sliver

| Operación | Cobalt Strike | Sliver | Notas |
|-----------|---|---|---|
| **Web RCE** | Impacket vía payload | Same (shell + reverse) | RCE es independiente de C2 |
| **Tunneling** | Beacon SOCKS | Ligolo-ng agent | CS integrado; Sliver vía herramienta externa |
| **C2 over tunnel** | Listener en proxy | Listener local + proxy | Mismo concepto |
| **Pivoting** | `beacon -p 8080` | Ligolo relay | Different naming |

---

## 6. MITRE ATT&CK Mapping

| Táctica | Técnica | ID | Lab-02 |
|---------|---------|----|----|
| Initial Access | Exploit Public-Facing Application | T1190 | Webmin RCE |
| Execution | Command and Scripting | T1059 | RCE commands |
| Defense Evasion | Proxy | T1090.004 | SOCKS tunnel via Ligolo |
| Command & Control | Non-Standard Port | T1571 | Beacon vía tunnel |
| Lateral Movement | Remote Service Session Hijacking | T1570 | Pivoting a través de agente |

---

## 7. OPSEC: Webmin + Tunneling

### Webmin RCE
- **Riesgo:** Logs del servidor (Webmin access logs, syslog)
- **Mitigación:** Ofuscar payload, borrar logs tras foothold

### SOCKS Tunneling
- **Riesgo:** Tráfico inusual (procesos sospechosos, conexiones de red)
- **Mitigación:** Ejecutar agente como servicio, usar puerto legítimo si es posible

### C2 over Tunnel
- **Riesgo:** Doble capa (tunnel + beacon) genera más telemetría
- **Mitigación:** Sleep/jitter aún más importante; minimizar comandos

---

## 8. Key Takeaways

1. **Web apps son entry point real:** No siempre comienza por phishing; a menudo por RCE web.
2. **Tunneling es fundamental:** Para operar en red segmentada, necesitas pivote.
3. **Ligolo (o equivalente) es herramienta crítica:** No es opcional si hay segmentación.
4. **C2 a través de tunnel = latencia extra:** Comandos más lentos, ajusta expectations.

---

*Theory · Lab-02 Silent Bridge · Web RCE & Pivoting*