# Manual del Operador — Pre-Engagement: Recon, Planificación, Decisiones Previas

> **Fase crítica:** 0-7 días  
> **Duración típica:** 3-14 días  
> **Salida:** Plan operacional detallado, vector identificado, RoE firmado

---

## 1. ¿Qué es Pre-Engagement?

**Pre-engagement** es todo lo que haces ANTES de comprometer el primer sistema.

No es "entrar al sistema". Es **recon, análisis, planificación, decisiones estratégicas**.

**Realidad:** A menudo **60-70% del tiempo de engagement** es pre-engagement puro.

### Por qué es crítico

Pre-engagement bien hecho = engagement exitoso. Pre-engagement mal hecho = fallo garantizado.

Si apresuras esta fase:
- ❌ Perderás vectores más efectivos
- ❌ Perderás información de defensa
- ❌ Ejecutarás técnicas contra defensa equivocada
- ❌ Ejecución rápida pero inefectiva

Si lo haces bien:
- ✅ Identificas vector ÓPTIMO
- ✅ Entiendes defensa antes de atacar
- ✅ Planificación realista de timeline
- ✅ Escalada segura a objetivo

---

## 2. Recon Pasivo: Descubrir sin tocar

### Fase 2.1: Open Source Intelligence (OSINT) — Humano

**Objetivo:** Descubrir estructura, empleados clave, patrones.

#### LinkedIn profiling

```
Estrategia: Buscar empleados de empresa-target

Búsqueda específica:
1. CEO/C-level (para social engineering)
2. IT staff (para phishing dirigida)
3. Security officer (para entender defensa)
4. Empleados recientemente cambiados (disconformes?)

Información a extraer:
- Nombres completos
- Emails (si están en perfil)
- Antecedentes (trabajos anteriores, skills)
- Relaciones (quién habla con quién)
- Fotos (para phishing más convincente)

Herramienta: LinkedIn stalker (búsquedas avanzadas)
Tiempo: 2-4 horas por empresa
Resultado: Lista de 10-20 targets personales
```

#### Redes sociales & HUMINT

```
Facebook, Twitter, Instagram:
- Empleados publican sobre vacaciones, ubicaciones
- Eventos de empresa (convenciones, team building)
- Información personal que revela rutinas

Método:
- Busca empleados encontrados en LinkedIn
- Recopila fotos, horarios, información personal
- Identifica patrones (horarios de trabajo, cafeterías habituales)

Caso de uso: Social engineering telefónico
- Llamas a recepción: "Soy John, volví de las vacaciones en Mallorca..."
- Recepcionista te reconoce por foto/info = credibilidad
```

#### Búsqueda de empleados "disconformes"

```
LinkedIn:
- "Empleado recientemente dejó EMPRESA-TARGET"
- Contacta: "Vi que trabajaste en X, ¿cómo era ambiente de seguridad?"
- Respuesta = información operativa real (defensa, sistemas, etc.)

Twitter/X:
- Busca hashtags como #job, #hiring, #leftmyjob
- Empleados disconformes tweetan sobre problemas, defensa débil, etc.
- Oro puro de información

Implicación operacional:
- Insider disconforme = potential vector (dinero/venganza)
- Información real sobre defensa = invaluable
```

### Fase 2.2: Open Source Intelligence (OSINT) — Técnico

#### Dominios, DNS, registros públicos

```
Objetivo: Mapear infraestructura, proveedores, tecnologías

Comandos:
$ whois company.com
  → Registrar (GoDaddy, Namecheap, etc.)
  → Contacto administrativo
  → Fecha de registro (antigüedad = organización establecida)

$ nslookup company.com
$ dig company.com
  → Nameservers (quién hospeda DNS)
  → MX records (proveedor email: Gmail, Office365, Exchange local?)
  → SPF/DKIM/DMARC (email security posture)

$ nslookup -type=MX company.com
  Typical response:
  - office365.com (Microsoft cloud = Office 365)
  - mail.company.com (self-hosted = complex, múltiples servers)
  - Gmail (Google Workspace)

Implicación operacional:
- Office365 = cloud, potencial phishing avanzado
- Mail.company.com = local server, potencial RCE
```

