# 10_configurar_forest_trusts_sid_filtering.ps1
# Maquina: DC-01 | Version: 2.0 | Junio 2026
# FIX v2.0: Reescrito con .NET (netdom /quarantine falla en WS2025)
#            New-ADTrust no existe en WS2025
#            DNS Conditional Forwarders incluidos

if ($env:COMPUTERNAME -ne "DC-01") { Write-Warning "Ejecutar en DC-01"; exit 1 }
Import-Module ActiveDirectory

Write-Host "================================================" -ForegroundColor DarkCyan
Write-Host "  DC-01: Forest Trusts + SID Filtering OFF" -ForegroundColor DarkCyan
Write-Host "================================================" -ForegroundColor DarkCyan

$forwarders = @(
    @{Zone="corp.local"; IP="10.0.2.11"},
    @{Zone="ext.local";  IP="10.0.2.14"}
)
foreach ($f in $forwarders) {
    try {
        Add-DnsServerConditionalForwarderZone -Name $f.Zone -MasterServers $f.IP -PassThru | Out-Null
        Write-Host "    [+] DNS Forwarder: $($f.Zone) -> $($f.IP)" -ForegroundColor Green
    } catch { Write-Host "    [i] Forwarder $($f.Zone) ya existe" -ForegroundColor Cyan }
}

$localDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$forests = @(
    @{Name="corp.local"; AdminPass="NuevaPassword2026!"},
    @{Name="ext.local";  AdminPass="NuevaPassword2026!"}
)

foreach ($f in $forests) {
    try {
        $prefix = $f.Name.Split('.')[0]
        $ctx = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain", $f.Name, "$prefix\Administrador", $f.AdminPass)
        $remoteDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($ctx)
        $localDomain.CreateTrustRelationship($remoteDomain, "Bidirectional")
        Write-Host "    [+] Trust: atackcorp.local <-> $($f.Name)" -ForegroundColor Green
    } catch {
        if ($_.Exception.Message -match "ya existe|already exists") {
            Write-Host "    [i] Trust ya existe: $($f.Name)" -ForegroundColor Cyan
        } else { Write-Host "    [!] Error trust $($f.Name): $_" -ForegroundColor Red }
    }
}

$localDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
foreach ($f in $forests) {
    try {
        $prefix = $f.Name.Split('.')[0]
        $ctx = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain", $f.Name, "$prefix\Administrador", $f.AdminPass)
        $remoteDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($ctx)
        $localDomain.SetSidFilteringStatus($remoteDomain, $false)
        Write-Host "    [!] SID Filtering OFF: $($f.Name)" -ForegroundColor Red
    } catch { Write-Host "    [!] Error SID Filtering $($f.Name): $_" -ForegroundColor Yellow }
}

Get-ADTrust -Filter * | Select-Object Name, Direction, SIDFilteringQuarantined | Format-Table
Write-Host "[OK] Script 10 completado." -ForegroundColor Green
