# =============================================================
# SCRIPT — Setup-DC02-Corp.ps1
# DC-02 — corp.local (Forest 2)
# Ejecutar como Administrador en DC-02
# =============================================================

Import-Module ActiveDirectory

Write-Host "`n[*] Configurando corp.local..." -ForegroundColor Cyan

# ── Estructura OUs ────────────────────────────────────────────
$OUs = @(
    "OU=Corporativo,DC=corp,DC=local",
    "OU=IT,DC=corp,DC=local",
    "OU=Usuarios,OU=Corporativo,DC=corp,DC=local",
    "OU=Administradores,OU=IT,DC=corp,DC=local",
    "OU=CuentasServicio,DC=corp,DC=local",
    "OU=Equipos,DC=corp,DC=local"
)

foreach ($ou in $OUs) {
    $name = ($ou -split ",")[0] -replace "OU=", ""
    $path = ($ou -split ",", 2)[1]
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ou'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $name -Path $path
        Write-Host "[+] OU creada: $name"
    }
}

# ── Usuarios corp.local ───────────────────────────────────────
$usuarios = @(
    @{ Name="John Smith";     Sam="john.smith";    Pass="JohnCorp2024!";  OU="OU=Usuarios,OU=Corporativo,DC=corp,DC=local" },
    @{ Name="Sarah Connor";   Sam="sarah.connor";  Pass="SarahCorp2024!"; OU="OU=Usuarios,OU=Corporativo,DC=corp,DC=local" },
    @{ Name="Corp Admin";     Sam="corp.admin";    Pass="CorpAdmin2024!"; OU="OU=Administradores,OU=IT,DC=corp,DC=local" },
    @{ Name="Corp Service";   Sam="corp_svc";      Pass="CorpSvc2024!";   OU="OU=CuentasServicio,DC=corp,DC=local" }
)

foreach ($u in $usuarios) {
    $pass = ConvertTo-SecureString $u.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name $u.Name `
            -SamAccountName $u.Sam `
            -UserPrincipalName "$($u.Sam)@corp.local" `
            -Path $u.OU `
            -AccountPassword $pass `
            -Enabled $true
        Write-Host "[+] Usuario creado: $($u.Sam)"
    }
}

# ── corp.admin → Domain Admins ────────────────────────────────
Add-ADGroupMember -Identity "Admins. del dominio" -Members "corp.admin" -ErrorAction SilentlyContinue
Write-Host "[!] corp.admin añadido a Domain Admins"

# ── SPN para corp_svc (Kerberoasting) ────────────────────────
Set-ADUser -Identity "corp_svc" -ServicePrincipalNames @{Add="MSSQLSvc/DC-02.corp.local:1433"}
Write-Host "[!] SPN añadido a corp_svc → Kerberoasting habilitado"

# ── GenericAll: john.smith sobre corp_svc ────────────────────
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
Write-Host "[!] ACL: john.smith tiene GenericAll sobre corp_svc"

# ── Shares ────────────────────────────────────────────────────
New-Item -Path "C:\Shares\Corp-Data" -ItemType Directory -Force | Out-Null
New-SmbShare -Name "Corp-Data" -Path "C:\Shares\Corp-Data" `
    -ReadAccess "CORP\Usuarios del dominio" -FullAccess "CORP\Admins. del dominio" `
    -ErrorAction SilentlyContinue
Write-Host "[+] Share Corp-Data creado"

# ── WinRM habilitado ─────────────────────────────────────────
Enable-PSRemoting -Force | Out-Null
Write-Host "[+] WinRM habilitado"

Write-Host "`n[✓] Setup corp.local completado." -ForegroundColor Green
