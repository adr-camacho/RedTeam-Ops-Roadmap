<div align="center">

```
██████╗ ███████╗██████╗     ████████╗███████╗ █████╗ ███╗   ███╗
██╔══██╗██╔════╝██╔══██╗    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
██████╔╝█████╗  ██║  ██║       ██║   █████╗  ███████║██╔████╔██║
██╔══██╗██╔══╝  ██║  ██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
██║  ██║███████╗██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚══════╝╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
```

# 🎯 RedTeam Ops Roadmap

**Entorno de laboratorio progresivo para operaciones ofensivas reales**  
*De fundamentos a Advanced Persistent Threat — Aprende haciendo, no leyendo*

[![Stars](https://img.shields.io/github/stars/adr-camacho/RedTeam-Ops-Roadmap?style=for-the-badge&color=red&labelColor=1a1a1a)](https://github.com/adr-camacho/RedTeam-Ops-Roadmap/stargazers)
[![Forks](https://img.shields.io/github/forks/adr-camacho/RedTeam-Ops-Roadmap?style=for-the-badge&color=orange&labelColor=1a1a1a)](https://github.com/adr-camacho/RedTeam-Ops-Roadmap/network)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge&labelColor=1a1a1a)](LICENSE)
[![Labs](https://img.shields.io/badge/LABS-7%20activos-brightgreen?style=for-the-badge&labelColor=1a1a1a)]()
[![Status](https://img.shields.io/badge/status-EN%20DESARROLLO%20ACTIVO-red?style=for-the-badge&labelColor=1a1a1a)]()

</div>

---

## 📌 ¿Qué es esto?

Un roadmap **práctico y progresivo** de Red Team Operations construido sobre entornos virtualizados reales. No teoría. No CTFs simplificados. Operaciones reales contra infraestructura AD, evasión de EDR, movimiento lateral y simulación de APT.

Cada fase amplía la anterior. Cada lab tiene un objetivo de ataque claro, documentación de TTPs y lecciones aprendidas.

---

## 🗺️ Mapa de fases

```
PHASE-01 ──────────────────────────────────────────────── FUNDAMENTALS
│  Lab-01  Active Directory Basics & Initial Compromise
│  Lab-02  Lateral Movement & Pivoting  
│  Lab-03  [En desarrollo]
│
PHASE-02 ──────────────────────────────────────────────── INTERMEDIATE OPS  
│  Lab-04  [Próximamente]
│  Lab-05  [Próximamente]
│
PHASE-03 ──────────────────────────────────────────────── ADVANCED / APT SIM
│  Lab-06  [Próximamente]
│  Lab-07  Lazarus Group — Evasión de Defender / Syscalls directas
│
PHASE-04 ──────────────────────────────────────────────── RED TEAM OPS
         [En diseño]
```

---

## 🔬 Labs activos

### ☠️ Lab-01 — Operation Ghost Forest
> **Escenario:** Compromiso inicial de un entorno Active Directory corporativo

| Parámetro | Detalle |
|-----------|---------|
| 🎯 Objetivo | Domain Admin desde posición de usuario estándar |
| 🏗️ Infraestructura | DC Windows Server 2022 + 2 workstations |
| 🔗 Cadena de ataque | Enum → Kerberoasting → Delegation Abuse → DCSync |
| 📋 TTPs cubiertos | T1558.003, T1134.001, T1484, T1003.006 |
| ✅ Estado | **COMPLETADO** (Fases 1–13) |

**Técnicas cubiertas:**
- `AS-REP Roasting` / `Kerberoasting`
- `Unconstrained & Constrained Delegation`
- `ACL Abuse` (WriteDACL, GenericAll, GenericWrite)
- `GPO Abuse` para persistencia
- `BloodHound` para análisis de paths de ataque
- `DCSync` y volcado de credenciales

---

### 🔀 Lab-02 — Pivoting & Lateral Movement
> **Escenario:** Expansión de acceso a través de múltiples segmentos de red

| Parámetro | Detalle |
|-----------|---------|
| 🎯 Objetivo | Comprometer tercer segmento de red aislado |
| 🏗️ Infraestructura | 3 subnets segmentadas + firewall interno |
| 🔗 Cadena de ataque | Foothold → Pivote 1 → Pivote 2 → Crown Jewels |
| 📋 TTPs cubiertos | T1090, T1021, T1550 |
| 🔧 Estado | **EN MEJORA** (segundo pivote + evasión Defender) |

---

### 🕵️ Lab-07 — Lazarus Group TTPs (Phase-03)
> **Escenario:** Simulación de APT con evasión avanzada de EDR

| Parámetro | Detalle |
|-----------|---------|
| 🎯 Objetivo | Operar en entorno real sin desactivar Tamper Protection |
| 🛡️ Defensa activa | Windows Defender con Tamper Protection ON |
| 🔗 Técnicas | AMSI Bypass en memoria, Direct Syscalls, Process Injection |
| 📋 TTPs cubiertos | T1562.001, T1055, T1134, T1059.001 |
| 🔧 Estado | **EN DESARROLLO** |

---

## 🏗️ Arquitectura de laboratorio

```
                    ┌─────────────────────────────────┐
                    │      HOST (Hypervisor)           │
                    │   VMware / VirtualBox / Hyper-V  │
                    └──────────────┬──────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
     ┌────────▼──────┐   ┌─────────▼─────┐   ┌────────▼──────┐
     │  SEGMENTO A   │   │  SEGMENTO B   │   │  SEGMENTO C   │
     │  10.10.10.0/24│   │ 10.10.20.0/24 │   │ 10.10.30.0/24 │
     │               │   │               │   │               │
     │  DC-01        │   │  SRV-01       │   │  SRV-DB       │
     │  WKSTN-01     │   │  WKSTN-02     │   │  (Crown Jewel)│
     │  WKSTN-02     │   │               │   │               │
     └───────────────┘   └───────────────┘   └───────────────┘
              │
     ┌────────▼──────┐
     │   ATTACKER    │
     │  Kali Linux   │
     │  + Arsenal    │
     └───────────────┘
```

---

## ⚙️ Requisitos

```bash
# Hardware mínimo
RAM:  16 GB  (recomendado 32 GB para Phase-03)
CPU:  8 cores con soporte de virtualización (VT-x / AMD-V)
Disk: 200 GB libres (SSD recomendado)

# Software
Hypervisor:  VMware Workstation Pro / VirtualBox 7+
Attacker OS: Kali Linux 2024.x
Target OS:   Windows Server 2022 + Windows 10/11
```

---

## 🚀 Inicio rápido

```bash
# 1. Clonar el repositorio
git clone https://github.com/adr-camacho/RedTeam-Ops-Roadmap.git
cd RedTeam-Ops-Roadmap

# 2. Revisar la fase que te interesa
cd Phase-01-Fundamentals/Lab-01

# 3. Desplegar el lab (PowerShell como Administrador en el DC)
.\Setup-Lab01-GhostForest-v2.ps1

# 4. Configurar el arsenal en Kali
chmod +x arsenal_setup.sh && ./arsenal_setup.sh

# 5. Leer el README del lab y comenzar
cat README.md
```

---

## 🛠️ Arsenal incluido

| Categoría | Herramientas |
|-----------|-------------|
| **C2 Framework** | Cobalt Strike, Metasploit, Sliver |
| **Reconocimiento AD** | BloodHound (SharpHound v2.5.9), PowerView, ADRecon |
| **Credential Access** | Mimikatz, Rubeus, CrackMapExec, Impacket |
| **Evasión** | AMSI bypass en memoria, Direct Syscalls, PE stomping |
| **Pivoting** | Ligolo-ng, Chisel, SSHuttle |
| **Post-explotación** | SharpCollection, PrivescCheck, WinPEAS |

---

## 📚 Documentación por lab

```
Phase-01-Fundamentals/
├── Lab-01/
│   ├── README.md                    # Guía completa del lab
│   ├── OPERATION_GHOST_FOREST.md    # Narrative del ataque
│   ├── docs/
│   │   ├── delegation.md            # Técnicas de delegación
│   │   ├── gpo_abuse.md             # Abuso de GPOs
│   │   ├── acl_abuse.md             # Escalada por ACLs
│   │   └── bloodhound.md            # Uso de BloodHound
│   ├── lessons_learned.md           # Qué salió mal y qué funcionó
│   └── scripts/
│       ├── Setup-Lab01-GhostForest-v2.ps1
│       └── arsenal_setup.sh
└── Lab-02/
    └── README.md
```

---

## 📖 MITRE ATT&CK Coverage

| Táctica | Técnicas cubiertas |
|---------|-------------------|
| **Reconnaissance** | T1592, T1590 |
| **Initial Access** | T1078, T1566 |
| **Execution** | T1059.001, T1059.003 |
| **Persistence** | T1484.001, T1547 |
| **Privilege Escalation** | T1134.001, T1134.003 |
| **Defense Evasion** | T1562.001, T1055, T1070 |
| **Credential Access** | T1558.003, T1003.006, T1003.001 |
| **Lateral Movement** | T1021.002, T1550.002 |
| **Collection** | T1039, T1074 |
| **Command & Control** | T1090, T1071 |

---

## ⚠️ Disclaimer

> Este repositorio es **únicamente para fines educativos y de investigación en entornos controlados**.  
> Todo el contenido está diseñado para practicar en laboratorios virtuales propios.  
> El uso de estas técnicas en sistemas sin autorización explícita es **ilegal**.  
> El autor no se responsabiliza del uso indebido de este material.

---

## 📬 Contacto

<div align="center">

[![LinkedIn](https://img.shields.io/badge/LinkedIn-adr--camacho-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/adr-camacho)
[![GitHub](https://img.shields.io/badge/GitHub-adr--camacho-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/adr-camacho)

*Si esto te es útil, dale una ⭐ — ayuda a que más gente lo encuentre*

</div>

---

<div align="center">
<sub>Built with 🔴 for the red team community · Not for skids · RTFM</sub>
</div>