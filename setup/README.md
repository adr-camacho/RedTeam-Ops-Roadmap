# ⚙️ Setup — Aprovisionamiento del Entorno

Este directorio contiene todos los scripts PowerShell necesarios para desplegar el entorno de laboratorio desde cero, así como las capturas de evidencia del aprovisionamiento.

---

## 📋 Orden de Ejecución

| # | Script | Máquina | Prerequisito | Reinicio |
|---|--------|---------|-------------|---------|
| 01 | `01_ad_promotion.ps1` | DC-01 | Windows Server 2019 limpio | ✅ Sí |
| 02 | `02_users_ous.ps1` | DC-01 | Script 01 + reinicio | No |
| 03 | `03_acls_delegations.ps1` | DC-01 | Script 02 | No |
| 04 | `04_iis_smb_gpo.ps1` | DC-01 | Script 02 | No |
| 05 | `05_mssql.ps1` | DC-01 | SQL Server Express instalado manualmente | No |
| 06 | `06_wkstn01.ps1` | WKSTN-01 | Máquina unida al dominio | No |

---

## 🚀 Ejecución

Todos los scripts deben ejecutarse como **Administrador** en PowerShell:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\01_ad_promotion.ps1
```

---

## 🏗️ Infraestructura resultante

Tras ejecutar todos los scripts el entorno queda configurado con:

**Dominio:** `atackcorp.local`

**Usuarios y vectores:**

| Usuario | Contraseña | Vector habilitado |
|---------|-----------|-------------------|
| `ceo.martinez` | `Direccion2024!` | AS-REP Roasting |
| `backup_svc` | `Backup2024!` | AS-REP Roasting |
| `sql_svc` | `SqlService123` | Kerberoasting + Unconstrained Delegation |
| `iis_svc` | `IisService123` | Kerberoasting + Constrained Delegation |
| `fin.garcia` | `Finanzas2024!` | GenericWrite sobre sql_svc |
| `it.admin` | `ITAdmin2024!` | Account Operators |
| `helpdesk.ruiz` | `Helpdesk2024!` | WriteDACL + GPO Abuse + SeImpersonate |
| `rrhh.lopez` | `RRHH2024!` | Credenciales en share SMB |
| `Administrator` | `Admin1234!` | Domain Admin |
| `sa` (MSSQL) | `Sa_Admin2024!` | xp_cmdshell |

---

## 📸 Capturas de aprovisionamiento

Las capturas de evidencia del setup se guardan en `screenshots/`:

| Archivo | Descripción |
|---------|-------------|
| `00_ad_promotion.png` | Promoción del dominio completada |
| `00_ou_structure.png` | Estructura de OUs en ADUC |
| `00_users_created.png` | Usuarios y cuentas de servicio creados |
| `00_spns_configured.png` | SPNs de sql_svc e iis_svc configurados |
| `00_acls_configured.png` | ACLs abusables configuradas |
| `00_delegation_set.png` | Delegaciones Kerberos configuradas |
| `00_smb_shares.png` | SMB shares creados |
| `00_iis_running.png` | IIS activo con info leak |
| `00_wkstn_config.png` | WKSTN-01 configurada |

---

> ⚠️ Entorno diseñado únicamente para fines educativos y de laboratorio.