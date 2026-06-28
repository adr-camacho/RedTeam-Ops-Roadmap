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
  [ CRTO Preparation · Cobalt Strike / Sliver C2 · MITRE ATT&CK v14 · 18 Labs ]
```

[![Estado](https://img.shields.io/badge/Estado-Documentado%2018%2F18-brightgreen?style=for-the-badge)](./)
[![Ejecutados](https://img.shields.io/badge/Ejecutados-7%20labs%20(Phase--01%2F02)-blue?style=for-the-badge)](./)
[![Horas](https://img.shields.io/badge/Horas%20invertidas-~143h-purple?style=for-the-badge)](./)
[![MITRE](https://img.shields.io/badge/Framework-MITRE%20ATT%26CK%20v14-black?style=for-the-badge)](https://attack.mitre.org)
[![CRTO](https://img.shields.io/badge/Objetivo-CRTO%20Agosto%202026-orange?style=for-the-badge)](./)
[![Licencia](https://img.shields.io/badge/Uso-Educativo-green?style=for-the-badge)](./)

**Documentación operacional de Red Team en Active Directory.**  
Adversary emulation real — APT29, APT41, APT28, Lazarus, APT10 — con C2 Open Source y Cobalt Strike.

[📋 Estado de labs](#-estado-de-labs) · [🗺️ Roadmap](#️-roadmap-completo) · [🏗️ Entorno](#️-arquitectura-del-entorno) · [🧠 Metodología](#-metodología) · [⚙️ Setup](#️-setup-del-entorno)

</div>

---

## 📌 ¿Qué es este repositorio?

Programa de preparación para la certificación **CRTO (Certified Red Team Operator)** documentado como repositorio operacional público. No es una colección de write-ups — es **documentación estructurada de 18 labs de adversary emulation**, con anatomía consistente, arco narrativo de adversarios reales y cobertura del temario CRTO de extremo a extremo.

**Lo que lo diferencia:**

- **18 labs en 4 fases**, todos documentados en anatomía v3.1: `technique · emulation · detection · lessons · execution`
- **Arco de adversario documentado:** APT29/APT41/APT28 (Phase-01/02) → Lazarus Group (Phase-03) → APT10/Cloud Hopper (Phase-04)
- **Emulation plans honestos:** cada `emulation.md` distingue qué es TTP genuina del actor vs tradecraft universal del operador — nivel de rigor defendible ante un revisor técnico
- **7 labs ejecutados de verdad** (Labs 01-07) con logs reales, hashes reales, fallos documentados y lecciones con causa raíz
- **11 labs diseñados** (Labs 08-18) como plan de ataque v3.1, listos para ejecutar con el curso CRTO
- **Capa defensiva integrada:** cada lab tiene `detection.md` con Event IDs, reglas Sigma/KQL y el "puente de evasión" hacia el siguiente bloque
- Infraestructura local real: **3 forests, 4 DCs, 2 workstations, Kali** — todo en VirtualBox

> ⚠️ **Entorno 100% controlado.** Laboratorio local con VMs. Uso exclusivo educativo y de preparación para certificación.

---

## 📋 Estado de labs

### Leyenda

| Icono | Significado |
|-------|-------------|
| ✅ **Ejecutado** | Lab completado con logs reales, credenciales capturadas, lecciones documentadas |
| 📐 **v3.1 (plan)** | Anatomía v3.1 completa — technique/emulation/detection/lessons + plan de ejecución; pendiente de ejecutar con el curso CRTO |

### Phase-01 — Fundamentals (APT29 · APT41)

| Lab | Operación | Adversario | Estado | Técnicas principales |
|-----|-----------|-----------|--------|---------------------|
| Lab-01 | 🌲 **GHOST FOREST** | APT29 | ✅ **Ejecutado** ~40h | AS-REP Roasting · Kerberoasting · DCSync · Delegation · GPO/ACL Abuse |
| Lab-02 | 🌉 **SILENT BRIDGE** | APT41 | ✅ **Ejecutado** ~18h | CVE-2019-12840 RCE · Ligolo-ng pivot · SAM dump · C2 relay |
| Lab-03 | 🌑 **DARK GATE** | APT29 | ✅ **Ejecutado** ~16h | ADCS ESC1/ESC4/ESC8 · Certipy · Certificate persistence |

### Phase-02 — Post-Exploitation (APT28)

| Lab | Operación | Adversario | Estado | Técnicas principales |
|-----|-----------|-----------|--------|---------------------|
| Lab-04 | 🔴 **IRON FOREST** | APT28 | ✅ **Ejecutado** ~20h | WriteDACL→DCSync · BloodHound · ADIDNS · Overpass-the-Hash |
| Lab-05 | ⛓️ **SILVER CHAIN** | APT28 | ✅ **Ejecutado** ~20h | RBCD · Shadow Credentials · Silver Ticket · Diamond Ticket |
| Lab-06 | 📋 **BLACK POLICY** | APT28 | ✅ **Ejecutado** ~25h | SID History · Cross-Forest Trust · GPO Abuse · DSInternals |
| Lab-07 | 🔒 **SHADOW VAULT** | APT28 | ✅ **Ejecutado** ~8h | LAPS · DPAPI · LSASS (bloqueado PPL) · Shadow Credentials |

### Phase-03 — Red Team Operations (Lazarus Group)

> El operador **monta y templa su kit**: C2, recon, persistencia, evasión.

| Lab | Operación | Estado | Bloque CRTO |
|-----|-----------|--------|-------------|
| Lab-08 | 📶 **BLACK BEACON** | 📐 v3.1 (plan) | C2 Foundations — listeners, beacons, staged/stageless, OPSEC |
| Lab-09 | 📡 **FIRST CONTACT** | 📐 v3.1 (plan) | Situational Awareness — árbol de decisión de la primera hora |
| Lab-10 | 🌱 **DEEP ROOT** | 📐 v3.1 (plan) | Host Persistence & PrivEsc — Potato, servicios, UAC, WMI |
| Lab-11 | 👁️ **GHOST SIGNAL** | 📐 v3.1 (plan) | Evasión I — Defender / AMSI / ETW patching |
| Lab-12 | 🛡️ **IRON VEIL** | 📐 v3.1 (plan) | Evasión II — AppLocker / CLM / LOLBAS |

### Phase-04 — Enterprise & Exam (APT10 / Cloud Hopper)

> El kit se **despliega en una operación enterprise completa**.

| Lab | Operación | Estado | Bloque CRTO |
|-----|-----------|--------|-------------|
| Lab-13 | 🔗 **LINKED SHADOWS** | 📐 v3.1 (plan) | MS SQL Servers — enum · linked servers · xp_cmdshell · lateral |
| Lab-14 | 👑 **GOLDEN THRONE** | 📐 v3.1 (plan) | Domain Dominance — Golden/Silver/Diamond · ADCS certs · DSRM · AdminSDHolder |
| Lab-15 | 🌲 **FOREST REIGN** | 📐 v3.1 (plan) | Forest & Trust Abuse — Extra SID · SID Filtering · cross-forest |
| Lab-16 | 🧰 **CUSTOM ARSENAL** | 📐 v3.1 (plan) | Extending C2 — Malleable C2 · BOFs · Aggressor Scripts |
| Lab-17 | 🚪 **SILENT EXIT** | 📐 v3.1 (plan) | Exfiltration & Reporting — data hunting · RAR+cloud · OPSEC |
| Lab-18 | ⚖️ **FINAL VERDICT** | 📐 v3.1 (plan) | Capstone — cadena completa 48h · Defender ON · por objetivos |

---

## 🗺️ Roadmap completo

```
PHASE-01 ── APT29 + APT41 ──► Fundamentos AD, Kerberos, ADCS, Pivotaje        [✅ ejecutado]
PHASE-02 ── APT28          ──► AD Avanzado, WriteDACL, DCSync, Credential Hunting [✅ ejecutado]
PHASE-03 ── Lazarus Group  ──► C2, Operativa de Host, Evasión (Defender/AMSI/AppLocker) [📐 plan]
PHASE-04 ── APT10          ──► MSSQL, Domain Dominance, Trusts, C2 avanzado, Capstone  [📐 plan]
```

El arco narrativo: **Lazarus monta y templa el kit** (Phase-03) → **APT10/Cloud Hopper lo despliega a escala enterprise** (Phase-04), culminando en el capstone Lab-18 que simula las 48h del examen CRTO.

Fuente de verdad del plan: [`docs/ROADMAP.md`](docs/ROADMAP.md) · Diseño del arco Phase-03/04: [`docs/PHASE_03_04_DESIGN.md`](docs/PHASE_03_04_DESIGN.md)

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
│  │  Root DC      │  │  child.atack. │  │  Windows 11  │             │
│  │  ADCS + LAPS  │  │  corp.local   │  │  23H2        │             │
│  └──────┬────────┘  └──────────────┘  └──────────────┘             │
│         │ BiDir Trust (SID Filtering OFF)                           │
│  FOREST 2: corp.local ◄────────────────────────────────            │
│  ┌──────────────┐  ┌──────────────┐                                │
│  │    DC-02      │  │   WKSTN-02   │                                │
│  │  10.0.2.11    │  │  10.0.2.12   │                                │
│  └──────────────┘  └──────────────┘                                │
│         │ BiDir Trust                                               │
│  FOREST 3: ext.local ◄─────────────────────────────────            │
│  ┌──────────────┐                                                   │
│  │    DC-04      │                                                  │
│  │  10.0.2.14    │                                                  │
│  └──────────────┘                                                   │
│                                                                     │
│  Kali Linux 10.0.2.9 — Atacante / C2 / Arsenal                     │
│  Lab-02 — Red interna 10.0.3.0/24                                   │
└─────────────────────────────────────────────────────────────────────┘
```