#### Reconocimiento de subdominios

```
Objetivo: Encontrar servicios expuestos (VPN, admin panels, test servers)

Herramientas:
- Shodan (búsqueda de servicios)
- Censys (búsqueda de certificados SSL)
- TheHarvester (emails + subdomains)
- Recon-ng (automated OSINT)

Ejemplo Shodan:
$ shodan search company.com
  → Resultados: servicios expuestos públicamente
    - port 3389 (RDP) en IP X.X.X.X
    - Apache 2.2.15 en www.company.com (old, exploitable)
    - VPN Citrix en vpn.company.com (potential exploitation)

Implicación operacional:
- RDP expuesto = potencial brute force
- Apache viejo = CVE conocido, RCE directo
- Citrix = VPN, si comprometes, tienes acceso directo a red interna
```

#### Búsqueda de vulnerabilidades conocidas

```
Paso 1: Identifica tecnologías
- Shodan: Apache 2.2.15, PHP 5.2, IIS 7
- whois: Hosting provider (AWS, Digital Ocean, etc.)
- DNS: Servicios en cloud (Office365, Salesforce, etc.)

Paso 2: Búsqueda de CVEs
$ searchsploit "Apache 2.2.15"
$ nvd.nist.gov (búsqueda por CVE)

Resultado:
- CVE-2013-1896: Apache 2.2.15 remote memory access
- Código de exploit disponible en Exploit-DB
- Severidad: HIGH

Implicación operacional:
- Conoces vulnerabilidad específica
- Tienes exploits listos
- Vector directo sin depender de phishing
```

### Fase 2.3: Reconocimiento Pasivo de Defensa

**Objetivo:** Descubrir qué defensa existe SIN triggering alertas.

#### Fingerprinting de WAF (Web Application Firewall)

```
Técnica: Enviar requests específicas, analizar respuesta

Herramientas:
- wafw00f (WAF detection)
- curl (manual fingerprinting)

Ejemplo:
$ wafw00f https://company.com
  Resultado: Cloudflare WAF detected
  Implicación: requests son proxificadas, IPs reales ocultas

Si no hay WAF:
- Requests van directo al server
- Más fácil explotar vulnerabilidades
- Menos defensa en perimeter
```

#### Detección de IDS/IPS (Intrusion Detection/Prevention)

```
Técnica: Enviar payloads que típicamente triggerean IDS, ver si hay respuesta

Indicadores:
- Request bloqueada (HTTP 403, 406)
- Timeout anómalo
- Conexión cerrada sin respuesta

Ejemplo:
$ curl -v "https://company.com/?param=<script>alert(1)</script>"
  
Si respuesta es 403 o timeout → IDS probablemente presente
Si respuesta es normal → poco/nada de IDS

Implicación operacional:
- IDS presente = payload debe ser evasivo
- No IDS = payloads pueden ser más obvios
```

### Fase 2.4: Reconocimiento de Red (si está permitido)

```
Prerequisito: RoE debe permitir network scanning

Técnica: Nmap scan (pasivo-ish, aunque noisy)

Comandos:
$ nmap -sn 10.0.0.0/24 (ping scan, identifica hosts activos)
$ nmap -sS -p 22,80,443,3389 10.0.0.0/24 (puertos comunes)
$ nmap -sV -p- 10.0.0.0/24 (service version detection, LENTO)

Resultado esperado:
- IPs activas
- Puertos abiertos
- Servicios (SSH, HTTP, RDP, LDAP)
- Versiones aproximadas

ADVERTENCIA:
- Nmap es NOISY (genera logs)
- Si hay IDS activo, será detectado
- Usar solo si RoE lo permite explícitamente
```

---

## 3. Social Engineering Reconnaissance (HUMINT)

### Fase 3.1: Pretexting (Mentir para obtener información)

**Objetivo:** Extraer información mediante engaño telefónico/email.

#### Llamada a recepción (pretexting clásico)

