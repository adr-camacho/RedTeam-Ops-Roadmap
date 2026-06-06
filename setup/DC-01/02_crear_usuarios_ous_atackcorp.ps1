# 02_crear_usuarios_ous_atackcorp.ps1
# Maquina: DC-01 (atackcorp.local)
# Version: 2.1 | Junio 2026
# FIX v2.1: sql_svc: SQLSvc2024! | iis_svc: IISService2024! (patron corporativo)

if ($env:COMPUTERNAME -ne "DC-01") { Write-Warning "Ejecutar en DC-01"; exit 1 }
Import-Module ActiveDirectory

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  DC-01: Creacion de OUs, Usuarios y Grupos" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

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
        Write-Host "    [+] OU: $name" -ForegroundColor Green
    } else {
        Write-Host "    [i] OU ya existe: $name" -ForegroundColor Cyan
    }
}

$usuarios = @(
    @{ Name="Carlos Martinez"; Sam="ceo.martinez"; Pass="Direccion2024!"; OU="OU=Direccion,OU=Corporativo,DC=atackcorp,DC=local"; NoPreAuth=$true },
    @{ Name="Laura Lopez";     Sam="rrhh.lopez";   Pass="RRHH2024!";      OU="OU=RRHH,OU=Corporativo,DC=atackcorp,DC=local";      NoPreAuth=$false },
    @{ Name="Fernando Garcia"; Sam="fin.garcia";   Pass="Finance2024!";   OU="OU=Finanzas,OU=Corporativo,DC=atackcorp,DC=local";  NoPreAuth=$false },
    @{ Name="IT Admin";        Sam="it.admin";     Pass="ITAdmin2024!";   OU="OU=Administradores,OU=IT,DC=atackcorp,DC=local";    NoPreAuth=$false },
    @{ Name="Helpdesk Ruiz";   Sam="helpdesk.ruiz";Pass="Helpdesk2024!";  OU="OU=Helpdesk,OU=IT,DC=atackcorp,DC=local";          NoPreAuth=$false }
)
foreach ($u in $usuarios) {
    $pass = ConvertTo-SecureString $u.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $u.Name -SamAccountName $u.Sam `
            -UserPrincipalName "$($u.Sam)@atackcorp.local" `
            -Path $u.OU -AccountPassword $pass -Enabled $true
        Write-Host "    [+] Usuario: $($u.Sam)" -ForegroundColor Green
    }
    if ($u.NoPreAuth) {
        Set-ADAccountControl -Identity $u.Sam -DoesNotRequirePreAuth $true
        Write-Host "    [!] AS-REP Roasting: $($u.Sam)" -ForegroundColor Red
    }
}

$servicios = @(
    @{ Sam="sql_svc";    Pass="SQLSvc2024!";     SPN="MSSQLSvc/DC-01.atackcorp.local:1433"; NoPreAuth=$false },
    @{ Sam="iis_svc";    Pass="IISService2024!"; SPN="HTTP/DC-01.atackcorp.local";           NoPreAuth=$false },
    @{ Sam="backup_svc"; Pass="Backup2024!";     SPN=$null;                                  NoPreAuth=$true  }
)
foreach ($svc in $servicios) {
    $pass = ConvertTo-SecureString $svc.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($svc.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $svc.Sam -SamAccountName $svc.Sam `
            -UserPrincipalName "$($svc.Sam)@atackcorp.local" `
            -Path "OU=CuentasServicio,DC=atackcorp,DC=local" `
            -AccountPassword $pass -Enabled $true
        Write-Host "    [+] Servicio: $($svc.Sam)" -ForegroundColor Green
    }
    if ($svc.SPN) {
        Set-ADUser -Identity $svc.Sam -ServicePrincipalNames @{Add=$svc.SPN}
        Write-Host "    [!] Kerberoasting (SPN): $($svc.Sam)" -ForegroundColor Red
    }
    if ($svc.NoPreAuth) {
        Set-ADAccountControl -Identity $svc.Sam -DoesNotRequirePreAuth $true
        Write-Host "    [!] AS-REP Roasting: $($svc.Sam)" -ForegroundColor Red
    }
}

Add-ADGroupMember -Identity "Opers. de cuentas" -Members "it.admin" -ErrorAction SilentlyContinue
Write-Host "    [!] it.admin -> Account Operators" -ForegroundColor Red

$winrmUsers = @("ceo.martinez", "backup_svc", "helpdesk.ruiz", "sql_svc", "iis_svc")
foreach ($u in $winrmUsers) {
    Add-ADGroupMember -Identity "Usuarios de administracion remota" -Members $u -ErrorAction SilentlyContinue
}
Write-Host "    [+] WinRM configurado para cuentas clave" -ForegroundColor Green
Write-Host "[OK] Script 02 completado." -ForegroundColor Green
