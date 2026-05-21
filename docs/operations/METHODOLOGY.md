# METHODOLOGY.md — Red Team Ops Roadmap
## Metodología de Trabajo — Proceso Estándar por Lab

**Versión:** 1.0 | **Fecha:** Mayo 2026 | **Autor:** Adrián Camacho

---

## 1. Filosofía de la metodología

Este documento define el proceso de trabajo para cada lab del roadmap. No es solo una guía de ejecución — es un sistema de aprendizaje diseñado para construir hábitos profesionales que se transfieran directamente a engagements reales.

**Principio fundamental:** Cada lab es un mini-engagement real. Aplica la misma disciplina, documentación y mentalidad OPSEC que en un engagement profesional.

---

## 2. Proceso por Lab — Visión General

```
┌─────────────────────────────────────────────────────────────┐
│  FASE 0: Preparación (antes de encender las VMs)            │
│  FASE 1: Lectura de tradecraft                              │
│  FASE 2: Planificación del ataque                           │
│  FASE 3: Ejecución                                          │
│  FASE 4: Documentación en tiempo real                       │
│  FASE 5: Análisis post-lab                                  │
│  FASE 6: Commit y cierre                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. FASE 0 — Preparación

### Antes de encender las VMs

```
□ Leer el README del lab (objetivos, crown jewels, adversario)
□ Leer el tradecraft.md completo del lab
□ Revisar el THREAT_MODEL.md — contexto del adversario
□ Verificar que el entorno está provisionado (script setup ejecutado)
□ Verificar que los crown jewels están desplegados (script CrownJewels ejecutado)
□ Tomar snapshot de las VMs (punto de retorno si algo falla)
□ Revisar TOOL_INDEX.md — qué herramientas se usarán en este lab
□ Verificar conectividad: ping DC-01, Kali con Internet
□ Abrir ENGAGEMENT_CHECKLIST.md y seguirlo
```

### Herramientas a preparar

```bash
# Verificar arsenal Kali
ls /opt/redteam/
which evil-winrm impacket-secretsdump certipy bloodhound-python

# Verificar arsenal Windows (en DC-01 o WKSTN-01 si aplica)
# Rubeus, SharpHound, etc. en C:\Tools\
```

---

## 4. FASE 1 — Lectura de Tradecraft

### Por qué leer ANTES de ejecutar

El tradecraft.md no es un manual de comandos — es la base teórica que permite improvisar cuando las herramientas fallan. Si solo sigues comandos sin entender por qué funcionan, en el examen CRTO o en un engagement real quedarás bloqueado ante cualquier variación.

### Qué extraer del tradecraft

Para cada técnica del lab, responder mentalmente:
- ¿Qué protocolo/mecanismo se está abusando?
- ¿Qué condición hace la técnica posible?
- ¿Qué alternativas hay si la herramienta falla?
- ¿Qué eventos genera en los logs?
- ¿Cómo se limpian los artefactos?

---

## 5. FASE 2 — Planificación del Ataque

### Definir el plan antes de ejecutar

```
1. ¿Cuál es el crown jewel de este lab?
2. ¿Cuál es el camino más corto hacia él? (BloodHound first)
3. ¿Qué credenciales tenemos al inicio?
4. ¿Qué técnicas aplican según el tradecraft?
5. ¿Cuál es el plan B si la técnica principal falla?
```

### Nomenclatura de capturas

Definir ANTES la nomenclatura de las capturas para no renombrarlas después:

```
faseXX-YY-descripcion-breve.png

Donde:
  XX = número de fase (01, 02, 03...)
  YY = número de captura dentro de la fase (01, 02...)
  descripcion = 3-5 palabras descriptivas con guiones

Ejemplos:
  fase01-01-nmap-scan.png
  fase11-03-rubeus-tgt-captured.png
  fase13-02-targeted-kerberoast-spn.png
