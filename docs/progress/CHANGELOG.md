# 📋 Changelog — Red Team Ops Roadmap

> Registro de cambios estructurales del repositorio.
> Tipos: `ADD` | `UPDATE` | `FIX` | `REFACTOR` | `DOCS`


## [2026-06-03] — Análisis completo del repo + mejoras calidad

### ADD — Visual
- `docs/assets/virtualbox_lab_environment.png` — captura VirtualBox todas las VMs corriendo con nombres descriptivos

### UPDATE — README global
- Badges actualizados: 62 TTPs, ~155h, 6/15 Labs
- Lab-06 marcado como completado con sección de fases y TTPs
- Tabla MITRE Coverage: 10 nuevas técnicas Lab-06 añadidas
- Árbol de estructura: Lab-06 actualizado

### PENDIENTE — Scripts provisioning (próxima sesión)
- `06_wkstn01_fixed.ps1` — añadir reglas firewall ICMP, SMB, WMI, Remote Scheduled Tasks
- `07_setup_DC02_Corp.ps1` — añadir creación de C:\Temp
- `09_setup_DC04_Ext.ps1` — reemplazar "Everyone" por SID *S-1-1-0 en New-SmbShare
- `CrownJewels-Lab06-BlackPolicy.ps1` — reemplazar nombre de grupo por SID en Enterprise-Strategy

---

## [2026-06-02] — Lab-06 BLACK POLICY Fase 05 — C2 + Cleanup + COMPLETADO

### ADD — Lab-06 Fase 05
- `Lab-06/docs/execution/c2_sliver.md` — C2 Sliver beacons WKSTN-01 + DC-02
- `Lab-06/docs/execution/cleanup_opsec.md` — artefactos eliminados, Defender reactivado
- `Lab-06/docs/execution/lateral_movement.md` — movimientos laterales completos Lab-06
- `Lab-06/loot/IPO_strategy_2026.txt` — Crown Jewel TOP SECRET exfiltrado
- `Lab-06/screenshots/FASE-05-C2-Cleanup/` — 4 capturas

### UPDATE — Docs Lab-06 COMPLETADO
- `OPERATION_BLACK_POLICY.md` — todas las fases completadas, todos los Crown Jewels
- `README.md` — Lab-06 completado, 5/5 fases, badges brightgreen
- `docs/analysis/lessons_learned.md` — L-01 a L-11 Fases 01-02
- `docs/analysis/mitigations.md` — Fases 01-02 con Event IDs y SIGMA rules

### ADD — Docs referencia
- `docs/reference/CREDENTIALS.md` — nuevo: todas las credenciales del entorno de lab
- `docs/assets/virtualbox_lab_environment.png` — entorno VirtualBox real corriendo

### FIX — Infraestructura Fase 05
- C:\Temp no existe en DC-02 → creado manualmente (pendiente script 07)
- Enterprise-Strategy share falla con nombre de grupo en multi-forest → SID directo

---

## [2026-06-02] — Lab-06 BLACK POLICY Fase 04 — GPO Abuse

### ADD — Lab-06 Fase 04
- `Lab-06/docs/execution/gpo_abuse.md` — GPO Abuse completo via pyGPOAbuse
- `Lab-06/loot/dacledit-20260602-102701.bak` — backup DACL original GPO IT-Baseline
- `Lab-06/loot/dacledit-20260602-125831.bak` — backup DACL post-restore
- `Lab-06/screenshots/FASE-04-GPO-Abuse/` — 9 capturas

### ADD — Arsenal
- `pyGPOAbuse` instalado en `/opt/redteam/pyGPOAbuse`

### UPDATE — Docs Lab-06
- `OPERATION_BLACK_POLICY.md` — Fase 04 completada, helpdesk.ruiz admin WKSTN-01
- `README.md` — Crown Jewel 1 completado
- `docs/reference/CREDENTIALS.md` — nuevo doc con todas las credenciales del entorno

### FIX — Infraestructura
- WKSTN-01: reglas firewall ICMP + SMB añadidas manualmente
- WKSTN-01: `06_wkstn01_fixed.ps1` pendiente actualización con firewall rules
- GPP XML manual no funciona en Windows 11 → usar pyGPOAbuse
- `New-SmbShare -ReadAccess "Everyone"` falla en español → usar SID `*S-1-1-0`

