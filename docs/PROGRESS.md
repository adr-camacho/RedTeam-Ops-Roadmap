# 📊 Progress Tracker — Red Team Ops Roadmap

> Diario de progreso del roadmap Red Team.
> Actualizado manualmente tras cada sesión de trabajo.

---

## 🧭 Estado General

| Métrica | Valor |
|---------|-------|
| Última actualización | 18/06/2026 |
| Plan vigente | ROADMAP v3.0 — 18 labs alineados a CRTO (`docs/design/ROADMAP.md`) |
| Labs completados | 7 / 18 |
| Fase actual | Phase-03 en autoría · Lab-08 Black Beacon (concepto) validado v3.1 |
| Horas totales invertidas | ~143h |

---

## 📈 Progreso por Fase

### 🟢 Phase-01 — Fundamentos y Pivotaje

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-01: Ghost Forest | ✅ Validado v3.1 | 09/05/2026 | 20/05/2026 | ~40h | ✅ Referencia |
| Lab-02: Silent Bridge | ✅ Validado v3.1 | 13/05/2026 | 15/05/2026 | ~18h | ✅ Referencia |
| Lab-03: Dark Gate | ✅ Validado v3.1 | 16/05/2026 | 17/05/2026 | ~16h | ✅ Referencia |

### 🟡 Phase-02 — AD Avanzado

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-04: Iron Forest | ✅ Validado v3.1 | 28/05/2026 | 29/05/2026 | ~20h | ✅ Referencia |
| Lab-05: Silver Chain | ✅ Validado v3.1 | 30/05/2026 | 30/05/2026 | ~20h | ✅ Referencia |
| Lab-06: Black Policy | ✅ Validado v3.1 | 01/06/2026 | 01/06/2026 | ~25h | ✅ Referencia |
| Lab-07: Shadow Vault | ✅ Validado v3.1 | 06/06/2026 | 06/06/2026 | ~8h | ✅ Referencia |

### 🔴 Phase-03 — Red Team Operations (C2, host, evasión)

| Lab | Estado | Bloque CRTO | Horas | Writeup |
|-----|--------|-------------|-------|---------|
| Lab-08: Black Beacon | ✅ Concepto v3.1 | C2 / modelo operador | — | — |
| Lab-09: First Contact | ✅ Concepto v3.1 | Situational Awareness & Host Recon | — | — |
| Lab-10: Deep Root | ✅ Operación v3.1 (plan) | Host Persistence & PrivEsc | — | — |
| Lab-11: Ghost Signal | ✅ Concepto v3.1 | Evasión I — Defender/AMSI/ETW | — | — |
| Lab-12: Iron Veil | ✅ Concepto v3.1 | Evasión II — AppLocker/CLM/LOLBAS | — | — |

### 🏴 Phase-04 — Enterprise & Exam (maestría AD, C2 avanzado, capstone)

| Lab | Estado | Bloque CRTO | Horas | Writeup |
|-----|--------|-------------|-------|---------|
| Lab-13: Linked Shadows | ✅ Operación v3.1 (plan) | MSSQL: linked servers, xp_cmdshell | — | — |
| Lab-14: Golden Throne | ✅ Operación v3.1 (plan) | Domain Dominance & Persistence | — | — |
| Lab-15: Forest Reign | ✅ Operación v3.1 (plan) | Forest & Trust Abuse | — | — |
| Lab-16: Custom Arsenal | ⏳ Pendiente | Extending the C2 (BOFs/Malleable/Aggressor) | — | — |
| Lab-17: Silent Exit | ⏳ Pendiente | Data Exfiltration & Reporting | — | — |
| Lab-18: Final Verdict | ⏳ Pendiente | Capstone — Exam Simulation | — | — |

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


### Semana 10 — 04-05/06/2026

#### 04/06/2026 — Sesion 23: DC-01 rebuild WS2025 + Setup completo infraestructura

**DC-01 Rebuild — Windows Server 2025:**
- DC-01 eliminado (WS2022 Build 20348.558 incompatible con Windows LAPS nativo)
- Nueva VM con Windows Server 2025 (Build 26100+)
- Scripts de provisioning 01-14 re-ejecutados en todas las maquinas
- SQL Server 2022 Express instalado (22GB RAM necesarios para instalacion fluida)
- ADCS: CA AtackCorp-CA + Web Enrollment operativos
- Windows LAPS nativo configurado y verificado
- Defender con exclusiones controladas configurado
- Forest Trusts reconfigurados via .NET (netdom falla en WS2025)
- WKSTN-01 re-unida al dominio nuevo

