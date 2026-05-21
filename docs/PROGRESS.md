# 📊 Progress Tracker — Red Team Ops Roadmap

> Diario de progreso del roadmap Red Team.
> Actualizado manualmente tras cada sesión de trabajo.

---

## 🧭 Estado General

| Métrica | Valor |
|---------|-------|
| Fecha de inicio | 09/05/2026 |
| Última actualización | 20/05/2026 |
| Labs completados | 3 / 14 |
| Labs en progreso | 0 / 12 |
| Horas totales invertidas | ~75h |
| Fase actual | Phase-02: AD Avanzado (preparación) |

---

## 📈 Progreso por Fase

### 🟢 Phase-01 — Fundamentos y Pivotaje

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-01: Ghost Forest | ✅ Completado | 09/05/2026 | 20/05/2026 | ~40h | ✅ Completo |
| Lab-02: Silent Bridge | ✅ Completado | 13/05/2026 | 15/05/2026 | ~18h | ✅ Completo |
| Lab-03: Dark Gate | ✅ Completado | 16/05/2026 | 17/05/2026 | ~16h | ✅ Completo |

### 🟡 Phase-02 — AD Avanzado

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-04: Iron Forest | ⏳ Pendiente | — | — | — | — |
| Lab-05: Silver Chain | ⏳ Pendiente | — | — | — | — |
| Lab-06: Black Policy | ⏳ Pendiente | — | — | — | — |

### 🔴 Phase-03 — Red Team & Evasión

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-07: Ghost Signal (Lazarus) | ⏳ Pendiente | — | — | — | — |
| Lab-08: Dark Current (Lazarus) | ⏳ Pendiente | — | — | — | — |
| Lab-09: Deep Holo (Lazarus) | ⏳ Pendiente | — | — | — | — |

### 🏴 Phase-04 — Simulación Real

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-10: Red Dante (APT10) | ⏳ Pendiente | — | — | — | — |
| Lab-11: Deep Water (APT10) | ⏳ Pendiente | — | — | — | — |
| Lab-12: Operation Zephyr (APT10) | ⏳ Pendiente | — | — | — | — |

---

## 📅 Diario de Sesiones

### Semana 1 — 09/05/2026 al 11/05/2026

#### 📌 09/05/2026 — Sesión 1: Setup inicial
- Repositorio `RedTeam-Ops-Roadmap` creado en GitHub
- Entorno VirtualBox: DC-01, WKSTN-01, Kali — Red NAT `LabRedTeam` 10.0.2.0/24
- **Horas:** ~3h

#### 📌 10/05/2026 — Sesión 2: Lab-01 Fases 1-3
- AS-REP Roasting: `ceo.martinez:Direccion2024!` + `backup_svc:Backup2024!`
- Evil-WinRM foothold como `ceo.martinez`
- **Horas:** ~2h

#### 📌 11/05/2026 — Sesión 3: Lab-01 documentación parcial
- infrastructure_setup, exploitation, enumeration_log generados
- **Horas:** ~1h

---

### Semana 2 — 12/05/2026 al 13/05/2026

#### 📌 12/05/2026 — Sesión 4: Lab-01 Fases 4-5
- Discovery completo + BloodHound attack paths
- Kerberoasting → `backup_svc:Backup2024!` → **Domain Admin** ✅
- **Horas:** ~8h

#### 📌 13/05/2026 — Sesión 5: Lab-01 Fases 6-10 + documentación completa
- Lateral Movement WKSTN-01 + C2 Sliver `EASY_PROFIT`
- LPE: Potato attacks fallaron en WinRM (Network tokens)
- Golden Ticket: `KDC_ERR_TGT_REVOKED` (PAC Validation WS2022)
- DCSync Administrator → Pass-the-Hash → **Domain Admin** ✅
- Documentación completa Lab-01
- **Horas:** ~12h

---

### Semana 3 — 13/05/2026 al 15/05/2026

#### 📌 13/05/2026 — Sesión 6: Lab-02 Setup infraestructura
- Red `LabInternal` (10.0.3.0/24) creada en VirtualBox
- PROD + GIT (Ubuntu 22.04) + PC-01 (Windows 11) configurados
- **Problema:** Ubuntu 26.04 incompatible con Webmin 1.890 → reinstalación Ubuntu 22.04
- **Horas:** ~4h

