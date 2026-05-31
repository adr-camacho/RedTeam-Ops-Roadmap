# 06_wkstn01.ps1 -- WKSTN-01 atackcorp.local
# PREREQUISITO: WinRM habilitado manualmente antes de ejecutar:
#   Enable-PSRemoting -Force
#   Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
#   net user Administrador /active:yes
#   net user Administrador NuevaPassword2026!
#   netsh advfirewall firewall add rule name="WinRM" protocol=TCP dir=in localport=5985 action=allow
Write-Host "[*] Configurando WKSTN-01..."

# AlwaysInstallElevated
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Write-Host "[+] AlwaysInstallElevated configurado"

# Autologon helpdesk.ruiz
$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "helpdesk.ruiz"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "Helpdesk2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "ATACKCORP"
Write-Host "[+] Autologon: helpdesk.ruiz / Helpdesk2024!"

# C:\Temp con permisos Everyone
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
Write-Host "[+] C:\Temp creado"

# Servicio con Unquoted Path + Weak Perms
New-Item -Path "C:\Program Files\Servicio Corporativo\Monitor" -ItemType Directory -Force | Out-Null
sc.exe create "CorpMonitor" binpath= "C:\Program Files\Servicio Corporativo\Monitor\monitor.exe" start= auto displayname= "Corporate Monitor Service"
sc.exe sdset CorpMonitor "D:(A;;RPWPDTLOSDRCWDWO;;;AU)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;SY)"
Write-Host "[+] Servicio CorpMonitor con Unquoted Path y Weak Perms"

# Remote Management Users
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "ATACKCORP\helpdesk.ruiz" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "ATACKCORP\ceo.martinez" -ErrorAction SilentlyContinue
Write-Host "[+] helpdesk.ruiz y ceo.martinez en Remote Management"

Write-Host "[OK] WKSTN-01 configurada."
