# 📋 Changelog — Red Team Ops Roadmap

> Registro de cambios estructurales del repositorio.
> Tipos: `ADD` | `UPDATE` | `FIX` | `REFACTOR` | `DOCS`

---

## [2026-05-21] — Roadmap v2.0 + Lab-01 Fases 11-13 completas + Tradecraft docs

### ADD
- `DESIGN.md` — Roadmap v2.0: filosofía, adversary emulation, crown jewels, coverage matrix CRTO (~98%)
- `Phase-02-Post-Exploitation/Lab-07-Shadow-Vault/` — LAPS, DPAPI, Shadow Credentials (nuevo)
- `Phase-03-Red-Team-Operations/Lab-09-First-Contact/` — Initial Access real: spraying, phishing (nuevo)
- `Phase-04-Enterprise-Simulation/Lab-14-Azure-Breach/` — Azure AD/Entra ID hybrid attacks (nuevo)
- `Lab-01-Ghost-Forest/docs/delegation.md` — Unconstrained + Constrained Delegation completo
- `Lab-01-Ghost-Forest/docs/gpo_abuse.md` — GPO Abuse con XML, SYSVOL, SIGMA
- `Lab-01-Ghost-Forest/docs/acl_abuse.md` — GenericWrite → Targeted Kerberoasting → DA
- `Lab-01-Ghost-Forest/docs/bloodhound.md` — Metodología BloodHound CE, python vs SharpHound
- `Lab-01-Ghost-Forest/docs/tradecraft.md` — Teoría profunda: Kerberos, Delegation, ACL, BloodHound, OPSEC
- `Lab-02-Silent-Bridge/docs/tradecraft.md` — Segmentación, CVE-2019-12840, Ligolo-ng, Git history
- `Lab-03-Dark-Gate/docs/tradecraft.md` — PKI/ADCS, PKINIT, ESC1/ESC4/ESC8, persistencia certs
- `tooling/arsenal_setup.sh` — SharpHound v2.5.9 via ZIP (fix: binario corrupto)
- `setup/provisioning/Setup-Lab01-GhostForest-v2.1.ps1` — OU IT, WinRM grupos, C:\Temp

### UPDATE
- `Lab-01-Ghost-Forest/docs/post_exploitation.md` — Fases 11-13 añadidas
- `Lab-01-Ghost-Forest/docs/lessons_learned.md` — +6 lecciones (L-14 a L-19)
- `Lab-01-Ghost-Forest/README.md` — Fases 11-13 en attack path, MITRE, credenciales
- `Lab-01-Ghost-Forest/OPERATION_GHOST_FOREST.md` — Fases 11-13 → ✅
- `docs/MITRE_MAPPING.md` — +8 técnicas Fases 11-13, adversarios v2.0
- `docs/LAB_INFRASTRUCTURE.md` — IPs corregidas (WKSTN-01: .8, Kali: .9), Finance2024!
- `docs/PROGRESS.md` — sesiones 11-13, +6 técnicas dominadas, 3/15 labs
- `README.md` — Roadmap v2.0 con 15 labs, links correctos, badge CRTO

### REFACTOR
- Numeración global labs: 15 labs con numeración secuencial sin duplicados
  Phase-03: Lab-08→09→10→11 | Phase-04: Lab-12→13→14→15
- `docs/OPSEC_NOTES.md` — añadidas secciones BloodHound, Delegation, GPO, ACL Abuse

---

## [2026-05-17] — Lab-03 DARK GATE completado + Arsenal Kali

### ADD
- `Lab-03-Dark-Gate/docs/infrastructure_setup.md` — ADCS setup + ESC1/ESC4/ESC8 con comandos reales
- `Lab-03-Dark-Gate/docs/enumeration_log.md` — Certipy find, ESC1/ESC8 identificados
- `Lab-03-Dark-Gate/docs/exploitation_esc1.md` — kill chain ESC1, hashes reales
- `Lab-03-Dark-Gate/docs/exploitation_esc4.md` — fin.garcia → plantilla modificada → DA
- `Lab-03-Dark-Gate/docs/exploitation_esc8.md` — relay identificado, KB5005413 documentado
- `Lab-03-Dark-Gate/docs/c2_sliver.md` — CLINICAL_CHAIRMAN, 3 beacons simultáneos
- `Lab-03-Dark-Gate/docs/persistence.md` — cert persistence post-rotación + kill chain completo
- `Lab-03-Dark-Gate/docs/lessons_learned.md` — 10 lecciones + tabla ESC1-ESC11
- `Lab-03-Dark-Gate/docs/mitigations.md` — mitigaciones + reglas SIGMA + CRL/OCSP
- `Lab-03-Dark-Gate/setup/Setup-Lab03-DarkGate.ps1` — script setup ADCS 4 bloques
- `Lab-03-Dark-Gate/screenshots/` — fases 1-6 con capturas reales
- `Phase-01-Fundamentals/Lab-01-Ghost-Forest/setup/Setup-Lab01-GhostForest-v2.ps1`
- `tooling/arsenal_setup.sh` — arsenal completo Kali (12 bloques)
- `tooling/lab_start.sh` — arranque rápido por lab
- `tooling/lab_stop.sh` — limpieza entre labs
- `tooling/kali_network_check.sh` — diagnóstico de red

