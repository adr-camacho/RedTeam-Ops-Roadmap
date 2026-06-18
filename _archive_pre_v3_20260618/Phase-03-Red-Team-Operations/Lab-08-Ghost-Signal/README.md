# 🔴 Lab-08: GHOST SIGNAL

![Status](https://img.shields.io/badge/Status-In%20Progress-orange)
![Phase](https://img.shields.io/badge/Phase-03-red)
![Adversary](https://img.shields.io/badge/Adversary-Lazarus%20Group-darkred)

> 🔄 **En progreso** — Phase-03: Red Team Operations. Primer lab con Defender activo sin Tamper Protection deshabilitado.

---

## 🎯 Resumen

| Campo | Detalle |
|-------|---------|
| **Nombre de operación** | GHOST SIGNAL |
| **Adversario simulado** | Lazarus Group (Corea del Norte — RGB) |
| **Credencial inicial** | `helpdesk.ruiz:Helpdesk2024!` |
| **Técnicas principales** | AMSI Bypass, Process Injection, Direct Syscalls, PE Evasion, Sleep Obfuscation |
| **Estado** | 🔄 En progreso |
| **Diferencial** | Defender activo — Tamper Protection ON — sin deshabilitar protecciones |

---

## 🏗️ Infraestructura

| VM | IP | Rol |
|----|----|----|
| DC-01 | 10.0.2.10 | atackcorp.local — Domain Controller |
| WKSTN-01 | 10.0.2.8 | Workstation — Defender activo — objetivo principal |
| Kali | 10.0.2.9 | Atacante |

**Defender estado:** Activo con Tamper Protection ON  
**Diferencial vs Labs anteriores:** No se deshabilitará Defender en ningún momento. El objetivo es operar sin ser detectado.

---

## 📋 Fases planificadas

| Fase | Técnica | MITRE ID | Estado |
|------|---------|----------|--------|
| 01 | Reconocimiento con Defender activo | T1046, T1087 | ⏳ Pendiente |
| 02 | AMSI Bypass in-memory | T1562.001 | ⏳ Pendiente |
| 03 | Process Injection (shellcode en proceso legítimo) | T1055 | ⏳ Pendiente |
| 04 | Direct Syscalls + PE Evasion | T1055.001, T1027 | ⏳ Pendiente |
| 05 | C2 Sliver con sleep obfuscation + beacon in-memory | T1071.001, T1027.002 | ⏳ Pendiente |
| 06 | OPSEC Cleanup sin rastros en Event Log | T1070 | ⏳ Pendiente |

---

## 🔑 Crown Jewels

| Asset | Ubicación | Condición |
|-------|-----------|-----------|
| Beacon in-memory persistente | WKSTN-01 (memoria) | Sin artefactos en disco |
| Credenciales LSASS in-memory | WKSTN-01 | Extracción sin MiniDump |
| Escalada local sin PPL bypass | WKSTN-01 | Solo via técnicas in-memory |

---

## 🛠️ Herramientas planificadas

| Herramienta | Técnica | Nota |
|-------------|---------|------|
| Custom AMSI bypass (PS/C#) | AMSI Bypass | In-memory — no tocar disco |
| Donut / sRDI | Shellcode generation | PE → shellcode |
| Sliver BOFs | Process Injection | Beacon Object Files |
| SysWhispers3 / HellsGate | Direct Syscalls | Evadir hooks de EDR |
| Sliver sleep obfuscation | C2 evasion | Heap encryption durante sleep |

---

## 📂 Documentación

- `docs/theory/tradecraft.md` — Teoría AMSI, Process Injection, Syscalls, EDR internals
- `docs/execution/` — Comandos por fase (pendiente ejecución)

---

## 🔗 Adversary Profile — Lazarus Group

| Campo | Detalle |
|-------|---------|
| **Nombre** | Lazarus Group / Hidden Cobra / ZINC |
| **Origen** | Corea del Norte — RGB (Reconnaissance General Bureau) |
| **Motivación** | Espionaje · Sabotaje · Robo financiero (crypto) |
| **TTPs características** | Spear phishing · Custom malware · Living off the land · EDR evasion avanzada |
| **Campañas conocidas** | WannaCry 2017 · Sony Pictures 2014 · Bangladesh Bank Heist 2016 · Operation Dream Job |
| **MITRE Group ID** | G0032 |

---

*GHOST SIGNAL — Adrián Camacho | Phase-03 Red Team Operations | Solo uso educativo*