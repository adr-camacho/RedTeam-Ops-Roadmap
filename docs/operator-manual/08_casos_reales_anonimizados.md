# Manual del Operador — Casos Reales (Anonimizados)

> **Propósito:** Aplicar todo lo aprendido a escenarios reales.  
> **Realidad:** Casos ficticios pero basados en engagements verdaderos.

---

## Caso 1: Startup FinTech (Madrid, 25 personas)

### Contexto

**Empresa:** Plataforma de inversiones online, fundada 2023  
**Datos sensibles:** Dinero de usuarios, transacciones, datos KYC  
**Defensa:** Mínima (Defender default, sin firewall)  
**Objetivo:** Validar seguridad de aplicación web

### Pre-engagement

**Recon OSINT:**
- LinkedIn: Encontrados CTO y 3 desarrolladores
- Shodan: Django 2.2.15 en www.company.com (vulnerable)
- DNS: AWS Hosted, sin WAF
- Git leak: Credenciales encontradas en repo público (GitHub)

**Conclusión:** Defensa es prácticamente inexistente

### Plan operacional

**Vector primario:** RCE en Django (CVE-2021-XXXXX)  
**Timeline:** 1-3 días  
**Objetivo:** Acceso a BD de clientes (SQLite, no protegida)

### Ejecución

**Día 1:**
- Identificada vulnerabilidad en endpoint `/api/auth/`
- Payload crafteado (deserialización insegura)
- RCE conseguido: shell en application server
- Contexto: www-data (user web app)

**Día 2:**
- Enumeración: Encontrados archivos de config
- Credenciales BD en plaintext (.env)
- SQLite database accesible directamente
- Beacon Sliver deployed

**Día 3:**
- Query: `SELECT * FROM users` = 1000+ registros
- Exfiltración de datos KYC
- Persistencia: Cron job para reverse shell

### Resultado

**✅ OBJETIVO COMPLETADO**

**Hallazgos:**
1. **CRÍTICA:** RCE en Django framework
2. **CRÍTICA:** Credenciales BD en .env (plaintext)
3. **ALTA:** BD SQLite sin protección
4. **ALTA:** Contenedor Docker sin restricciones

**Recomendaciones:**
1. Upgrade Django (ya existen parches)
2. Credential vault (AWS Secrets Manager)
3. BD en managed service (AWS RDS)
4. Container hardening

**Timeline implementación:** 30 días urgente

---

## Caso 2: Empresa Seguros (Valencia, 200 personas)

### Contexto

**Empresa:** Seguros de vida, 40 años operando  
**Datos sensibles:** Pólizas, datos de asegurados, dinero  
**Defensa:** Defender ACTIVO, firewall básico, sin SOC  
**Objetivo:** Acceso a BBDD de pólizas

### Pre-engagement

**Recon OSINT:**
- LinkedIn: Identificado IT manager con frustración visible
- Email pattern: firstname.lastname@company.com
- Organización: 2 personas IT, sin security staff
- Defensa: Básica pero presente

**Conclusión:** Phishing dirigida es mejor vector

### Plan operacional

**Vector primario:** Phishing dirigida a IT manager  
**Vector backup:** SQL Server brute force si phishing falla  
**Timeline:** 7-14 días  
**Objetivo:** BBDD de pólizas

### Ejecución

**Día 1-2:**
- Email crafteado: "Renovación SSL certificate"
- Payload Sliver beacon (stageless, obfuscated)
- Delivery via Gmail + spoofing

**Día 3:**
- IT manager abrió email, hizo click
- Defender bloqueó payload
- Intentó de nuevo (usuario más confiado segundo click)
- Segunda tentativa falló también

**Día 4-5:**
- Phishing no funciona
- Pivotó a SQL Server brute force
- Port 1433 abierto (error de firewall)
- Credenciales por defecto encontradas: sa/ViejoPassword123
- Acceso directo a BBDD

**Día 6-10:**
- Query table "pólizas"
- 50k registros exfiltrados
- Persistencia: Account "audit" creado en SQL Server
- Limpieza: Logs borrados

