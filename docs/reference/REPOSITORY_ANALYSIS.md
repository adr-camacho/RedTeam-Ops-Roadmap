# 📊 REPOSITORY ANALYSIS — RedTeam-Ops-Roadmap
## Análisis exhaustivo, arquitectura, estado actual y roadmap

**Versión:** 1.0 | **Fecha:** 17/06/2026 | **Autor:** Claude (análisis) + Adrián Camacho (proyecto)

---

## 📋 Tabla de contenidos

1. [Visión General](#visión-general)
2. [Arquitectura](#arquitectura)
3. [Filosofía y Principios](#filosofía-y-principios)
4. [Estado Técnico Actual](#estado-técnico-actual)
5. [Coverage MITRE ATT&CK](#coverage-mitre-attck)
6. [Limitaciones Documentadas](#limitaciones-documentadas)
7. [Calidad de Documentación](#calidad-de-documentación)
8. [Roadmap de Mejora](#roadmap-de-mejora)

---

## 🎯 Visión General

### Objetivo fundamental

**RedTeam-Ops-Roadmap** es un **programa estructurado de formación en Red Team ofensivo** diseñado específicamente para preparación CRTO (Certified Red Team Operator) mediante adversary emulation en laboratorio educativo controlado.

**NO es:**
- ❌ Una colección de CTF writeups
- ❌ Un "hacking para principiantes"
- ❌ Ejercicios técnicos aislados

**SÍ es:**
- ✅ Un programa profesional que replica metodologías reales de equipos Red Team
- ✅ Infraestructura corporativa moderna con defensas realistas
- ✅ Pedagogía progresiva: cada lab agrega exactamente una capa de complejidad
- ✅ Documentación honesta: fallos documentados con la misma profundidad que éxitos

### Métricas actuales (17/06/2026)

```
Laboratorios completados:     7/15 (46.7%)
Tiempo invertido:              ~143 horas
Documentación:                 145 archivos .md
Scripts de provisioning:       56 archivos (PowerShell + Bash)
Tamaño total:                  453 MB
TTPs dominadas:                61 técnicas MITRE ATT&CK v14
Cobertura MITRE:               ~57% (meta: 80-85% con roadmap completo)
Fidelidad CRTO:                ~65% (meta: 98% con Phase-03 + Phase-04)
```

---

## 🏗️ Arquitectura

### Estructura física del repositorio

```
Red-Team_Labs/
├── Phase-01-Fundamentals/           ✅ COMPLETADA (3 labs)
│   ├── Lab-01-Ghost-Forest/         ✅ APT29 — Fundamentos Kerberos
│   ├── Lab-02-Silent-Bridge/        ✅ APT41 — Pivoting + exploits públicos
│   └── Lab-03-Dark-Gate/            ✅ APT29 — ADCS exploitation
├── Phase-02-Post-Exploitation/      🟡 EN PROGRESO (Labs 04-07)
│   ├── Lab-04-Iron-Forest/          ✅ APT28 — WriteDACL abuse
│   ├── Lab-05-Silver-Chain/         ✅ APT28 — Delegation abuse
│   ├── Lab-06-Black-Policy/         ✅ APT28 — Cross-forest trust
│   └── Lab-07-Shadow-Vault/         🟡 APT28 — LAPS + DPAPI (en ejecución)
├── Phase-03-Red-Team-Operations/    ⏳ PENDIENTE (Labs 08-11)
│   ├── Lab-08-Ghost-Signal/         ⏳ Lazarus — AMSI bypass in-memory
│   ├── Lab-09-First-Contact/        ⏳ Lazarus — Initial access
│   ├── Lab-10-Dark-Current/         ⏳ Lazarus — BOFs + Havoc C2
│   └── Lab-11-Deep-Holo/            ⏳ Lazarus — Multi-layer evasion
├── Phase-04-Enterprise-Simulation/  ⏳ PENDIENTE (Labs 12-15)
├── docs/                            📚 DOCUMENTACIÓN GLOBAL
│   ├── REPOSITORY_ANALYSIS.md       ← TÚ ESTÁS AQUÍ
│   ├── DESIGN.md             Filosofía + principios + roadmap
│   ├── reference/DETECTION_LIBRARY.md SIGMA rules + Event IDs
│   ├── operations/                  Checklists operacionales
│   ├── reference/                   Arsenal, infraestructura, MITRE mapping
│   └── progress/                    Diario de sesiones + changelog
├── setup/                           🛠️ Scripts de provisioning
├── tooling/                         🔧 Herramientas de laboratorio
└── README.md                        🏠 Página principal

Total: 145 archivos .md + 56 scripts = 201 assets documentados
```

### Estructura por lab (ejemplo Lab-01)

```
Lab-01-Ghost-Forest/
├── README.md                          Visión general
├── OPERATION_GHOST_FOREST.md          Reporte operacional formal
├── docs/
│   ├── theory/tradecraft.md           Teoría: Kerberos, AS-REP, etc.
│   ├── execution/
│   │   ├── infrastructure_setup.md    Provisioning detallado
│   │   ├── enumeration_log.md         Reconnaissance paso a paso
│   │   ├── exploitation.md            Explotación técnica
│   │   ├── privilege_escalation.md    Escalada detallada
│   │   ├── lateral_movement.md        Movimiento entre sistemas
│   │   ├── delegation.md              Unconstrained/Constrained
│   │   ├── gpo_abuse.md               GPO Abuse
│   │   ├── acl_abuse.md               ACL Abuse
│   │   ├── persistence.md             C2 deployment
│   │   └── objective_completion.md    Crown Jewels
│   └── analysis/
│       ├── mitigations.md             Hardening recomendado
│       └── lessons_learned.md         Limitaciones encontradas
├── screenshots/                       Evidencia visual
├── nmap/                              Resultados de escaneo
├── loot/                              Credenciales, hashes, certs
└── setup/                             Scripts específicos del lab
```

### Infraestructura CRTO-equivalent

| Host | IP | OS | RAM | Dominio | Rol |
|------|----|----|-----|---------|-----|
| DC-01 | 10.0.2.10 | Windows Server 2025 | 22GB | atackcorp.local | Root DC + ADCS + LAPS |
| DC-02 | 10.0.2.11 | Windows Server 2022 | 3GB | corp.local | Root DC (Forest 2) |
| DC-03 | 10.0.2.13 | Windows Server 2022 | 3GB | child.atackcorp.local | Child DC |
| DC-04 | 10.0.2.14 | Windows Server 2022 | 2GB | ext.local | Root DC (Forest 3) |
| WKSTN-01 | 10.0.2.8 | Windows 11 | 3GB | atackcorp.local | Workstation + LAPS |
| WKSTN-02 | 10.0.2.12 | Windows 11 | 3GB | corp.local | Workstation |
| Kali | 10.0.2.9 | Kali 2026.1 | 8GB | — | Atacante + C2 Server |

**Network:** NAT LabRedTeam 10.0.2.0/24 | Route adicional 10.0.3.0/24

---

## 💡 Filosofía y Principios

### Los 7 pilares fundamentales

**1. Comprensión sobre ejecución**
- ¿Entiendes POR QUÉ funciona AS-REP Roasting? (protocolos Kerberos)
- ¿Podrías implementar la técnica desde cero si el tool fallara?
- No es suficiente "ejecutar la herramienta" — hay que entender el protocolo

**2. OPSEC como mentalidad, no como fase**
- ¿Qué logs genera cada comando? (Event IDs específicos)
- ¿Cómo limpio artefactos sin dejar rastro?
- ¿Puedo hacer esto desde Kali sin tocar el objetivo?
- OPSEC es una pregunta constante, no el último capítulo

**3. Realismo sobre velocidad**
- Crown Jewels explícitos (no "romper un lab por romper")
- Adversarios reales documentados en MITRE ATT&CK
- Defensas modernas: Defender activo, PAC Validation, KPP, SID Filtering
- Velocidad < Comprensión

**4. Blue Team integrado**
- Cada técnica MITRE viene acompañada de detección
- Event IDs generados (T1558.003 → Event ID 4769)
- Reglas SIGMA para cada ataque
- Hardening recomendado
- "Un buen Red Teamer sabe cómo le detectan"

**5. Progresión pedagógica incremental**
- Lab-01: Kerberos + credential cracking (base)
- Lab-02: Pivoting en red segmentada (+1 capa)
- Lab-03: ADCS exploitation (+1 capa)
- Lab-04: ACL abuse (+1 capa)
- ... NUNCA dos conceptos nuevos simultáneamente

**6. Documentación honesta**
- ✅ Golden Tickets rechazados por PAC Validation (documentado)
- ✅ LSASS dump bloqueado por KPP (documentado)
- ✅ AMSI bypass no persiste en WinRM (documentado)
- Los fallos son lecciones didácticas más valiosas que los éxitos

**7. Fidelidad CRTO exacta**
- Multi-forest: atackcorp.local + corp.local + ext.local + child.atackcorp.local
- SID Filtering OFF (Labs 04-06) para permitir cross-forest attacks
- SID Filtering ON (Labs 12-14) para defensas realistas
- Windows Server 2025 con LAPS nativo
- Estructura idéntica al examen CRTO

---

## 📊 Estado Técnico Actual

### Labs completados (7/15)

#### ✅ Lab-01: GHOST FOREST (APT29)
- **Estado:** Completado | **Horas:** ~40 | **Técnicas:** 13
- **Crown Jewels:** Domain Admin hash + credenciales fin.garcia + hashes NTLM
- **Técnicas MITRE:** T1558.004, T1558.003, T1003.006, T1550.002, T1484.001, T1222, T1558.001, T1187, T1071.001
- **Lecciones:** Golden Tickets bloqueados por PAC, Evil-WinRM Network Logon limitaciones

#### ✅ Lab-02: SILENT BRIDGE (APT41)
- **Estado:** Completado | **Horas:** ~18 | **Técnicas:** 8
- **Crown Jewels:** thomas credentials + SAM dump PC-01 + Git history secrets
- **Técnicas MITRE:** T1190, T1572, T1021.002, T1552.001, T1003.002, T1003.006
- **Lecciones:** Ligolo-ng full-duplex tunneling, Git como fuente de credenciales

#### ✅ Lab-03: DARK GATE (APT29)
- **Estado:** Completado | **Horas:** ~16 | **Técnicas:** 7
- **Crown Jewels:** Certificado válido como Administrador post-rotación
- **Técnicas MITRE:** T1649 (ESC1/ESC4/ESC8), T1557.001, T1558.001, T1070.004
- **Lecciones:** Certipy v5.0.4 necesario, certificados como persistencia

#### ✅ Lab-04: IRON FOREST (APT28)
- **Estado:** Completado | **Horas:** ~20 | **Técnicas:** 8
- **Crown Jewels:** Domain Admin hash vía WriteDACL abuse + credenciales SYSVOL
- **Técnicas MITRE:** T1222, T1003.006, T1552.001, T1550.003, T1557.001
- **Lecciones:** bloodyad más robusto que impacket-dacledit, ADIDNS poisoning

#### ✅ Lab-05: SILVER CHAIN (APT28)
- **Estado:** Completado | **Horas:** ~20 | **Técnicas:** 8
- **Crown Jewels:** TGS como Administrador vía RBCD + Silver + Diamond Tickets
- **Técnicas MITRE:** T1558.001, T1556, T1558.002, T1550.001
- **Lecciones:** pywhisker requiere --use-ldaps en WS2025, RBCD más flexible

#### ✅ Lab-06: BLACK POLICY (APT28)
- **Estado:** Completado (Fase 02 ejecutada) | **Horas:** ~25 | **Técnicas:** 9
- **Crown Jewels:** Forest Admin cross-forest vía SID History injection
- **Técnicas MITRE:** T1134.005, T1482, T1087.002, T1558.003, T1003.006
- **Lecciones:** SID History protegido, DSInternals requiere parada NTDS

#### ⏳ Lab-07: SHADOW VAULT (APT28) — EN PROGRESO
- **Estado:** Fases 01-02 completadas, Fase 03+ en redirección | **Horas:** ~8 | **Técnicas planificadas:** 8
- **Crown Jewels:** LAPS password + DPAPI credentials + Shadow Credentials NT hash + beacon persistente
- **Técnicas MITRE:** T1201, T1555.004, T1003.001, T1649, T1071.001, T1562.001, T1070.004
- **Bloqueador actual:** AMSI bypass via PowerShell no persiste en WinRM (documentado + redirección en proceso)

---

## 🎯 Coverage MITRE ATT&CK

### Técnicas completadas (61 total)

**Kerberos & Tickets (10):**
- ✅ AS-REP Roasting (T1558.004)
- ✅ Kerberoasting (T1558.003)
- ✅ Silver Ticket (T1558.002)
- ⚠️ Golden Ticket (T1558.001) — bloqueado por PAC
- ✅ Diamond Ticket (T1558.001)
- ✅ Unconstrained Delegation (T1558.001)
- ✅ Constrained Delegation (T1558.001)
- ✅ RBCD (T1558.001)
- ✅ Pass-the-Ticket (T1550.003, T1550.001)

**Credential Access (12):**
- ✅ DCSync (T1003.006)
- ✅ SAM dump (T1003.002)
- ❌ LSASS dump (T1003.001) — KPP bloquea
- ✅ DPAPI Credential Manager (T1555.004)
- ✅ Shadow Credentials (T1556)
- ✅ Credentials in files (T1552.001)
- ✅ LAPS password disclosure (T1201)
- ✅ Pass-the-Hash (T1550.002)
- ✅ Overpass-the-Hash (T1550.003)
- ✅ ADCS ESC1/ESC4/ESC8 (T1649)

**Defense Evasion (8):**
- ⚠️ AMSI bypass (T1562.001) — no persiste en WinRM
- ✅ Indicator removal (T1070.004)
- ✅ Obfuscation (T1140, T1027)
- ✅ Disable event logging (T1562.008)

**Lateral Movement (6):**
- ✅ WinRM (T1021.006)
- ✅ SMB (T1021.002)
- ✅ Pass-the-Hash/Ticket (T1550.002/003)
- ✅ Tool transfer (T1570)

**Persistence (5):**
- ✅ Account manipulation (T1098.003)
- ✅ Certificate persistence (T1649)
- ✅ GPO abuse (T1484.001)

**Discovery & Enumeration (9):**
- ✅ LDAP enumeration (T1087.002)
- ✅ Domain groups discovery (T1087.003/004)
- ✅ Trust discovery (T1482)
- ✅ BloodHound (T1087.002)
- ✅ Network scanning (T1046)
- ✅ SMB shares (T1135)

**Command & Control (3):**
- ✅ Sliver C2 (T1071.001, T1573.002, T1572)

### Resumen de cobertura

```
Cobertura actual:    61 / 107 TTPs = 57%
Meta Lab-07:         65 / 107 = 61%
Meta Phase-03:       85 / 107 = 79%
Meta completa:       98 / 107 = 92%
```

---

## ⚠️ Limitaciones Documentadas

### 1. Golden Tickets bloqueados por PAC Validation

**Técnica:** Golden Ticket forjado  
**OS:** Windows Server 2022+  
**Estado:** ❌ BLOQUEADO  

**Por qué:**
- KB5005413 (2021) implementó validación criptográfica de PAC
- DCs validan que el PAC sea firmado con la clave krbtgt
- Forjar un PAC sin clavedu online es imposible
- Golden Tickets = técnica EOL en defenses modernas

**Alternativa funcionando:**
- ✅ Silver Tickets (no usan PAC)
- ✅ Diamond Tickets (parcial via Rubeus)

**Lección:** Técnicas evolucionan. Red teamers modernos no confían en Golden Tickets.

---

### 2. LSASS dump bloqueado por Kernel Patch Protection

**Técnica:** rundll32 comsvcs MiniDump  
**OS:** Windows 11 Build 26100+  
**Estado:** ❌ BLOQUEADO  

**Por qué:**
- LSASS es Protected Process Light (RunAsPPL=2)
- Windows 11 23H2+ tiene Kernel Patch Protection adicional
- Incluso con PPL=0, el kernel bloquea acceso a LSASS

**Alternativas:**
- ⏳ Kernel exploit (BYOD) — cubierto en Phase-03 Labs-08-11
- ✅ Secretsdump via DCSync (alternativa funcional)
- ✅ Beacon Sliver para acceso remoto

**Lección:** LSASS dump via herramientas estándar = técnica EOL.

---

### 3. AMSI bypass NO persiste en WinRM

**Técnica:** Marshal.WriteInt32 patching  
**Vector:** PowerShell via Evil-WinRM  
**Estado:** ⚠️ NO FUNCIONA (no es error del lab)  

**Por qué:**
- Nueva sesión Evil-WinRM = nuevo proceso PowerShell
- AMSI se inicializa frescamente en cada proceso
- Patching es local al proceso actual
- `-EncodedCommand` es detectado por Defender

**Alternativa funcionando:**
- ✅ Beacon ejecutable (.exe) con evasión integrada
- ✅ Sliver C2 con ofuscación nativa (no necesita PowerShell)

**Lección:** OPSEC es el vector, no la herramienta. Evil-WinRM + PowerShell ≠ ataque realista.

---

### 4. SID History es atributo protegido

**Técnica:** Modificar sIDHistory vía LDAP  
**Herramientas intentadas:** bloodyad, impacket-dacledit, mimikatz `misc::addsid`  
**Estado:** ❌ NINGUNA FUNCIONA  

**Solución funcionando:**
- ✅ DSInternals `Add-ADDBSidHistory` (requiere parada NTDS)
- ✅ impacket secretsdump via DS-Replication (más silencioso)

**Lección:** Algunos atributos están protegidos diseñadamente. DSInternals accede ntds.dit directamente.

---

### 5. Evil-WinRM crea Network Logon sin privilegios

**Problema:** `Get-ADGroup -Server cross-domain` falla  
**Causa:** Network Logon (tipo 3) sin SeDebugPrivilege  

**Alternativas documentadas:**
- ✅ LDAP reflection API en lugar de `Get-ADGroup`
- ✅ RDP para tareas que requieren Interactive logon

---

## 📚 Calidad de Documentación

### Fortalezas

1. ✅ **Comandos exactos y copiables** — Funcionales en el entorno
2. ✅ **Versiones de herramientas documentadas** — Certipy v5.0.4, SharpHound v2.5.9, etc.
3. ✅ **Screenshots con anotaciones** — Recuadros, flechas, explicaciones
4. ✅ **MITRE mapping explícito** — T-ID con descripción y contexto
5. ✅ **Rutas de archivos exactas** — ~/RedTeam-Repo/setup/...
6. ✅ **Limitaciones conocidas** — No oculta problemas
7. ✅ **Análisis defensivo** — Hardening, Event IDs, SIGMA rules
8. ✅ **OPSEC considerations** — En cada fase
9. ✅ **Lecciones trans-lab** — Aplicables a futuro

### Áreas de mejora (No-blockers)

1. ⚠️ **Guía de error-handling** — "Si error X ocurre, intenta Y"
2. ⚠️ **Matriz de compatibilidad** — Herramienta × versión × OS
3. ⚠️ **Timeline visual** — Gráfico Gantt de ejecución
4. ⚠️ **Videos/demos** — Técnicas complejas (Shadow Credentials, RBCD)
5. ⚠️ **Comparativa ideal vs realidad** — Tabla por técnica

---

## 🚀 Roadmap de Mejora

### Inmediato (Julio — Antes CRTO agosto)

**Lab-07 SHADOW VAULT:**
- [ ] Redirigir ejecución Fase 03 a beacon Sliver .exe
- [ ] Documentar bloqueo KPP (LSASS dump)
- [ ] Completar Fases 04-05
- [ ] Capturar screenshots finales
- [ ] Marcar como ✅ COMPLETADO

**Lab-01 Refinamiento:**
- [ ] Completar `delegation.md` con ejemplos
- [ ] Completar `gpo_abuse.md` con ejemplos
- [ ] Completar `acl_abuse.md` con ejemplos
- [ ] Crear `bloodhound.md` como documento nuevo
- [ ] Actualizar `lessons_learned.md`

**Tooling:**
- [ ] Crear `lab_healthcheck.sh` (validar VMs pre-lab)
- [ ] Crear `lab_teardown.sh` (limpiar entre labs)
- [ ] Actualizar `arsenal_setup.sh` (versiones actuales)

### Corto plazo (Agosto)

**Documentación global:**
- [ ] `docs/COVERAGE_MATRIX.md` — Técnicas × Labs
- [ ] `docs/TROUBLESHOOTING.md` — Error handling
- [ ] `docs/TOOL_VERSIONS.md` — Compatibilidad
- [ ] `docs/OPSEC_PLAYBOOK.md` — Mejores prácticas
- [ ] `docs/BLUE_TEAM.md` — Perspectiva defensiva

**Phase-03 Planificación:**
- [ ] Diseñar Labs 08-11 (AMSI, Process Injection, BOFs)
- [ ] Definir Crown Jewels y técnicas MITRE
- [ ] Pre-provisioning VMs

### Mediano plazo (Septiembre post-CRTO)

**Phase-04 Ejecución:**
- Labs 12-15 (Enterprise simulation completa)
- Cloud hybrid (Azure AD / Entra ID)
- SID Filtering ON (defensas realistas)

**Presentación profesional:**
- [ ] GitHub Pages con site visual
- [ ] LinkedIn posts por lab
- [ ] Blog técnico (articulos detallados)
- [ ] Posible GitHub release (con disclaimers)

---

## 📖 Notas importantes

### Sobre este repositorio

Este repositorio es un **programa estructurado de formación** equivalente a:
- Cursos CRTO oficiales (Hack The Box)
- Tradecraft guides profesionales (ired.team)
- Adversary emulation frameworks (MITRE CAR)

### Licencia y uso educativo

```
⚠️ DISCLAIMER:
Todo el contenido de este repositorio es de uso exclusivamente educativo
y se ejecuta en entornos de laboratorio controlados bajo consentimiento explícito.

El uso de estas técnicas contra sistemas sin autorización explícita es
ILEGAL y está penado por la ley. El autor no se hace responsable del uso
indebido de este material.
```

### Contribuciones

Este proyecto actualmente es de un autor. Las mejoras planificadas incluyen:
- Feedback desde otros Red Teamers
- Integración comunitaria post-CRTO
- Posible open-sourcing controlado

---

## 📞 Referencias rápidas

- **DESIGN.md** — Filosofía completa y roadmap v2.1
- **README.md** — Visión general y estado actual
- **docs/PROGRESS.md** — Diario de sesiones
- **docs/reference/ARSENAL.md** — Herramientas completas
- **docs/reference/MITRE_MAPPING.md** — Coverage MITRE detallado

---

*Repository Analysis v1.0 — Claude | 17/06/2026*  
*Para usar este documento: referencia en README.md o estructura de docs/*