### DOCS — Lecciones aprendidas Fase 04
- GPP ScheduledTasks XML no procesado en Windows 11 — pyGPOAbuse más compatible
- GPT.INI Version counter debe incrementarse para que el cliente reprocese el GPO
- Windows 11 bloquea WMI y Remote Scheduled Tasks por defecto

---

## [2026-06-01] — Lab-06 BLACK POLICY Fases 01-02 + Fixes provisioning

### ADD — Lab-06 ejecución
- `Lab-06/docs/execution/enumeration_log.md` — Reconnaissance completo multi-forest
- `Lab-06/docs/execution/sid_history.md` — SID History injection via DSInternals
- `Lab-06/docs/execution/infrastructure_setup.md` — Infraestructura multi-forest
- `Lab-06/loot/fase01-kerberoast-corp.txt` + `fase01-kerberoast-ext.txt` — hashes corp_svc / ext_svc
- `Lab-06/loot/fase02-dcsync-krbtgt.ntds.kerberos` — krbtgt AES256/AES128
- `Lab-06/screenshots/FASE-01-Reconnaissance/` — 10 capturas
- `Lab-06/screenshots/FASE-02-SID-History/` — 7 capturas

### ADD — Arsenal v2.1
- `tooling/arsenal_setup.sh` v2.1 — bloodyad (apt), mimikatz.exe, DSInternals v4.14

### FIX — Scripts provisioning v1.1
- `08_setup_DC03_Child.ps1` v1.1 — DNS primario DC-01, ADWS port 9389, C:\Temp
- `10_setup_Trusts_And_SIDHistory.ps1` — ADWS firewall rule añadida en DC-01

### UPDATE — Docs globales
- `README.md` — badges actualizados (52 TTPs, ~141h), Lab-06 en progreso
- `docs/design/DESIGN.md` v2.1 — infraestructura multi-forest, fixes, lecciones
- `docs/progress/PROGRESS.md` — Sesión 18 añadida
- `Lab-06/OPERATION_BLACK_POLICY.md` — Fase 02 completada, loot krbtgt
- `Lab-06/README.md` — progreso actualizado

### DOCS — Lecciones aprendidas
- Evil-WinRM token de red bloquea ADWS cross-domain → .NET NTAccount.Translate()
- sIDHistory protegido en AD — DSInternals requerido, bloodyad no puede modificarlo
- mimikatz misc::addsid eliminado en v2.2.0+

---


## [2026-05-31] — Infraestructura CRTO completa + Setup Lab-06

### ADD — Nueva infraestructura (entorno CRTO completo)
- `DC-02` (10.0.2.11) — corp.local — Forest 2 operativo
- `DC-03` (10.0.2.13) — child.atackcorp.local — Child Domain operativo
- `DC-04` (10.0.2.14) — ext.local — Forest 3 operativo
- `WKSTN-02` (10.0.2.12) — corp.local workstation operativa
- Forest Trusts: atackcorp.local ↔ corp.local ↔ ext.local (BiDirectional)
- SID Filtering deshabilitado en todos los trusts (Lab-06 SID History)
- DNS Conditional Forwarders configurados en todos los DCs

### ADD — Scripts provisioning nuevos
- `setup/provisioning/07_Setup_DC02_Corp.ps1` — OUs, usuarios, ACLs, Kerberoasting corp.local
- `setup/provisioning/08_Setup_DC03_Child.ps1` — child domain, SID Filtering off
- `setup/provisioning/09_Setup_DC04_Ext.ps1` — ext.local, share con credenciales expuestas
- `setup/provisioning/10_Setup_Trusts_And_SIDHistory.ps1` — SID Filtering deshabilitado, cross.user
- `setup/provisioning/11_Setup_WKSTN02_Corp.ps1` — WinRM, autologon, C:\Temp

