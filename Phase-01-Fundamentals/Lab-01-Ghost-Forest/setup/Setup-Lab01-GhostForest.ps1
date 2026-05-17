# ============================================================
#  GHOST FOREST — Lab-01 Attacktive Directory
#  Setup Script: Vulnerability Pre-Configuration
#  Operación: APT29 Emulation | MITRE ATT&CK v14
#  Autor: Red Team Ops Roadmap
#  Ejecutar como: Administrador en DC-01
# ============================================================
# VULNERABILIDADES CONFIGURADAS:
#   [1] DCSync ACL Abuse      → T1003.006 + T1484.001
#   [2] Kerberoasting         → T1558.003
#   [3] Password en Desc      → T1087.002 (bonus)
# ============================================================

#Requires -RunAsAdministrator
Import-Module ActiveDirectory

$Domain      = "atackcorp.local"
$DomainDN    = (Get-ADDomain).DistinguishedName
$DCHostname  = "DC-01.atackcorp.local"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GHOST FOREST — Lab Setup v1.0" -ForegroundColor Cyan
Write-Host "  Dominio: $Domain" -ForegroundColor Cyan
Write-Host "  DC:      $DCHostname" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ─────────────────────────────────────────────────────────────
# BLOQUE 0 — Verificación de prerrequisitos
# ─────────────────────────────────────────────────────────────
Write-Host "[*] Verificando prerrequisitos..." -ForegroundColor Yellow