| Host | IP | OS | RAM | Rol |
|------|----|----|-----|-----|
| DC-01 | 10.0.2.10 | Windows Server 2025 | 22GB | Domain Controller — atackcorp.local · ADCS · Windows LAPS |
| DC-02 | 10.0.2.11 | Windows Server 2022 | 3GB | Domain Controller — corp.local (Forest 2) |
| DC-03 | 10.0.2.13 | Windows Server 2022 | 3GB | Domain Controller — child.atackcorp.local |
| DC-04 | 10.0.2.14 | Windows Server 2022 | 2GB | Domain Controller — ext.local (Forest 3) |
| WKSTN-01 | 10.0.2.8 | Windows 11 23H2 | 3GB | Workstation — atackcorp.local (PPL activo) |
| WKSTN-02 | 10.0.2.12 | Windows 11 | 3GB | Workstation — corp.local |
| Kali | 10.0.2.9 | Kali Linux 2026.1 | 8GB | Atacante / C2 Server |

---

## 📂 Estructura del Repositorio

```
Red-Team_Labs/
├── README.md
├── docs/
│   ├── ROADMAP.md                     # Plan canónico 18 labs (fuente de verdad)
│   ├── DESIGN.md                      # Filosofía y metodología v3.1
│   ├── STANDARDS.md                   # Anatomía v3.1 + Definition of Done
│   ├── PROGRESS.md                    # Estado de labs y diario de progreso
│   ├── CHANGELOG.md                   # Historial de cambios
│   ├── PHASE_03_04_DESIGN.md          # Diseño del arco narrativo Phase-03/04
│   ├── adversaries/                   # Perfiles de adversario (5 actores)
│   │   ├── APT28.md · APT29.md · APT41.md
│   │   ├── Lazarus.md                 # Ancla Phase-03
│   │   └── APT10.md                   # Ancla Phase-04 (Cloud Hopper)
│   └── reference/
│       ├── ARSENAL.md · TOOL_INDEX.md
│       ├── BLOODHOUND_METHODOLOGY.md  # Referencia transversal
│       ├── CRTO_COVERAGE.md
│       ├── DETECTION_LIBRARY.md       # Herencia en detection.md de cada lab
│       ├── MITRE_MAPPING.md
│       └── LAB_INFRASTRUCTURE.md
├── setup/                             # Scripts de aprovisionamiento (por DC/WKSTN)
├── tooling/                           # arsenal_setup.sh · lab_start/stop.sh
├── Phase-01-Fundamentals/             # ✅ Labs 01-03 ejecutados
├── Phase-02-Post-Exploitation/        # ✅ Labs 04-07 ejecutados
├── Phase-03-Red-Team-Operations/      # 📐 Labs 08-12 documentados v3.1
└── Phase-04-Enterprise-Simulation/    # 📐 Labs 13-18 documentados v3.1
```