```
Escenario: "Soy del equipo IT, he perdido la contraseña"

Guion:
"Hola, soy [nombre creíble], estoy fuera de oficina y necesito resetear
mi contraseña para acceder a email. ¿Cuál es el patrón de emails de
la empresa? ¿firstname.lastname@ o algo diferente?"

Objetivo:
- Confirmar patrón de email (firstname.lastname, fn.lastname, etc.)
- Confirmación de que IT existe
- Información de estructura organizacional

Variante: "Necesito confirmar departamentos para el directorio..."
Resultado: Lista de departamentos, nombres, jerarquía

Variante: "¿Quién es el contacto de IT? Necesito reportar un problema..."
Resultado: Nombres específicos de IT staff para phishing dirigido
```

#### Email pretexting (phishing de pre-engagement)

```
Email de prueba (NO payload, solo info gathering):

From: noreply@company.com (spoofed)
To: it@company.com
Subject: "Urgent: Password Policy Update - Action Required"

Body:
"Please confirm your current password policy by clicking below:
[link a dominio fake que captura datos]"

Si hacen click:
- Confirmación: usan ese email
- Si captura password: credenciales reales
- Información: Qué tan conscientes están de phishing

IMPORTANTE: Debe estar autorizado en RoE (muy específico)
```

### Fase 3.2: Open Source Building (OSINT personas)

#### Búsqueda de información personal

```
Proceso para cada empleado clave:

1. Nombres completos, títulos, departamentos (LinkedIn)
2. Búsqueda en Google, Bing
3. Búsqueda en redes sociales
4. Información financiera (si es ejecutivo, búsqueda de propiedades)
5. Información de viajes, hobbies, familia

Caso de uso: Spear phishing más convincente
- "Hola John, vi que eres fan de Barcelona FC, vimos tu foto..."
- Credibilidad personal = mayor tasa de click

OPSEC: No dejes rastro de que buscaste esto
- Usa VPN
- No sincronices accounts
- Mantén separado los perfiles de investigación
```

---

## 4. Rules of Engagement (RoE): Documento Legal Crítico

### ¿Qué es RoE?

**RoE es el contrato legal que define:**
- ✅ Qué SÍ puedes atacar (in scope)
- ❌ Qué NO puedes atacar (out of scope)
- ⚖️ Límites legales, responsabilidades
- 📋 Escala de severidad en respuesta

### Estructura típica RoE

```
RULES OF ENGAGEMENT — ENGAGEMENT_ID
=====================================

1. SCOPE (IN/OUT)

   IN SCOPE:
   - Sistemas de producción de CORPORATION
   - Empleados listados en documento adjunto
   - Email, Active Directory, servidores web
   - Aplicaciones custom (nombreapp.com)
   - Máquinas Windows 10, Windows Server 2022

   OUT OF SCOPE:
   - Servicios de terceros (AWS, Azure, Salesforce) EXCEPTO donde específicamente alojado
   - Sistemas de proveedores externos
   - Clientes de la empresa (datos no atacar)
   - Infraestructura física
   - Personas no autorizadas

2. TÉCNICAS PERMITIDAS

   ✓ Phishing
   ✓ Social Engineering
   ✓ Web exploitation (si es en scope)
   ✓ Lateral movement
   ✓ Credential harvesting
   ✓ Persistence mechanisms (si es en scope, aclarado)

   ✗ Denegación de servicio (DoS)
   ✗ Daño de datos (borrado, corrupción)
   ✗ Exfiltración de datos fuera de lab (salvo POC específico)
   ✗ Acceso a sistemas de backup en producción

3. ESCALA DE RESPUESTA

   Si defensores detectan ataque:
   - Acción 1: Pausa operativa (notificación mutuamente acordada)
   - Acción 2: Briefing (explicar qué intentaban)
   - Acción 3: Continuación si cliente autoriza, o STOP

4. CONTACTOS Y ESCALADA

   Red Team Lead: [nombre, teléfono, email]
   Cliente Contact: [nombre, teléfono, email 24/7]
   Legal/Compliance: [contacto si hay dudas]
   
   En caso de detección: Contactar cliente inmediatamente
   En caso de data sensitivity: Parar, reportar, no exfiltrar

5. DURACIÓN

   Engagement: [fecha inicio] a [fecha fin]
   Extensiones: Solo con email escrito

6. FIRMA

   Cliente: _________________  Fecha: ___________
   Red Team Lead: _________________  Fecha: ___________
   Legal/Compliance: _________________  Fecha: ___________
```

