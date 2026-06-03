# 06_wkstn01_fixed.ps1 -- WKSTN-01 atackcorp.local
# Version: 2.0 | Actualizado: Junio 2026
#
# PREREQUISITO: Ejecutar manualmente ANTES del script:
#   Enable-PSRemoting -Force
#   Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
#   net user Administrador /active:yes
#   net user Administrador NuevaPassword2026!
#   netsh advfirewall firewall add rule name="WinRM" protocol=TCP dir=in localport=5985 action=allow

Write-Host "[*] Configurando WKSTN-01..." -ForegroundColor Cyan

# --- AlwaysInstallElevated ---
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Write-Host "[+] AlwaysInstallElevated configurado"

# --- Autologon helpdesk.ruiz ---
$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "helpdesk.ruiz"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "Helpdesk2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "ATACKCORP"
Write-Host "[+] Autologon: helpdesk.ruiz / Helpdesk2024!"

# --- C:\Temp para transferencia de herramientas ---
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
$acl = Get-Acl "C:\Temp"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("*S-1-1-0","FullControl","Allow")
$acl.SetAccessRule($rule)
Set-Acl "C:\Temp" $acl
Write-Host "[+] C:\Temp creado con permisos Everyone"

# --- Servicio con Unquoted Path + Weak Perms ---
New-Item -Path "C:\Program Files\Servicio Corporativo\Monitor" -ItemType Directory -Force | Out-Null
sc.exe create "CorpMonitor" binpath= "C:\Program Files\Servicio Corporativo\Monitor\monitor.exe" start= auto displayname= "Corporate Monitor Service"
sc.exe sdset CorpMonitor "D:(A;;RPWPDTLOSDRCWDWO;;;AU)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;SY)"
Write-Host "[+] Servicio CorpMonitor con Unquoted Path y Weak Perms"

# --- Remote Management Users ---
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "ATACKCORP\helpdesk.ruiz" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "ATACKCORP\ceo.martinez"  -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "ATACKCORP\sql_svc"       -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "ATACKCORP\iis_svc"       -ErrorAction SilentlyContinue
Write-Host "[+] helpdesk.ruiz, ceo.martinez, sql_svc, iis_svc en Remote Management"

# --- Reglas de firewall (FIX v2.0) ---
# ICMP
netsh advfirewall firewall add rule name="ICMP Allow" protocol=icmpv4:8,any dir=in action=allow | Out-Null
Write-Host "[+] Firewall: ICMP permitido"

# SMB
netsh advfirewall firewall add rule name="SMB Allow" protocol=TCP dir=in localport=445 action=allow | Out-Null
Write-Host "[+] Firewall: SMB (445) permitido"

# WMI
netsh advfirewall firewall set rule group="Instrumental de administracion de Windows (WMI)" new enable=yes | Out-Null
Write-Host "[+] Firewall: WMI permitido"

# Remote Scheduled Tasks (necesario para Invoke-GPUpdate remoto desde DC)
netsh advfirewall firewall set rule group="Remote Scheduled Tasks Management" new enable=yes | Out-Null
Write-Host "[+] Firewall: Remote Scheduled Tasks Management permitido"

Write-Host ""
Write-Host "[OK] WKSTN-01 configurada (v2.0)" -ForegroundColor Green
