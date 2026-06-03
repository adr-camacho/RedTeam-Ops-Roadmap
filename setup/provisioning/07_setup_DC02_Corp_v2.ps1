# 07_setup_DC02_Corp.ps1 -- DC-02 corp.local (Forest 2)
# Version: 1.1 | Actualizado: Junio 2026
# FIX v1.1: Añadido C:\Temp para transferencia de herramientas

Import-Module ActiveDirectory
Write-Host "[*] Configurando corp.local..." -ForegroundColor Cyan

# --- OUs ---
$OUs = @(
    "OU=Corporativo,DC=corp,DC=local",
    "OU=IT,DC=corp,DC=local",
    "OU=Usuarios,OU=Corporativo,DC=corp,DC=local",
    "OU=Administradores,OU=IT,DC=corp,DC=local",
    "OU=CuentasServicio,DC=corp,DC=local",
    "OU=Equipos,DC=corp,DC=local"
)
foreach ($ou in $OUs) {
    $name = ($ou -split ",")[0] -replace "OU=",""
    $path = ($ou -split ",",2)[1]
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ou'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $name -Path $path
        Write-Host "[+] OU creada: $name"
    }
}

# --- Usuarios ---
$usuarios = @(
    @{Name="John Smith";   Sam="john.smith";   Pass="JohnCorp2024!";  OU="OU=Usuarios,OU=Corporativo,DC=corp,DC=local"},
    @{Name="Sarah Connor"; Sam="sarah.connor"; Pass="SarahCorp2024!"; OU="OU=Usuarios,OU=Corporativo,DC=corp,DC=local"},
    @{Name="Corp Admin";   Sam="corp.admin";   Pass="CorpAdmin2024!"; OU="OU=Administradores,OU=IT,DC=corp,DC=local"},
    @{Name="Corp Service"; Sam="corp_svc";     Pass="CorpSvc2024!";   OU="OU=CuentasServicio,DC=corp,DC=local"}
)
foreach ($u in $usuarios) {
    $pass = ConvertTo-SecureString $u.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $u.Name -SamAccountName $u.Sam -UserPrincipalName "$($u.Sam)@corp.local" `
            -Path $u.OU -AccountPassword $pass -Enabled $true
        Write-Host "[+] Usuario: $($u.Sam)"
    }
}

# --- Domain Admins ---
Add-ADGroupMember -Identity "Admins. del dominio" -Members "corp.admin" -ErrorAction SilentlyContinue
Write-Host "[!] corp.admin -> Domain Admins"

# --- SPN corp_svc (Kerberoasteable cross-forest) ---
Set-ADUser -Identity "corp_svc" -ServicePrincipalNames @{Add="MSSQLSvc/DC-02.corp.local:1433"}
Write-Host "[!] SPN corp_svc -> Kerberoasting cross-forest habilitado"

# --- ACL: john.smith GenericAll sobre corp_svc (Lab-06 Fase 03 path) ---
$johnSID = (Get-ADUser "john.smith").SID
$corpSvc = Get-ADUser "corp_svc" -Properties DistinguishedName
$acl = Get-Acl "AD:\$($corpSvc.DistinguishedName)"
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $johnSID,
    [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,
    [System.Security.AccessControl.AccessControlType]::Allow
)
$acl.AddAccessRule($rule)
Set-Acl "AD:\$($corpSvc.DistinguishedName)" $acl
Write-Host "[!] john.smith GenericAll sobre corp_svc (Targeted Kerberoasting path)"

# --- Share Corp-Data ---
New-Item -Path "C:\Shares\Corp-Data" -ItemType Directory -Force | Out-Null
New-SmbShare -Name "Corp-Data" -Path "C:\Shares\Corp-Data" `
    -ReadAccess "*S-1-5-21-750084600-2533406826-1069631424-513" `
    -FullAccess "*S-1-5-21-750084600-2533406826-1069631424-512" `
    -ErrorAction SilentlyContinue
Write-Host "[+] Share Corp-Data creado"

# --- C:\Temp para transferencia de herramientas (FIX v1.1) ---
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
$acl = Get-Acl "C:\Temp"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("*S-1-1-0","FullControl","Allow")
$acl.SetAccessRule($rule)
Set-Acl "C:\Temp" $acl
Write-Host "[+] C:\Temp creado (FIX v1.1)"

# --- WinRM ---
Enable-PSRemoting -Force | Out-Null
Write-Host "[+] WinRM habilitado"

Write-Host ""
Write-Host "[OK] Setup corp.local completado (v1.1)" -ForegroundColor Green
