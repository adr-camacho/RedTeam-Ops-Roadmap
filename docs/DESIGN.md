# DESIGN.md — Red Team Ops Roadmap
## Principios de Diseño, Metodología y Arquitectura

**Versión:** 2.0 | **Fecha:** 20/05/2026 | **Autor:** Adrián Camacho

---

## 1. Filosofía de Diseño

Este roadmap no es una colección de labs — es un **programa de formación estructurado** con un objetivo claro: transformar a alguien sin experiencia en Red Team en un profesional capaz de ejecutar engagements reales contra entornos corporativos modernos.

### Principios fundamentales

**1. Comprensión sobre ejecución**  
Cada técnica se entiende a nivel de protocolo antes de automatizarla. Si una herramienta falla, el operador sabe construir el exploit desde cero.

**2. OPSEC como mentalidad, no como fase**  
El OPSEC no es un capítulo al final del lab — es una pregunta constante. ¿Puedo hacer esto desde Kali sin tocar el objetivo? ¿Qué logs genera este comando? ¿Cómo limpio los artefactos?

**3. Realismo sobre velocidad**  
Los labs incluyen crown jewels definidos, adversarios reales con TTPs documentadas, y comportamientos defensivos que reflejan entornos corporativos modernos (PAC Validation, Defender activo, AMSI).

**4. Blue Team integrado**  
Cada técnica ofensiva viene acompañada de su contrapartida defensiva: Event IDs generados, reglas SIGMA, hardening recomendado. Un buen Red Teamer conoce cómo le detectan.

**5. Progresión pedagógica incremental**  
Cada lab añade exactamente una capa de complejidad sobre el anterior. Nunca se introducen dos conceptos nuevos simultáneamente si uno de ellos puede esperar.

**6. Documentación honesta**  
Los fallos se documentan con la misma profundidad que los éxitos. Una técnica que no funciona en un entorno moderno es una lección más valiosa que una que sí funciona.

---

## 2. Adversary Emulation Methodology

El roadmap sigue el framework de **adversary emulation** — no ejecutamos técnicas genéricas sino que reproducimos comportamientos de grupos APT reales documentados en MITRE ATT&CK.

### Proceso por lab

```
1. Seleccionar adversario (APT29, APT41, APT28, Lazarus, APT10)
2. Estudiar sus TTPs documentadas en MITRE ATT&CK Groups
3. Diseñar el entorno que refleje un objetivo real del adversario
4. Ejecutar reproduciendo su comportamiento (no solo las técnicas)
5. Documentar diferencias entre el comportamiento ideal y el real
6. Analizar desde perspectiva Blue Team cómo detectar al adversario
```

### Adversarios y su justificación

| Adversario | Grupo MITRE | Fase | Justificación |
|-----------|-------------|------|---------------|
| **APT29** (Cozy Bear) | G0016 | Phase-01 | Especialistas en AD, Kerberos y ADCS — fundamentos ideales |
| **APT41** (Double Dragon) | G0096 | Phase-01 | Pivoting y acceso inicial via exploits públicos — Lab-02 |
| **APT28** (Fancy Bear) | G0007 | Phase-02 | AD avanzado, Forest Trusts, GPO — post-explotación |
| **Lazarus Group** | G0032 | Phase-03 | EDR evasion, C2 avanzado, OPSEC extremo |
| **APT10** (Stone Panda) | G0045 | Phase-04 | Simulaciones largas, infraestructura compleja |

---

## 3. Roadmap v2.0 — Estructura Revisada

### Cambios principales respecto a v1.0

| v1.0 | v2.0 | Razón |
|------|------|-------|
| 4 Phases, 12 Labs | 4 Phases, 14 Labs (+2) | Añadir Initial Access real y Azure AD |
| BloodHound en Fase 11 de Lab-01 | BloodHound como metodología transversal | Es la herramienta #1, no una técnica avanzada |
| Sin crown jewels definidos | Crown jewels en cada lab | Realismo — los objetivos concretos motivan las decisiones |
| Cobertura ~65% | Objetivo: 80-85% | Gaps cubiertos: Initial Access, Azure, EDR progresivo |
| Lab-01 con 13 fases mezcladas | Lab-01 reestructurado, fases avanzadas en Phase-02 | Progresión pedagógica clara |

