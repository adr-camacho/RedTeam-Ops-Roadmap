# 01_configurar_workstation_wkstn02_corp.ps1
# Maquina: WKSTN-02 | Version: 2.0 | Junio 2026

if ($env:COMPUTERNAME -ne "WKSTN-02") { Write-Warning "Ejecutar en WKSTN-02"; exit 1 }

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  WKSTN-02: Configuracion workstation corp.local" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "CORP\john.smith" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "CORP\corp.admin" -ErrorAction SilentlyContinue
Write-Host "[+] john.smith y corp.admin en Remote Management" -ForegroundColor Green

$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "john.smith"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "JohnCorp2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "CORP"
Write-Host "[+] Autologon: john.smith" -ForegroundColor Green

New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
New-Item -Path "C:\Tools" -ItemType Directory -Force | Out-Null

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Write-Host "[!] AlwaysInstallElevated configurado" -ForegroundColor Red

netsh advfirewall firewall add rule name="ICMP Allow" protocol=icmpv4:8,any dir=in action=allow | Out-Null
netsh advfirewall firewall add rule name="SMB Allow" protocol=TCP dir=in localport=445 action=allow | Out-Null
Enable-PSRemoting -Force | Out-Null
Write-Host "[OK] WKSTN-02 configurada (v2.0)" -ForegroundColor Green
