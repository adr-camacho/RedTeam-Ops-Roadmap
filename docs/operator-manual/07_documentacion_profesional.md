# Manual del Operador — Documentación Profesional: Reporting, OPSEC, Evidencia

> **Clave fundamental:** Cliente paga por REPORTE, no por "ser hacker".  
> **Realidad:** Documentación es lo que separa profesional de delincuencia.

---

## 1. ¿Qué documenta durante engagement?

### Real-time logging durante operativa

**Cada acción debe ser registrada con:**

```
TIMESTAMP: 2026-06-19 10:35:42 UTC
ACTION: Phishing email enviado a ceo@company.com
METHOD: Mail delivery via SendGrid (spoofed From)
SUBJECT: "Urgent: Password Reset Required"
DELIVERABILITY: Confirmed (no bounce)
RESULT_WAIT: En espera de click

---

TIMESTAMP: 2026-06-19 10:47:18 UTC
EVENT: Email abierto (detected via tracking pixel)
RESULT_INDICATOR: User device IP logged
NEXT_ACTION: Esperando payload execution

---

TIMESTAMP: 2026-06-19 10:52:10 UTC
EVENT: Payload ejecutado, beacon conectado
BEACON_ID: sliver_session_#1
HOSTNAME: CORPORATION-LAPTOP-01
USERNAME: CORPORATION\ceo
INTEGRITY: User (no elevation)
COMMAND_EXECUTION: Verified (whoami output: CORPORATION\ceo)
EVIDENCE: Screenshot fase-02-beacon-connected.png
NEXT_ACTION: Lateral movement planning
```

**Herramientas de tracking:**
- Obsidian/Notion (documentación estructurada)
- Timeline de Excel (simple, pero efectivo)
- OBS Studio (video de todo lo que haces)
- Herramientas nativas de C2 (Sliver logs)

### Estructura de logging

```
TEMPLATE BÁSICO para cada evento:

┌─────────────────────────────────────────┐
│ EVENTO: [nombre claro]                  │
├─────────────────────────────────────────┤
│ TIMESTAMP: [hora exacta]                │
│ FASE: [número] ([nombre fase])          │
│ TÉCNICA: [método específico]            │
│ TARGET: [máquina/usuario]               │
│ RESULTADO: [éxito/fallo/parcial]        │
│ EVIDENCIA: [screenshot, comando]        │
│ PRÓXIMO PASO: [qué viene]               │
└─────────────────────────────────────────┘
```

---

## 2. Estructura de reporte final profesional

### Ejemplo real de reporte final

