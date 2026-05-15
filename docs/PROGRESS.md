# 📊 Progress Tracker — Red Team Ops Roadmap

> Diario de progreso del roadmap hacia la certificación CRTO.  
> Actualizado manualmente tras cada sesión de trabajo.

---

## 🧭 Estado General

| Métrica | Valor |
|---------|-------|
| Fecha de inicio | 09/05/2026 |
| Última actualización | 15/05/2026 |
| Labs completados | 2 / 12 |
| Labs en progreso | 0 / 12 |
| Horas totales invertidas | ~44h |
| Fase actual | Phase-01: Fundamentals |

---

## 📈 Progreso por Fase

### 🟢 Phase 01 — Fundamentos y Pivotaje

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-01: Attacktive Directory | ✅ Completado | 09/05/2026 | 13/05/2026 | ~26h | ✅ Completo |
| Lab-02: Wreath | ✅ Completado | 13/05/2026 | 15/05/2026 | ~18h | ✅ Completo |
| Lab-03: Gatekeeper | ⏳ Pendiente | — | — | — | — |

### 🟡 Phase 02 — Post-Explotación y Abuso de AD

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-04: Forest | ⏳ Pendiente | — | — | — | — |
| Lab-05: Monteverde | ⏳ Pendiente | — | — | — | — |
| Lab-06: Support | ⏳ Pendiente | — | — | — | — |

### 🔴 Phase 03 — Red Team & Evasión de Defensas

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-07: Red Team Pathway | ⏳ Pendiente | — | — | — | — |
| Lab-08: AD Enum & Attacks | ⏳ Pendiente | — | — | — | — |
| Lab-09: Holo | ⏳ Pendiente | — | — | — | — |

### 🏴 Phase 04 — Simulación de Infraestructura Real

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-10: Dante | ⏳ Pendiente | — | — | — | — |
| Lab-11: Offshore | ⏳ Pendiente | — | — | — | — |
| Lab-12: Zephyr | ⏳ Pendiente | — | — | — | — |

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
- VMs PROD y GIT creadas con Ubuntu Server
- **Problema:** Ubuntu 26.04 incompatible con Webmin 1.890 → reinstalación con Ubuntu 22.04
- IPs estáticas: PROD (10.0.2.200 / 10.0.3.200), GIT (10.0.3.150)
- PC-01 Windows 11 creado en LabInternal (10.0.3.7)
- **Horas:** ~4h

#### 📌 14/05/2026 — Sesión 7: Lab-02 Fases 1-3
- Webmin 1.890 instalado en PROD con dependencias manuales
- **Fase 1:** Nmap → MiniServ 1.890 → CVE-2019-12840 identificado
- **Fase 2:** CVE-2019-15107 bloqueado por MINISERV_INTERNAL
  - Metasploit inoperativo → exploit Python construido desde `46984.rb`
  - Shell reversa `root@prod` ✅
- **Fase 3:** Ligolo-ng v0.7.5 → túnel TLS → red interna 10.0.3.0/24 enrutada ✅
- **Horas:** ~8h

#### 📌 15/05/2026 — Sesión 8: Lab-02 Fases 4-7 + documentación completa
- **Fase 4:** Git clone → `git show 992ecff` → `thomas:iamthegreatest` ✅
- **Fase 5:** Evil-WinRM → PC-01 Windows 11 (pc-01\thomas, Admin local) ✅
- **Fase 6:** Beacon `SUDDEN_COMMUNICATION` en PC-01 via relay PROD ✅
  - Beacon v1 fallaba → `listener_add` PROD → beacon v2 apuntando a 10.0.3.200
- **Fase 7:** schtasks + Registry Run Key + SAM dump + objetivo completado ✅
  - Hashes: `thomas:e1168d5763d3da51868e0fefc70d18e8`
- Documentación completa Lab-02
- **Horas:** ~6h

---

## 🏆 Técnicas Dominadas

| Técnica | MITRE ID | Lab | Nivel |
|---------|----------|-----|-------|
| AS-REP Roasting | T1558.004 | Lab-01 | ✅ Dominada |
| Kerberoasting | T1558.003 | Lab-01 | ✅ Dominada |
| DCSync | T1003.006 | Lab-01 | ✅ Dominada |
| Pass-the-Hash | T1550.002 | Lab-01 | ✅ Dominada |
| WinRM Lateral Movement | T1021.006 | Lab-01/02 | ✅ Dominada |
| C2 Sliver HTTPS | T1071.001 | Lab-01/02 | ✅ Dominada |
| Web RCE (CVE-2019-12840) | T1190 | Lab-02 | ✅ Dominada |
| Protocol Tunneling Ligolo-ng | T1572 | Lab-02 | ✅ Dominada |
| Relay C2 (Ligolo listener) | T1090 | Lab-02 | ✅ Dominada |
| Credential Discovery Git | T1552.001 | Lab-02 | ✅ Dominada |
| SAM Credential Dump | T1003.002 | Lab-02 | ✅ Dominada |
| Scheduled Task Persistence | T1053.005 | Lab-02 | ✅ Dominada |
| Exploit Python (weaponización) | T1587.001 | Lab-02 | ✅ Dominada |
| Golden Ticket | T1558.001 | Lab-01 | 🔄 Parcial (PAC Validation) |
| Token Impersonation | T1134.001 | Lab-01 | 🔄 Parcial (WinRM limitación) |

---

## 🔧 Incidencias globales

| Fecha | Problema | Solución |
|-------|---------|---------|
| 12/05 | DCSync bloqueado (token cacheado) | Pivotar a Kerberoasting |
| 12/05 | Hashcat sin GPU en VirtualBox | John the Ripper (CPU) |
| 13/05 | Golden Ticket KDC_ERR_TGT_REVOKED | Pass-the-Hash alternativa |
| 13/05 | Potato attacks fallan en WinRM | Beacon DA suficiente |
| 13/05 | Ubuntu 26.04 incompatible Webmin | Reinstalar Ubuntu 22.04 |
| 14/05 | CVE-2019-15107 MINISERV_INTERNAL | CVE-2019-12840 autenticado |
| 14/05 | Metasploit inoperativo | Exploit Python manual |
| 15/05 | WinRM perfil Público | `winrm quickconfig -force` |
| 15/05 | Beacon sin visibilidad hacia Kali | `listener_add` relay en PROD |

---

*⚡ Leyenda: ✅ Completado | 🔄 Parcial | ⏳ Pendiente*