### Resultado

**✅ OBJETIVO COMPLETADO** (por vector alternativo)

**Hallazgos:**
1. **CRÍTICA:** SQL Server expuesto en Internet (puerto 1433)
2. **CRÍTICA:** Credenciales por defecto no cambiadas
3. **ALTA:** Sin firewall segmentación (DMZ = intranet)
4. **ALTA:** Logs no auditados (limpieza undetected)

**Lección:** Cuando phishing falla, vector alternativo es crítico  
Tener plan B, plan C es diferencia entre éxito y fallo

---

## Caso 3: Banco Regional (Barcelona, 1500+ personas)

### Contexto

**Empresa:** Banco regional español  
**Datos sensibles:** Dinero de 100k+ clientes, transacciones  
**Defensa:** MDE, Splunk SIEM, SOC 24/7  
**Objetivo:** Validar insider risk + defensa técnica

### Pre-engagement

**Recon:**
- LinkedIn: 1500 empleados, perfiles análisis detallado
- Análisis: Empleado con "frustración visible" identificado
  - Recién ascendido a posición media
  - Bajo salario (posts indirectos)
  - Ex-empleado en misma empresa (conoce systems)

**Conclusión:** Insider es vector único viable

### Plan operacional

**Vector primario:** Insider recruitment vía dinero  
**Timeline:** 25-30 días  
**Objetivo:** Datos de clientes, proof of concept

### Ejecución

**Día 1-10:**
- Contacto indirecto vía LinkedIn
- "Soy del sector, entiendo frustración"
- Múltiples conversaciones, rapport building
- Insider aún desconfiado (banco es employer)

**Día 10-15:**
- Propuesta: Dinero a cambio de credenciales
- Insider rechaza (miedo legal)
- Reframing: "Auditoría interna, es permitido"
- Insider accede ("son auditoría interna")

**Día 16-20:**
- Insider proporciona credenciales (account con acceso a datos)
- Account es legítimo, no sospechoso
- Acceso a BBDD de clientes
- Credenciales AD de ejecutivo (acceso escalado)

**Día 21-25:**
- Query datos de clientes
- POC: 100 registros exfiltrados
- Movimiento lateral vía credenciales legítimas
- Acceso a sistemas críticos

**Día 25-30:**
- SOC comenzó a sospechar (account activo fuera horario)
- Blue team investigó credenciales
- Insider confesó bajo presión
- OPERACIÓN ABORTADA

### Resultado

**⚠️ PARCIALMENTE COMPLETADO** (detectado antes de full objective)

**Hallazgos:**
1. **CRÍTICA:** Insider risk muy alto
2. **CRÍTICA:** Credenciales de ejecutivo sin MFA
3. **ALTA:** Behavioral analytics no detectó inmediatamente
4. **ALTA:** Empleado disconforme no fue identificado en prevención

**Lección:** En banca, insider es tan viable como técnico puro  
Defensa técnica fuerte = insider risk se vuelve principal

**Recomendaciones:**
1. Insider threat program formal
2. Behavioral analytics (Splunk)
3. Account activity monitoring
4. MFA obligatorio ejecutivos

---

## Caso 4: Manufacturera (Bilbao, 500 personas)

### Contexto

**Empresa:** Fabrica electrónica, 25 años operando  
**Sistemas críticos:** SCADA/PLC controls linea producción  
**Defensa:** IT débil (Defender), OT sin defensa  
**Objetivo:** Validar segmentación y criticidad de OT

### Pre-engagement

**Recon:**
- Shodan: Múltiples SCADA/PLC sistemas en Internet
- Enumeración: Network es FLAT (no segmentación)
- Empleados: Técnicos con acceso amplio

**Conclusión:** OT es completamente vulnerable

### Plan operacional

**Vector primario:** Phishing a IT staff  
**Objetivo:** Acceso a red OT, demostración de impacto crítico  
**RoE nota:** STOP inmediatamente si accedo a SCADA

### Ejecución

**Día 1-3:**
- Phishing dirigida a IT technician
- Beacon ejecutado
- Acceso a red interna

