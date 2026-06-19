# Manual del Operador — Estrategias por Tipo de Empresa

> **Realidad:** Cada empresa es distinta. No hay una "receta universal".  
> **Clave:** Adaptar estrategia operacional al contexto específico.

---

## 1. Tipología de empresas españolas: Matriz de decisión

### Startup Tech (10-50 personas)

**Perfil:**
- Equipos pequeños, IT minimal
- Mínima o nula defensa (no hay SOC)
- Tecnología moderna (cloud, DevOps, containers)
- Procesos rápidos, menos auditoría
- Ciclo de vida corto (1-3 años en mayoría)

**Defensa típica:**
- Defender default (deshabilitado a menudo)
- Firewall básico (o cloud-native)
- Sin SIEM, sin IDS
- Respuesta a incidentes: lenta (sin procedures)

**Vectores óptimos:**
1. **Phishing (90% éxito)** — personal joven, confianza alta
2. **RCE web (80% éxito)** — código legacy, dependencias sin patchear
3. **Insider (70% éxito)** — empleados disconformes (startup = salarios bajos)

**Timeline operacional:** 3-7 días completo  
**OPSEC requerida:** Media (sin monitoreo sofisticado)

**Consideraciones especiales:**
- Mucho tráfico a cloud (AWS, Slack, GitHub)
- Desarrolladores con acceso amplio a producción
- Credenciales en variables de entorno (Docker, config files)
- Poco control de cambios

**Estrategia específica:**
```
Día 1-2: Phishing dirigida a CTO/senior developer
Día 2-4: Obtener credenciales GitHub
Día 4-6: Acceso a deployments, BBDD credentials
Día 6-7: Exfiltración, persistencia opcional
```

---

### Pyme Tradicional (50-500 personas)

**Perfil:**
- Equipos IT pequeños (2-5 personas)
- Defensa básica pero presente
- Sistemas heterogéneos (legacy + moderno)
- Procesos formales pero no exhaustivos
- Estructura jerárquica clara

**Defensa típica:**
- Defender ACTIVO en endpoints
- Firewall corporativo (Palo Alto, Fortinet)
- Logs centralizados pero sin análisis real-time
- Sin SOC (máximo 1 person "security")
- AD presente

**Vectores óptimos:**
1. **Phishing dirigida (70% éxito)** — especialmente a IT staff
2. **Web RCE (60% éxito)** — aplicaciones custom no patcheadas
3. **Credential hunting (80% éxito)** — mal management de secrets

**Timeline operacional:** 7-14 días  
**OPSEC requerida:** Media-Alta (Defender presente)

**Consideraciones especiales:**
- AD presente = Kerberoasting posible
- Usuarios con permisos excesivos (segregación pobre)
- Scripts en shares públicas (credenciales hardcodeadas)
- Auditoría = cumplimiento, no seguridad real

**Estrategia específica:**
```
Día 1-3: OSINT exhaustivo, phishing dirigida a IT manager
Día 3-5: Payload ejecuta, beacon conecta
Día 5-8: Lateral movement vía AD abuse
Día 8-12: Credential hunting, escalada
Día 12-14: Objective, exfiltración
```

**Mitigación OPSEC:**
- Evasión de Defender necesaria (AMSI bypass, etc.)
- Sleep 30-45s entre comandos
- Uso de credential tools legítimas (sekurlsa vía proc dump)

---

### Empresa Grande (500-2000+ personas)

**Perfil:**
- Equipos SOC/Blue Team presentes
- Defensa sofisticada (EDR, SIEM, IPS)
- Auditoría constante, compliance exhausto
- Segmentación de red
- Logs exhaustivos, monitoreo real-time

**Defensa típica:**
- EDR sofisticado (MDE, CrowdStrike, Sentinel One)
- SIEM central (Splunk, ELK, Sentinel)
- SOC 24/7 (3-10 personas)
- Incident response plan activo
- MFA en sistemas críticos

**Vectores óptimos:**
1. **Insider (80% éxito)** — dinero, venganza, facilidad
2. **Supply chain (60% éxito)** — terceros más débiles
3. **Phishing spear dirigida (40% éxito)** — requiere extrema precisión

**Timeline operacional:** 14-30+ días  
**OPSEC requerida:** Muy Alta (detección casi garantizada)

**Consideraciones especiales:**
- Detección es *esperable*, no sorpresa
- Objetivo = completar antes de ser detectado
- Plan de salida crítico
- Insider = oro puro

**Estrategia específica:**
```
Día 1-7: Recon exhaustivo, insider mapping
Día 7-14: Relationship building con insider disconforme
Día 14-20: Insider proporciona credenciales/acceso
Día 20-25: Movimiento lateral vía credenciales legítimas
Día 25-30: Objective, exfiltración rápida
```

**CRÍTICO:**
- No puedes ser sigiloso = velocidad es defensa
- Insider es 10x más eficaz que técnico puro
- Blue team VERÁ movimiento → documentar, limpiar, salida

---

### Banca / Finanzas (1000+)

**Perfil:**
- Defensa **MAXIMIZADA**
- Compliance regulatorio OBSESIVO (PCI-DSS, GDPR, regulación BCN)
- Blue Team + Red Team internos
- Auditoría regulatoria permanente
- Respuesta a incidentes: **HORAS**, no días

**Defensa típica:**
- EDR enterprise (MDE + Microsoft 365 Defender)
- SIEM sofisticado (Splunk Enterprise)
- SOC 24/7/365 (10-30 personas)
- Threat hunting activo
- MFA obligatorio, 2FA en críticos
- Network segmentation estricta

