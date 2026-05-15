# Infrastructure Setup — Operación GHOST FOREST
## Entorno de Lab + Configuración de Vulnerabilidades
**Operación:** GHOST FOREST | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 12/05/2026  
**Repositorio:** github.com/adr-camacho/RedTeam-Ops-Roadmap

---

## 1. Topología de Red

```
┌─────────────────────────────────────────────────────────────┐
│                  RED NAT — LabRedTeam                       │
│                   Segmento: 10.0.2.0/24                     │
│                                                             │
│   ┌──────────────┐            ┌──────────────────────────┐  │
│   │    DC-01     │            │        WKSTN-01          │  │
│   │  10.0.2.10   │◄──────────►│       10.0.2.20          │  │
│   │  WS 2022     │            │   Windows 11 Enterprise  │  │
│   │  DC / DNS    │            │   [objetivo Fase 6 LM]   │  │
│   │  MSSQL / IIS │            └──────────────────────────┘  │
│   └──────────────┘                        ▲                 │
│          ▲                                │                 │
│          └────────────────────────────────┘                 │
│                           ▲                                 │
│              ┌────────────┴────────────┐                    │
│              │       Kali Linux        │                    │
│              │     10.0.2.9 (fijo)     │                    │
│              │  Máquina operadora      │                    │
│              └─────────────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Inventario de Máquinas

| Host | Sistema Operativo | IP | Rol en la operación |
|------|------------------|----|-------------------|
| DC-01 | Windows Server 2022 Standard Evaluation | 10.0.2.10 | Domain Controller — objetivo principal |
| WKSTN-01 | Windows 11 Enterprise Evaluation | 10.0.2.20 | Workstation — objetivo Lateral Movement (Fase 6) |
| Kali | Kali Linux 2026.1 | 10.0.2.9 | Máquina operadora APT29 |

**Dominio:** `atackcorp.local`  
**Hipervisor:** Oracle VirtualBox  
**Tipo de red:** NAT Network — `LabRedTeam`

---

## 3. Usuarios del Dominio

| Usuario | Tipo | Contraseña | Notas |
|---------|------|-----------|-------|
| Administrador | Built-in DA | — | Objetivo final |
| ceo.martinez | Usuario dominio | `Direccion2024!` | AS-REP Roastable — foothold inicial |
| backup_svc | Cuenta de servicio | `Backup2024!` | AS-REP Roastable + Kerberoastable + DA |
| sql_svc | Cuenta de servicio | — | Kerberoastable — Unconstrained Delegation |
| iis_svc | Cuenta de servicio | — | Kerberoastable — IIS |
| helpdesk.ruiz | Usuario dominio | — | — |
| it.admin | Usuario dominio | — | — |
| fin.garcia | Usuario dominio | — | — |
| rrhh.lopez | Usuario dominio | — | — |
| krbtgt | Built-in | — | Objetivo Golden Ticket (Fase 9) |

---

## 4. Vulnerabilidades Preconfiguradas

Las siguientes vulnerabilidades fueron inyectadas intencionalmente en el entorno para replicar configuraciones inseguras reales. Configuradas mediante el script `Setup-Lab01-GhostForest.ps1` ejecutado como Administrador en DC-01.

### 4.1 — AS-REP Roasting (T1558.004)
**Cuentas vulnerables:** `ceo.martinez`, `backup_svc`  
**Configuración:** Flag `UF_DONT_REQUIRE_PREAUTH` activa — preautenticación Kerberos deshabilitada  
**Realismo:** Común en cuentas de servicio antiguas y usuarios legacy migrados sin revisión de seguridad  
**Path de ataque:** GetNPUsers → hash AS-REP → crack offline → credenciales en claro

### 4.2 — DCSync ACL Abuse (T1003.006 + T1484.001)
**Cuenta afectada:** `ceo.martinez`  
**Configuración:** Permisos de replicación de directorio asignados sobre `DC=atackcorp,DC=local`

| GUID | Permiso | Estado |
|------|---------|--------|
| `1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` | DS-Replication-Get-Changes | ✅ Allow |
| `1131f6ab-9c07-11d1-f79f-00c04fc2dcd2` | DS-Replication-Get-Changes-All | ✅ Allow |
| `89e95b76-444d-4c62-991a-0facbeda640c` | DS-Replication-Get-Changes-In-Filtered-Set | ✅ Allow |

**Realismo:** Delegaciones incorrectas sobre el objeto raíz del dominio — error común en entornos con administración descentralizada  
**Path de ataque:** secretsdump DCSync → hash NTLM Administrator → Pass-the-Hash → DA  
**Nota:** Durante la operación este vector resultó bloqueado por token de sesión cacheado (Kerberos). El permiso está correctamente configurado pero requiere nuevo logon del usuario para ser efectivo.

### 4.3 — Kerberoasting (T1558.003)
**Cuenta afectada:** `backup_svc`  
**Configuración:** SPN registrado + membresía en Domain Admins

```
SPN: MSSQLSvc/DC-01.atackcorp.local:1433
Grupo: Admins. del dominio (S-1-5-21-768292631-183641691-1245477636-512)
```

**Realismo:** Cuentas de servicio con SPNs registrados y contraseñas débiles — uno de los vectores más frecuentes en auditorías de AD  
**Path de ataque:** GetUserSPNs → TGS → crack offline → Evil-WinRM → DA ✅ (completado)

### 4.4 — Password en Description (T1087.002)
**Cuenta afectada:** `backup_svc`  
**Configuración:** Contraseña en texto claro en campo Description de AD

```
Description: "Backup Service - pwd temporal: Backup2024! (pendiente cambio)"
```

**Realismo:** Práctica habitual en equipos de IT para comunicar contraseñas temporales — campo visible por cualquier usuario autenticado del dominio  
**Path de ataque:** LDAP enum descriptions → credenciales → Evil-WinRM → DA

---

## 5. Script de Configuración

**Archivo:** `setup/Setup-Lab01-GhostForest.ps1`  
**Ejecutar como:** Administrador en DC-01  
**Versión corregida:** v1.1 (fix SPN hardcodeado + DA por SID-512 universal)

### Uso

```powershell
# En DC-01 como Administrador
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Setup-Lab01-GhostForest.ps1
```

### Correcciones aplicadas en v1.1

| Bug | Causa | Fix |
|-----|-------|-----|
| SPN registrado vacío (`MSSQLSvc/`) | Variable `$DCHostname` no expandida en bloque `try/catch` | Hardcodeado como literal `"MSSQLSvc/DC-01.atackcorp.local:1433"` |
| `Domain Admins` no encontrado | Windows Server en español usa `"Admins. del dominio"` | Búsqueda por SID-512 universal `S-1-5-21-...-512` |
| Verificación DA fallaba | Mismo problema de nombre | Mismo fix SID-512 en bloque de verificación |

### Output esperado tras ejecución correcta

```
============================================================
  GHOST FOREST — Lab Setup v1.0
  Dominio: atackcorp.local
  DC:      DC-01.atackcorp.local