### Estructura v2.0

```
Phase-01: Fundamentos AD (Labs 01-03) ← Labs existentes, pulidos
Phase-02: AD Avanzado (Labs 04-07)    ← +1 lab nuevo (Shadow Credentials/LAPS)
Phase-03: Red Team Ops (Labs 08-11)   ← +1 lab nuevo (Initial Access real)
Phase-04: Enterprise Simulation (Labs 12-14) ← +1 lab nuevo (Azure AD)
```

---

## 4. Coverage Matrix v2.0

### Técnicas cubiertas por fase

| Técnica / Concepto | Lab | Phase | Estado |
|-------------------|-----|-------|--------|
| **Reconocimiento y enumeración AD** | | | |
| Network scanning (Nmap) | Lab-01 | P01 | ✅ |
| LDAP enumeration | Lab-01 | P01 | ✅ |
| SMB enumeration | Lab-01 | P01 | ✅ |
| BloodHound — metodología completa | Lab-01 | P01 | ✅ |
| PowerView enumeration | Lab-04 | P02 | ⏳ |
| ADIDNS abuse | Lab-04 | P02 | ⏳ |
| **Kerberos Attacks** | | | |
| AS-REP Roasting | Lab-01 | P01 | ✅ |
| Kerberoasting | Lab-01 | P01 | ✅ |
| Targeted Kerberoasting | Lab-01 | P01 | ✅ |
| Pass-the-Ticket | Lab-01 | P01 | ✅ |
| Pass-the-Hash | Lab-01/03 | P01 | ✅ |
| Overpass-the-Hash | Lab-04 | P02 | ⏳ |
| Golden Ticket | Lab-01 | P01 | 🔄 Parcial |
| Silver Ticket | Lab-05 | P02 | ⏳ |
| Diamond Ticket | Lab-05 | P02 | ⏳ |
| **Delegation Abuse** | | | |
| Unconstrained Delegation | Lab-01 | P01 | ✅ |
| Constrained Delegation (S4U2Proxy) | Lab-01 | P01 | ✅ |
| Resource-Based Constrained Delegation | Lab-05 | P02 | ⏳ |
| **ACL / Permission Abuse** | | | |
| GenericWrite → Targeted Kerberoast | Lab-01 | P01 | ✅ |
| WriteDACL → DCSync | Lab-04 | P02 | ⏳ |
| GenericAll → Shadow Credentials | Lab-05 | P02 | ⏳ |
| ForceChangePassword | Lab-04 | P02 | ⏳ |
| **GPO / Policy Abuse** | | | |
| GPO Modification (GpoEditDeleteModifySecurity) | Lab-01 | P01 | ✅ |
| SID History injection | Lab-06 | P02 | ⏳ |
| Cross-Forest Trust exploitation | Lab-06 | P02 | ⏳ |
| **Credential Access** | | | |
| DCSync | Lab-01/03 | P01 | ✅ |
| LSASS dump alternativo | Lab-07 | P02 | ⏳ |
| DPAPI — credenciales navegadores/vaults | Lab-07 | P02 | ⏳ |
| LAPS abuse | Lab-07 | P02 | ⏳ |
| Shadow Credentials | Lab-07 | P02 | ⏳ |
| Credential hunting (files, registry, DB) | Lab-04 | P02 | ⏳ |
| **ADCS** | | | |
| ESC1 — SAN Abuse | Lab-03 | P01 | ✅ |
| ESC4 — Template Modification | Lab-03 | P01 | ✅ |
| ESC8 — NTLM Relay (identificado) | Lab-03 | P01 | 🔄 |
| ESC6/ESC7 | Lab-07 | P02 | ⏳ |
| **Initial Access** | | | |
| Web exploit (CVE público) | Lab-02 | P01 | ✅ |
| Git history credential exposure | Lab-02 | P01 | ✅ |
| Password spraying | Lab-08 | P03 | ⏳ |
| Phishing (HTML smuggling) | Lab-08 | P03 | ⏳ |
| VPN/Citrix abuse | Lab-08 | P03 | ⏳ |
| **Pivoting y C2** | | | |
| Ligolo-ng tunneling | Lab-02 | P01 | ✅ |
| Sliver HTTPS C2 | Lab-01/02/03 | P01 | ✅ |
| Relay C2 (listener en pivote) | Lab-02 | P01 | ✅ |
| Havoc C2 | Lab-09 | P03 | ⏳ |
| C2 infraestructura (redirectors) | Lab-10 | P03 | ⏳ |
| Domain fronting | Lab-10 | P03 | ⏳ |
| **EDR / Evasión** | | | |
| AMSI bypass (in-memory) | Lab-08 | P03 | ⏳ |
| Process injection | Lab-08 | P03 | ⏳ |
| Direct syscalls (SysWhispers) | Lab-08 | P03 | ⏳ |
| Sleep obfuscation | Lab-09 | P03 | ⏳ |
| BOFs (Beacon Object Files) | Lab-09 | P03 | ⏳ |
| ETW patching | Lab-09 | P03 | ⏳ |
| PE evasion (sin Tamper Protection) | Lab-08 | P03 | ⏳ |
| **Azure AD / Entra ID** | | | |
| Azure AD enumeration | Lab-13 | P04 | ⏳ |
| Token theft (PRT) | Lab-13 | P04 | ⏳ |
| Hybrid AD attacks (on-prem → cloud) | Lab-13 | P04 | ⏳ |
| Azure privilege escalation | Lab-13 | P04 | ⏳ |
| **Forest / Enterprise** | | | |
| Forest Trust enumeration | Lab-11 | P04 | ⏳ |
| SID Filtering bypass | Lab-11 | P04 | ⏳ |
| Cross-forest Kerberoasting | Lab-11 | P04 | ⏳ |
| ExtraSids attack | Lab-06 | P02 | ⏳ |

