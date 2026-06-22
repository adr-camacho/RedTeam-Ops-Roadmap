# ============================================================
#  GHOST FOREST — Lab-01 Ghost Forest
#  Setup Script v2.1: Infraestructura completa + Vulnerabilidades + OU IT + WinRM
#  Operación: APT29 Emulation | MITRE ATT&CK v14
#  Autor: Red Team Ops Roadmap — Adrián Camacho
#
#  CAMBIOS v2.1:
#    - OU IT bajo Corporativo + vinculación WKSTN-01 + GPO IT-Baseline link
#    - sql_svc/iis_svc/helpdesk.ruiz añadidos a grupo WinRM
#    - C:\Temp creado con permisos Everyone
#    - Constrained Delegation: CIFS → MSSQLSvc/dc01:1433 (corrección)
#    - GPO IT-Baseline vinculada a OU=IT,OU=Corporativo (ruta correcta)
#    - Bloques renumerados (8→11)
#  Ejecutar como: Administrador en DC-01 (atackcorp.local)
#
#  ESTRUCTURA CREADA:
#    OUs: Corporativo > Direccion/RRHH/Finanzas | IT > Administradores/Helpdesk | CuentasServicio | Equipos
#    Usuarios: ceo.martinez, rrhh.lopez, fin.garcia, it.admin, helpdesk.ruiz, sql_svc, iis_svc, backup_svc
#
#  VULNERABILIDADES CONFIGURADAS:
#    [1] AS-REP Roasting      → ceo.martinez (PreAuth deshabilitado)
#    [2] Kerberoasting        → backup_svc (SPN + Domain Admin)
#    [3] Password en Desc     → backup_svc (T1087.002)
#    [4] DCSync ACL Abuse     → ceo.martinez (T1003.006)
#    [5] Unconstrained Deleg  → sql_svc (T1558.001)
#    [6] Constrained Deleg    → iis_svc (S4U2Proxy — T1558.001)
#    [7] GPO Abuse            → helpdesk.ruiz (FullControl IT-Baseline)
#    [8] ACL Abuse            → fin.garcia (GenericWrite sobre sql_svc)
# ============================================================

#Requires -RunAsAdministrator
Import-Module ActiveDirectory

$Domain     = "atackcorp.local"
$DomainDN   = (Get-ADDomain).DistinguishedName
$DomainSID  = (Get-ADDomain).DomainSID.Value
$DCHostname = "DC-01.atackcorp.local"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GHOST FOREST — Lab Setup v2.0" -ForegroundColor Cyan
Write-Host "  Dominio: $Domain" -ForegroundColor Cyan
Write-Host "  DC:      $DCHostname" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ─────────────────────────────────────────────────────────────
# BLOQUE 1 — Estructura de OUs
# ─────────────────────────────────────────────────────────────
Write-Host "[*] BLOQUE 1 — Creando estructura de OUs..." -ForegroundColor Yellow

$OUs = @(
    @{Name="Corporativo";      Path=$DomainDN},
    @{Name="Direccion";        Path="OU=Corporativo,$DomainDN"},
    @{Name="RRHH";             Path="OU=Corporativo,$DomainDN"},
    @{Name="Finanzas";         Path="OU=Corporativo,$DomainDN"},
    @{Name="IT";               Path=$DomainDN},
    @{Name="Administradores";  Path="OU=IT,$DomainDN"},
    @{Name="Helpdesk";         Path="OU=IT,$DomainDN"},
    @{Name="CuentasServicio";  Path=$DomainDN},
    @{Name="Equipos";          Path=$DomainDN}
)