### UPDATE
- `README.md` — giro Red Team puro, roadmap actualizado, Lab-03 ADCS, tooling/ y setup/provisioning/
- `docs/PROGRESS.md` — Lab-03 completado, sesiones 9-10, 19 técnicas dominadas
- `docs/CHANGELOG.md` — esta entrada
- `Lab-03-Dark-Gate/OPERATION_DARK_GATE.md` — plan actualizado con datos reales
- `Lab-03-Dark-Gate/README.md` — badges, attack path, stack tecnológico real

### FIX
- Certipy ESC4: añadir `WriteDacl + WriteProperty` (Certipy v5 requiere más que GenericWrite)
- Impacket conflicto pip vs apt: eliminar `/usr/local/lib/python3.13/dist-packages/impacket*`
- KB5005413: ESC8 relay SMB→HTTP bloqueado en WS2022 — documentado como comportamiento real

---

## [2026-05-16] — Lab-03 iniciado + reestructuración repo

### ADD
- `Lab-03-Dark-Gate/OPERATION_DARK_GATE.md` — plan operación APT29 ADCS (movido desde Phase-01 raíz)
- `Lab-03-Dark-Gate/README.md` — índice con vectores ESC1/ESC4/ESC8

### FIX
- `OPERATION_DARK_GATE.md` movido a `Lab-03-Dark-Gate/` (estaba en Phase-01 raíz)
- `SILENT_BRIDGE.md` → `OPERATION_SILENT_BRIDGE.md` (consistencia naming)
- `setup/provisioning/` → `setup/provisioning/` (typo corregido)
- `Lab-01/docs/README.md` → `Lab-01/README.md` (ubicación correcta)

---

## [2026-05-15] — Lab-02 SILENT BRIDGE completado — Fases 5-7

### ADD
- `Lab-02-Silent-Bridge/docs/post-exploitation.md` — Fase 5: lateral movement PC-01
- `Lab-02-Silent-Bridge/docs/c2_sliver.md` — Fase 6: beacon SUDDEN_COMMUNICATION relay PROD
- `Lab-02-Silent-Bridge/docs/persistence.md` — Fase 7: schtasks + Run Key + SAM dump
- `Lab-02-Silent-Bridge/docs/lessons_learned.md` — 14 lecciones, comparativa Lab-01 vs Lab-02
- `Lab-02-Silent-Bridge/docs/mitigations.md` — mitigaciones + reglas SIGMA
- Screenshots Fases 5-7
- `fase3-05-nmap-through-tunnel.png` — captura pendiente Fase 3

### UPDATE
- `docs/PROGRESS.md` — Lab-02 completado, sesiones 6-8
- `docs/MITRE_MAPPING.md` — Lab-02 técnicas ✅, T1003.001→T1003.002

### FIX
- Beacon v1 → v2: `listener_add` PROD como relay (PC-01 sin visibilidad hacia Kali)

---

## [2026-05-14] — Lab-02 SILENT BRIDGE — Fases 1-4

### ADD
- `Lab-02-Silent-Bridge/docs/enumeration_log.md` — Fases 1 y 4
- `Lab-02-Silent-Bridge/docs/exploitation.md` — CVE-2019-12840, exploit Python desde 46984.rb
- `Lab-02-Silent-Bridge/docs/pivoting.md` — Ligolo-ng v0.7.5

---

## [2026-05-13] — Lab-02 iniciado + reestructuración raíz

### ADD
- `Lab-02-Silent-Bridge/` — estructura completa + OPERATION_SILENT_BRIDGE.md
- `docs/CHANGELOG.md`, `docs/OPSEC_NOTES.md`, `docs/DETECTION_RULES.md`
- `.gitignore` — Sliver sessions, hashes, binarios, BloodHound JSONs

### REFACTOR
- Archivos `.md` de raíz movidos a `docs/`

---

## [2026-05-13] — Lab-01 GHOST FOREST completado

### ADD
- `Lab-01/docs/lateral_movement.md`, `privilege_escalation.md`, `persistence.md`
- `Lab-01/docs/objective_completion.md`, `lessons_learned.md`, `mitigations.md`
- Screenshots Fases 6-10

### FIX
- `Setup-Lab01-GhostForest.ps1` v1.1: SPN hardcodeado, DA por SID-512 universal

---

## [2026-05-11] — Setup inicial del proyecto

### ADD
- Repositorio creado, estructura completa 12 labs / 4 fases
- ARSENAL.md, LAB_INFRASTRUCTURE.md, MITRE_MAPPING.md, PROGRESS.md, WRITEUP_TEMPLATE.md
- Lab-01 OPERATION_GHOST_FOREST.md + Setup-Lab01-GhostForest.ps1 v1.0
- Entorno VirtualBox: DC-01, WKSTN-01, Kali — LabRedTeam 10.0.2.0/24

---

*Formato basado en [Keep a Changelog](https://keepachangelog.com/)*