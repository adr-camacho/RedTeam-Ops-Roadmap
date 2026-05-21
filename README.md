# 🚩 Red Team Ops Roadmap

[![Status](https://img.shields.io/badge/Status-In%20Progress-orange)](https://github.com/adr-camacho/RedTeam-Ops-Roadmap)
[![Domain](https://img.shields.io/badge/Domain-Active%20Directory%20%7C%20Red%20Team-red)](https://github.com/adr-camacho/RedTeam-Ops-Roadmap)
[![C2](https://img.shields.io/badge/C2-Sliver%20%7C%20Havoc-blueviolet)](https://github.com/adr-camacho/RedTeam-Ops-Roadmap)
[![MITRE](https://img.shields.io/badge/Framework-MITRE%20ATT%26CK%20v14-red)](./docs/MITRE_MAPPING.md)
[![Labs](https://img.shields.io/badge/Labs-3%2F15%20Completados-green)](./docs/PROGRESS.md)
[![Design](https://img.shields.io/badge/Roadmap-v2.0-blue)](./DESIGN.md)

Repositorio de operaciones Red Team con enfoque en **entornos reales de Active Directory**. Documenta el proceso de aprendizaje progresivo desde fundamentos hasta simulación de infraestructura corporativa compleja, emulando adversarios reales mediante frameworks C2 modernos y open source.

El objetivo no es ejecutar herramientas mecánicamente — es **entender cada técnica a nivel de protocolo**, construir exploits desde cero cuando las herramientas fallan, y documentar tanto la perspectiva ofensiva como la defensiva en cada operación.

---

## 🎯 Enfoque

**Red Team puro** — emulación de adversarios reales (APT29, APT41, APT28, Lazarus, APT10) con técnicas aplicables en engagements profesionales 2024-2026.

- Exploits construidos manualmente cuando los frameworks fallan
- C2 con Sliver (open source, equivalente a Cobalt Strike)
- Documentación de vulnerabilidades bloqueadas (comportamiento real en entornos modernos)
- Perspectiva Blue Team en cada lab (detección, Event IDs, reglas SIGMA)

---

## 🏗️ Infraestructura

Entornos propios desplegados en **VirtualBox** — control total sobre vectores y configuración.

### Red NAT — LabRedTeam (10.0.2.0/24)

| Host | SO | IP | Rol |
|------|----|----|-----|
| DC-01 | Windows Server 2022 | `10.0.2.10` | Domain Controller + ADCS |
| WKSTN-01 | Windows 11 Enterprise | `10.0.2.8` | Workstation corporativa |
| PROD | Ubuntu 22.04 LTS | `10.0.2.200` | Servidor producción (Webmin) |
| Kali | Kali Linux 2026.1 | `10.0.2.9` | Máquina operadora (compartida) |

### Red NAT — LabInternal (10.0.3.0/24)

| Host | SO | IP | Rol |
|------|----|----|-----|
| PROD | Ubuntu 22.04 LTS | `10.0.3.200` | Pivote hacia red interna |
| GIT | Ubuntu 22.04 LTS | `10.0.3.150` | Servidor Git interno |
| PC-01 | Windows 11 Enterprise | `10.0.3.7` | Endpoint Windows interno |

- **Dominio:** `atackcorp.local`
- **CA:** `AtackCorp-CA` (ADCS — ESC1/ESC4/ESC8 configurados)
- **Kali compartida** entre todos los labs — arsenal instalado una vez

> 📄 Infraestructura completa: [LAB_INFRASTRUCTURE.md](./docs/LAB_INFRASTRUCTURE.md)

---

## 🛠️ Arsenal

| Categoría | Herramientas |
|-----------|-------------|
| **C2** | Sliver v1.7.3, Havoc C2 (Phase-03) |
| **ADCS Abuse** | Certipy v5.0.4 |
| **Enumeración AD** | BloodHound, PowerView, enum4linux-ng |
| **Kerberos** | Impacket, Kerbrute, Rubeus |
| **Pivoting** | Ligolo-ng v0.7.5 |
| **Acceso remoto** | Evil-WinRM, NetExec |
| **Coerción NTLM** | PetitPotam, Coercer, PrinterBug |
| **Post-Explotación** | WinPEAS, LinPEAS, PrivescCheck |
| **Cracking** | Hashcat, John the Ripper |
| **Escaneo** | Nmap, Gobuster, Feroxbuster |

> 📄 Arsenal completo + setup: [tooling/arsenal_setup.sh](./tooling/arsenal_setup.sh) | [ARSENAL.md](./docs/ARSENAL.md)

---

## 🗺️ Roadmap v2.0

> 📐 Diseño completo, principios pedagógicos y coverage matrix: [DESIGN.md](./DESIGN.md)

### 🟢 Phase-01 — Fundamentos AD

| # | Operación | Adversario | Técnicas | Estado |
|---|-----------|-----------|---------|--------|
| 01 | [GHOST FOREST](./Phase-01-Fundamentals/Lab-01-Ghost-Forest/) | APT29 | AS-REP Roasting, Kerberoasting, Delegation, GPO/ACL Abuse, BloodHound, C2 | ✅ Completado |
| 02 | [SILENT BRIDGE](./Phase-01-Fundamentals/Lab-02-Silent-Bridge/) | APT41 | CVE-2019-12840, Ligolo-ng, Git history, relay C2 | ✅ Completado |
| 03 | [DARK GATE](./Phase-01-Fundamentals/Lab-03-Dark-Gate/) | APT29 | ADCS ESC1/ESC4/ESC8, Certipy, cert persistence | ✅ Completado |

### 🟡 Phase-02 — AD Avanzado

| # | Operación | Adversario | Técnicas | Estado |
|---|-----------|-----------|---------|--------|
| 04 | [IRON FOREST](./Phase-02-Post-Exploitation/Lab-04-Iron-Forest/) | APT28 | WriteDACL, ForceChangePassword, Overpass-the-Hash, credential hunting | ⏳ Pendiente |
| 05 | [SILVER CHAIN](./Phase-02-Post-Exploitation/Lab-05-Silver-Chain/) | APT28 | RBCD, Shadow Credentials, Silver Ticket, Diamond Ticket | ⏳ Pendiente |
| 06 | [BLACK POLICY](./Phase-02-Post-Exploitation/Lab-06-Black-Policy/) | APT28 | SID History, ExtraSids, Cross-Forest Trust | ⏳ Pendiente |
| 07 | [SHADOW VAULT](./Phase-02-Post-Exploitation/Lab-07-Shadow-Vault/) | APT28 | LAPS abuse, DPAPI, Shadow Credentials, LSASS alternativo | ⏳ Pendiente |

### 🔴 Phase-03 — Red Team Operations

| # | Operación | Adversario | Técnicas | Estado |
|---|-----------|-----------|---------|--------|
| 08 | [GHOST SIGNAL](./Phase-03-Red-Team-Operations/Lab-08-Ghost-Signals/) | Lazarus | AMSI bypass, process injection, direct syscalls, PE evasion | ⏳ Pendiente |
| 09 | [FIRST CONTACT](./Phase-03-Red-Team-Operations/Lab-09-First-Contact/) | Lazarus | Password spraying, phishing HTML smuggling, VBA macros | ⏳ Pendiente |
| 10 | [DARK CURRENT](./Phase-03-Red-Team-Operations/Lab-10-Dark-Current/) | Lazarus | Havoc C2, sleep obfuscation, BOFs, ETW patching | ⏳ Pendiente |
| 11 | [DEEP HOLO](./Phase-03-Red-Team-Operations/Lab-11-Deep-Holo/) | Lazarus | C2 infraestructura, redirectors, domain fronting | ⏳ Pendiente |

### 🏴 Phase-04 — Enterprise Simulation

| # | Operación | Adversario | Técnicas | Estado |
|---|-----------|-----------|---------|--------|
| 12 | [RED DANTE](./Phase-04-Enterprise-Simulation/Lab-12-Red-Dante/) | APT10 | Red masiva heterogénea, persistencia, exfiltración | ⏳ Pendiente |
| 13 | [DEEP WATER](./Phase-04-Enterprise-Simulation/Lab-13-Deep-Water/) | APT10 | Forest Trusts avanzados, CRTO preparation | ⏳ Pendiente |
| 14 | [AZURE BREACH](./Phase-04-Enterprise-Simulation/Lab-14-Azure-Breach/) | APT10 | Azure AD/Entra ID, PRT theft, hybrid attacks | ⏳ Pendiente |
| 15 | [OPERATION ZEPHYR](./Phase-04-Enterprise-Simulation/Lab-15-Operation-Zephyr/) | APT10 | Forest Trusts, CRTO exam preparation | ⏳ Pendiente |

---

## 📋 Próximos pasos

- **Lab-04 IRON FOREST** — WriteDACL, ForceChangePassword, credential hunting
- **Lab-07 SHADOW VAULT** (nuevo) — LAPS, DPAPI, Shadow Credentials
- **Lab-09 FIRST CONTACT** (nuevo) — Initial Access real sin credenciales previas
- **Lab-13 AZURE BREACH** (nuevo) — Azure AD/Entra ID hybrid attacks

> 📐 Ver [DESIGN.md](./DESIGN.md) para el diseño completo del Roadmap v2.0

---

## 📂 Estructura del repositorio

```
Red-Team_Labs/
├── tooling/                        ← utilidades del operador (Kali)
│   ├── arsenal_setup.sh            ← instala todo el arsenal en Kali
│   ├── lab_start.sh                ← arranca entorno de un lab
│   ├── lab_stop.sh                 ← limpia entre labs
│   └── kali_network_check.sh       ← diagnóstico de red
├── docs/                           ← documentación global
│   ├── ARSENAL.md
│   ├── CHANGELOG.md
│   ├── DETECTION_RULES.md
│   ├── LAB_INFRASTRUCTURE.md
│   ├── MITRE_MAPPING.md
│   ├── OPSEC_NOTES.md
│   ├── PROGRESS.md
│   └── WRITEUP_TEMPLATE.md
├── Phase-01-Fundamentals/
│   ├── Lab-01-Ghost-Forest/            ✅ GHOST FOREST (APT29)
│   ├── Lab-02-Silent-Bridge/           ✅ SILENT BRIDGE (APT41)
│   └── Lab-03-Dark-Gate/               ✅ DARK GATE (APT29)
├── Phase-02-Post-Exploitation/
├── Phase-02-Post-Exploitation/
│   ├── Lab-04 a Lab-07-Shadow-Vault
├── Phase-03-Red-Team-Operations/
├── Phase-04-Enterprise-Simulation/
└── setup/                          ← aprovisionamiento del dominio (DC-01)
    └── provisioning/               ← PowerShell scripts para DC-01
```

Cada lab sigue la estructura:
```
Lab-XX/
├── OPERATION_NAME.md       ← plan de operación + adversario
├── README.md               ← índice + attack path + estado
├── docs/                   ← writeups por fase
├── screenshots/            ← evidencias organizadas por fase
├── setup/                  ← scripts de aprovisionamiento
├── loot/                   ← hashes y credenciales obtenidas
└── nmap/                   ← outputs de escaneo
```

---

## 📊 Documentación global

| Documento | Descripción |
|-----------|-------------|
| [PROGRESS.md](./docs/PROGRESS.md) | Diario de sesiones, horas y técnicas dominadas |
| [MITRE_MAPPING.md](./docs/MITRE_MAPPING.md) | Mapeo completo de TTPs por adversario y lab |
| [ARSENAL.md](./docs/ARSENAL.md) | Arsenal de herramientas con referencia por lab |
| [CHANGELOG.md](./docs/CHANGELOG.md) | Registro de cambios del repositorio |
| [DETECTION_RULES.md](./docs/DETECTION_RULES.md) | Event IDs y reglas SIGMA consolidadas |
| [OPSEC_NOTES.md](./docs/OPSEC_NOTES.md) | Notas de OPSEC transversales |
| [LAB_INFRASTRUCTURE.md](./docs/LAB_INFRASTRUCTURE.md) | Entorno VirtualBox + scripts de aprovisionamiento |
| [WRITEUP_TEMPLATE.md](./docs/WRITEUP_TEMPLATE.md) | Plantilla estándar para writeups |
| [DESIGN.md](./DESIGN.md) | Roadmap v2.0 — principios de diseño, coverage matrix, crown jewels |

---

## 📫 Contacto

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Adrián%20Camacho-0077B5?logo=linkedin)](https://www.linkedin.com/in/adrian-camacho-mora/)
[![TryHackMe](https://img.shields.io/badge/TryHackMe-sapodos-212C42?logo=tryhackme)](https://tryhackme.com/p/sapodos)