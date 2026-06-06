# 13_setup_ADCS.ps1 -- Servicios de Certificados AD (ADCS) vulnerable
# Version: 1.0 | Junio 2026
# Maquina: DC-01 (atackcorp.local)
# Prerequisito: Scripts 01-02 ejecutados
#
# Vulnerabilidades configuradas (Lab-03 DARK GATE):
#   ESC1 -- Template con SAN arbitrario (Client Authentication)
#   ESC4 -- Template con GenericWrite para fin.garcia
#   ESC8 -- NTLM Relay contra HTTP enrollment endpoint
#
# Adversario simulado: APT29 (Cozy Bear)

Write-Host "=============================================" -ForegroundColor DarkMagenta
Write-Host "    ADCS Setup -- DC-01 (atackcorp.local)    " -ForegroundColor DarkMagenta
Write-Host "=============================================" -ForegroundColor DarkMagenta

# BLOQUE 1 -- Instalar ADCS
Write-Host "[*] Instalando Active Directory Certificate Services..." -ForegroundColor Yellow
$feature = Get-WindowsFeature -Name ADCS-Cert-Authority
if (-not $feature.Installed) {
    Install-WindowsFeature -Name ADCS-Cert-Authority, ADCS-Web-Enrollment -IncludeManagementTools
    Write-Host "    [+] ADCS instalado" -ForegroundColor Green
} else {
    Write-Host "    [i] ADCS ya instalado" -ForegroundColor Cyan
}

# BLOQUE 2 -- Configurar CA raiz
Write-Host "[*] Configurando CA raiz empresarial..." -ForegroundColor Yellow
try {
    Install-AdcsCertificationAuthority `
        -CAType EnterpriseRootCa `
        -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
        -KeyLength 2048 `
        -HashAlgorithmName SHA256 `
        -CACommonName "AtackCorp-CA" `
        -CADistinguishedNameSuffix "DC=atackcorp,DC=local" `
        -DatabaseDirectory "C:\Windows\system32\CertLog" `
        -LogDirectory "C:\Windows\system32\CertLog" `
        -Force
    Write-Host "    [+] CA AtackCorp-CA configurada" -ForegroundColor Green
} catch {
    Write-Host "    [i] CA ya configurada o error: $_" -ForegroundColor Cyan
}

# BLOQUE 3 -- Instalar Web Enrollment
Write-Host "[*] Configurando Web Enrollment..." -ForegroundColor Yellow
try {
    Install-AdcsWebEnrollment -Force
    Write-Host "    [+] Web Enrollment habilitado (http://DC-01/certsrv)" -ForegroundColor Green
} catch {
    Write-Host "    [i] Web Enrollment ya configurado: $_" -ForegroundColor Cyan
}

# BLOQUE 4 -- Template ESC1: SAN arbitrario
Write-Host "[*] Configurando template vulnerable ESC1..." -ForegroundColor Yellow
try {
    $ConfigContext = ([ADSI]"LDAP://RootDSE").configurationNamingContext
    $TemplateContainer = "CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"

    # Duplicar template User para crear ESC1
    $SourceTemplate = [ADSI]"LDAP://CN=User,$TemplateContainer"
    $NewTemplate = $SourceTemplate.PSBase.CopyTo("LDAP://CN=CorpUser-ESC1,$TemplateContainer")
    $NewTemplate.Put("cn", "CorpUser-ESC1")
    $NewTemplate.Put("displayName", "CorpUser-ESC1")
    $NewTemplate.Put("msPKI-Certificate-Name-Flag", 1)  # ENROLLEE_SUPPLIES_SUBJECT
    $NewTemplate.Put("msPKI-Enrollment-Flag", 0)
    $NewTemplate.Put("pKIExtendedKeyUsage", @("1.3.6.1.5.5.7.3.2"))  # Client Authentication
    $NewTemplate.SetInfo()

    Write-Host "    [!] ESC1: Template CorpUser-ESC1 creado (SAN arbitrario habilitado)" -ForegroundColor Red
} catch {
    Write-Host "    [i] Template ESC1 ya existe o error: $_" -ForegroundColor Cyan
}

