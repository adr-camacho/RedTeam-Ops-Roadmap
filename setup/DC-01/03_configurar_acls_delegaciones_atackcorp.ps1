# 03_configurar_acls_delegaciones_atackcorp.ps1
# Maquina: DC-01 | Version: 2.1 | Junio 2026
# FIX v2.1: Import-Module AD antes de Get-ADDomain en WriteDACL dominio
#            WKSTN-01: re-ejecutar si no esta en AD

if ($env:COMPUTERNAME -ne "DC-01") { Write-Warning "Ejecutar en DC-01"; exit 1 }
Import-Module ActiveDirectory

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  DC-01: ACLs vulnerables y delegaciones" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

try {
    $finGarcia = (Get-ADUser "fin.garcia").SID
    $sqlSvc = Get-ADUser "sql_svc" -Properties DistinguishedName
    $acl = Get-Acl "AD:\$($sqlSvc.DistinguishedName)"
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($finGarcia,[System.DirectoryServices.ActiveDirectoryRights]::GenericWrite,[System.Security.AccessControl.AccessControlType]::Allow)
    $acl.AddAccessRule($rule); Set-Acl "AD:\$($sqlSvc.DistinguishedName)" $acl
    Write-Host "    [!] fin.garcia GenericWrite sobre sql_svc" -ForegroundColor Red
} catch { Write-Host "    [!] Error GenericWrite: $_" -ForegroundColor Red }

$wkstn = Get-ADComputer "WKSTN-01" -ErrorAction SilentlyContinue
if ($wkstn) {
    try {
        $helpdesk = (Get-ADUser "helpdesk.ruiz").SID
        $acl = Get-Acl "AD:\$($wkstn.DistinguishedName)"
        $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($helpdesk,[System.DirectoryServices.ActiveDirectoryRights]::WriteDacl,[System.Security.AccessControl.AccessControlType]::Allow)
        $acl.AddAccessRule($rule); Set-Acl "AD:\$($wkstn.DistinguishedName)" $acl
        Write-Host "    [!] helpdesk.ruiz WriteDACL sobre WKSTN-01" -ForegroundColor Red
    } catch { Write-Host "    [!] Error WriteDACL WKSTN-01: $_" -ForegroundColor Red }
} else { Write-Host "    [!] WKSTN-01 no encontrada — re-ejecutar tras unirla al dominio" -ForegroundColor Yellow }

try {
    $domain = Get-ADDomain
    $finGarcia = (Get-ADUser "fin.garcia").SID
    $acl = Get-Acl "AD:\$($domain.DistinguishedName)"
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($finGarcia,"WriteDacl","Allow",[System.DirectoryServices.ActiveDirectorySecurityInheritance]::None)
    $acl.AddAccessRule($ace); Set-Acl "AD:\$($domain.DistinguishedName)" $acl
    Write-Host "    [!] fin.garcia WriteDACL sobre dominio (DCSync path)" -ForegroundColor Red
} catch { Write-Host "    [!] Error WriteDACL dominio: $_" -ForegroundColor Red }

Set-ADAccountControl -Identity "sql_svc" -TrustedForDelegation $true
Write-Host "    [!] Unconstrained Delegation: sql_svc" -ForegroundColor Red

Set-ADUser -Identity "iis_svc" -Add @{"msDS-AllowedToDelegateTo"="MSSQLSvc/DC-01.atackcorp.local:1433"}
Set-ADAccountControl -Identity "iis_svc" -TrustedToAuthForDelegation $true
Write-Host "    [!] Constrained Delegation: iis_svc -> MSSQLSvc" -ForegroundColor Red

try {
    $gpo = Get-GPO -Name "IT-Baseline" -ErrorAction SilentlyContinue
    if (-not $gpo) {
        $gpo = New-GPO -Name "IT-Baseline"
        New-GPLink -Name "IT-Baseline" -Target "OU=IT,DC=atackcorp,DC=local" | Out-Null
        Write-Host "    [+] GPO IT-Baseline creada" -ForegroundColor Green
    }
    $gpoGuid = "{$($gpo.Id)}"
    $helpdesk = (Get-ADUser "helpdesk.ruiz").SID
    $acl = Get-Acl "AD:\CN=$gpoGuid,CN=Policies,CN=System,DC=atackcorp,DC=local"
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($helpdesk,[System.DirectoryServices.ActiveDirectoryRights]::WriteDacl,[System.Security.AccessControl.AccessControlType]::Allow)
    $acl.AddAccessRule($rule); Set-Acl "AD:\CN=$gpoGuid,CN=Policies,CN=System,DC=atackcorp,DC=local" $acl
    Write-Host "    [!] helpdesk.ruiz WriteDACL sobre GPO IT-Baseline ($gpoGuid)" -ForegroundColor Red
} catch { Write-Host "    [!] Error GPO: $_" -ForegroundColor Red }

Write-Host "[OK] Script 03 completado." -ForegroundColor Green
