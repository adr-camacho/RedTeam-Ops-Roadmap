# 🏗️ Infraestructura Vulnerable — Entorno Empresa Mediana

> Documento de aprovisionamiento completo para el entorno de laboratorio Red Team.  
> Simula una empresa mediana con Active Directory, SQL Server, IIS y shares corporativos.  
> Incluye vectores de ataque reales: Kerberos, ACL Abuse, Delegaciones, MSSQL, GPO Abuse y Trusts.

---

## 📋 Índice

1. [Diagrama de Red y Vulnerabilidades](#-diagrama-de-red-y-vulnerabilidades)
2. [Máquinas del Entorno](#-máquinas-del-entorno)
3. [DC-01 — Domain Controller](#-dc-01--domain-controller)
4. [WKSTN-01 — Workstation Corporativa](#-wkstn-01--workstation-corporativa)
5. [Mapa de Vectores de Ataque](#-mapa-de-vectores-de-ataque)
6. [Scripts de Aprovisionamiento](#-scripts-de-aprovisionamiento)

---

## 🗺️ Diagrama de Red y Vulnerabilidades

```
┌─────────────────────────────────────────────────────────────────┐
│                    RED NAT — LabRedTeam                         │
│                     Segmento: 10.0.2.0/24                       │
│                                                                 │
│  ┌─────────────────────┐      ┌─────────────────────────────┐   │
│  │      DC-01          │      │         WKSTN-01            │   │
│  │  Windows Server     │      │   Windows 11 Enterprise     │   │
│  │      2022           │◄────►│        10.0.2.8             │   │
│  │    10.0.2.10        │      │                             │   │
│  │                     │      │  Vulnerabilidades:          │   │
│  │  Servicios:         │      │  [W1] Token Impersonation   │   │
│  │  • AD DS            │      │  [W2] Unquoted Service Path │   │
│  │  • DNS              │      │  [W3] AlwaysInstallElev.    │   │
│  │  • MSSQL Server     │      │  [W4] Autologon Creds       │   │
│  │  • IIS 10.0         │      │  [W5] LAPS no configurado   │   │
│  │  • SMB Shares       │      │  [W6] Weak Service Perms    │   │
│  │                     │      └─────────────────────────────┘   │
│  │  Vulnerabilidades:  │                                        │
│  │  [D1] AS-REP Roast  │      ┌─────────────────────────────┐   │
│  │  [D2] Kerberoasting │      │          Kali               │   │
│  │  [D3] ACL Abuse     │      │      Kali Linux 2026.1      │   │
│  │  [D4] Delegación    │◄────►│        10.0.2.9             │   │
│  │  [D5] GPO Abuse     │      │                             │   │
│  │  [D6] MSSQL xp_cmd  │      │      Máquina Atacante       │   │
│  │  [D7] Info Leak     │      └─────────────────────────────┘   │
│  │  [D8] SMB Null Sess │                                        │
│  └─────────────────────┘                                        │
└─────────────────────────────────────────────────────────────────┘

Dominio: atackcorp.local
```

---

## 💻 Máquinas del Entorno

| Host | SO | IP | RAM | Rol | Servicios |
|------|----|----|-----|-----|-----------|
| DC-01 | Windows Server 2022 Standard Evaluation | `10.0.2.10` | 2GB | Domain Controller | AD DS, DNS, MSSQL, IIS, SMB |
| WKSTN-01 | Windows 11 Enterprise Evaluation | `10.0.2.8` | 4GB | Workstation | SMB, WinRM, Servicios locales |
| Kali | Kali Linux 2026.1 | `10.0.2.9` | 2GB | Atacante | Arsenal Red Team |

### Configuración de red Kali (permanente)

```bash
# IP estática via NetworkManager
sudo nmcli con add type ethernet con-name "LabRedTeam" ifname eth0 \
  ipv4.method manual \
  ipv4.addresses 10.0.2.9/24 \
  ipv4.gateway 10.0.2.1 \
  ipv4.dns 10.0.2.10 \
  connection.autoconnect yes
sudo nmcli con up LabRedTeam
```

---

## 🖥️ DC-01 — Domain Controller

### Software a instalar

| Software | Versión | Propósito | Vector habilitado |
|----------|---------|-----------|-------------------|
| Active Directory DS | Incluido en WS2022 | Controlador de dominio | Base de todo |
| DNS Server | Incluido en WS2022 | Resolución de nombres | — |
| MSSQL Server Express | 2019 | Base de datos corporativa | [D6] xp_cmdshell |
| IIS 10.0 | Incluido en WS2022 | Web interna corporativa | [D7] Info Leak |
| RSAT Tools | Incluido | Administración AD | — |

### Estructura de Active Directory

```
atackcorp.local
│
├── OU=Corporativo
│   ├── OU=Direccion
│   │   └── Usuario: ceo.martinez (alto privilegio, AS-REP Roasting)
│   ├── OU=RRHH
│   │   └── Usuario: rrhh.lopez
│   └── OU=Finanzas
│       └── Usuario: fin.garcia (GenericWrite sobre sql_svc)
│
├── OU=IT
│   ├── OU=Administradores
│   │   └── Usuario: it.admin (miembro de Account Operators)
│   └── OU=Helpdesk
│       └── Usuario: helpdesk.ruiz (WriteDACL sobre WKSTN-01)
│
├── OU=CuentasServicio
│   ├── sql_svc (SPN: MSSQLSvc/dc01.atackcorp.local:1433) ← Kerberoasting + Unconstrained Delegation
│   ├── iis_svc (SPN: HTTP/dc01.atackcorp.local) ← Kerberoasting + Constrained Delegation
│   └── backup_svc (DoesNotRequirePreAuth=True + DA) ← AS-REP Roasting
│
└── OU=Equipos
    └── WKSTN-01
```

### Vulnerabilidades del DC-01

**[D1] AS-REP Roasting**
- Cuentas afectadas: `backup_svc`, `ceo.martinez`
- Atributo: `DoesNotRequirePreAuth = True`

**[D2] Kerberoasting**
- Cuentas afectadas: `sql_svc` (MSSQL), `iis_svc` (HTTP)
- SPNs configurados con contraseñas crackeables

**[D3] ACL Abuse**
- `fin.garcia` tiene `GenericWrite` sobre `sql_svc` → permite modificar SPN o resetear contraseña
- `helpdesk.ruiz` tiene `WriteDACL` sobre el objeto `WKSTN-01` → permite añadir permisos
- `it.admin` es miembro de `Account Operators` → puede modificar usuarios no admin

**[D4] Delegación Kerberos**
- `sql_svc` tiene configurada **Unconstrained Delegation**
- `iis_svc` tiene configurada **Constrained Delegation** (S4U2Proxy) hacia MSSQL

**[D5] GPO Abuse**
- GPO `IT-Baseline` tiene permisos de escritura para el grupo `Helpdesk`
- Permite modificar GPO y ejecutar código en equipos donde se aplica

**[D6] MSSQL xp_cmdshell**
- `sql_svc` tiene habilitado `xp_cmdshell`
- Login SA con contraseña débil como fallback

**[D7] Information Leak — IIS**
- Página web interna expone versión de software y estructura de directorios
- Archivo `web.config` accesible con credenciales en texto claro

**[D8] SMB Null Session**
- Share `\\DC-01\Publico` accesible sin autenticación
- Contiene documentos con información sensible (contraseñas en docs)

---

## 🖥️ WKSTN-01 — Workstation Corporativa

### Software a instalar

| Software | Versión | Propósito | Vector habilitado |
|----------|---------|-----------|-------------------|
| Google Chrome | Última | Navegador corporativo | [W4] Credenciales guardadas |
| 7-Zip | 23.x | Compresor corporativo | [W2] Unquoted Service Path |
| VNC Server (TightVNC) | 2.8 | Acceso remoto IT | [W4] Contraseña débil registry |
| Servicio personalizado | — | Servicio corporativo ficticio | [W2] Unquoted Path + [W6] Weak Perms |
| WinRM habilitado | — | Administración remota | Acceso post-explotación |

### Vulnerabilidades de WKSTN-01

**[W1] Token Impersonation**
- Usuario `helpdesk.ruiz` con privilegios `SeImpersonatePrivilege`
- Vector: PrintSpoofer / GodPotato para elevar a SYSTEM
- **Nota:** En Windows 11 via WinRM, los Potato attacks fallan por Network tokens. Requiere sesión interactiva.

**[W2] Unquoted Service Path**
- Servicio: `C:\Program Files\Servicio Corporativo\Monitor\monitor.exe`
- Permite colocar binario malicioso en `C:\Program Files\Servicio.exe`

**[W3] AlwaysInstallElevated**
- Registry keys configuradas:
  - `HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated = 1`
  - `HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated = 1`
- Permite instalar .msi con privilegios SYSTEM

**[W4] Autologon / Credenciales en Registry**
- `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon`
  - `DefaultUserName = helpdesk.ruiz`
  - `DefaultPassword = Helpdesk2024!`
- TightVNC con contraseña débil en registry (`rrhh.lopez:Verano2024`)

**[W5] LAPS no configurado**
- Contraseña de administrador local idéntica en DC-01 y WKSTN-01
- Permite Pass-the-Hash lateral una vez obtenido el hash

**[W6] Weak Service Permissions**
- El servicio `CorpMonitor` tiene permisos `SERVICE_ALL_ACCESS` para `Authenticated Users`
- Permite modificar el binario del servicio y ejecutar código como SYSTEM

---

## 🎯 Mapa de Vectores de Ataque

```
FASE 1 — Acceso Inicial
────────────────────────
Kali → SMB Null Session [D8] → Documentos con credenciales
     → AS-REP Roasting [D1] → Hash de backup_svc / ceo.martinez
     → Kerberoasting [D2] → Hash de sql_svc / iis_svc

FASE 2 — Post-Explotación (DC)
────────────────────────────────
Credenciales sql_svc → MSSQL xp_cmdshell [D6] → Shell como sql_svc
Hash crackeado → Evil-WinRM → Acceso interactivo
                → Enumeración ACLs [D3]
                → fin.garcia → GenericWrite sobre sql_svc → Reset password

FASE 3 — Movimiento Lateral
────────────────────────────
helpdesk.ruiz → WriteDACL sobre WKSTN-01 [D3] → Acceso a workstation
              → SeImpersonatePrivilege [W1] → SYSTEM en WKSTN-01 (requiere sesión interactiva)
WKSTN-01 → Autologon creds [W4] → Credenciales rrhh.lopez
         → LAPS ausente [W5] → Pass-the-Hash al DC
         → AlwaysInstallElevated [W3] → Escalada via MSI malicioso

FASE 4 — Escalada de Privilegios (AD)
───────────────────────────────────────
it.admin (Account Operators) [D3] → Modificar miembros de grupos
GPO Helpdesk [D5] → Modificar GPO → Ejecución como SYSTEM en WKSTN-01
Unconstrained Delegation sql_svc [D4] → Captura TGT de DA → Pass-the-Ticket
Constrained Delegation iis_svc [D4] → S4U2Self + S4U2Proxy → Impersonar DA

OBJETIVO FINAL: Domain Admin sobre atackcorp.local
```

---

## 📜 Scripts de Aprovisionamiento

### Script 1 — DC-01: Promoción y configuración del dominio

Ejecutar en DC-01 como Administrador local, **antes** de promocionar el dominio:

```powershell
# =============================================================
# SCRIPT 01 — Instalación AD DS y promoción del dominio
# Ejecutar: PowerShell como Administrador
# =============================================================

# 1. Instalar rol AD DS
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 2. Promocionar como Domain Controller
Import-Module ADDSDeployment
Install-ADDSForest `
    -DomainName "atackcorp.local" `
    -DomainNetbiosName "ATACKCORP" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns:$true `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "Admin1234!" -AsPlainText -Force) `
    -Force:$true

# El servidor se reiniciará automáticamente
```

---

### Script 2 — DC-01: Estructura AD y usuarios vulnerables

Ejecutar **después** del reinicio, como Administrador del dominio:

```powershell
# =============================================================
# SCRIPT 02 — Creación de OUs, usuarios y grupos
# =============================================================

Import-Module ActiveDirectory

# ── Crear estructura de OUs ──────────────────────────────────
$OUs = @(
    "OU=Corporativo,DC=atackcorp,DC=local",
    "OU=Direccion,OU=Corporativo,DC=atackcorp,DC=local",
    "OU=RRHH,OU=Corporativo,DC=atackcorp,DC=local",
    "OU=Finanzas,OU=Corporativo,DC=atackcorp,DC=local",
    "OU=IT,DC=atackcorp,DC=local",
    "OU=Administradores,OU=IT,DC=atackcorp,DC=local",
    "OU=Helpdesk,OU=IT,DC=atackcorp,DC=local",
    "OU=CuentasServicio,DC=atackcorp,DC=local",
    "OU=Equipos,DC=atackcorp,DC=local"
)

foreach ($ou in $OUs) {
    $name = ($ou -split ",")[0] -replace "OU=", ""
    $path = ($ou -split ",", 2)[1]
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ou'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $name -Path $path
        Write-Host "[+] OU creada: $name"
    }
}

# ── Crear usuarios corporativos ──────────────────────────────
$usuarios = @(
    @{ Name="Carlos Martinez"; Sam="ceo.martinez"; Pass="Direccion2024!"; OU="OU=Direccion,OU=Corporativo,DC=atackcorp,DC=local"; NoPreAuth=$true },
    @{ Name="Laura Lopez";     Sam="rrhh.lopez";   Pass="RRHH2024!";      OU="OU=RRHH,OU=Corporativo,DC=atackcorp,DC=local";      NoPreAuth=$false },
    @{ Name="Fernando Garcia"; Sam="fin.garcia";   Pass="Finance2024!" ;  OU="OU=Finanzas,OU=Corporativo,DC=atackcorp,DC=local";  NoPreAuth=$false },
    @{ Name="IT Admin";        Sam="it.admin";     Pass="ITAdmin2024!";   OU="OU=Administradores,OU=IT,DC=atackcorp,DC=local";    NoPreAuth=$false },
    @{ Name="Helpdesk Ruiz";   Sam="helpdesk.ruiz";Pass="Helpdesk2024!";  OU="OU=Helpdesk,OU=IT,DC=atackcorp,DC=local";          NoPreAuth=$false }
)

foreach ($u in $usuarios) {
    $pass = ConvertTo-SecureString $u.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name $u.Name `
            -SamAccountName $u.Sam `
            -UserPrincipalName "$($u.Sam)@atackcorp.local" `
            -Path $u.OU `
            -AccountPassword $pass `
            -Enabled $true
        Write-Host "[+] Usuario creado: $($u.Sam)"
    }
    if ($u.NoPreAuth) {
        Set-ADAccountControl -Identity $u.Sam -DoesNotRequirePreAuth $true
        Write-Host "[!] AS-REP Roasting habilitado: $($u.Sam)"
    }
}

# ── Crear cuentas de servicio ────────────────────────────────
$servicios = @(
    @{ Sam="sql_svc";    Pass="SqlService123"; SPN="MSSQLSvc/dc01.atackcorp.local:1433"; NoPreAuth=$false },
    @{ Sam="iis_svc";    Pass="IisService123";  SPN="HTTP/dc01.atackcorp.local";          NoPreAuth=$false },
    @{ Sam="backup_svc"; Pass="Backup2024!";    SPN="MSSQLSvc/DC-01.atackcorp.local:1433"; NoPreAuth=$true  }
)

foreach ($svc in $servicios) {
    $pass = ConvertTo-SecureString $svc.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($svc.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name $svc.Sam `
            -SamAccountName $svc.Sam `
            -UserPrincipalName "$($svc.Sam)@atackcorp.local" `
            -Path "OU=CuentasServicio,DC=atackcorp,DC=local" `
            -AccountPassword $pass `
            -Enabled $true
        Write-Host "[+] Cuenta de servicio creada: $($svc.Sam)"
    }
    if ($svc.SPN) {
        # SPN hardcodeado como literal para evitar bug de interpolación en try/catch
        Set-ADUser -Identity $svc.Sam -ServicePrincipalNames @{Add=$svc.SPN}
        Write-Host "[!] Kerberoasting habilitado (SPN): $($svc.Sam) → $($svc.SPN)"
    }
    if ($svc.NoPreAuth) {
        Set-ADAccountControl -Identity $svc.Sam -DoesNotRequirePreAuth $true
        Write-Host "[!] AS-REP Roasting habilitado: $($svc.Sam)"
    }
}

# ── backup_svc → Domain Admins (por SID-512, universal) ──────
$daGroup = Get-ADGroup -Filter {SID -eq "S-1-5-21-768292631-183641691-1245477636-512"}
Add-ADGroupMember -Identity $daGroup -Members "backup_svc"
Write-Host "[!] backup_svc añadido a $($daGroup.Name)"

# ── it.admin → Account Operators ────────────────────────────
Add-ADGroupMember -Identity "Opers. de cuentas" -Members "it.admin" -ErrorAction SilentlyContinue
Write-Host "[!] ACL Abuse: it.admin añadido a Account Operators"

# ── Añadir ceo.martinez a Remote Management Users ────────────
Add-ADGroupMember -Identity "Usuarios de administración remota" -Members "ceo.martinez"
Write-Host "[+] ceo.martinez añadido a Usuarios de administración remota"

Write-Host "`n[+] Script 02 completado."
```

---

### Script 3 — DC-01: ACLs abusables y delegaciones

```powershell
# =============================================================
# SCRIPT 03 — Configuración de ACLs vulnerables y delegaciones
# =============================================================

Import-Module ActiveDirectory

# ── GenericWrite: fin.garcia sobre sql_svc ───────────────────
$finGarcia  = (Get-ADUser "fin.garcia").SID
$sqlSvc     = Get-ADUser "sql_svc" -Properties DistinguishedName
$acl        = Get-Acl "AD:\$($sqlSvc.DistinguishedName)"
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $finGarcia,
    [System.DirectoryServices.ActiveDirectoryRights]::GenericWrite,
    [System.Security.AccessControl.AccessControlType]::Allow
)
$acl.AddAccessRule($rule)
Set-Acl "AD:\$($sqlSvc.DistinguishedName)" $acl
Write-Host "[!] ACL Abuse: fin.garcia tiene GenericWrite sobre sql_svc"

# ── WriteDACL: helpdesk.ruiz sobre WKSTN-01 ─────────────────
$helpdesk = (Get-ADUser "helpdesk.ruiz").SID
$wkstn    = Get-ADComputer "WKSTN-01" -Properties DistinguishedName
$acl2     = Get-Acl "AD:\$($wkstn.DistinguishedName)"
$rule2 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $helpdesk,
    [System.DirectoryServices.ActiveDirectoryRights]::WriteDacl,
    [System.Security.AccessControl.AccessControlType]::Allow
)
$acl2.AddAccessRule($rule2)
Set-Acl "AD:\$($wkstn.DistinguishedName)" $acl2
Write-Host "[!] ACL Abuse: helpdesk.ruiz tiene WriteDACL sobre WKSTN-01"

# ── DCSync ACL: ceo.martinez ─────────────────────────────────
$DomainDN = (Get-ADDomain).DistinguishedName
$userSID  = (Get-ADUser "ceo.martinez").SID
$aclDC    = Get-Acl "AD:\$DomainDN"

foreach ($guid in @(
    [GUID]"1131f6aa-9c07-11d1-f79f-00c04fc2dcd2",  # DS-Replication-Get-Changes
    [GUID]"1131f6ab-9c07-11d1-f79f-00c04fc2dcd2",  # DS-Replication-Get-Changes-All
    [GUID]"89e95b76-444d-4c62-991a-0facbeda640c"   # DS-Replication-Get-Changes-In-Filtered-Set
)) {
    $rule3 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $userSID,
        [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight,
        [System.Security.AccessControl.AccessControlType]::Allow,
        $guid,
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
    )
    $aclDC.AddAccessRule($rule3)
}
Set-Acl "AD:\$DomainDN" $aclDC
Write-Host "[!] DCSync ACL: ceo.martinez tiene permisos de replicación"

# ── Unconstrained Delegation: sql_svc ───────────────────────
Set-ADAccountControl -Identity "sql_svc" -TrustedForDelegation $true
Write-Host "[!] Delegación: Unconstrained Delegation habilitada en sql_svc"

# ── Constrained Delegation: iis_svc → MSSQL ─────────────────
Set-ADUser -Identity "iis_svc" -Add @{
    'msDS-AllowedToDelegateTo' = 'MSSQLSvc/dc01.atackcorp.local:1433'
}
Set-ADAccountControl -Identity "iis_svc" -TrustedToAuthForDelegation $true
Write-Host "[!] Delegación: Constrained Delegation (S4U2Proxy) habilitada en iis_svc"

# ── Password en Description: backup_svc ─────────────────────
Set-ADUser "backup_svc" -Description "Backup Service - pwd temporal: Backup2024! (pendiente cambio)"
Write-Host "[!] Info Leak: password en Description de backup_svc"

Write-Host "`n[+] Script 03 completado."
```

---

### Script 4 — DC-01: IIS, MSSQL, SMB Shares y GPO abusable

```powershell
# =============================================================
# SCRIPT 04 — Servicios: IIS, SMB Shares, GPO vulnerable
# =============================================================

# ── Instalar IIS ─────────────────────────────────────────────
Install-WindowsFeature -Name Web-Server, Web-Mgmt-Tools -IncludeManagementTools
$webContent = @"
<html><head><title>AtackCorp - Portal Interno</title></head>
<body>
<h1>Portal Interno AtackCorp</h1>
<p>Sistema: Windows Server 2022 Standard Evaluation — IIS 10.0 — ASP.NET 4.8</p>
<!-- Conexion BD: Server=dc01;Database=CorpDB;User=sql_svc;Password=SqlService123 -->
<p>Contacto IT: it.admin@atackcorp.local</p>
</body></html>
"@
Set-Content "C:\inetpub\wwwroot\index.html" $webContent
Write-Host "[!] Info Leak: credenciales en comentario HTML de IIS"

# ── SMB Share corporativo con acceso anónimo ─────────────────
New-Item -Path "C:\Shares\Publico" -ItemType Directory -Force
New-Item -Path "C:\Shares\IT" -ItemType Directory -Force

$docContent = @"
=== CREDENCIALES DE ACCESO — USO INTERNO ===
VPN: vpn.atackcorp.local / Usuario: it.admin / Pass: ITAdmin2024!
Backup: backup_svc / Pass: Backup2024!
MSSQL SA: sa / Pass: Sa_Admin2024!
=== CONFIDENCIAL ===
"@
Set-Content "C:\Shares\Publico\IT_Passwords_OLD.txt" $docContent

New-SmbShare -Name "Publico" -Path "C:\Shares\Publico" `
    -ChangeAccess "Everyone" -ReadAccess "Everyone"
New-SmbShare -Name "IT$" -Path "C:\Shares\IT" `
    -FullAccess "ATACKCORP\it.admin", "ATACKCORP\Admins. del dominio"

Write-Host "[!] SMB: Share Publico accesible sin autenticación con credenciales expuestas"

# ── GPO abusable por Helpdesk ────────────────────────────────
Import-Module GroupPolicy
$gpo = New-GPO -Name "IT-Baseline" -Comment "Politica base equipos IT"
New-GPLink -Name "IT-Baseline" -Target "OU=Equipos,DC=atackcorp,DC=local"

$gpoPath = "\\atackcorp.local\SYSVOL\atackcorp.local\Policies\{$($gpo.Id)}"
$acl = Get-Acl $gpoPath
$helpdesk = New-Object System.Security.Principal.NTAccount("ATACKCORP\helpdesk.ruiz")
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $helpdesk, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl $gpoPath $acl
Write-Host "[!] GPO Abuse: helpdesk.ruiz tiene FullControl sobre IT-Baseline GPO"

Write-Host "`n[+] Script 04 completado."
```

---

### Script 5 — DC-01: Instalación MSSQL con xp_cmdshell

```powershell
# =============================================================
# SCRIPT 05 — Configuración MSSQL vulnerable
# NOTA: Instalar SQL Server Express 2019 manualmente primero
# Descarga: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
# =============================================================

$query = @"
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'sql_svc')
BEGIN
    CREATE LOGIN [sql_svc] WITH PASSWORD = 'SqlService123';
    EXEC sp_addsrvrolemember 'sql_svc', 'sysadmin';
END

ALTER LOGIN [sa] WITH PASSWORD = 'Sa_Admin2024!', CHECK_POLICY = OFF;
ALTER LOGIN [sa] ENABLE;

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CorpDB')
    CREATE DATABASE CorpDB;
"@

sqlcmd -S localhost -Q $query -E
Write-Host "[!] MSSQL: xp_cmdshell habilitado, login SA activo"
```

---

### Script 6 — WKSTN-01: Vulnerabilidades locales

Ejecutar en WKSTN-01 como Administrador local **después** de unirla al dominio:

```powershell
# =============================================================
# SCRIPT 06 — Configuración vulnerable de WKSTN-01
# Compatible con Windows 11 Enterprise Evaluation
# =============================================================

# ── Habilitar WinRM ──────────────────────────────────────────
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Write-Host "[+] WinRM habilitado"

# ── AlwaysInstallElevated ─────────────────────────────────────
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" `
    -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" `
    -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Write-Host "[!] AlwaysInstallElevated habilitado"

# ── Autologon con credenciales en registry ───────────────────
$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "helpdesk.ruiz"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "Helpdesk2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "ATACKCORP"
Write-Host "[!] Autologon configurado: helpdesk.ruiz / Helpdesk2024!"

# ── Servicio con Unquoted Path ───────────────────────────────
New-Item -Path "C:\Program Files\Servicio Corporativo\Monitor" -ItemType Directory -Force
sc.exe create "CorpMonitor" `
    binpath= "C:\Program Files\Servicio Corporativo\Monitor\monitor.exe" `
    start= auto `
    displayname= "Corporate Monitor Service"

# ── Weak Service Permissions ──────────────────────────────────
sc.exe sdset CorpMonitor "D:(A;;RPWPDTLOSDRCWDWO;;;AU)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;SY)"
Write-Host "[!] Weak Service Perms: Authenticated Users tienen control total sobre CorpMonitor"

# ── SeImpersonatePrivilege para helpdesk.ruiz ────────────────
# NOTA: En Windows 11 via WinRM, Potato attacks fallan por Network tokens
# SeImpersonatePrivilege funciona correctamente desde sesiones interactivas
$seceditCfg = @"
[Unicode]
Unicode=yes
[Privilege Rights]
SeImpersonatePrivilege = *S-1-5-32-568,*S-1-5-6,ATACKCORP\helpdesk.ruiz
"@
$seceditCfg | Out-File "$env:TEMP\privs.inf" -Encoding Unicode
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg "$env:TEMP\privs.inf" /quiet
Write-Host "[!] SeImpersonatePrivilege añadido a helpdesk.ruiz"

Write-Host "`n[+] Script 06 completado. WKSTN-01 lista."
```

---

## 🔑 Resumen de Credenciales del Lab

| Usuario | Contraseña | Privilegio | Vector |
|---------|-----------|------------|--------|
| `Administrador` | `Admin1234!` | Domain Admin (built-in) | — |
| `ceo.martinez` | `Direccion2024!` | Usuario normal + WinRM | AS-REP Roasting |
| `backup_svc` | `Backup2024!` | **Domain Admin** | AS-REP Roasting + Kerberoasting |
| `sql_svc` | `SqlService123` | Cuenta servicio | Kerberoasting + Unconstrained Deleg. |
| `iis_svc` | `IisService123` | Cuenta servicio | Kerberoasting + Constrained Deleg. |
| `fin.garcia` | `Finance2024!` | Usuario normal | GenericWrite sobre sql_svc |
| `it.admin` | `ITAdmin2024!` | Account Operators | ACL Abuse |
| `helpdesk.ruiz` | `Helpdesk2024!` | Helpdesk | WriteDACL, GPO, SeImpersonate |
| `rrhh.lopez` | `RRHH2024!` | Usuario normal | Credenciales en share |
| `sa` (MSSQL) | `Sa_Admin2024!` | Sysadmin SQL | xp_cmdshell |

---

---

## 🔴 Lab-04 — IRON FOREST | APT28 (Fancy Bear)

> Comparte el entorno base de Lab-01/03 (DC-01 + WKSTN-01 + Kali).  
> Requiere ejecutar `CrownJewels-Lab04-IronForest.ps1` en DC-01 antes de iniciar el lab.

### Setup requerido

```powershell
# En DC-01 como Administrador
.\Phase-02-Post-Exploitation\Lab-04-Iron-Forest\setup\CrownJewels-Lab04-IronForest.ps1
```

### Artefactos creados por CrownJewels

| Artefacto | Ruta | Propósito |
|---|---|---|
| `backup_database.ps1` | `C:\CorporateData\IT\Scripts\` | Credenciales sql_svc + backup_svc en claro |
| `deploy_webapp.ps1` | `C:\CorporateData\IT\Scripts\` | Credenciales iis_svc + webapp_db en claro |
| `ConsoleHost_history.txt` | `C:\Users\Administrador.DC-01\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\` | Contraseña DA + Finance2024! en claro |
| `Q1_2026_Confidential.txt` | `C:\CorporateData\Finance\Reports\` | Datos financieros (objetivo) |
| Share `IT-Scripts` | `\\DC-01\IT-Scripts` | ReadAccess: Usuarios del dominio |
| ACE WriteDACL | AD objeto dominio | fin.garcia → WriteDACL → DC=atackcorp,DC=local |

### Credenciales relevantes Lab-04

| Usuario | Contraseña | Origen | Relevancia |
|---|---|---|---|
| `fin.garcia` | `Finance2024!` | PS history del Administrador | **WriteDACL → DCSync path** |
| `backup_svc` | `Backup2024!` | backup_database.ps1 | Acceso C$ para PS history |
| `sa` (SQL) | `SQLsa2026!` | backup_database.ps1 | SQL lateral movement |
| `iis_svc` | `IISService2024!` | deploy_webapp.ps1 | Cuenta servicio IIS |
| `webapp_db` | `WebappDB2024!` | deploy_webapp.ps1 | Conexión string DB |
| `Administrador` | `NuevaPassword2026!` | PS history | Domain Admin directo |

### Loot capturado

```
loot/
├── dcsync_hashes.txt     — Todos los hashes NTLM del dominio (13 entradas)
└── ntlmv2_backup_svc.txt — NTLMv2 de backup_svc capturado via WPAD poisoning
```

### Herramientas específicas Lab-04

| Herramienta | Ruta en Kali | Uso |
|---|---|---|
| dnstool.py | `/opt/redteam/krbrelayx/dnstool.py` | ADIDNS registro WPAD |
| SharpHound.exe | `/opt/redteam/windows/SharpHound.exe` | Recolección BloodHound CE |
| BloodHound CE | `~/tools/ad/bloodhound-ce/` | `sudo docker compose up -d` |

### Crown Jewels obtenidos

| # | Objetivo | Resultado |
|---|---|---|
| 1 | Credenciales en scripts IT | ✅ 4 credenciales en claro |
| 2 | Historial PS Administrador | ✅ `Finance2024!` + `NuevaPassword2026!` |
| 3 | DCSync rights via WriteDACL | ✅ fin.garcia → DS-Replication |
| 4 | Hash NTLM Administrador | ✅ `bc3abc2e0673a58e9e559d415b56d69d` |
| 5 | Hash NTLM krbtgt | ✅ `d5237a2e43cb315c90679e2a5dae34ad` |
| 6 | NTLMv2 backup_svc via WPAD | ✅ Capturado con Responder |
| 7 | Beacon Sliver en DC-01 | ✅ `iron_forest_dc01` — ATACKCORP\Administrador |

---

## 🔴 Lab-05 — SILVER CHAIN | APT28 (Fancy Bear)

> Comparte el entorno base de Lab-01/03/04 (DC-01 + WKSTN-01 + Kali).  
> Requiere ejecutar `Setup-Lab05-SilverChain.ps1` en DC-01 antes de iniciar el lab.

### Setup requerido

```powershell
# En DC-01 como Administrador — subir via Evil-WinRM desde Kali
# upload /home/kali/RedTeam-Repo/Phase-02-Post-Exploitation/Lab-05-Silver-Chain/setup/Setup-Lab05-SilverChain.ps1
.\Setup-Lab05-SilverChain.ps1
```

### Cambios específicos del entorno

| Componente | Cambio | Propósito |
|------------|--------|-----------|
| `helpdesk.ruiz` → `WKSTN-01$` | GenericWrite añadido | RBCD abuse path |
| `fin.garcia` → `iis_svc` | WriteProperty msDS-KeyCredentialLink | Shadow Credentials path |
| DC-01 | SQL Server Express 2022 instalado | Silver Ticket target (MSSQLSvc/1433) |
| DC-01 | Share `SQL-Confidential` creado | Crown Jewel objetivo |
| MachineAccountQuota | = 10 (verificado) | Crear ATTACKER$ para RBCD |

### Credenciales relevantes Lab-05

| Usuario | Contraseña | Hash NTLM | Relevancia |
|---------|-----------|-----------|------------|
| `helpdesk.ruiz` | `Helpdesk2024!` | — | Credencial inicial — RBCD path |
| `fin.garcia` | `Finance2024!` | — | Shadow Credentials path |
| `iis_svc` | `IisService123` | `b329981877f0ca1243192863f356a2f9` | Target Shadow Credentials |
| `ATTACKER$` | `Attacker2026!` | — | Cuenta máquina RBCD (eliminada post-lab) |
| `Administrador` | `NuevaPassword2026!` | `bc3abc2e0673a58e9e559d415b56d69d` | DA |
| `krbtgt` | — | `d5237a2e43cb315c90679e2a5dae34ad` | Diamond Ticket — AES256: `2f123c9bb0d3fadaa6b09592d0a5be11c2d0768cc7f566d8939a5d021e517aa6` |

### Loot capturado

```
loot/
├── lab05_hashes.txt      — iis_svc NTLM hash
└── lab05_sharphound.zip  — BloodHound collection (354 objetos)
```

### Crown Jewels obtenidos

| # | Objetivo | Técnica | Resultado |
|---|----------|---------|-----------|
| 1 | Acceso C$ WKSTN-01 como Administrador | RBCD S4U2Proxy | ✅ TGS Kerberos sin credenciales en claro |
| 2 | Hash NTLM iis_svc | Shadow Credentials PKINIT | ✅ `b329981877f0ca1243192863f356a2f9` |
| 3 | Acceso MSSQLSvc/DC-01:1433 | Silver Ticket | ✅ Forjado localmente sin KDC |
| 4 | Acceso C$ DC-01 | Diamond Ticket | ✅ TGT real + PAC modificado — bypass PAC Validation |
| 5 | Beacon WKSTN-01 | Sliver HTTP | ✅ LIGHT_CARTLOAD — ATACKCORP\Administrador |

### Notas técnicas

- **pywhisker conflicto:** Instala impacket 0.12.0 → reinstalar 0.13.1 antes de ticketer
- **SQL Server:** Descargado en Kali (266MB) y subido via Evil-WinRM — no pre-instalado
- **Diamond Ticket:** Requiere AES256 del krbtgt — NTLM no suficiente para Rubeus diamond
- **kirbi→ccache:** Rubeus genera .kirbi — convertir con `impacket-ticketConverter`
- **Evil-WinRM + Kerberos:** Requiere `/etc/hosts` y `/etc/krb5.conf` configurados

*Última actualización: Mayo 2026 — Lab-05 SILVER CHAIN añadido — Adrián Camacho*