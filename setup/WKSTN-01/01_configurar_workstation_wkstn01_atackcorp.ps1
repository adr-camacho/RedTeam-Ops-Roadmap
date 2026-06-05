# 01_configurar_workstation_wkstn01_atackcorp.ps1
# Maquina: WKSTN-01 | Version: 3.0 | Junio 2026
# FIX v3.0: C:\Temp SID via WellKnownSidType (fallo *S-1-1-0 en WS2025)
#            Reglas firewall ICMP, SMB, WMI, Remote Scheduled Tasks
# PREREQUISITO MANUAL:
#   Enable-PSRemoting -Force
#   net user Administrador /active:yes
#   net user Administrador NuevaPassword2026!
#   netsh advfirewall firewall add rule name="WinRM" protocol=TCP dir=in localport=5985 action=allow

if ($env:COMPUTERNAME -ne "WKSTN-01") { Write-Warning "Ejecutar en WKSTN-01"; exit 1 }

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  WKSTN-01: Configuracion workstation atackcorp" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Write-Host "[!] AlwaysInstallElevated configurado" -ForegroundColor Red

$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "helpdesk.ruiz"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "Helpdesk2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "ATACKCORP"
Write-Host "[+] Autologon: helpdesk.ruiz" -ForegroundColor Green

New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
$acl = Get-Acl "C:\Temp"
$everyoneSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::WorldSid, $null)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($everyoneSid, "FullControl", "Allow")
$acl.SetAccessRule($rule); Set-Acl "C:\Temp" $acl
Write-Host "[+] C:\Temp con permisos Everyone (WellKnownSidType)" -ForegroundColor Green

New-Item -Path "C:\Tools" -ItemType Directory -Force | Out-Null
Write-Host "[+] C:\Tools creado" -ForegroundColor Green

New-Item -Path "C:\Program Files\Servicio Corporativo\Monitor" -ItemType Directory -Force | Out-Null
sc.exe create "CorpMonitor" binpath= "C:\Program Files\Servicio Corporativo\Monitor\monitor.exe" start= auto displayname= "Corporate Monitor Service" | Out-Null
sc.exe sdset CorpMonitor "D:(A;;RPWPDTLOSDRCWDWO;;;AU)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;SY)" | Out-Null
Write-Host "[!] Servicio CorpMonitor con Unquoted Path" -ForegroundColor Red

$rmUsers = @("ATACKCORP\helpdesk.ruiz","ATACKCORP\ceo.martinez","ATACKCORP\sql_svc","ATACKCORP\iis_svc")
foreach ($u in $rmUsers) { Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member $u -ErrorAction SilentlyContinue }
Write-Host "[+] Remote Management configurado" -ForegroundColor Green

netsh advfirewall firewall add rule name="ICMP Allow" protocol=icmpv4:8,any dir=in action=allow | Out-Null
netsh advfirewall firewall add rule name="SMB Allow" protocol=TCP dir=in localport=445 action=allow | Out-Null
netsh advfirewall firewall set rule group="Instrumental de administracion de Windows (WMI)" new enable=yes | Out-Null
netsh advfirewall firewall set rule group="Remote Scheduled Tasks Management" new enable=yes | Out-Null
Write-Host "[+] Firewall: ICMP, SMB, WMI, Remote Scheduled Tasks" -ForegroundColor Green

Write-Host "[OK] WKSTN-01 configurada (v3.0)" -ForegroundColor Green
