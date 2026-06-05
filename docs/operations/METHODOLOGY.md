# METHODOLOGY.md — Red Team Ops Roadmap
## Metodología de Trabajo — Proceso Estándar por Lab

**Versión:** 2.0 | **Fecha:** Junio 2026 | **Autor:** Adrián Camacho

> v2.0 — Metodología ampliada a 10 pasos. Se añaden THREAT MODEL, RECONNAISSANCE
> y CLEANUP como pasos formales independientes.

---

## 1. Filosofía de la metodología

Este documento define el proceso de trabajo para cada lab del roadmap. No es solo una guía de ejecución — es un sistema de aprendizaje diseñado para construir hábitos profesionales que se transfieran directamente a engagements reales.

**Principio fundamental:** Cada lab es un mini-engagement real. Aplica la misma disciplina, documentación y mentalidad OPSEC que en un engagement profesional.

---

## 2. Proceso por Lab — Visión General

```
┌────────────────────────────────────────────────────────────────┐
│  PASO 1: ADVERSARY SELECTION  → APT real · Kill chain · TTPs   │
│  PASO 2: THREAT MODEL         → Crown Jewels · Scope · Éxito   │
│  PASO 3: THEORY               → Fundamentos antes de ejecutar  │
│  PASO 4: INFRASTRUCTURE       → Setup reproducible + snapshots │
│  PASO 5: RECONNAISSANCE       → BloodHound · Attack paths      │
│  PASO 6: EXECUTION            → Comandos + output + OPSEC      │
│  PASO 7: CLEANUP              → Artefactos · ACLs · GPOs       │
│  PASO 8: ANALYSIS             → Post-mortem + lecciones        │
│  PASO 9: BLUE TEAM            → Event IDs · SIGMA · Hardening  │
│  PASO 10: REPORT              → PDF ejecutivo + lessons learned │
└────────────────────────────────────────────────────────────────┘
```

---

## 3. PASO 1 — ADVERSARY SELECTION

### Selección del grupo APT

Cada lab emula un actor de amenaza real. La selección no es arbitraria — el adversario determina el estilo operacional, las técnicas priorizadas y el nivel de sofisticación OPSEC esperado.

```
□ Identificar el grupo APT del lab (APT29, APT28, Lazarus, APT10...)
□ Leer el THREAT_MODEL.md — contexto del adversario
□ Revisar las TTPs documentadas del grupo en MITRE ATT&CK Groups
□ Entender el kill chain característico del grupo
□ Identificar qué técnicas son signature del adversario
```

| Adversario | Labs | TTPs Características |
|-----------|------|---------------------|
| APT29 / Cozy Bear | 01, 03 | Kerberos abuse, LOLBins, ADCS, C2 encubierto |
| APT41 / Double Dragon | 02 | Web RCE, pivotaje multicapa, implantes persistentes |
| APT28 / Fancy Bear | 04-07 | ACL Abuse, DCSync, Delegation, GPO Abuse, LAPS |
| Lazarus Group | 08-11 | EDR Evasion, AMSI Bypass, C2 avanzado, syscalls |
| APT10 / Stone Panda | 12-15 | Forest Trusts, supply chain, exfiltración masiva |

---

## 4. PASO 2 — THREAT MODEL

### Definir el scope antes de tocar nada

Este paso convierte el lab en un engagement con límites definidos. En un engagement real, el Threat Model es el documento que el cliente firma antes de empezar.

```
□ ¿Cuál es el Crown Jewel de este lab? (el objetivo final)
□ ¿Qué sistemas están en scope? (IPs autorizadas)
□ ¿Cuál es la credencial inicial? (punto de partida)
□ ¿Cuáles son las condiciones de éxito? (cómo sé que terminé)
□ ¿Qué técnicas están autorizadas en este lab?
□ ¿Cuáles son los límites? (qué NO tocar)
□ ¿Cuál es el plan B si la técnica principal está bloqueada?
```

> Ver `docs/operations/RULES_OF_ENGAGEMENT.md` para el marco operacional completo.

---

## 5. PASO 3 — THEORY

### Fundamentos antes de ejecutar

El tradecraft.md no es un manual de comandos — es la base teórica que permite improvisar cuando las herramientas fallan.

Para cada técnica del lab, responder:
- ¿Qué protocolo/mecanismo se está abusando?
- ¿Qué condición hace la técnica posible?
- ¿Qué alternativas hay si la herramienta falla?
- ¿Qué eventos genera en los logs?
- ¿Cómo se limpian los artefactos?

