# 📊 Progress Tracker — Red Team Ops Roadmap

> Diario de progreso del roadmap hacia la certificación CRTO.  
> Actualizado manualmente tras cada sesión de trabajo.

---

## 🧭 Estado General

| Métrica | Valor |
|---------|-------|
| Fecha de inicio | 09/05/2026 |
| Última actualización | 13/05/2026 |
| Labs completados | 1 / 12 |
| Labs en progreso | 0 / 12 |
| Horas totales invertidas | ~26h |
| Fase actual | Phase-01: Fundamentals |

---

## 📈 Progreso por Fase

### 🟢 Phase 01 — Fundamentos y Pivotaje

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-01: Attacktive Directory | ✅ Completado | 09/05/2026 | 13/05/2026 | ~26h | ✅ Completo |
| Lab-02: Wreath | ⏳ Pendiente | — | — | — | — |
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

#### 📌 09/05/2026
**Sesión 1 — Setup inicial del proyecto**
- Creación del repositorio `RedTeam-Ops-Roadmap` en GitHub
- Definición de la estructura de fases y labs
- Setup del entorno VirtualBox: DC-01, WKSTN-01, Kali
- Red NAT `LabRedTeam` configurada en segmento `10.0.2.0/24`
- **Horas:** ~3h

#### 📌 10/05/2026
**Sesión 2 — Lab-01: Infraestructura y AS-REP Roasting**
- Script PowerShell de aprovisionamiento del DC ejecutado
- Dominio `atackcorp.local` configurado con usuarios y vectores inyectados
- AS-REP Roasting completado: hashes extraídos con `GetNPUsers` — `ceo.martinez` y `backup_svc`
- Cracking con diccionario dirigido OSINT: `Direccion2024!` y `Backup2024!`
- Acceso interactivo conseguido vía Evil-WinRM como `ceo.martinez`
- **Horas:** ~2h

#### 📌 11/05/2026
**Sesión 3 — Documentación parcial y arsenal**
- Documentación parcial: `infrastructure_setup.md`, `exploitation.md`, `enumeration_log.md`, `post-exploitation.md`
- Arsenal completo instalado en Kali
- Generación de `ARSENAL.md` y `LAB_INFRASTRUCTURE.md`
- **Horas:** ~1h

---

### Semana 2 — 12/05/2026 al 13/05/2026

#### 📌 12/05/2026
**Sesión 4 — Fases 4-5: Discovery + Kerberoasting → Domain Admin**

- **Fase 4 — Discovery (T1082, T1087.002, T1069.002, T1018, T1558.003)**
  - Enumeración completa del dominio: usuarios, grupos, SPNs, descriptions, equipos
  - Identificación de 3 attack paths hacia Domain Admin
  - Hallazgo: `backup_svc` con SPN + DA membership + password en Description
  - Hallazgo: `sql_svc` con Unconstrained Delegation
  - Capturas: `fase4-01` a `fase4-06`

- **Fase 5 — Kerberoasting (T1558.003)**
  - `impacket-GetUserSPNs` → 3 hashes TGS capturados (sql_svc, iis_svc, backup_svc)
  - John the Ripper + diccionario custom → `backup_svc:Backup2024!` crackeado
  - Evil-WinRM como `backup_svc` → **Domain Admin confirmado**
  - Capturas: `fase5-01` a `fase5-04`

- **Problemas encontrados:**
  - DCSync bloqueado (token de sesión cacheado) → pivote a Kerberoasting
  - Hashcat sin GPU en VirtualBox → John the Ripper como alternativa
  - DNS de Kali mal configurado → fix `nmcli` con DNS al DC

- **Horas:** ~8h

#### 📌 13/05/2026
**Sesión 5 — Fases 6-10: Lateral Movement, C2, LPE, Golden Ticket, Objective**

