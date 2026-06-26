# 🗺️ ROADMAP.md — Plan canónico (DESIGN v3.0)

> **Fuente de verdad** del roadmap. Sustituye a los borradores `ROADMAP_v2_CRTO.md` y absorbe la matriz de
> cobertura de `CRTO_ALIGNMENT.md`. El README y `PROGRESS.md` **referencian** este documento en lugar de
> repetir el plan, para evitar desincronización.
>
> Objetivo: preparación del examen **Red Team Ops (CRTO)** cubriendo el temario en profundidad.
> Ubicación: `docs/design/ROADMAP.md` · Fecha: 18/06/2026

---

## 1. Visión y objetivo

El repo es un **programa de estudio orientado al examen CRTO**: práctico, multi-dominio, *assumed breach*,
**con Defender activo**, evaluado por objetivos. Criterio de diseño: **el temario manda** (cert-first), y
**profundidad sobre cantidad** (depth-first). La narrativa APT se mantiene como piel didáctica, subordinada
a la cobertura del temario.

---

## 2. Estructura — 18 labs en 4 fases

| Fase | Labs | Foco |
|------|------|------|
| **Phase-01 · Fundamentals** | 01–03 | Fundamentos AD, pivotaje, ADCS |
| **Phase-02 · Post-Exploitation** | 04–07 | AD avanzado: ACLs, tickets, GPO, LAPS/DPAPI |
| **Phase-03 · Red Team Operations** | 08–12 | C2, operativa de host, evasión |
| **Phase-04 · Enterprise & Exam** | 13–18 | Maestría AD, C2 avanzado, capstone |

> Cambio de estructura de carpetas: se reasignan los labs de Phase-03/04 y se crean subcarpetas para
> Lab-12…Lab-18. Las carpetas actuales Lab-08…Lab-11 se re-encuadran según §4.

---

## 3. Plan de labs 01–18

| Lab | Título | Bloque CRTO | Estado |
|-----|--------|-------------|--------|
| 01 | Ghost Forest | Kerberos roasting → DCSync → DA (1ª kill-chain) | ✅ v3.1 |
| 02 | Silent Bridge | Web RCE → pivoting (Ligolo) → relay C2 | ✅ v3.1 |
| 03 | Dark Gate | ADCS ESC1/4/8 → cert abuse → DA + persistencia | ✅ v3.1 |
| 04 | Iron Forest | ACL abuse (WriteDACL/GenericWrite) → DCSync; cred hunting, ADIDNS | ✅ v3.1 |
| 05 | Silver Chain | Delegación (RBCD/Shadow Creds) + forja Silver/Diamond | ✅ v3.1 |
| 06 | Black Policy | GPO abuse cross-forest + SID History + Forest Trusts | ✅ v3.1 |
| 07 | Shadow Vault | Credential theft: LAPS/DPAPI/LSASS/Shadow Creds (endpoint 23H2) | ✅ v3.1 |
| 08 | Black Beacon · C2 Foundations | C2, listeners, staged/stageless, OPSEC, CS↔Sliver | ✅ v3.1 (concepto) |
| 09 | First Contact · Situational Awareness | Host recon, postura defensiva, árbol de decisión 1ª hora | ✅ v3.1 (concepto) |
| 10 | Deep Root · Host Persist & PrivEsc | Token abuse, servicios, UAC; Run/Task/Service/COM/WMI | ✅ v3.1 (plan) |
| 11 | Ghost Signal · Evasion I | Defender/AMSI/ETW, firma vs comportamiento, kits CS | ✅ v3.1 (concepto) |
| 12 | Iron Veil · Evasion II | AppLocker/CLM/LOLBAS, lógica de whitelisting | ✅ v3.1 (concepto) |
| 13 | Linked Shadows · MSSQL | Enum, linked servers, xp_cmdshell, lateral SQL | ✅ v3.1 (plan) |
| 14 | Golden Throne · Domain Dominance | Tickets forjados, ADCS certs, DSRM, AdminSDHolder | ✅ v3.1 (plan) |
| 15 | Forest Reign · Trust Abuse | Extra SID, SID Filtering, cross-forest lateral | ✅ v3.1 (plan) |
| 16 | Custom Arsenal · Extending C2 | Malleable profiles, BOFs, Aggressor, footprint | ✅ v3.1 (concepto) |
| 17 | Exfiltration & Reporting | Data hunting, exfil, OPSEC, reporte | ⏳ |
| 18 | Capstone — Exam Simulation | Cadena completa, Defender ON, por objetivos | ⏳ |

---

## 4. Objetivo de cada lab nuevo (08–18)

> Detalle de profundidad (teoría/práctica/detección) en el `theory.md` de cada lab. Resumen:

