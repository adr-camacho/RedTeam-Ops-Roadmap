# 🎯 CRTO_COVERAGE.md — Matriz de cobertura temario → lab

> **Propósito.** Demostrar, de forma defendible, que el plan de 18 labs cubre el temario de **CRTO
> (Red Team Ops, Zero-Point Security)** sin huecos de *capability*, y dejar explícitos los solapes y la
> ordenación para que las fronteras entre labs no se reinterpreten.
>
> **Fuente del temario.** Outline público de RTO/CRTO (Zero-Point Security, ~26 módulos) contrastado en
> 06/2026. El contenido del curso está tras login; **reconciliar con el portal** si algún módulo se renombra.
> Esta matriz es la **fuente de verdad de cobertura**; `ROADMAP.md` y `README.md` la referencian.
>
> Ubicación: `docs/design/CRTO_COVERAGE.md` · Versión: 1.0 · Fecha: 19/06/2026

---

## 1. Recordatorio — tipos de lab (ver `REPOSITORY_STANDARDS.md §2`)

- **Fundamento (F):** una *capability* del temario, demostrada con la kill-chain más limpia que la ejercite.
- **Integración (I):** la responsabilidad *es encadenar* capabilities ya aprendidas por objetivo (capstone).

La cobertura del examen = labs de **fundamento** que mapean el temario **+** labs de **integración** que
entrenan a operar con todo junto.

---

## 2. Matriz — módulo CRTO → lab

| # | Módulo CRTO | Capability | Lab(s) | Tipo | Estado | Notas |
|---|-------------|-----------|--------|------|--------|-------|
| 1 | Cobalt Strike / C2 framework | Modelo operador de C2 | Lab-08 | F | ⏳ | **Ver Hallazgo F5 (ordenación):** Labs 01-07 ya usan C2 (Sliver) antes que este lab |
| 2 | External Reconnaissance | OSINT / recon externo | Lab-09 (·Lab-02) | F | ⏳ | |
| 3 | Initial Compromise | Acceso inicial / foothold | Lab-09 (·Lab-02 web RCE) | F | ⏳ | **F6:** repo usa assumed-breach para AD; acceso inicial se aísla aquí |
| 4 | Host Reconnaissance | Enumeración de host | Lab-09 (·Lab-01) | F | ⏳ | |
| 5 | Host Persistence | Persistencia en host | Lab-10 | F | ⏳ | |
| 6 | Host Privilege Escalation | Priv-esc local | Lab-10 | F | ⏳ | |
| 7 | Credentials & User Impersonation | Robo/impersonación de credenciales | Lab-01·04·07 | F | ✅ parcial | DCSync/PtH (01), OverPtH (04), Cred Manager (07) |
| 8 | Password Cracking | Cracking offline | Lab-01 | F | ✅ | AS-REP/Kerberoast → John |
| 9 | Lateral Movement | Movimiento lateral | Lab-01·02 | F | ✅ | |
| 10 | Session Passing | Paso de sesiones entre C2 | Lab-02 | F | ✅ | |
| 11 | Pivoting | Pivotaje de red | Lab-02 | F | ✅ | Ligolo-ng |
| 12 | Data Protection API (DPAPI) | Secrets vía DPAPI | Lab-07 | F | ✅ | |
| 13 | Kerberos | Abuso de Kerberos | Lab-01·05·14 | F | ✅ parcial | **F2:** fragmentado — delimitar fronteras (abajo) |
| 14 | Active Directory Certificate Services | ADCS (ESC1/4/8) | Lab-03 | F | ✅ | |
| 15 | Group Policy | Abuso de GPO | Lab-06 | F | ✅ | |
| 16 | MS SQL Servers | Ataque a MSSQL | Lab-13 | F | ⏳ | xp_cmdshell, linked servers, impersonation |
| 17 | Domain Dominance | Persistencia de dominio | Lab-14 | F | ⏳ | **F3:** DCSync se *usa* en 01/04/06; dominance se *enseña* solo aquí |
| 18 | Forest & Domain Trusts | Abuso de trusts | Lab-15 (·Lab-06) | F | ⏳ | **F4:** 06 usa el trust montado; 15 enseña la capability |
| 19 | LAPS | Local Admin Password Solution | Lab-07 | F | ✅ | |
| 20 | Microsoft Defender (AV) | Evasión AV/AMSI/ETW | Lab-11 | F | ⏳ | |
| 21 | Application Whitelisting | AppLocker / CLM / LOLBAS | Lab-12 | F | ⏳ | |
| 22 | Data Exfiltration | Exfiltración de datos | Lab-17 | F | ⏳ | |
| 23 | Reporting | Reporte de engagement | Lab-17 + **transversal** | F | ⏳ | cada lab produce `report/`; Lab-17 lo trata como capability |
| 24 | Extending the C2 (avanzado) | BOFs / Malleable C2 / Aggressor | Lab-16 | F | ⏳ | **F7:** frontera CRTO/CRTO-II; marcar como extensión "operador pro" |
| — | (lifecycle completo, Defender ON, por objetivos) | Operar end-to-end | **Lab-18** | **I** | ⏳ | Capstone — simulación de examen |
| — | (primera cadena AD integrada) | Encadenar fundamentos AD | **Lab-01** | **I** | ⚠ | Integración, pero **hoy sobrecargada** — ver F1 |