```
□ Leer tradecraft.md completo del lab
□ Revisar ARSENAL.md — versiones y flags de las herramientas
□ Revisar TOOL_INDEX.md — qué herramienta se usa en qué fase
□ Revisar OPSEC_NOTES.md — lecciones transversales de labs anteriores
```

---

## 6. PASO 4 — INFRASTRUCTURE

### Setup reproducible

```
□ Ejecutar scripts de provisioning de setup/ en el orden correcto
□ Ejecutar CrownJewels del lab en DC-01
□ Verificar conectividad: bash tooling/lab_start.sh XX
□ Tomar snapshot pre-lab en VirtualBox
□ Verificar arsenal Kali: which evil-winrm nxc certipy bloodyad
```

```bash
# Verificar entorno listo
bash tooling/lab_start.sh XX

# Snapshot pre-lab (desde VirtualBox o CLI)
VBoxManage snapshot "DC-01" take "pre-lab-XX" --live
```

> Los scripts de provisioning están en `setup/DC-01/`, `setup/DC-02/`, etc.
> Ver `setup/README.md` para el orden completo de ejecución.

---

## 7. PASO 5 — RECONNAISSANCE

### Mapear antes de explotar

La reconnaissance es una fase distinta de la ejecución. Su objetivo es construir un mapa completo del entorno antes de tomar ninguna acción ofensiva.

```
□ Enumeración de red: nmap, nxc smb/ldap
□ Enumeración AD: BloodHound CE + SharpHound
□ Identificar attack paths hacia el Crown Jewel
□ Documentar usuarios, grupos, SPNs, ACLs relevantes
□ Identificar misconfigurations (Unconstrained Delegation, WriteDACL, etc.)
□ Planificar el ataque basándose en los paths encontrados
```

```bash
# Recolección BloodHound
nxc ldap DC-IP -u user -p pass --bloodhound -c All --dns-server DC-IP

# Enumeración SMB
nxc smb DC-IP -u user -p pass --shares

# Enumeración LDAP
ldapsearch -H ldap://DC-IP -x -b "DC=dominio,DC=local" "(objectClass=user)"
```

**Principio:** No ejecutes nada ofensivo hasta tener el mapa completo. BloodHound primero, siempre.

---

## 8. PASO 6 — EXECUTION

### Ejecución con disciplina OPSEC

**Antes de cada comando:**
- ¿Puedo hacer esto desde Kali sin tocar el objetivo?
- ¿Qué logs genera este comando?
- ¿Es este el método más silencioso disponible?

**Durante la ejecución:**
- Documentar cada paso al momento de ejecutarlo
- Capturar evidencias inmediatamente con nombre correcto
- Verificar que cada paso funcionó antes de pasar al siguiente
- Registrar loot en tiempo real

```bash
# Registrar loot
echo "[$(date '+%H:%M')] usuario:pass (método: técnica)" >> ~/loot/lab-XX-loot.txt
```

**Nomenclatura de capturas:**
```
faseXX-YY-descripcion-breve.png
Ejemplo: fase03-02-winrm-shell-established.png
```

**Cuando algo falla:**
1. Leer el error completo
2. Buscar en `lessons_learned.md` si es un problema conocido
3. Consultar el tradecraft — ¿hay alternativa?
4. Documentar el fallo y su causa
5. Intentar la alternativa

---

## 9. PASO 7 — CLEANUP

### Limpiar artefactos — comportamiento real de APT

El cleanup no es opcional — es parte del engagement. Un APT real elimina sus rastros. Practicarlo en el lab construye el hábito para certificaciones y engagements reales.

```
□ Eliminar SPNs añadidos para Targeted Kerberoasting
□ Restaurar plantillas ADCS modificadas (ESC4)
□ Eliminar tareas GPO añadidas
□ Eliminar binarios subidos al objetivo (C:\Temp\*.exe)
□ Eliminar cuentas de máquina creadas para RBCD
□ Limpiar historial PowerShell en el objetivo
□ Restaurar DACLs modificadas
□ Eliminar Shadow Credentials añadidas
□ Verificar que no quedan tickets en /tmp/*.ccache
□ Eliminar beacon del C2 del disco del objetivo
```

```powershell
# Limpiar historial PowerShell en el objetivo (vía Evil-WinRM)
Clear-History
Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue
```

> Ver `docs/operations/ENGAGEMENT_CHECKLIST.md` para el checklist completo de cleanup.

