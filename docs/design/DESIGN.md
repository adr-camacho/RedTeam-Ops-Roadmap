# DESIGN.md — Red Team Ops Roadmap
## Principios de Diseño, Metodología y Arquitectura

**Versión:** 2.1 | **Fecha:** 01/06/2026 | **Autor:** Adrián Camacho

---

## Historial de versiones

| Versión | Fecha | Cambios principales |
|---------|-------|---------------------|
| v1.0 | 09/05/2026 | Estructura inicial — 12 labs, 4 phases |
| v2.0 | 20/05/2026 | Rediseño completo — 14 labs, crown jewels, coverage matrix 80%, CRTO alignment |
| v2.1 | 01/06/2026 | Infraestructura CRTO completa — 3 forests, multi-DC, TTPs avanzadas Lab-06 |

---

## 1. Filosofía de Diseño

Este roadmap no es una colección de labs — es un **programa de formación estructurado** con un objetivo claro: transformar a alguien sin experiencia en Red Team en un profesional capaz de ejecutar engagements reales contra entornos corporativos modernos.

### Principios fundamentales

**1. Comprensión sobre ejecución**
Cada técnica se entiende a nivel de protocolo antes de automatizarla. Si una herramienta falla, el operador sabe construir el exploit desde cero.

**2. OPSEC como mentalidad, no como fase**
El OPSEC no es un capítulo al final del lab — es una pregunta constante. ¿Puedo hacer esto desde Kali sin tocar el objetivo? ¿Qué logs genera este comando? ¿Cómo limpio los artefactos?

**3. Realismo sobre velocidad**
Los labs incluyen crown jewels definidos, adversarios reales con TTPs documentadas, y comportamientos defensivos que reflejan entornos corporativos modernos (PAC Validation, Defender activo, AMSI).

**4. Blue Team integrado**
Cada técnica ofensiva viene acompañada de su contrapartida defensiva: Event IDs generados, reglas SIGMA, hardening recomendado. Un buen Red Teamer conoce cómo le detectan.

**5. Progresión pedagógica incremental**
Cada lab añade exactamente una capa de complejidad sobre el anterior. Nunca se introducen dos conceptos nuevos simultáneamente si uno de ellos puede esperar.

**6. Documentación honesta**
Los fallos se documentan con la misma profundidad que los éxitos. Una técnica que no funciona en un entorno moderno es una lección más valiosa que una que sí funciona.

**7. [NUEVO v2.1] Fidelidad al examen CRTO**
La infraestructura replica exactamente la del examen CRTO: multi-forest con trusts BiDirectional, SID Filtering configurable, child domains, y workstations unidas a dominios distintos. El objetivo no es aprobar el examen — es tener la competencia real que el examen certifica.

---

## 2. Adversary Emulation Methodology

El roadmap sigue el framework de **adversary emulation** — no ejecutamos técnicas genéricas sino que reproducimos comportamientos de grupos APT reales documentados en MITRE ATT&CK.

### Proceso por lab

```
1. Seleccionar adversario (APT29, APT41, APT28, Lazarus, APT10)
2. Estudiar sus TTPs documentadas en MITRE ATT&CK Groups
3. Diseñar el entorno que refleje un objetivo real del adversario
4. Ejecutar reproduciendo su comportamiento (no solo las técnicas)
5. Documentar diferencias entre el comportamiento ideal y el real
6. Analizar desde perspectiva Blue Team cómo detectar al adversario
```

### Adversarios y su justificación

| Adversario | Grupo MITRE | Fase | Justificación |
|-----------|-------------|------|---------------|
| **APT29** (Cozy Bear) | G0016 | Phase-01 | Especialistas en AD, Kerberos y ADCS — fundamentos ideales |
| **APT41** (Double Dragon) | G0096 | Phase-01 | Pivoting y acceso inicial via exploits públicos — Lab-02 |
| **APT28** (Fancy Bear) | G0007 | Phase-02 | AD avanzado, Forest Trusts, GPO, SID History — post-explotación |
| **Lazarus Group** | G0032 | Phase-03 | EDR evasion, C2 avanzado, OPSEC extremo |
| **APT10** (Stone Panda) | G0045 | Phase-04 | Simulaciones largas, infraestructura compleja |

---

## 3. Infraestructura — v2.1