### CRÍTICO: Sin RoE firmado = eres criminal

En España (LORGPD, Tipo Penal 197 CP):
- Acceso no autorizado = delito
- Pena: 1-2 años cárcel + multa
- Sin RoE = no hay "autorización"

**NO inicies NUNCA sin RoE firmado y enviado.**

---

## 5. Selección de Vector: ¿Cuál es el mejor entry point?

### Matriz de decisión: Vectores comunes

```
VECTOR 1: PHISHING (Email + Malware)
=========================================
Ventajas:
  ✓ Simple de ejecutar
  ✓ Tasa de éxito media-alta (30-50% en empresas medianas)
  ✓ Bajo costo técnico
  ✓ Común = menos sospechoso si está bien crafteado

Desventajas:
  ✗ Defender puede bloquear payload
  ✗ Usuario puede reportar
  ✗ Requiere entrega de email (spoofing)
  ✗ No funciona si MFA está activo

Timing: 2-7 días para usuario que caiga
OPSEC: Media (email es auditado, pero sin análisis profundo en medianas)
Mejor para: Empresas medianas sin SOC sofisticado


VECTOR 2: WEB RCE (Aplicación web vulnerable)
===============================================
Ventajas:
  ✓ Directo al servidor
  ✓ Menos dependencia del usuario
  ✓ Acceso rápido si vuln existe
  ✓ Silencioso (usuario no sabe)

Desventajas:
  ✗ Requiere vulnerabilidad conocida o 0-day
  ✗ WAF puede bloquear
  ✗ Logs del servidor capturan exploit
  ✗ Posible detección por IDS

Timing: 1-3 días si vuln es conocida
OPSEC: Media-Alta (servidor logs son críticos)
Mejor para: Startups, aplicaciones legacy


VECTOR 3: VPN/RDP EXPUESTO (Fuerza bruta, default creds)
===========================================================
Ventajas:
  ✓ Acceso directo a red corporativa
  ✓ Usuario real = permisos reales
  ✓ Sin intermediarios

Desventajas:
  ✗ Logs auditados (muy sospechoso)
  ✗ MFA bloqueará (si está activo)
  ✗ Attempt múltiples triggeran alertas
  ✗ Account lockout = defensa sabe

Timing: Minutos-horas si credenciales son débiles
OPSEC: BAJA (todo es auditado, intentos múltiples = obvio)
Mejor para: Infraestructura muy antigua, sin MFA


VECTOR 4: SUPPLY CHAIN (Tercero comprometido)
===============================================
Ventajas:
  ✓ Menos esperado
  ✓ Credibilidad (es proveedores)
  ✓ Acceso a múltiples empresas desde un punto

Desventajas:
  ✗ Requiere identificar proveedor específico
  ✗ Timeline largo
  ✗ Scope puede ser ambiguo

Timing: 10-20 días (requiere identificar target tercero)
OPSEC: Alta (tráfico de proveedor es "normal")
Mejor para: Empresas grandes, múltiples proveedores


VECTOR 5: INSIDER (Compromiso de empleado real)
=================================================
Ventajas:
  ✓ Permisos reales
  ✓ OPSEC perfecta (es empleado)
  ✓ Acceso a información sensible
  ✓ Muy efectivo

Desventajas:
  ✗ Requiere "recruitment" de insider
  ✗ Riesgo legal/ético (más complejo)
  ✗ Insider puede tener second thoughts

Timing: 5-15 días (necesita identificar, contactar, rapport)
OPSEC: Máxima (es acción interna)
Mejor para: Grandes empresas, financieras, objetivo crítico
```

### Decisión operacional: ¿Cuál elegir?

