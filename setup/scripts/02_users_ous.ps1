# =============================================================
# SCRIPT 02 — Creación de OUs, usuarios y grupos
# Ejecutar: PowerShell como Administrador del dominio
# Máquina: DC-01 (después del reinicio)
# =============================================================

Import-Module ActiveDirectory

Write-Host "`n[*] Creando estructura de OUs..." -ForegroundColor Cyan

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
        Write-Host "[+] OU creada: $name" -ForegroundColor Green
    } else {
        Write-Host "[!] OU ya existe: $name" -ForegroundColor Yellow
    }
}

Write-Host "`n[*] Creando usuarios corporativos..." -ForegroundColor Cyan

# ── Crear usuarios corporativos ──────────────────────────────
$usuarios = @(
    @{ Name="Carlos Martinez"; Sam="ceo.martinez"; Pass="Direccion2024!"; OU="OU=Direccion,OU=Corporativo,DC=atackcorp,DC=local"; NoPreAuth=$true },
    @{ Name="Laura Lopez";     Sam="rrhh.lopez";   Pass="RRHH2024!";      OU="OU=RRHH,OU=Corporativo,DC=atackcorp,DC=local";      NoPreAuth=$false },
    @{ Name="Fernando Garcia"; Sam="fin.garcia";   Pass="Finanzas2024!";  OU="OU=Finanzas,OU=Corporativo,DC=atackcorp,DC=local";  NoPreAuth=$false },
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
        Write-Host "[+] Usuario creado: $($u.Sam)" -ForegroundColor Green
    } else {
        Write-Host "[!] Usuario ya existe: $($u.Sam)" -ForegroundColor Yellow
    }
    if ($u.NoPreAuth) {
        Set-ADAccountControl -Identity $u.Sam -DoesNotRequirePreAuth $true
        Write-Host "[!] AS-REP Roasting habilitado: $($u.Sam)" -ForegroundColor Red
    }
}

Write-Host "`n[*] Creando cuentas de servicio..." -ForegroundColor Cyan

# ── Crear cuentas de servicio ────────────────────────────────
$servicios = @(
    @{ Sam="sql_svc";    Pass="SqlService123"; SPN="MSSQLSvc/dc01.atackcorp.local:1433"; NoPreAuth=$false },
    @{ Sam="iis_svc";    Pass="IisService123";  SPN="HTTP/dc01.atackcorp.local";          NoPreAuth=$false },
    @{ Sam="backup_svc"; Pass="Backup2024!";    SPN=$null;                                NoPreAuth=$true  }
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
        Write-Host "[+] Cuenta de servicio creada: $($svc.Sam)" -ForegroundColor Green
    } else {
        Write-Host "[!] Cuenta ya existe: $($svc.Sam)" -ForegroundColor Yellow
    }
    if ($svc.SPN) {
        Set-ADUser -Identity $svc.Sam -ServicePrincipalNames @{Add=$svc.SPN}
        Write-Host "[!] Kerberoasting habilitado (SPN): $($svc.Sam) -> $($svc.SPN)" -ForegroundColor Red
    }
    if ($svc.NoPreAuth) {
        Set-ADAccountControl -Identity $svc.Sam -DoesNotRequirePreAuth $true
        Write-Host "[!] AS-REP Roasting habilitado: $($svc.Sam)" -ForegroundColor Red
    }
}

# ── it.admin → Account Operators ────────────────────────────
Add-ADGroupMember -Identity "Opers. de cuentas" -Members "it.admin"
Write-Host "[!] ACL Abuse: it.admin añadido a Account Operators" -ForegroundColor Red

# ── Usuarios de administración remota (WinRM) ────────────────
$winrmUsers = @("ceo.martinez", "backup_svc", "helpdesk.ruiz")
foreach ($u in $winrmUsers) {
    Add-ADGroupMember -Identity "Usuarios de administración remota" -Members $u -ErrorAction SilentlyContinue
    Write-Host "[+] WinRM habilitado para: $u" -ForegroundColor Green
}

Write-Host "`n[+] Script 02 completado." -ForegroundColor Green