foreach ($ou in $OUs) {
    try {
        New-ADOrganizationalUnit -Name $ou.Name -Path $ou.Path -ErrorAction Stop
        Write-Host "    [+] OU creada: $($ou.Name)" -ForegroundColor Green
    } catch {
        Write-Host "    [*] OU ya existe: $($ou.Name)" -ForegroundColor Yellow
    }
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 2 — Usuarios del dominio
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 2 — Creando usuarios del dominio..." -ForegroundColor Yellow

$Users = @(
    @{
        SamAccountName = "ceo.martinez"
        Name           = "CEO Martinez"
        GivenName      = "CEO"
        Surname        = "Martinez"
        Password       = "Direccion2024!"
        Path           = "OU=Direccion,OU=Corporativo,$DomainDN"
        Description    = "Director Ejecutivo"
    },
    @{
        SamAccountName = "rrhh.lopez"
        Name           = "RRHH Lopez"
        GivenName      = "RRHH"
        Surname        = "Lopez"
        Password       = "RRHH2024!"
        Path           = "OU=RRHH,OU=Corporativo,$DomainDN"
        Description    = "Recursos Humanos"
    },
    @{
        SamAccountName = "fin.garcia"
        Name           = "Fin Garcia"
        GivenName      = "Fin"
        Surname        = "Garcia"
        Password       = "Finance2024!"
        Path           = "OU=Finanzas,OU=Corporativo,$DomainDN"
        Description    = "Departamento Financiero"
    },
    @{
        SamAccountName = "it.admin"
        Name           = "IT Admin"
        GivenName      = "IT"
        Surname        = "Admin"
        Password       = "ITAdmin2024!"
        Path           = "OU=Administradores,OU=IT,$DomainDN"
        Description    = "Administrador IT"
    },
    @{
        SamAccountName = "helpdesk.ruiz"
        Name           = "Helpdesk Ruiz"
        GivenName      = "Helpdesk"
        Surname        = "Ruiz"
        Password       = "Helpdesk2024!"
        Path           = "OU=Helpdesk,OU=IT,$DomainDN"
        Description    = "Soporte Técnico"
    },
    @{
        SamAccountName = "sql_svc"
        Name           = "SQL Service"
        GivenName      = "SQL"
        Surname        = "Service"
        Password       = "SQLService2024!"
        Path           = "OU=CuentasServicio,$DomainDN"
        Description    = "Cuenta de servicio MSSQL"
    },
    @{
        SamAccountName = "iis_svc"
        Name           = "IIS Service"
        GivenName      = "IIS"
        Surname        = "Service"
        Password       = "IISService2024!"
        Path           = "OU=CuentasServicio,$DomainDN"
        Description    = "Cuenta de servicio IIS"
    },
    @{
        SamAccountName = "backup_svc"
        Name           = "Backup Service"
        GivenName      = "Backup"
        Surname        = "Service"
        Password       = "Backup2024!"
        Path           = "OU=CuentasServicio,$DomainDN"
        Description    = "Backup Service - pwd temporal: Backup2024! (pendiente cambio)"
    }
)

foreach ($user in $Users) {
    try {
        $secPwd = ConvertTo-SecureString $user.Password -AsPlainText -Force
        New-ADUser `
            -SamAccountName $user.SamAccountName `
            -Name $user.Name `
            -GivenName $user.GivenName `
            -Surname $user.Surname `
            -AccountPassword $secPwd `
            -Path $user.Path `
            -Description $user.Description `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -ErrorAction Stop
        Write-Host "    [+] Usuario creado: $($user.SamAccountName) / $($user.Password)" -ForegroundColor Green
    } catch {
        Write-Host "    [*] Usuario ya existe: $($user.SamAccountName)" -ForegroundColor Yellow
        # Actualizar contraseña y descripción por si acaso
        Set-ADAccountPassword -Identity $user.SamAccountName -NewPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force) -Reset -ErrorAction SilentlyContinue
        Set-ADUser -Identity $user.SamAccountName -Description $user.Description -ErrorAction SilentlyContinue
    }
}

# Añadir ceo.martinez a Remote Management Users
try {
    Add-ADGroupMember -Identity "S-1-5-32-580" -Members "ceo.martinez" -ErrorAction Stop
    Write-Host "    [+] ceo.martinez añadido a Remote Management Users" -ForegroundColor Green
} catch {
    Write-Host "    [*] ceo.martinez ya está en Remote Management Users" -ForegroundColor Yellow
}

# Añadir cuentas de servicio a Remote Management Users (para WinRM en DC-01)
$winrmAccounts = @("sql_svc", "iis_svc", "helpdesk.ruiz")
foreach ($account in $winrmAccounts) {
    try {
        # Buscar grupo por nombre en español
        $groupName = (net localgroup | Select-String "administraci" | Select-Object -First 1).ToString().Trim().TrimStart('*')
        if (-not $groupName) { $groupName = "Remote Management Users" }
        net localgroup $groupName "$account" /add 2>$null | Out-Null
        Write-Host "    [+] $account añadido a grupo WinRM" -ForegroundColor Green
    } catch {
        Write-Host "    [*] $account ya está en grupo WinRM o error: $_" -ForegroundColor Yellow
    }
}

