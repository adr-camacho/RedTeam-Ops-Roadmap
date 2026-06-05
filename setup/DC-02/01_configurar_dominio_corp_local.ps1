# 01_configurar_dominio_corp_local.ps1
# Maquina: DC-02 | Version: 2.0 | Junio 2026
# FIX v2.0: -Server DC-02.corp.local en cmdlets AD | SID dinamico en shares

if ($env:COMPUTERNAME -ne "DC-02") { Write-Warning "Ejecutar en DC-02"; exit 1 }
Import-Module ActiveDirectory
$server = "DC-02.corp.local"

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  DC-02: Configuracion corp.local (Forest 2)" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

$OUs = @("OU=Corporativo,DC=corp,DC=local","OU=IT,DC=corp,DC=local","OU=Usuarios,OU=Corporativo,DC=corp,DC=local","OU=Administradores,OU=IT,DC=corp,DC=local","OU=CuentasServicio,DC=corp,DC=local","OU=Equipos,DC=corp,DC=local")
foreach ($ou in $OUs) {
    $name = ($ou -split ",")[0] -replace "OU=",""
    $path = ($ou -split ",",2)[1]
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ou'" -Server $server -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $name -Path $path -Server $server
        Write-Host "    [+] OU: $name" -ForegroundColor Green
    }
}

$usuarios = @(
    @{Name="John Smith";   Sam="john.smith";   Pass="JohnCorp2024!";  OU="OU=Usuarios,OU=Corporativo,DC=corp,DC=local"},
    @{Name="Sarah Connor"; Sam="sarah.connor"; Pass="SarahCorp2024!"; OU="OU=Usuarios,OU=Corporativo,DC=corp,DC=local"},
    @{Name="Corp Admin";   Sam="corp.admin";   Pass="CorpAdmin2024!"; OU="OU=Administradores,OU=IT,DC=corp,DC=local"},
    @{Name="Corp Service"; Sam="corp_svc";     Pass="CorpSvc2024!";   OU="OU=CuentasServicio,DC=corp,DC=local"}
)
foreach ($u in $usuarios) {
    $pass = ConvertTo-SecureString $u.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -Server $server -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $u.Name -SamAccountName $u.Sam -UserPrincipalName "$($u.Sam)@corp.local" -Path $u.OU -AccountPassword $pass -Enabled $true -Server $server
        Write-Host "    [+] Usuario: $($u.Sam)" -ForegroundColor Green
    }
}

Add-ADGroupMember -Identity "Admins. del dominio" -Members "corp.admin" -Server $server -ErrorAction SilentlyContinue
Set-ADUser -Identity "corp_svc" -ServicePrincipalNames @{Add="MSSQLSvc/DC-02.corp.local:1433"} -Server $server
Write-Host "    [!] corp.admin -> DA | SPN corp_svc" -ForegroundColor Red

try {
    $johnSID = (Get-ADUser "john.smith" -Server $server).SID
    $corpSvc = Get-ADUser "corp_svc" -Server $server -Properties DistinguishedName
    $acl = Get-Acl "AD:\$($corpSvc.DistinguishedName)"
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($johnSID,[System.DirectoryServices.ActiveDirectoryRights]::GenericAll,[System.Security.AccessControl.AccessControlType]::Allow)
    $acl.AddAccessRule($rule); Set-Acl "AD:\$($corpSvc.DistinguishedName)" $acl
    Write-Host "    [!] john.smith GenericAll sobre corp_svc" -ForegroundColor Red
} catch { Write-Host "    [!] Error ACL: $_" -ForegroundColor Red }

New-Item -Path "C:\Shares\Corp-Data" -ItemType Directory -Force | Out-Null
$domSID = (Get-ADDomain -Server $server).DomainSID.Value
New-SmbShare -Name "Corp-Data" -Path "C:\Shares\Corp-Data" -ReadAccess "*$domSID-513" -FullAccess "*$domSID-512" -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
Enable-PSRemoting -Force | Out-Null
Write-Host "[OK] DC-02 configurado (v2.0)" -ForegroundColor Green
