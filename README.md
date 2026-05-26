<div align="center">

```
██████╗ ███████╗██████╗     ████████╗███████╗ █████╗ ███╗   ███╗
██╔══██╗██╔════╝██╔══██╗    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
██████╔╝█████╗  ██║  ██║       ██║   █████╗  ███████║██╔████╔██║
██╔══██╗██╔══╝  ██║  ██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
██║  ██║███████╗██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚══════╝╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
```

[![Estado](https://img.shields.io/badge/Estado-En%20Progreso-orange?style=for-the-badge)](.)
[![Labs](https://img.shields.io/badge/Labs%20completados-3%20%2F%2015-blue?style=for-the-badge)](.)
[![Horas](https://img.shields.io/badge/Horas%20invertidas-%7E75h-purple?style=for-the-badge)](.)
[![MITRE](https://img.shields.io/badge/Framework-MITRE%20ATT%26CK%20v14-black?style=for-the-badge)](https://attack.mitre.org)
[![C2](https://img.shields.io/badge/C2-Sliver%20%7C%20Havoc-blueviolet?style=for-the-badge)](.)
[![Licencia](https://img.shields.io/badge/Uso-Educativo-green?style=for-the-badge)](.)

**Documentación operacional de Red Team en Active Directory.**  
Adversary emulation real — APT29, APT41, APT28, Lazarus, APT10 — con C2 Open Source.

[📋 Estado de labs](#-estado-de-labs) · [🗺️ Roadmap completo](#️-roadmap-completo) · [🧠 Metodología](#-metodología) · [⚙️ Setup](#️-setup-del-entorno) · [📊 MITRE Coverage](#-mitre-attck-coverage)

</div>

---

## 📌 ¿Qué es este repositorio?

Este repositorio documenta mi preparación para la certificación **CRTO (Certified Red Team Operator)**. No es una colección de writeups — es **documentación operacional** estructurada como lo haría un equipo Red Team profesional.

**Lo que lo diferencia:**

- Cada lab tiene una **operación nombrada** con adversario APT real, objetivos concretos y Crown Jewels definidos
- Todo está mapeado contra **MITRE ATT&CK v14 Enterprise** con ID de técnica y subtécnica
- Los fallos se documentan con la misma profundidad que los éxitos — una técnica bloqueada por PAC Validation o KB5005413 es una lección más valiosa que una que funciona sin fricción
- El C2 principal es **Sliver** (BishopFox) replicando capacidades de Cobalt Strike en Open Source
- Cada técnica ofensiva viene acompañada de su detección: Event IDs, reglas SIGMA, hardening

> ⚠️ **Entorno 100% controlado.** Todo se ejecuta en laboratorio local con VMs. Uso exclusivamente educativo y de preparación para certificación.

---

## 🏗️ Arquitectura del Entorno

```
┌─────────────────────────────────────────────────────────────────┐
│                     RED TEAM LAB — ghost.local                  │
│                                                                 │
│  ┌─────────────────┐        ┌─────────────────┐               │
│  │     DC-01        │        │    WKSTN-01      │               │
│  │  10.0.2.10       │◄──────►│   10.0.2.8       │               │
│  │  Win Srv 2022    │        │   Windows 11     │               │
│  │  ghost.local     │        │   PC-01          │               │
│  │  ADCS: AtackCorp │        │                  │               │
│  └────────┬─────────┘        └────────┬─────────┘               │
│           │                           │                         │
│           └──────────────┬────────────┘                         │
│                          │  10.0.2.0/24  (LabRedTeam NAT)       │
│                          │                                       │
│                 ┌────────┴────────┐                             │
│                 │   Kali Linux     │                             │
│                 │   10.0.2.9       │ ← Atacante principal        │
│                 │   Sliver C2      │                             │
│                 │   Ligolo-ng      │                             │
│                 │   Arsenal completo│                            │
│                 └─────────────────┘                             │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Lab-02 — Red interna adicional              │   │
│  │  PROD (10.0.3.10) · GIT (10.0.3.11) · PC-01 (10.0.3.20)│   │
│  │              Ligolo-ng tunnel ←── Kali                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

| Host | IP | OS | Rol |
|---|---|---|---|
| DC-01 | 10.0.2.10 | Windows Server 2022 | Domain Controller — ghost.local + ADCS (AtackCorp-CA) |
| WKSTN-01 | 10.0.2.8 | Windows 11 | Workstation objetivo |
| Kali | 10.0.2.9 | Kali Linux 2024 | Atacante / C2 Server |
| PROD | 10.0.3.10 | Ubuntu 22.04 | Servidor web Lab-02 (Webmin 1.890) |
| GIT | 10.0.3.11 | Ubuntu 22.04 | Servidor Git Lab-02 |
| PC-01 | 10.0.3.20 | Windows 11 | Workstation red interna Lab-02 |

---

## 🗺️ Roadmap Completo

El roadmap emula **5 grupos APT reales** a través de **4 Fases** y **15 Labs**.

```
PHASE-01 ── APT29 + APT41 ──► Fundamentos AD, Kerberos, ADCS, Pivotaje
PHASE-02 ── APT28          ──► AD Avanzado, Delegaciones, ACL, GPO
PHASE-03 ── Lazarus Group  ──► EDR Evasion, C2 avanzado, Initial Access real
PHASE-04 ── APT10          ──► Enterprise Simulation, Forest Trusts, Azure AD
```

---

### 🟢 Phase-01 — Fundamentos y Pivotaje

| # | Operación | Adversario | Estado | Técnicas principales |
|---|---|---|---|---|
| Lab-01 | 🌲 **GHOST FOREST** | APT29 (Cozy Bear) | ✅ Completado ~40h | AS-REP Roasting, Kerberoasting, DCSync, Delegation, GPO Abuse, ACL Abuse |
| Lab-02 | 🌉 **SILENT BRIDGE** | APT41 (Double Dragon) | ✅ Completado ~18h | CVE-2019-12840, Ligolo-ng Pivot, Sliver relay C2, SAM dump, Git cred disclosure |
| Lab-03 | 🌑 **DARK GATE** | APT29 (Cozy Bear) | ✅ Completado ~16h | ADCS ESC1/ESC4/ESC8, Certipy, NTLM Relay, Certificate persistence |

### 🟡 Phase-02 — AD Avanzado

| # | Operación | Adversario | Estado | Técnicas planificadas |
|---|---|---|---|---|
| Lab-04 | 🔴 **IRON FOREST** | APT28 (Fancy Bear) | ⏳ Próximo | WriteDACL, ForceChangePassword, Credential Hunting, ACL chains |
| Lab-05 | ⛓️ **SILVER CHAIN** | APT28 (Fancy Bear) | ⏳ Pendiente | RBCD, Silver Ticket, Diamond Ticket, S4U2Proxy avanzado |
| Lab-06 | 📋 **BLACK POLICY** | APT28 (Fancy Bear) | ⏳ Pendiente | SID History, Cross-Forest Trust, GPO abuse avanzado |
| Lab-07 | 🔒 **SHADOW VAULT** | APT28 (Fancy Bear) | ⏳ Pendiente | LAPS, DPAPI, Shadow Credentials, LSASS dump sin Mimikatz |

### 🔴 Phase-03 — Red Team & Evasión de Defensas

| # | Operación | Adversario | Estado | Técnicas planificadas |
|---|---|---|---|---|
| Lab-08 | 👁️ **GHOST SIGNAL** | Lazarus Group | ⏳ Pendiente | AMSI bypass in-memory, Process injection, Direct syscalls, Beacon PE evasion |
| Lab-09 | 📡 **FIRST CONTACT** | Lazarus Group | ⏳ Pendiente | Password spraying, HTML Smuggling, VBA macros, Initial Access sin credenciales |
| Lab-10 | ⚡ **DARK CURRENT** | Lazarus Group | ⏳ Pendiente | Havoc C2, Sleep obfuscation, BOFs, OPSEC avanzado |
| Lab-11 | 🕳️ **DEEP HOLO** | Lazarus Group | ⏳ Pendiente | Simulación multicapa, pivoting avanzado, EDR evasion real |

### 🏴 Phase-04 — Enterprise Simulation

| # | Operación | Adversario | Estado | Técnicas planificadas |
|---|---|---|---|---|
| Lab-12 | 🔥 **RED DANTE** | APT10 (Stone Panda) | ⏳ Pendiente | Red masiva mixta, persistencia multicapa, exfiltración |
| Lab-13 | 🌊 **DEEP WATER** | APT10 (Stone Panda) | ⏳ Pendiente | Forest Trusts avanzados, preparación CRTO, AD completo |
| Lab-14 | ☁️ **AZURE BREACH** | APT10 (Stone Panda) | ⏳ Pendiente | Azure AD / Entra ID, Cloud-to-OnPremise, hybrid attacks |
| Lab-15 | 🌪️ **OPERATION ZEPHYR** | APT10 (Stone Panda) | ⏳ Pendiente | Supply chain, infraestructura compleja, simulación final CRTO |

---

## 📋 Estado de Labs

### ✅ Lab-01 — GHOST FOREST | APT29 (Cozy Bear)

**13 fases completadas · ~40 horas · Documentación completa**

<details>
<summary>Ver todas las fases y TTPs</summary>

| Fase | Nombre | Técnica | MITRE ID | Herramienta |
|---|---|---|---|---|
| 01 | Reconnaissance | Network scanning + LDAP/SMB enum | T1046, T1135 | Nmap, enum4linux-ng |
| 02 | Initial Access | AS-REP Roasting → crack | T1558.004, T1110.002 | GetNPUsers, Hashcat |
| 03 | Execution / Foothold | Evil-WinRM shell como ceo.martinez | T1021.006, T1078.002 | Evil-WinRM, CrackMapExec |
| 04 | Discovery | BloodHound CE + PowerView + SPN enum | T1087.002, T1069.002, T1482 | BloodHound, ldapsearch |
| 05 | Credential Access | Kerberoasting → backup_svc → DA | T1558.003, T1110.002 | GetUserSPNs, John |
| 06 | Lateral Movement | WinRM a WKSTN-01 como backup_svc | T1021.006, T1550.002 | Evil-WinRM, Impacket |
| 07 | C2 Establishment | Sliver HTTPS beacon `EASY_PROFIT` | T1071.001, T1573.002 | Sliver v1.7.3 |
| 08 | Privilege Escalation | SeImpersonatePrivilege + Defender bypass | T1134.001, T1562.001 | PrintSpoofer (parcial) |
| 09 | Persistence | Golden Ticket (bloqueado PAC Validation) + beacon | T1558.001 | Impacket ticketer |
| 10 | Objective Completion | DCSync → Pass-the-Hash → Domain Admin | T1003.006, T1550.002 | secretsdump, Evil-WinRM |
| 11 | Delegation Abuse | Unconstrained (PetitPotam) + Constrained S4U2Proxy | T1558.001, T1187 | Rubeus, PetitPotam |
| 12 | GPO Abuse | helpdesk.ruiz → ScheduledTasks.xml SYSVOL → admin local | T1484.001, T1053.005 | PowerShell + SYSVOL |
| 13 | ACL Abuse | fin.garcia GenericWrite → Targeted Kerberoast → SQLService2024! | T1222, T1558.003 | bloodyAD, GetUserSPNs |

**Crown Jewels capturados:** Hash NTLM del Administrador del dominio · Dominio ghost.local comprometido al 100%  
**Lecciones clave:** PAC Validation en WS2022 bloquea Golden Ticket estándar · Potato attacks fallan sobre tokens de red WinRM · SharpHound cubre ACLs/GPOs que bloodhound-python no recoge

</details>

---

### ✅ Lab-02 — SILENT BRIDGE | APT41 (Double Dragon)

**7 fases completadas · ~18 horas · Documentación completa**

<details>
<summary>Ver todas las fases y TTPs</summary>

| Fase | Nombre | Técnica | MITRE ID | Herramienta |
|---|---|---|---|---|
| 01 | Reconnaissance | Fingerprint Webmin 1.890 + CVE research | T1046, T1592 | Nmap, WhatWeb |
| 02 | Initial Access | CVE-2019-12840 RCE → root@prod | T1190, T1587.001 | Exploit Python desde 46984.rb |
| 03 | Pivoting | Ligolo-ng v0.7.5 → red interna enrutada | T1572, T1090.001 | Ligolo-ng |
| 04 | Internal Enum | Git history → thomas:iamthegreatest | T1552.001, T1213 | git log, curl |
| 05 | Lateral Movement | Evil-WinRM PC-01 como thomas | T1021.006 | Evil-WinRM |
| 06 | C2 Establishment | Beacon `SUDDEN_COMMUNICATION` vía relay PROD | T1071.001, T1090 | Sliver + Ligolo listener |
| 07 | Persistence + Loot | schtasks + SAM dump + objetivo completado | T1053.005, T1003.002 | Impacket secretsdump |

**Crown Jewels capturados:** Hash NTLM thomas + SAM de PC-01 · Red interna 10.0.3.0/24 comprometida  
**Lecciones clave:** CVE-2019-15107 bloqueado por MINISERV_INTERNAL → CVE-2019-12840 como alternativa · Ubuntu 26.04 incompatible con Webmin 1.890 → Ubuntu 22.04 · Relay C2 via Ligolo listener elimina visibilidad directa Kali↔objetivo

</details>

---

### ✅ Lab-03 — DARK GATE | APT29 (Cozy Bear)

**6 fases completadas · ~16 horas · Documentación completa**

<details>
<summary>Ver todas las fases y TTPs</summary>

| Fase | Nombre | Técnica | MITRE ID | Herramienta |
|---|---|---|---|---|
| 01 | ADCS Enumeration | certipy-ad find → ESC1 + ESC4 + ESC8 | T1046 | Certipy v5.0.4 |
| 02 | ESC1 — SAN Abuse | ceo.martinez → cert como Administrador → DA | T1649 | Certipy |
| 03 | ESC4 — Template Modification | fin.garcia GenericWrite → plantilla modificada → cert DA → restaurada | T1222, T1649 | Certipy |
| 04 | ESC8 — NTLM Relay | PetitPotam exitoso, relay bloqueado KB5005413 (documentado) | T1557.001, T1187 | PetitPotam, ntlmrelayx |
| 05 | C2 Establishment | `CLINICAL_CHAIRMAN` en DC-01 — 3 beacons simultáneos | T1071.001 | Sliver v1.7.3 |
| 06 | Certificate Persistence | Cert válido post-rotación de contraseña → DA confirmado | T1649 | Certipy |

**Crown Jewels capturados:** Certificado de Administrador válido · Persistencia post-rotación de contraseña  
**Lecciones clave:** ESC8 bloqueado en WS2022 por KB5005413 (Extended Protection for Authentication) · Certificate persistence sobrevive a cambio de contraseña del DA · ESC4 requiere restaurar la plantilla por OPSEC

</details>

---

## 📂 Estructura del Repositorio

```
Red-Team_Labs/
│
├── README.md
│
├── docs/                                    ← Documentación global
│   ├── design/
│   │   └── DESIGN.md                        # Filosofía, adversary emulation, roadmap v2.0
│   ├── detection/
│   │   └── DETECTION_RULES.md               # Reglas SIGMA y Event IDs por técnica
│   ├── operations/
│   │   ├── ENGAGEMENT_CHECKLIST.md          # Pre/durante/post operación
│   │   ├── METHODOLOGY.md                   # Proceso operacional estándar
│   │   ├── OPSEC_NOTES.md                   # OPSEC para entornos reales
│   │   └── THREAT_MODEL.md                  # Modelo de amenaza del entorno
│   ├── progress/
│   │   ├── PROGRESS.md                      # Diario de sesiones + técnicas dominadas
│   │   └── CHANGELOG.md                     # Historial de cambios del repo
│   └── reference/
│       ├── ARSENAL.md                        # Arsenal completo por categoría
│       ├── LAB_INFRASTRUCTURE.md            # Infraestructura detallada de cada lab
│       ├── MITRE_MAPPING.md                 # Mapping completo MITRE ATT&CK v14
│       └── TOOL_INDEX.md                    # Índice de herramientas con versiones
│
├── setup/                                   ← Setup global del entorno
│   ├── provisioning/
│   │   ├── 01_ad_promotion.ps1              # Promoción DC
│   │   ├── 02_users_ous.ps1                 # Usuarios y OUs
│   │   ├── 03_acls_delegations.ps1          # ACLs y delegaciones
│   │   ├── 04_iis_smb_gpo.ps1              # IIS, SMB, GPO
│   │   ├── 05_mssql.ps1                     # MSSQL
│   │   └── 06_wkstn01.ps1                  # Workstation
│   └── README.md
│
├── Phase-01-Fundamentals/
│   ├── Lab-01-Ghost-Forest/
│   │   ├── OPERATION_GHOST_FOREST.md        # Operación completa (resumen ejecutivo)
│   │   ├── README.md
│   │   ├── docs/
│   │   │   ├── theory/tradecraft.md         # Fundamentos teóricos (24KB)
│   │   │   ├── execution/                   # 10 docs de ejecución paso a paso
│   │   │   │   ├── enumeration_log.md
│   │   │   │   ├── exploitation.md
│   │   │   │   ├── lateral_movement.md
│   │   │   │   ├── persistence.md
│   │   │   │   ├── post_exploitation.md
│   │   │   │   ├── privilege_escalation.md
│   │   │   │   ├── delegation.md
│   │   │   │   ├── gpo_abuse.md
│   │   │   │   ├── acl_abuse.md
│   │   │   │   ├── bloodhound.md
│   │   │   │   └── infrastructure_setup.md
│   │   │   ├── analysis/
│   │   │   │   ├── lessons_learned.md       # 19 lecciones documentadas
│   │   │   │   └── mitigations.md
│   │   │   └── report/
│   │   │       └── Reporte_GHOST_FOREST.pdf # Reporte ejecutivo PDF
│   │   ├── setup/
│   │   │   ├── Setup-Lab01-GhostForest-v2.ps1    # Setup completo del lab
│   │   │   └── CrownJewels-Lab01-GhostForest.ps1 # Verificación de objetivos
│   │   ├── screenshots/
│   │   │   ├── FASE-01-Reconnaissance/      # 5 capturas
│   │   │   ├── FASE-02-Initial-Access-.../  # 4 capturas
│   │   │   ├── FASE-03-Execution-Initial-Foothold/
│   │   │   ├── FASE-04-Discovery/
│   │   │   ├── FASE-05-Credential-Access-.../
│   │   │   ├── FASE-06-Lateral-Movement/
│   │   │   ├── FASE-07-C2-Establishment/
│   │   │   ├── FASE-08-Privilege-Escalation/
│   │   │   ├── FASE-09-Persistence/
│   │   │   ├── FASE-10-Objective-Completion/
│   │   │   ├── FASE-11-Unconstrained-Constrained-Delegation/ # 15 capturas
│   │   │   ├── FASE-12-GPO-Abuse/
│   │   │   └── FASE-13-ACL-Abuse/
│   │   ├── loot/                            # Hashes, tickets capturados
│   │   └── nmap/                            # Escaneos de reconocimiento
│   │
│   ├── Lab-02-Silent-Bridge/                # Misma estructura + capturas FASE-01 a FASE-07
│   └── Lab-03-Dark-Gate/                    # Misma estructura + capturas FASE-01 a FASE-06
│
├── Phase-02-Post-Exploitation/
│   ├── Lab-04-Iron-Forest/                  # tradecraft.md completo + CrownJewels script
│   ├── Lab-05-Silver-Chain/
│   ├── Lab-06-Black-Policy/
│   └── Lab-07-Shadow-Vault/
│
├── Phase-03-Red-Team-Operations/
│   ├── Lab-08-Ghost-Signals/
│   ├── Lab-09-First-Contact/
│   ├── Lab-10-Dark-Current/
│   └── Lab-11-Deep-Holo/
│
└── Phase-04-Enterprise-Simulation/
    ├── Lab-12-Red-Dante/
    ├── Lab-13-Deep-Water/
    ├── Lab-14-Azure-Breach/
    └── Lab-15-Operation-Zephyr/
```

**Cada lab completado contiene:**
- `OPERATION_*.md` — Resumen ejecutivo de la operación
- `docs/theory/tradecraft.md` — Fundamentos teóricos de todas las técnicas del lab
- `docs/execution/*.md` — Comandos reales con output, razonamiento y notas OPSEC
- `docs/analysis/lessons_learned.md` — Qué funcionó, qué falló y por qué
- `docs/analysis/mitigations.md` — Detección y hardening desde perspectiva Blue Team
- `docs/report/*.pdf` — Reporte ejecutivo en PDF
- `setup/Setup-Lab*.ps1` — Script PowerShell de setup reproducible
- `setup/CrownJewels-Lab*.ps1` — Script de verificación de objetivos
- `screenshots/FASE-XX-Nombre/` — Evidencia visual organizada por fase

---

## 🧠 Metodología

### Proceso operacional por lab

```
1. ADVERSARY SELECTION  → Seleccionar grupo APT real (MITRE Groups)
                          Estudiar sus TTPs documentadas
                          
2. THEORY               → Fundamentos del protocolo antes de ejecutar
                          Si la herramienta falla, construir el exploit desde cero
                          
3. INFRASTRUCTURE       → Setup reproducible con scripts PowerShell
                          Crown Jewels definidos antes de empezar
                          
4. EXECUTION            → Comandos documentados con output real
                          Notas OPSEC en cada paso: ¿qué logs genera?
                          
5. ANALYSIS             → Post-mortem: ¿qué funcionó? ¿qué falló? ¿por qué?
                          Diferencias entre comportamiento ideal y real
                          
6. BLUE TEAM            → Event IDs generados por cada técnica
                          Reglas SIGMA de detección
                          Hardening y mitigaciones
                          
7. REPORT               → Reporte ejecutivo en PDF
                          Lessons learned actualizadas
```

### Nomenclatura de screenshots

```
screenshots/
└── FASE-XX-Nombre-Tecnica/
    └── faseXX-YY-descripcion-accion.png

Ejemplo:
FASE-11-Unconstrained-Constrained-Delegation/
└── fase11-04-petitpotam-coercion.png
```

### Bloques de captura en docs de ejecución

```markdown
> 📸 Captura:
> ![fase11-04](../../screenshots/FASE-11-Unconstrained-Constrained-Delegation/fase11-04-petitpotam-coercion.png)
```

---

## 🛠️ Arsenal

### C2 Frameworks

| Herramienta | Versión | Labs | Uso |
|---|---|---|---|
| **Sliver** (BishopFox) | v1.7.3 | Lab-01/02/03 | C2 principal — HTTPS/mTLS beacons, pivots, post-explotación |
| **Havoc C2** | Latest | Lab-10 | C2 alternativo — BOFs, sleep obfuscation, Demon implant |

### Active Directory & Kerberos

| Herramienta | Uso |
|---|---|
| **Impacket** | GetNPUsers, GetUserSPNs, secretsdump, psexec, getST |
| **Rubeus** | Ticket manipulation, monitor, S4U2Self/S4U2Proxy |
| **BloodHound CE** v9.1.0 | Attack paths, ACL analysis, domain mapping |
| **SharpHound** v2.5.9 | Recolección BloodHound (cubre ACLs/GPOs que bloodhound-python no) |
| **bloodhound-python** | Recolección remota OPSEC-friendly (sin ejecutar binarios) |
| **PowerView** | Enumeración AD desde PowerShell — LOLBins |
| **bloodyAD** | ACL abuse — GenericWrite, WriteDACL, DACL edit |
| **CrackMapExec / NetExec** | Validación de credenciales, SMB, WinRM |
| **Evil-WinRM** | Shell remota WinRM con upload/download integrado |
| **Kerbrute** | Enumeración de usuarios sin bloqueo de cuentas |

### ADCS

| Herramienta | Versión | Uso |
|---|---|---|
| **Certipy** | v5.0.4 | Enumerar y explotar ESC1/ESC4/ESC8 — find, req, auth |
| **PetitPotam** | Latest | NTLM coercion para relay y unconstrained delegation |
| **ntlmrelayx** | Impacket | Relay NTLM a ADCS Web Enrollment |

### Pivotaje & Red

| Herramienta | Uso |
|---|---|
| **Ligolo-ng** v0.7.5 | Tunneling full-duplex — proxy Kali + agent objetivo |
| **Chisel** | Tunneling HTTP/HTTPS reversible |
| **Nmap** | Reconocimiento a través de túneles Ligolo |

### Evasión & Post-Explotación (Phase-03)

| Herramienta | Uso |
|---|---|
| AMSI bypass (in-memory) | Sin escribir a disco — patch directo en memoria |
| Process Injection | Inyección de beacon en proceso legítimo (explorer, svchost) |
| Direct Syscalls (SysWhispers) | Evasión de hooks EDR a nivel de kernel |
| nanodump / PPLdump | LSASS dump sin Mimikatz para evadir AV |
| BOFs (Beacon Object Files) | Extensiones de Havoc sin fork de proceso |

---

## ⚙️ Setup del Entorno

### Requisitos de hardware

```
RAM mínima:    16 GB  (recomendado 32 GB para correr 3 VMs simultáneas)
CPU:           4 cores (recomendado 8 — VT-x/AMD-V activo en BIOS)
Disco:         150 GB libres
Hypervisor:    VirtualBox 7.x
```

### Setup automatizado — Lab-01

```powershell
# En DC-01 como Administrador (PowerShell)

# 1. Provisioning del dominio ghost.local
.\setup\provisioning\01_ad_promotion.ps1
.\setup\provisioning\02_users_ous.ps1
.\setup\provisioning\03_acls_delegations.ps1
.\setup\provisioning\04_iis_smb_gpo.ps1
.\setup\provisioning\05_mssql.ps1

# 2. Setup completo Lab-01 (usuarios vulnerables, OUs, ACLs, ADCS)
.\Phase-01-Fundamentals\Lab-01-Ghost-Forest\setup\Setup-Lab01-GhostForest-v2.ps1

# 3. Verificar Crown Jewels (confirma que el lab es explotable)
.\Phase-01-Fundamentals\Lab-01-Ghost-Forest\setup\CrownJewels-Lab01-GhostForest.ps1
```

```bash
# En Kali Linux
git clone https://github.com/adr-camacho/RedTeam-Ops-Roadmap.git
cd RedTeam-Ops-Roadmap

# Setup arsenal (Certipy, NetExec, BloodHound CE, SharpHound, Ligolo-ng...)
bash Phase-01-Fundamentals/Lab-01-Ghost-Forest/setup/arsenal_setup.sh
```

### Usuarios del lab (Lab-01)

| Usuario | Grupo | Vulnerabilidad |
|---|---|---|
| ceo.martinez | Domain Users | No requiere preauth (AS-REP Roasteable) |
| backup_svc | **Domain Admins** | Tiene SPN → Kerberoasteable |
| sql_svc | Domain Users | Unconstrained Delegation |
| iis_svc | Domain Users | Constrained Delegation |
| fin.garcia | Domain Users | GenericWrite sobre VulnerableUser (ADCS) |
| helpdesk.ruiz | IT (OU) | GpoEditDeleteModifySecurity sobre GPO |

---

## 📊 MITRE ATT&CK Coverage

**Técnicas dominadas: 25 · Parciales: 3 · En roadmap: 30+**

| Táctica | Técnica | ID | Lab | Estado |
|---|---|---|---|---|
| Reconnaissance | Network Service Discovery | T1046 | Lab-01/02/03 | ✅ |
| Reconnaissance | Account Discovery — Domain | T1087.002 | Lab-01 | ✅ |
| Initial Access | Exploit Public Application | T1190 | Lab-02 | ✅ |
| Initial Access | Password Spraying | T1110.003 | Lab-09 | ⏳ |
| Execution | Windows Remote Management | T1021.006 | Lab-01/02/03 | ✅ |
| Execution | Scheduled Task | T1053.005 | Lab-01/02 | ✅ |
| Persistence | Golden Ticket | T1558.001 | Lab-01 | 🔄 PAC Validation |
| Persistence | Certificate Persistence | T1649 | Lab-03 | ✅ |
| Privilege Escalation | GPO Modification | T1484.001 | Lab-01 | ✅ |
| Privilege Escalation | Token Impersonation | T1134.001 | Lab-01 | 🔄 WinRM |
| Defense Evasion | Impair Defenses | T1562.001 | Lab-01 | ✅ |
| Defense Evasion | AMSI Bypass | T1562 | Lab-08 | ⏳ |
| Defense Evasion | Process Injection | T1055 | Lab-08 | ⏳ |
| Credential Access | AS-REP Roasting | T1558.004 | Lab-01 | ✅ |
| Credential Access | Kerberoasting | T1558.003 | Lab-01 | ✅ |
| Credential Access | Targeted Kerberoasting | T1558.003 | Lab-01 | ✅ |
| Credential Access | DCSync | T1003.006 | Lab-01/03 | ✅ |
| Credential Access | SAM Credential Dump | T1003.002 | Lab-02 | ✅ |
| Credential Access | Unconstrained Delegation | T1558.001 | Lab-01 | ✅ |
| Credential Access | Constrained Delegation S4U2Proxy | T1558.001 | Lab-01 | ✅ |
| Credential Access | ESC1 — SAN Abuse | T1649 | Lab-03 | ✅ |
| Credential Access | ESC4 — Template Modification | T1649 | Lab-03 | ✅ |
| Credential Access | ESC8 — NTLM Relay ADCS | T1557.001 | Lab-03 | 🔄 KB5005413 |
| Credential Access | Git History Disclosure | T1552.001 | Lab-02 | ✅ |
| Credential Access | LAPS Abuse | — | Lab-07 | ⏳ |
| Credential Access | DPAPI | — | Lab-07 | ⏳ |
| Credential Access | Shadow Credentials | T1556 | Lab-07 | ⏳ |
| Discovery | BloodHound / Domain Trust | T1482, T1069.002 | Lab-01 | ✅ |
| Lateral Movement | Pass-the-Hash | T1550.002 | Lab-01/03 | ✅ |
| Lateral Movement | WinRM | T1021.006 | Lab-01/02/03 | ✅ |
| Collection | Credential Hunting Git | T1213 | Lab-02 | ✅ |
| C&C | Sliver HTTPS/mTLS | T1071.001, T1573.002 | Lab-01/02/03 | ✅ |
| C&C | Protocol Tunneling Ligolo-ng | T1572 | Lab-02 | ✅ |
| C&C | Relay C2 | T1090 | Lab-02 | ✅ |
| Privilege Escalation | ACL Abuse — GenericWrite | T1222 | Lab-01 | ✅ |
| Privilege Escalation | Forced Authentication — PetitPotam | T1187 | Lab-01/03 | ✅ |

---

## 📁 Documentación Global

| Documento | Tamaño | Descripción |
|---|---|---|
| `docs/design/DESIGN.md` | 22KB | Filosofía de diseño, adversary emulation, roadmap v2.0, coverage matrix |
| `docs/detection/DETECTION_RULES.md` | 24KB | Reglas SIGMA, Event IDs y artefactos forenses por técnica |
| `docs/operations/ENGAGEMENT_CHECKLIST.md` | 7.6KB | Checklist pre/durante/post operación |
| `docs/operations/METHODOLOGY.md` | 9.3KB | Proceso operacional estándar del roadmap |
| `docs/operations/OPSEC_NOTES.md` | 18KB | OPSEC aplicado — qué logs genera cada acción |
| `docs/operations/THREAT_MODEL.md` | 10.6KB | Modelo de amenaza del entorno lab |
| `docs/reference/ARSENAL.md` | 13.5KB | Arsenal completo con flags, versiones y ejemplos |
| `docs/reference/LAB_INFRASTRUCTURE.md` | 29KB | Infraestructura detallada de cada lab |
| `docs/reference/MITRE_MAPPING.md` | 14.6KB | Mapping MITRE ATT&CK v14 completo por lab |
| `docs/reference/TOOL_INDEX.md` | 6.3KB | Índice de herramientas con rutas y versiones |
| `docs/progress/PROGRESS.md` | 9.7KB | Diario de sesiones + 26 técnicas dominadas |
| `docs/progress/CHANGELOG.md` | 7.4KB | Historial completo de cambios |

---

## 🔜 Próximo objetivo

**Lab-04 — IRON FOREST · APT28 (Fancy Bear)**

| Campo | Detalle |
|---|---|
| Técnicas | WriteDACL, ForceChangePassword, Credential Hunting, ACL chains a DA |
| Crown Jewels | Hash DA vía cadena ACL — sin Kerberoasting |
| Fundamento | tradecraft.md ya generado (17.9KB) |

---

<div align="center">

---

**Adrián Camacho** · Red Team Ops

[![LinkedIn](https://img.shields.io/badge/LinkedIn-adrian--camacho--mora-0077B5?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/adrian-camacho-mora/)
[![TryHackMe](https://img.shields.io/badge/TryHackMe-sapodos-red?style=flat-square&logo=tryhackme)](https://tryhackme.com/p/sapodos)
[![GitHub](https://img.shields.io/badge/GitHub-adr--camacho-181717?style=flat-square&logo=github)](https://github.com/adr-camacho)

> *"Documenta como si alguien más tuviera que ejecutar la operación."*

⚠️ **Disclaimer:** Todo el contenido de este repositorio es de uso exclusivamente educativo y se ejecuta en entornos de laboratorio controlados bajo consentimiento explícito. El uso de estas técnicas contra sistemas sin autorización explícita es ilegal y está penado por la ley. El autor no se hace responsable del uso indebido de este material.

</div>