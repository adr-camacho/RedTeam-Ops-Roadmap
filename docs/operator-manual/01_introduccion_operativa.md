# Manual del Operador de Red Team Español — Introducción a la Operativa

> **Versión:** 1.0 (Iterativa)  
> **Ámbito:** España — entorno empresarial europeo  
> **Público:** Operadores de red team, pentesters, especialistas en seguridad ofensiva  
> **Estado:** Vivo — mejora y refinamiento continuo

---

## 1. ¿Qué es un Operador de Red Team?

Un **operador de red team** es un profesional de ciberseguridad que **simula ataques reales** contra infraestructuras empresariales para identificar vulnerabilidades, debilidades operacionales y gaps defensivos.

**NO es:**
- ❌ Script kiddie ejecutando herramientas
- ❌ Hacker malicioso
- ❌ Pentester de "checkbox compliance"

**SÍ es:**
- ✅ Profesional estratégico que piensa como atacante
- ✅ Toma decisiones basadas en contexto, riesgos, objetivos
- ✅ Documenta, reporta, enseña
- ✅ Trabaja dentro de marco legal y ético

---

## 2. Día a Día del Operador: Realidad vs Cine

### Lo que NO es

**Cine:** Hacker en hoodie, 10 pantallas, "hackear en 3 minutos".

**Realidad:** 
- 70% **análisis, espera, documentación**
- 20% **ejecución técnica**
- 10% **manejo de imprevistos**

### Estructura típica de jornada

```
09:00 - Arrive, check alerts/logs de día anterior
09:30 - Planning: ¿qué ejecutar hoy? ¿avances? ¿bloques?
10:00 - Reconnaissance/Intelligence (puede durar horas/días)
12:00 - Pausa
13:00 - Execution (si está lista)
15:00 - Documentación (screenshots, notas, timelines)
16:30 - Reporte avances (manager/cliente)
17:00 - Prep para mañana
```

**Real:**
- A menudo **pasas un día completo en recon** sin tocar nada
- **Esperas** a que se cumpla una condición (usuario login, evento)
- **Documenta todo** — si no está documentado, no pasó
- **Fallas frecuentes** — cambias plan

---

## 3. Mentalidad del Operador: Decisiones Clave

### Pregunta 1: ¿Cuál es el objetivo real?

No es "estar en el sistema". Es:
- Acceso a datos específicos (BBDD, emails, IP, etc.)
- Persistencia a largo plazo
- Movimiento lateral hasta X objetivo
- Demostrativo (proof of concept)

**Decision:** Tu estrategia depende del objetivo.

### Pregunta 2: ¿Cuál es el entorno?

- ¿Empresa pequeña (50 personas) vs grande (5000+)?
- ¿Startup tech vs banca tradicional?
- ¿On-premise vs cloud?
- ¿Segmentación de red?

**Decision:** Entorno define viabilidad de técnicas.

### Pregunta 3: ¿Tengo tiempo o necesito velozidad?

- **Tiempo:** Sigiloso, lento, sin detección
- **Velocidad:** Agresivo, rápido, importa menos OPSEC

**Decision:** Estrategia cambia radicalmente.

---

## 4. Fases Operacionales Reales

### Fase 1: Pre-Engagement (0-7 días)

**Qué haces:**
- Recon pasivo (público: LinkedIn, web, DNS, dominios)
- Social engineering recon (llamadas, emails, OSINT)
- Validación de scope (¿qué está IN/OUT?)
- Planificación de estrategia

**Duración:** A menudo **días completos sin acceso al sistema**

**Decisión clave:** Identificas **vector de entrada óptimo**

---

### Fase 2: Initial Compromise (1-3 días)

**Qué haces:**
- Ejecutas vector (phishing, RCE web, etc.)
- Obtienes **foothold** (acceso a primer sistema)
- Estableces **C2** (command & control)
- Documenta información inicial del sistema

**Duración:** Puede ser **1 hora o 1 semana** (depende de defensa)

**Decisión clave:** ¿Escalas inmediatamente o te establecés quieto?

---

### Fase 3: Post-Exploitation & Reconnaissance (3-10 días)

**Qué haces:**
- Mapeo de red (máquinas, usuarios, servicios)
- Credential hunting (LSASS dump, archivos, registros)
- BloodHound/AD mapping
- Identificas caminos de escalada

**Duración:** **Más tiempo aquí = menos riesgo después**

**Decisión clave:** ¿Cuál es el camino óptimo a objetivo?

---

### Fase 4: Lateral Movement & Escalation (5-15 días)

**Qué haces:**
- Pivotaje entre máquinas
- Movimiento vía Kerberos, RDP, etc.
- Evasión de defensa (Defender, EDR, logs)
- Aproximación a objetivo

**Duración:** **Variable** — puede acelerarse o estancarse

**Decisión clave:** ¿Cuándo es seguro escalar?

---

### Fase 5: Objective Completion & Persistence (1-5 días)

**Qué haces:**
- Acceso a objetivo final (datos, sistema crítico)
- Estableces persistencia (si aplica)
- Cubre trazas (logs, evidencia)
- Documenta "prueba de concepto"

**Duración:** Rápido (minutos) si todo está listo

**Decisión clave:** ¿Persistencia a largo plazo o salida limpia?

---

## 5. Decisiones Operacionales Reales: Árbol de Decisión Simplificado

```
¿Defensa detectó movimiento?
├─ SÍ → ¿Puedo evadirla?
│   ├─ SÍ → Continúo sigiloso
│   ├─ NO → ¿Puedo escalarla?
│   │   ├─ SÍ → Escalo ofensivamente
│   │   └─ NO → ABORT, documenta fallida
├─ NO → ¿Estoy en objetivo?
│   ├─ SÍ → Completa, exfiltración, persistencia
│   └─ NO → Continúa movimiento
```

---

## 6. Lo que Nadie Te Cuenta: Realidad Incómoda

### Fallo es frecuente
- 30-40% de técnicas no funcionan (depende de defensa)
- Plan B, Plan C, Plan D obligatorios
- Documentar fallo = valioso para cliente

### Evasión es constante
- No es "hackear sin ser detectado"
- Es "ser detectado DESPUÉS de completar objetivo"
- Defender está ahí. Siempre. Trabajas CON eso

### Documentación > ejecución
- Cliente paga por **reporte, evidencia, enseñanza**
- Si no está documentado, es como si no pasara
- Screenshots, timelines, justificación técnica

### Presión temporal
- A menudo hay **fecha limite de engagement**
- No todos los objetivos se alcanzan en tiempo
- Prioriza: ¿qué es crítico?

---

## 7. Ética y Legal en Contexto Español

### Marco Legal
- **RD 1377/1997** (protección de datos)
- **LORGPD** (RGPD España)
- **Tipo penal 197 CP** (acceso no autorizado)

**Implicación:** Todo debe estar en Rules of Engagement firmado. Sin firma, eres criminal.

### Profesionalismo
- Reporte confidencial (cliente solamente)
- No publicar detalles (salvo caso documental con permiso)
- Separar hallazgos "críticos" de "nice-to-have"

---

## 8. Próximos Capítulos

Este manual continúa con:
- **02:** Pre-Engagement (cómo reconocer empresa, planificar)
- **03:** Estrategias por tipo de empresa
- **04:** Árbol de decisiones (detailed)
- **05:** Manejo de frenos y pivotes
- **06:** Contexto español (defensas, cultura)
- **07:** Documentación profesional
- **08:** Casos reales (anonimizados)

---

*Manual del Operador · Versión 1.0 · Introducción*  
*Iteración: Viviente. Mejoras continuas esperadas.*