### Anatomía de cada lab (v3.1)

```
Lab-XX-Nombre/
├── README.md                    # Ficha: capability, arquetipo, adversario, links
├── docs/
│   ├── technique.md             # Concepto, internals, comandos, CS↔Sliver, MITRE, OPSEC
│   ├── emulation.md             # Plan de emulación: genuino vs tradecraft (honesto)
│   ├── detection.md             # Blue Team: Event IDs, Sigma/KQL, puente de evasión
│   ├── lessons.md               # Lecciones con causa raíz
│   └── execution/               # Módulos con grafo de dependencias
│       ├── M1_nombre.md         # Labs 01-07: log real con output y capturas
│       └── M2_nombre.md         # Labs 08-18: plan de ejecución (pasa a log al ejecutar)
└── loot/ · nmap/ · screenshots/ · report/
```

---

## 🔍 Detalle de labs ejecutados (01-07)

<details>
<summary>✅ Lab-01 — GHOST FOREST | APT29 · ~40h · 13 fases</summary>

| Fase | Técnica | MITRE ID | Herramienta |
|------|---------|----------|-------------|
| Reconnaissance | Network scanning + LDAP/SMB enum | T1046, T1135 | Nmap, enum4linux-ng |
| Initial Access | AS-REP Roasting → ceo.martinez | T1558.004, T1110.002 | GetNPUsers, Hashcat |
| Foothold | Evil-WinRM shell | T1021.006 | Evil-WinRM |
| Discovery | BloodHound CE + PowerView + SPN enum | T1087.002, T1482 | BloodHound, ldapsearch |
| Credential Access | Kerberoasting → backup_svc → DA | T1558.003 | GetUserSPNs, John |
| Lateral Movement | WinRM a WKSTN-01 | T1021.006, T1550.002 | Evil-WinRM |
| C2 | Sliver HTTPS beacon EASY_PROFIT | T1071.001, T1573.002 | Sliver v1.7.3 |
| Privilege Escalation | SeImpersonatePrivilege + Defender bypass | T1134.001 | PrintSpoofer |
| Persistence | Golden Ticket — bloqueado PAC Validation | T1558.001 | Impacket ticketer |
| Domain Compromise | DCSync → Pass-the-Hash → DA | T1003.006, T1550.002 | secretsdump |
| Delegation Abuse | Unconstrained (PetitPotam) + Constrained S4U2Proxy | T1558.001 | Rubeus |
| GPO Abuse | helpdesk.ruiz → ScheduledTasks.xml SYSVOL | T1484.001, T1053.005 | SYSVOL |
| ACL Abuse | fin.garcia GenericWrite → Targeted Kerberoast | T1222, T1558.003 | bloodyAD |

