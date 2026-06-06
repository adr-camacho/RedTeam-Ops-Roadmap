# 01_configurar_workstation_wkstn01_atackcorp.ps1
# Maquina: WKSTN-01 (Windows 11 - atackcorp.local)
# Version: 3.1 | Junio 2026
#
# CAMBIOS v3.1:
#   - Añadido helpdesk.ruiz a grupos: Usuarios, Usuarios de escritorio remoto,
#     Usuarios de administracion remota
#   - WinRM SDDL con SID de helpdesk.ruiz (S-1-5-21-1477887621-1571165968-1426961061-1107)
#   - Firewall deshabilitado completamente (mas realista entorno corporativo)
#   - ADPasswordEncryptionEnabled=0 para LAPS sin cifrado GKDI
#   - RunAsPPL=0 + RunAsPPLBoot=0 para LSASS dump
#   - Defender deshabilitado con exclusiones
#   - C:\Temp SID via WellKnownSidType (fix *S-1-1-0 en WS2025)
#   - Evil-WinRM requiere formato DOMINIO\usuario
#
# PREREQUISITO MANUAL (antes de ejecutar):
#   Enable-PSRemoting -Force
#   net user Administrador /active:yes
#   net user Administrador NuevaPassword2026!
#   netsh advfirewall firewall add rule name="WinRM" protocol=TCP dir=in localport=5985 action=allow

if ($env:COMPUTERNAME -ne "WKSTN-01") { Write-Warning "Ejecutar en WKSTN-01"; exit 1 }

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  WKSTN-01: Configuracion workstation v3.1" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

# --- Firewall OFF (realista entorno corporativo con firewall perimetral) ---
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False
Write-Host "[+] Firewall deshabilitado (todos los perfiles)" -ForegroundColor Green

# --- AlwaysInstallElevated ---
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Write-Host "[!] AlwaysInstallElevated configurado" -ForegroundColor Red

# --- Autologon helpdesk.ruiz ---
$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "helpdesk.ruiz"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "Helpdesk2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "ATACKCORP"
Write-Host "[+] Autologon: helpdesk.ruiz" -ForegroundColor Green

# --- C:\Temp con permisos Everyone (FIX v3.0: WellKnownSidType) ---
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
$acl = Get-Acl "C:\Temp"
$everyoneSid = New-Object System.Security.Principal.SecurityIdentifier(
    [System.Security.Principal.WellKnownSidType]::WorldSid, $null)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $everyoneSid, "FullControl", "Allow")
$acl.SetAccessRule($rule)
Set-Acl "C:\Temp" $acl
Write-Host "[+] C:\Temp creado con permisos Everyone" -ForegroundColor Green

# --- C:\Tools ---
New-Item -Path "C:\Tools" -ItemType Directory -Force | Out-Null
Write-Host "[+] C:\Tools creado" -ForegroundColor Green

# --- Servicio CorpMonitor con Unquoted Path ---
New-Item -Path "C:\Program Files\Servicio Corporativo\Monitor" -ItemType Directory -Force | Out-Null
sc.exe create "CorpMonitor" binpath= "C:\Program Files\Servicio Corporativo\Monitor\monitor.exe" start= auto displayname= "Corporate Monitor Service" | Out-Null
sc.exe sdset CorpMonitor "D:(A;;RPWPDTLOSDRCWDWO;;;AU)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;SY)" | Out-Null
Write-Host "[!] Servicio CorpMonitor con Unquoted Path y Weak Permissions" -ForegroundColor Red

# --- Grupos locales (FIX v3.1) ---
# helpdesk.ruiz necesita estar en estos grupos para WinRM y login local
$groups = @(
    "Usuarios",
    "Usuarios de escritorio remoto",
    "Usuarios de administración remota"
)
foreach ($g in $groups) {
    Add-LocalGroupMember -Group $g -Member "ATACKCORP\helpdesk.ruiz" -ErrorAction SilentlyContinue
}
Add-LocalGroupMember -Group "Usuarios de administración remota" -Member "ATACKCORP\ceo.martinez" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administración remota" -Member "ATACKCORP\sql_svc" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administración remota" -Member "ATACKCORP\iis_svc" -ErrorAction SilentlyContinue
Write-Host "[+] Grupos locales configurados para helpdesk.ruiz y cuentas de servicio" -ForegroundColor Green

# --- WinRM SDDL con SID de helpdesk.ruiz (FIX v3.1) ---
# SID helpdesk.ruiz: S-1-5-21-1477887621-1571165968-1426961061-1107
$helpdeskSID = "S-1-5-21-1477887621-1571165968-1426961061-1107"
Set-PSSessionConfiguration -Name "Microsoft.PowerShell" `
    -SecurityDescriptorSddl "O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;$helpdeskSID)(A;;GR;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)" -Force
Restart-Service WinRM -Force
Write-Host "[+] WinRM SDDL actualizado para helpdesk.ruiz" -ForegroundColor Green

# --- LAPS sin cifrado GKDI (FIX v3.1) ---
# WS2025 usa GKDI por defecto — deshabilitar para herramientas Linux
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\LAPS\Config" /v ADPasswordEncryptionEnabled /t REG_DWORD /d 0 /f | Out-Null
Write-Host "[+] LAPS: ADPasswordEncryptionEnabled=0 (sin cifrado GKDI)" -ForegroundColor Green

# --- PPL deshabilitado (FIX v3.1) ---
# Windows 11 23H2+ activa PPL por defecto — bloquea LSASS dump
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPLBoot /t REG_DWORD /d 0 /f | Out-Null
Write-Host "[+] LSASS PPL deshabilitado (RunAsPPL=0)" -ForegroundColor Green

# --- Defender deshabilitado (FIX v3.1) ---
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionPath "C:\Temp" -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionPath "C:\Tools" -ErrorAction SilentlyContinue
Write-Host "[+] Defender deshabilitado con exclusiones C:\Temp y C:\Tools" -ForegroundColor Green

Write-Host ""
Write-Host "================================================" -ForegroundColor DarkGreen
Write-Host "  WKSTN-01 configurada v3.1" -ForegroundColor DarkGreen
Write-Host "================================================" -ForegroundColor DarkGreen
Write-Host "NOTA: Reiniciar para que PPL=0 surta efecto completo" -ForegroundColor Yellow
Write-Host "NOTA: Tras reinicio ejecutar: Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False" -ForegroundColor Yellow
Write-Host "NOTA: Evil-WinRM usar formato: DOMINIO\usuario" -ForegroundColor Yellow