============================================================

[*] Verificando prerrequisitos...
    [+] Usuario encontrado: ceo.martinez
    [+] Usuario encontrado: backup_svc

[*] BLOQUE 1 — Configurando DCSync ACL Abuse...
    [+] Permisos DCSync asignados a ceo.martinez
    [+] GUIDs configurados:
        DS-Replication-Get-Changes
        DS-Replication-Get-Changes-All
        DS-Replication-Get-Changes-In-Filtered-Set

[*] BLOQUE 2 — Configurando Kerberoasting (backup_svc)...
    [+] SPN registrado: MSSQLSvc/DC-01.atackcorp.local:1433
    [+] backup_svc añadido a Admins. del dominio

[*] BLOQUE 3 — Configurando Password en Description (bonus)...
    [+] Description con password configurada en backup_svc

[*] BLOQUE 4 — Verificación del escenario...

    [ACL] Permisos de replicación sobre DC=atackcorp,DC=local :
    [+] DCSync ACL verificada para ceo.martinez

    [SPN] SPNs registrados para backup_svc:
    [+] MSSQLSvc/DC-01.atackcorp.local:1433

    [DA]  Miembros de Admins. del dominio:
    [+] Administrador
    [+] backup_svc
```

---

## 6. Kill Chains disponibles

```
PATH A — DCSync ACL Abuse [T1003.006]
────────────────────────────────────────────────────────
  ceo.martinez (Evil-WinRM)
    → impacket-secretsdump DCSync
    → Hash NTLM Administrator
    → evil-winrm Pass-the-Hash
    → Domain Admin
  Estado: configurado ✅ | ejecutado: bloqueado por token cacheado

