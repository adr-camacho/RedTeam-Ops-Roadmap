# 01_configurar_dominio_ext_local.ps1
# Maquina: DC-04 | Version: 2.0 | Junio 2026
# FIX v2.0: SID *S-1-1-0 en lugar de "Everyone" (falla en espanol)
#            -Server DC-04.ext.local en cmdlets AD

if ($env:COMPUTERNAME -ne "DC-04") { Write-Warning "Ejecutar en DC-04"; exit 1 }
Import-Module ActiveDirectory
$server = "DC-04.ext.local"

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  DC-04: Configuracion ext.local (Forest 3)" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

$OUs = @("OU=Corporativo,DC=ext,DC=local","OU=IT,DC=ext,DC=local","OU=Usuarios,OU=Corporativo,DC=ext,DC=local","OU=Administradores,OU=IT,DC=ext,DC=local","OU=CuentasServicio,DC=ext,DC=local")
foreach ($ou in $OUs) {
    $name = ($ou -split ",")[0] -replace "OU=",""
    $path = ($ou -split ",",2)[1]
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ou'" -Server $server -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $name -Path $path -Server $server
        Write-Host "    [+] OU: $name" -ForegroundColor Green
    }
}

$usuarios = @(
    @{Name="Ext User";    Sam="ext.user";   Pass="ExtUser2024!";  OU="OU=Usuarios,OU=Corporativo,DC=ext,DC=local"},
    @{Name="Ext Admin";   Sam="ext.admin";  Pass="ExtAdmin2024!"; OU="OU=Administradores,OU=IT,DC=ext,DC=local"},
    @{Name="Ext Service"; Sam="ext_svc";    Pass="ExtSvc2024!";   OU="OU=CuentasServicio,DC=ext,DC=local"}
)
foreach ($u in $usuarios) {
    $pass = ConvertTo-SecureString $u.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -Server $server -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $u.Name -SamAccountName $u.Sam -UserPrincipalName "$($u.Sam)@ext.local" -Path $u.OU -AccountPassword $pass -Enabled $true -Server $server
        Write-Host "    [+] Usuario: $($u.Sam)" -ForegroundColor Green
    }
}

Add-ADGroupMember -Identity "Admins. del dominio" -Members "ext.admin" -Server $server -ErrorAction SilentlyContinue
Set-ADUser -Identity "ext_svc" -ServicePrincipalNames @{Add="MSSQLSvc/DC-04.ext.local:1433"} -Server $server
Write-Host "    [!] ext.admin -> DA | SPN ext_svc" -ForegroundColor Red

New-Item -Path "C:\Shares\Ext-Data" -ItemType Directory -Force | Out-Null
@"
=== EXT CORP CREDENTIALS ===
ext.admin / ExtAdmin2024!
SQL: ext_svc / ExtSvc2024!
=== CONFIDENTIAL ===
"@ | Set-Content "C:\Shares\Ext-Data\credentials_backup.txt" -Encoding UTF8
New-SmbShare -Name "Ext-Data" -Path "C:\Shares\Ext-Data" -ReadAccess "*S-1-1-0" -ErrorAction SilentlyContinue | Out-Null
Write-Host "    [!] Share Ext-Data con credenciales expuestas (Crown Jewel Lab-06)" -ForegroundColor Red

New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
Enable-PSRemoting -Force | Out-Null
Write-Host "[OK] DC-04 configurado (v2.0)" -ForegroundColor Green
