# =============================================================
# SCRIPT — Setup-WKSTN02-Corp.ps1
# WKSTN-02 — corp.local workstation
# Ejecutar como Administrador en WKSTN-02
# =============================================================

Write-Host "`n[*] Configurando WKSTN-02 (corp.local)..." -ForegroundColor Cyan

# ── WinRM habilitado ─────────────────────────────────────────
Enable-PSRemoting -Force | Out-Null
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Write-Host "[+] WinRM habilitado"

# ── Añadir usuarios corp al grupo Remote Management ──────────
Add-LocalGroupMember -Group "Usuarios de administración remota" `
    -Member "CORP\john.smith" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Usuarios de administración remota" `
    -Member "CORP\corp.admin" -ErrorAction SilentlyContinue
Write-Host "[+] john.smith y corp.admin añadidos a Remote Management"

# ── Autologon con credenciales en registry ───────────────────
$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $winlogon -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $winlogon -Name "DefaultUserName"   -Value "john.smith"
Set-ItemProperty -Path $winlogon -Name "DefaultPassword"   -Value "JohnCorp2024!"
Set-ItemProperty -Path $winlogon -Name "DefaultDomainName" -Value "CORP"
Write-Host "[!] Autologon configurado: john.smith / JohnCorp2024!"

# ── Crear C:\Temp con permisos Everyone ──────────────────────
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
$acl = Get-Acl "C:\Temp"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl "C:\Temp" $acl
Write-Host "[+] C:\Temp creado con permisos Everyone"

Write-Host "`n[✓] Setup WKSTN-02 completado." -ForegroundColor Green
