# 11_Setup_WKSTN02_Corp.ps1 -- WKSTN-02 corp.local
# PREREQUISITO: WinRM habilitado manualmente antes de ejecutar:
#   Enable-PSRemoting -Force
#   Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
#   net user Administrador /active:yes
#   net user Administrador Admin1234!
#   netsh advfirewall firewall add rule name="WinRM" protocol=TCP dir=in localport=5985 action=allow
Write-Host "[*] Configurando WKSTN-02..."

# Remote Management Users
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "CORP\john.smith" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "CORP\corp.admin" -ErrorAction SilentlyContinue
Write-Host "[+] john.smith y corp.admin en Remote Management"

# Autologon john.smith
$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "john.smith"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "JohnCorp2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "CORP"
Write-Host "[+] Autologon: john.smith / JohnCorp2024!"

# C:\Temp
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
Write-Host "[+] C:\Temp creado"

# AlwaysInstallElevated
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Write-Host "[+] AlwaysInstallElevated configurado"

Write-Host "[OK] WKSTN-02 configurada."
