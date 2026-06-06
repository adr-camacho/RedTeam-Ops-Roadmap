#Requires -RunAsAdministrator
<#
.SYNOPSIS Crown Jewels — Lab-05 SILVER CHAIN (APT28)
.NOTES Ejecutar en DC-01. Requiere Lab-01 setup completado.
       Crown Jewels: cuentas con permisos para RBCD + Shadow Credentials abuse
#>
$ErrorActionPreference = "SilentlyContinue"
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor DarkMagenta
Write-Host "║    SILVER CHAIN — Crown Jewels Provisioning     ║" -ForegroundColor DarkMagenta
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor DarkMagenta

# BLOQUE 1 — Cuenta con GenericWrite sobre WKSTN-01 (RBCD target)
Write-Host "[*] Configurando GenericWrite para RBCD abuse..." -ForegroundColor Yellow
try {
    $wkstn = Get-ADComputer "WKSTN-01"
    $helpdesk = Get-ADUser "helpdesk.ruiz"
    $acl = Get-Acl "AD:\$($wkstn.DistinguishedName)"
    $sid = $helpdesk.SID
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $sid, "WriteProperty,GenericWrite", "Allow",
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None)
    $acl.AddAccessRule($ace)
    Set-Acl "AD:\$($wkstn.DistinguishedName)" $acl
    Write-Host "    [+] helpdesk.ruiz tiene GenericWrite sobre WKSTN-01 → RBCD abuse" -ForegroundColor Green
} catch { Write-Host "    [!] Error RBCD setup: $_" -ForegroundColor Red }

# BLOQUE 2 — Cuenta con GenericWrite sobre iis_svc (Shadow Credentials target)
Write-Host "[*] Configurando GenericWrite para Shadow Credentials..." -ForegroundColor Yellow
try {
    $iisSvc = Get-ADUser "iis_svc"
    $finGarcia = Get-ADUser "fin.garcia"
    $acl = Get-Acl "AD:\$($iisSvc.DistinguishedName)"
    $sid = $finGarcia.SID
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $sid, "WriteProperty", "Allow",
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None,
        [System.Guid]"5b47d60f-6090-40b2-9f37-2a4de88f3063")  # ms-DS-Key-Credential-Link
    $acl.AddAccessRule($ace)
    Set-Acl "AD:\$($iisSvc.DistinguishedName)" $acl
    Write-Host "    [+] fin.garcia puede escribir msDS-KeyCredentialLink de iis_svc → Shadow Credentials" -ForegroundColor Green
} catch { Write-Host "    [!] Error Shadow Creds setup: $_" -ForegroundColor Red }

# BLOQUE 3 — Datos de alto valor protegidos (accesibles solo como DA o con Silver Ticket)
Write-Host "[*] Creando datos protegidos por Kerberos (Silver Ticket target)..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\CorporateData\Confidential-SQL" -Force | Out-Null
@"
ATACKCORP — DATOS CONFIDENCIALES SQL SERVER
============================================
Tabla: AppCredentials (AtackCorpDB)
  ERP: erp_admin / ERPadmin2026!
  CRM: crm_user / CRMpass2024!
  VPN: vpn_admin / VPNgw2026!xK

Conexion SQL: Server=DC-01;Database=AtackCorpDB;User=sa;Password=SQLsa2026!
CROWN JEWEL: Acceder como Administrador via Silver Ticket → MSSQLSvc/dc01:1433
"@ | Out-File "C:\CorporateData\Confidential-SQL\sql_crown_jewel.txt" -Encoding UTF8

# Crear share solo accesible con privilegios de DA (Silver Ticket objetivo)
try {
    New-SmbShare -Name "SQL-Confidential" -Path "C:\CorporateData\Confidential-SQL" `
      -NoAccess "Everyone" `
      -FullAccess "ATACKCORP\Admins. del dominio" -ErrorAction Stop | Out-Null
    Write-Host "    [+] Share SQL-Confidential creado (solo DA — Silver Ticket objetivo)" -ForegroundColor Green
} catch { Write-Host "    [*] Share ya existe" -ForegroundColor Yellow }

# BLOQUE 4 — MachineAccountQuota verificación (necesario para RBCD)
Write-Host "[*] Verificando MachineAccountQuota..." -ForegroundColor Yellow
$maq = (Get-ADDomain).Properties["ms-DS-MachineAccountQuota"]
if (-not $maq) { $maq = 10 }
Write-Host "    [+] MachineAccountQuota: $maq (usuarios pueden crear cuentas de maquina para RBCD)" -ForegroundColor Green

# RESUMEN
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor DarkMagenta
Write-Host " CROWN JEWELS — Lab-05 SILVER CHAIN" -ForegroundColor DarkMagenta
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor DarkMagenta
Write-Host "  #1 GenericWrite WKSTN-01        helpdesk.ruiz → RBCD → admin WKSTN-01" -ForegroundColor Cyan
Write-Host "  #2 msDS-KeyCredentialLink       fin.garcia → Shadow Creds → iis_svc" -ForegroundColor Cyan
Write-Host "  #3 Share SQL-Confidential       solo DA — Silver Ticket MSSQLSvc objetivo" -ForegroundColor Cyan
Write-Host "  #4 MachineAccountQuota: $maq   necesario para crear cuenta RBCD" -ForegroundColor Cyan
Write-Host " OBJETIVO: RBCD → admin WKSTN-01 | Shadow Creds → iis_svc | Silver Ticket → SQL" -ForegroundColor Yellow
Write-Host " DATOS FICTICIOS — SOLO USO EDUCATIVO" -ForegroundColor DarkGray
