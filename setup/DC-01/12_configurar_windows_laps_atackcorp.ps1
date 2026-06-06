# 12_configurar_windows_laps_atackcorp.ps1
# Maquina: DC-01 (atackcorp.local — Windows Server 2025)
# Prerequisito: Script 02 ejecutado (helpdesk.ruiz creado)
#               WKSTN-01 unida al dominio y en OU=IT
# Version: 1.1 | Junio 2026
#
# FIX v1.1 (Lab-07):
#   - ADPasswordEncryptionEnabled=0 en GPO LAPS-Policy
#     WS2025 usa cifrado GKDI por defecto — herramientas Linux no descifran GKDI
#   - AllowedPrincipals usa nombre completo ATACKCORP\helpdesk.ruiz
#   - Añadida verificacion de que WKSTN-01 tiene la GPO aplicada
#   - Instruccion gpupdate /force en WKSTN-01 tras ejecutar

if ($env:COMPUTERNAME -ne "DC-01") { Write-Warning "Ejecutar en DC-01"; exit 1 }
Import-Module ActiveDirectory

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  DC-01: Windows LAPS nativo (v1.1)" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

# --- Extender schema AD para Windows LAPS ---
Write-Host "[*] Extendiendo schema AD para Windows LAPS..." -ForegroundColor Yellow
try {
    Update-LapsADSchema -Confirm:$false
    Write-Host "[+] Schema LAPS extendido (msLAPS-Password, msLAPS-EncryptedPassword)" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*already*" -or $_.Exception.Message -like "*ya*") {
        Write-Host "[i] Schema LAPS ya extendido" -ForegroundColor Cyan
    } else {
        Write-Host "[!] Error schema: $_" -ForegroundColor Red
    }
}

# --- Configurar permisos en OU=IT ---
Write-Host "[*] Configurando permisos LAPS en OU=IT..." -ForegroundColor Yellow
try {
    # Habilitar WKSTN-01 para reportar password LAPS al DC
    Set-LapsADComputerSelfPermission -Identity "OU=IT,DC=atackcorp,DC=local"
    Write-Host "[+] Self-permission configurada en OU=IT" -ForegroundColor Green
} catch { Write-Host "[!] Error self-permission: $_" -ForegroundColor Red }

try {
    # helpdesk.ruiz puede leer msLAPS-Password (misconfiguration intencional para el lab)
    Set-LapsADReadPasswordPermission -Identity "OU=IT,DC=atackcorp,DC=local" `
        -AllowedPrincipals "ATACKCORP\helpdesk.ruiz"
    Write-Host "[!] helpdesk.ruiz puede leer msLAPS-Password de WKSTN-01 (misconfiguration lab)" -ForegroundColor Red
} catch { Write-Host "[!] Error read-permission: $_" -ForegroundColor Red }

# --- Crear y configurar GPO LAPS-Policy ---
Write-Host "[*] Configurando GPO LAPS-Policy..." -ForegroundColor Yellow
$gpoName = "LAPS-Policy"
$gpo = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
if (-not $gpo) {
    $gpo = New-GPO -Name $gpoName
    Write-Host "[+] GPO LAPS-Policy creada" -ForegroundColor Green
} else {
    Write-Host "[i] GPO LAPS-Policy ya existe" -ForegroundColor Cyan
}

# Vincular GPO a OU=IT
try {
    New-GPLink -Name $gpoName -Target "OU=IT,DC=atackcorp,DC=local" -ErrorAction Stop | Out-Null
    Write-Host "[+] GPO vinculada a OU=IT" -ForegroundColor Green
} catch {
    Write-Host "[i] GPO ya vinculada a OU=IT" -ForegroundColor Cyan
}

# Configurar settings LAPS en GPO
$lapsKey = "HKLM\Software\Microsoft\Windows\CurrentVersion\LAPS\Config"

# Backup directory: Active Directory (2)
Set-GPRegistryValue -Name $gpoName -Key $lapsKey -ValueName "BackupDirectory" -Type DWord -Value 2

# Password age: 30 dias
Set-GPRegistryValue -Name $gpoName -Key $lapsKey -ValueName "PasswordAgeDays" -Type DWord -Value 30

# Password length: 14 caracteres
Set-GPRegistryValue -Name $gpoName -Key $lapsKey -ValueName "PasswordLength" -Type DWord -Value 14

# Cuenta administrador: Administrador
Set-GPRegistryValue -Name $gpoName -Key $lapsKey -ValueName "AdministratorAccountName" -Type String -Value "Administrador"

# FIX v1.1: Deshabilitar cifrado GKDI para compatibilidad con herramientas Linux
# WS2025 usa GKDI por defecto — nxc, ldeep, pyLAPS no descifran GKDI desde Linux
# En produccion: mantener ADPasswordEncryptionEnabled=1 (mas seguro)
Set-GPRegistryValue -Name $gpoName -Key $lapsKey -ValueName "ADPasswordEncryptionEnabled" -Type DWord -Value 0
Write-Host "[!] ADPasswordEncryptionEnabled=0 (sin cifrado GKDI — solo para lab)" -ForegroundColor Red

Write-Host "[+] GPO LAPS-Policy configurada" -ForegroundColor Green

# --- Verificar configuracion ---
Write-Host "[*] Verificacion de configuracion LAPS..." -ForegroundColor Yellow
Get-GPO -Name $gpoName | Select-Object DisplayName, GpoStatus, ModificationTime | Format-Table

# --- Instrucciones post-ejecucion ---
Write-Host ""
Write-Host "================================================" -ForegroundColor DarkGreen
Write-Host "  Script 12 completado (v1.1)" -ForegroundColor DarkGreen
Write-Host "================================================" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "SIGUIENTE PASO — Ejecutar en WKSTN-01:" -ForegroundColor Yellow
Write-Host "  gpupdate /force" -ForegroundColor Cyan
Write-Host "  Invoke-LapsPolicyProcessing  (como Administrador)" -ForegroundColor Cyan
Write-Host ""
Write-Host "VERIFICAR desde DC-01 tras gpupdate en WKSTN-01:" -ForegroundColor Yellow
Write-Host "  Get-LapsADPassword -Identity WKSTN-01 -AsPlainText" -ForegroundColor Cyan
Write-Host ""
Write-Host "VERIFICAR desde helpdesk.ruiz:" -ForegroundColor Yellow
Write-Host "  nxc ldap 10.0.2.10 -u helpdesk.ruiz -p 'Helpdesk2024!' -M laps" -ForegroundColor Cyan