### Resumen de cobertura

| Categoría | Técnicas cubiertas | Total | % |
|-----------|-------------------|-------|---|
| Reconocimiento/Enum | 4 | 6 | 67% |
| Kerberos Attacks | 6 | 10 | 60% |
| Delegation Abuse | 2 | 3 | 67% |
| ACL/Permission Abuse | 1 | 4 | 25% |
| GPO/Policy Abuse | 1 | 3 | 33% |
| Credential Access | 2 | 7 | 29% |
| ADCS | 2 | 4 | 50% |
| Initial Access | 2 | 5 | 40% |
| Pivoting y C2 | 4 | 6 | 67% |
| EDR/Evasión | 0 | 7 | 0% |
| Azure AD | 0 | 4 | 0% |
| Forest/Enterprise | 0 | 4 | 0% |
| **TOTAL** | **24** | **63** | **~38%** |

> **Nota:** La cobertura actual es ~38% de técnicas individuales. Completando el roadmap v2.0 se llegará al ~80%.

---

## 5. Crown Jewels — Objetivos por Lab

En entornos reales nunca se ataca "todo" — se identifican activos de alto valor y se diseña el path más directo hacia ellos. Cada lab tiene crown jewels definidos que motivan las decisiones tácticas.

| Lab | Crown Jewels | Justificación |
|-----|-------------|---------------|
| **Lab-01** | Hash NTLM del Administrador + DB financiera (fin.garcia) | Credenciales de DA + datos sensibles de Finanzas |
| **Lab-02** | Credenciales de PC-01 (thomas) + SAM dump | Endpoint Windows interno en red segmentada |
| **Lab-03** | Certificado de Administrador + persistencia post-rotación | Persistencia via certificado válido tras cambio de contraseña |
| **Lab-04** | Hash DA via WriteDACL + credenciales en shares | Escalada via permisos AD abusables |
| **Lab-05** | TGS como Administrador via RBCD + Silver Ticket | Impersonación sin contraseña |
| **Lab-06** | Acceso cross-forest + SID History injection | Escalada entre dominios |
| **Lab-07** | LAPS password + DPAPI credentials | Credenciales protegidas por el sistema |
| **Lab-08** | Foothold inicial via phishing/spraying | Primer acceso sin credenciales previas |
| **Lab-09** | Beacon persistente sin detección EDR | Operación encubierta en entorno con EDR activo |
| **Lab-10** | Infraestructura C2 profesional operativa | Redirectors + domain fronting |
| **Lab-11** | Forest Admin via trust exploitation | Escalada entre forests |
| **Lab-12** | Azure Global Admin via PRT theft | Cloud privilege escalation |
| **Lab-13** | Simulación engagement completo | End-to-end Red Team operation |
| **Lab-14** | CRTO exam simulation | Validación de competencias |

