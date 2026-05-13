# 📋 Changelog — Red Team Ops Roadmap

> Registro de cambios estructurales del repositorio.  
> Formato: `[YYYY-MM-DD] — Tipo — Descripción`  
> Tipos: `ADD` (nuevo contenido) | `UPDATE` (actualización) | `FIX` (corrección) | `REFACTOR` (reestructuración) | `DOCS` (documentación pura)

---

## [2026-05-13] — Lab-02 iniciado + Reestructuración de raíz

### ADD
- `Phase-01-Fundamentals/Lab-02-Wreath/` — estructura completa del lab creada
- `Lab-02-Wreath/OPERATION_SILENT_BRIDGE.md` — plan de operación APT41
- `Lab-02-Wreath/README.md` — índice del lab con attack path y MITRE mapping
- `Lab-02-Wreath/docs/infrastructure_setup.md` — topología y vectores Wreath
- `Lab-02-Wreath/docs/pivoting.md` — referencia operacional Ligolo-ng (template)
- `docs/CHANGELOG.md` — este fichero
- `docs/OPSEC_NOTES.md` — aprendizajes OPSEC transversales
- `docs/DETECTION_RULES.md` — reglas SIGMA y Event IDs consolidados
- `docs/` — carpeta de documentación raíz creada

### UPDATE
- `docs/MITRE_MAPPING.md` — añadido perfil multi-APT (6 adversarios), Lab-02 con 23 técnicas APT41, columna Adversario en índice, sección de estadísticas
- `README.md` — links actualizados a `docs/`, Lab-02 añadido como In Progress

### REFACTOR
- Archivos `.md` de raíz movidos a `docs/` — raíz queda solo con `README.md`

---

## [2026-05-13] — Lab-01 completado

### ADD
- `Lab-01-Attacktive-Directory/docs/lateral_movement.md` — Fases 6-7: LM + C2 Sliver
- `Lab-01-Attacktive-Directory/docs/privilege_escalation.md` — Fase 8: LPE WKSTN-01
- `Lab-01-Attacktive-Directory/docs/persistence.md` — Fase 9: Golden Ticket
- `Lab-01-Attacktive-Directory/docs/objective_completion.md` — Fase 10: DCSync + DA
- `Lab-01-Attacktive-Directory/docs/lessons_learned.md` — 12 lecciones documentadas
- `Lab-01-Attacktive-Directory/docs/mitigations.md` — mitigaciones Blue Team
- Screenshots Fases 6-10 — capturas de evidencia operacional

### UPDATE
- `PROGRESS.md` — sesión 5 documentada (Fases 6-10), 12h registradas
- `README.md` — Lab-01 marcado como ✅ Completado, badge 1/12

### FIX
- `setup/Setup-Lab01-GhostForest.ps1` → v1.1: SPN hardcodeado como literal, DA por SID-512 universal

---

## [2026-05-12] — Lab-01: Fases 1-5 completadas

### ADD
- `Lab-01-Attacktive-Directory/docs/enumeration_log.md` — Fase 1: Reconnaissance
- `Lab-01-Attacktive-Directory/docs/exploitation.md` — Fases 2-3: AS-REP Roasting + foothold
- `Lab-01-Attacktive-Directory/docs/post_exploitation.md` — Fases 4-5: Discovery + Kerberoasting → DA
- `Lab-01-Attacktive-Directory/loot/` — users.txt, asrep_hashes.txt, targeted_wordlist.txt
- `Lab-01-Attacktive-Directory/nmap/` — outputs completos (ports, detailed, wkstn01)
- Screenshots Fases 1-5 — capturas de evidencia operacional

### UPDATE
- `PROGRESS.md` — sesiones 2-4 documentadas

---

## [2026-05-11] — Setup inicial del proyecto

### ADD
- Repositorio `RedTeam-Ops-Roadmap` creado en GitHub
- `README.md` — índice principal del roadmap (12 labs, 4 fases)
- `ARSENAL.md` — arsenal de herramientas completo con guías de instalación
- `LAB_INFRASTRUCTURE.md` — entorno vulnerable: 6 scripts PowerShell de aprovisionamiento
- `MITRE_MAPPING.md` — mapping inicial (APT29, 39 técnicas)
- `PROGRESS.md` — tracker de progreso inicializado
- `WRITEUP_TEMPLATE.md` — plantilla estándar para writeups
- `Lab-01-Attacktive-Directory/OPERATION_GHOST_FOREST.md` — plan de operación APT29
- `Lab-01-Attacktive-Directory/docs/infrastructure_setup.md` — entorno Lab-01
- `Lab-01-Attacktive-Directory/setup/Setup-Lab01-GhostForest.ps1` — v1.0
- Entorno VirtualBox: DC-01, WKSTN-01, Kali — Red NAT `LabRedTeam` `10.0.2.0/24`

---

*Formato basado en [Keep a Changelog](https://keepachangelog.com/)*