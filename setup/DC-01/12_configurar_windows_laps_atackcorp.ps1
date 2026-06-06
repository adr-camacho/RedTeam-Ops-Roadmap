# 12_setup_LAPS.ps1 -- Windows LAPS nativo (Windows Server 2025)
# Version: 1.0 | Junio 2026
# Prerequisito: DC-01 promovido como DC, AD operativo
# Prerequisito: Ejecutar DESPUES de 02_users_ous.ps1
#
# NOTA: Este script usa Windows LAPS nativo (WS2025+)
#       NO requiere instalacion de MSI legacy
#       Atributo: msLAPS-Password (no ms-Mcs-AdmPwd)
#
# MISCONFIGURATION INTENCIONAL para Lab-07:
#   helpdesk.ruiz tiene permisos de lectura sobre msLAPS-Password de WKSTN-01
#   Esto permite el ataque LAPS Password Disclosure

Import-Module ActiveDirectory
Write-Host "=============================================" -ForegroundColor DarkCyan
Write-Host "    Windows LAPS Setup -- DC-01 (WS2025)    " -ForegroundColor DarkCyan
Write-Host "=============================================" -ForegroundColor DarkCyan

# BLOQUE 1 -- Extender schema AD para Windows LAPS
Write-Host "[*] Extendiendo schema AD para Windows LAPS..." -ForegroundColor Yellow
try {
    Update-LapsADSchema -Confirm:$false
    Write-Host "    [+] Schema LAPS extendido correctamente" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error al extender schema: $_" -ForegroundColor Red
    Write-Host "    [i] Verifica que eres Schema Admin" -ForegroundColor Yellow
    exit 1
}

# BLOQUE 2 -- Permisos para que WKSTN-01 escriba su propia password
Write-Host "[*] Configurando permisos LAPS en OU IT..." -ForegroundColor Yellow
try {
    Set-LapsADComputerSelfPermission -Identity "OU=IT,OU=Corporativo,DC=atackcorp,DC=local"
    Write-Host "    [+] WKSTN-01 puede escribir su propia LAPS password" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error permisos SelfPermission: $_" -ForegroundColor Red
}

# BLOQUE 3 -- MISCONFIGURATION: helpdesk.ruiz puede leer LAPS passwords
# Esta es la vulnerabilidad intencional que se explotara en Lab-07
Write-Host "[*] Configurando misconfiguration LAPS (Lab-07)..." -ForegroundColor Yellow
try {
    Set-LapsADReadPasswordPermission -Identity "OU=IT,OU=Corporativo,DC=atackcorp,DC=local" `
        -AllowedPrincipals "helpdesk.ruiz"
    Write-Host "    [!] MISCONFIGURATION: helpdesk.ruiz puede leer msLAPS-Password de WKSTN-01" -ForegroundColor Red
    Write-Host "    [i] Este es el vector de ataque de Lab-07 Fase 01" -ForegroundColor Cyan
} catch {
    Write-Host "    [!] Error permisos ReadPassword: $_" -ForegroundColor Red
}

# BLOQUE 4 -- GPO para activar Windows LAPS en WKSTN-01
Write-Host "[*] Creando GPO Windows LAPS..." -ForegroundColor Yellow
try {
    # Eliminar GPO anterior si existe
    Get-GPO -Name "LAPS-Policy" -ErrorAction SilentlyContinue | Remove-GPO -Confirm:$false

    New-GPO -Name "LAPS-Policy" | New-GPLink -Target "OU=IT,OU=Corporativo,DC=atackcorp,DC=local" | Out-Null

    # Configurar politica LAPS via registry CSE
    Set-GPRegistryValue -Name "LAPS-Policy" `
        -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\LAPS\Config" `
        -ValueName "BackupDirectory" -Type DWord -Value 2 | Out-Null

    Set-GPRegistryValue -Name "LAPS-Policy" `
        -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\LAPS\Config" `
        -ValueName "PasswordAgeDays" -Type DWord -Value 30 | Out-Null

    Set-GPRegistryValue -Name "LAPS-Policy" `
        -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\LAPS\Config" `
        -ValueName "PasswordLength" -Type DWord -Value 14 | Out-Null

    Set-GPRegistryValue -Name "LAPS-Policy" `
        -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\LAPS\Config" `
        -ValueName "AdministratorAccountName" -Type String -Value "Administrador" | Out-Null

    Set-GPRegistryValue -Name "LAPS-Policy" `
        -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\LAPS\Config" `
        -ValueName "PasswordComplexity" -Type DWord -Value 4 | Out-Null

    Write-Host "    [+] GPO LAPS-Policy creada y vinculada a OU=IT,OU=Corporativo" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error creando GPO: $_" -ForegroundColor Red
}

# BLOQUE 5 -- Verificacion
Write-Host "[*] Verificando configuracion LAPS..." -ForegroundColor Yellow
try {
    $schema = Get-LapsADSchema
    Write-Host "    [+] Schema LAPS verificado" -ForegroundColor Green
} catch {
    Write-Host "    [!] No se pudo verificar el schema" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor DarkCyan
Write-Host " Windows LAPS Setup completado" -ForegroundColor DarkCyan
Write-Host "=============================================" -ForegroundColor DarkCyan
Write-Host "  Schema extendido: msLAPS-Password" -ForegroundColor Cyan
Write-Host "  GPO: LAPS-Policy vinculada a OU=IT,OU=Corporativo" -ForegroundColor Cyan
Write-Host "  MISCONFIGURATION: helpdesk.ruiz puede leer LAPS passwords" -ForegroundColor Red
Write-Host ""
Write-Host "  SIGUIENTE PASO: En WKSTN-01 ejecutar gpupdate /force" -ForegroundColor Yellow
Write-Host "  VERIFICAR: Get-LapsADPassword -Identity WKSTN-01 -AsPlainText" -ForegroundColor Yellow
