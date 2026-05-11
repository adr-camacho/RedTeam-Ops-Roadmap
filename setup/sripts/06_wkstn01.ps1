# =============================================================
# SCRIPT 06 — Configuración vulnerable de WKSTN-01
# Ejecutar: PowerShell como Administrador local
# Máquina: WKSTN-01
# Prerequisito: Máquina unida al dominio atackcorp.local
# =============================================================

# ── Verificar que está unida al dominio ──────────────────────
$domain = (Get-WmiObject Win32_ComputerSystem).Domain
if ($domain -ne "atackcorp.local") {
    Write-Host "[!] WKSTN-01 no está unida a atackcorp.local (dominio actual: $domain)" -ForegroundColor Red
    Write-Host "    Une la máquina primero con: Add-Computer -DomainName atackcorp.local" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n[*] Configurando WKSTN-01 como workstation corporativa vulnerable..." -ForegroundColor Cyan

# ── Habilitar WinRM ──────────────────────────────────────────
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Write-Host "[+] WinRM habilitado" -ForegroundColor Green

# ── AlwaysInstallElevated ────────────────────────────────────
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" `
    -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" `
    -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Write-Host "[!] AlwaysInstallElevated habilitado (HKLM + HKCU)" -ForegroundColor Red

# ── Autologon con credenciales en registry ───────────────────
$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "helpdesk.ruiz"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "Helpdesk2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "ATACKCORP"
Write-Host "[!] Autologon configurado: ATACKCORP\helpdesk.ruiz / Helpdesk2024!" -ForegroundColor Red

# ── Servicio con Unquoted Service Path ───────────────────────
Write-Host "`n[*] Creando servicio vulnerable (Unquoted Service Path)..." -ForegroundColor Cyan
New-Item -Path "C:\Program Files\Servicio Corporativo\Monitor" -ItemType Directory -Force | Out-Null

# Crear ejecutable dummy (batch que simula un servicio)
$dummyBat = @"
@echo off
:loop
timeout /t 60 >nul
goto loop
"@
Set-Content "C:\Program Files\Servicio Corporativo\Monitor\monitor.bat" $dummyBat

# Crear wrapper .exe con sc.exe (servicio real)
# Nota: en un lab real usar un .exe compilado con mingw como dummy service
sc.exe create "CorpMonitor" `
    binpath= "C:\Program Files\Servicio Corporativo\Monitor\monitor.exe" `
    start= auto `
    displayname= "Corporate Monitor Service" | Out-Null

Write-Host "[!] Servicio 'CorpMonitor' creado con ruta sin comillas" -ForegroundColor Red
Write-Host "    Path vulnerable: C:\Program Files\Servicio Corporativo\Monitor\monitor.exe" -ForegroundColor Yellow

# ── Weak Service Permissions ─────────────────────────────────
# Dar control total sobre el servicio a Authenticated Users
sc.exe sdset CorpMonitor "D:(A;;RPWPDTLOSDRCWDWO;;;AU)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;BA)" | Out-Null
Write-Host "[!] Weak Service Perms: Authenticated Users tienen control sobre CorpMonitor" -ForegroundColor Red

# ── SeImpersonatePrivilege para helpdesk.ruiz ────────────────
Write-Host "`n[*] Configurando SeImpersonatePrivilege para helpdesk.ruiz..." -ForegroundColor Cyan
$seceditCfg = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeImpersonatePrivilege = *S-1-5-32-568,*S-1-5-6,ATACKCORP\helpdesk.ruiz
"@
$seceditCfg | Out-File "$env:TEMP\privs.inf" -Encoding Unicode
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg "$env:TEMP\privs.inf" /quiet
Write-Host "[!] SeImpersonatePrivilege añadido a helpdesk.ruiz" -ForegroundColor Red

# ── Deshabilitar Windows Defender ────────────────────────────
Write-Host "`n[*] Deshabilitando Windows Defender para el lab..." -ForegroundColor Cyan
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
Write-Host "[+] Windows Defender deshabilitado" -ForegroundColor Green

# ── Resumen final ────────────────────────────────────────────
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " WKSTN-01 configurada. Resumen:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " [!] WinRM habilitado (puerto 5985)" -ForegroundColor Yellow
Write-Host " [!] AlwaysInstallElevated activo" -ForegroundColor Yellow
Write-Host " [!] Autologon: helpdesk.ruiz / Helpdesk2024!" -ForegroundColor Yellow
Write-Host " [!] Unquoted Service Path: CorpMonitor" -ForegroundColor Yellow
Write-Host " [!] Weak Service Perms: CorpMonitor" -ForegroundColor Yellow
Write-Host " [!] SeImpersonatePrivilege: helpdesk.ruiz" -ForegroundColor Yellow
Write-Host " [+] Windows Defender deshabilitado" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[+] Script 06 completado." -ForegroundColor Green
