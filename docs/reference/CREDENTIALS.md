# CREDENTIALS.md — Red Team Ops Roadmap
## Credenciales de administración del entorno de laboratorio
**Uso:** Solo para gestión del entorno — NO son credenciales de ataque  
**Autor:** Adrián Camacho | **Actualizado:** Junio 2026

> ⚠️ Este archivo contiene credenciales de laboratorio en texto claro.  
> **Nunca subir a repositorios públicos en entornos reales.**  
> Uso exclusivo en entorno VirtualBox local controlado.

---

## Credenciales de Administrador local por VM

| VM | IP | OS | Usuario | Contraseña | Notas |
|----|----|----|---------|-----------|-------|
| DC-01 | 10.0.2.10 | Windows Server 2022 | Administrador | `NuevaPassword2026!` | Domain Admin atackcorp.local |
| DC-02 | 10.0.2.11 | Windows Server 2022 | Administrador | `Admin1234!` | Domain Admin corp.local |
| DC-03 | 10.0.2.13 | Windows Server 2022 | Administrador | `Admin1234!` | Domain Admin child.atackcorp.local |
| DC-04 | 10.0.2.14 | Windows Server 2022 | Administrador | `Admin1234!` | Domain Admin ext.local |
| WKSTN-01 | 10.0.2.8 | Windows 11 | Administrador | `NuevaPassword2026!` | Admin local — dominio ATACKCORP |
| WKSTN-02 | 10.0.2.12 | Windows 11 | Administrador | `Admin1234!` | Admin local — dominio CORP |
| Kali | 10.0.2.9 | Kali Linux | kali | `kali` | — |

---

## Credenciales de dominio por forest

### atackcorp.local (DC-01)

| Usuario | Contraseña | Grupo | Rol en labs |
|---------|-----------|-------|-------------|
| `Administrador` | `NuevaPassword2026!` | Domain Admins | Admin dominio |
| `helpdesk.ruiz` | `Helpdesk2024!` | — | Credencial inicial Lab-04/05/06 |
| `backup_svc` | `Backup2024!` | **Domain Admins** | SPN — DA |
| `iis_svc` | `IISService2024!` | — | SPN servicio IIS |
| `sql_svc` | `SQLSvc2024!` | — | SPN servicio SQL |
| `ceo.martinez` | `Direccion2024!` | — | AS-REP Roasteable |
| `fin.garcia` | `Finanzas2024!` | — | WriteDACL Lab-04 |
| `cross.user` | `CrossUser2024!` | — | Cuenta cross-forest |
| `child.user` | `ChildUser2024!` | — | SID History target Lab-06 |

### corp.local (DC-02)

| Usuario | Contraseña | Grupo | Rol en labs |
|---------|-----------|-------|-------------|
| `Administrador` | `Admin1234!` | Domain Admins | Admin dominio |
| `corp.admin` | `CorpAdmin2024!` | **Domain Admins** | DA corp.local |
| `john.smith` | `JohnCorp2024!` | — | GenericAll sobre corp_svc — autologon WKSTN-02 |
| `sarah.connor` | `SarahCorp2024!` | — | Usuario normal |
| `corp_svc` | `CorpSvc2024!` | — | SPN MSSQLSvc/DC-02:1433 — Kerberoasteable |

### child.atackcorp.local (DC-03)

| Usuario | Contraseña | Grupo | Rol en labs |
|---------|-----------|-------|-------------|
| `Administrador` | `Admin1234!` | Domain Admins | Admin dominio |
| `child.admin` | `ChildAdmin2024!` | **Domain Admins** | DA child domain — acceso Evil-WinRM DC-03 |
| `child.user` | `ChildUser2024!` | — | Target SID History injection |
| `child_svc` | `ChildSvc2024!` | — | SPN HTTP/DC-03 |

### ext.local (DC-04)

| Usuario | Contraseña | Grupo | Rol en labs |
|---------|-----------|-------|-------------|
| `Administrador` | `Admin1234!` | Domain Admins | Admin dominio |
| `ext.admin` | `ExtAdmin2024!` | **Domain Admins** | DA ext.local — en Ext-Data share |
| `ext.user` | `ExtUser2024!` | Ext-Readers | Acceso share Ext-Data |
| `ext_svc` | `ExtSvc2024!` | — | SPN MSSQLSvc/DC-04:1433 |

---

## Credenciales de servicios (DC-01)

| Servicio | Usuario | Contraseña | Ubicación |
|---------|---------|-----------|-----------|
| MSSQL SA | `sa` | `SQLsa2026!` | IT-Scripts/backup_database.ps1 |
| IIS Service | `ATACKCORP\iis_svc` | `IISService2024!` | IT-Scripts/deploy_webapp.ps1 |
| Webapp DB | `webapp_db` | `WebappDB2024!` | IT-Scripts/deploy_webapp.ps1 |

---

## Acceso rápido para administración

```bash
# DC-01
evil-winrm -i 10.0.2.10 -u Administrador -p 'NuevaPassword2026!'

# DC-02
evil-winrm -i 10.0.2.11 -u Administrador -p 'Admin1234!'

# DC-03
evil-winrm -i 10.0.2.13 -u child.admin -p 'ChildAdmin2024!'

# DC-04
evil-winrm -i 10.0.2.14 -u Administrador -p 'Admin1234!'
```

---

*Red Team Ops Roadmap — Adrián Camacho | Uso exclusivo en entorno de laboratorio local*