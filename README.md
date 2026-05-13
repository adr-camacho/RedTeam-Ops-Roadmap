# 🚩 Red Team Ops & CRTO Preparation Path

[![Status](https://img.shields.io/badge/Status-In%20Progress-orange)](https://github.com/adr-camacho/RedTeam-Ops-Roadmap)
[![Domain](https://img.shields.io/badge/Domain-Active%20Directory%20%7C%20Red%20Team-red)](https://github.com/adr-camacho/RedTeam-Ops-Roadmap)
[![C2](https://img.shields.io/badge/C2-Sliver%20%7C%20Havoc-blueviolet)](https://github.com/adr-camacho/RedTeam-Ops-Roadmap)
[![MITRE](https://img.shields.io/badge/Framework-MITRE%20ATT%26CK%20v14-red)](./MITRE_MAPPING.md)
[![Labs](https://img.shields.io/badge/Labs-1%2F12%20Completados-green)](./PROGRESS.md)

Este repositorio documenta el proceso completo de preparación para la certificación **CRTO (Certified Red Team Operator)**, incluyendo infraestructura de laboratorio propia, metodologías de ataque sobre **Active Directory** y writeups técnicos con perspectiva de detección (Blue Team).

El enfoque principal es la simulación de adversarios reales mediante **C2 Frameworks modernos y Open Source**, profundizando en el funcionamiento interno de cada técnica en lugar de limitarse a su ejecución mecánica.

---

## 🎯 Objetivo

Dominar las tácticas de post-explotación, movimiento lateral y evasión de defensas propias del CRTO, replicando las capacidades de Cobalt Strike mediante frameworks abiertos como **Sliver** y **Havoc C2**, y documentando cada técnica tanto desde la perspectiva ofensiva como defensiva.

**Adversario simulado:** APT29 (Cozy Bear) — Actor de estado con especialización en AD y evasión de defensas. Ver [MITRE_MAPPING.md](./MITRE_MAPPING.md) para el mapeo completo de TTPs.

---

## 🏗️ Infraestructura del Laboratorio

Entorno propio desplegado en **VirtualBox** simulando una empresa mediana con Active Directory, SQL Server, IIS y shares corporativos. Red NAT aislada para evitar exposición de tráfico sensible.

| Host | Sistema Operativo | IP | Rol |
|------|------------------|----|-----|
| DC-01 | Windows Server 2022 Standard Evaluation | `10.0.2.10` | Domain Controller |
| WKSTN-01 | Windows 11 Enterprise Evaluation | `10.0.2.8` | Workstation corporativa |
| Kali | Kali Linux 2026.1 | `10.0.2.9` | Máquina atacante |

- **Dominio:** `atackcorp.local`
- **Red:** NAT Network `LabRedTeam` — Segmento `10.0.2.0/24`
- **Vectores preconfigurados:** AS-REP Roasting, Kerberoasting, ACL Abuse, Unconstrained/Constrained Delegation, GPO Abuse, xp_cmdshell, SMB Null Session, Unquoted Service Path, Token Impersonation

> 📄 Documentación completa del entorno y scripts de aprovisionamiento: [LAB_INFRASTRUCTURE.md](./LAB_INFRASTRUCTURE.md)

---

## 🛠️ Stack Tecnológico

| Categoría | Herramientas |
|-----------|-------------|
| **C2 Frameworks** | Sliver (BishopFox), Havoc C2 |
| **Enumeración AD** | BloodHound, PowerView, Adalanche, enum4linux-ng |
| **Ataques Kerberos** | Rubeus, Impacket, Kerbrute |
| **Cracking** | Hashcat, John the Ripper |
| **Pivoting** | Ligolo-ng, Chisel |
| **Post-Explotación** | Evil-WinRM, CrackMapExec, Metasploit |
| **Evasión** | AMSI Bypass, Donut, mingw-w64 |
| **Escaneo** | Nmap, Masscan, Gobuster, Feroxbuster |

> 📄 Lista completa con comandos de instalación y referencia por lab: [ARSENAL.md](./ARSENAL.md)

---

## 🗺️ Roadmap de Operaciones

> ⚠️ **Todos los labs son entornos propios** desplegados en VirtualBox. Cada escenario replica las técnicas y configuraciones de los labs de referencia (THM, HTB) pero sobre infraestructura construida y aprovisionada manualmente, lo que permite un control total sobre los vectores de ataque y una comprensión más profunda del entorno.

### 🟢 Fase 1 — Fundamentos y Pivotaje

| # | Lab | Referencia | Técnicas principales | Estado |
|---|-----|-----------|---------------------|--------|
| 01 | [Attacktive Directory](./Phase-01-Fundamentals/Lab-01-Attacktive-Directory/) | Lab propio (ref. THM) | AS-REP Roasting, Kerberoasting, DCSync, Pass-the-Hash, C2 Sliver | ✅ Completado |
| 02 | Wreath | Lab propio (ref. THM) | Pivoting con Ligolo-ng, evasión de segmentación | ⏳ Pendiente |
| 03 | Gatekeeper | Lab propio (ref. THM) | Buffer Overflow, explotación de servicios | ⏳ Pendiente |

### 🟡 Fase 2 — Post-Explotación y Abuso de AD

| # | Lab | Referencia | Técnicas principales | Estado |
|---|-----|-----------|---------------------|--------|
| 04 | Forest | Lab propio (ref. HTB) | ACL Abuse, DCSync, Pass-the-Hash, Golden Ticket | ⏳ Pendiente |
| 05 | Monteverde | Lab propio (ref. HTB) | Azure AD, Cloud-to-OnPremise | ⏳ Pendiente |
| 06 | Support | Lab propio (ref. HTB) | Memory dumps, extracción de secretos | ⏳ Pendiente |

### 🔴 Fase 3 — Red Team & Evasión de Defensas

| # | Lab | Referencia | Técnicas principales | Estado |
|---|-----|-----------|---------------------|--------|
| 07 | Red Team Pathway | Lab propio (ref. THM) | C2 infrastructure, EDR/AMSI evasion | ⏳ Pendiente |
| 08 | AD Enum & Attacks | Lab propio (ref. HTB Academy) | BloodHound avanzado, Attack Paths, GPO Abuse | ⏳ Pendiente |
| 09 | Holo | Lab propio (ref. THM) | Simulación corporativa completa, pivoting multicapa | ⏳ Pendiente |

### 🏴 Fase 4 — Simulación de Infraestructura Real

| # | Lab | Referencia | Técnicas principales | Estado |
|---|-----|-----------|---------------------|--------|
| 10 | Dante | Lab propio (ref. HTB Pro Lab) | Red masiva mixta, persistencia, exfiltración | ⏳ Pendiente |
| 11 | Offshore | Lab propio (ref. HTB Pro Lab) | Escenario espejo del examen CRTO | ⏳ Pendiente |
| 12 | Zephyr | Lab propio (ref. HTB Pro Lab) | Forest Trusts, técnicas modernas Red Team | ⏳ Pendiente |

---

## 📂 Metodología de Documentación

Cada laboratorio sigue una estructura estandarizada:

```
Phase-XX-Nombre/
└── Lab-XX-Nombre/
    ├── docs/
    │   ├── infrastructure_setup.md   # Configuración del entorno y vectores inyectados
    │   ├── enumeration_log.md        # Bitácora de enumeración
    │   ├── exploitation.md           # Comandos y razonamiento técnico
    │   ├── post-exploitation.md      # Post-explotación y movimiento lateral
    │   ├── lateral_movement.md       # Movimiento lateral y C2
    │   ├── privilege_escalation.md   # Escalada de privilegios
    │   ├── persistence.md            # Persistencia y Golden Ticket
    │   └── objective_completion.md   # Objetivo final y resumen
    ├── loot/                         # Hashes, wordlists y credenciales obtenidas
    ├── nmap/                         # Outputs de escaneo (.nmap, .gnmap, .xml)
    ├── setup/                        # Scripts de aprovisionamiento de vulnerabilidades
    └── screenshots/                  # Evidencias visuales organizadas por fase
```

Cada writeup incluye:
1. **Summary:** Resumen ejecutivo orientado a negocio
2. **Attack Path:** Mapa visual del compromiso
3. **Exploitation:** Comandos con razonamiento técnico
4. **Detection:** Cómo detectar cada técnica (Event IDs, reglas SIGMA)

> 📄 Plantilla reutilizable para cada lab: [WRITEUP_TEMPLATE.md](./WRITEUP_TEMPLATE.md)

---

## 📊 Progreso y Documentos del Proyecto

| Documento | Descripción |
|-----------|-------------|
| [PROGRESS.md](./PROGRESS.md) | Diario de sesiones, horas invertidas y lecciones aprendidas |
| [ARSENAL.md](./ARSENAL.md) | Arsenal de herramientas instaladas con guía de uso |
| [LAB_INFRASTRUCTURE.md](./LAB_INFRASTRUCTURE.md) | Entorno vulnerable: software, scripts PowerShell y diagrama |
| [MITRE_MAPPING.md](./MITRE_MAPPING.md) | Mapeo de 39 técnicas ATT&CK a los 12 labs del roadmap |
| [WRITEUP_TEMPLATE.md](./WRITEUP_TEMPLATE.md) | Plantilla estándar para writeups con sección Blue Team |

---

## 📫 Contacto

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Adrián%20Camacho-0077B5?logo=linkedin)](https://www.linkedin.com/in/adrian-camacho-mora/)
[![TryHackMe](https://img.shields.io/badge/TryHackMe-sapodos-212C42?logo=tryhackme)](https://tryhackme.com/p/sapodos)