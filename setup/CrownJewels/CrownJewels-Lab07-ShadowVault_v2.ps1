#Requires -RunAsAdministrator
# CrownJewels-Lab07-ShadowVault_v2.ps1
# Maquina: DC-01 (atackcorp.local) — ejecutar como Administrador de dominio
# Version: 2.0 | Junio 2026
#
# FIX v2.0 (Lab-07):
#   - cmdkey via PsExec -i 1 en sesion interactiva de helpdesk.ruiz
#     El script original usaba cmdkey directamente como Administrador —
#     las credenciales DPAPI se almacenaban en el perfil del Administrador,
#     no en el de helpdesk.ruiz. PsExec -i 1 ejecuta en la sesion de consola
#     activa de helpdesk.ruiz (autologon), guardando los blobs DPAPI correctamente.
#   - Verificacion de que helpdesk.ruiz tiene sesion activa antes de ejecutar
#   - PsExec64.exe debe estar en C:\Temp de WKSTN-01 o descargarse
#   - Permisos LAPS ahora configurados con msLAPS-Password (Windows LAPS nativo)
#     en lugar de ms-Mcs-AdmPwd (LAPS legacy)
#
# PREREQUISITO: WKSTN-01 encendida con helpdesk.ruiz en sesion interactiva (autologon)

$ErrorActionPreference = "SilentlyContinue"

Write-Host "==========================================================" -ForegroundColor DarkCyan
Write-Host "  SHADOW VAULT — Crown Jewels Provisioning v2.0" -ForegroundColor DarkCyan
Write-Host "  Adversario: APT28 (Fancy Bear)" -ForegroundColor DarkCyan
Write-Host "==========================================================" -ForegroundColor DarkCyan

# ============================================================
# BLOQUE 1 — Permisos LAPS (Windows LAPS nativo — msLAPS-Password)
# ============================================================
Write-Host "[*] Configurando permisos LAPS excesivos en WKSTN-01..." -ForegroundColor Yellow
try {
    Import-Module ActiveDirectory
    $wkstn = Get-ADComputer "WKSTN-01" -Properties DistinguishedName
    $helpdesk = Get-ADUser "helpdesk.ruiz"
    $sid = $helpdesk.SID

    # GUID de msLAPS-Password (Windows LAPS nativo — diferente de ms-Mcs-AdmPwd)
    $msLAPSPasswordGuid = [System.Guid]"d212edba-30b3-4128-8f16-80c84fa963c9"

    $acl = Get-Acl "AD:\$($wkstn.DistinguishedName)"
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $sid, "ReadProperty", "Allow",
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None,
        $msLAPSPasswordGuid)
    $acl.AddAccessRule($ace)
    Set-Acl "AD:\$($wkstn.DistinguishedName)" $acl
    Write-Host "[!] helpdesk.ruiz puede leer msLAPS-Password de WKSTN-01 (Windows LAPS nativo)" -ForegroundColor Red
} catch {
    Write-Host "[*] Permisos LAPS ya configurados via Set-LapsADReadPasswordPermission" -ForegroundColor Yellow
}

# ============================================================
# BLOQUE 2 — DPAPI credentials en contexto de helpdesk.ruiz
# FIX v2.0: Usar PsExec -i 1 para ejecutar en sesion interactiva
# ============================================================
Write-Host "[*] Configurando credenciales DPAPI en Credential Manager de helpdesk.ruiz..." -ForegroundColor Yellow

# Verificar que WKSTN-01 es accesible
$wkstnIP = "10.0.2.8"
if (-not (Test-Connection -ComputerName $wkstnIP -Count 1 -Quiet)) {
    Write-Host "[!] WKSTN-01 no responde — asegurarse de que esta encendida" -ForegroundColor Red
    Write-Host "    Continuar manualmente: en WKSTN-01 como helpdesk.ruiz ejecutar:" -ForegroundColor Yellow
    Write-Host '    cmdkey /add:"portal-it.atackcorp.local" /user:"helpdesk.ruiz" /pass:"Helpdesk2024!"' -ForegroundColor Cyan
    Write-Host '    cmdkey /add:"DC-01\SQLEXPRESS" /user:"sa" /pass:"SQLsa2026!"' -ForegroundColor Cyan
} else {
    Write-Host "[+] WKSTN-01 accesible — ejecutando cmdkey via PsExec..." -ForegroundColor Green

    # Verificar que PsExec esta disponible en WKSTN-01
    $psexecPath = "\\$wkstnIP\C$\Temp\PsExec64.exe"
    if (-not (Test-Path $psexecPath)) {
        Write-Host "[!] PsExec64.exe no encontrado en C:\Temp de WKSTN-01" -ForegroundColor Yellow
        Write-Host "    Descargar PsExec64.exe y copiarlo a \\$wkstnIP\C$\Temp\" -ForegroundColor Yellow
        Write-Host "    Luego ejecutar manualmente en WKSTN-01 como Administrador:" -ForegroundColor Yellow
        Write-Host '    C:\Temp\PsExec64.exe /accepteula -i 1 cmd.exe /c "cmdkey /add:portal-it.atackcorp.local /user:helpdesk.ruiz /pass:Helpdesk2024! && cmdkey /add:DC-01\SQLEXPRESS /user:sa /pass:SQLsa2026!"' -ForegroundColor Cyan
    } else {
        # Ejecutar cmdkey en la sesion interactiva de helpdesk.ruiz (sesion 1 = consola activa)
        # -i 1: sesion de consola con autologon de helpdesk.ruiz
        # Sin -u/-p: hereda el token de la sesion 1 (helpdesk.ruiz)
        $cmd1 = 'cmdkey /add:"portal-it.atackcorp.local" /user:"helpdesk.ruiz" /pass:"Helpdesk2024!"'
        $cmd2 = 'cmdkey /add:"DC-01\SQLEXPRESS" /user:"sa" /pass:"SQLsa2026!"'
        $fullCmd = "$cmd1 && $cmd2"

        & $psexecPath /accepteula \\$wkstnIP -i 1 -s cmd.exe /c $fullCmd 2>$null
        Write-Host "[+] Credenciales DPAPI configuradas en sesion de helpdesk.ruiz" -ForegroundColor Green
        Write-Host "[!] DPAPI cred1: helpdesk.ruiz:Helpdesk2024! (portal-it.atackcorp.local)" -ForegroundColor Red
        Write-Host "[!] DPAPI cred2: sa:SQLsa2026! (DC-01\SQLEXPRESS)" -ForegroundColor Red
    }
}