### [NUEVO v2.1] Arquitectura multi-forest completa

La infraestructura fue ampliada en Sesión 17 (31/05/2026) para replicar el entorno del examen CRTO:

```
                    ┌─────────────────────────────────────────┐
                    │           FOREST 1 — atackcorp.local     │
                    │  DC-01 (10.0.2.10) — Root DC            │
                    │  DC-03 (10.0.2.13) — child.atackcorp    │
                    │  WKSTN-01 (10.0.2.8)                    │
                    └──────────────┬──────────────────────────┘
                                   │ BiDirectional Trust (SID Filtering OFF)
                    ┌──────────────┴──────────────────────────┐
                    │           FOREST 2 — corp.local          │
                    │  DC-02 (10.0.2.11) — Root DC            │
                    │  WKSTN-02 (10.0.2.12)                   │
                    └──────────────┬──────────────────────────┘
                                   │ BiDirectional Trust (SID Filtering OFF)
                    ┌──────────────┴──────────────────────────┐
                    │           FOREST 3 — ext.local           │
                    │  DC-04 (10.0.2.14) — Root DC            │
                    └─────────────────────────────────────────┘

                    Kali (10.0.2.9) — Atacante
                    Red: NAT Network LabRedTeam 10.0.2.0/24
                    Ruta adicional: 10.0.3.0/24 via 10.0.2.1
```

### VMs y especificaciones

| VM | IP | OS | RAM | Dominio | Rol |
|----|----|----|-----|---------|-----|
| DC-01 | 10.0.2.10 | Windows Server 2022 | 4GB | atackcorp.local | Root DC Forest 1 |
| DC-02 | 10.0.2.11 | Windows Server 2022 | 2GB | corp.local | Root DC Forest 2 |
| DC-03 | 10.0.2.13 | Windows Server 2022 | 2GB | child.atackcorp.local | Child DC |
| DC-04 | 10.0.2.14 | Windows Server 2022 | 2GB | ext.local | Root DC Forest 3 |
| WKSTN-01 | 10.0.2.8 | Windows 11 | 3GB | atackcorp.local | Workstation |
| WKSTN-02 | 10.0.2.12 | Windows 11 | 2GB | corp.local | Workstation |
| Kali | 10.0.2.9 | Kali Linux 2024 | 8GB | — | Atacante |

### Scripts de provisioning

| Script | VM | Versión | Estado |
|--------|----|---------|--------|
| `00_setup_lab01_ghost_forest_v2.ps1` | DC-01 | v2.0 | ✅ |
| `01_ad_promotion.ps1` | DC-01 | v1.0 | ✅ |
| `02_users_ous.ps1` | DC-01 | v1.0 | ✅ |
| `03_acls_delegations.ps1` | DC-01 | v1.0 | ✅ |
| `04_iis_smb_gpo.ps1` | DC-01 | v1.0 | ✅ |
| `05_mssql.ps1` | DC-01 | v1.0 | ✅ |
| `06_wkstn01_fixed.ps1` | WKSTN-01 | v1.1 | ✅ |
| `07_setup_DC02_Corp.ps1` | DC-02 | v1.0 | ✅ |
| `08_setup_DC03_Child.ps1` | DC-03 | v1.1 | ✅ Fix DNS+ADWS+C:\Temp |
| `09_setup_DC04_Ext.ps1` | DC-04 | v1.0 | ✅ |
| `10_setup_Trusts_And_SIDHistory.ps1` | DC-01 | v1.0 | ✅ |
| `11_Setup_WKSTN02_Corp_fixed.ps1` | WKSTN-02 | v1.1 | ✅ |

---

## 4. Roadmap v2.1 — Estructura

### Cambios respecto a v2.0

| v2.0 | v2.1 | Razón |
|------|------|-------|
| DC-01 + WKSTN-01 únicamente | 4 DCs + 2 WKSTNs + 3 Forests | Fidelidad CRTO completa |
| Lab-06 con 1 DC adicional | Lab-06 con 3 forests independientes | Mayor realismo y cobertura |
| mimikatz para SID History | DSInternals + bloodyad | mimikatz `misc::addsid` eliminado en v2.2.0+ |
| ~38% cobertura MITRE | ~45% con Lab-06 en curso | +7% con técnicas cross-forest |

