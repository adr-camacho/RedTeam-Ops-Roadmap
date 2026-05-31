# 11_Setup_WKSTN02_Corp.ps1 -- WKSTN-02 corp.local
Write-Host "[*] Configurando WKSTN-02..."

Enable-PSRemoting -Force | Out-Null
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Write-Host "[+] WinRM habilitado"

Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "CORP\john.smith" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administracion remota" -Member "CORP\corp.admin" -ErrorAction SilentlyContinue
Write-Host "[+] john.smith y corp.admin anadidos a Remote Management"

$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "john.smith"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "JohnCorp2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "CORP"
Write-Host "[!] Autologon: john.smith / JohnCorp2024!"

New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
$acl = Get-Acl "C:\Temp"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$acl.AddAccessRule($rule)
Set-Acl "C:\Temp" $acl
Write-Host "[+] C:\Temp creado con permisos Everyone"

Write-Host "[OK] Setup WKSTN-02 completado."
