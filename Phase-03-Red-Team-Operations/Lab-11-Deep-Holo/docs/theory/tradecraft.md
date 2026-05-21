# Tradecraft — Operación DEEP HOLO
## Lab-11: Infraestructura C2 Profesional, Redirectors y Domain Fronting

**Operación:** DEEP HOLO | **Adversario:** Lazarus Group | **Nivel:** Red Team Operations  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [Infraestructura C2 profesional — Arquitectura](#1-infraestructura-c2)
2. [Redirectors — Ocultar el teamserver](#2-redirectors)
3. [Domain Fronting — CDN como escudo](#3-domain-fronting)
4. [Categorización de dominios](#4-categorización-de-dominios)
5. [Pivot Listeners — C2 en redes segmentadas](#5-pivot-listeners)
6. [Detección y resiliencia de la infraestructura](#6-detección-y-resiliencia)
7. [OPSEC — Infraestructura de grado APT](#7-opsec)

---

## 1. Infraestructura C2 Profesional — Arquitectura

### Por qué el teamserver no puede ser el punto de contacto directo

En un engagement real, el teamserver es el activo más valioso — contiene toda la información del engagement, los beacons, el historial de comandos. Si el Blue Team lo descubre e identifica su IP, puede:
- Bloquear la IP en el firewall
- Contactar al proveedor de hosting para derribar el servidor
- Extraer logs para análisis forense

La solución es nunca exponer el teamserver directamente — siempre usar capas intermedias.

### Arquitectura de infraestructura C2 profesional

```
Operador
    ↓ VPN cifrada
Teamserver (IP desconocida, en VPS privado)
    ↑
Redirector 1 (VPS sacrificable) ← Agente en víctima
Redirector 2 (CDN/Domain Fronting)
    ↑
Beacon en víctima
```

### Componentes de la infraestructura

| Componente | Función | Características |
|-----------|---------|-----------------|
| **Teamserver** | Control central | IP oculta, solo accesible por operadores via VPN |
| **Redirectors** | Relay de tráfico | IPs sacrificables, fáciles de reemplazar |
| **Long Haul** | Persistencia larga | Check-in infrecuente (días), perfil muy sigiloso |
| **Short Haul** | Operaciones activas | Check-in frecuente, más capacidades |
| **Staging** | Entrega del payload | Server temporal para entregar el beacon inicial |

### Separación de infraestructura por función

Un engagement profesional tiene múltiples servidores con funciones distintas:

```
staging.attacker.com → entrega el beacon inicial (se quema si se detecta)
c2-long.attacker.com → comunicación de persistencia (muy sigiloso)
c2-active.attacker.com → operaciones activas (más ruidoso, aceptable)
phishing.attacker.com → credenciales (se quema tras el uso)
```

---

## 2. Redirectors — Ocultar el teamserver

### ¿Qué es un redirector?

Un redirector es un servidor intermedio que recibe las conexiones del beacon y las reenvía al teamserver real. Si el Blue Team descubre el redirector, solo obtiene una IP sacrificable — el teamserver permanece oculto.

### Tipos de redirectors

#### Dumb Pipe (reenvío simple)

```bash
# socat — redirige todo el tráfico del puerto 443 al teamserver
socat TCP4-LISTEN:443,fork TCP4:TEAMSERVER_IP:443

# iptables
iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination TEAMSERVER_IP:443
iptables -t nat -A POSTROUTING -j MASQUERADE
```

Ventaja: simple. Desventaja: el redirector reenvía todo — si el Blue Team envía tráfico de análisis, llega al teamserver.

#### Smart Redirector con Apache/Nginx

Un redirector inteligente solo reenvía tráfico que coincide con el perfil C2 y devuelve respuestas legítimas al resto:

```apache
# Apache mod_rewrite — redirector inteligente
RewriteEngine On

# Solo reenviar si el User-Agent coincide con el perfil del beacon
RewriteCond %{HTTP_USER_AGENT} "Mozilla/5.0.*Windows NT 10.0.*WebKit"
RewriteCond %{REQUEST_URI} "^/api/v1/update"
RewriteRule ^(.*)$ https://TEAMSERVER_IP$1 [P,L]

# Todo lo demás → sitio legítimo (no revela el teamserver)
RewriteRule ^(.*)$ https://microsoft.com/en-us/ [R=302,L]
```

#### Caddie — Redirector especializado para C2

```bash
# Caddie filtra tráfico basándose en reglas avanzadas
# Solo reenvía si:
# - User-Agent coincide
# - URI coincide con el perfil
# - No proviene de rangos IP conocidos de sandboxes
# - No proviene de ASNs de proveedores de seguridad
```

---

## 3. Domain Fronting — CDN como escudo

### ¿Cómo funciona Domain Fronting?

Domain Fronting abusa de la arquitectura de los CDNs. Cuando un CDN recibe una petición HTTPS, el SNI (Server Name Indication) en el handshake TLS indica el dominio frontal, pero el header HTTP `Host` indica el dominio real.

```
Beacon → HTTPS a cdn.cloudfront.net (SNI = cdn.cloudfront.net)
    ↓ dentro del túnel TLS cifrado
    Host: mi-teamserver.cloudfront.net  ← el CDN redirige aquí
```

El proxy corporativo ve:
- Conexión HTTPS a `cdn.cloudfront.net` — legítimo (Amazon CDN)
- No puede ver el header Host dentro del TLS

El CDN redirige internamente al teamserver real sin que la víctima o el proxy lo sepan.

### Estado actual del Domain Fronting

La mayoría de CDNs grandes han bloqueado Domain Fronting:
- **AWS Cloudfront** — bloqueado desde 2018
- **Azure CDN** — bloqueado
- **Google Cloud CDN** — bloqueado

CDNs que aún lo permiten (puede cambiar):
- Algunos CDNs de Azul, Fastly, Cloudflare (con configuración específica)
- CDNs regionales menos conocidos

### Alternativa: Domain Hiding

En lugar de Domain Fronting, usar CDNs que permiten configurar el origen backend sin revelar su IP:

```
Beacon → CDN (cloudflare.com/proxy) → Teamserver (IP oculta detrás del CDN)
```

Cloudflare Proxy oculta la IP del origen — incluso si el Blue Team intenta resolver el dominio del teamserver, obtiene IPs de Cloudflare, no del servidor real.

---

## 4. Categorización de dominios

### Por qué la categoría del dominio importa

Los proxies corporativos filtran el tráfico por categoría del dominio. Un dominio recién registrado o sin categoría es bloqueado automáticamente.

### Estrategias de categorización

#### Domain aging

Registrar el dominio 6-12 meses antes del engagement, generar tráfico orgánico (artículos de blog, presencia en redes sociales) para que el dominio sea indexado y categorizado.

#### Comprar dominios expirados

Dominios expirados que tenían buena reputación pueden comprarse en subastas:
- Ya están categorizados
- Tienen historial de tráfico legítimo
- Pueden tener backlinks que aumentan la credibilidad

```bash
# Herramientas para buscar dominios expirados con buena categoría
# DomCop, ExpiredDomains.net, GoDaddy Auctions

# Verificar categoría del dominio antes de comprar
# Bluecoat: https://sitereview.bluecoat.com/
# Cisco Talos: https://talosintelligence.com/reputation_center
# Fortiguard: https://www.fortiguard.com/webfilter
```

---

## 5. Pivot Listeners — C2 en redes segmentadas

### El problema de las redes segmentadas

En entornos con segmentación, un beacon en la red interna puede no tener acceso directo a Internet. El beacon necesita comunicarse con el teamserver a través de un pivote con acceso a ambas redes.

### Tipos de Pivot Listeners

#### Reverse Port Forward

El beacon en la red interna conecta al beacon en la red DMZ, que actúa como relay:

```
Teamserver ← DMZ beacon ← Firewall ← Internal beacon
    ↑              ↑
Internet       Red DMZ        Red interna
```

```
# En Sliver — configurar reverse port forward
rportfwd add -b 10.0.3.200:8080 -r 127.0.0.1:443

# El beacon interno conecta a 10.0.3.200:8080
# El beacon DMZ reenvía a localhost:443 → teamserver
```

#### SOCKS Proxy via Beacon

```
# Configurar SOCKS proxy a través del beacon DMZ
socks5 start -P 1080

# Beacon interno usa el SOCKS proxy del beacon DMZ
# para llegar al teamserver
```

#### Bind Listener

En lugar de que el beacon conecte al teamserver (reverse), el teamserver conecta al beacon (bind). Útil cuando el beacon no puede iniciar conexiones salientes pero puede recibir conexiones entrantes.

---

## 6. Detección y resiliencia de la infraestructura

### Cómo el Blue Team detecta la infraestructura C2

1. **IDS/IPS** — firmas de beacons conocidos en el tráfico
2. **Proxy logs** — dominios contactados, frecuencia, patrones
3. **Threat intel** — IPs y dominios en listas negras
4. **Análisis de certificados** — certificados auto-firmados o recién emitidos
5. **JA3/JA3S fingerprinting** — fingerprint del handshake TLS

### Resiliencia de la infraestructura

Diseñar la infraestructura asumiendo que partes de ella serán descubiertas:

```
Si el redirector es descubierto:
→ Reemplazarlo por otro en minutos (automatizar con Terraform/Ansible)
→ El teamserver sigue oculto y operativo

Si el dominio de C2 es bloqueado:
→ Cambiar a dominio de backup (pre-configurado en el beacon)
→ Domain Parking — el beacon tiene lista de dominios de fallback

Si el beacon es detectado:
→ El teamserver sigue operativo
→ Re-desplegar beacon desde otro vector
```

### JA3 Fingerprinting

JA3 genera un hash del handshake TLS que puede identificar el cliente independientemente de las IPs o dominios:

```
# Evitar JA3 conocidos de C2 frameworks
# Sliver por defecto tiene un JA3 conocido

# Solución: usar TLS randomization
# Modificar el orden de cipher suites para cambiar el JA3
```

---

## 7. OPSEC — Infraestructura de grado APT

### Principios de Lazarus Group para infraestructura C2

1. **Compartimentación** — cada operación usa infraestructura separada
2. **Rotación rápida** — si se compromete algo, sustituir en horas
3. **Nunca reutilizar infraestructura** — cada engagement usa IPs/dominios nuevos
4. **Infraestructura as Code** — desplegar con Terraform para rapidez
5. **Pago anónimo** — VPS pagados con crypto para dificultar atribución

### Terraform para infraestructura C2 rápida

```hcl
# Desplegar redirector en Digital Ocean en minutos
resource "digitalocean_droplet" "redirector" {
  image  = "ubuntu-22-04-x64"
  name   = "redirector-01"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  
  provisioner "remote-exec" {
    inline = [
      "apt-get install -y socat apache2",
      "socat TCP4-LISTEN:443,fork TCP4:${var.teamserver_ip}:443 &"
    ]
  }
}
```

### Checklist de infraestructura pre-engagement

```
□ Teamserver en VPS con pago anónimo
□ VPN del operador al teamserver configurada
□ Redirectores desplegados (2+ para resiliencia)
□ Dominios comprados (aged o categorizados)
□ Certificados SSL válidos (Let's Encrypt)
□ Perfiles de tráfico configurados
□ Dominios de fallback en el beacon
□ Backup del teamserver
□ Plan de contingencia si se quema la infraestructura
```

---

## Referencias

- [Red Team Infrastructure Wiki](https://github.com/bluscreenofjeff/Red-Team-Infrastructure-Wiki)
- [Domain Fronting via Cloudfront](https://digi.ninja/blog/cloudfront_domain_fronting.php)
- [MITRE ATT&CK — Lazarus Group](https://attack.mitre.org/groups/G0032/)
- [Terraform para infraestructura Red Team](https://github.com/ralphte/build_a_phish)

---

*Operación DEEP HOLO — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*