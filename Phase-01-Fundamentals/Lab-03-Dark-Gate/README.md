# 🔴 Lab-03: ADCS Abuse — Dark Gate

![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![Platform](https://img.shields.io/badge/Platform-Lab%20Propio%20(DC--01%20reutilizado)-red)
![Phase](https://img.shields.io/badge/Phase-01%20Fundamentals-blue)
![Adversary](https://img.shields.io/badge/Adversary-APT29%20Cozy%20Bear-darkred)
![Focus](https://img.shields.io/badge/Focus-ADCS%20Abuse%20%7C%20ESC1%20%7C%20ESC4%20%7C%20ESC8-purple)
![MITRE](https://img.shields.io/badge/MITRE%20ATT%26CK-T1649%20%7C%20T1557%20%7C%20T1222-red)

---

## 🎯 Resumen Ejecutivo

Operación de abuso de **Active Directory Certificate Services (ADCS)** emulando las TTPs de **APT29 (Cozy Bear)**. Se explotan tres vectores ESC1, ESC4 y ESC8 para escalar desde usuario de dominio hasta Domain Admin y establecer persistencia via certificado que sobrevive a la rotación de contraseñas.

| Campo | Detalle |
|-------|---------|
| **Operación** | DARK GATE |
| **Adversario** | APT29 (Cozy Bear) — SVR Rusia |
| **CA objetivo** | `AtackCorp-CA` @ DC-01 (10.0.2.10) |
| **Herramienta** | Certipy v5.0.4 |
| **Beacon C2** | `CLINICAL_CHAIRMAN` (4d1146b0) |
| **Hash DA** | `bc3abc2e0673a58e9e559d415b56d69d` (post-rotación) |

---

## 🗺️ Topología

```
[Kali 10.0.2.9] ──── LabRedTeam ──── [DC-01 10.0.2.10]
 Certipy v5.0.4                        AtackCorp-CA
 Impacket / PetitPotam                 http://10.0.2.10/certsrv/
 Sliver C2                             Plantilla VulnerableUser (ESC1)
```

---

## 🔐 Vulnerabilidades Configuradas

| ESC | Tipo | Vector | Usuario | Estado |
|-----|------|--------|---------|--------|
| **ESC1** | Enrollee Supplies Subject | `VulnerableUser` — SAN arbitrario | Domain Users | ✅ Explotado |
| **ESC4** | Write on Template | `fin.garcia` GenericWrite + WriteDacl | fin.garcia | ✅ Explotado |
| **ESC8** | NTLM Relay to HTTP | `/certsrv/` HTTP — KB5005413 bloquea relay | Cualquier equipo | ✅ Identificado |

---

## 🔗 Attack Path

| # | Fase | Técnica | ID MITRE | Estado |
|---|------|---------|----------|--------|
| 1 | Reconnaissance | ADCS Enumeration (Certipy find) | T1046 | ✅ |
| 2 | ESC1 Exploitation | cert como Administrador → hash DA | T1649 | ✅ |
| 3 | ESC4 Exploitation | fin.garcia modifica plantilla → cert DA | T1222+T1649 | ✅ |
| 4 | ESC8 — NTLM Relay | Identificado — bloqueado KB5005413 WS2022 | T1557+T1187 | ✅ |
| 5 | C2 Establishment | CLINICAL_CHAIRMAN — DC-01 Administrador | T1071.001 | ✅ |
| 6 | Persistence | Cert válido post-rotación contraseña | T1649 | ✅ |

---

## 🛠️ Stack Tecnológico

| Herramienta | Versión | Uso |
|-------------|---------|-----|
| Certipy | v5.0.4 | ADCS enumeration + exploitation |
| impacket-ntlmrelayx | 0.14.0 | ESC8 relay |
| PetitPotam | — | NTLM coercion |
| Evil-WinRM | v3.9 | Lateral movement |
| Sliver | v1.7.3 | C2 beacon |

---

## 📂 Documentación

| Documento | Descripción | Estado |
|-----------|-------------|--------|
| [OPERATION_DARK_GATE.md](./OPERATION_DARK_GATE.md) | Plan completo — todas las fases | ✅ |
| [infrastructure_setup.md](./docs/infrastructure_setup.md) | ADCS setup + ESC1/ESC4/ESC8 | ✅ |
| [enumeration_log.md](./docs/enumeration_log.md) | Fase 1 — Certipy find | ✅ |
| [exploitation_esc1.md](./docs/exploitation_esc1.md) | Fase 2 — ESC1 kill chain | ✅ |
| [exploitation_esc4.md](./docs/exploitation_esc4.md) | Fase 3 — ESC4 + restauración OPSEC | ✅ |
| [exploitation_esc8.md](./docs/exploitation_esc8.md) | Fase 4 — ESC8 identificado + KB5005413 | ✅ |
| [c2_sliver.md](./docs/c2_sliver.md) | Fase 5 — CLINICAL_CHAIRMAN + 3 beacons | ✅ |
| [persistence.md](./docs/persistence.md) | Fase 6 — cert persistence + kill chain | ✅ |
| [lessons_learned.md](./docs/lessons_learned.md) | 10 lecciones + tabla ESC1-ESC11 | ✅ |
| [mitigations.md](./docs/mitigations.md) | Blue Team + SIGMA + CRL/OCSP | ✅ |

---

## 🔵 Detección (Blue Team)

| Indicador | Fuente | Event ID |
|-----------|--------|----------|
| Cert con SAN de Administrador | CA Audit Log | 4886 + 4887 |
| Autenticación PKINIT con cert | DC Security Log | 4768 |
| Modificación de plantilla | DC Security Log | 4899 |
| NTLM relay hacia /certsrv/ | Network IDS | — |
| Beacon outbound desde DC | Sysmon Event 3 | — |

---

## 📋 Setup

```powershell
# En DC-01 como Administrador
.\setup\Setup-Lab03-DarkGate.ps1
```

---

*Operación DARK GATE — Adrián Camacho | Mayo 2026*