```

---

## 6. FASE 3 — Ejecución

### Principios durante la ejecución

**1. OPSEC primero**
Antes de cada comando, preguntarse:
- ¿Puedo hacer esto desde Kali sin tocar el objetivo?
- ¿Qué logs genera este comando?
- ¿Es este el método más silencioso disponible?

**2. Documentar en tiempo real**
No ejecutar 10 comandos y luego intentar recordar qué pasó. Documentar cada paso al momento de ejecutarlo.

**3. Capturar evidencias inmediatamente**
Cada resultado relevante → captura de pantalla con anotaciones → nombre correcto.

**4. Un paso a la vez**
Verificar que cada paso funcionó antes de pasar al siguiente. No asumir que el comando anterior tuvo éxito.

### Manejo de fallos

Cuando algo falla:
```
1. Leer el error completo — no ignorarlo
2. Buscar en lessons_learned.md si es un problema conocido
3. Consultar el tradecraft — ¿hay una alternativa?
4. Documentar el fallo y la causa (será una lección aprendida)
5. Intentar la alternativa
```

---

## 7. FASE 4 — Documentación en Tiempo Real

### Qué documentar durante la ejecución

Para cada técnica ejecutada:

```markdown
## Técnica: [nombre]
**Comando:** `comando exacto ejecutado`
**Output:** [output relevante]
**Resultado:** [éxito/fallo y por qué]
**Artefactos creados:** [archivos, cuentas, cambios en AD]
**Limpieza necesaria:** [qué hay que limpiar al terminar]
```

### Estructura de capturas

Cada captura debe incluir:
1. El comando ejecutado (visible en la terminal)
2. El output completo relevante
3. Una anotación explicando qué demuestra la captura

### Loot — Registrar todo lo obtenido

```bash
# Mantener un archivo de loot actualizado durante el lab
cat >> ~/loot/lab-XX-loot.txt << EOF
[FECHA HORA] Credencial: usuario:password (método: técnica)
[FECHA HORA] Hash: usuario:NTLM_HASH (método: DCSync)
[FECHA HORA] Ticket: /tmp/ticket.ccache (tipo: TGT/TGS)
EOF
```

---

## 8. FASE 5 — Análisis Post-Lab

### Completar la documentación

Una vez terminada la ejecución, completar o actualizar:

```
□ execution/post_exploitation.md — flujo completo de la sesión
□ analysis/lessons_learned.md — qué aprendiste que no sabías antes
□ analysis/mitigations.md — cómo se habría podido defender
□ OPERATION_XXX.md — actualizar estado de cada fase a ✅
□ docs/MITRE_MAPPING.md — añadir nuevas técnicas ejecutadas
□ docs/OPSEC_NOTES.md — añadir insights OPSEC nuevos
```

### Preguntas de reflexión post-lab

Para cada lab, responder honestamente:
1. ¿Hubo alguna técnica que no funcionó como esperaba? ¿Por qué?
2. ¿Qué haría diferente en un engagement real?
3. ¿Qué técnica OPSEC adicional aplicaría?
4. ¿Qué habría detectado el Blue Team de mis acciones?
5. ¿Cómo se podría haber mitigado el ataque principal?

---

## 9. FASE 6 — Commit y Cierre

### Checklist pre-commit

```
□ Todos los docs actualizados
□ Capturas nombradas correctamente y en screenshots/
□ Loot guardado en loot/
□ Artefactos limpiados en las VMs (SPNs, GPOs, tareas, etc.)
□ Snapshot post-lab creado en VirtualBox
□ PROGRESS.md actualizado con las horas invertidas
□ CHANGELOG.md actualizado con los cambios del lab
```

### Mensaje de commit estándar

```
feat: Lab-XX NOMBRE — [resumen de lo ejecutado]

## Fases ejecutadas
- Fase N: [técnica] → [resultado]

## Credenciales obtenidas
- cuenta: contraseña/hash (método)

## Documentos generados/actualizados
- execution/fichero.md
- analysis/lessons_learned.md (+N lecciones)

## MITRE técnicas
- T1XXX.XXX — descripción
```

---

## 10. Estándares de calidad

### Un lab está completo cuando

```
□ Todas las fases ejecutadas y documentadas
□ Capturas con anotaciones para cada paso relevante
□ lessons_learned.md actualizado con mínimo 3 lecciones nuevas
□ mitigations.md actualizado con contramedidas específicas
□ OPERATION_XXX.md con todas las fases en ✅
□ Crown jewels comprometidos y documentados
□ MITRE mapping actualizado
□ Commit hecho con mensaje correcto
```

### Criterios de calidad de la documentación

| Criterio | Estándar |
|----------|----------|
| Claridad | Un Red Teamer sin contexto previo puede seguir el writeup |
| Completitud | Incluye tanto los éxitos como los fallos |
| OPSEC | Documenta alternativas más sigilosas |
| Blue Team | Incluye qué habría detectado y cómo |
| Reproducibilidad | Los comandos exactos permiten reproducir el lab |

---

## 11. Iteración y mejora continua

### Después de cada Phase completada

Al finalizar cada Phase (grupo de labs):
1. Revisar todos los lessons_learned de los labs de esa phase
2. Identificar patrones — ¿qué errores se repiten?
3. Actualizar DESIGN.md con la versión siguiente del roadmap
4. Actualizar la coverage matrix CRTO
5. Ajustar los labs futuros basándose en lo aprendido

### Versioning del roadmap

```
v1.0 → Estructura inicial
v2.0 → Rediseño tras completar Phase-01 (este punto)
v3.0 → Tras completar Phase-02 (más técnicas de AD avanzado)
v4.0 → Tras completar Phase-03 (incorporar feedback de EDR evasion real)
```

---

*Red Team Ops Roadmap — Adrián Camacho | Mayo 2026*  
*Metodología de trabajo — Únicamente con fines educativos*