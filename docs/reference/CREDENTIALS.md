# CREDENTIALS.md — Red Team Ops Roadmap
## Credenciales de administracion del entorno de laboratorio

**Uso:** Solo para gestion del entorno — NO son credenciales de ataque  
**Autor:** Adrian Camacho | **Actualizado:** Junio 2026 (v2.1 — Lab-07 LAPS + DPAPI loot)

> Este archivo contiene credenciales de laboratorio en texto claro.  
> **Nunca subir a repositorios publicos en entornos reales.**  
> Uso exclusivo en entorno VirtualBox local controlado.

---

## Credenciales de Administrador local por VM

| VM | IP | OS | Usuario | Contrasena | Notas |
|----|----|----|---------|-----------|-------|
| DC-01 | 10.0.2.10 | Windows Server 2025 | Administrador | `NuevaPassword2026!` | Domain Admin atackcorp.local |
| DC-02 | 10.0.2.11 | Windows Server 2022 | Administrador | `NuevaPassword2026!` | Domain Admin corp.local |
| DC-03 | 10.0.2.13 | Windows Server 2022 | Administrador | `NuevaPassword2026!` | Domain Admin child.atackcorp.local |
| DC-04 | 10.0.2.14 | Windows Server 2022 | Administrador | `NuevaPassword2026!` | Domain Admin ext.local |
| WKSTN-01 | 10.0.2.8 | Windows 11 | Administrador | `NuevaPassword2026!` | Admin local — dominio ATACKCORP |
| WKSTN-02 | 10.0.2.12 | Windows 11 | Administrador | `NuevaPassword2026!` | Admin local — dominio CORP |
| Kali | 10.0.2.9 | Kali Linux | kali | `kali` | — |

> **Nota:** DC-02, DC-03, DC-04 tenian Admin1234! por defecto — cambiado a NuevaPassword2026! en Junio 2026

---

## Credenciales de dominio por forest

### atackcorp.local (DC-01 — Windows Server 2025)

| Usuario | Contrasena | Grupo | Rol en labs |
|---------|-----------|-------|-------------|
| `Administrador` | `NuevaPassword2026!` | Domain Admins | Admin dominio |
| `ceo.martinez` | `Direccion2024!` | — | AS-REP Roasteable — credencial inicial Lab-01 |
| `fin.garcia` | `Finance2024!` | — | WriteDACL dominio — GenericWrite sql_svc — Lab-04 |
| `helpdesk.ruiz` | `Helpdesk2024!` | — | Credencial inicial Lab-04/05/06/07 — lee LAPS WKSTN-01 |
| `it.admin` | `ITAdmin2024!` | Account Operators | ACL Abuse path |
| `rrhh.lopez` | `RRHH2024!` | — | Usuario normal |
| `sql_svc` | `SQLSvc2024!` | — | SPN MSSQLSvc/DC-01:1433 — Kerberoasteable |
| `iis_svc` | `IISService2024!` | — | SPN HTTP/DC-01 — Constrained Delegation |
| `backup_svc` | `Backup2024!` | — | AS-REP Roasteable — WinRM |
| `cross.user` | `CrossUser2024!` | — | Cuenta cross-forest Lab-06 |
| `child.user` | `ChildUser2024!` | — | SID History target Lab-06 |

### corp.local (DC-02)

| Usuario | Contrasena | Grupo | Rol en labs |
|---------|-----------|-------|-------------|
| `Administrador` | `NuevaPassword2026!` | Domain Admins | Admin dominio |
| `corp.admin` | `CorpAdmin2024!` | Domain Admins | DA corp.local |
| `john.smith` | `JohnCorp2024!` | — | GenericAll sobre corp_svc — autologon WKSTN-02 |
| `sarah.connor` | `SarahCorp2024!` | — | Usuario normal |
| `corp_svc` | `CorpSvc2024!` | — | SPN MSSQLSvc/DC-02:1433 — Kerberoasteable cross-forest |

### child.atackcorp.local (DC-03)