**Crown Jewels:** Hash NTLM Administrador · Hash krbtgt `d5237a2e...` · Dominio comprometido
**Lecciones clave:** PAC Validation bloquea Golden Ticket · Potato falla en WinRM · SharpHound cubre ACLs/GPOs que bloodhound-python no recoge
</details>

<details>
<summary>✅ Lab-02 — SILENT BRIDGE | APT41 · ~18h · 7 fases</summary>

| Fase | Técnica | MITRE ID | Herramienta |
|------|---------|----------|-------------|
| Reconnaissance | Fingerprint Webmin 1.890 | T1046, T1592 | Nmap, WhatWeb |
| Initial Access | CVE-2019-12840 RCE → root@prod | T1190 | Exploit Python |
| Pivoting | Ligolo-ng v0.7.5 → red interna | T1572, T1090.001 | Ligolo-ng |
| Internal Enum | Git history → thomas:iamthegreatest | T1552.001, T1213 | git log |
| Lateral Movement | Evil-WinRM PC-01 como thomas | T1021.006 | Evil-WinRM |
| C2 | Beacon SUDDEN_COMMUNICATION vía relay | T1071.001 | Sliver + Ligolo |
| Persistence + Loot | schtasks + SAM dump | T1053.005, T1003.002 | secretsdump |

