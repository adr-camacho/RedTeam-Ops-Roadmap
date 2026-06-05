#Requires -RunAsAdministrator
# Crown Jewels -- Lab-07 SHADOW VAULT (APT28)
# Version: 1.0 | Junio 2026
$ErrorActionPreference = "SilentlyContinue"
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host "    SHADOW VAULT -- Crown Jewels Provisioning     " -ForegroundColor DarkCyan
Write-Host "==================================================" -ForegroundColor DarkCyan

# BLOQUE 1 -- LAPS simulado
Write-Host "[*] Configurando LAPS password en WKSTN-01..." -ForegroundColor Yellow
try {
    $wkstn = Get-ADComputer "WKSTN-01" -Properties "ms-Mcs-AdmPwd"
    if ($null -ne $wkstn."ms-Mcs-AdmPwd") {
        Write-Host "    [+] LAPS instalado -- password real disponible" -ForegroundColor Green
    } else {
        Write-Host "    [i] LAPS no instalado -- simulando via archivo" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "C:\CorporateData\IT\LAPS" -Force | Out-Null
        $lapsContent = "LAPS PASSWORD REGISTRY -- ATACKCORP`n"
        $lapsContent += "===================================`n"
        $lapsContent += "Equipo: WKSTN-01 (10.0.2.8)`n"
        $lapsContent += "Password Admin Local: LAPSwkstn01_2026!`n"
        $lapsContent += "Expiracion: 01/08/2026`n"
        $lapsContent += "Ultima rotacion: 01/05/2026`n`n"
        $lapsContent += "Equipo: DC-01 (10.0.2.10)`n"
        $lapsContent += "Password Admin Local: LAPSdc01_2026!xK`n"
        $lapsContent += "Expiracion: 01/08/2026`n`n"
        $lapsContent += "NOTA: LAPS v1 instalado -- ms-Mcs-AdmPwd legible por helpdesk.ruiz (permisos excesivos)`n"
        Set-Content "C:\CorporateData\IT\LAPS\laps_registry.txt" $lapsContent -Encoding UTF8
        Write-Host "    [+] Simulacion LAPS creada en C:\CorporateData\IT\LAPS\" -ForegroundColor Green
    }
} catch { Write-Host "    [!] Error LAPS: $_" -ForegroundColor Red }

# BLOQUE 2 -- DPAPI credentials
Write-Host "[*] Creando credenciales DPAPI simuladas..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\Users\helpdesk.ruiz\AppData\Local\Microsoft\Credentials-Backup" -Force | Out-Null
$vaultContent = "DPAPI CREDENTIAL VAULT -- helpdesk.ruiz`n"
$vaultContent += "=======================================`n"
$vaultContent += "Credenciales almacenadas:`n"
$vaultContent += "  - Portal IT interno: helpdesk.ruiz / Helpdesk2024!`n"
$vaultContent += "  - Monitoring Zabbix: helpdesk / Zabbix@2026!`n"
$vaultContent += "  - VPN corporativa: david.ruiz / VPNhelpdesk2024!`n"
$vaultContent += "  - SQL Management: sa / SQLsa2026!`n"
Set-Content "C:\Users\helpdesk.ruiz\AppData\Local\Microsoft\Credentials-Backup\vault_reference.txt" $vaultContent -Encoding UTF8

& cmdkey /add:"portal-it.atackcorp.local" /user:"helpdesk.ruiz" /pass:"Helpdesk2024!" 2>$null
& cmdkey /add:"DC-01\SQLEXPRESS" /user:"sa" /pass:"SQLsa2026!" 2>$null
Write-Host "    [+] Credenciales en Windows Credential Manager (helpdesk.ruiz)" -ForegroundColor Green

# BLOQUE 3 -- Permisos LAPS excesivos
Write-Host "[*] Configurando permisos LAPS excesivos..." -ForegroundColor Yellow
try {
    $wkstn = Get-ADComputer "WKSTN-01"
    $helpdesk = Get-ADUser "helpdesk.ruiz"
    $acl = Get-Acl "AD:\$($wkstn.DistinguishedName)"
    $sid = $helpdesk.SID
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $sid, "ReadProperty", "Allow",
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None,
        [System.Guid]"7ece0d4e-1e41-4c75-a37a-14ddfea1a3f7")
    $acl.AddAccessRule($ace)
    Set-Acl "AD:\$($wkstn.DistinguishedName)" $acl
    Write-Host "    [+] helpdesk.ruiz puede leer ms-Mcs-AdmPwd de WKSTN-01" -ForegroundColor Green
} catch { Write-Host "    [*] No se pudo configurar permisos LAPS: $_" -ForegroundColor Yellow }

# BLOQUE 4 -- Crown Jewel: datos RGPD
Write-Host "[*] Creando crown jewel -- datos HR confidenciales..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\CorporateData\HR\Confidential" -Force | Out-Null
$hrContent = "ATACKCORP -- EXPEDIENTES PERSONALES -- CONFIDENCIAL RGPD`n"
$hrContent += "=======================================================`n"
$hrContent += "EMPLEADO: Roberto Martinez (ceo.martinez)`n"
$hrContent += "  DNI: 12345678-A  |  Salario: 95.000 EUR`n"
$hrContent += "  Cuenta: ES76 2100 0418 6012 3456 7891`n"
$hrContent += "  Stock options: 50.000 EUR`n`n"
$hrContent += "EMPLEADO: David Ruiz (helpdesk.ruiz)`n"
$hrContent += "  DNI: 87654321-B  |  Salario: 32.000 EUR`n"
$hrContent += "  Cuenta: ES23 0049 0001 9920 1234 5678`n`n"
$hrContent += "*** DATO PROTEGIDO RGPD -- ACCESO RESTRINGIDO HR + DA ***`n"
Set-Content "C:\CorporateData\HR\Confidential\expedientes_personales_2026.txt" $hrContent -Encoding UTF8

try {
    New-SmbShare -Name "HR-Confidential" -Path "C:\CorporateData\HR\Confidential" `
      -NoAccess "*S-1-1-0" `
      -FullAccess "*S-1-5-21-768292631-183641691-1245477636-512" -ErrorAction Stop | Out-Null
    Write-Host "    [+] Share HR-Confidential creado (solo DA)" -ForegroundColor Green
} catch { Write-Host "    [*] Share ya existe" -ForegroundColor Yellow }

# RESUMEN
Write-Host ""
Write-Host "===================================================" -ForegroundColor DarkCyan
Write-Host " CROWN JEWELS -- Lab-07 SHADOW VAULT" -ForegroundColor DarkCyan
Write-Host "===================================================" -ForegroundColor DarkCyan
Write-Host "  #1 LAPS passwords          C:\CorporateData\IT\LAPS\" -ForegroundColor Cyan
Write-Host "  #2 DPAPI Credential Mgr    cmdkey entries helpdesk.ruiz" -ForegroundColor Cyan
Write-Host "  #3 Permisos LAPS           helpdesk.ruiz lee ms-Mcs-AdmPwd WKSTN-01" -ForegroundColor Cyan
Write-Host "  #4 RGPD data               HR-Confidential share (solo DA)" -ForegroundColor Cyan
Write-Host " OBJETIVO: LAPS + DPAPI + HR data" -ForegroundColor Yellow
Write-Host " DATOS FICTICIOS -- SOLO USO EDUCATIVO" -ForegroundColor DarkGray