---

## 6. Roadmap v2.0 — Detalle por Lab

### Phase-01: Fundamentos AD

#### Lab-01 — GHOST FOREST ✅
- **Adversario:** APT29 | **Entorno:** atackcorp.local (DC-01 + WKSTN-01)
- **Kill chain:** AS-REP Roasting → Kerberoasting → DA → Delegation → GPO → ACL
- **Crown Jewels:** Hash Administrador + credenciales fin.garcia
- **Estado:** Completado (13 fases)

#### Lab-02 — SILENT BRIDGE ✅
- **Adversario:** APT41 | **Entorno:** Red segmentada (PROD + GIT + PC-01)
- **Kill chain:** CVE-2019-12840 → Ligolo-ng → Git history → WinRM → C2
- **Crown Jewels:** SAM dump PC-01 + credenciales thomas
- **Estado:** Completado

#### Lab-03 — DARK GATE ✅
- **Adversario:** APT29 | **Entorno:** atackcorp.local + ADCS
- **Kill chain:** ESC1 → cert DA → ESC4 → persistencia certificado
- **Crown Jewels:** Certificado Administrador válido post-rotación
- **Estado:** Completado

---

### Phase-02: AD Avanzado

#### Lab-04 — IRON FOREST ⏳
- **Adversario:** APT28 | **Entorno:** atackcorp.local extendido
- **Técnicas nuevas:** WriteDACL, ForceChangePassword, Overpass-the-Hash, credential hunting
- **Crown Jewels:** Hash DA via WriteDACL + credenciales en shares SYSVOL
- **Progresión:** Lab-01 cubrió GenericWrite. Este lab cubre WriteDACL y GenericAll completo.

#### Lab-05 — SILVER CHAIN ⏳
- **Adversario:** APT28 | **Entorno:** atackcorp.local
- **Técnicas nuevas:** RBCD, Shadow Credentials, Silver Ticket, Diamond Ticket
- **Crown Jewels:** TGS como Administrador sin contraseña (RBCD)
- **Progresión:** Lab-01 cubrió Unconstrained/Constrained. Este lab cubre RBCD y técnicas modernas.

#### Lab-06 — BLACK POLICY ⏳
- **Adversario:** APT28 | **Entorno:** Multi-dominio (nuevo Forest añadido)
- **Técnicas nuevas:** SID History, ExtraSids, Cross-Forest Trust, Forest Trust enumeration
- **Crown Jewels:** Forest Admin del segundo dominio
- **Progresión:** Lab-01 cubrió GPO dentro del dominio. Este lab cubre cross-domain.

#### Lab-07 — SHADOW VAULT ⏳ (NUEVO)
- **Adversario:** APT28 | **Entorno:** atackcorp.local + LAPS configurado
- **Técnicas nuevas:** LAPS abuse, DPAPI, Shadow Credentials, LSASS dump alternativo
- **Crown Jewels:** LAPS password + credenciales en DPAPI vault
- **Justificación:** Gap crítico identificado en v1.0 — técnicas modernas de credential access
- **Nombre de operación:** SHADOW VAULT

