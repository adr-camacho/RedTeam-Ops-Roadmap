# 🔴 Lab-03: Gatekeeper — Buffer Overflow x86

![Status](https://img.shields.io/badge/Status-In%20Progress-orange)
![Platform](https://img.shields.io/badge/Platform-Lab%20Propio%20(ref.%20THM)-red)
![Phase](https://img.shields.io/badge/Phase-01%20Fundamentals-blue)
![Adversary](https://img.shields.io/badge/Adversary-FIN7%20Carbanak-darkred)
![Focus](https://img.shields.io/badge/Focus-Buffer%20Overflow%20%7C%20x86%20Exploit%20Dev-purple)
![MITRE](https://img.shields.io/badge/MITRE%20ATT%26CK-T1203%20%7C%20T1574%20%7C%20T1543-red)

---

## 🎯 Resumen Ejecutivo

Operación de explotación de servicio Windows vulnerable mediante **Buffer Overflow x86**, emulando las TTPs de **FIN7 (Carbanak)**. Se desarrolla un exploit BOF propio desde cero — fuzzing, offset, badchars, JMP ESP y shellcode — contra el servicio `Gatekeeper` expuesto en red. Post-explotación incluye escalada a SYSTEM, C2 Sliver y persistencia via servicio Windows.

| Campo | Detalle |
|-------|---------|
| **Nombre de operación** | DARK GATE |
| **Adversario simulado** | FIN7 (Carbanak) — cibercrimen financiero |
| **Vector de entrada** | Buffer Overflow en servicio Gatekeeper `:31337` |
| **Técnica principal** | Exploit development x86 — EIP control + JMP ESP |
| **C2 final** | Sliver beacon HTTPS en GATE-01 |
| **Objetivo primario** | RCE + SYSTEM en GATE-01 |

---

## 🗺️ Topología de Red

```
[Kali 10.0.2.9] ──── LabRedTeam ──── [GATE-01 Windows 10.0.2.X]
                                       Servicio Gatekeeper :31337
                                       [objetivo BOF]
```

---

## 🔗 Attack Path

| # | Fase | Técnica | ID MITRE | Herramienta |
|---|------|---------|----------|-------------|
| 1 | Reconnaissance | Network Service Discovery | T1046 | Nmap |
| 2 | BOF Development | Exploit Development | T1588.006 | Python + Immunity |
| 3 | Initial Access | Exploitation for Client Execution | T1203 | Python exploit |
| 4 | Privilege Escalation | Token Impersonation / Service | T1134.001 | PrintSpoofer |
| 5 | C2 | Application Layer Protocol HTTPS | T1071.001 | Sliver |
| 6 | Persistence | Create Windows Service | T1543.003 | sc create |

---

## 🛠️ Stack Tecnológico

| Categoría | Herramienta |
|-----------|-------------|
| **Exploit Dev** | Python 3, Immunity Debugger, mona.py |
| **Fuzzing** | Script Python custom |
| **Shellcode** | msfvenom |
| **Escalada** | PrintSpoofer / GodPotato |
| **C2** | Sliver (BishopFox) |
| **Escaneo** | Nmap |

---

## 📂 Documentación

| Documento | Descripción | Estado |
|-----------|-------------|--------|
| [OPERATION_DARK_GATE.md](./OPERATION_DARK_GATE.md) | Plan completo de la operación | ✅ |
| [infrastructure_setup.md](./docs/infrastructure_setup.md) | Entorno + servicio Gatekeeper | ⏳ |
| [enumeration_log.md](./docs/enumeration_log.md) | Fase 1 — Reconnaissance | ⏳ |
| [bof_development.md](./docs/bof_development.md) | Fase 2 — Desarrollo del exploit BOF | ⏳ |
| [exploitation.md](./docs/exploitation.md) | Fase 3 — Explotación en producción | ⏳ |
| [privilege_escalation.md](./docs/privilege_escalation.md) | Fase 4 — Escalada a SYSTEM | ⏳ |
| [c2_sliver.md](./docs/c2_sliver.md) | Fase 5 — Beacon Sliver | ⏳ |
| [persistence.md](./docs/persistence.md) | Fase 6 — Persistencia + objetivo | ⏳ |
| [lessons_learned.md](./docs/lessons_learned.md) | Post-operación | ⏳ |
| [mitigations.md](./docs/mitigations.md) | Blue Team | ⏳ |

---

## 🔵 Detección (Blue Team)

| Indicador | Fuente | Técnica |
|-----------|--------|---------|
| Payload > 1000 bytes en puerto :31337 | Network/IDS | T1203 — BOF |
| Application Error gatekeeper.exe (Event 1000) | Windows Event Log | T1203 — Crash |
| Conexión saliente desde gatekeeper.exe | Sysmon Event 3 | T1071.001 — C2 |
| Nuevo servicio Windows (Event 7045) | System Event Log | T1543.003 — Persistence |
| `reg save HKLM\SAM` | Sysmon Event 1 | T1003.002 — Credential Dump |

---

*Operación DARK GATE — Adrián Camacho*  
*Entorno de laboratorio — Únicamente con fines educativos*