### Estructura v2.1

```
Phase-01: Fundamentos AD (Labs 01-03)     ✅ Completada
Phase-02: AD Avanzado (Labs 04-07)        🟡 En progreso — Lab-06 Fase 02
Phase-03: Red Team Ops (Labs 08-11)       ⏳ Pendiente
Phase-04: Enterprise Simulation (Labs 12-15) ⏳ Pendiente
```

---

## 5. Coverage Matrix v2.1

### Técnicas cubiertas

| Técnica | MITRE ID | Lab | Estado |
|---------|----------|-----|--------|
| **Reconocimiento** | | | |
| Network scanning | T1046 | Lab-01/06 | ✅ |
| LDAP enumeration | T1087.002 | Lab-01/06 | ✅ |
| SMB enumeration | T1135 | Lab-01/06 | ✅ |
| BloodHound metodología | T1087.002 | Lab-01/04/05 | ✅ |
| Cross-forest enumeration | T1482 | Lab-06 | ✅ |
| Trust Discovery | T1482 | Lab-06 | ✅ |
| **Kerberos Attacks** | | | |
| AS-REP Roasting | T1558.004 | Lab-01 | ✅ |
| Kerberoasting | T1558.003 | Lab-01/06 | ✅ |
| Cross-Forest Kerberoasting | T1558.003 | Lab-06 | ✅ |
| Pass-the-Ticket | T1550.003 | Lab-01/05 | ✅ |
| Pass-the-Hash | T1550.002 | Lab-01/03 | ✅ |
| Overpass-the-Hash | T1550.003 | Lab-04 | ✅ |
| Golden Ticket | T1558.001 | Lab-01 | 🔄 Parcial |
| Silver Ticket | T1558.002 | Lab-05 | ✅ |
| Diamond Ticket | T1558.001 | Lab-05 | ✅ |
| **Delegation Abuse** | | | |
| Unconstrained Delegation | T1558.001 | Lab-01 | ✅ |
| Constrained Delegation | T1558.001 | Lab-01 | ✅ |
| RBCD | T1558.001 | Lab-05 | ✅ |
| **ACL / Permission Abuse** | | | |
| GenericWrite → Kerberoast | T1558.003 | Lab-01 | ✅ |
| WriteDACL → DCSync | T1222+T1003.006 | Lab-04 | ✅ |
| GenericAll → Shadow Credentials | T1556 | Lab-05 | ✅ |
| **Forest / Trust Abuse** | | | |
| SID History Injection | T1134.005 | Lab-06 | ✅ |
| Cross-Forest Trust Abuse | T1134.005 | Lab-06 | ⏳ Fase 03 |
| GPO Abuse Cross-Forest | T1484.001 | Lab-06 | ⏳ Fase 04 |
| ExtraSids Attack | T1134.005 | Lab-06 | ⏳ Fase 03 |
| **Credential Access** | | | |
| DCSync | T1003.006 | Lab-01/04/06 | ✅ |
| Credential Hunting Files | T1552.001 | Lab-02/04/06 | ✅ |
| Shadow Credentials | T1556 | Lab-05 | ✅ |
| SAM dump | T1003.002 | Lab-02 | ✅ |
| DPAPI | T1555 | Lab-07 | ⏳ |
| LAPS | T1555 | Lab-07 | ⏳ |
| **ADCS** | | | |
| ESC1 — SAN Abuse | T1649 | Lab-03 | ✅ |
| ESC4 — Template Modification | T1649 | Lab-03 | ✅ |
| ESC8 — NTLM Relay | T1557 | Lab-03 | 🔄 |
| **Pivoting / C2** | | | |
| Ligolo-ng tunneling | T1572 | Lab-02 | ✅ |
| Sliver HTTPS C2 | T1071.001 | Lab-01/02/03/04/05 | ✅ |
| Relay C2 | T1090 | Lab-02 | ✅ |
| **Initial Access** | | | |
| Web exploit (CVE) | T1190 | Lab-02 | ✅ |
| Git history credentials | T1552.001 | Lab-02 | ✅ |
| **EDR / Evasión** | | | |
| AMSI bypass | T1562 | Lab-08/09 | ⏳ |
| Process injection | T1055 | Lab-08/09 | ⏳ |
| Direct syscalls | T1055 | Lab-08/09 | ⏳ |