---

### Phase-03: Red Team Operations

#### Lab-08 — FIRST CONTACT ⏳ (NUEVO)
- **Adversario:** Lazarus | **Entorno:** Desde Internet (sin credenciales previas)
- **Técnicas nuevas:** Password spraying (Kerbrute), phishing HTML smuggling, VBA macros, HTML Smuggling
- **Crown Jewels:** Primer foothold en la red corporativa sin credenciales previas
- **Justificación:** Cronológicamente correcto — en un engagement real, Initial Access viene antes que la evasión
- **Nombre de operación:** FIRST CONTACT
- **CRTO:** Módulo "Initial Compromise" completo

#### Lab-09 — GHOST SIGNAL ⏳ (renombrado de Lab-07)
- **Adversario:** Lazarus | **Entorno:** atackcorp.local con Defender activo
- **Técnicas nuevas:** AMSI bypass, process injection, direct syscalls, PE evasion, AppLocker bypass
- **Crown Jewels:** Beacon persistente en DC-01 sin alertas Defender
- **Progresión:** Primera vez que Defender está completamente activo
- **CRTO:** Módulos "AV Evasion", "AMSI", "AppLocker"

#### Lab-10 — DARK CURRENT ⏳ (renombrado de Lab-08)
- **Adversario:** Lazarus | **Entorno:** atackcorp.local con EDR real
- **Técnicas nuevas:** Havoc C2, sleep obfuscation, BOFs, ETW patching, Malleable C2
- **Crown Jewels:** C2 operativo sin detección en entorno con EDR activo
- **CRTO:** Módulos "Malleable C2", "BOFs", "Behavioural Detections"

#### Lab-11 — DEEP HOLO ⏳ (renombrado de Lab-09)
- **Adversario:** Lazarus | **Entorno:** Corporativo multicapa con segmentación real
- **Técnicas nuevas:** C2 infraestructura (redirectors, domain fronting, profiles), Pivot Listeners
- **Crown Jewels:** Infraestructura C2 profesional operativa end-to-end
- **CRTO:** Módulos "Pivot Listeners", "Proxychains", "Reverse Port Forwards"

---

### Phase-04: Enterprise Simulation

#### Lab-12 — RED DANTE ⏳ (renombrado de Lab-10)
- **Adversario:** APT10 | **Entorno:** Red masiva heterogénea
- **Técnicas:** Consolidación de todo lo anterior en escenario complejo
- **Crown Jewels:** Compromiso total de infraestructura enterprise

#### Lab-13 — AZURE BREACH ⏳ (NUEVO — CRÍTICO)
- **Adversario:** APT10 | **Entorno:** Hybrid AD (on-prem + Azure AD/Entra ID)
- **Técnicas nuevas:** Azure AD enumeration, PRT theft, token abuse, hybrid attacks
- **Crown Jewels:** Azure Global Admin via comprometer cuenta sincronizada on-prem
- **Justificación:** Imposible ignorar en 2026 — el 90% de empresas tienen AD híbrido
- **Nombre de operación:** AZURE BREACH

#### Lab-14 — OPERATION ZEPHYR ⏳ (renombrado de Lab-12)
- **Adversario:** APT10 | **Entorno:** Full enterprise simulation
- **Técnicas:** Forest Trusts avanzados + CRTO exam preparation
- **Crown Jewels:** Compromiso total multi-forest
- **Justificación:** Preparación directa para certificación CRTO

---

## 7. Cobertura Objetivo v2.0

Con el roadmap v2.0 completo:

| Área | v1.0 | v2.0 | Mejora |
|------|------|------|--------|
| Kerberos attacks | 60% | 90% | +30% |
| ACL/Delegation abuse | 33% | 85% | +52% |
| Credential access | 29% | 80% | +51% |
| ADCS | 50% | 75% | +25% |
| Initial Access | 40% | 75% | +35% |
| EDR/Evasión | 0% | 70% | +70% |
| Azure AD | 0% | 65% | +65% |
| C2 Infrastructure | 67% | 85% | +18% |
| **COBERTURA GLOBAL** | **~38%** | **~80%** | **+42%** |

