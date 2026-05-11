# 📊 Progress Tracker — Red Team Ops Roadmap

> Diario de progreso del roadmap hacia la certificación CRTO.  
> Actualizado manualmente tras cada sesión de trabajo.

---

## 🧭 Estado General

| Métrica | Valor |
|---------|-------|
| Fecha de inicio | 09/05/2026 |
| Última actualización | 11/05/2026 |
| Labs completados | 0 / 12 |
| Labs en progreso | 1 / 12 |
| Horas totales invertidas | ~6h |
| Fase actual | Phase-01: Fundamentals |

---

## 📈 Progreso por Fase

### 🟢 Phase 01 — Fundamentos y Pivotaje

| Lab | Estado | Fecha inicio | Fecha fin | Horas | Writeup |
|-----|--------|-------------|-----------|-------|---------|
| Lab-01: Attacktive Directory | 🔄 En progreso | 09/05/2026 | — | ~6h | Parcial |
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
- Dominio `attackitivedirectory.local` configurado
- Vulnerabilidades inyectadas: AS-REP Roasting (`svcadmin`), Kerberoasting (`sql_svc`)
- AS-REP Roasting completado: hash extraído con `GetNPUsers.py` y crackeado con John
- Credenciales obtenidas: `svcadmin:Laboratorio123`
- Acceso interactivo conseguido vía Evil-WinRM
- **Horas:** ~2h

#### 📌 11/05/2026
**Sesión 3 — Documentación y arsenal**
- Documentación parcial en VSCode: `infrastructure_setup.md`, `exploitation.md`, `enumeration_log.md`, `post-exploitation.md`
- Reporte PDF generado: `Reporte Laboratorio Attacktive Directory.pdf`
- BloodHound 9.0 instalado (adaptador NAT temporal)
- Arsenal completo instalado en Kali
- Generación de `ARSENAL.md` y `LAB_INFRASTRUCTURE.md`
- Nueva infraestructura planificada: `atackcorp.local` con vectores extendidos
- **Pendiente:** Kerberoasting contra `sql_svc`, BloodHound collection
- **Horas:** ~1h

---

## 🧠 Lecciones Aprendidas

### Lab-01

| # | Lección | Categoría |
|---|---------|-----------|
| 1 | El error `referral: DSID-03100838` en Impacket indica fallo DNS, no de credenciales. Solución: `echo "nameserver <DC_IP>" > /etc/resolv.conf` | Troubleshooting |
| 2 | En redes NAT aisladas sin salida a internet, añadir un segundo adaptador NAT temporal para instalar herramientas y eliminarlo después | Infraestructura |
| 3 | AS-REP Roasting requiere que `DoesNotRequirePreAuth = True`. Verificar en DC con `Get-ADUser -Identity <user> -Properties DoesNotRequirePreAuth` | Kerberos |
| 4 | `SeImpersonatePrivilege` + `SeMachineAccountPrivilege` son señales claras de vector LPE via PrintSpoofer/GodPotato | Post-Explotación |

---

## 🏆 Técnicas Dominadas

| Técnica | MITRE ID | Lab | Nivel |
|---------|----------|-----|-------|
| AS-REP Roasting | T1558.004 | Lab-01 | ✅ Dominada |
| Kerberoasting | T1558.003 | Lab-01 | 🔄 En progreso |
| Token Impersonation | T1134.001 | Lab-01 | 🔄 En progreso |
| Unquoted Service Path | T1574.009 | Lab-01 | 📖 Estudiada |

---

## 🔧 Problemas Encontrados y Soluciones

| Fecha | Problema | Causa | Solución |
|-------|---------|-------|---------|
| 11/05/2026 | `GetUserSPNs` falla con `referral` error | DNS no resuelve el dominio + typo en nombre | Añadir DC como nameserver + corregir nombre |
| 11/05/2026 | `apt install bloodhound` falla sin internet | VM en red NAT interna sin salida | Añadir Adaptador 2 NAT en VirtualBox temporalmente |

---

## 📚 Recursos Consultados

| Recurso | Tipo | Lab relacionado |
|---------|------|----------------|
| [HackTricks - AS-REP Roasting](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/asreproast) | Documentación | Lab-01 |
| [Impacket GetNPUsers](https://github.com/fortra/impacket/blob/master/examples/GetNPUsers.py) | Tool docs | Lab-01 |
| [ired.team - Kerberoasting](https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/t1208-kerberoasting) | Documentación | Lab-01 |
| [Evil-WinRM GitHub](https://github.com/Hackplayers/evil-winrm) | Tool docs | Lab-01 |

---

*⚡ Leyenda de estados:*  
✅ Completado | 🔄 En progreso | ⏳ Pendiente | ❌ Bloqueado