### Resumen de cobertura

| Categoría | Cubiertas | Total | % |
|-----------|-----------|-------|---|
| Reconocimiento | 5 | 6 | 83% |
| Kerberos | 8 | 10 | 80% |
| Delegation | 3 | 3 | 100% |
| ACL Abuse | 3 | 4 | 75% |
| Forest/Trust | 1 | 4 | 25% |
| Credential Access | 5 | 7 | 71% |
| ADCS | 2 | 4 | 50% |
| Pivoting/C2 | 3 | 6 | 50% |
| Initial Access | 2 | 5 | 40% |
| EDR/Evasión | 0 | 7 | 0% |
| **TOTAL** | **32** | **56** | **~57%** |

> Con Lab-06 completo se llegará a ~65%. Completando el roadmap v2.1: ~80-85%.

---

## 6. Crown Jewels — Objetivos por Lab

| Lab | Crown Jewels | Estado |
|-----|-------------|--------|
| **Lab-01 GHOST FOREST** | Hash NTLM Administrador + credenciales fin.garcia | ✅ |
| **Lab-02 SILENT BRIDGE** | SAM dump PC-01 + credenciales thomas | ✅ |
| **Lab-03 DARK GATE** | Certificado Administrador válido post-rotación | ✅ |
| **Lab-04 IRON FOREST** | Hash DA via WriteDACL + credenciales SYSVOL | ✅ |
| **Lab-05 SILVER CHAIN** | TGS como Administrador via RBCD + Silver Ticket | ✅ |
| **Lab-06 BLACK POLICY** | Forest Admin cross-forest + hash krbtgt atackcorp | 🟡 En progreso |
| **Lab-07 SHADOW VAULT** | LAPS password + DPAPI credentials | ⏳ |
| **Lab-08 FIRST CONTACT** | Foothold inicial sin credenciales previas | ⏳ |
| **Lab-09 GHOST SIGNAL** | Beacon persistente sin detección Defender | ⏳ |
| **Lab-10 DARK CURRENT** | C2 operativo sin detección EDR activo | ⏳ |
| **Lab-11 DEEP HOLO** | Infraestructura C2 profesional end-to-end | ⏳ |
| **Lab-12 RED DANTE** | Compromiso total red enterprise | ⏳ |
| **Lab-13 AZURE BREACH** | Azure Global Admin via híbrido on-prem | ⏳ |
| **Lab-14 OPERATION ZEPHYR** | Full enterprise simulation — CRTO prep | ⏳ |

---

## 7. Lecciones de Diseño — v2.1

### Evil-WinRM — Limitaciones token de red
`Get-ADGroup -Server cross-domain` falla en sesiones Evil-WinRM por token Network Logon (Type 3).
ADWS no acepta consultas autenticadas con este token. Alternativa funcional:

```powershell
([System.Security.Principal.NTAccount]"DOMAIN\Group").Translate(
    [System.Security.Principal.SecurityIdentifier]).Value
```

### SID History — Atributo protegido en AD
`sIDHistory` no puede modificarse via LDAP estándar aunque se sea DA. Requiere:
- **DSInternals `Add-ADDBSidHistory`** — modificación directa ntds.dit (Stop NTDS requerido)
- **impacket** via DS-Replication — sin parar NTDS (más silencioso)
- **bloodyad** — NO funciona para sIDHistory (protegido por AD por diseño, no limitación de la herramienta)

### mimikatz `misc::addsid` eliminado
mimikatz 2.2.0+ (incluido en Kali) no incluye `misc::addsid`. Herramienta correcta: DSInternals.
Para manipulación LDAP remota: bloodyad (cuando el atributo lo permite).

### DNS en child domains
DC-03 (child domain) necesita DC-01 como DNS primario para consultas cross-forest.
Sin esto, consultas ADWS cross-domain fallan intermitentemente aunque la IP sea accesible.
Fix: `Set-DnsClientServerAddress -ServerAddresses ("10.0.2.10","10.0.2.13")`

### Defender bloquea herramientas en upload
Windows Defender detecta y elimina mimikatz durante o inmediatamente después del upload via Evil-WinRM.
Deshabilitar antes del upload: `Set-MpPreference -DisableRealtimeMonitoring $true`
En labs Phase-03 (Lazarus) se trabajará evasión real sin deshabilitar Tamper Protection.

