#Requires -RunAsAdministrator
<#
.SYNOPSIS Crown Jewels — Lab-04 IRON FOREST (APT28)
.NOTES Ejecutar en DC-01 tras Setup-Lab01-GhostForest-v2.ps1
#>
$ErrorActionPreference = "SilentlyContinue"
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor DarkYellow
Write-Host "║     IRON FOREST — Crown Jewels Provisioning     ║" -ForegroundColor DarkYellow
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor DarkYellow

# BLOQUE 1 — Directorios
Write-Host "[*] Creando estructura de datos corporativos..." -ForegroundColor Yellow
$dirs = @("C:\CorporateData\IT\Scripts","C:\CorporateData\Finance\Reports",
          "C:\CorporateData\HR\Confidential","C:\SharedData","C:\Temp\IT-Scripts")
foreach ($d in $dirs) { New-Item -ItemType Directory -Path $d -Force | Out-Null }

# BLOQUE 2 — Credenciales en scripts IT (credential hunting target)
Write-Host "[*] Creando scripts IT con credenciales embebidas..." -ForegroundColor Yellow
@"
# Script de backup automático — Dept IT
# Ejecutar como SYSTEM via tarea programada
`$SQLServer = "DC-01\SQLEXPRESS"
`$SQLUser = "sa"
`$SQLPass = "SQLsa2026!"          # TODO: mover a vault
`$BackupPath = "\\DC-01\Backups"
`$BackupUser = "backup_svc"
`$BackupPass = "Backup2024!"
net use `$BackupPath /user:ATACKCORP\`$BackupUser `$BackupPass
Invoke-Sqlcmd -ServerInstance `$SQLServer -Username `$SQLUser -Password `$SQLPass -Query "BACKUP DATABASE AtackCorpDB TO DISK='`$BackupPath\backup.bak'"
"@ | Out-File "C:\CorporateData\IT\Scripts\backup_database.ps1" -Encoding UTF8

@"
# Deployment script — last updated 15/03/2026
# Credenciales servicio IIS — cambiar antes del 01/07
`$IISUser = "ATACKCORP\iis_svc"
`$IISPass = "IISService2024!"
`$SQLConnStr = "Server=DC-01;Database=AtackCorpDB;User=webapp_db;Password=WebappDB2024!"
# Deploy nueva version webapp
Stop-WebSite -Name "Default Web Site"
# ... deploy logic
Start-WebSite -Name "Default Web Site"
"@ | Out-File "C:\CorporateData\IT\Scripts\deploy_webapp.ps1" -Encoding UTF8
Write-Host "    [+] Scripts IT con credenciales creados" -ForegroundColor Green

# BLOQUE 3 — Historial PowerShell con credenciales
Write-Host "[*] Creando historial PS con credenciales..." -ForegroundColor Yellow
$histPath = "C:\Users\Administrador.DC-01\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine"
New-Item -ItemType Directory -Path $histPath -Force | Out-Null
@"
net use \\NAS-01\Backups /user:ATACKCORP\backup_svc Backup2024!
Invoke-Sqlcmd -ServerInstance DC-01\SQLEXPRESS -Username sa -Password SQLsa2026!
Set-ADAccountPassword -Identity fin.garcia -NewPassword (ConvertTo-SecureString "Finance2024!" -AsPlainText -Force)
impacket-secretsdump atackcorp.local/Administrador:'NuevaPassword2026!'@10.0.2.10
"@ | Out-File "$histPath\ConsoleHost_history.txt" -Encoding UTF8
Write-Host "    [+] Historial PS creado" -ForegroundColor Green

# BLOQUE 4 — Datos financieros con permisos abusables (WriteDACL target)
Write-Host "[*] Configurando shares con ACLs vulnerables..." -ForegroundColor Yellow
@"
ATACKCORP — REPORTE FINANCIERO Q1 2026 — CONFIDENCIAL
=====================================================
Ingresos Q1: 750.000 EUR
EBITDA Q1:   112.500 EUR
Contratos nuevos: Tech Solutions Madrid (120.000 EUR), Farmaceutica Levante (200.000 EUR)
PROYECCION Q2: 800.000 EUR (pendiente firma contrato Constructora Norte)
"@ | Out-File "C:\CorporateData\Finance\Reports\Q1_2026_Confidential.txt" -Encoding UTF8

try {
    New-SmbShare -Name "IT-Scripts" -Path "C:\CorporateData\IT\Scripts" `
      -Description "Scripts IT internos" `
      -ReadAccess "ATACKCORP\Usuarios del dominio" `
      -FullAccess "ATACKCORP\Admins. del dominio" -ErrorAction Stop | Out-Null
    Write-Host "    [+] Share \\DC-01\IT-Scripts creado (todos los usuarios — credential hunting)" -ForegroundColor Green
} catch { Write-Host "    [*] Share IT-Scripts ya existe" -ForegroundColor Yellow }

# BLOQUE 5 — Objeto AD con WriteDACL mal configurado
Write-Host "[*] Configurando ACL vulnerable (WriteDACL para fin.garcia sobre dominio)..." -ForegroundColor Yellow
try {
    $domain = Get-ADDomain
    $finGarcia = Get-ADUser "fin.garcia"
    $domainDN = $domain.DistinguishedName
    $acl = Get-Acl "AD:\$domainDN"
    $sid = $finGarcia.SID
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $sid, "WriteDacl", "Allow", [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None)
    $acl.AddAccessRule($ace)
    Set-Acl "AD:\$domainDN" $acl
    Write-Host "    [+] fin.garcia tiene WriteDACL sobre el dominio (DCSync via ACL abuse)" -ForegroundColor Green
} catch { Write-Host "    [!] Error configurando WriteDACL: $_" -ForegroundColor Red }

# RESUMEN
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor DarkYellow
Write-Host " CROWN JEWELS — Lab-04 IRON FOREST" -ForegroundColor DarkYellow
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor DarkYellow
Write-Host "  #1 Scripts IT con credenciales  C:\CorporateData\IT\Scripts\" -ForegroundColor Cyan
Write-Host "  #2 Historial PS con credenciales ConsoleHost_history.txt" -ForegroundColor Cyan
Write-Host "  #3 Reporte financiero Q1        C:\CorporateData\Finance\Reports\" -ForegroundColor Cyan
Write-Host "  #4 Share IT-Scripts             \\DC-01\IT-Scripts (lectura todos)" -ForegroundColor Cyan
Write-Host "  #5 WriteDACL fin.garcia         sobre objeto dominio → DCSync" -ForegroundColor Cyan
Write-Host " OBJETIVO: WriteDACL → DCSync | credential hunting → lateral movement" -ForegroundColor Yellow
Write-Host " DATOS FICTICIOS — SOLO USO EDUCATIVO" -ForegroundColor DarkGray
