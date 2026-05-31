# 08_Setup_DC03_Child.ps1 -- DC-03 child.atackcorp.local
Import-Module ActiveDirectory
Write-Host "[*] Configurando child.atackcorp.local..."

$OUs = @(
    "OU=Corporativo,DC=child,DC=atackcorp,DC=local",
    "OU=IT,DC=child,DC=atackcorp,DC=local",
    "OU=Usuarios,OU=Corporativo,DC=child,DC=atackcorp,DC=local",
    "OU=Administradores,OU=IT,DC=child,DC=atackcorp,DC=local",
    "OU=CuentasServicio,DC=child,DC=atackcorp,DC=local",
    "OU=Equipos,DC=child,DC=atackcorp,DC=local"
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
    @{Name="Child User";    Sam="child.user";   Pass="ChildUser2024!";  OU="OU=Usuarios,OU=Corporativo,DC=child,DC=atackcorp,DC=local"},
    @{Name="Child Admin";   Sam="child.admin";  Pass="ChildAdmin2024!"; OU="OU=Administradores,OU=IT,DC=child,DC=atackcorp,DC=local"},
    @{Name="Child Service"; Sam="child_svc";    Pass="ChildSvc2024!";   OU="OU=CuentasServicio,DC=child,DC=atackcorp,DC=local"}
)
foreach ($u in $usuarios) {
    $pass = ConvertTo-SecureString $u.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $u.Name -SamAccountName $u.Sam -UserPrincipalName "$($u.Sam)@child.atackcorp.local" `
            -Path $u.OU -AccountPassword $pass -Enabled $true
        Write-Host "[+] Usuario: $($u.Sam)"
    }
}

Add-ADGroupMember -Identity "Admins. del dominio" -Members "child.admin" -ErrorAction SilentlyContinue
Write-Host "[!] child.admin -> Domain Admins"

Set-ADUser -Identity "child_svc" -ServicePrincipalNames @{Add="HTTP/DC-03.child.atackcorp.local"}
Write-Host "[!] SPN child_svc -> Kerberoasting habilitado"

Enable-PSRemoting -Force | Out-Null
Write-Host "[+] WinRM habilitado"

netdom trust child.atackcorp.local /domain:atackcorp.local /quarantine:No /userO:child.admin /passwordO:ChildAdmin2024!
Write-Host "[!] SID Filtering deshabilitado hacia atackcorp.local"

Write-Host "[OK] Setup child.atackcorp.local completado."
