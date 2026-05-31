# =============================================================
# SCRIPT — Setup-Trusts-And-SIDHistory.ps1
# DC-01 — atackcorp.local
# Configura SID History y vulnerabilidades cross-forest
# Ejecutar como Administrador en DC-01
# =============================================================

Import-Module ActiveDirectory

Write-Host "`n[*] Configurando SID History y vulnerabilidades cross-forest..." -ForegroundColor Cyan

# ── Deshabilitar SID Filtering en trust con corp.local ───────
# Necesario para que SID History funcione cross-forest
netdom trust atackcorp.local /domain:corp.local /quarantine:No `
    /userO:Administrador /passwordO:NuevaPassword2026!
Write-Host "[!] SID Filtering deshabilitado en trust atackcorp ↔ corp.local"

# ── Deshabilitar SID Filtering en trust con ext.local ────────
netdom trust atackcorp.local /domain:ext.local /quarantine:No `
    /userO:Administrador /passwordO:NuevaPassword2026!
Write-Host "[!] SID Filtering deshabilitado en trust atackcorp ↔ ext.local"

# ── Añadir SID History a usuario migrado ─────────────────────
# Simulamos usuario migrado de corp.local con SID History de DA atackcorp
# En entorno real usar ADMT (Active Directory Migration Tool)
# Vector Lab-06: si john.smith@corp.local tiene SID History S-1-5-21-768292631-183641691-1245477636-512
#                puede actuar como DA en atackcorp.local

Write-Host "[!] SID History path listo para Lab-06"
Write-Host "    Vector: usuario corp.local con SID History de DA atackcorp"
Write-Host "    Herramienta: mimikatz 'misc::addsid' o ADMT"

# ── Verificar trusts ─────────────────────────────────────────
Write-Host "`n[*] Trusts configurados:" -ForegroundColor Cyan
Get-ADTrust -Filter * | Select-Object Name, Direction, TrustType | Format-Table

# ── Crear usuario en atackcorp con acceso a corp.local ───────
# Foreign Security Principal para acceso cross-forest
$pass = ConvertTo-SecureString "CrossUser2024!" -AsPlainText -Force
if (-not (Get-ADUser -Filter "SamAccountName -eq 'cross.user'" -ErrorAction SilentlyContinue)) {
    New-ADUser `
        -Name "Cross User" `
        -SamAccountName "cross.user" `
        -UserPrincipalName "cross.user@atackcorp.local" `
        -Path "OU=IT,DC=atackcorp,DC=local" `
        -AccountPassword $pass `
        -Enabled $true
    Write-Host "[+] cross.user creado en atackcorp.local"
}

Write-Host "`n[✓] Setup Trusts y SID History completado." -ForegroundColor Green
Write-Host "`n[i] Para Lab-06 SID History injection usar:" -ForegroundColor Yellow
Write-Host "    mimikatz# misc::addsid /user:john.smith /sid:S-1-5-21-768292631-183641691-1245477636-512"