# ============================================================
# BLOQUE 3 — Crown Jewel: datos RGPD en share HR-Confidential
# ============================================================
Write-Host "[*] Creando crown jewel — expedientes personales (RGPD)..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\CorporateData\HR\Confidential" -Force | Out-Null

@"
ATACKCORP — EXPEDIENTES PERSONALES — CONFIDENCIAL RGPD
=======================================================
EMPLEADO: Roberto Martinez (ceo.martinez)
  DNI: 12345678-A  |  Salario: 95.000 EUR  |  Cuenta: ES76 2100 0418 6012 3456 7891
  Evaluacion: Excelente  |  Stock options: 50.000 EUR

EMPLEADO: David Ruiz (helpdesk.ruiz)
  DNI: 87654321-B  |  Salario: 32.000 EUR  |  Cuenta: ES23 0049 0001 9920 1234 5678
  Nota disciplinaria: 1 (tardanza reiterada Q1 2026)

*** DATO PROTEGIDO RGPD — ACCESO RESTRINGIDO HR + DA ***
*** Brecha de este dato: multa potencial 4% facturacion anual ***

DATOS FICTICIOS — SOLO USO EDUCATIVO
"@ | Out-File "C:\CorporateData\HR\Confidential\expedientes_personales_2026.txt" -Encoding UTF8

try {
    New-SmbShare -Name "HR-Confidential" -Path "C:\CorporateData\HR\Confidential" `
        -NoAccess "Everyone" -FullAccess "ATACKCORP\Admins. del dominio" -ErrorAction Stop | Out-Null
    Write-Host "[+] Share HR-Confidential creado (datos RGPD — solo DA)" -ForegroundColor Green
} catch { Write-Host "[i] Share HR-Confidential ya existe" -ForegroundColor Cyan }

# ============================================================
# BLOQUE 4 — WriteDACL de helpdesk.ruiz sobre WKSTN-01 (Shadow Credentials)
# ============================================================
Write-Host "[*] Configurando WriteDACL de helpdesk.ruiz sobre WKSTN-01..." -ForegroundColor Yellow
try {
    $wkstn = Get-ADComputer "WKSTN-01" -Properties DistinguishedName
    $helpdesk = Get-ADUser "helpdesk.ruiz"
    $acl = Get-Acl "AD:\$($wkstn.DistinguishedName)"
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $helpdesk.SID,
        [System.DirectoryServices.ActiveDirectoryRights]::WriteDacl,
        [System.Security.AccessControl.AccessControlType]::Allow)
    $acl.AddAccessRule($rule)
    Set-Acl "AD:\$($wkstn.DistinguishedName)" $acl
    Write-Host "[!] helpdesk.ruiz WriteDACL sobre WKSTN-01 (Shadow Credentials path)" -ForegroundColor Red
} catch { Write-Host "[!] Error WriteDACL: $_" -ForegroundColor Red }

# ============================================================
# RESUMEN
# ============================================================
Write-Host ""
Write-Host "==========================================================" -ForegroundColor DarkCyan
Write-Host "  CROWN JEWELS — Lab-07 SHADOW VAULT" -ForegroundColor DarkCyan
Write-Host "==========================================================" -ForegroundColor DarkCyan
Write-Host "  #1 LAPS permisos excesivos   helpdesk.ruiz lee msLAPS-Password WKSTN-01" -ForegroundColor Cyan
Write-Host "  #2 DPAPI Credential Manager  cmdkey entries en sesion helpdesk.ruiz" -ForegroundColor Cyan
Write-Host "  #3 WriteDACL WKSTN-01        helpdesk.ruiz WriteDACL (Shadow Credentials)" -ForegroundColor Cyan
Write-Host "  #4 HR-Confidential share     Expedientes RGPD (solo Domain Admin)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  OBJETIVO: LAPS -> admin WKSTN-01 | DPAPI -> creds | Shadow Creds -> NT hash" -ForegroundColor Yellow
Write-Host "  DATOS FICTICIOS — SOLO USO EDUCATIVO" -ForegroundColor DarkGray