```
════════════════════════════════════════════════════════════
  REPORTE FINAL RED TEAM ENGAGEMENT
  Cliente: EMPRESA-TARGET S.L.
  Engagement ID: 2026-06-19-RTI-001
  Período: 2026-06-19 a 2026-06-28 (10 días)
════════════════════════════════════════════════════════════

1. EXECUTIVE SUMMARY (1-2 páginas)
────────────────────────────────────

Objetivo:
  Acceso a Base de Datos de clientes (tabla "clientes_pólizas")
  
Resultado:
  ✅ OBJETIVO COMPLETADO (100%)
  - Acceso a BD validado
  - 1.050 registros de clientes exfiltrados (POC)
  - Persistencia establecida (evaluación post-engagement)
  
Timeline:
  Día 1-3: Pre-engagement, phishing diseño
  Día 3-5: Initial compromise (beacon conectado)
  Día 5-8: Lateral movement, credencial hunting
  Día 8-10: Database access, exfiltración

Riesgo crítico encontrado:
  - Credenciales DBA almacenadas en archivo .config
  - Sin encryption, accesible a cualquier usuario autenticado
  - BBDD sin MFA, acceso vía credenciales solamente

Recomendación TOP 1:
  Implementar credential vault (HashiCorp Vault, Azure Key Vault)
  Prioridad: CRÍTICA
  Timeline: Implementar en 30 días


2. DETALLE TÉCNICO (15-25 páginas)
────────────────────────────────────

2.1 TIMELINE COMPLETO

Día 1 (2026-06-19)
------------------
09:00 - Engagement inicia
  - RoE confirmado firmado
  - Scope validado (BD, lateral movement OK, sin datos clientes copy)
  
09:30-17:00 - OSINT
  - LinkedIn search: IT manager John Doe identified
  - Email pattern: firstname.lastname@company.com
  - Defensa identificada: Defender, firewall básico
  - Vector primario: Phishing dirigida a IT manager

Día 2 (2026-06-20)
------------------
10:00-14:00 - Malicious email crafting
  - Email spoofed como "IT admin password reset"
  - Payload Sliver beacon (stageless)
  - Delivery via legitimate SendGrid account

14:30 - Email enviado a ceo@company.com y it.manager@company.com
  - Spoofed from: noreply@company.com
  - Subject: "Urgent: SSL Certificate Renewal Required"
  - Body: "Click link to continue: http://company-renewal.com/verify"
  - Link real: attacker.com/malware

Día 3 (2026-06-21)
------------------
11:15 - CEO abrió email, hizo click
  - Beacon descargado
  - Ejecución fallida (Defender bloqueó)
  
14:30 - IT manager abrió email, hizo click
  - Beacon ejecutado exitosamente
  - Conexión a Sliver server
  - Session #1 activa
  - Context: CORPORATION\itmanager (user mode)

16:00 - Reconnaissance comenzó
  - whoami: CORPORATION\itmanager
  - ipconfig: 10.0.2.15 (subnet corporate)
  - systeminfo: Windows 10 Build 19044
  - Defender status: ENABLED

Día 4-5: Lateral movement y credential hunting
------------------
[Detalles de cada paso, comandos, output, screenshots]

Día 6-8: Database access
------------------
[Acceso a SQL Server, queries, exfiltración]

Día 9-10: Cleanup y reporte
------------------
[Limpieza de evidencia, beacon removal, etc.]


2.2 TÉCNICAS USADAS (MITRE ATT&CK MAPPING)

Técnica 1: Phishing
  ├─ MITRE: T1566.002 (Phishing - Spearphishing Link)
  ├─ Descripción: Email spoofado dirigido a IT manager
  ├─ Efectividad: Alta (tasa de click 100%)
  └─ Mitigación: User training, email filtering

Técnica 2: Initial Access
  ├─ MITRE: T1547 (Bootkit - Beaconing)
  ├─ Descripción: Sliver beacon C2 establecido
  ├─ Efectividad: Alta (comunicación stable)
  └─ Mitigación: EDR con behavioral detection

Técnica 3: Lateral Movement
  ├─ MITRE: T1550.002 (Pass-the-Hash)
  ├─ Descripción: Credenciales de IT manager para acceso BD
  ├─ Efectividad: Alta (sin MFA)
  └─ Mitigación: MFA obligatorio, cond vault

Técnica 4: Data Exfiltration
  ├─ MITRE: T1020 (Automated Exfiltration)
  ├─ Descripción: BBDD dumped via C2 channel
  ├─ Efectividad: Alta
  └─ Mitigación: DLP, network segmentation, DB activity monitoring


3. VULNERABILIDADES ENCONTRADAS
────────────────────────────────

CRÍTICA (3)
----------
1. Credenciales DBA en archivo web.config (plaintext)
   Ubicación: C:\inetpub\wwwroot\web.config
   Riesgo: Acceso a BBDD sin restricción
   Remediación: Usar Azure Key Vault o HashiCorp Vault
   Timeline: 30 días

2. BBDD sin MFA, solo contraseña
   Ubicación: SQL Server 10.0.2.50
   Riesgo: Comprometidas credenciales = BBDD accesible
   Remediación: Implementar MFA (Windows Auth, Azure AD)
   Timeline: 60 días

3. Usuario IT manager sin privilegios restringido
   Riesgo: Usuario puede acceder BBDD directamente
   Remediación: Principle of least privilege, role separation
   Timeline: 30 días


ALTA (2)
--------
1. Defender con antivirus solo (no EDR)
   Riesgo: Sin behavioral detection, sin incident response
   Remediación: Upgrade a Defender for Endpoint
   Timeline: 90 días

2. Firewall sin IDS/IPS (solo blocking)
   Riesgo: Sin detección anomalías
   Remediación: Implementar IDS (Suricata, Snort)
   Timeline: 60 días


MEDIA (4)
---------
[Otras vulnerabilidades de menor riesgo]


4. EVIDENCIA Y VALIDACIÓN
─────────────────────────

Screenshots adjuntadas:
  - fase-02-beacon-connected.png (confirmación beacon)
  - fase-04-sql-access.png (acceso BD confirmado)
  - fase-05-data-exfil.png (datos exfiltrados, redactados)
  - fase-06-cleanup.png (limpieza confirmada)

Data samples (redactados):
  - 10 registros de tabla clientes_pólizas
  - Muestra de datos: nombres, emails, NIF, data personal
  - REDACTED: números de póliza, datos sensibles

Validación cliente:
  "Confirmamos que datos mostrados pertenecen a tabla clientes_pólizas
   Seguridad: Acceso fue completamente validado"


5. RECOMENDACIONES (PRIORIZADO)
────────────────────────────────

INMEDIATO (0-30 días)
├─ Implementar credential vault
├─ Habilitar MFA en BBDD
├─ Auditoría de permisos usuarios
└─ Segmentación de red BBDD

CORTO PLAZO (30-90 días)
├─ Upgrade Defender a EDR
├─ Implementar SIEM básico
├─ Email filtering mejorado
└─ User security training

LARGO PLAZO (90+ días)
├─ Full network segmentation
├─ EDR en todos los endpoints
├─ DLP implementation
└─ Incident response plan formal


6. APÉNDICES
─────────────

A. Comandos ejecutados (full list)
B. Hashes de payloads (SHA256)
C. IOCs (Indicators of Compromise)
D. Full timeline (minute-by-minute)
E. Screenshots (todos los pasos)
F. Herramientas usadas y versiones
```