**Crown Jewels:** Hash NTLM thomas · SAM de PC-01 · Red interna 10.0.3.0/24 comprometida
</details>

<details>
<summary>✅ Lab-03 — DARK GATE | APT29 · ~16h · 6 fases</summary>

| Fase | Técnica | MITRE ID | Herramienta |
|------|---------|----------|-------------|
| ADCS Enum | certipy-ad find → ESC1 + ESC4 + ESC8 | T1046 | Certipy v5.0.4 |
| ESC1 — SAN Abuse | ceo.martinez → cert Administrador → DA | T1649 | Certipy |
| ESC4 — Template Modification | fin.garcia GenericWrite → plantilla modificada | T1222, T1649 | Certipy |
| ESC8 — NTLM Relay | PetitPotam exitoso, relay bloqueado KB5005413 | T1557.001 | PetitPotam |
| C2 | CLINICAL_CHAIRMAN en DC-01 | T1071.001 | Sliver |
| Certificate Persistence | Cert válido post-rotación de contraseña | T1649 | Certipy |

**Crown Jewels:** Certificado Administrador válido · Persistencia post-rotación
</details>

<details>
<summary>✅ Lab-04 — IRON FOREST | APT28 · ~20h · 8 fases</summary>

| Fase | Técnica | MITRE ID | Herramienta |
|------|---------|----------|-------------|
| Reconnaissance | BloodHound CE + SharpHound v2.5.9 | T1087.002 | BloodHound CE |
| Credential Hunting | Share IT-Scripts + historial PS | T1552.001 | smbclient |
| Overpass-the-Hash | fin.garcia → TGT Kerberos válido | T1550.003 | impacket-getTGT |
| WriteDACL Abuse | fin.garcia → DCSync rights | T1222 | impacket-dacledit |
| DCSync | Volcado completo hashes NTLM | T1003.006 | secretsdump |
| ADIDNS Abuse | wpad.atackcorp.local → Responder NTLMv2 | T1557.001 | dnstool + Responder |
| C2 | Beacon iron_forest_dc01 en DC-01 como DA | T1071.001 | Sliver |
| Cleanup OPSEC | DCSync rights eliminados + WPAD tombstoned | T1070 | dacledit |

**Crown Jewels:** Hash NTLM Administrador `bc3abc2e...` · Hash krbtgt `d5237a2e...`
**Lecciones clave:** DNS Global Query Block List bloquea WPAD · bloodhound-python no importa en BloodHound CE 5.x
</details>

<details>
<summary>✅ Lab-05 — SILVER CHAIN | APT28 · ~20h · 6 fases</summary>

| Fase | Técnica | MITRE ID | Herramienta |
|------|---------|----------|-------------|
| Reconnaissance | BloodHound CE + SharpHound v2.5.9 | T1087.002 | BloodHound CE |
| RBCD Abuse | MachineAccountQuota + S4U2Self/S4U2Proxy | T1558.001 | impacket, getST |
| Shadow Credentials | msDS-KeyCredentialLink → PKINIT → hash | T1556, T1649 | pywhisker, certipy-ad |
| Silver Ticket | NTLM hash iis_svc → TGS MSSQLSvc forjado | T1558.002 | impacket-ticketer |
| Diamond Ticket | krbtgt AES256 → TGT real + PAC modificado | T1558.001 | Rubeus |
| C2 + Cleanup | Beacon WKSTN-01 + OPSEC cleanup | T1071.001 | Sliver |