**Vectores óptimos:**
1. **Insider (90% éxito)** — único vector viable
2. **Physical (70% éxito)** — si está permitido
3. **Social engineering extrema (30% éxito)** — riqueza de targets permite muchos intentos

**Timeline operacional:** 20-40+ días  
**OPSEC requerida:** CRÍTICA (detección = fallo)

**Consideraciones especiales:**
- Insider es OBLIGATORIO
- Técnico puro tiene <10% éxito
- Regulación implica divulgación si comprometen
- Fallo = regulador sabe

**Estrategia específica:**
```
Día 1-10: Identificar insider disconforme (ex-empleado, bajo sueldo, etc.)
Día 10-20: Relationship building, dinero/venganza como incentivo
Día 20-30: Insider proporciona acceso + credenciales
Día 30-35: Movimiento, objetivo
Día 35-40: Exfiltración, salida limpia
```

**Nota:** Si defensa lo ve, **ABORT inmediatamente**. No hay recuperación.

---

## 2. Matriz comparativa: Decisiones por tipo

```
┌──────────────┬─────────────┬──────────────┬────────────────┬──────────────────┐
│ Aspecto      │ Startup     │ Pyme         │ Grande         │ Finanzas         │
├──────────────┼─────────────┼──────────────┼────────────────┼──────────────────┤
│ Defensa      │ Baja        │ Media        │ Alta           │ Crítica          │
│ Timeline     │ 3-7d        │ 7-14d        │ 14-30d         │ 20-40d           │
│ Phishing     │ SÍ (simple) │ SÍ (dirigida)│ Spear solo     │ Insider prefer   │
│ Web RCE      │ SÍ          │ SÍ           │ Raro           │ Casi imposible   │
│ OPSEC nivel  │ 1/5         │ 3/5          │ 4/5            │ 5/5              │
│ Insider risk │ Alto        │ Medio        │ Bajo           │ Muy Alto (+$$$)  │
│ SOC presente │ NO          │ NO/maybe     │ SÍ             │ SÍ (24/7)        │
│ SIEM         │ NO          │ Posible      │ SÍ             │ SÍ (Splunk)      │
│ EDR          │ Defender    │ Defender+    │ CrowdStrike    │ MDE enterprise   │
│ MFA          │ NO          │ NO/2FA SSH   │ SÍ (críticos)  │ SÍ (obligatorio) │
│ Detección    │ Lenta       │ Media        │ Rápida         │ Muy Rápida       │
│ Valor datos  │ Bajo        │ Medio        │ Alto           │ Muy Alto         │
└──────────────┴─────────────┴──────────────┴────────────────┴──────────────────┘
```

---

## 3. Decisiones específicas según contexto

### ¿Objetivo es exfiltración o demostrativo?

**Exfiltración (objetivo datos):**
- OPSEC máxima → evasión total
- Timing no importa (puede tomar semanas)
- Cleanup crítico (no dejar rastro)
- Insider viable, técnico complejo

**Demostrativo (POC):**
- Puede ser agresivo
- Timeline corto importa
- Cleanup menos crítico
- Técnico puro viable

---

### ¿Múltiples oficinas vs centralizado?

**Múltiples oficinas:**
- Pivota entre ubicaciones
- Usa C2 distribuido
- Cada oficina puede tener defensa diferente
- Elige la más débil

**Centralizado:**
- Concentra esfuerzo
- Un fallo = todo fallo
- Movimiento lateral más directo

---

### ¿Cloud vs On-Premise?

**Cloud (AWS, Azure, Salesforce):**
- Scope DEBE estar claramente definido en RoE
- "AWS" es vago → especificar qué cuentas/servicios
- Terceros (AWS support) pueden estar involucrados
- Límites legales muy específicos

**On-Premise:**
- Libertad operacional mayor
- Full control sobre infraestructura
- Responsabilidad cliente = mayor

---

## 4. Casos reales españoles: Tipología

### Caso: Startup FinTech (Madrid, 25 personas)

**Contexto:** App web de inversiones, 2 años de antigüedad

**Defensa:** Defender default (deshabilitado), no firewall

**Vector elegido:** RCE en aplicación (framework Django 2.2, CVE conocido)

**Resultado:** Compromiso en 1 día, acceso a BBDD de clientes en 2 días

**Lección:** Startups = prioridad en velocidad sobre OPSEC

---

### Caso: Empresa Seguros (Valencia, 200 personas)

**Contexto:** Pólizas de clientes, datos sensibles

**Defensa:** Defender ACTIVO, firewall básico, sin SOC

**Vector elegido:** Phishing dirigida a IT manager (encontrado en LinkedIn)

**Resultado:** Beacon en 3 días, lateral movement en 6 días, objetivo en 10 días

**Lección:** Phishing dirigida es 70% del vector en medianas españolas

---

### Caso: Banco (Barcelona, 1500+ personas)

**Contexto:** Datos financieros, compliance exhausto

**Defensa:** MDE, Splunk, SOC 24/7

**Vector elegido:** Insider disconforme (ex-empleado, bajo salario)

**Resultado:** Acceso completo en 25 días, datos exfiltrados en 30 días

**Lección:** En banca, insider es único vector viable; técnico puro falla garantizado

---

*Manual del Operador · Capítulo 03: Estrategias por Tipo*  
*Versión 1.0 — Contextual, España-específico, pragmático*