```
Proceso de selección:

Paso 1: Evalúa defensa identificada
  → ¿Hay WAF? (excluye web RCE simple)
  → ¿Hay MFA? (excluye VPN brute)
  → ¿Hay SOC? (phishing debe ser más targeting)

Paso 2: Evalúa timeline
  → ¿Tienes 7 días? Phishing viable
  → ¿Tienes 1-2 días? RCE si existe
  → ¿Tienes 3 semanas? Insider viable

Paso 3: Evalúa viabilidad técnica
  → ¿Existe RCE conocida? Usa RCE
  → ¿No hay vuln clara? Phishing es backup
  → ¿Defensa muy fuerte? Insider

Paso 4: Elige el ÓPTIMO
  - No el más "cool"
  - No el más rápido
  - El que tiene balance: éxito + timeline + OPSEC

Ejemplo decisión real:
  - Empresa: Pyme española, 200 personas
  - Defensa: Defender, firewall básico, sin SOC
  - Timeline: 10 días
  - Objetivo: Acceso a SQL Server

  Decisión: Phishing dirigida a IT staff
  Razón: Sin SOC, phishing funciona, 10 días suficientes
  Backup: RCE si phishing falla después 5 días
```

---

## 6. Plan Operacional: Documento de ejecución

### Estructura del Plan

```
PLAN OPERACIONAL — ENGAGEMENT CLIENTE_X
========================================

1. OBJETIVO OPERACIONAL
   Acceso a BBDD de clientes (table `clientes_pólizas`)
   Objetivo crítico: Exfiltración de 1000+ registros

2. VECTORES IDENTIFICADOS
   
   Vector Primario: Phishing dirigida a IT staff
   - Target: IT manager (LinkedIn: John Doe)
   - Email trigger: "Renovación urgente certificado SSL"
   - Payload: Beacon Sliver stageless
   - Timing: T+2-5 días (esperar click)
   - OPSEC consideraciones: Defender ACTIVO, evasión necesaria
   
   Vector Secundario: RCE en aplicación web
   - Target: company-webapp v3.2 (detectable vía Shodan)
   - Vulnerability: CVE-2024-XXXXX (deserialización insegura)
   - Exploit disponible: Exploit-DB #XXXXX
   - Timing: T+1-3 días
   - OPSEC: WAF puede filtrar, payload debe ser evasivo
   
   Vector Tertiary: SQL Server brute force (si hay exposición)
   - Target: sql.company.com puerto 1433 (detectado en Shodan)
   - Timing: T+0-2 días
   - OPSEC: Logs auditados, attempt límite 10 antes de lockout

3. TIMELINE ESTIMADO
   
   Phishing vector:
   - T+0-1: Setup malicious email
   - T+1-2: Envío y espera
   - T+2-5: Usuario abre, payload ejecuta
   - T+5-7: Lateral movement / credential hunting
   - T+7-10: SQL Server access / objective
   
   Total phishing: 10 días (worst case)

4. OPSEC CONSIDERACIONES
   
   Threat model:
   - Defender ACTIVO en endpoints → evasión obligatoria
   - Sin SOC detectado → respuesta lenta
   - Firewall básico → pivoting sin restricción
   - Logs sin SIEM → histórico pero sin monitoreo real-time
   
   Mitigaciones:
   - Sleep 30-60s entre comandos (no pattern obvious)
   - LSASS dump vía legitimate tools (no mimikatz directo)
   - C2 en puerto 443 (imita HTTPS legítimo)
   - Evitar PowerShell (Event 4104 auditado) → usar cmd.exe

5. ESCALADA CRITERIA
   
   Si phishing no funciona en 5 días:
   → Intenta RCE (vector secundario)
   
   Si RCE tampoco funciona:
   → Intenta SQL brute force (vector tertiary)
   
   Si ninguno funciona:
   → PAUSA, reevalúa (posible defensa más fuerte de lo esperado)
   → Cliente notificado inmediatamente

6. PARADA / ABORT CRITERIA
   
   - Si blue team contacta explícitamente
   - Si infrastructure es dropeada (aislamiento)
   - Si objetivo completado (exfiltración)
   - Si timeline se agota sin progreso técnico
   
   En caso de abort:
   → Limpieza (logs, artifacts)
   → Reporte de hallazgos parciales
   → Recomendaciones de hardening

7. DELIVERABLES
   
   - Reporte final con screenshots y timeline
   - Evidencia de acceso (data samples redactados)
   - MITRE ATT&CK mapping
   - Recomendaciones de remediación
   - Seguimiento de implementación (30 días post-engagement)
```