- **Fase 6 — Lateral Movement (T1021.006)**
  - Nmap WKSTN-01 → puerto 5985 WinRM abierto
  - Evil-WinRM como `backup_svc` → shell DA en WKSTN-01
  - Fix de red: IP estática Kali via NetworkManager
  - Capturas: `fase6-00` a `fase6-02`

- **Fase 7 — C2 Sliver (T1071.001, T1573.002)**
  - Instalación Sliver v1.7.3 desde script oficial
  - Listener HTTPS :443 configurado
  - Beacon `EASY_PROFIT` generado (windows/amd64, symbol obfuscation)
  - Upload via Evil-WinRM + ejecución `Start-Process -WindowStyle Hidden`
  - Beacon conectado: `be691c17 EASY_PROFIT — WKSTN-01 — ATACKCORP\backup_svc`
  - Capturas: `fase7-01` a `fase7-05`

- **Fase 8 — Privilege Escalation (T1134.001, T1562.001)**
  - `getprivs` → SeImpersonatePrivilege habilitado
  - Tamper Protection deshabilitada desde GUI
  - Defender deshabilitado via `Set-MpPreference`
  - SweetPotato (PrintSpoofer, DCOM, WinRM) → todos fallaron (limitación WinRM/Win11)
  - Decisión táctica: beacon DA suficiente para objetivos
  - Capturas: `fase8-01` a `fase8-05`

- **Fase 9 — Golden Ticket (T1558.001, T1003.006)**
  - DCSync krbtgt → NT hash + AES256 obtenidos
  - `impacket-ticketer` → ticket forjado (3650 días)
  - `KDC_ERR_TGT_REVOKED` → PAC Validation en Windows Server 2022
  - Capturas: `fase9-01` a `fase9-03`

- **Fase 10 — Objective Completion (T1003.006, T1550.002)**
  - DCSync `Administrador` → NT hash `b73fdfe10e87b4ca5c0d957f81de6863`
  - Pass-the-Hash via Evil-WinRM → shell como `atackcorp\administrador`
  - Grupos confirmados: DA + EA + Schema Admins — **dominio comprometido**
  - Capturas: `fase10-01`, `fase10-02`

- **Documentación generada:**
  - `lateral_movement.md`, `privilege_escalation.md`, `persistence.md`, `objective_completion.md`
  - `mitigations.md`, `lessons_learned.md`
  - `README.md` actualizado (Lab-01 completado, badge 1/12)
  - `PROGRESS.md` actualizado (este fichero)

- **Horas:** ~12h

---

## 🧠 Lecciones Aprendidas

### Lab-01 — Attacktive Directory

| # | Lección | Categoría |
|---|---------|-----------|
| 1 | IP estática en Kali via NetworkManager, no `ip addr add` — persiste entre sesiones | Infraestructura |
| 2 | Usar SIDs universales para grupos built-in en entornos en español | Scripting |
| 3 | El nombre built-in `Administrator` es `Administrador` en español | Localización |
| 4 | Añadir `sessionresume_*` al `.gitignore` desde el inicio | Git |
| 5 | Diccionario dirigido OSINT > rockyou.txt en entornos corporativos | Cracking |
| 6 | Permisos AD aplican en el siguiente logon del usuario, no inmediatamente | Active Directory |
| 7 | Verificar SPNs registrados tras setup — bug de interpolación en `try/catch` PowerShell | Scripting |
| 8 | Golden Ticket clásico falla en Windows Server 2022 por PAC Validation | Kerberos |
| 9 | Potato attacks requieren token interactivo — WinRM genera tokens de red | LPE |
| 10 | AMSI es independiente de las exclusiones de carpeta de Defender | AV Evasion |
| 11 | Documentar fallos con análisis técnico es tan valioso como documentar éxitos | Documentación |
| 12 | Definir nomenclatura de capturas antes de empezar el lab | Documentación |

> 📄 Lecciones detalladas con causa raíz y solución: [Lab-01/docs/lessons_learned.md](./Phase-01-Fundamentals/Lab-01-Attacktive-Directory/docs/lessons_learned.md)

