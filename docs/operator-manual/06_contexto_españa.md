# Manual del Operador — Contexto España: Defensas, Cultura, Marco Legal

> **Clave:** España ≠ USA. Defensas, cultura, regulaciones son distintas.  
> **Importancia:** Adaptación al contexto local es diferenciador de profesional.

---

## 1. Marco Legal Español: LORGPD y Penal

### LORGPD (Ley Orgánica de Regulación y Garantía de Derechos Digitales)

**Artículo clave:** Protección de datos personales como derecho fundamental.

**Implicación para red team:**
- Acceso a datos personales = requiere justificación legal exhaustiva
- Información de clientes, empleados, etc. = sensible
- Exfiltración = delito grave (incluso con autorización, si hay datos)

**Requisitos:**
- RoE DEBE estar firmado (no oral, no email vago)
- Especificación clara de qué datos se pueden tocar
- GDPR-compliant data handling

### Tipo Penal 197 CP (Acceso No Autorizado)

```
Art. 197 CP:
"El que, sin autorización y sabiendo que no la tiene,
acceda a un sistema informático ajeno...
será castigado con pena de 1 a 2 años de cárcel
y multa de 6.000 a 30.000 euros."

EXCEPCIONES (defensa legal):
  ✓ RoE firmado (autorización previa)
  ✓ Dentro del scope acordado
  ✓ Sin daño intencional
  ✓ Documentación de conformidad

CRÍTICO: Sin RoE = eres criminal
```

**Cómo protegerse legalmente:**
1. RoE FIRMADO por representante legal cliente
2. Documentación de fecha/hora (engagement log)
3. Respeto estricto a scope
4. Abogado que revise antes de lanzar

---

## 2. Regulación Sectorial Española

### PCI-DSS (Pagos, tarjetas de crédito)

**Aplica a:** Empresas que procesan pagos, tiendas online

**Defensa típica:**
- Firewall dedicado para PCI
- Segmentación estricta (cardholder data network separada)
- MFA obligatorio
- Auditoría anual externa

**Implicación operacional:**
- PCI network es FORTIFIED
- Lateral movement es bloqueado deliberadamente
- Si objetivo es PCI data: vector debe ser insider o tercero

### ISO 27001 (Seguridad de información)

**Muy común en España:** 70% de medianas tienen certificación.

**Defensa típica:**
- Procesos formales de auditoría
- Logs centralizados
- Incident response plan
- Cambios controlados

**Implicación operacional:**
- Defensa está documentada (puedes revisar documentación pública)
- Cambios son lentos (seguridad es "formal", no real-time)
- Procesos = oportunidades (cambios de contraseña, deployments, etc.)

---

## 3. Características de Empresas Españolas

### Jerarquía y decisiones TOP-DOWN

**Estructura típica:**
- Directivo decide defensa/inversión
- IT implementa (sin input mucho)
- Cambios son LENTOS

**Implicación operacional:**
- CEO contactó = decisión hecha
- Cambio de defensa = semanas (no días)
- Phishing al C-level es muy efectiva

### Confianza interpersonal es clave

**Cultura española:**
- Red de contactos importa
- "Yo te conozco de..." abre puertas
- Social engineering es EFECTIVA

**Implicación operacional:**
- Phishing "personalized" funciona muy bien
- Pretexting vía LinkedIn = tasa alta éxito
- Insider recruitment es viable (relaciones)

### Horarios laborales regulares

**Típico:**
- 9:00-18:00 (algunos 8:00-16:00)
- Fin de semana = sin monitoring
- Fuera de horario = defensa DÉBIL

**Implicación operacional:**
- Ejecuta operaciones críticas fuera horario (21:00-08:00)
- Phishing enviado viernes 18:00 = menos monitoreado
- Cambios de defensa son implementados en horario laboral

---

## 4. Defensas comunes en España por tamaño

### Startup (10-50)
- Defender default (a menudo deshabilitado)
- No firewall
- AWS sin WAF
- Sin SOC
- Developers con acceso amplio

**Vector primario:** RCE web  
**OPSEC:** Baja

### Pyme (50-500)
- Defender ACTIVO
- Firewall básico (Sophos, Fortinet)
- No SIEM
- "Security by compliance" (no real)
- Acceso a shares públicas

**Vector primario:** Phishing dirigida  
**OPSEC:** Media

### Mediana (500-2000)
- EDR posible (Sentinel One, CrowdStrike)
- Firewall sofisticado
- SIEM básico (Splunk)
- SOC 1-2 personas
- Auditoría anual

**Vector primario:** Insider/Supply chain  
**OPSEC:** Alta

### Grande (2000+)
- EDR sofisticado
- SIEM central
- SOC 24/7
- Incident response plan
- Auditoría constante