# Crear C:\Temp con permisos Everyone (para uploads de herramientas)
try {
    New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null
    icacls "C:\Temp" /grant "Everyone:(OI)(CI)F" | Out-Null
    Write-Host "    [+] C:\Temp creado con permisos Everyone" -ForegroundColor Green
} catch {
    Write-Host "    [*] C:\Temp ya existe" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 3 — Vulnerabilidad 1: AS-REP Roasting
# T1558.004 — Steal or Forge Kerberos Tickets: AS-REP Roasting
# Condición: ceo.martinez no requiere preautenticación Kerberos
#            → cualquier usuario puede solicitar TGT → crack offline
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 3 — Configurando AS-REP Roasting (ceo.martinez)..." -ForegroundColor Yellow

try {
    Set-ADAccountControl -Identity "ceo.martinez" -DoesNotRequirePreAuth $true
    Write-Host "    [+] PreAuth deshabilitada en ceo.martinez (AS-REP Roasting)" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 4 — Vulnerabilidad 2: Kerberoasting + Password en Desc
# T1558.003 — Kerberoasting
# T1087.002 — Account Discovery: Domain Account
# Condición: backup_svc tiene SPN + es DA + password en descripción
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 4 — Configurando Kerberoasting (backup_svc)..." -ForegroundColor Yellow

try {
    $spn = "MSSQLSvc/DC-01.atackcorp.local:1433"
    Set-ADUser "backup_svc" -ServicePrincipalNames @{Add = $spn}
    Write-Host "    [+] SPN registrado: $spn" -ForegroundColor Green

    # Añadir a Domain Admins (SID-512 universal)
    $daGroup = Get-ADGroup -Filter {SID -eq "S-1-5-21-$($DomainSID.Split('-')[1..6] -join '-')-512"} -ErrorAction SilentlyContinue
    if (-not $daGroup) {
        $daGroup = Get-ADGroup -Filter {GroupCategory -eq 'Security' -and GroupScope -eq 'Global'} | Where-Object {$_.SID -like "*-512"}
    }
    Add-ADGroupMember -Identity $daGroup -Members "backup_svc" -ErrorAction SilentlyContinue
    Write-Host "    [+] backup_svc añadido a Domain Admins" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 5 — Vulnerabilidad 3: DCSync ACL Abuse
# T1003.006 — OS Credential Dumping: DCSync
# Condición: ceo.martinez tiene permisos de replicación
#            → impacket-secretsdump → hash NTLM Administrator
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 5 — Configurando DCSync ACL (ceo.martinez)..." -ForegroundColor Yellow

try {
    $userSID = (Get-ADUser "ceo.martinez").SID
    $acl     = Get-Acl "AD:\$DomainDN"

    $guidGetChanges         = [GUID]"1131f6aa-9c07-11d1-f79f-00c04fc2dcd2"
    $guidGetChangesAll      = [GUID]"1131f6ab-9c07-11d1-f79f-00c04fc2dcd2"
    $guidGetChangesFiltered = [GUID]"89e95b76-444d-4c62-991a-0facbeda640c"

    $adRights      = [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight
    $adType        = [System.Security.AccessControl.AccessControlType]::Allow
    $adInheritance = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None

    foreach ($guid in @($guidGetChanges, $guidGetChangesAll, $guidGetChangesFiltered)) {
        $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
            $userSID, $adRights, $adType, $guid, $adInheritance
        )
        $acl.AddAccessRule($rule)
    }
    Set-Acl "AD:\$DomainDN" $acl
    Write-Host "    [+] Permisos DCSync asignados a ceo.martinez" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 6 — Vulnerabilidad 4: Unconstrained Delegation
# T1558.001 — Golden Ticket / Delegation Abuse
# Condición: sql_svc tiene TrustedForDelegation
#            → cualquier usuario que autentique contra sql_svc
#            → TGT del usuario cacheado en memoria de sql_svc
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 6 — Configurando Unconstrained Delegation (sql_svc)..." -ForegroundColor Yellow

try {
    Set-ADAccountControl -Identity "sql_svc" -TrustedForDelegation $true
    Write-Host "    [+] Unconstrained Delegation habilitada en sql_svc" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 7 — Vulnerabilidad 5: Constrained Delegation (S4U2Proxy)
# T1558.001 — Kerberos Delegation Abuse
# Condición: iis_svc puede delegar a CIFS/DC-01 en nombre de cualquier usuario
#            → S4U2Self + S4U2Proxy → TGS como cualquier usuario
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 7 — Configurando Constrained Delegation (iis_svc)..." -ForegroundColor Yellow

try {
    Set-ADAccountControl -Identity "iis_svc" -TrustedToAuthForDelegation $true
    Set-ADUser "iis_svc" -Add @{'msDS-AllowedToDelegateTo'=@("MSSQLSvc/dc01.atackcorp.local:1433","MSSQLSvc/dc01")}
    Write-Host "    [+] Constrained Delegation (S4U2Proxy) habilitada en iis_svc → MSSQLSvc/dc01:1433" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 8 — OU IT + WKSTN-01 + GPO IT-Baseline link
# Prerequisito para GPO Abuse (Fase 12)
# Condición: WKSTN-01 en OU IT → GPO IT-Baseline aplicada
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 8 — Configurando OU IT y vinculación WKSTN-01..." -ForegroundColor Yellow

try {
    # Crear OU IT bajo Corporativo si no existe
    try {
        New-ADOrganizationalUnit -Name "IT" -Path "OU=Corporativo,$DomainDN" -ErrorAction Stop
        Write-Host "    [+] OU IT creada bajo Corporativo" -ForegroundColor Green
    } catch {
        Write-Host "    [*] OU IT ya existe bajo Corporativo" -ForegroundColor Yellow
    }

    # Mover WKSTN-01 al OU IT si existe
    $wkstn = Get-ADComputer "WKSTN-01" -ErrorAction SilentlyContinue
    if ($wkstn) {
        Move-ADObject -Identity $wkstn.DistinguishedName -TargetPath "OU=IT,OU=Corporativo,$DomainDN" -ErrorAction SilentlyContinue
        Write-Host "    [+] WKSTN-01 movida a OU=IT,OU=Corporativo" -ForegroundColor Green
    } else {
        Write-Host "    [*] WKSTN-01 no encontrada — vincular manualmente cuando se una al dominio" -ForegroundColor Yellow
    }
} catch {
    Write-Host "    [!] Error: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 9 — Vulnerabilidad 6: GPO Abuse
# T1484.001 — Domain Policy Modification: Group Policy
# Condición: helpdesk.ruiz tiene FullControl sobre GPO IT-Baseline
#            → modificar GPO → ejecutar código como SYSTEM en equipos del OU IT
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 8 — Configurando GPO Abuse (helpdesk.ruiz)..." -ForegroundColor Yellow

try {
    # Crear GPO IT-Baseline si no existe
    $GPO = Get-GPO -Name "IT-Baseline" -ErrorAction SilentlyContinue
    if (-not $GPO) {
        $GPO = New-GPO -Name "IT-Baseline"
        New-GPLink -Name "IT-Baseline" -Target "OU=IT,OU=Corporativo,$DomainDN" | Out-Null
        Write-Host "    [+] GPO IT-Baseline creada y vinculada a OU=IT,OU=Corporativo" -ForegroundColor Green
    } else {
        Write-Host "    [*] GPO IT-Baseline ya existe" -ForegroundColor Yellow
    }

    # Asignar FullControl a helpdesk.ruiz sobre la GPO
    $GPOPath = "AD:\CN={$($GPO.Id)},CN=Policies,CN=System,$DomainDN"
    $helpdeskSID = (Get-ADUser "helpdesk.ruiz").SID
    $acl = Get-Acl $GPOPath

    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $helpdeskSID,
        [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,
        [System.Security.AccessControl.AccessControlType]::Allow
    )
    $acl.AddAccessRule($rule)
    Set-Acl $GPOPath $acl
    Write-Host "    [+] helpdesk.ruiz tiene FullControl sobre IT-Baseline GPO" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 10 — Vulnerabilidad 7: ACL Abuse (GenericWrite)
# T1098 — Account Manipulation
# Condición: fin.garcia tiene GenericWrite sobre sql_svc
#            → puede modificar atributos de sql_svc
#            → añadir SPN → Kerberoast sql_svc
#            → o añadirse a grupos de sql_svc
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 10 — Configurando ACL Abuse (fin.garcia → sql_svc)..." -ForegroundColor Yellow

try {
    $finGarciaSID = (Get-ADUser "fin.garcia").SID
    $sqlSvcDN     = (Get-ADUser "sql_svc").DistinguishedName
    $acl          = Get-Acl "AD:\$sqlSvcDN"

    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $finGarciaSID,
        [System.DirectoryServices.ActiveDirectoryRights]::GenericWrite,
        [System.Security.AccessControl.AccessControlType]::Allow
    )
    $acl.AddAccessRule($rule)
    Set-Acl "AD:\$sqlSvcDN" $acl
    Write-Host "    [+] fin.garcia tiene GenericWrite sobre sql_svc" -ForegroundColor Green
} catch {
    Write-Host "    [!] Error: $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 11 — Verificación final del escenario
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[*] BLOQUE 11 — Verificación del escenario..." -ForegroundColor Yellow

# AS-REP Roasting
$asrep = Get-ADUser "ceo.martinez" -Properties DoesNotRequirePreAuth
if ($asrep.DoesNotRequirePreAuth) {
    Write-Host "    [+] AS-REP Roasting: ceo.martinez sin preauth ✅" -ForegroundColor Green
} else {
    Write-Host "    [!] AS-REP Roasting: NO configurado" -ForegroundColor Red
}

# Kerberoasting
$spns = (Get-ADUser "backup_svc" -Properties ServicePrincipalName).ServicePrincipalName
if ($spns) {
    Write-Host "    [+] Kerberoasting: backup_svc SPN = $($spns -join ', ') ✅" -ForegroundColor Green
} else {
    Write-Host "    [!] Kerberoasting: SPN no encontrado" -ForegroundColor Red
}

# Unconstrained Delegation
$uncons = Get-ADUser "sql_svc" -Properties TrustedForDelegation
if ($uncons.TrustedForDelegation) {
    Write-Host "    [+] Unconstrained Delegation: sql_svc ✅" -ForegroundColor Green
} else {
    Write-Host "    [!] Unconstrained Delegation: NO configurado" -ForegroundColor Red
}

# Constrained Delegation
$cons = Get-ADUser "iis_svc" -Properties 'msDS-AllowedToDelegateTo'
if ($cons.'msDS-AllowedToDelegateTo') {
    Write-Host "    [+] Constrained Delegation: iis_svc → $($cons.'msDS-AllowedToDelegateTo' -join ', ') ✅" -ForegroundColor Green
} else {
    Write-Host "    [!] Constrained Delegation: NO configurado" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────
# RESUMEN FINAL — Kill Chains disponibles
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ESCENARIO LISTO — Kill Chains disponibles" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  CREDENCIALES:" -ForegroundColor White
Write-Host "    ceo.martinez  : Direccion2024!" -ForegroundColor Gray
Write-Host "    backup_svc    : Backup2024! (en descripción)" -ForegroundColor Gray
Write-Host "    fin.garcia    : Finance2024!" -ForegroundColor Gray
Write-Host "    helpdesk.ruiz : Helpdesk2024!" -ForegroundColor Gray
Write-Host "    sql_svc       : SQLService2024!" -ForegroundColor Gray
Write-Host "    iis_svc       : IISService2024!" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATH A  [AS-REP Roasting]          T1558.004" -ForegroundColor Magenta
Write-Host "    GetNPUsers → TGT ceo.martinez → crack → shell" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATH B  [Kerberoasting]             T1558.003" -ForegroundColor Magenta
Write-Host "    GetUserSPNs → TGS backup_svc → crack → DA" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATH C  [DCSync]                    T1003.006" -ForegroundColor Magenta
Write-Host "    secretsdump → hash Administrador → PTH → DA" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATH D  [Unconstrained Delegation]  T1558.001" -ForegroundColor Magenta
Write-Host "    Comprometer sql_svc → SpoolSample/PetitPotam → TGT DA" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATH E  [Constrained Delegation]    T1558.001" -ForegroundColor Magenta
Write-Host "    Comprometer iis_svc → S4U2Self/Proxy → TGS como DA" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATH F  [GPO Abuse]                 T1484.001" -ForegroundColor Magenta
Write-Host "    helpdesk.ruiz → modificar IT-Baseline GPO → RCE como SYSTEM" -ForegroundColor Gray
Write-Host ""
Write-Host "  PATH G  [ACL Abuse]                 T1098" -ForegroundColor Magenta
Write-Host "    fin.garcia → GenericWrite sql_svc → SPN → Kerberoast → DA" -ForegroundColor Gray
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Listo — volver a Kali y atacar" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