---

## 🏆 Técnicas Dominadas

| Técnica | MITRE ID | Lab | Nivel |
|---------|----------|-----|-------|
| AS-REP Roasting | T1558.004 | Lab-01 | ✅ Dominada |
| Kerberoasting | T1558.003 | Lab-01 | ✅ Dominada |
| DCSync | T1003.006 | Lab-01 | ✅ Dominada |
| Pass-the-Hash | T1550.002 | Lab-01 | ✅ Dominada |
| WinRM Lateral Movement | T1021.006 | Lab-01 | ✅ Dominada |
| C2 Sliver (beacon HTTPS) | T1071.001 | Lab-01 | ✅ Dominada |
| ACL Abuse (DCSync perms) | T1484.001 | Lab-01 | ✅ Dominada |
| Impair Defenses | T1562.001 | Lab-01 | ✅ Dominada |
| Golden Ticket | T1558.001 | Lab-01 | 🔄 Parcial (PAC Validation) |
| Token Impersonation | T1134.001 | Lab-01 | 🔄 Parcial (WinRM limitación) |
| Password in Description | T1087.002 | Lab-01 | ✅ Dominada |

---

## 🔧 Problemas Encontrados y Soluciones

| Fecha | Problema | Causa | Solución |
|-------|---------|-------|---------|
| 12/05/2026 | DCSync `ACCESS_DENIED` pese a ACL correcta | Token de sesión cacheado pre-permisos | Pivotar a Kerberoasting |
| 12/05/2026 | Hashcat falla en VirtualBox | Sin GPU disponible | John the Ripper (CPU) |
| 12/05/2026 | Kali no resuelve dominio | DNS no apunta al DC | `nmcli` con `ipv4.dns 10.0.2.10` |
| 13/05/2026 | WKSTN-01 no alcanzable | VM apagada / IP Kali sin ruta | Encender VM + `ip route add` |
| 13/05/2026 | SweetPotato falla (todos los métodos) | WinRM genera Network tokens | Decisión táctica: beacon DA suficiente |
| 13/05/2026 | Golden Ticket revocado | PAC Validation Windows Server 2022 | Pass-the-Hash como alternativa |
| 13/05/2026 | AMSI bloquea SweetPotato.ps1 | Escaneo en memoria independiente de exclusiones | Deshabilitar script scanning |
| 13/05/2026 | `"Domain Admins"` no encontrado | Windows en español → `Admins. del dominio` | Usar SID-512 universal |
| 13/05/2026 | SPN registrado vacío (`MSSQLSvc/`) | Bug interpolación variable en `try/catch` PS | Hardcodear SPN como literal |

---

## 📚 Recursos Consultados

| Recurso | Tipo | Lab relacionado |
|---------|------|----------------|
| [HackTricks - AS-REP Roasting](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/asreproast) | Documentación | Lab-01 |
| [HackTricks - Kerberoasting](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/kerberoast) | Documentación | Lab-01 |
| [Impacket - secretsdump](https://github.com/fortra/impacket) | Tool docs | Lab-01 |
| [Evil-WinRM GitHub](https://github.com/Hackplayers/evil-winrm) | Tool docs | Lab-01 |
| [Sliver C2 Docs](https://sliver.sh/docs) | Tool docs | Lab-01 |
| [ired.team - DCSync](https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/dump-password-hashes-from-domain-controller-with-dcsync) | Documentación | Lab-01 |
| [MITRE ATT&CK - APT29](https://attack.mitre.org/groups/G0016/) | Framework | Lab-01 |
| [SweetPotato GitHub](https://github.com/CCob/SweetPotato) | Tool docs | Lab-01 |

---

*⚡ Leyenda de estados:*  
✅ Completado | 🔄 En progreso | ⏳ Pendiente | ❌ Bloqueado