**Vector primario:** Insider + recursos  
**OPSEC:** Muy alta

---

## 5. Herramientas específicas usadas en España

### EDR/XDR típicos

**Microsoft Defender for Endpoint (MDE)** — 50% de medianas
- Detección de beacon
- PowerShell logging (Event 4104)
- Credential dumping alerts
- **Defensa principal contra:** Mimikatz, Sliver obvio

**CrowdStrike Falcon** — 30% de grandes
- Behavioral analytics
- Threat intelligence integrado
- Respuesta más rápida

**Sentinel One** — 20% startups/medianas
- Ransomware-focused
- Menos sofisticado que MDE

### SIEM típicos

**Splunk Enterprise** — 60% grandes
- Logs exhaustivos
- Alertas en tiempo real
- Caro ($$$)

**Microsoft Sentinel** — 30% medianas
- Cloud-based
- Integrado con Office 365
- Alertas en AD login anómalo

**ELK Stack** — 20% startups/dev
- Open source
- Logs pero sin análisis sofisticado

---

## 6. Tácticas específicas para contexto español

### Phishing dirigida a nivel ejecutivo

**Por qué funciona en España:**
- Ejecutivos abren email personal
- Confianza en contactos
- Menos training de seguridad

**Táctica:**
```
Identificar: CEO/CFO vía LinkedIn
Crear: Email de "banco" o "regulatory body"
Asunto: "Acción urgente requerida"
Link: Página falsa que parece legítima

Ejemplo:
  From: noreply@bancespaña.es (spoofed)
  Subject: "Su cuenta fue accesada. Verificar identidad"
  Tasa de éxito: 40-50% (muy alta)
```

### Aprovecha "cambios de contraseña" como vector

**Contexto español:**
- Empresas hacen cambios de password regularmente
- IT notifica por email
- Empleados están "expecting" algo

**Táctica:**
```
Envía email que parece de IT:
  "Cambio de política de contraseña requerido.
   Por favor, click aquí para actualizar password."
   
Página maliciosa captura credenciales
Tasa: 30-40% (muy efectiva)
```

### Targeting de terceros proveedores

**Por qué:** Proveedores tienen acceso pero defensa débil

**Ejemplo en España:**
- Proveedor de limpieza (acceso a oficinas)
- Proveedor IT (acceso a sistemas)
- Gestoría (acceso a datos financieros)

**Táctica:**
```
1. Identifica proveedor clave
2. Ataca proveedor (defensa más débil)
3. Usa acceso proveedor para entrar a cliente
4. Tasa de éxito: 60% (menos defensas)
```

---

## 7. Tiempo y estacionalidad en España

### Mejor timing para operaciones

```
PEOR timing (máxima alerta):
- Enero (nuevo año, auditoría)
- Abril (impuestos)
- Septiembre (inicio fiscal)
- Diciembre (auditoría año)

MEJOR timing (mínima alerta):
- Junio-julio (vacaciones, skeleton crew)
- Agosto (país en vacaciones)
- Viernes 18:00 (no monitoreado)

APROVECHA:
- Cambios de personal (onboarding, acceso temporal)
- Períodos de cambio de defensa (nuevo EDR, migración)
```

---

## 8. Reguladores y entidades españolas

### Si cliente es "regulated"

**Bancos de España (regulador):**
- Obliga reporte si hay breach
- Inspecciones periódicas

**Agencia Española de Protección de Datos (AEPD):**
- Regulador de GDPR España
- Multas hasta 20 millones € por violación

**Implicación:**
- Cliente es más "sensible" a seguridad
- Deben reportar detecciones a regulador
- Engagement debe ser "documentado a la perfección"

---

## 9. Checklist pre-engagement: Contexto España

```
Legal/Regulatorio:
☐ RoE está FIRMADO (no email, documento formal)
☐ Firma es de representante legal (no IT manager)
☐ Scope está claramente definido (IN/OUT específico)
☐ Datos personales: ¿permitido tocar?
☐ Abogado ha revisado RoE

Temporal:
☐ Timing no es en período "alerta máxima"
☐ Fridays OK, Mondays mejor evitar
☐ Verano = mejor (skeleton crew)

Cultural:
☐ Entiendes jerarquía cliente (quién decide)
☐ Insider mapping completado (LinkedIn)
☐ Relaciones españolas mapeadas

Técnico:
☐ EDR específico identificado
☐ Defensa estimada (startup/pyme/grande)
☐ OPSEC strategy es apropiada para tamaño
☐ Evasión techniques preparadas
```

---

*Manual del Operador · Capítulo 06: Contexto España*  
*Versión 1.0 — Legal-first, cultural, contextual*