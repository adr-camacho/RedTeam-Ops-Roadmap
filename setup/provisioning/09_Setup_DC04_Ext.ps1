# 09_Setup_DC04_Ext.ps1 -- DC-04 ext.local (Forest 3)
Import-Module ActiveDirectory
Write-Host "[*] Configurando ext.local..."

$OUs = @(
    "OU=Corporativo,DC=ext,DC=local",
    "OU=IT,DC=ext,DC=local",
    "OU=Usuarios,OU=Corporativo,DC=ext,DC=local",
    "OU=Administradores,OU=IT,DC=ext,DC=local",
    "OU=CuentasServicio,DC=ext,DC=local"
)
foreach ($ou in $OUs) {
    $name = ($ou -split ",")[0] -replace "OU=",""
    $path = ($ou -split ",",2)[1]
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ou'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $name -Path $path
        Write-Host "[+] OU creada: $name"
    }
}

$usuarios = @(
    @{Name="Ext User";    Sam="ext.user";   Pass="ExtUser2024!";  OU="OU=Usuarios,OU=Corporativo,DC=ext,DC=local"},
    @{Name="Ext Admin";   Sam="ext.admin";  Pass="ExtAdmin2024!"; OU="OU=Administradores,OU=IT,DC=ext,DC=local"},
    @{Name="Ext Service"; Sam="ext_svc";    Pass="ExtSvc2024!";   OU="OU=CuentasServicio,DC=ext,DC=local"}
)
foreach ($u in $usuarios) {
    $pass = ConvertTo-SecureString $u.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $u.Name -SamAccountName $u.Sam -UserPrincipalName "$($u.Sam)@ext.local" `
            -Path $u.OU -AccountPassword $pass -Enabled $true
        Write-Host "[+] Usuario: $($u.Sam)"
    }
}

Add-ADGroupMember -Identity "Admins. del dominio" -Members "ext.admin" -ErrorAction SilentlyContinue
Write-Host "[!] ext.admin -> Domain Admins"

Set-ADUser -Identity "ext_svc" -ServicePrincipalNames @{Add="MSSQLSvc/DC-04.ext.local:1433"}
Write-Host "[!] SPN ext_svc -> Kerberoasting cross-forest habilitado"

New-ADGroup -Name "Ext-Readers" -GroupScope Global -Path "OU=Corporativo,DC=ext,DC=local" -ErrorAction SilentlyContinue
Add-ADGroupMember -Identity "Ext-Readers" -Members "ext.user" -ErrorAction SilentlyContinue
Write-Host "[+] Grupo Ext-Readers creado"

New-Item -Path "C:\Shares\Ext-Data" -ItemType Directory -Force | Out-Null
$doc = "=== EXT CORP CREDENTIALS ===`next.admin / ExtAdmin2024!`nSQL: ext_svc / ExtSvc2024!`n=== CONFIDENTIAL ==="
Set-Content "C:\Shares\Ext-Data\credentials_backup.txt" $doc
New-SmbShare -Name "Ext-Data" -Path "C:\Shares\Ext-Data" -ReadAccess "Everyone" -ErrorAction SilentlyContinue
Write-Host "[!] Share Ext-Data con credenciales expuestas creado"

Enable-PSRemoting -Force | Out-Null
Write-Host "[+] WinRM habilitado"
Write-Host "[OK] Setup ext.local completado."