### Enable-PSRemoting en scripts via Evil-WinRM
`Enable-PSRemoting -Force` dentro de un script ejecutado via Evil-WinRM corta la conexión.
Ejecutar manualmente en la VM antes de lanzar el script de provisioning.

---

## 8. Mejoras Pendientes — v2.2

| # | Mejora | Prioridad | Aplica a |
|---|--------|-----------|---------|
| 1 | Script `lab_healthcheck.sh` — verificar conectividad pre-lab | Alta | tooling/ |
| 2 | Snapshots VMs post-provisioning para reset rápido | Alta | Manual |
| 3 | ADCS en DC-01 visible cross-forest para ESC8 cross-domain | Media | Lab-06 |
| 4 | Constrained delegation en corp_svc DC-02 | Media | Lab-06 |
| 5 | LAPS en WKSTN-01 | Baja | Lab-07 prep |
| 6 | Script de teardown/reset por lab | Media | tooling/ |
| 7 | Integrar bloodyad en arsenal_setup.sh como apt package | ✅ Hecho v2.1 | tooling/ |
| 8 | DSInternals v4.14 en arsenal | ✅ Hecho v2.1 | tooling/ |

---

## 9. Orden de arranque de VMs por fase

| Fase | VMs requeridas |
|------|---------------|
| Lab-06 Fase 01 Recon | DC-01 → DC-02 → DC-04 → Kali |
| Lab-06 Fase 02 SID History | DC-01 → DC-03 → Kali |
| Lab-06 Fase 03 Cross-Forest Trust | DC-01 → DC-02 → DC-04 → Kali |
| Lab-06 Fase 04 GPO Abuse | DC-01 → WKSTN-01 → Kali |
| Lab-06 Fase 05 C2 + Cleanup | DC-01 → DC-02 → WKSTN-01 → WKSTN-02 → Kali |

---

## 10. Cobertura CRTO — v2.1

| Módulo CRTO | Lab(s) | Cobertura |
|-------------|--------|-----------|
| Command & Control | Lab-01/02/10/11 | ✅ |
| Initial Compromise | Lab-08 | ⏳ |
| Host Reconnaissance | Lab-01/04 | 🔄 |
| Host Persistence | Lab-01/02 | ✅ |
| Credential Access | Lab-01/03/04/05/06 | ✅ |
| Domain Recon | Lab-01/04/05/06 | ✅ |
| Lateral Movement | Lab-01/02/04 | ✅ |
| Pivoting | Lab-02/11 | ✅ |
| ADCS | Lab-03 | ✅ |
| AD Kerberos Attacks | Lab-01/05/06 | ✅ |
| Shadow Credentials | Lab-05/07 | 🔄 |
| LAPS | Lab-07 | ⏳ |
| Forest Trusts | Lab-06/12/14 | 🔄 En progreso |
| GPO Abuse | Lab-01/06 | 🔄 En progreso |
| AV/EDR Evasion | Lab-09/10 | ⏳ |
| AMSI/AppLocker | Lab-09 | ⏳ |
| BOFs | Lab-10 | ⏳ |

**Cobertura CRTO actual:** ~65% | **Con roadmap v2.1 completo:** ~98%

---

## 11. Recursos de Referencia

### Frameworks
- [MITRE ATT&CK Enterprise](https://attack.mitre.org/matrices/enterprise/)
- [MITRE ATT&CK Groups](https://attack.mitre.org/groups/)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)

### Certificaciones objetivo
- **CRTO** (Certified Red Team Operator) — Lab-14 como preparación directa
- **CRTE** (Certified Red Team Expert) — Phase-02/03 como preparación
- **OSCP+** — Phase-01 como base sólida

### Documentación de adversarios
- APT29: [CISA Advisory AA21-116A](https://www.cisa.gov/news-events/cybersecurity-advisories/aa21-116a)
- APT28: [MITRE G0007](https://attack.mitre.org/groups/G0007/)
- Lazarus: [CISA Advisory AA22-108A](https://www.cisa.gov/news-events/cybersecurity-advisories/aa22-108a)

---

*Red Team Ops Roadmap v2.1 — Adrián Camacho | Junio 2026*