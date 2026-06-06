# =============================================================
# SCRIPT 03 — Configuración de ACLs vulnerables y delegaciones
# Ejecutar: PowerShell como Administrador del dominio
# Máquina: DC-01
# Prerequisito: Script 02 ejecutado
# =============================================================

Import-Module ActiveDirectory

Write-Host "`n[*] Configurando ACLs abusables..." -ForegroundColor Cyan

# ── GenericWrite: fin.garcia sobre sql_svc ───────────────────
$finGarcia = (Get-ADUser "fin.garcia").SID
$sqlSvc    = Get-ADUser "sql_svc" -Properties DistinguishedName
$acl       = Get-Acl "AD:\$($sqlSvc.DistinguishedName)"
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $finGarcia,
    [System.DirectoryServices.ActiveDirectoryRights]::GenericWrite,
    [System.Security.AccessControl.AccessControlType]::Allow
)
$acl.AddAccessRule($rule)
Set-Acl "AD:\$($sqlSvc.DistinguishedName)" $acl
Write-Host "[!] ACL: fin.garcia tiene GenericWrite sobre sql_svc" -ForegroundColor Red

# ── WriteDACL: helpdesk.ruiz sobre WKSTN-01 ─────────────────
$helpdesk = (Get-ADUser "helpdesk.ruiz").SID
$wkstn    = Get-ADComputer "WKSTN-01" -Properties DistinguishedName -ErrorAction SilentlyContinue

if ($wkstn) {
    $acl2 = Get-Acl "AD:\$($wkstn.DistinguishedName)"
    $rule2 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $helpdesk,
        [System.DirectoryServices.ActiveDirectoryRights]::WriteDacl,
        [System.Security.AccessControl.AccessControlType]::Allow
    )
    $acl2.AddAccessRule($rule2)
    Set-Acl "AD:\$($wkstn.DistinguishedName)" $acl2
    Write-Host "[!] ACL: helpdesk.ruiz tiene WriteDACL sobre WKSTN-01" -ForegroundColor Red
} else {
    Write-Host "[!] WKSTN-01 no encontrada en AD. Une la workstation al dominio y re-ejecuta." -ForegroundColor Yellow
}

Write-Host "`n[*] Configurando delegaciones Kerberos..." -ForegroundColor Cyan

# ── Unconstrained Delegation: sql_svc ───────────────────────
Set-ADAccountControl -Identity "sql_svc" -TrustedForDelegation $true
Write-Host "[!] Delegación: Unconstrained Delegation habilitada en sql_svc" -ForegroundColor Red

# ── Constrained Delegation: iis_svc → MSSQL ─────────────────
Set-ADUser -Identity "iis_svc" -Add @{
    'msDS-AllowedToDelegateTo' = 'MSSQLSvc/dc01.atackcorp.local:1433'
}
Set-ADAccountControl -Identity "iis_svc" -TrustedToAuthForDelegation $true
Write-Host "[!] Delegación: Constrained Delegation (S4U2Proxy) habilitada en iis_svc" -ForegroundColor Red

Write-Host "`n[+] Script 03 completado." -ForegroundColor Green