#### 📌 14/05/2026 — Sesión 7: Lab-02 Fases 1-3
- Webmin 1.890 instalado con dependencias manuales
- CVE-2019-15107 bloqueado (MINISERV_INTERNAL) → CVE-2019-12840 — exploit Python construido desde `46984.rb`
- Shell reversa `root@prod` ✅ | Ligolo-ng v0.7.5 → red interna enrutada ✅
- **Horas:** ~8h

#### 📌 15/05/2026 — Sesión 8: Lab-02 Fases 4-7 + documentación
- Git history → `thomas:iamthegreatest` ✅
- Evil-WinRM PC-01 + beacon `SUDDEN_COMMUNICATION` via relay PROD ✅
- schtasks + SAM dump + objetivo completado ✅
- **Horas:** ~6h

---

### Semana 4 — 16/05/2026 al 17/05/2026

#### 📌 16/05/2026 — Sesión 9: Lab-03 Setup + Arsenal Kali
- ADCS instalado en DC-01 → `AtackCorp-CA` corriendo ✅
- ESC1: plantilla `VulnerableUser` (msPKI-Certificate-Name-Flag=1) ✅
- ESC4: `fin.garcia` GenericWrite + WriteDacl sobre VulnerableUser ✅
- ESC8: Web Enrollment HTTP → `http://10.0.2.10/certsrv/` ✅
- Kali conectada a Internet (Adaptador 2 NAT)
- Arsenal instalado: Certipy v5.0.4, PetitPotam, NetExec, PowerView, WinPEAS, Rubeus, SharpHound
- Scripts de utilidad: arsenal_setup.sh, lab_start.sh, lab_stop.sh, kali_network_check.sh
- Setup-Lab01-GhostForest-v2.ps1 generado (7 vulnerabilidades + OUs + usuarios)
- **Horas:** ~8h

#### 📌 17/05/2026 — Sesión 10: Lab-03 Fases 1-6 + documentación completa
- **Fase 1:** certipy-ad find → ESC1 + ESC8 confirmados ✅
- **Fase 2:** ESC1 — ceo.martinez → cert Administrador → hash `b73fdfe1...` → DA ✅
- **Fase 3:** ESC4 — fin.garcia → plantilla modificada → cert DA → restaurada (OPSEC) ✅
- **Fase 4:** ESC8 — PetitPotam exitoso, relay bloqueado KB5005413 (WS2022) → documentado ✅
- **Fase 5:** C2 `CLINICAL_CHAIRMAN` en DC-01 — 3 beacons activos simultáneamente ✅
- **Fase 6:** Cert persistence — válido post-rotación → hash `bc3abc2e...` → DA confirmado ✅
- Documentación completa Lab-03 (9 documentos)
- **Horas:** ~8h

---

## 🏆 Técnicas Dominadas

| Técnica | MITRE ID | Lab | Nivel |
|---------|----------|-----|-------|
| AS-REP Roasting | T1558.004 | Lab-01 | ✅ Dominada |
| Kerberoasting | T1558.003 | Lab-01 | ✅ Dominada |
| DCSync | T1003.006 | Lab-01 | ✅ Dominada |
| Pass-the-Hash | T1550.002 | Lab-01/03 | ✅ Dominada |
| WinRM Lateral Movement | T1021.006 | Lab-01/02/03 | ✅ Dominada |
| C2 Sliver HTTPS | T1071.001 | Lab-01/02/03 | ✅ Dominada |
| Web RCE (CVE-2019-12840) | T1190 | Lab-02 | ✅ Dominada |
| Protocol Tunneling Ligolo-ng | T1572 | Lab-02 | ✅ Dominada |
| Relay C2 (Ligolo listener) | T1090 | Lab-02 | ✅ Dominada |
| Credential Discovery Git | T1552.001 | Lab-02 | ✅ Dominada |
| SAM Credential Dump | T1003.002 | Lab-02 | ✅ Dominada |
| Scheduled Task Persistence | T1053.005 | Lab-02 | ✅ Dominada |
| Exploit Python manual | T1587.001 | Lab-02/03 | ✅ Dominada |
| ADCS Enumeration (Certipy) | T1046 | Lab-03 | ✅ Dominada |
| ESC1 — SAN Abuse | T1649 | Lab-03 | ✅ Dominada |
| ESC4 — Template Modification | T1222+T1649 | Lab-03 | ✅ Dominada |
| ESC8 — NTLM Relay ADCS | T1557.001 | Lab-03 | ✅ Identificada |
| Certificate Persistence | T1649 | Lab-03 | ✅ Dominada |
| NTLM Coercion (PetitPotam) | T1187 | Lab-03 | ✅ Dominada |
| Golden Ticket | T1558.001 | Lab-01 | 🔄 Parcial (PAC Validation) |
| Token Impersonation | T1134.001 | Lab-01 | 🔄 Parcial (WinRM) |
| Unconstrained Delegation | T1558.001 | Lab-01 | ✅ Dominada |
| Constrained Delegation (S4U2Proxy) | T1558.001 | Lab-01 | ✅ Dominada |
| GPO Abuse (SYSVOL) | T1484.001 | Lab-01 | ✅ Dominada |
| Targeted Kerberoasting (GenericWrite) | T1558.003 | Lab-01 | ✅ Dominada |
| BloodHound CE metodología | T1087.002 | Lab-01 | ✅ Dominada |
| PetitPotam NTLM coerción | T1187 | Lab-01 | ✅ Dominada |