---

## 10. PASO 8 — ANALYSIS

### Post-mortem honesto

```
□ execution/post_exploitation.md — flujo completo documentado
□ analysis/lessons_learned.md — mínimo 3 lecciones nuevas
□ analysis/mitigations.md — contramedidas específicas del lab
□ OPERATION_XXX.md — todas las fases marcadas ✅
□ docs/reference/MITRE_MAPPING.md — nuevas técnicas añadidas
□ docs/operations/OPSEC_NOTES.md — insights OPSEC nuevos
```

**Preguntas de reflexión obligatorias:**
1. ¿Hubo alguna técnica que no funcionó como esperaba? ¿Por qué?
2. ¿Qué haría diferente en un engagement real?
3. ¿Qué técnica OPSEC adicional aplicaría?
4. ¿Qué habría detectado el Blue Team?
5. ¿Cómo se habría mitigado el ataque principal?

---

## 11. PASO 9 — BLUE TEAM

### Perspectiva defensiva

Cada técnica ofensiva tiene su contrapartida defensiva. Documentarla consolida la comprensión bidireccional del ataque.

Para cada técnica ejecutada:

| Campo | Contenido |
|-------|-----------|
| Event IDs | IDs generados por la técnica (4769, 4624, 5145...) |
| Regla SIGMA | Detección en formato SIGMA o pseudocódigo |
| Hardening | Configuración que habría bloqueado el ataque |
| Indicadores | IOCs observables (hashes, patrones de tráfico) |

```yaml
# Ejemplo regla SIGMA — Kerberoasting
title: Kerberoasting Detection
detection:
  selection:
    EventID: 4769
    ServiceName|not|endswith: '$'
    TicketEncryptionType: '0x17'  # RC4
  condition: selection
```

---

## 12. PASO 10 — REPORT

### Reporte ejecutivo

```
□ Reporte PDF generado (docs/report/Reporte_NOMBRE.pdf)
□ Resumen ejecutivo: objetivo, metodología, hallazgos, impacto
□ OPERATION_XXX.md finalizado
□ PROGRESS.md actualizado con horas y técnicas
□ CHANGELOG.md con entrada del lab
□ Commit con mensaje estándar
□ Snapshot post-lab en VirtualBox
□ git push
```

**Mensaje de commit estándar:**
```
feat: Lab-XX NOMBRE — [resumen]

Fases: X/X completadas
Credenciales: [resumen de loot]
TTPs: T1XXX, T1XXX
Horas: ~Xh
```

---

## 13. Estándares de calidad

### Un lab está completo cuando

```
□ Todas las fases ejecutadas y documentadas
□ Capturas con anotaciones para cada paso relevante
□ lessons_learned.md con mínimo 3 lecciones nuevas
□ mitigations.md con contramedidas específicas
□ OPERATION_XXX.md con todas las fases en ✅
□ Crown Jewels comprometidos y documentados
□ MITRE mapping actualizado
□ Cleanup ejecutado y documentado
□ Commit hecho con mensaje correcto
```

### Criterios de calidad

| Criterio | Estándar |
|----------|----------|
| Claridad | Un Red Teamer sin contexto previo puede seguir el writeup |
| Completitud | Incluye éxitos Y fallos con igual profundidad |
| OPSEC | Documenta alternativas más sigilosas para cada técnica |
| Blue Team | Incluye qué habría detectado y cómo mitigarlo |
| Reproducibilidad | Los comandos exactos permiten reproducir el lab desde cero |
| Cleanup | Los artefactos se eliminan como en un engagement real |

---

## 14. Iteración y mejora continua

### Después de cada Phase completada

1. Revisar todos los `lessons_learned.md` de los labs de esa phase
2. Identificar patrones — ¿qué errores se repiten?
3. Actualizar `DESIGN.md` con la versión siguiente del roadmap
4. Actualizar la coverage matrix CRTO
5. Ajustar los labs futuros basándose en lo aprendido

### Versioning del roadmap

```
v1.0 → Estructura inicial (Mayo 2026)
v2.0 → Rediseño tras completar Phase-01 + metodología 10 pasos (Junio 2026)
v3.0 → Tras completar Phase-02 (AD avanzado completo)
v4.0 → Tras completar Phase-03 (EDR evasion real)
```

---

*Red Team Ops Roadmap — Adrián Camacho | Junio 2026*  
*Metodología de trabajo v2.0 — Únicamente con fines educativos*