**Crown Jewels:** Silver Ticket MSSQLSvc · Diamond Ticket bypass PAC Validation
**Lecciones clave:** pywhisker rompe impacket (reinstalar 0.13.1) · Diamond Ticket requiere AES256
</details>

<details>
<summary>✅ Lab-06 — BLACK POLICY | APT28 · ~25h · 5 fases</summary>

| Fase | Técnica | MITRE ID | Herramienta |
|------|---------|----------|-------------|
| Reconnaissance | Cross-Forest enum + Kerberoasting corp_svc/ext_svc | T1558.003 | nxc, GetUserSPNs, John |
| SID History Injection | DSInternals → child.user = DA atackcorp | T1134.005 | DSInternals v4.14 |
| Cross-Forest Trust | corp.local + ext.local comprometidos · DCSync krbtgt x3 | T1482, T1003.006 | bloodyAD, secretsdump |
| GPO Abuse | WriteDACL helpdesk.ruiz → FullControl GPO → admin WKSTN-01 | T1484.001 | dacledit, pyGPOAbuse |
| C2 + Cleanup | Beacons WKSTN-01 + DC-02 · Crown Jewel IPO_strategy_2026.txt | T1071.001 | Sliver |

**Crown Jewels:** `IPO_strategy_2026.txt` · krbtgt atackcorp/corp/ext · helpdesk.ruiz admin local
</details>

<details>
<summary>✅ Lab-07 — SHADOW VAULT | APT28 · ~8h · 5 fases</summary>

| Fase | Técnica | MITRE ID | Herramienta |
|------|---------|----------|-------------|
| LAPS Extraction | Windows LAPS Password Disclosure via LDAP | T1201 | nxc ldap -M laps |
| DPAPI Extraction | DPAPI Master Key dump + Credential Manager decrypt | T1555.004 | impacket-dpapi |
| LSASS Dump | comsvcs.dll MiniDump — BLOQUEADO Windows 11 23H2+ (PPL/KPP) | T1003.001 | Bloqueado |
| Shadow Credentials | msDS-KeyCredentialLink abuse + PKINIT | T1649 | pywhisker, certipy-ad |
| C2 + Cleanup | Sliver HTTPS beacon + eliminación artefactos | T1071.001 | Sliver |

**Crown Jewels:** `WKSTN-01\Administrador:@98q6$13Z{K99;` · `sa:SQLsa2026!` · NT hash WKSTN-01$
**Lecciones clave:** WS2025 LAPS usa GKDI por defecto · Windows 11 23H2+ KPP bloquea LSASS incluso con PPL=0
</details>

---

## 🧠 Metodología

```
┌────────────────────────────────────────────────────────────────────┐
│  LABS 01-07 (ejecutados)          LABS 08-18 (plan v3.1)           │
│  ─────────────────────            ─────────────────────────────    │
│  1. Adversary Selection           1. technique.md — el porqué      │
│  2. Threat Model + Crown Jewels   2. emulation.md — el actor       │
│  3. Theory (technique.md)         3. detection.md — el defensor    │
│  4. Infrastructure + Setup        4. lessons.md — el criterio      │
│  5. Reconnaissance                5. execution/ — el PLAN          │
│  6. Execution (logs reales)          (pasa a log real al ejecutar  │
│  7. Cleanup + OPSEC                   con el curso CRTO)           │
│  8. Analysis + lessons                                              │
│  9. Detection (Blue Team)                                          │
│ 10. Report                                                         │
└────────────────────────────────────────────────────────────────────┘
```

**Principio de honestidad técnica:** los `emulation.md` distinguen explícitamente qué es TTP genuina del actor (citada con fuente) vs tradecraft universal del operador — esa distinción es la diferencia entre un emulation plan defendible y teatro decorativo.

---

## 🛠️ Arsenal Principal

### C2 Frameworks

| Herramienta | Versión | Uso |
|-------------|---------|-----|
| **Sliver** (BishopFox) | v1.7.3 | C2 principal Labs 01-07 — HTTP/mTLS |
| **Cobalt Strike** | (curso CRTO) | C2 Labs 08-18 — Malleable C2, BOFs, Aggressor |

