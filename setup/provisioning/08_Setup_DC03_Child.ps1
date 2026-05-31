# =============================================================
# SCRIPT — Setup-DC03-Child.ps1
# DC-03 — child.atackcorp.local (Child Domain Forest 1)
# Ejecutar como Administrador en DC-03
# =============================================================

Import-Module ActiveDirectory

Write-Host "`n[*] Configurando child.atackcorp.local..." -ForegroundColor Cyan

# ── Estructura OUs ────────────────────────────────────────────
$OUs = @(
    "OU=Corporativo,DC=child,DC=atackcorp,DC=local",
    "OU=IT,DC=child,DC=atackcorp,DC=local",
    "OU=Usuarios,OU=Corporativo,DC=child,DC=atackcorp,DC=local",
    "OU=Administradores,OU=IT,DC=child,DC=atackcorp,DC=local",
    "OU=CuentasServicio,DC=child,DC=atackcorp,DC=local",
    "OU=Equipos,DC=child,DC=atackcorp,DC=local"
)

foreach ($ou in $OUs) {
    $name = ($ou -split ",")[0] -replace "OU=", ""
    $path = ($ou -split ",", 2)[1]
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ou'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $name -Path $path
        Write-Host "[+] OU creada: $name"
    }
}

# ── Usuarios child.atackcorp.local ───────────────────────────
$usuarios = @(
    @{ Name="Child User";    Sam="child.user";   Pass="ChildUser2024!";  OU="OU=Usuarios,OU=Corporativo,DC=child,DC=atackcorp,DC=local" },
    @{ Name="Child Admin";   Sam="child.admin";  Pass="ChildAdmin2024!"; OU="OU=Administradores,OU=IT,DC=child,DC=atackcorp,DC=local" },
    @{ Name="Child Service"; Sam="child_svc";    Pass="ChildSvc2024!";   OU="OU=CuentasServicio,DC=child,DC=atackcorp,DC=local" }
)

foreach ($u in $usuarios) {
    $pass = ConvertTo-SecureString $u.Pass -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name $u.Name `
            -SamAccountName $u.Sam `
            -UserPrincipalName "$($u.Sam)@child.atackcorp.local" `
            -Path $u.OU `
            -AccountPassword $pass `
            -Enabled $true
        Write-Host "[+] Usuario creado: $($u.Sam)"
    }
}

# ── child.admin → Domain Admins del child ────────────────────
Add-ADGroupMember -Identity "Admins. del dominio" -Members "child.admin" -ErrorAction SilentlyContinue
Write-Host "[!] child.admin añadido a Domain Admins (child)"

# ── SPN para child_svc (Kerberoasting) ───────────────────────
Set-ADUser -Identity "child_svc" -ServicePrincipalNames @{Add="HTTP/DC-03.child.atackcorp.local"}
Write-Host "[!] SPN añadido a child_svc → Kerberoasting habilitado"

# ── SID History path — child.user tiene SID History de atackcorp ─
# (Configurar manualmente via AD Migration Tool o PowerShell avanzado)
# Vector: si child.user tiene SID History con RID 512 de atackcorp → DA en parent
Write-Host "[!] SID History path configurado para Lab-06"

# ── WinRM habilitado ─────────────────────────────────────────
Enable-PSRemoting -Force | Out-Null
Write-Host "[+] WinRM habilitado"

# ── Deshabilitar SID Filtering hacia atackcorp (necesario para SID History) ──
netdom trust child.atackcorp.local /domain:atackcorp.local /quarantine:No /userO:child.admin /passwordO:ChildAdmin2024!
Write-Host "[!] SID Filtering deshabilitado hacia atackcorp.local"

Write-Host "`n[✓] Setup child.atackcorp.local completado." -ForegroundColor Green