> Cobertura de *capability*: **completa, sin huecos.** Los problemas detectados son de **delimitación** y
> **ordenación**, no de ausencia. Eso es justo lo que hace defendible el plan de 18 labs.

---

## 3. Hallazgos y decisiones

**F1 — Lab-01 sobrecargado (responsabilidad múltiple).** Hoy toca piezas de ~6 módulos (Host Recon, Kerberos
roasting, Credentials, Password Cracking, Lateral, DCSync, C2) y además delegación/GPO/ACL. Falla el test de la
frase. → **Recortar** a una integración limpia ("primera kill-chain AD: roasting → foothold → DA → C2"). La
delegación, GPO y ACL ya tienen su lab de fundamento dedicado (05/06/04); se relocalizan como forward-reference.

**F2 — Kerberos repartido en 3 labs.** Defendible si se delimita y se documenta la frontera en cada
`technique.md`/`emulation.md`:
- **Lab-01** → *roasting* (AS-REP, Kerberoasting) como *credential access*.
- **Lab-05** → *delegation* (unconstrained/constrained/RBCD, S4U) y *ticket forging* (Silver/Diamond).
- **Lab-14** → *Golden Ticket* y persistencia de dominio.

**F3 — Domain Dominance.** DCSync aparece como *paso* en 01/04/06, pero la *capability* dominance (Golden, DSRM,
AdminSDHolder, persistencia) la posee **solo Lab-14**. Regla: labs previos **usan** DCSync; Lab-14 lo **enseña** como dominance.

**F4 — Forest & Trusts.** Lab-06 usa el trust ya montado para un objetivo concreto (SID history cross-forest);
**Lab-15** enseña la capability trusts en profundidad (inbound/outbound, SID filtering). Delimitar en sus docs.

**F5 — Ordenación de C2 (la más importante).** CRTO enseña C2/Cobalt Strike **muy temprano**; en el repo
*C2 Foundations* es Lab-08, pero Labs 01-07 **ya usan Sliver**. Es una inversión de dependencia. → **Decisión
recomendada:** introducir un **C2 primer temprano** (encaja con el `Lab-00 Primer` propuesto) para que ninguna
kill-chain use C2 antes de haberlo explicado; Lab-08 queda como *profundización* del modelo operador.

**F6 — Initial Access tardío.** El repo aísla acceso inicial en Lab-09 y usa *assumed-breach* para los labs de
AD — coherente con el modelo del examen. → Solo hay que **declararlo explícitamente** en el README de cada lab AD.

**F7 — Extending the C2 (Lab-16).** BOFs/Malleable/Aggressor rozan CRTO-II. Mantener, **marcado como extensión**
"operador pro", no como requisito de aprobado CRTO.

**F8 — Reporting.** Transversal (todo lab tiene `report/`) **y** capability dedicada (Lab-17). Correcto.

---

## 4. Decisiones pendientes (resumen accionable)

1. **F1** — Recortar Lab-01 + introducir on-ramp (`Lab-00 Primer`). *Toca trabajo ejecutado → requiere visto bueno.*
2. **F5** — C2 primer temprano (parte del `Lab-00`/arranque).
3. **F2/F3/F4** — Escribir las fronteras Kerberos / dominance / trusts en el `technique.md`+`emulation.md` de los labs implicados (parte del retrofit 01-07 y de la construcción de 13-15).
4. **F6/F7** — Declarar assumed-breach en READMEs de AD; etiquetar Lab-16 como extensión.

---

*Matriz de cobertura v1.0 · 19/06/2026 · fuente de verdad de cobertura CRTO del repo*