### FIX — Scripts provisioning corregidos
- `setup/provisioning/06_wkstn01.ps1` — eliminado Enable-PSRemoting (cortaba conexion Evil-WinRM)
- `setup/provisioning/11_Setup_WKSTN02_Corp.ps1` — eliminado Enable-PSRemoting
- Ambos scripts incluyen prerequisitos de WinRM en comentario de cabecera

### UPDATE — Docs globales
- `README.md` — diagrama arquitectura actualizado con 4 DCs + 2 WKSTNs + Forest Trusts
- `README.md` — tabla hosts actualizada, requisitos hardware actualizados
- `README.md` — setup automatizado con comentarios por VM
- `docs/reference/LAB_INFRASTRUCTURE.md` — seccion infraestructura ampliada CRTO completa

### ADD — Lab-06 BLACK POLICY
- `Phase-02-Post-Exploitation/Lab-06-Black-Policy/screenshots/` — carpetas FASE-01 a FASE-05
- `Phase-02-Post-Exploitation/Lab-06-Black-Policy/OPERATION_BLACK_POLICY.md`
- `Phase-02-Post-Exploitation/Lab-06-Black-Policy/docs/theory/tradecraft.md`
- `Phase-02-Post-Exploitation/Lab-06-Black-Policy/setup/Setup-Lab06-BlackPolicy.ps1`

---

## [2026-05-30] — Lab-05 SILVER CHAIN completado + Mejoras globales

### ADD — Lab-05 SILVER CHAIN
- `Lab-05-Silver-Chain/docs/execution/enumeration_log.md` — SharpHound 354 objetos, BloodHound CE Cypher queries
- `Lab-05-Silver-Chain/docs/execution/rbcd_abuse.md` — ATTACKER$, S4U2Self+S4U2Proxy, acceso C$ WKSTN-01
- `Lab-05-Silver-Chain/docs/execution/shadow_credentials.md` — pywhisker, PKINIT, iis_svc hash
- `Lab-05-Silver-Chain/docs/execution/silver_ticket.md` — ticketer, MSSQLSvc/DC-01:1433, SQL Server 2022
- `Lab-05-Silver-Chain/docs/execution/diamond_ticket.md` — Rubeus diamond, kirbi→ccache, bypass PAC Validation
- `Lab-05-Silver-Chain/docs/execution/c2_sliver.md` — beacon LIGHT_CARTLOAD WKSTN-01
- `Lab-05-Silver-Chain/docs/execution/cleanup_opsec.md` — ATTACKER$ eliminado, Shadow Creds limpiadas
- `Lab-05-Silver-Chain/docs/execution/infrastructure_setup.md` — ACLs, MAQ, SQL Server, credenciales
- `Lab-05-Silver-Chain/docs/analysis/lessons_learned.md` — 10 lecciones (L-01 a L-10)
- `Lab-05-Silver-Chain/docs/analysis/mitigations.md` — RBCD, Shadow Creds, Silver/Diamond Ticket detección
- `Lab-05-Silver-Chain/loot/lab05_hashes.txt` — iis_svc NTLM hash
- `Lab-05-Silver-Chain/loot/lab05_sharphound.zip` — BloodHound collection 354 objetos
- `Lab-05-Silver-Chain/nmap/` — escaneos DC-01 + WKSTN-01 (compartidos con Lab-01)
- Screenshots FASE-01 a FASE-06: 14 capturas

### UPDATE — Lab-05
- `Lab-05-Silver-Chain/OPERATION_SILVER_CHAIN.md` — actualizado con resultados reales de operación
- `Lab-05-Silver-Chain/README.md` — estado ✅ completado, 6 fases, crown jewels obtenidos

### ADD — Mejoras globales portfolio
- `README.md` — badge Labs→TTPs Dominadas (35→45), diagrama Mermaid kill chain
- `Labs 06-15/README.md` — Design Phase notice, numeración y adversarios correctos
- `tooling/arsenal_setup.sh` — reescrito completamente (era PS script incorrecto)

### FIX
- `tooling/arsenal_setup.sh` — contenido era PS script de provisioning AD (incorrecto)
- `Lab-03/screenshots/FASE-04` — renombrada sin espacio en nombre de carpeta
- `Lab-05/docs/` — docs vacíos del template eliminados
- `loot/` Labs 01-03 — archivos reales añadidos (dcsync_hashes, sam_hashes, cert_hash)
- `nmap/` Labs 01-04 — escaneos reales regenerados (eran placeholders de 9 bytes)
- `.gitignore` — ligolo-ng.history y ligolo-selfcerts/ añadidos