PATH B — Kerberoasting [T1558.003]
────────────────────────────────────────────────────────
  ceo.martinez (Evil-WinRM)
    → impacket-GetUserSPNs → TGS backup_svc
    → john crack → Backup2024!
    → evil-winrm backup_svc
    → Domain Admin ✅ COMPLETADO

PATH C — Password en Description [T1087.002]
────────────────────────────────────────────────────────
  ceo.martinez (Evil-WinRM)
    → LDAP enum descriptions
    → backup_svc: Backup2024! en texto claro
    → evil-winrm backup_svc
    → Domain Admin ✅ CONFIRMADO (vector alternativo)
```

---

## 7. Estructura del repositorio

```
Lab-01-Attacktive-Directory/
├── setup/
│   └── Setup-Lab01-GhostForest.ps1      ← Script de configuración de vulnerabilidades
├── loot/
│   ├── users.txt                         ← Lista de usuarios del dominio
│   ├── asrep_hashes.txt                  ← Hashes AS-REP capturados
│   ├── corporate_base.txt                ← Base OSINT corporativa
│   └── targeted_wordlist.txt             ← Diccionario dirigido OSINT
├── nmap/
│   ├── ports.nmap                        ← Port discovery — output texto
│   ├── ports.gnmap                       ← Port discovery — output grepable
│   ├── ports.xml                         ← Port discovery — output XML
│   ├── detailed.nmap                     ← Service version — output texto
│   ├── detailed.gnmap                    ← Service version — output grepable
│   └── detailed.xml                      ← Service version — output XML
├── screenshots/
│   ├── FASE-1—Reconnaissance/
│   │   ├── fase1-01-nmap-port-discovery.png
│   │   ├── fase1-02-nmap-service-version.png
│   │   ├── fase1-03-smb-null-session.png
│   │   ├── fase1-04-smb-guest-denied.png
│   │   └── fase1-05-ldap-anonymous-denied.png
│   ├── FASE-2-Initial-Access-(Credential Access)/
│   │   ├── fase2-01-asrep-roasting-hashes.png
│   │   ├── fase2-02-asrep-hashes-file.png
│   │   ├── fase2-03-asrep-crack-targeted-wordlist.png
│   │   └── fase2-04-asrep-credentials-confirmed.png
│   ├── FASE-3-Execution-Initial-Foothold/
│   │   ├── fase3-01-cme-credential-validation.png
│   │   └── fase3-02-winrm-shell-established.png
│   ├── FASE-4-Discovery/
│   │   ├── fase4-01-system-info.png
│   │   ├── fase4-02-domain-users-groups.png
│   │   ├── fase4-03-privileged-groups.png
│   │   ├── fase4-03b-privileged-groups-fix.png
│   │   ├── fase4-04-spn-enumeration.png
│   │   ├── fase4-05-description-passwords.png
│   │   └── fase4-06-domain-computers.png
│   └── FASE-5-Credential-Access-(Ampliada)/
│       ├── fase5-01-kerberoasting-GetUserSPNs.png
│       ├── fase5-02-kerberoast-hashes-capturados.png
│       ├── fase5-03-john-crack-backup_svc.png
│       └── fase5-04-domain-admin-backup_svc.png
├── docs/
│   ├── enumeration_log.md               ← Fase 1: Reconnaissance
│   ├── exploitation.md                  ← Fases 2-3: AS-REP Roasting + foothold
│   ├── post-exploitation.md             ← Fases 4-5: Discovery + DA
│   └── infrastructure_setup.md          ← Este documento
└── README.md                            ← Plan de operación completo
```

---

## 8. Notas OPSEC

| Principio APT29 | Implementación |
|----------------|----------------|
| Living-off-the-Land en Discovery | Comandos nativos (`net`, `whoami`, ADSI searcher) antes de herramientas externas |
| Mínimo ruido en Kerberos | Solo tickets de cuentas previamente identificadas — sin fuerza bruta |
| C2 solo en WKSTN-01 | Beacon Sliver no desplegado en DC — pendiente Fase 7 |
| Diccionario dirigido | OSINT simulado de empresa en lugar de fuerza bruta genérica |
| Documentación en tiempo real | Cada comando registrado con output antes de continuar |

---

**Fases pendientes:** 6 (Lateral Movement) → 7 (C2 Sliver) → 8 (LPE WKSTN-01) → 9 (Golden Ticket) → 10 (DCSync + Objective Completion)