**CrownJewels:**
- Labs 01-07 ejecutados en nuevo DC-01

**Lecciones tecnicas clave:**
- WS2025: New-ADTrust no existe, netdom /quarantine falla
- SQL Server instalacion silenciosa bloquea con < 12GB RAM
- DC-03 necesario para schema extension (Schema FSMO)
- C:\Temp SID fix: WellKnownSidType.WorldSid

**Horas sesion:** ~10h

---

#### 05/06/2026 — Sesion 24: Reorganizacion repo + Documentacion

**Reorganizacion setup/:**
- Nueva estructura por maquina: DC-01, DC-02, DC-03, DC-04, WKSTN-01, WKSTN-02, CrownJewels
- Scripts con nombres descriptivos (01_promover_controlador_de_dominio_atackcorp.ps1, etc.)
- Todos los fixes aplicados en los scripts reescritos
- Script Deploy-SetupScripts.ps1 para despliegue automatico
- 35 archivos cambiados, 1774 inserciones

**Documentacion:**
- RULES_OF_ENGAGEMENT.md — nuevo documento operacional
- CREDENTIALS.md v2.0 — actualizado con todas las credenciales
- CHANGELOG.md — entrada completa del rebuild
- setup/README.md v3.0 — guion completo con orden de ejecucion

**Horas sesion:** ~4h

**Total acumulado:** ~135h


---

### Semana 11 — 06/06/2026

#### Sesiones 25-26: Lab-07 SHADOW VAULT — Ejecución completa