### UPDATE — Docs globales
- `PROGRESS.md` — Lab-05 completado, semana 7, 45 TTPs dominadas, ~115h
- `CHANGELOG.md` — entradas 30/05 añadidas
- `MITRE_MAPPING.md` — Lab-05 técnicas ✅ (RBCD, Shadow Creds, Silver/Diamond Ticket)
- `ARSENAL.md` — pywhisker, SQL Server Express 2022, impacket 0.13.1 nota
- `LAB_INFRASTRUCTURE.md` — sección Lab-05 añadida

---

## [2026-05-29] — Lab-04 IRON FOREST completado — Fases 04-08

### ADD
- `Lab-04/docs/execution/writedacl_abuse.md` — dacledit write/read, verificación ACEs, SIGMA
- `Lab-04/docs/execution/dcsync.md` — secretsdump via fin.garcia (no-DA), crown jewels
- `Lab-04/docs/execution/adidns_abuse.md` — dnstool WPAD, DNS Block List, Responder NTLMv2
- `Lab-04/docs/execution/c2_sliver.md` — beacon iron_forest_dc01 en DC-01 como DA
- `Lab-04/docs/execution/cleanup_opsec.md` — DCSync rights eliminados, WPAD tombstoned
- `Lab-04/docs/analysis/mitigations.md` — detección y hardening por técnica
- `Lab-04/loot/dcsync_hashes.txt` — hashes NTLM completos del dominio
- `Lab-04/loot/ntlmv2_backup_svc.txt` — NTLMv2 capturado via WPAD poisoning
- `Lab-04/screenshots/FASE-04 a FASE-08` — evidencia visual completa

### UPDATE
- `Lab-04/OPERATION_IRON_FOREST.md` — estado COMPLETADO, 8/8 fases
- `Lab-04/README.md` — badge Status→Completado, fases y crown jewels actualizados
- `Lab-04/docs/analysis/lessons_learned.md` — 13 lecciones (L-07 a L-13 añadidas)
- `docs/PROGRESS.md` — sesiones 14-15, +7 técnicas dominadas, 4/15 labs
- `docs/MITRE_MAPPING.md` — Lab-04 técnicas actualizadas a ✅
- `docs/reference/LAB_INFRASTRUCTURE.md` — sección Lab-04 añadida
- `docs/reference/ARSENAL.md` — BloodHound CE Docker, krb5-user, dnstool.py
- `docs/operations/OPSEC_NOTES.md` — secciones WriteDACL/ADIDNS/Responder/Sliver

### FIX
- `Lab-04/screenshots/FASE-07` — screenshots movidas desde FASE-06 a carpeta correcta
- `Lab-04/screenshots/FASE-01 a FASE-03` — reorganización nomenclatura

---

## [2026-05-28] — Lab-04 IRON FOREST iniciado — Fases 01-03 + infraestructura Kali

### ADD
- `Lab-04/docs/execution/enumeration_log.md` — BloodHound CE setup, SharpHound 358 objetos
- `Lab-04/docs/execution/credential_hunting.md` — share IT-Scripts, 6 credenciales
- `Lab-04/docs/execution/lateral_movement.md` — Overpass-the-Hash, TGT fin.garcia
- `Lab-04/docs/analysis/lessons_learned.md` — 6 lecciones iniciales (L-01 a L-06)
- `Lab-04/setup/CrownJewels-Lab04-IronForest.ps1` — ejecutado en DC-01
- `~/tools/ad/bloodhound-ce/docker-compose.yml` — BloodHound CE con Neo4j 4.4

### UPDATE
- Kali RAM: 4GB → 8GB | DC-01 RAM: 2GB → 4GB | WKSTN-01 RAM: 2GB → 3GB
- `tooling/arsenal_setup.sh` — SharpHound v2.5.9 ruta correcta `/opt/redteam/windows/`
- `docs/PROGRESS.md` — sesión 14 añadida

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