---

## 📋 Pendientes por lab

| Lab | Pendiente | Prioridad |
|-----|----------|-----------|
| Lab-04 | IRON FOREST — WriteDACL, ForceChangePassword, credential hunting | Alta |
| Lab-07 | SHADOW VAULT (nuevo) — LAPS, DPAPI, Shadow Credentials | Alta |
| Lab-09 | FIRST CONTACT (nuevo) — Initial Access real sin credenciales | Alta |
| Lab-13 | AZURE BREACH (nuevo) — Azure AD/Entra ID hybrid attacks | Alta |
| Lab-02 | Segundo pivote (tercer segmento de red) | Media |
| Lab-02 | Setup-Lab02-SilentBridge.sh (bash — PROD + GIT setup Ubuntu) | Baja |

---

*⚡ Leyenda: ✅ Completado | 🔄 Parcial | ⏳ Pendiente*
---

### Semana 5 — 18/05/2026 al 20/05/2026

#### 📌 18/05/2026 — Sesión 11: Lab-01 Fase 11 — Delegation Abuse
- Unconstrained Delegation (sql_svc): Rubeus monitor → TGT DC-01$ capturado automáticamente
- PetitPotam coerción → TGT fresco post-coerción ✅
- Constrained Delegation (iis_svc): S4U2Self + S4U2Proxy → TGS como Administrador → MSSQLSvc/dc01:1433 ✅
- BloodHound CE v9.1.0 configurado: bloodhound-python recolección (OPSEC) + SharpHound v2.5.9
- Kali: Adaptador 3 NAT Internet permanente configurado via NetworkManager
- **Horas:** ~6h

#### 📌 19/05/2026 — Sesión 12: Lab-01 Fase 11 BloodHound + Fases 12-13
- BloodHound CE: attack paths analizados — backup_svc (1 salto), fin.garcia (GenericWrite path)
- bloodhound-python vs SharpHound: diferencia en coverage ACLs/GPOs documentada
- Fase 12: GPO Abuse — helpdesk.ruiz → ScheduledTasks.xml en SYSVOL → Admin local WKSTN-01 ✅
- Fase 13: ACL Abuse — fin.garcia GenericWrite → bloodyAD SPN → GetUserSPNs → SQLService2024! ✅
- **Horas:** ~5h

#### 📌 20/05/2026 — Sesión 13: Documentación Lab-01 + Roadmap v2.0
- 4 docs nuevos generados: delegation.md, gpo_abuse.md, acl_abuse.md, bloodhound.md
- lessons_learned.md actualizado (+6 lecciones L-14 a L-19)
- Setup-Lab01-GhostForest-v2.1.ps1: OU IT, WinRM, C:\Temp, SPN corregido
- arsenal_setup.sh: SharpHound descarga via ZIP con verificación
- DESIGN.md generado: Roadmap v2.0 con 14 labs, crown jewels, coverage matrix 80%
- **Horas:** ~4h