**Fases ejecutadas:**
- Fase 01 ✅ LAPS Password Extraction — nxc laps → WKSTN-01\Administrador:@98q6$13Z{K99;
- Fase 02 ✅ DPAPI Credential Extraction — impacket-dpapi → sa:SQLsa2026! + helpdesk.ruiz:Helpdesk2024!
- Fase 03 ⚠️ LSASS Dump — Bloqueado por Windows 11 23H2+ KPP (documentado)
- Fase 04 ✅ Shadow Credentials — pywhisker + certipy-ad → NT hash WKSTN-01$
- Fase 05 ✅ C2 + OPSEC Cleanup — Sliver SUPPORTING_NECKLACE + artefactos eliminados

**Loot:**
- WKSTN-01\Administrador : @98q6$13Z{K99; (LAPS msLAPS-Password)
- sa : SQLsa2026! (DPAPI — DC-01\SQLEXPRESS)
- helpdesk.ruiz : Helpdesk2024! (DPAPI — portal-it)
- WKSTN-01$ NT hash : 5bcb127196e1fd7cc35e3d62066cabe3 (Shadow Credentials)

**Problemas resueltos:**
- WS2025 LAPS cifrado GKDI → deshabilitar ADPasswordEncryptionEnabled
- helpdesk.ruiz sin grupos locales en WKSTN-01 → WKSTN-01 v3.1 script actualizado
- WinRM SDDL no incluía helpdesk.ruiz → Set-PSSessionConfiguration con SID
- Evil-WinRM requiere DOMINIO\usuario para usuarios de dominio
- LSASS dump bloqueado en Windows 11 23H2+ → documentado para Labs 08-11
- Firewall se reactiva tras reinicio → Set-NetFirewallProfile en provisioning

**Scripts actualizados:**
- setup/WKSTN-01 v3.1, setup/DC-01/12_laps v1.1, CrownJewels-Lab07 v2.0
- tooling/arsenal_setup.sh v2.3, tooling/lab_start.sh v2.0

**Horas sesión:** ~8h | **Total acumulado: ~143h**

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
| WriteDACL Abuse → DCSync | T1222 + T1003.006 | Lab-04 | ✅ Dominada |
| Credential Hunting — Files/PS History | T1552.001 | Lab-04 | ✅ Dominada |
| Overpass-the-Hash (impacket-getTGT) | T1550.003 | Lab-04 | ✅ Dominada |
| ADIDNS Abuse — WPAD Poisoning | T1557.001 | Lab-04 | ✅ Dominada |
| NTLMv2 Capture (Responder) | T1557.001 | Lab-04 | ✅ Dominada |
| C2 HTTP Beacon (Sliver) | T1071.001 | Lab-04 | ✅ Dominada |
| OPSEC Cleanup (dacledit remove + dnstool) | T1070 | Lab-04 | ✅ Dominada |
| RBCD S4U2Self+S4U2Proxy | T1558.001 | Lab-05 | ✅ Dominada |
| Shadow Credentials (msDS-KeyCredentialLink) | T1556 | Lab-05 | ✅ Dominada |
| PKINIT Authentication | T1649 | Lab-05 | ✅ Dominada |
| Silver Ticket | T1558.002 | Lab-05 | ✅ Dominada |
| Diamond Ticket (bypass PAC Validation) | T1558.001 | Lab-05 | ✅ Dominada |
| MachineAccountQuota Abuse | T1136.002 | Lab-05 | ✅ Dominada |
| kirbi→ccache conversion | T1550.003 | Lab-05 | ✅ Dominada |
| Kerberos Ticket Forging | T1558 | Lab-05 | ✅ Dominada |
| Indicator Removal (RBCD/Shadow Creds) | T1070 | Lab-05 | ✅ Dominada |
| Pass-the-Ticket (impacket-smbclient) | T1550.003 | Lab-05 | ✅ Dominada |

---

## 📋 Pendientes por lab

| Lab | Pendiente | Prioridad |
|-----|----------|-----------|
| Lab-06 | BLACK POLICY — SID History, Cross-Forest Trust, GPO abuse avanzado | Alta |
| Lab-07 | SHADOW VAULT — LAPS, DPAPI, Shadow Credentials | Alta |
| Lab-08 | GHOST SIGNAL — AMSI bypass, Process injection, syscalls directas | Alta |
| Lab-09 | FIRST CONTACT — Initial Access real sin credenciales | Alta |
| Lab-10 | DARK CURRENT — Havoc C2, BOFs, sleep obfuscation | Media |
| Lab-11 | DEEP HOLO — Simulación multicapa, EDR evasion real | Media |
| Lab-12 | RED DANTE — Red masiva mixta, persistencia multicapa, exfiltración | Media |
| Lab-13 | DEEP WATER — Forest Trusts avanzados, preparación CRTO | Media |
| Lab-14 | AZURE BREACH — Azure AD/Entra ID hybrid attacks | Alta |
| Lab-15 | OPERATION ZEPHYR — Supply chain, simulación final CRTO | Media |
| Lab-02 | Segundo pivote (tercer segmento de red) | Media |
| Lab-02 | Setup-Lab02-SilentBridge.sh (bash — PROD + GIT setup Ubuntu) | Baja |

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

---

### Semana 6 — 28/05/2026 al 29/05/2026

#### 📌 28/05/2026 — Sesión 14: Lab-04 IRON FOREST — Fases 01-03
- BloodHound CE instalado via Docker en `~/tools/ad/bloodhound-ce/` (Neo4j 4.4 + APOC)
- Docker + docker compose v2.27.0 instalados en Kali
- RAM VMs optimizada: Kali 8GB, DC-01 4GB, WKSTN-01 3GB
- SharpHound v2.5.9 descargado y ejecutado desde WKSTN-01 — 358 objetos recolectados
- BloodHound CE confirma: `fin.garcia → WriteDACL → ATACKCORP.LOCAL`
- Fase 02: share `\\DC-01\IT-Scripts` — 4 credenciales en claro + historial PS Administrador
- 6 credenciales totales incluyendo `fin.garcia:Finance2024!` y `Administrador:NuevaPassword2026!`
- Fase 03: TGT Kerberos fin.garcia via impacket-getTGT — válido 10h
- krb5-user instalado para klist
- **Horas:** ~8h

#### 📌 29/05/2026 — Sesión 15: Lab-04 IRON FOREST — Fases 04-08
- Fase 04: WriteDACL → dacledit write DCSync rights (ACE[15]+ACE[19] confirmados)
- Fase 05: DCSync con fin.garcia (no-DA) → hash Administrador + krbtgt + todos los usuarios
- Fase 06: ADIDNS — `wpad.atackcorp.local → 10.0.2.9`, DNS Block List desactivado, Responder NTLMv2 capturado
- Fase 07: Sliver beacon `iron_forest_dc01` en DC-01 como ATACKCORP\Administrador
- Fase 08: Cleanup OPSEC — DCSync rights eliminados, WPAD tombstoned, beacon borrado del disco
- Documentación completa: 8 docs de ejecución + lessons_learned (13 lecciones) + OPERATION_IRON_FOREST.md
- **Horas:** ~12h

---

### Semana 7 — 30/05/2026

#### 📌 30/05/2026 — Sesión 16: Lab-05 SILVER CHAIN — Fases 01-06 + Documentación completa

- Fase 01: SharpHound v2.5.9 desde WKSTN-01 — 354 objetos · BloodHound CE confirma GenericWrite paths
- Fase 02: RBCD Abuse — ATTACKER$ via MAQ · S4U2Self+S4U2Proxy → TGS como Administrador@WKSTN-01 ✅
- Fase 03: Shadow Credentials — pywhisker → msDS-KeyCredentialLink · certipy-ad PKINIT → iis_svc NTLM hash ✅
- Fase 04: Silver Ticket — hash iis_svc NTLM → TGS MSSQLSvc/DC-01:1433 forjado localmente ✅
- Fase 05: Diamond Ticket — krbtgt AES256 via DCSync · Rubeus diamond → TGT real + PAC modificado · bypass PAC Validation ✅
- Fase 06: C2 + Cleanup — beacon LIGHT_CARTLOAD WKSTN-01 · ATTACKER$ eliminado · Shadow Creds limpiadas ✅
- Problemas resueltos: pywhisker/impacket conflict, Evil-WinRM Kerberos, SQL Server instalado, SharpHound placeholder
- Documentación completa: 10 docs execution/analysis + OPERATION actualizado + docs globales
- **Horas:** ~20h

**Total Lab-04:** ~20h

---

### Semana 8 — 31/05/2026

#### 31/05/2026 — Sesion 17: Infraestructura CRTO completa + Setup Lab-06

**Infraestructura ampliada — 3 forests como el examen CRTO:**
- DC-02 (10.0.2.11) — corp.local — nuevo forest instalado y configurado
- DC-03 (10.0.2.13) — child.atackcorp.local — child domain de atackcorp.local
- DC-04 (10.0.2.14) — ext.local — tercer forest independiente
- WKSTN-02 (10.0.2.12) — workstation unida a corp.local
- Forest Trusts BiDirectional: atackcorp ↔ corp ↔ ext
- SID Filtering deshabilitado en todos los trusts
- DNS Conditional Forwarders configurados en los 4 DCs

**Scripts generados:**
- 07_Setup_DC02_Corp.ps1, 08_Setup_DC03_Child.ps1, 09_Setup_DC04_Ext.ps1
- 10_Setup_Trusts_And_SIDHistory.ps1, 11_Setup_WKSTN02_Corp.ps1
- 06_wkstn01.ps1 corregido (sin Enable-PSRemoting)

**Problemas resueltos:**
- Enable-PSRemoting dentro de scripts Evil-WinRM corta la conexion → ejecutar manualmente antes
- Cuenta Administrador inactiva en Windows 11 → net user Administrador /active:yes
- WKSTNs perdian trust al dominio tras reinstalacion → rejoinar manualmente
- Evil-WinRM upload con nombres numerados genera punto extra → usar .\. prefix

**Horas:** ~6h

*⚡ Leyenda: ✅ Completado | 🔄 Parcial | ⏳ Pendiente*
---

### Semana 9 — 01/06/2026


#### 📌 01/06/2026 — Sesión 19: Lab-06 BLACK POLICY — Fase 03 Cross-Forest Trust Abuse

**Lab-06 Fase 03 — Cross-Forest Trust Abuse:**

**Path A — corp.local via Targeted Kerberoasting:**
- dacledit confirma john.smith GenericAll (FullControl 0xf01ff) sobre corp_svc ✅
- bloodyAD set SPN fake/dc02.corp.local en corp_svc via GenericAll ✅
- Targeted Kerberoasting → hash corp_svc `$krb5tgs$23$*corp_svc$CORP.LOCAL*` capturado ✅
- John crackea CorpSvc2024! con wordlist corporativa ✅
- Evil-WinRM DC-02 como corp.admin (DA corp.local) ✅
- DCSync krbtgt corp.local: NTLM 3e30210f... · AES256 42ebdb6b... ✅
- OPSEC cleanup: SPN restaurado a MSSQLSvc/DC-02.corp.local:1433 ✅

**Path B — ext.local via Credential Exposure:**
- Share Ext-Data accesible con ext.user:ExtUser2024! ✅
- credentials_backup.txt descargado: ext.admin/ExtAdmin2024! + ext_svc/ExtSvc2024! ✅
- Evil-WinRM DC-04 como ext.admin (DA ext.local) ✅
- DCSync krbtgt ext.local: NTLM 5c8afa0a... · AES256 90be6556... ✅

**Problemas resueltos:**
- Share Ext-Data no creado en provisioning — "Everyone" falla en Windows español → usar SID *S-1-1-0
- corp_svc sin acceso WinRM — comportamiento correcto (cuenta de servicio)
- impacket-secretsdump falla fuera del directorio del lab — siempre ejecutar desde el lab

**Horas:** ~3h

---

## 🏆 Técnicas Dominadas — Actualizado 06/06/2026

| Técnica | MITRE ID | Lab | Nivel |
|---------|----------|-----|-------|
| Targeted Kerberoasting via GenericAll | T1558.003 | Lab-06 | ✅ Dominada |
| ACL Abuse cross-forest (dacledit) | T1222 | Lab-06 | ✅ Dominada |
| Forest Trust credential exposure | T1552.001 | Lab-06 | ✅ Dominada |
| bloodyAD SPN manipulation | T1558.003 | Lab-06 | ✅ Dominada |
| DCSync multi-forest | T1003.006 | Lab-06 | ✅ Dominada |

#### 📌 01/06/2026 — Sesión 18: Lab-06 BLACK POLICY — Fases 01-02 + Provisioning completo

**Provisioning infraestructura completa:**
- DC-02, DC-03, DC-04, WKSTN-01 (reinstalada), WKSTN-02 provisionados
- Forest Trusts BiDirectional operativos: atackcorp ↔ corp ↔ ext
- SID Filtering OFF en todos los trusts — CrownJewels ejecutados en DC-01
- Fixes v1.1: 08_setup_DC03_Child.ps1 (DNS primario DC-01, ADWS port 9389, C:\Temp)
- arsenal_setup.sh v2.1: bloodyad, mimikatz, DSInternals v4.14 añadidos

**Lab-06 Fase 01 — Reconnaissance:**
- Host discovery 10.0.2.0/24 — DC-01/02/04 activos
- Port scan completo tres DCs — MSSQL 1433 en DC-01 (hallazgo adicional)
- SMB enum: IT-Scripts share DC-01 → 4 credenciales en texto claro (backup_svc DA, iis_svc, sa, webapp_db)
- LDAP anonymous bind tres forests — naming contexts confirmados
- Cross-forest Kerberoasting: corp_svc (CorpSvc2024!) + ext_svc (ExtSvc2024!) crackeados con wordlist dirigida

**Lab-06 Fase 02 — SID History Injection:**
- Evil-WinRM DC-03 como child.admin (child.atackcorp.local)
- SID DA atackcorp.local obtenido via .NET NTAccount.Translate() — workaround Evil-WinRM token limitado
- DSInternals v4.14 subido via Evil-WinRM → Add-ADDBSidHistory con Force
- child.user SIDHistory = S-1-5-21-768292631-183641691-1245477636-512 (DA atackcorp.local) ✅
- Evil-WinRM DC-01 como child.user — whoami /groups confirma DA cross-domain ✅
- DCSync krbtgt atackcorp.local: NTLM d5237a2e... · AES256 2f123c9b... ✅

**Problemas resueltos:**
- Evil-WinRM Get-ADGroup cross-domain falla (token red) → .NET NTAccount.Translate() como workaround
- bloodyad v2.5.4 elimina add sidHistory — sIDHistory protegido en AD, no modificable via LDAP
- mimikatz misc::addsid eliminado en v2.2.0+ → DSInternals como herramienta preferida
- DC-03 DNS primario incorrecto → Set-DnsClientServerAddress a DC-01
- DC-01 ADWS puerto 9389 cerrado → netsh firewall rule añadida
- Defender bloquea mimikatz en upload → Set-MpPreference -DisableRealtimeMonitoring $true

**Horas:** ~15h

---

## 🏆 Técnicas Dominadas — Actualizado 06/06/2026

| Técnica | MITRE ID | Lab | Nivel |
|---------|----------|-----|-------|
| SID History Injection | T1134.005 | Lab-06 | ✅ Dominada |
| Cross-Forest Kerberoasting | T1558.003 | Lab-06 | ✅ Dominada |
| Trust Discovery multi-forest | T1482 | Lab-06 | ✅ Dominada |
| DSInternals — ntds.dit manipulation | T1003.003 | Lab-06 | ✅ Dominada |
| Credential Hunting cross-forest SMB | T1552.001 | Lab-06 | ✅ Dominada |
| DCSync cross-domain (SID History) | T1003.006 | Lab-06 | ✅ Dominada |
| .NET NTAccount LDAP translation | T1087.002 | Lab-06 | ✅ Dominada |
| Windows LAPS Password Disclosure | T1201 | Lab-07 | ✅ Dominada |
| DPAPI offline credential extraction | T1555.004 | Lab-07 | ✅ Dominada |
| Shadow Credentials (msDS-KeyCredentialLink) | T1649 | Lab-07 | ✅ Dominada |
| PKINIT auth — certipy-ad | T1649 | Lab-07 | ✅ Dominada |
| LSASS dump evasion research | T1003.001 | Lab-07 | ⚠️ Parcial (KPP Win11) |