$requiredUsers = @("ceo.martinez", "backup_svc")
foreach ($user in $requiredUsers) {
    try {
        Get-ADUser $user -ErrorAction Stop | Out-Null
        Write-Host "    [+] Usuario encontrado: $user" -ForegroundColor Green
    } catch {
        Write-Host "    [!] USUARIO NO ENCONTRADO: $user — Abortando." -ForegroundColor Red
        exit 1
    }
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 1 — DCSync ACL Abuse
# T1003.006 — OS Credential Dumping: DCSync
# T1484.001 — Domain Policy Modification: Group Policy
# Objetivo: ceo.martinez puede replicar el directorio
#           → secretsdump → hash NTLM de Administrator
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 1 — Configurando DCSync ACL Abuse..." -ForegroundColor Yellow

try {
    $userSID = (Get-ADUser "ceo.martinez").SID
    $acl     = Get-Acl "AD:\$DomainDN"

    # DS-Replication-Get-Changes (GUID estándar)
    $guidGetChanges = [GUID]"1131f6aa-9c07-11d1-f79f-00c04fc2dcd2"
    # DS-Replication-Get-Changes-All (necesario para cuentas sensibles)
    $guidGetChangesAll = [GUID]"1131f6ab-9c07-11d1-f79f-00c04fc2dcd2"
    # DS-Replication-Get-Changes-In-Filtered-Set (opcional, para objetos filtrados)
    $guidGetChangesFiltered = [GUID]"89e95b76-444d-4c62-991a-0facbeda640c"

    $adRights = [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight
    $adType   = [System.Security.AccessControl.AccessControlType]::Allow
    $adInheritance = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None

    foreach ($guid in @($guidGetChanges, $guidGetChangesAll, $guidGetChangesFiltered)) {
        $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
            $userSID, $adRights, $adType, $guid, $adInheritance
        )
        $acl.AddAccessRule($rule)
    }

    Set-Acl "AD:\$DomainDN" $acl
    Write-Host "    [+] Permisos DCSync asignados a ceo.martinez" -ForegroundColor Green
    Write-Host "    [+] GUIDs configurados:" -ForegroundColor Green
    Write-Host "        DS-Replication-Get-Changes" -ForegroundColor DarkGreen
    Write-Host "        DS-Replication-Get-Changes-All" -ForegroundColor DarkGreen
    Write-Host "        DS-Replication-Get-Changes-In-Filtered-Set" -ForegroundColor DarkGreen

} catch {
    Write-Host "    [!] Error configurando DCSync ACL: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 2 — Kerberoasting via backup_svc
# T1558.003 — Steal or Forge Kerberos Tickets: Kerberoasting
# Objetivo: backup_svc tiene SPN registrado + está en DA
#           → ceo.martinez solicita TGS → crack → DA
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 2 — Configurando Kerberoasting (backup_svc)..." -ForegroundColor Yellow

try {
    # Registrar SPN simulando servicio MSSQL legítimo
    # Hardcodeado como literal para evitar bug de interpolación de variables en bloques try/catch
    $spn = "MSSQLSvc/DC-01.atackcorp.local:1433"
    Set-ADUser "backup_svc" -ServicePrincipalNames @{Add = $spn}
    Write-Host "    [+] SPN registrado: $spn" -ForegroundColor Green

    # Añadir backup_svc al grupo Domain Admins usando SID-512 (universal, independiente del idioma del SO)
    $daGroup = Get-ADGroup -Filter { SID -eq "S-1-5-21-768292631-183641691-1245477636-512" }
    Add-ADGroupMember -Identity $daGroup -Members "backup_svc"
    Write-Host "    [+] backup_svc añadido a $($daGroup.Name)" -ForegroundColor Green

} catch {
    Write-Host "    [!] Error configurando Kerberoasting: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 3 — Password en Description (Bonus)
# T1087.002 — Account Discovery: Domain Account
# Objetivo: enumeración LDAP revela password en claro
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 3 — Configurando Password en Description (bonus)..." -ForegroundColor Yellow

try {
    Set-ADUser "backup_svc" -Description "Backup Service - pwd temporal: Backup2024! (pendiente cambio)"
    Write-Host "    [+] Description con password configurada en backup_svc" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error configurando description: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 4 — Verificación final del escenario
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 4 — Verificación del escenario..." -ForegroundColor Yellow

# Verificar ACL DCSync
Write-Host ""
Write-Host "    [ACL] Permisos de replicación sobre $DomainDN :" -ForegroundColor Cyan
$aclCheck = (Get-Acl "AD:\$DomainDN").Access | Where-Object {
    $_.IdentityReference -match "martinez" -and
    $_.ActiveDirectoryRights -match "ExtendedRight"
}
if ($aclCheck) {
    Write-Host "    [+] DCSync ACL verificada para ceo.martinez" -ForegroundColor Green
} else {
    Write-Host "    [!] ACL DCSync NO encontrada — revisar manualmente" -ForegroundColor Red
}

# Verificar SPN
Write-Host ""
Write-Host "    [SPN] SPNs registrados para backup_svc:" -ForegroundColor Cyan
$spnCheck = (Get-ADUser "backup_svc" -Properties ServicePrincipalName).ServicePrincipalName
if ($spnCheck) {
    $spnCheck | ForEach-Object { Write-Host "    [+] $_" -ForegroundColor Green }
} else {
    Write-Host "    [!] Sin SPNs — revisar manualmente" -ForegroundColor Red
}

# Verificar grupo DA de backup_svc (SID-512 universal)
Write-Host ""
$daGroup = Get-ADGroup -Filter { SID -eq "S-1-5-21-768292631-183641691-1245477636-512" }
Write-Host "    [DA]  Miembros de $($daGroup.Name):" -ForegroundColor Cyan
$daMembers = Get-ADGroupMember -Identity $daGroup | Select-Object -ExpandProperty SamAccountName
$daMembers | ForEach-Object { Write-Host "    [+] $_" -ForegroundColor Green }

# ─────────────────────────────────────────────────────────────
# RESUMEN FINAL — Kill Chain disponible
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ESCENARIO LISTO — Kill Chains disponibles" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  PATH A  [DCSync]" -ForegroundColor Magenta
Write-Host "  ceo.martinez shell (Evil-WinRM)" -ForegroundColor White
Write-Host "    → secretsdump DCSync desde Kali" -ForegroundColor Gray
Write-Host "    → Hash NTLM de Administrator" -ForegroundColor Gray
Write-Host "    → Evil-WinRM Pass-the-Hash" -ForegroundColor Gray
Write-Host "    → Domain Admin  [T1003.006]" -ForegroundColor Green
Write-Host ""
Write-Host "  PATH B  [Kerberoasting]" -ForegroundColor Magenta
Write-Host "  ceo.martinez shell (Evil-WinRM)" -ForegroundColor White
Write-Host "    → GetUserSPNs → TGS backup_svc" -ForegroundColor Gray
Write-Host "    → Hashcat crack → Backup2024!" -ForegroundColor Gray
Write-Host "    → Evil-WinRM como backup_svc" -ForegroundColor Gray
Write-Host "    → Domain Admin  [T1558.003]" -ForegroundColor Green
Write-Host ""
Write-Host "  PATH C  [Bonus — Description enum]" -ForegroundColor Magenta
Write-Host "  ceo.martinez shell (Evil-WinRM)" -ForegroundColor White
Write-Host "    → LDAP enum descriptions" -ForegroundColor Gray
Write-Host "    → Password backup_svc en claro" -ForegroundColor Gray
Write-Host "    → Evil-WinRM como backup_svc" -ForegroundColor Gray
Write-Host "    → Domain Admin  [T1087.002]" -ForegroundColor Green
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Fase 5 lista — volver a Kali y atacar" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