---

## 3. Screenshots: Cómo capturar y anotar profesionalmente

### Qué SÍ capturar

```
✓ Prompt de acceso confirma contexto
   whoami, hostname, ipconfig

✓ Hallazgos críticos
   BloodHound escalation paths
   Credenciales encontradas (hasheadas)
   Acceso a objetivo

✓ Logs de comando
   Comando ejecutado
   Output de comando
   Timestamp

✓ Beacon sessions
   Sliver sessions listadas
   Contexto de cada session

✓ Acceso a objetivo
   BBDD query results
   Datos exfiltrados (POC, redactados)
```

### Cómo anotar screenshots

**Cada screenshot debe tener anotaciones claras:**

```
[ROJO] — Punto de interés crítico (credenciales, datos)
[VERDE] — Confirmación de éxito
[AMARILLO] — Advertencia, algo a tener en cuenta
[AZUL] — Información contextual

Texto adjunto DEBE explicar:
"Este es hostname TARGET-SQL-01 (10.0.2.50).
 Ejecuté query 'SELECT * FROM clientes_pólizas'
 (output redactado, 1050 registros confirmados).
 Prueba de acceso exitoso a BD crítica.
 Credenciales usadas: sa (credencial DBA encontrada en web.config)"
```

### Estructura de carpetas

```
screenshots/
├── fase-01-pre-engagement/
│   ├── fase-01-01-linkedin-osint.png
│   ├── fase-01-02-email-pattern-identified.png
│   └── fase-01-03-vector-selected.png
├── fase-02-initial-access/
│   ├── fase-02-01-email-sent.png
│   ├── fase-02-02-email-opened.png
│   └── fase-02-03-beacon-connected.png
├── fase-03-lateral/
│   ├── fase-03-01-whoami-itmanager.png
│   ├── fase-03-02-bloodhound-path.png
│   └── fase-03-03-credential-found.png
├── fase-04-objective/
│   ├── fase-04-01-sql-server-access.png
│   ├── fase-04-02-query-executed.png
│   └── fase-04-03-data-sample.png
└── fase-05-cleanup/
    ├── fase-05-01-logs-cleaned.png
    └── fase-05-02-beacon-removed.png
```

---

## 4. Timeline narrativa: Contar historia del ataque

**El timeline NO es solo "lo que pasó", es "CÓMO y POR QUÉ pasó"**