### Active Directory & Kerberos

| Herramienta | Uso |
|-------------|-----|
| **Impacket** | GetNPUsers, GetUserSPNs, secretsdump, getTGT, dacledit |
| **Rubeus** | Ticket manipulation, S4U2Self/S4U2Proxy, Diamond Ticket |
| **BloodHound CE** v9.1.0 | Attack paths, ACL analysis |
| **SharpHound** v2.5.9 | Recolección CE-compatible |
| **PowerView** | Enumeración AD desde PowerShell |
| **bloodyAD** | ACL abuse — GenericWrite, WriteDACL |
| **Evil-WinRM** | Shell remota WinRM |
| **PowerUpSQL** | Enumeración y explotación MSSQL (Lab-13) |

### ADCS, Pivoting & Evasión

| Herramienta | Uso |
|-------------|-----|
| **Certipy** v5.0.4 | ADCS ESC1/ESC4/ESC8 |
| **Ligolo-ng** v0.7.5 | Tunneling full-duplex |
| **PrintSpoofer / GodPotato** | SeImpersonate → SYSTEM |
| **DSInternals** v4.14 | SID History injection |
| **pyGPOAbuse** | GPO abuse cross-forest |

---

## ⚙️ Setup del Entorno

```
RAM: 40 GB mínimo · CPU: 8 cores · Disco: 400 GB · Hypervisor: VirtualBox 7.x
```

```powershell
# DC-01 — atackcorp.local (ejecutar en orden)
.\setup\DC-01\01_promover_controlador_de_dominio_atackcorp.ps1
.\setup\DC-01\02_crear_usuarios_ous_atackcorp.ps1
.\setup\DC-01\10_configurar_forest_trusts_sid_filtering.ps1
.\setup\DC-01\12_configurar_windows_laps_atackcorp.ps1
.\setup\DC-01\13_instalar_adcs_ca_atackcorp.ps1
```

```bash
# En Kali Linux
git clone https://github.com/adr-camacho/RedTeam-Ops-Roadmap.git
cd RedTeam-Ops-Roadmap && bash tooling/arsenal_setup.sh
```

Guía completa: [`setup/README.md`](setup/README.md)

---

## 📚 Documentación Global

| Documento | Descripción |
|-----------|-------------|
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Plan canónico 18 labs — fuente de verdad |
| [`docs/DESIGN.md`](docs/DESIGN.md) | Filosofía y metodología v3.1 |
| [`docs/STANDARDS.md`](docs/STANDARDS.md) | Anatomía v3.1 + Definition of Done |
| [`docs/PHASE_03_04_DESIGN.md`](docs/PHASE_03_04_DESIGN.md) | Arco narrativo Phase-03/04 |
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | Estado de labs y diario de progreso |
| [`docs/adversaries/`](docs/adversaries/) | Perfiles de adversario (5 actores) |
| [`docs/reference/MITRE_MAPPING.md`](docs/reference/MITRE_MAPPING.md) | Mapping MITRE ATT&CK v14 completo |
| [`docs/reference/DETECTION_LIBRARY.md`](docs/reference/DETECTION_LIBRARY.md) | Biblioteca de detección transversal |
| [`docs/reference/BLOODHOUND_METHODOLOGY.md`](docs/reference/BLOODHOUND_METHODOLOGY.md) | Metodología BloodHound |

---

<div align="center">

---

**Adrián Camacho** · Red Team Ops

[![LinkedIn](https://img.shields.io/badge/LinkedIn-adrian--camacho--mora-0077B5?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/adrian-camacho-mora/)
[![GitHub](https://img.shields.io/badge/GitHub-adr--camacho-181717?style=flat-square&logo=github)](https://github.com/adr-camacho)

> *"Documenta como si alguien más tuviera que ejecutar la operación."*

⚠️ **Disclaimer:** Todo el contenido es de uso exclusivamente educativo en entornos de laboratorio controlados. El uso de estas técnicas contra sistemas sin autorización explícita es ilegal. El autor no se hace responsable del uso indebido.

</div>