---

## 8. Principios de Iteración

El roadmap mejora iterativamente:

### Por lab completado
- Documentar gaps técnicos descubiertos durante la ejecución
- Proponer mejoras a labs anteriores
- Actualizar coverage matrix

### Por Phase completada
- Revisar progresión pedagógica
- Comparar contra frameworks de referencia (CRTO, PNPT, OSCP+)
- Actualizar adversary emulation fidelity

### Versiones del roadmap
- **v1.0** — Estructura inicial (12 labs, 4 phases)
- **v2.0** — Rediseño (14 labs, crown jewels, cobertura 80%)
- **v3.0** — Tras completar Phase-01/02 (refinamiento basado en ejecución real)

---

## 9. Cobertura CRTO — Coverage Matrix

El CRTO (Zero-Point Security / RastaMouse) tiene un syllabus oficial de 167 lecciones. El roadmap v2.0 cubre directamente los módulos del curso.

### Módulos CRTO vs Labs del Roadmap

| Módulo CRTO | Contenido | Lab(s) | Cobertura |
|-------------|-----------|--------|-----------|
| **Getting Started** | OPSEC, Attack Lifecycle, Engagement Planning | Transversal | ✅ |
| **Command & Control** | Cobalt Strike / Sliver, Listeners, Payloads, Pivot Listeners | Lab-01/02/10/11 | ✅ |
| **External Reconnaissance** | DNS, Google Dorks, OSINT | Lab-08 | ⏳ |
| **Initial Compromise** | Password Spraying, Phishing, VBA, HTML Smuggling | Lab-08 | ⏳ |
| **Host Reconnaissance** | Seatbelt, Processes, Keylogger | Lab-01/04 | 🔄 Parcial |
| **Host Persistence** | Task Scheduler, Registry, COM Hijacking | Lab-01/02 | ✅ |
| **Privilege Escalation** | Weak Services, UAC Bypass, WMI | Lab-01 | 🔄 Parcial |
| **Credential Access** | Mimikatz, NTLM, Kerberos tickets, SAM, DCSync | Lab-01/03 | ✅ |
| **Password Cracking** | Hashcat, wordlists, rules, masks | Lab-01/02 | ✅ |
| **Domain Recon** | PowerView, ADSearch, SharpView | Lab-01/04 | ✅ |
| **Lateral Movement** | PTH, PTT, OPtH, Token Impersonation, WMI, DCOM, PsExec | Lab-01/02 | ✅ |
| **Session Passing** | Process Injection, Jump/Remote-Exec | Lab-09 | ⏳ |
| **Pivoting** | Proxychains, Proxifier, Reverse Port Forwards | Lab-02/11 | ✅ |
| **ADCS** | ESC1, ESC4, ESC8, Forged Certificates | Lab-03 | ✅ |
| **AD Kerberos Attacks** | Kerberoasting, AS-REP, Delegation (UC/CD/RBCD) | Lab-01/05 | ✅ |
| **Shadow Credentials** | msDS-KeyCredentialLink abuse | Lab-05/07 | ⏳ |
| **MS SQL** | Impersonation, Command Execution, Lateral Movement | Lab-04 | ⏳ |
| **LAPS** | Enumeration, Reading, Backdoors | Lab-07 | ⏳ |
| **Domain Dominance** | Silver/Golden/Diamond Tickets, DCSync | Lab-01/05 | ✅ |
| **Forest Trusts** | Parent/Child, Inbound/Outbound, Cross-Forest | Lab-06/12/14 | ⏳ |
| **GPO Abuse** | Modify GPO, Create & Link GPO | Lab-01/06 | ✅ |
| **Data Hunting** | File Shares, Databases, Credential Manager | Lab-04 | ⏳ |
| **AV Evasion** | Artifact Kit, Malleable C2, Resource Kit | Lab-09/10 | ⏳ |
| **AMSI Bypasses** | Manual bypass, Post-Exploitation AMSI | Lab-09 | ⏳ |
| **AppLocker Bypasses** | Policy Enum, LOLBins, Beacon DLL | Lab-09 | ⏳ |
| **BOFs** | Beacon Object Files | Lab-10 | ⏳ |

