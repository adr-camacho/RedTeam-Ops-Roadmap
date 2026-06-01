# 08_Setup_DC03_Child.ps1 -- DC-03 child.atackcorp.local
# Autor: Adrián Camacho | Versión: 1.1 | Junio 2026
# Fixes v1.1:
#   - Añadido DNS primario apuntando a DC-01 (10.0.2.10) para ADWS cross-domain
#   - Añadido firewall rule ADWS (9389) para consultas cross-forest
#   - Añadido C:\Temp para transferencia de herramientas
#   - Añadida descarga de DSInternals v4.14 para SID History injection

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

# [FIX v1.1] DNS primario apuntando a DC-01 para ADWS cross-domain
# Sin esto Get-ADGroup -Server cross-domain falla en sesiones WinRM
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses ("10.0.2.10","10.0.2.13")
Write-Host "[+] DNS primario -> DC-01 (10.0.2.10) para ADWS cross-domain"

# [FIX v1.1] Firewall rule ADWS para consultas cross-forest
netsh advfirewall firewall add rule name="ADWS-Internal" protocol=TCP dir=in localport=9389 remoteip=10.0.2.0/24 action=allow | Out-Null
Write-Host "[+] Firewall ADWS (9389) abierto para subred 10.0.2.0/24"

# [FIX v1.1] C:\Temp para transferencia de herramientas
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
Write-Host "[+] C:\Temp creado"

Write-Host "[OK] Setup child.atackcorp.local completado."
