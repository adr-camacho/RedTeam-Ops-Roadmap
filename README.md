<div align="center">

```
 ██████╗ ███████╗██████╗     ████████╗███████╗ █████╗ ███╗   ███╗
 ██╔══██╗██╔════╝██╔══██╗    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
 ██████╔╝█████╗  ██║  ██║       ██║   █████╗  ███████║██╔████╔██║
 ██╔══██╗██╔══╝  ██║  ██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
```

```
  [ Active Directory Adversary Emulation — APT29 · APT41 · APT28 · Lazarus · APT10 ]
  [ CRTO Preparation · Sliver C2 · MITRE ATT&CK v14 · 5/15 Labs · 45 TTPs ]
```

[![Estado](https://img.shields.io/badge/Estado-En%20Progreso-orange?style=for-the-badge)](.)
[![TTPs](https://img.shields.io/badge/TTPs%20Dominadas-45-brightgreen?style=for-the-badge)](.)
[![Horas](https://img.shields.io/badge/Horas%20invertidas-%7E115h-purple?style=for-the-badge)](.)
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
┌─────────────────────────────────────────────────────────────────────┐
│                    RED TEAM LAB — 10.0.2.0/24 (LabRedTeam NAT)     │
│                                                                     │
│  FOREST 1: atackcorp.local                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │    DC-01      │  │    DC-03      │  │   WKSTN-01   │             │
│  │  10.0.2.10    │  │  10.0.2.13    │  │  10.0.2.8    │             │
│  │  Root DC      │  │  child.atack  │  │  Windows 11  │             │
│  │  ADCS         │  │  corp.local   │  │              │             │
│  └──────┬────────┘  └──────────────┘  └──────────────┘             │
│         │ BiDir Trust          BiDir Trust                          │
│  FOREST 2: corp.local ◄────────────────────────────────            │
│  ┌──────────────┐  ┌──────────────┐                                │
│  │    DC-02      │  │   WKSTN-02   │                                │
│  │  10.0.2.11    │  │  10.0.2.12   │                                │
│  │  Root DC      │  │  Windows 11  │                                │
│  └──────────────┘  └──────────────┘                                │
│         │ BiDir Trust                                               │
│  FOREST 3: ext.local ◄─────────────────────────────────            │
│  ┌──────────────┐                                                   │
│  │    DC-04      │                                                  │
│  │  10.0.2.14    │                                                  │
│  │  Root DC      │                                                  │
│  └──────────────┘                                                   │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Kali Linux 10.0.2.9 — Atacante / C2 / Arsenal               │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Lab-02 — Red interna 10.0.3.0/24                            │  │
│  │  PROD (10.0.3.10) · GIT (10.0.3.11) · PC-01 (10.0.3.20)     │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

> 🖥️ **Entorno real en VirtualBox** — todos los labs se ejecutan en máquinas virtuales locales

![Lab Environment](docs/assets/virtualbox_lab_environment.png)

| Host | IP | OS | RAM | Rol |
|---|---|---|---|---|
| DC-01 | 10.0.2.10 | Windows Server 2022 | 4GB | Domain Controller — atackcorp.local + ADCS |
| DC-02 | 10.0.2.11 | Windows Server 2022 | 3GB | Domain Controller — corp.local (Forest 2) |
| DC-03 | 10.0.2.13 | Windows Server 2022 | 3GB | Domain Controller — child.atackcorp.local |
| DC-04 | 10.0.2.14 | Windows Server 2022 | 2GB | Domain Controller — ext.local (Forest 3) |
| WKSTN-01 | 10.0.2.8 | Windows 11 | 3GB | Workstation — atackcorp.local |
| WKSTN-02 | 10.0.2.12 | Windows 11 | 3GB | Workstation — corp.local |
| Kali | 10.0.2.9 | Kali Linux 2026.1 | 8GB | Atacante / C2 Server |
| PROD | 10.0.3.10 | Ubuntu 22.04 | — | Servidor web Lab-02 (Webmin 1.890) |
| GIT | 10.0.3.11 | Ubuntu 22.04 | — | Servidor Git Lab-02 |
| PC-01 | 10.0.3.20 | Windows 11 | — | Workstation red interna Lab-02 |

---

## 🗺️ Roadmap Completo

El roadmap emula **5 grupos APT reales** a través de **4 Fases** y **15 Labs**.

```
PHASE-01 ── APT29 + APT41 ──► Fundamentos AD, Kerberos, ADCS, Pivotaje
PHASE-02 ── APT28          ──► AD Avanzado, WriteDACL, DCSync, Credential Hunting
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

| # | Operación | Adversario | Estado | Técnicas principales |
|---|---|---|---|---|
| Lab-04 | 🔴 **IRON FOREST** | APT28 (Fancy Bear) | ✅ Completado ~20h | WriteDACL→DCSync, Credential Hunting, ADIDNS Poisoning, Overpass-the-Hash |
| Lab-05 | ⛓️ **SILVER CHAIN** | APT28 (Fancy Bear) | ✅ Completado ~20h | RBCD, Shadow Credentials, Silver Ticket, Diamond Ticket |
| Lab-06 | 📋 **BLACK POLICY** | APT28 (Fancy Bear) | ⏳ Pendiente | SID History, Cross-Forest Trust, GPO abuse avanzado |
| Lab-07 | 🔒 **SHADOW VAULT** | APT28 (Fancy Bear) | ⏳ Pendiente | LAPS, DPAPI, Shadow Credentials, LSASS dump sin Mimikatz |

### 🔴 Phase-03 — Red Team & Evasión de Defensas

| # | Operación | Adversario | Estado | Técnicas planificadas |
|---|---|---|---|---|
| Lab-08 | 👁️ **GHOST SIGNAL** | Lazarus Group | ⏳ Pendiente | AMSI bypass in-memory, Process injection, Direct syscalls |
| Lab-09 | 📡 **FIRST CONTACT** | Lazarus Group | ⏳ Pendiente | Password spraying, HTML Smuggling, VBA macros |
| Lab-10 | ⚡ **DARK CURRENT** | Lazarus Group | ⏳ Pendiente | Havoc C2, Sleep obfuscation, BOFs |
| Lab-11 | 🕳️ **DEEP HOLO** | Lazarus Group | ⏳ Pendiente | Simulación multicapa, EDR evasion real |

### 🏴 Phase-04 — Enterprise Simulation

| # | Operación | Adversario | Estado | Técnicas planificadas |
|---|---|---|---|---|
| Lab-12 | 🔥 **RED DANTE** | APT10 (Stone Panda) | ⏳ Pendiente | Red masiva mixta, persistencia multicapa, exfiltración |
| Lab-13 | 🌊 **DEEP WATER** | APT10 (Stone Panda) | ⏳ Pendiente | Forest Trusts avanzados, preparación CRTO |
| Lab-14 | ☁️ **AZURE BREACH** | APT10 (Stone Panda) | ⏳ Pendiente | Azure AD / Entra ID, Cloud-to-OnPremise |
| Lab-15 | 🌪️ **OPERATION ZEPHYR** | APT10 (Stone Panda) | ⏳ Pendiente | Supply chain, simulación final CRTO |

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
| 09 | Persistence | Golden Ticket (bloqueado PAC Validation) | T1558.001 | Impacket ticketer |
| 10 | Objective Completion | DCSync → Pass-the-Hash → Domain Admin | T1003.006, T1550.002 | secretsdump, Evil-WinRM |
| 11 | Delegation Abuse | Unconstrained (PetitPotam) + Constrained S4U2Proxy | T1558.001, T1187 | Rubeus, PetitPotam |
| 12 | GPO Abuse | helpdesk.ruiz → ScheduledTasks.xml SYSVOL → admin local | T1484.001, T1053.005 | PowerShell + SYSVOL |
| 13 | ACL Abuse | fin.garcia GenericWrite → Targeted Kerberoast → SQLService2024! | T1222, T1558.003 | bloodyAD, GetUserSPNs |

**Crown Jewels:** Hash NTLM Administrador · Dominio comprometido al 100%  
**Lecciones clave:** PAC Validation bloquea Golden Ticket · Potato attacks fallan en WinRM · SharpHound cubre ACLs/GPOs que bloodhound-python no recoge

</details>

---

### ✅ Lab-02 — SILENT BRIDGE | APT41 (Double Dragon)

**7 fases completadas · ~18 horas · Documentación completa**

<details>
<summary>Ver todas las fases y TTPs</summary>

| Fase | Nombre | Técnica | MITRE ID | Herramienta |
|---|---|---|---|---|
| 01 | Reconnaissance | Fingerprint Webmin 1.890 + CVE research | T1046, T1592 | Nmap, WhatWeb |
| 02 | Initial Access | CVE-2019-12840 RCE → root@prod | T1190, T1587.001 | Exploit Python |
| 03 | Pivoting | Ligolo-ng v0.7.5 → red interna enrutada | T1572, T1090.001 | Ligolo-ng |
| 04 | Internal Enum | Git history → thomas:iamthegreatest | T1552.001, T1213 | git log, curl |
| 05 | Lateral Movement | Evil-WinRM PC-01 como thomas | T1021.006 | Evil-WinRM |
| 06 | C2 Establishment | Beacon `SUDDEN_COMMUNICATION` vía relay PROD | T1071.001, T1090 | Sliver + Ligolo |
| 07 | Persistence + Loot | schtasks + SAM dump | T1053.005, T1003.002 | Impacket secretsdump |

**Crown Jewels:** Hash NTLM thomas + SAM de PC-01 · Red interna 10.0.3.0/24 comprometida

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
| 03 | ESC4 — Template Modification | fin.garcia GenericWrite → plantilla modificada | T1222, T1649 | Certipy |
| 04 | ESC8 — NTLM Relay | PetitPotam exitoso, relay bloqueado KB5005413 | T1557.001, T1187 | PetitPotam, ntlmrelayx |
| 05 | C2 Establishment | `CLINICAL_CHAIRMAN` en DC-01 | T1071.001 | Sliver v1.7.3 |
| 06 | Certificate Persistence | Cert válido post-rotación de contraseña | T1649 | Certipy |

**Crown Jewels:** Certificado Administrador válido · Persistencia post-rotación de contraseña

</details>

---

### ✅ Lab-04 — IRON FOREST | APT28 (Fancy Bear)

**8 fases completadas · ~20 horas · Documentación completa**

<details>
<summary>Ver todas las fases y TTPs</summary>

| Fase | Nombre | Técnica | MITRE ID | Herramienta |
|---|---|---|---|---|
| 01 | Reconnaissance | BloodHound CE + SharpHound v2.5.9 | T1087.002 | BloodHound CE, SharpHound |
| 02 | Credential Hunting | Share IT-Scripts + historial PS | T1552.001, T1039 | smbclient |
| 03 | Overpass-the-Hash | fin.garcia → TGT Kerberos válido 10h | T1550.003 | impacket-getTGT |
| 04 | WriteDACL Abuse | fin.garcia → DCSync rights sobre dominio | T1222 | impacket-dacledit |
| 05 | DCSync | Volcado completo hashes NTLM (13 entradas) | T1003.006 | impacket-secretsdump |
| 06 | ADIDNS Abuse | wpad.atackcorp.local → Responder NTLMv2 | T1557.001 | dnstool + Responder |
| 07 | C2 Establishment | Beacon `iron_forest_dc01` en DC-01 como DA | T1071.001 | Sliver v1.7.3 |
| 08 | Cleanup OPSEC | DCSync rights eliminados + WPAD tombstoned | T1070 | dacledit + dnstool |

**Crown Jewels:** Hash NTLM Administrador `bc3abc2e...` · Hash krbtgt `d5237a2e...` · NTLMv2 backup_svc  
**Lecciones clave:** DNS Global Query Block List bloquea WPAD · Responder conflicto puerto 80 con Docker · bloodhound-python no importa en BloodHound CE 5.x

</details>

---

### ✅ Lab-05 — SILVER CHAIN | APT28 (Fancy Bear)

**6 fases completadas · ~20 horas · Documentación completa**

<details>
<summary>Ver todas las fases y TTPs</summary>

| Fase | Nombre | Técnica | MITRE ID | Herramienta |
|---|---|---|---|---|
| 01 | Reconnaissance | BloodHound CE + SharpHound v2.5.9 | T1087.002 | BloodHound CE, SharpHound |
| 02 | RBCD Abuse | MachineAccountQuota + S4U2Self/S4U2Proxy | T1558.001 | impacket-addcomputer, getST |
| 03 | Shadow Credentials | msDS-KeyCredentialLink → PKINIT → hash | T1556, T1649 | pywhisker, certipy-ad |
| 04 | Silver Ticket | NTLM hash iis_svc → TGS MSSQLSvc forjado | T1558.002 | impacket-ticketer |
| 05 | Diamond Ticket | krbtgt AES256 → TGT real + PAC modificado | T1558.001 | Rubeus |
| 06 | C2 + Cleanup | Beacon WKSTN-01 + OPSEC cleanup | T1071.001, T1070 | Sliver, impacket, pywhisker |

**Crown Jewels:** TGS Administrador@WKSTN-01 · iis_svc NTLM `b329981877f0ca1243192863f356a2f9` · Silver Ticket MSSQLSvc · Diamond Ticket bypass PAC Validation  
**Lecciones clave:** pywhisker rompe impacket (reinstalar 0.13.1) · Diamond Ticket requiere AES256 · kirbi→ccache para usar desde Linux

</details>

---

## 🔜 Próximo objetivo

**Lab-06 — BLACK POLICY · APT28 (Fancy Bear)**

| Campo | Detalle |
|---|---|
| Técnicas | SID History, Cross-Forest Trust, GPO abuse avanzado, Domain Trust attacks |
| Crown Jewels | Acceso cross-domain via SID History injection |

---

## 📂 Estructura del Repositorio

```
Red-Team_Labs/
│
├── README.md
│
├── docs/
│   ├── design/
│   │   └── DESIGN.md                        # Filosofía, adversary emulation, roadmap v2.0
│   ├── detection/
│   │   └── DETECTION_RULES.md               # Reglas SIGMA y Event IDs por técnica
│   ├── operations/
│   │   ├── ENGAGEMENT_CHECKLIST.md          # Checklist pre/durante/post operación
│   │   ├── METHODOLOGY.md                   # Proceso operacional estándar
│   │   ├── OPSEC_NOTES.md                   # 17 secciones de OPSEC operacional
│   │   ├── THREAT_MODEL.md                  # Modelo de amenaza del entorno
│   │   └── WRITEUP_TEMPLATE.md              # Plantilla para nuevos labs
│   ├── progress/
│   │   ├── PROGRESS.md                      # Diario de sesiones + 35 técnicas dominadas
│   │   └── CHANGELOG.md                     # Historial de cambios del repo
│   └── reference/
│       ├── ARSENAL.md                        # Arsenal completo con rutas y versiones
│       ├── LAB_INFRASTRUCTURE.md            # Infraestructura detallada de cada lab
│       ├── MITRE_MAPPING.md                 # Mapping MITRE ATT&CK v14 por lab
│       └── TOOL_INDEX.md                    # Índice de herramientas con versiones
│
├── setup/
│   ├── provisioning/
|   |   └── 00_Setup_Lab01-GhostForest-v2.ps1
│   │   ├── 01_ad_promotion.ps1
│   │   ├── 02_users_ous.ps1
│   │   ├── 03_acls_delegations.ps1
│   │   ├── 04_iis_smb_gpo.ps1
│   │   ├── 05_mssql.ps1
│   │   ├── 06_wkstn01.ps1
│   │   ├── 07_Setup_DC02_Corp.ps1
│   │   ├── 08_Setup_DC03_Child.ps1
│   │   ├── 09_Setup_DC04_Ext.ps1
│   │   ├── 10_Setup_Trusts_And_SIDHistory.ps1
│   │   ├── 11_Setup_WKSTN02_Corp.ps1
│   │   
│   └── screenshots/                         # Evidencia del setup del entorno
│
├── tooling/                                 # Scripts de setup del arsenal Kali
│   ├── arsenal_setup.sh
│   ├── lab_start.sh
│   └── lab_stop.sh
│
├── Phase-01-Fundamentals/
│   ├── Lab-01-Ghost-Forest/    ✅ 13 fases · ~40h · APT29
│   ├── Lab-02-Silent-Bridge/   ✅ 7 fases  · ~18h · APT41
│   └── Lab-03-Dark-Gate/       ✅ 6 fases  · ~16h · APT29
│
├── Phase-02-Post-Exploitation/
│   ├── Lab-04-Iron-Forest/     ✅ 8 fases  · ~20h · APT28
│   ├── Lab-05-Silver-Chain/    ✅ 6 fases  · ~20h · APT28
│   ├── Lab-06-Black-Policy/    ⏳ Pendiente · APT28
│   └── Lab-07-Shadow-Vault/    ⏳ Pendiente · APT28
│
├── Phase-03-Red-Team-Operations/
│   ├── Lab-08-Ghost-Signals/   ⏳ Pendiente · Lazarus
│   ├── Lab-09-First-Contact/   ⏳ Pendiente · Lazarus
│   ├── Lab-10-Dark-Current/    ⏳ Pendiente · Lazarus
│   └── Lab-11-Deep-Holo/       ⏳ Pendiente · Lazarus
│
└── Phase-04-Enterprise-Simulation/
    ├── Lab-12-Red-Dante/        ⏳ Pendiente · APT10
    ├── Lab-13-Deep-Water/       ⏳ Pendiente · APT10
    ├── Lab-14-Azure-Breach/     ⏳ Pendiente · APT10
    └── Lab-15-Operation-Zephyr/ ⏳ Pendiente · APT10
```

**Cada lab completado contiene:**
- `OPERATION_*.md` — Resumen ejecutivo de la operación
- `docs/theory/tradecraft.md` — Fundamentos teóricos
- `docs/execution/*.md` — Comandos reales con output y notas OPSEC
- `docs/analysis/lessons_learned.md` — Qué funcionó, qué falló y por qué
- `docs/analysis/mitigations.md` — Detección y hardening Blue Team
- `docs/report/*.pdf` — Reporte ejecutivo en PDF
- `setup/CrownJewels-Lab*.ps1` — Script de verificación de objetivos
- `screenshots/FASE-XX-Nombre/` — Evidencia visual organizada por fase
- `loot/` — Hashes, tickets y credenciales capturadas

---

## 🔗 Kill Chain — Operaciones completadas

```mermaid
graph LR
    A[🎯 Foothold<br/>AS-REP · Kerberoast<br/>CVE-2019-12840<br/>ESC1/ESC4] --> B[🔀 Pivot<br/>Ligolo-ng<br/>Multi-network]
    B --> C[🔑 Credential Access<br/>DCSync · SAM dump<br/>Cert Auth · ADIDNS<br/>PS History · SMB shares]
    C --> D[⬆️ Privilege Escalation<br/>WriteDACL · ACL abuse<br/>GPO abuse · ADCS<br/>Delegation]
    D --> E[📡 C2<br/>Sliver HTTP/mTLS<br/>Beacons persistentes]
    E --> F[🧹 Cleanup<br/>OPSEC · Artefactos<br/>eliminados]

    style A fill:#cc0000,color:#fff
    style B fill:#ff6600,color:#fff
    style C fill:#cc6600,color:#fff
    style D fill:#990099,color:#fff
    style E fill:#006699,color:#fff
    style F fill:#009933,color:#fff
```

---

## 🧠 Metodología

```
1. ADVERSARY SELECTION  → Seleccionar grupo APT real · Estudiar TTPs documentadas
2. THEORY               → Fundamentos del protocolo antes de ejecutar
3. INFRASTRUCTURE       → Setup reproducible con scripts PowerShell
4. EXECUTION            → Comandos documentados con output real + notas OPSEC
5. ANALYSIS             → Post-mortem: qué funcionó, qué falló y por qué
6. BLUE TEAM            → Event IDs · Reglas SIGMA · Hardening
7. REPORT               → Reporte ejecutivo en PDF + lessons learned
```

---

## 🛠️ Arsenal

### C2 Frameworks

| Herramienta | Versión | Labs | Uso |
|---|---|---|---|
| **Sliver** (BishopFox) | v1.7.3 | Lab-01/02/03/04 | C2 principal — HTTP/mTLS beacons, post-explotación |
| **Havoc C2** | Latest | Lab-10 | C2 alternativo — BOFs, sleep obfuscation |

### Active Directory & Kerberos

| Herramienta | Uso |
|---|---|
| **Impacket** | GetNPUsers, GetUserSPNs, secretsdump, getTGT, dacledit |
| **Rubeus** | Ticket manipulation, S4U2Self/S4U2Proxy |
| **BloodHound CE** v9.1.0 | Attack paths, ACL analysis — Docker `~/tools/ad/bloodhound-ce/` |
| **SharpHound** v2.5.9 | Recolección CE-compatible — `/opt/redteam/windows/SharpHound.exe` |
| **bloodhound-python** | Recolección OPSEC-friendly (sin binarios en objetivo) |
| **PowerView** | Enumeración AD desde PowerShell — LOLBins |
| **bloodyAD** | ACL abuse — GenericWrite, WriteDACL |
| **Evil-WinRM** | Shell remota WinRM con upload/download |
| **Kerbrute** | Enumeración de usuarios sin bloqueo de cuentas |

### ADCS & ACL Abuse

| Herramienta | Versión | Uso |
|---|---|---|
| **Certipy** | v5.0.4 | ESC1/ESC4/ESC8 |
| **impacket-dacledit** | v0.14 | WriteDACL → DCSync rights |
| **dnstool.py** (krbrelayx) | Latest | ADIDNS registro WPAD |
| **Responder** | v3.2.2 | NTLMv2 capture via WPAD |
| **PetitPotam** | Latest | NTLM coercion |

### Pivotaje & Red

| Herramienta | Uso |
|---|---|
| **Ligolo-ng** v0.7.5 | Tunneling full-duplex — redes segmentadas |
| **Chisel** | Tunneling HTTP/HTTPS reversible |
| **Nmap** | Reconocimiento a través de túneles Ligolo |

---

## ⚙️ Setup del Entorno

### Requisitos de hardware

```
RAM mínima:    32 GB  (entorno CRTO completo — 4 DCs + 2 WKSTNs + Kali)
CPU:           8 cores (recomendado — VT-x/AMD-V activo en BIOS)
Disco:         400 GB libres
Hypervisor:    VirtualBox 7.x
RAM por VM:    Kali 8GB · DC-01 4GB · DC-02/03 3GB · DC-04 2GB · WKSTNs 3GB
```

### Setup automatizado

```powershell
# DC-01 — atackcorp.local
.\setup\provisioning\01_ad_promotion.ps1
.\setup\provisioning\02_users_ous.ps1
.\setup\provisioning\03_acls_delegations.ps1
.\setup\provisioning\04_iis_smb_gpo.ps1
.\setup\provisioning\05_mssql.ps1
.\setup\provisioning\10_Setup_Trusts_And_SIDHistory.ps1  # post Forest Trusts

# WKSTN-01 — atackcorp.local
.\setup\provisioning\06_wkstn01.ps1
.\setup\provisioning\00_setup_lab01_ghost_forest_v2.ps1

# DC-02 — corp.local
.\setup\provisioning\07_Setup_DC02_Corp.ps1

# DC-03 — child.atackcorp.local
.\setup\provisioning\08_Setup_DC03_Child.ps1

# DC-04 — ext.local
.\setup\provisioning\09_Setup_DC04_Ext.ps1

# WKSTN-02 — corp.local
.\setup\provisioning\11_Setup_WKSTN02_Corp.ps1
```

```bash
# En Kali Linux
git clone https://github.com/adr-camacho/RedTeam-Ops-Roadmap.git
cd RedTeam-Ops-Roadmap
bash tooling/arsenal_setup.sh
```

---

## 📊 MITRE ATT&CK Coverage

**Técnicas dominadas: 45 · Parciales: 2 · En roadmap: 24+**

| Táctica | Técnica | ID | Lab | Estado |
|---|---|---|---|---|
| Reconnaissance | Network Service Discovery | T1046 | Lab-01/02/03 | ✅ |
| Initial Access | Exploit Public Application | T1190 | Lab-02 | ✅ |
| Execution | Windows Remote Management | T1021.006 | Lab-01/02/03/04 | ✅ |
| Persistence | Certificate Persistence | T1649 | Lab-03 | ✅ |
| Privilege Escalation | GPO Modification | T1484.001 | Lab-01 | ✅ |
| Privilege Escalation | WriteDACL → DCSync | T1222 | Lab-04 | ✅ |
| Defense Evasion | Impair Defenses | T1562.001 | Lab-01 | ✅ |
| Defense Evasion | Indicator Removal | T1070 | Lab-04 | ✅ |
| Credential Access | AS-REP Roasting | T1558.004 | Lab-01 | ✅ |
| Credential Access | Kerberoasting | T1558.003 | Lab-01 | ✅ |
| Credential Access | DCSync | T1003.006 | Lab-01/03/04 | ✅ |
| Credential Access | Overpass-the-Hash | T1550.003 | Lab-04 | ✅ |
| Credential Access | ESC1/ESC4 ADCS | T1649 | Lab-03 | ✅ |
| Credential Access | Credential Hunting | T1552.001 | Lab-02/04 | ✅ |
| Credential Access | ADIDNS/WPAD Poisoning | T1557.001 | Lab-04 | ✅ |
| Lateral Movement | Pass-the-Hash | T1550.002 | Lab-01/03 | ✅ |
| C&C | Sliver HTTP/mTLS | T1071.001, T1573.002 | Lab-01/02/03/04 | ✅ |
| C&C | Protocol Tunneling Ligolo-ng | T1572 | Lab-02 | ✅ |
| Privilege Escalation | RBCD S4U2Proxy | T1558.001 | Lab-05 | ✅ |
| Credential Access | Shadow Credentials | T1556 | Lab-05 | ✅ |
| Credential Access | Silver Ticket | T1558.002 | Lab-05 | ✅ |
| Credential Access | Diamond Ticket | T1558.001 | Lab-05 | ✅ |

---

## 📁 Documentación Global

| Documento | Descripción |
|---|---|
| `docs/design/DESIGN.md` | Filosofía, adversary emulation, roadmap v2.0 |
| `docs/detection/DETECTION_RULES.md` | Reglas SIGMA y Event IDs por técnica |
| `docs/operations/ENGAGEMENT_CHECKLIST.md` | Checklist pre/durante/post operación |
| `docs/operations/OPSEC_NOTES.md` | 17 secciones de OPSEC operacional |
| `docs/reference/ARSENAL.md` | Arsenal completo con rutas y versiones |
| `docs/reference/LAB_INFRASTRUCTURE.md` | Infraestructura detallada de cada lab |
| `docs/reference/MITRE_MAPPING.md` | Mapping MITRE ATT&CK v14 completo |
| `docs/progress/PROGRESS.md` | Diario de sesiones + 45 técnicas dominadas |
| `docs/progress/CHANGELOG.md` | Historial completo de cambios |

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