| Usuario | Contrasena | Grupo | Rol en labs |
|---------|-----------|-------|-------------|
| `Administrador` | `NuevaPassword2026!` | Domain Admins | Admin dominio |
| `child.admin` | `ChildAdmin2024!` | Domain Admins | DA child domain — Evil-WinRM DC-03 |
| `child.user` | `ChildUser2024!` | — | Target SID History injection Lab-06 |
| `child_svc` | `ChildSvc2024!` | — | SPN HTTP/DC-03 |

### ext.local (DC-04)

| Usuario | Contrasena | Grupo | Rol en labs |
|---------|-----------|-------|-------------|
| `Administrador` | `NuevaPassword2026!` | Domain Admins | Admin dominio |
| `ext.admin` | `ExtAdmin2024!` | Domain Admins | DA ext.local — credenciales en Ext-Data share |
| `ext.user` | `ExtUser2024!` | Ext-Readers | Acceso share Ext-Data |
| `ext_svc` | `ExtSvc2024!` | — | SPN MSSQLSvc/DC-04:1433 — Kerberoasteable cross-forest |

---

## Credenciales de servicios (DC-01)

| Servicio | Usuario | Contrasena | Notas |
|---------|---------|-----------|----|
| SQL Server SA | `sa` | `Sa_Admin2024!` | Mixed Mode auth — sysadmin |
| SQL Server app | `sql_svc` | `SQLSvc2024!` | Login con rol sysadmin |
| IIS App Pool | `ATACKCORP\iis_svc` | `IISService2024!` | Constrained Delegation |
| Webapp DB | `webapp_db` | `WebappDB2024!` | IT-Scripts/deploy_webapp.ps1 |
| LAPS Admin local WKSTN-01 | `Administrador` | `@98q6$13Z{K99;` (rota mensualmente) | Legible por helpdesk.ruiz — msLAPS-Password |

---

## Credenciales Crown Jewels (ficticias)

| Sistema | Usuario | Contrasena | Ubicacion |
|---------|---------|-----------|----------|
| Banca Santander | `atackcorp_001` | `Santander@2024Corp!` | CorporateData/Finance/ |
| BBVA Empresas | `ATCK-CORP-ES` | `BBVAcorp2026$!` | CorporateData/Finance/ |
| Azure tenant | `admin@atackcorp.onmicrosoft.com` | `AzureTemp2026!` | CorporateData/Executive/ |
| CA backup | — | `CAbackup2025!AtackCorp` | CorporateData/PKI-Admin/ |
| Zabbix | `zabbix` | `Zabbix@2026!` | CorporateData/IT/ |
| SQL Server SA (DPAPI Lab-07) | `sa` | `SQLsa2026!` | DC-01\SQLEXPRESS — extraída via DPAPI |

---

## Acceso rapido para administracion

```bash
# DC-01 (atackcorp.local)
evil-winrm -i 10.0.2.10 -u Administrador -p 'NuevaPassword2026!'

# DC-02 (corp.local)
evil-winrm -i 10.0.2.11 -u Administrador -p 'NuevaPassword2026!'

# DC-03 (child.atackcorp.local)
evil-winrm -i 10.0.2.13 -u Administrador -p 'NuevaPassword2026!'

# DC-04 (ext.local)
evil-winrm -i 10.0.2.14 -u Administrador -p 'NuevaPassword2026!'

# WKSTN-01
evil-winrm -i 10.0.2.8 -u Administrador -p 'NuevaPassword2026!'

# WKSTN-02
evil-winrm -i 10.0.2.12 -u Administrador -p 'NuevaPassword2026!'
```

---

## GPOs relevantes

| GPO | GUID | Vinculado a | Vulnerabilidad |
|-----|------|------------|----------------|
| IT-Baseline | `{696f7ac2-bb76-4a99-bc34-1a6bbfdc9ba6}` | OU=IT | helpdesk.ruiz WriteDACL — GPO Abuse Lab-04/06 |
| LAPS-Policy | Ver Get-GPO -Name "LAPS-Policy" | OU=IT | Windows LAPS config WKSTN-01 |
| Defender-Lab-Config | Ver Get-GPO | OU=Equipos | Exclusiones Defender |

---

*Red Team Ops Roadmap — Adrian Camacho | Uso exclusivo en entorno de laboratorio local*