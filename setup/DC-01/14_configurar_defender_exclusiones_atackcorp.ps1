# 14_setup_Defender.ps1 -- Configuracion de Windows Defender para entorno de lab
# Version: 1.0 | Junio 2026
# Prerequisito: DC-01 promovido como DC
#
# OBJETIVO: Dejar Defender activo pero con exclusiones controladas
# que permiten ejecutar herramientas de lab sin deshabilitarlo completamente
#
# FILOSOFIA: En Labs 01-06 deshabilitamos Defender con Set-MpPreference -DisableRealtimeMonitoring
#            En Labs 08-11 (Lazarus) trabajaremos con Defender ACTIVO -- evasion real
#            Este script prepara el terreno para ese escenario

Write-Host "=============================================" -ForegroundColor DarkYellow
Write-Host "    Windows Defender Lab Config -- DC-01     " -ForegroundColor DarkYellow
Write-Host "=============================================" -ForegroundColor DarkYellow

# BLOQUE 1 -- Verificar estado actual de Defender
Write-Host "[*] Estado actual de Defender..." -ForegroundColor Yellow
$defStatus = Get-MpComputerStatus
Write-Host "    AntivirusEnabled: $($defStatus.AntivirusEnabled)" -ForegroundColor Cyan
Write-Host "    RealTimeProtectionEnabled: $($defStatus.RealTimeProtectionEnabled)" -ForegroundColor Cyan
Write-Host "    AMEngineVersion: $($defStatus.AMEngineVersion)" -ForegroundColor Cyan

# BLOQUE 2 -- Exclusiones de carpetas para herramientas de lab
# Permite ejecutar SharpHound, Rubeus, etc desde estas rutas sin bloqueo
Write-Host "[*] Configurando exclusiones de carpetas..." -ForegroundColor Yellow
$exclusionPaths = @(
    "C:\Temp",
    "C:\Tools",
    "C:\Users\helpdesk.ruiz\Documents",
    "C:\Users\fin.garcia\Documents",
    "C:\CorporateData"
)
foreach ($path in $exclusionPaths) {
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Add-MpPreference -ExclusionPath $path
    Write-Host "    [+] Exclusion anadida: $path" -ForegroundColor Green
}

# BLOQUE 3 -- Exclusiones de procesos
Write-Host "[*] Configurando exclusiones de procesos..." -ForegroundColor Yellow
$exclusionProcesses = @(
    "powershell.exe",
    "pwsh.exe",
    "cmd.exe",
    "msiexec.exe"
)
foreach ($proc in $exclusionProcesses) {
    Add-MpPreference -ExclusionProcess $proc
    Write-Host "    [+] Proceso excluido: $proc" -ForegroundColor Green
}

# BLOQUE 4 -- Configuracion de alertas (reducir ruido en lab)
Write-Host "[*] Configurando nivel de alertas..." -ForegroundColor Yellow
Set-MpPreference -MAPSReporting Disabled
Set-MpPreference -SubmitSamplesConsent NeverSend
Set-MpPreference -DisableBlockAtFirstSeen $true
Write-Host "    [+] MAPS deshabilitado (sin telemetria a Microsoft)" -ForegroundColor Green
Write-Host "    [+] Envio de muestras deshabilitado" -ForegroundColor Green

# BLOQUE 5 -- Mantener Defender ACTIVO para Labs 08-11
Write-Host "[*] Verificando que Defender sigue activo..." -ForegroundColor Yellow
Set-MpPreference -DisableRealtimeMonitoring $false
$status = Get-MpComputerStatus
Write-Host "    RealTimeProtection: $($status.RealTimeProtectionEnabled)" -ForegroundColor Cyan
if ($status.RealTimeProtectionEnabled) {
    Write-Host "    [+] Defender ACTIVO con exclusiones controladas" -ForegroundColor Green
} else {
    Write-Host "    [!] Defender inactivo -- revisar configuracion" -ForegroundColor Red
}

# BLOQUE 6 -- GPO para propagar configuracion a WKSTN-01
Write-Host "[*] Creando GPO para Defender en workstations..." -ForegroundColor Yellow
try {
    Get-GPO -Name "Defender-Lab-Config" -ErrorAction SilentlyContinue | Remove-GPO -Confirm:$false

    New-GPO -Name "Defender-Lab-Config" | `
        New-GPLink -Target "OU=Equipos,DC=atackcorp,DC=local" | Out-Null

    # Exclusion C:\Temp en workstations via GPO
    Set-GPRegistryValue -Name "Defender-Lab-Config" `
        -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" `
        -ValueName "C:\Temp" -Type String -Value 0 | Out-Null

    Set-GPRegistryValue -Name "Defender-Lab-Config" `
        -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" `
        -ValueName "C:\Tools" -Type String -Value 0 | Out-Null

    Write-Host "    [+] GPO Defender-Lab-Config creada" -ForegroundColor Green
} catch {
    Write-Host "    [*] GPO no creada (puede requerir OU=Equipos): $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor DarkYellow
Write-Host " Defender Lab Config completada" -ForegroundColor DarkYellow
Write-Host "=============================================" -ForegroundColor DarkYellow
Write-Host "  Defender: ACTIVO" -ForegroundColor Green
Write-Host "  Exclusiones: C:\Temp, C:\Tools, C:\CorporateData" -ForegroundColor Cyan
Write-Host "  MAPS/Telemetria: DESHABILITADA" -ForegroundColor Cyan
Write-Host "  Labs 01-06: usar Set-MpPreference -DisableRealtimeMonitoring para binarios conocidos" -ForegroundColor Yellow
Write-Host "  Labs 08-11: Defender activo -- practicar evasion real" -ForegroundColor Yellow