# BLOQUE 5 -- Template ESC4: GenericWrite para fin.garcia
Write-Host "[*] Configurando template vulnerable ESC4..." -ForegroundColor Yellow
try {
    $SourceTemplate2 = [ADSI]"LDAP://CN=User,$TemplateContainer"
    $NewTemplate2 = $SourceTemplate2.PSBase.CopyTo("LDAP://CN=CorpAdmin-ESC4,$TemplateContainer")
    $NewTemplate2.Put("cn", "CorpAdmin-ESC4")
    $NewTemplate2.Put("displayName", "CorpAdmin-ESC4")
    $NewTemplate2.SetInfo()

    # ACL: fin.garcia tiene GenericWrite sobre el template
    $finGarcia = (Get-ADUser "fin.garcia").SID
    $templatePath = "AD:\CN=CorpAdmin-ESC4,$TemplateContainer"
    $acl = Get-Acl $templatePath
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $finGarcia,
        [System.DirectoryServices.ActiveDirectoryRights]::GenericWrite,
        [System.Security.AccessControl.AccessControlType]::Allow
    )
    $acl.AddAccessRule($rule)
    Set-Acl $templatePath $acl

    Write-Host "    [!] ESC4: Template CorpAdmin-ESC4 con GenericWrite para fin.garcia" -ForegroundColor Red
} catch {
    Write-Host "    [i] Template ESC4 ya existe o error: $_" -ForegroundColor Cyan
}

# BLOQUE 6 -- Publicar templates en la CA
Write-Host "[*] Publicando templates en la CA..." -ForegroundColor Yellow
try {
    Add-CATemplate -TemplateName "CorpUser-ESC1" -Force
    Write-Host "    [+] Template CorpUser-ESC1 publicado" -ForegroundColor Green
} catch {
    Write-Host "    [i] CorpUser-ESC1: $_" -ForegroundColor Cyan
}
try {
    Add-CATemplate -TemplateName "CorpAdmin-ESC4" -Force
    Write-Host "    [+] Template CorpAdmin-ESC4 publicado" -ForegroundColor Green
} catch {
    Write-Host "    [i] CorpAdmin-ESC4: $_" -ForegroundColor Cyan
}

# BLOQUE 7 -- Permisos de enrollment
Write-Host "[*] Configurando permisos de enrollment..." -ForegroundColor Yellow
try {
    # Domain Users pueden hacer enrollment en ESC1
    $domUsers = (Get-ADGroup "Usuarios del dominio").SID
    $esc1Path = "AD:\CN=CorpUser-ESC1,$TemplateContainer"
    $acl1 = Get-Acl $esc1Path
    # Enrollment right GUID
    $enrollGuid = [System.Guid]"0e10c968-78fb-11d2-90d4-00c04f79dc55"
    $rule1 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $domUsers,
        [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight,
        [System.Security.AccessControl.AccessControlType]::Allow,
        $enrollGuid,
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
    )
    $acl1.AddAccessRule($rule1)
    Set-Acl $esc1Path $acl1
    Write-Host "    [!] ESC1: Domain Users pueden hacer enrollment (vector de ataque)" -ForegroundColor Red
} catch {
    Write-Host "    [i] Permisos enrollment: $_" -ForegroundColor Cyan
}

# RESUMEN
Write-Host ""
Write-Host "=============================================" -ForegroundColor DarkMagenta
Write-Host " ADCS Setup completado -- AtackCorp-CA" -ForegroundColor DarkMagenta
Write-Host "=============================================" -ForegroundColor DarkMagenta
Write-Host "  CA: AtackCorp-CA @ DC-01.atackcorp.local" -ForegroundColor Cyan
Write-Host "  Web Enrollment: http://DC-01/certsrv" -ForegroundColor Cyan
Write-Host "  ESC1: CorpUser-ESC1 (SAN arbitrario)" -ForegroundColor Red
Write-Host "  ESC4: CorpAdmin-ESC4 (GenericWrite fin.garcia)" -ForegroundColor Red
Write-Host ""
Write-Host "  VERIFICAR: certipy find -u helpdesk.ruiz@atackcorp.local -p Helpdesk2024! -dc-ip 10.0.2.10 -vulnerable" -ForegroundColor Yellow