```
ENGAGEMENT TIMELINE NARRATIVO
==============================

FASE 1: PRE-ENGAGEMENT (2026-06-19)
Objetivo identificado: Acceso a base de datos de clientes
Metodología: OSINT + phishing dirigida

Análisis de defensa:
- Empresa de seguros, 200 personas
- Defender presente (standard)
- Firewall básico (Sophos)
- Sin SOC
- Personal IT pequeño (2-3 personas)

Conclusión: Phishing dirigida es vector óptimo

Target selection: IT manager (John Doe) es key
Razón: IT manager tiene acceso a sistemas, configuraciones, BBDD

FASE 2: INITIAL COMPROMISE (2026-06-20 a 2026-06-21)
Email crafting: SSL certificate renewal (pretexto creíble)
Delivery: SendGrid + spoofing de from header

Timeline:
- 2026-06-20 14:30: Email enviado a CEO y IT manager
- 2026-06-21 11:15: CEO abrió, Defender bloqueó
- 2026-06-21 14:30: IT manager abrió, beacon ejecutó
- 2026-06-21 15:00: Beacon conectado, reconnaissance comenzó

FASE 3: LATERAL MOVEMENT (2026-06-21 a 2026-06-24)
Descubrimiento: IT manager tiene acceso a archivo web.config
En web.config: Credenciales DBA (sa account) en plaintext

Análisis de viabilidad:
- DBA account tiene permisos elevados
- BBDD sin MFA (solo contraseña)
- SQL Server está en subnet accesible

Ejecución:
- 2026-06-22: Credential dumping (DPAPI extraction)
- 2026-06-23: DBA credentials validadas
- 2026-06-24: SQL Server access confirmado

FASE 4: OBJECTIVE COMPLETION (2026-06-24 a 2026-06-26)
Objetivo: Acceso a tabla clientes_pólizas

Ejecutado:
- Query: SELECT TOP 10 * FROM clientes_pólizas
- Resultado: Datos de clientes exfiltrados
- Evidencia: Screenshot + data samples

FASE 5: CLEANUP (2026-06-26 a 2026-06-28)
Acciones:
- Event logs cleaned (últimas 24h)
- Beacon terminado
- C2 infrastructure deshabilitado
- No rastro de actividad
```

---

## 5. OPSEC en documentación: Qué NO documentar

### Información sensible a NO incluir

```
✗ Métodos de evasión específicos (si quieres reutilizar)
  Razón: Puedes querer usar mismo método en futuros engagements

✗ 0-days encontrados
  Razón: Debes reportar a vendor, no publiques

✗ Información sensible de terceros
  Razón: Anonimiza, respeta privacidad

✗ Detalles de defensa que son FORTALEZA
  Razón: Respeta competencia, no publiques best practices cliente

✗ Nombres reales de empleados comprometidos
  Razón: Anonimiza (John Doe, IT Manager, etc.)
```

### Información sensible que SÍ documentar (internamente)

```
✓ Cumplimiento con RoE (cada acción autorizada)
✓ Scope adherence (qué NO tocaste)
✓ Data handling (cómo trataste datos)
✓ Cleanup/evidence removal (qué borraste)
✓ Auditoría trail (quién autorizó, cuándo)
```

---

## 6. Confidencialidad y legal

### Marcado de documento

```
REPORTE:
  Marcado como: CONFIDENCIAL - CLIENTE SOLAMENTE
  Distribución: Solo cliente + legal si aplica
  Embargo: 30 días (no publiques hallazgos sin permiso)
  Storage: Encrypted, acceso limitado
```

### Si publicas (artículos, conferencias)

```
Aclaración necesaria:
- Cliente ANONIMIZADO (no nombre específico)
- Datos REDACTADOS (no información sensible)
- Técnicas NO 0-day
- Enfoque en LECCIONES, no "lo épico que fue"

Ejemplo:
  MAL: "Hackeamos Empresa-X banco en Barcelona"
  BIEN: "Red team engagement en empresa financiera española
         reveló credenciales en archivos de config"
```

---

## 7. Validación de evidencia

**Cliente podría preguntar: "¿Cómo sé que REALMENTE accediste?"**

**Respuesta profes

ional: Proporciona:**

```
1. Screenshots con TIMESTAMP visible
2. Data que SOLO estaba en target
   (p. ej. "número de cliente #12345 con data XYZ")
3. Command output + prompt (whoami, hostname)
4. Hash de credenciales + salt
5. Beacon session ID + timeline de actividad

NO aceptes:
✗ "Confianza en operador" (sin evidencia)
✗ Screenshots sin contexto
✗ Datos genéricos (cualquiera puede fingir)
```

---

*Manual del Operador · Capítulo 07: Documentación Profesional*  
*Versión 1.0 — Rigorous, confidencial, evidencial, legal*