---

## 7. Preparación técnica

### Infraestructura necesaria

```
ANTES de lanzar, prepara:

☐ C2 Framework
  - Sliver: server levantado, listeners configurados
  - Backup: Havoc o Metasploit si Sliver falla

☐ Payloads
  - Staged (pequeño, rápido descarga)
  - Stageless (completo, más confiable)
  - Compilados y testeados en sandbox

☐ Hosting
  - Servidor web (HTTP para serving payloads)
  - Dominio spoofed (si phishing lo requiere)
  - HTTPS válido (para C2 legítimo)

☐ Wordlists
  - Contraseñas comunes (rockyou + custom)
  - Usernames (encontrados en OSINT)
  - Emails (si necesitas spam)

☐ Anonimato
  - VPN o proxy (separar tráfico operativo)
  - Cuentas creadas con opsec (no vincular a ti)
  - Nombres falsos (dominio, emails)

☐ Documentación
  - Plantilla de screenshots
  - Guión de recon / notas
  - Template de timeline
  - Checklist de OPSEC
```

### Testing previo a lanzamiento

```
ANTES de lanzar contra cliente:

1. Sandbox testing
   - Ejecuta payload en VM aislada
   - Verifica que beacon conecte correctamente
   - Comprueba detección (AV, etc.)

2. Phishing testing (si es el vector)
   - Envía email de test a cuenta propia
   - ¿Delivera? (¿Gmail lo marca spam?)
   - ¿Payload descarga? (¿Defender lo bloquea?)
   - ¿Beacon conecta? (¿Firewall lo filtra?)

3. Network testing (si hay C2 in-house)
   - ¿Listeners responden desde Kali?
   - ¿Beacon session se establece correctamente?
   - ¿Comandos se ejecutan sin lag extremo?

4. OPSEC validation
   - ¿Domains están correctamente spoofed?
   - ¿Email headers no revelan origen?
   - ¿C2 traffic está cifrada?
   - ¿Logs están siendo capturados?

Si algo falla acá → FIX antes de lanzar contra cliente
```

---

## 8. Punto de decisión: ¿Lanzamos o re-planeamos?

### Checklist de go/no-go

```
ANTES DE LANZAR, responde honestamente:

RECON
☐ ¿Recon fue exhaustivo? (OSINT, técnico, social)
☐ ¿Identificaste defensa probable?
☐ ¿Tienes lista de 3+ vectores?
☐ ¿Conoces estructura IT/AD?
☐ ¿Identificaste IT staff clave (para phishing)?

PLANIFICACIÓN
☐ ¿Plan operacional está documentado?
☐ ¿Timeline es realista?
☐ ¿Tengo backup plan si vector primario falla?
☐ ¿Criteria de parada están claras?
☐ ¿Criterios de escalada definidos?

INFRAESTRUCTURA
☐ ¿C2 está testeado y funcional?
☐ ¿Payloads están compilados y testeados?
☐ ¿Servidor web está corriendo?
☐ ¿Anonimato está validado (VPN, proxies)?
☐ ¿Documentación está lista?

LEGAL
☐ ¿RoE está FIRMADO por cliente?
☐ ¿Scope está claramente definido (IN/OUT)?
☐ ¿Tengo aprobación por escrito para phishing/social eng?
☐ ¿Contactos de cliente están disponibles 24/7?
☐ ¿Abogado ha revisado RoE?

OPSEC
☐ ¿Identificaste defensa específica (Defender, EDR, SIEM)?
☐ ¿Tienes estrategia de evasión para esa defensa?
☐ ¿Sleep/jitter está configurado?
☐ ¿Logs están siendo capturados?
☐ ¿Cleanup plan está documentado?

Si TODOS son SÍ → LANZAR
Si ALGUNO es NO → ESPERA, REPARA

Riesgo de lanzar sin estar listo = fallo garantizado
Costo de esperar 1 día más = mitigación de riesgo
```

---

*Manual del Operador · Capítulo 02: Pre-Engagement*  
*Versión 1.0 — Exhaustivo, pragmático, legal-first*