### Resumen cobertura CRTO

| Categoría | Módulos totales CRTO | Cubiertos ahora | Con Roadmap v2.0 |
|-----------|---------------------|-----------------|-----------------|
| Fundamentos/OPSEC | 4 | 4 (100%) | 4 (100%) |
| C2 y Infraestructura | 6 | 4 (67%) | 6 (100%) |
| Reconocimiento/Enum | 5 | 3 (60%) | 5 (100%) |
| Credential Access | 8 | 7 (88%) | 8 (100%) |
| Lateral Movement | 7 | 5 (71%) | 7 (100%) |
| AD Attacks | 10 | 7 (70%) | 10 (100%) |
| AV/EDR Evasion | 6 | 0 (0%) | 5 (83%) |
| Evasión avanzada | 4 | 0 (0%) | 4 (100%) |
| **TOTAL** | **50** | **30 (60%)** | **49 (98%)** |

> **Conclusión:** El Roadmap v2.0 completo cubre el **~98% del syllabus CRTO**. Completar Phase-01 y Phase-02 te deja al **~70%** listo para el examen. Completar hasta Phase-03 te deja al **~95%** — prácticamente listo.

### Diferencias CRTO vs Roadmap

| CRTO usa | Roadmap usa | Equivalencia |
|----------|-------------|-------------|
| Cobalt Strike | Sliver + Havoc C2 | Los conceptos son idénticos — C2, listeners, beacons, BOFs |
| SnapLabs (nube) | VirtualBox local | Mayor control sobre el entorno |
| Windows-only | Windows + Linux | Mayor cobertura real |

**Nota importante:** El CRTO usa Cobalt Strike como C2. Todos los conceptos (listeners, payloads, BOFs, Malleable C2, sleep obfuscation) son directamente trasladables a Sliver/Havoc. Cuando llegues al examen, la diferencia es solo sintáctica — los conceptos ya los habrás dominado.

---

## 10. Nota — Primera Iteración

Este DESIGN.md es la **primera iteración** del diseño formal del roadmap. Está sujeto a revisión continua conforme se ejecutan los labs.

**Puntos de mejora identificados para v2.1:**
- Añadir lab de consolidación/challenge entre Phase-01 y Phase-02
- Refinar la coverage matrix con MITRE ATT&CK Groups (APT29/APT28) además del CRTO
- Evaluar si MS SQL (módulo CRTO importante) merece un lab dedicado o se integra en Lab-04
- Revisar si Azure AD requiere infraestructura separada o puede integrarse en entorno existente

---

## 11. Recursos de Referencia

### Frameworks
- [MITRE ATT&CK Enterprise](https://attack.mitre.org/matrices/enterprise/)
- [MITRE ATT&CK Groups](https://attack.mitre.org/groups/)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)

### Certificaciones objetivo
- **CRTO** (Certified Red Team Operator) — Lab-14 como preparación directa
- **CRTE** (Certified Red Team Expert) — Phase-02/03 como preparación
- **OSCP+** — Phase-01 como base sólida

### Documentación de adversarios
- APT29: [CISA Advisory AA21-116A](https://www.cisa.gov/news-events/cybersecurity-advisories/aa21-116a)
- APT41: [Mandiant APT41 Report](https://www.mandiant.com/resources/apt41-dual-espionage-and-cyber-crime-operation)
- Lazarus: [CISA Advisory AA22-108A](https://www.cisa.gov/news-events/cybersecurity-advisories/aa22-108a)

---

*Red Team Ops Roadmap v2.0 — Adrián Camacho | Mayo 2026*