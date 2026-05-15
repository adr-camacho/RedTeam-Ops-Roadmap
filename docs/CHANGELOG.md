# 📋 Changelog — Red Team Ops Roadmap

> Registro de cambios estructurales del repositorio.  
> Formato: `[YYYY-MM-DD] — Tipo — Descripción`  
> Tipos: `ADD` | `UPDATE` | `FIX` | `REFACTOR` | `DOCS`

---

## [2026-05-15] — Lab-02 SILENT BRIDGE completado — Fases 5-7

### ADD
- `Lab-02-Wreath/docs/post-exploitation.md` — Fase 5: lateral movement PC-01, incidencia WinRM perfil Público
- `Lab-02-Wreath/docs/c2_sliver.md` — Fase 6: beacon SUDDEN_COMMUNICATION, arquitectura relay PROD
- `Lab-02-Wreath/docs/persistence.md` — Fase 7: schtasks + Run Key + SAM dump + kill chain completo
- `Lab-02-Wreath/docs/lessons_learned.md` — 14 lecciones, comparativa Lab-01 vs Lab-02
- `Lab-02-Wreath/docs/mitigations.md` — mitigaciones por vector + reglas SIGMA + tabla de criticidad
- Screenshots Fases 5-7

### UPDATE
- `docs/PROGRESS.md` — Lab-02 completado, sesiones 6-8, técnicas dominadas actualizadas
- `docs/CHANGELOG.md` — esta entrada

---

## [2026-05-14] — Lab-02 SILENT BRIDGE — Fases 1-4 completadas

### ADD
- `Lab-02-Wreath/docs/enumeration_log.md` — Fases 1 y 4 con datos reales
- `Lab-02-Wreath/docs/exploitation.md` — CVE-2019-12840, exploit Python desde 46984.rb
- `Lab-02-Wreath/docs/pivoting.md` — Ligolo-ng v0.7.5, agent ID real, ruta 10.0.3.0/24
- Screenshots Fases 1-4

### FIX
- Beacon v1 → v2: `listener_add` en PROD como relay C2 (PC-01 sin visibilidad hacia Kali)

---

## [2026-05-13] — Lab-02 iniciado + Reestructuración de raíz

### ADD
- `Lab-02-Wreath/` — estructura completa + OPERATION_SILENT_BRIDGE.md + setup script
- `docs/CHANGELOG.md`, `docs/OPSEC_NOTES.md`, `docs/DETECTION_RULES.md`
- `.gitignore` — Sliver sessions, loot hashes, binarios, JSONs BloodHound

### UPDATE
- `docs/MITRE_MAPPING.md` — perfil multi-APT, Lab-02 (23 TTPs APT41)
- `README.md` — links a `docs/`, Lab-02 añadido

### REFACTOR
- Archivos `.md` de raíz movidos a `docs/`

---

## [2026-05-13] — Lab-01 completado

### ADD
- `Lab-01/docs/lateral_movement.md`, `privilege_escalation.md`, `persistence.md`
- `Lab-01/docs/objective_completion.md`, `lessons_learned.md`, `mitigations.md`
- Screenshots Fases 6-10

### FIX
- `Setup-Lab01-GhostForest.ps1` v1.1: SPN hardcodeado, DA por SID-512 universal

---

## [2026-05-12] — Lab-01 Fases 1-5 completadas

### ADD
- `Lab-01/docs/enumeration_log.md`, `exploitation.md`, `post_exploitation.md`
- `Lab-01/loot/`, `Lab-01/nmap/`, screenshots Fases 1-5

---

## [2026-05-11] — Setup inicial del proyecto

### ADD
- Repositorio creado, estructura completa 12 labs / 4 fases
- ARSENAL.md, LAB_INFRASTRUCTURE.md, MITRE_MAPPING.md, PROGRESS.md, WRITEUP_TEMPLATE.md
- Lab-01 OPERATION_GHOST_FOREST.md + Setup-Lab01-GhostForest.ps1 v1.0
- Entorno VirtualBox: DC-01, WKSTN-01, Kali — LabRedTeam 10.0.2.0/24

---

*Formato basado en [Keep a Changelog](https://keepachangelog.com/)*