**Día 4:**
- Enumeración: Red flat, sin firewall interno
- Descubrimiento: PLC systems accesibles vía network
- CRÍTICA HALLAZGO: Sistemas de control directamente accesibles

**Operación PARADA inmediatamente**
- Cliente notificado de hallazgo crítico
- No se continuó explotación
- Documentado riesgo de sabotaje (industria 4.0)

### Resultado

**⚠️ OPERACIÓN PAUSADA POR HALLAZGO CRÍTICO**

**Hallazgo clave:**
Acceso a SCADA systems sin MFA, sin segmentación, sin monitoring  
Riesgo: Insider puede parar línea producción, causar daño físico

**Recomendación URGENTE:**
1. Red segmentacion OT/IT inmediato
2. SCADA systems detrás de firewall
3. MFA para acceso SCADA
4. Monitoring de cambios en PLC

**Lección:** Hallazgo crítico puede cambiar objetivo de engagement  
Profesionalismo = parar si riesgo es demasiado grande

---

## Análisis comparativo: Qué funcionó, qué no

### Vector efectividad por tipo empresa

```
┌──────────────┬────────┬────────┬─────────┬──────────┐
│ Vector       │ Startup│ Pyme   │ Grande  │ OT/Crit  │
├──────────────┼────────┼────────┼─────────┼──────────┤
│ Phishing     │ 30%    │ 70%    │ 10%     │ 40%      │
│ Web RCE      │ 90%    │ 60%    │ 5%      │ N/A      │
│ Insider      │ 50%    │ 30%    │ 85%     │ 90%      │
│ Supply chain │ 40%    │ 50%    │ 70%     │ 60%      │
│ Social eng   │ 60%    │ 40%    │ 20%     │ 50%      │
└──────────────┴────────┴────────┴─────────┴──────────┘

Conclusión: Vector óptimo depende de tamaño/defensa
```

### Defensa "sorpresas" encontradas en casos

```
SORPRESA 1 (Startup FinTech):
  Esperado: Defensa débil
  Realidad: Defensa inexistente (código público con credenciales)
  Aprendizaje: OSINT puede revelar más que ataque

SORPRESA 2 (Empresa Seguros):
  Esperado: Phishing funcionaría
  Realidad: Defender bloqueó iteradamente, pero fallo era alternativa
  Aprendizaje: Plan B es obligatorio, no opcional

SORPRESA 3 (Banco):
  Esperado: Insider sería reacio
  Realidad: Insider fue accesible (dinero como motivador)
  Aprendizaje: Insider risk es constante en cualquier tamaño

SORPRESA 4 (Manufacturera):
  Esperado: OT estaría segmentado
  Realidad: OT fue completamente accesible desde IT
  Aprendizaje: Conocimiento = responsabilidad de parar
```

---

## Lecciones aplicables a todos los casos

### Lección 1: Pre-engagement es 70% del trabajo

Todos los casos exitosos tuvieron recon exhaustivo  
Phishing dirigida a IT manager = conocer nombre, frustración  
RCE en Django = identificación de versión específica  
Insider access = análisis de 1500 perfiles de LinkedIn

### Lección 2: Plan B es diferencia entre éxito y fallo

Empresa Seguros: Phishing falló, SQL brute force funcionó  
Sin backup plan = objective no alcanzado

### Lección 3: Profesionalismo = documentación

Todos los casos tuvieron documentación completa  
Screenshots, timeline, hallazgos, recomendaciones  
Cliente paga por reporte, no por "haber sido hacker"

### Lección 4: Insider risk es subestimado

Incluso banco con SOC 24/7 fue vulnerable a insider  
Dinero/frustración > defensa técnica  
Cultural risk (insider threat program) es más importante que técnico

### Lección 5: Hallazgo crítico = parar

Manufacturera: Riesgo de sabotaje en SCADA  
Profesional = reconocer límite, NO continuar  
Valor = haber identificado el riesgo

---

*Manual del Operador · Capítulo 08: Casos Reales*  
*Versión 1.0 — Anonimizados, educacionales, realistas*