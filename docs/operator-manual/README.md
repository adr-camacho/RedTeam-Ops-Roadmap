# Manual del Operador de Red Team Español

> **Objetivo:** Documentación profesional y realista sobre cómo trabaja un operador de red team en una empresa española.

> **Audiencia:** Operadores, pentesters, especialistas en seguridad ofensiva, estudiantes CRTO.

> **Estado:** Versión 1.0 (Junio 2026) — Viva, iterativa, sujeta a mejora continua.

---

## 📚 Contenido

### **Capítulo 01: Introducción a la Operativa**
Qué es un operador de red team, día a día real vs cine, mentalidad operacional, fases de engagement.

### **Capítulo 02: Pre-Engagement**
Recon OSINT, recon técnico, social engineering, selección de vector, Rules of Engagement legales, preparación.

### **Capítulo 03: Estrategias por Tipo de Empresa**
Adaptación operacional específica para startups, pymes, grandes empresas, sector financiero.

### **Capítulo 04: Árboles de Decisión Operacional**
Lógica de decisión en puntos críticos: detección, movimiento lateral, hunting de credenciales, continuidad vs abort.

### **Capítulo 05: Manejo de Frenos**
Qué hacer cuando defensa es más fuerte que esperado, cuando técnicas fallan, cuando everything breaks.

### **Capítulo 06: Contexto España**
Marco legal (LORGPD, Tipo Penal 197 CP), defensas comunes españolas, cultura empresarial, timing operacional.

### **Capítulo 07: Documentación Profesional**
Logging en tiempo real, estructura de reporte final, screenshots/evidencia, timeline narrativa, confidencialidad.

### **Capítulo 08: Casos Reales Anonimizados**
Cuatro casos de engagement (startup, pyme, grande, OT/crítico), lecciones aprendidas, qué funcionó/no funcionó.

---

## 🎯 Cómo usar este manual

### **Estudiante CRTO**
```
1. Lee cap 01-03 para entender contexto general
2. Durante labs: Usa cap 04-05 para decisiones operacionales
3. Final: Referencia cap 07 para documentar hallazgos
```

### **Operador en engagement actual**
```
Pre-engagement:
  → Cap 02: Checklist de pre-engagement
  → Cap 03: Selecciona estrategia por tipo empresa
  → Cap 06: Valida marco legal si es en España

Durante engagement:
  → Cap 04: Árbol de decisión en puntos críticos
  → Cap 05: Si hiteas freno, consulta alternativas

Post-engagement:
  → Cap 07: Template y estructura de reporte
```

### **Aprendizaje general**
```
Lee completo (3-4 horas) para:
  - Entender profesión de red team operator
  - Contextualizar técnicas dentro operativa real
  - Cap 08: Realidad práctica de engagements
```

---

## 📊 Estadísticas del manual

| Métrica | Valor |
|---------|-------|
| Total capítulos | 8 |
| Total líneas | 3,314 |
| Total tamaño | ~98 KB |
| Casos reales documentados | 4 |
| Árboles de decisión | 5 |
| Checklist operacionales | 10+ |
| Cobertura temas | Pre → Post engagement |

---

## 🔄 Iteración y mejora continua

Este manual es **vivo**. Versión 1.0 cubre fundacionales. Futuras iteraciones esperadas:

- **1.1:** Detalle técnico expandido (comandos específicos, POCs, Sliver integration)
- **1.2:** Más casos reales (finanzas, gobierno, OT específico, crítica infrastructure)
- **1.3:** Integración con herramientas (Sliver, Cobalt Strike, etc.)
- **1.4:** MITRE ATT&CK mapping expandido, coverage matrix
- **2.0:** Módulos especializados (insider recruitment, supply chain, física)

**Contribuciones bienvenidas** de operadores con experiencia real de campo.

---

## ⚖️ Nota Legal y Ética

Este manual documenta **trabajos autorizados** (red team engagements):

✅ **Siempre dentro de:**
- Rules of Engagement firmados por cliente
- Marco legal español (LORGPD, Tipo Penal 197 CP)
- Autorización previa explícita
- Scope definido y respetado

❌ **NUNCA para:**
- Acceso no autorizado (delito)
- Exfiltración de datos sin permiso
- Daño intencional
- Cualquier actividad fuera RoE

**Responsabilidad:** Usar este conocimiento profesionalmente y éticamente.

---

## 📖 Estructura de archivo

```
OPERADOR_MANUAL/
├── README.md (este archivo)
├── 01-introduccion-operativa.md
├── 02-pre-engagement.md
├── 03-estrategias-por-tipo-empresa.md
├── 04-decision-trees.md
├── 05-manejo-de-frenos.md
├── 06-contexto-españa.md
├── 07-documentacion-profesional.md
└── 08-casos-reales-anonimizados.md
```

---

## 🔗 Referencias

**Legislación española:**
- LORGPD (Ley Orgánica de Regulación y Garantía de Derechos Digitales)
- Código Penal Art. 197 (Acceso no autorizado)
- PCI-DSS, ISO 27001 (compliancia)

**Frameworks operacionales:**
- MITRE ATT&CK (técnicas, tácticas)
- NIST Cybersecurity Framework
- Red Team Tradecraft (operacional)

**Certificaciones relacionadas:**
- CRTO (Certified Red Team Operator)
- OSCP (Offensive Security Certified Professional)
- GPEN (GIAC Penetration Tester)

---

## 👤 Autor

Adrián Camacho  
Backend Java Developer → Offensive Security Specialist  
Preparación CRTO 2026  
Zaragoza, España

---

*Manual del Operador de Red Team Español*  
*Versión 1.0 · Junio 2026*  
*Vivo, iterativo, educacional, profesional*