- **08 · C2 Foundations** — modelo operador CS (team server, listeners, beacons, staging, OPSEC) + tabla de equivalencia **CS ↔ Sliver**.
- **09 · Initial Access & Foothold** — external recon/OSINT, initial compromise, host recon y estabilización del primer beacon.
- **10 · Host Persistence & PrivEsc** — persistencia (run keys, servicios, tareas, COM) y priv-esc local (UAC, servicios, token), con detección.
- **11 · Evasión I** — Defender/AMSI/ETW: firma vs comportamiento, modelo Artifact/Resource Kit. *Teoría + detección + OPSEC en repo; payload/kit en el curso.*
- **12 · Evasión II** — AppLocker, CLM, LOLBAS: rutas permitidas, lógica de bypass conceptual, detección (8003/8004, 4104). *Bypass en el curso.*
- **13 · MS SQL Server Attacks** — enum, linked servers, `xp_cmdshell`, escalada y lateral vía SQL. (Requiere **VM SQL Server** nueva.)
- **14 · Domain Dominance & Persistence** — Golden/Silver/Diamond tickets, forged certs, DSRM, AdminSDHolder; detectabilidad y longevidad.
- **15 · Forest & Trust Abuse** — escalada hijo→raíz, SID history, trusts inbound/outbound, Kerberos cross-forest, SID filtering. (Usa los trusts ya montados.)
- **16 · Extending the C2** — BOFs, diseño de perfiles Malleable C2 (OPSEC), Aggressor. *Diseño/uso/OPSEC en repo; código en el curso.*
- **17 · Exfiltration & Reporting** — data hunting, staging, canales de exfil + ciclo de reporte/OPSEC del engagement.
- **18 · Capstone** — simulación de examen: assumed breach, multi-dominio, Defender ON, objetivos por outcome + autoevaluación.

---

## 5. Matriz de cobertura CRTO

> **Matriz detallada y defendible (fuente de verdad de cobertura):** [`CRTO_COVERAGE.md`](CRTO_COVERAGE.md) — módulo CRTO → lab, tipo (fundamento/integración), huecos y solapes.

| Bloque CRTO | Lab(s) | Estado |
|---|---|---|
| C2 / Cobalt Strike (modelo operador) | 01/02/07 (Sliver), 08 | 🟡→🟢 |
| External Recon / Initial Compromise | 02, 09 | 🟡→🟢 |
| Host Recon | 01, 09 | 🟢 |
| Host Persistence | 10 | 🔴→🟢 |
| Host Privilege Escalation | 10 | 🟡→🟢 |
| Domain Recon | 01, 04 | 🟢 |
| Lateral Movement | 01, 02 | 🟢 |
| Credentials & User Impersonation | 01, 04, 07 | 🟢 |
| Password Cracking | 01 | 🟢 |
| Session Passing / Pivoting / RPF | 02 | 🟢 |
| DPAPI | 07 | 🟢 |
| Kerberos | 01 + Fundamentos | 🟢 |
| Group Policy | 06 | 🟢 |
| Discretionary ACLs | 04 | 🟢 |
| Defender / AMSI / ETW evasion | 11 | 🔴→🟢 |
| AppLocker / CLM / LOLBAS | 12 | 🔴→🟢 |
| MS SQL Servers | 13 | 🔴→🟢 |
| Domain Dominance / Persistence | 01, 14 | 🟡→🟢 |
| Forest & Domain Trusts | 06, 15 | 🟡→🟢 |
| LAPS | 07 | 🟢 |
| ADCS (ESC1–8) | 03 | 🟢 |
| Extending CS (BOFs/Malleable/Aggressor) | 16 | 🔴→🟢 |
| Data Exfiltration | 17 | 🔴→🟢 |
| Reporting / OPSEC | 17, docs | 🟡→🟢 |

> Esta matriz se actualiza tras cada lab; es el indicador de "cobertura del temario".

---

## 6. Regla de construcción (división de trabajo)

| Pieza | Dónde | Quién |
|---|---|---|
| Teoría (internals, taxonomías, AMSI/ETW/AppLocker) | Repo | ✅ |
| Detección / blue team de cada técnica | Repo | ✅ |
| Operativa AD (recon, lateral, dominio, trusts, MSSQL, tickets) | Lab casero | ✅ hands-on |
| Documentación, matriz, reporte | Repo | ✅ |
| **Código armado de bypass / loader / kit / BOF** | **Lab oficial CRTO** | ❌ no en el repo |

---

## 7. Gobernanza de documentación

- **`docs/design/ROADMAP.md`** (este doc) — fuente de verdad del plan y la cobertura.
- **`docs/design/DESIGN.md`** — filosofía, metodología, arquitectura (mantiene historial de versiones).
- **`PROGRESS.md`** — estado vivo por lab y diario de sesiones; referencia este roadmap.
- **`README.md`** — overview; su sección de roadmap enlaza aquí, no la duplica.
- **`docs/reference/MITRE_MAPPING.md`** — TTPs por lab.
- Profundidad por técnica → `theory.md` / `detection.md` de cada lab.

---

## 8. Historial de versiones (DESIGN)

| Versión | Fecha | Cambio |
|---|---|---|
| v1.0 | 09/05/2026 | Estructura inicial — 12 labs, 4 fases |
| v2.0 | 20/05/2026 | Rediseño — 14 labs, crown jewels, coverage matrix |
| v2.1 | 01/06/2026 | Infra CRTO completa — 3 forests, multi-DC |
| **v3.0** | **18/06/2026** | **Rediseño por temario — 18 labs, 08–18 reconstruidos, matriz CRTO integrada** |

---

## 9. Decisiones aplicadas (defaults, revisables)

1. **11 labs** nuevos (08–18), máxima profundidad.
2. **VM SQL Server** añadida para Lab-13.
3. **Theming APT** mantenido como piel (Lazarus evasión / APT10 enterprise).
4. **Lab-10** persistencia + priv-esc juntos.

> Pendiente de validar: contenido de **Lab-05** y alcance ADCS de **Lab-03** para cerrar la matriz.

---

*Plan canónico v3.0 · Fuente de verdad · 18/06/2026*
