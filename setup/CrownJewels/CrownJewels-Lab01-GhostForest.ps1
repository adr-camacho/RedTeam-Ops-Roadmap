#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Crown Jewels Provisioning — Lab-01 GHOST FOREST
    Crea los activos de alto valor que APT29 buscaría en un engagement real.

.DESCRIPTION
    Este script crea datos ficticios pero realistas que simulan los "crown jewels"
    de una empresa mediana: base de datos financiera, documentos confidenciales,
    credenciales almacenadas, emails estratégicos y datos de clientes.
    
    IMPORTANTE: Todos los datos son completamente ficticios y de uso exclusivamente educativo.

.NOTES
    Operación:  GHOST FOREST
    Lab:        Lab-01
    Adversario: APT29 (Cozy Bear)
    Ejecutar:   En DC-01 como Administrador del dominio
    Requisito:  Setup-Lab01-GhostForest-v2.1.ps1 ejecutado previamente
#>

param(
    [string]$Domain = "atackcorp.local",
    [string]$DCName = "DC-01"
)

$ErrorActionPreference = "SilentlyContinue"

function Write-Banner {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║          GHOST FOREST — Crown Jewels Provisioning           ║" -ForegroundColor Red
    Write-Host "║              Lab-01 | APT29 Emulation Target                ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "[*] $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "    [+] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "    [i] $Message" -ForegroundColor Cyan
}

Write-Banner

# ─────────────────────────────────────────────────────────────
# BLOQUE 1 — Estructura de directorios corporativos
# ─────────────────────────────────────────────────────────────
Write-Step "BLOQUE 1 — Creando estructura de directorios corporativos..."

$dirs = @(
    "C:\CorporateData",
    "C:\CorporateData\Finance",
    "C:\CorporateData\Finance\2025",
    "C:\CorporateData\Finance\2026",
    "C:\CorporateData\Finance\Payroll",
    "C:\CorporateData\HR",
    "C:\CorporateData\HR\Employees",
    "C:\CorporateData\Legal",
    "C:\CorporateData\IT",
    "C:\CorporateData\IT\Credentials",
    "C:\CorporateData\Executive",
    "C:\CorporateData\Clients"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
Write-Success "Estructura de directorios creada"

# ─────────────────────────────────────────────────────────────
# BLOQUE 2 — Documentos financieros (Crown Jewel #1)
# Base de datos de nóminas y cuentas bancarias ficticias
# ─────────────────────────────────────────────────────────────
Write-Step "BLOQUE 2 — Creando documentos financieros..."

# Nóminas 2026
$nominas2026 = @"
ATACKCORP S.L. — NÓMINAS 2026 — CONFIDENCIAL
=============================================
Generado: 01/05/2026 | Responsable: fin.garcia@atackcorp.local

EMPLEADO               SALARIO_BRUTO   SALARIO_NETO   IBAN
ceo.martinez           95.000 EUR      68.400 EUR     ES76 2100 0418 6012 3456 7891
fin.garcia             58.000 EUR      42.760 EUR     ES91 2100 0418 6098 7654 3210
helpdesk.ruiz          32.000 EUR      24.320 EUR     ES23 0049 0001 9920 1234 5678
sql_svc (cuenta svc)   N/A             N/A            N/A
iis_svc (cuenta svc)   N/A             N/A            N/A

TOTAL MASA SALARIAL MENSUAL: 185.000 EUR
CUENTA EMPRESA (PAGOS): ES12 1234 1234 1612 3456 7890
ENTIDAD BANCARIA: Banco Santander — Oficina 0418 Zaragoza

*** DOCUMENTO ESTRICTAMENTE CONFIDENCIAL — USO INTERNO ***
*** Distribución no autorizada constituye delito — Art. 199 CP ***
"@
$nominas2026 | Out-File "C:\CorporateData\Finance\Payroll\nominas_2026_Q1Q2.txt" -Encoding UTF8
Write-Success "Nóminas 2026 creadas"

# Cuentas bancarias y contraseñas de banca online
$banking = @"
ATACKCORP S.L. — ACCESOS BANCA ONLINE — CONFIDENCIAL
====================================================
ENTIDAD: Banco Santander Business
URL: https://empresas.bancosantander.es
USUARIO: atackcorp_001
PASSWORD: Santander@2024Corp!
SEGUNDO FACTOR: SMS a +34 600 123 456

ENTIDAD: BBVA Empresas  
URL: https://empresas.bbva.es
USUARIO: ATCK-CORP-ES
PASSWORD: BBVAcorp2026$!
SEGUNDO FACTOR: Token físico SN: 4892-BBVA-7731

TRANSFERENCIAS > 50.000 EUR requieren autorización de ceo.martinez
Contacto gestor: carlos.vegas@santander.com | Tel: 976 XXX XXX
"@
$banking | Out-File "C:\CorporateData\Finance\accesos_banca_online.txt" -Encoding UTF8
Write-Success "Accesos bancarios creados"

# Presupuesto anual
$presupuesto = @"
ATACKCORP S.L. — PRESUPUESTO ANUAL 2026
=======================================
INGRESOS PROYECTADOS:
  Contratos recurrentes:    2.400.000 EUR
  Nuevos clientes:            600.000 EUR
  TOTAL INGRESOS:           3.000.000 EUR

GASTOS:
  Masa salarial:            2.220.000 EUR
  Infraestructura IT:         180.000 EUR
  Marketing:                   90.000 EUR
  Legal y compliance:          60.000 EUR
  TOTAL GASTOS:             2.550.000 EUR

BENEFICIO NETO PROYECTADO:   450.000 EUR

PROYECTOS ESTRATÉGICOS 2026:
  - Expansión a mercado alemán (inversión: 200.000 EUR)
  - Adquisición potencial TechStartup SL (valoración: 1.2M EUR)
  - Migración infraestructura a Azure (Q3 2026)
"@
$presupuesto | Out-File "C:\CorporateData\Finance\2026\presupuesto_anual_2026.txt" -Encoding UTF8
Write-Success "Presupuesto anual creado"

# ─────────────────────────────────────────────────────────────
# BLOQUE 3 — Datos de clientes (Crown Jewel #2)
# ─────────────────────────────────────────────────────────────
Write-Step "BLOQUE 3 — Creando base de datos de clientes..."

$clientes = @"
ATACKCORP S.L. — BASE DE DATOS CLIENTES — CONFIDENCIAL
======================================================
ID    EMPRESA                    CONTACTO              EMAIL                        CONTRATO      VALOR_ANUAL
001   Industrias Ibérica S.A.    Juan Pérez Martín     jperez@industriasib.com      ATCK-2024-001  85.000 EUR
002   Tech Solutions Madrid SL   Ana García López      agarcia@techsol.es           ATCK-2024-002  120.000 EUR
003   Grupo Hotelero Zaragoza    Miguel Torres Ruiz    mtorres@ghzaragoza.com       ATCK-2025-001  45.000 EUR
004   Farmacéutica Levante SA    Laura Sánchez Vila    lsanchez@farmalev.com        ATCK-2025-002  200.000 EUR
005   Constructora Norte SL      Carlos Jiménez Roca   cjimenez@consnorte.com       ATCK-2026-001  95.000 EUR

NDA VIGENTES: Todos los clientes tienen NDA firmado
RENOVACIONES PENDIENTES: Cliente 003 — vence 30/06/2026
CLIENTES EN NEGOCIACIÓN: 3 prospectos (valor estimado: 350.000 EUR)

*** DATO PROTEGIDO RGPD — TRATAMIENTO RESTRINGIDO ***
"@
$clientes | Out-File "C:\CorporateData\Clients\clientes_activos_2026.txt" -Encoding UTF8
Write-Success "Base de datos de clientes creada"

# ─────────────────────────────────────────────────────────────
# BLOQUE 4 — Credenciales IT almacenadas (Crown Jewel #3)
# ─────────────────────────────────────────────────────────────
Write-Step "BLOQUE 4 — Creando repositorio de credenciales IT..."

$credenciales = @"
ATACKCORP IT — CREDENCIALES DE INFRAESTRUCTURA
===============================================
ATENCION: Cambiar todas las passwords el 01/01 y 01/07

=== SERVIDORES ===
DC-01 (10.0.2.10)
  Administrador local: NuevaPassword2026!
  Cuenta de dominio:   ATACKCORP\Administrador

WKSTN-01 (10.0.2.8)  
  Admin local: Admin2026!
  Usuario: atackcorp\helpdesk.ruiz / Helpdesk2024!

=== SERVICIOS ===
SQL Server (DC-01\SQLEXPRESS)
  sa account: SQLsa2026!
  App user: sql_svc / SQLService2024!

IIS (DC-01)
  App Pool: iis_svc / IISService2024!
  
=== BACKUP ===
Backup solution: backup_svc / Backup2024!
Destino backup: \\NAS-01\Backups (credenciales en script)
NAS-01 admin: admin / NASadmin2026!

=== CLOUD ===
Azure subscription: atackcorp-prod
  Tenant ID: 12345678-abcd-efgh-ijkl-123456789012
  App registration: atackcorp-app / AppSecret2026!xK9
  
=== MONITORIZACIÓN ===
Zabbix: https://monitor.atackcorp.local
  Admin: zabbix / Zabbix@2026!

NOTA: Estas credenciales deben migrarse a CyberArk - pendiente Q3 2026
"@
$credenciales | Out-File "C:\CorporateData\IT\Credentials\infrastructure_creds.txt" -Encoding UTF8
Write-Success "Repositorio de credenciales IT creado"

# ─────────────────────────────────────────────────────────────
# BLOQUE 5 — Emails ejecutivos (Crown Jewel #4)
# ─────────────────────────────────────────────────────────────
Write-Step "BLOQUE 5 — Creando comunicaciones ejecutivas..."

$email_acquisition = @"
DE: ceo.martinez@atackcorp.local
PARA: board@atackcorp.local
CC: fin.garcia@atackcorp.local
ASUNTO: CONFIDENCIAL - Adquisición TechStartup SL
FECHA: 15/04/2026

Estimado consejo,

Tras las conversaciones mantenidas con los fundadores de TechStartup SL,
confirmo que la valoración final acordada es de 1.200.000 EUR.

La due diligence técnica ha sido satisfactoria. IT confirma que su
infraestructura es compatible con la nuestra.

PRÓXIMOS PASOS:
1. Firma de LOI prevista para 01/06/2026
2. Cierre de operación: Q3 2026
3. Integración IT: Q4 2026

Esta información es ESTRICTAMENTE CONFIDENCIAL hasta comunicado oficial.
Cualquier filtración antes del cierre puede hacer fracasar la operación.

Atentamente,
Roberto Martínez
CEO — ATACKCORP S.L.
"@
$email_acquisition | Out-File "C:\CorporateData\Executive\email_adquisicion_confidencial.txt" -Encoding UTF8

$email_azure = @"
DE: helpdesk.ruiz@atackcorp.local  
PARA: ceo.martinez@atackcorp.local
ASUNTO: Re: Migración Azure - Credenciales temporales
FECHA: 02/05/2026

Hola Roberto,

Te envío las credenciales temporales para el tenant de Azure que hemos
creado para las pruebas de migración:

Portal: https://portal.azure.com
Usuario: admin@atackcorp.onmicrosoft.com
Password: AzureTemp2026!

Subscription ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Resource Group: atackcorp-prod-rg

IMPORTANTE: Cambiar esta password antes del 01/06/2026

Un saludo,
David Ruiz
IT Helpdesk — ATACKCORP S.L.
"@
$email_azure | Out-File "C:\CorporateData\Executive\email_azure_credenciales.txt" -Encoding UTF8
Write-Success "Comunicaciones ejecutivas creadas"

# ─────────────────────────────────────────────────────────────
# BLOQUE 6 — SMB Shares con permisos (Crown Jewel #5)
# ─────────────────────────────────────────────────────────────
Write-Step "BLOQUE 6 — Configurando SMB Shares corporativos..."

# Share Finanzas (solo Finance group)
try {
    New-SmbShare -Name "Finance" -Path "C:\CorporateData\Finance" `
        -Description "Documentos financieros — Acceso restringido" `
        -FullAccess "ATACKCORP\Admins. del dominio" `
        -ReadAccess "ATACKCORP\fin.garcia" -ErrorAction Stop | Out-Null
    Write-Success "Share \\DC-01\Finance creado (solo fin.garcia + DA)"
} catch {
    Write-Host "    [*] Share Finance ya existe o error: $_" -ForegroundColor Yellow
}

# Share IT (solo IT group)
try {
    New-SmbShare -Name "IT-Internal" -Path "C:\CorporateData\IT" `
        -Description "Recursos IT internos" `
        -FullAccess "ATACKCORP\Admins. del dominio" `
        -ReadAccess "ATACKCORP\helpdesk.ruiz" -ErrorAction Stop | Out-Null
    Write-Success "Share \\DC-01\IT-Internal creado"
} catch {
    Write-Host "    [*] Share IT-Internal ya existe o error: $_" -ForegroundColor Yellow
}

# Share Corporativo (todos los usuarios del dominio — lectura)
try {
    New-SmbShare -Name "Corporativo" -Path "C:\CorporateData\Clients" `
        -Description "Información corporativa general" `
        -ReadAccess "ATACKCORP\Usuarios del dominio" `
        -FullAccess "ATACKCORP\Admins. del dominio" -ErrorAction Stop | Out-Null
    Write-Success "Share \\DC-01\Corporativo creado (todos los usuarios)"
} catch {
    Write-Host "    [*] Share Corporativo ya existe o error: $_" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 7 — Archivo de credenciales en SYSVOL (intencionalmente)
# Simula un error común de administración
# ─────────────────────────────────────────────────────────────
Write-Step "BLOQUE 7 — Añadiendo credenciales en SYSVOL (vulnerability)..."

$sysvol_creds = @"
# Script de instalación — credenciales de servicio
# NOTA: Mover a CyberArk antes del 01/07/2026

$SQLPassword = "SQLService2024!"
$IISPassword = "IISService2024!"
$BackupPassword = "Backup2024!"

# Net use para backup
net use \\NAS-01\Backups /user:backup_svc $BackupPassword
"@
$sysvol_path = "\\$DCName\SYSVOL\$Domain\scripts"
if (Test-Path $sysvol_path) {
    $sysvol_creds | Out-File "$sysvol_path\install_services.ps1" -Encoding UTF8
    Write-Success "Credenciales en SYSVOL\scripts\install_services.ps1 (credential hunting target)"
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 8 — Base de datos SQL ficticia
# ─────────────────────────────────────────────────────────────
Write-Step "BLOQUE 8 — Creando base de datos SQL con datos sensibles..."

$sql_script = @"
-- Crear base de datos corporativa con datos sensibles ficticios
USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'AtackCorpDB')
BEGIN
    CREATE DATABASE AtackCorpDB;
END
GO

USE AtackCorpDB;
GO

-- Tabla de clientes con datos personales
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Clientes' AND xtype='U')
BEGIN
    CREATE TABLE Clientes (
        ID INT PRIMARY KEY IDENTITY,
        Empresa NVARCHAR(100),
        Contacto NVARCHAR(100),
        Email NVARCHAR(100),
        Telefono NVARCHAR(20),
        NIF NVARCHAR(15),
        ValorContrato DECIMAL(10,2)
    );
    
    INSERT INTO Clientes VALUES
    ('Industrias Iberica SA', 'Juan Perez', 'jperez@industriasib.com', '+34 976 111 222', 'A12345678', 85000.00),
    ('Tech Solutions Madrid', 'Ana Garcia', 'agarcia@techsol.es', '+34 91 222 333', 'B87654321', 120000.00),
    ('Farmaceutica Levante', 'Laura Sanchez', 'lsanchez@farmalev.com', '+34 963 444 555', 'C11223344', 200000.00);
END
GO

-- Tabla de credenciales de aplicaciones (Crown Jewel)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AppCredentials' AND xtype='U')
BEGIN
    CREATE TABLE AppCredentials (
        App NVARCHAR(50),
        Username NVARCHAR(100),
        Password NVARCHAR(100),
        Notes NVARCHAR(200)
    );
    
    INSERT INTO AppCredentials VALUES
    ('ERP System', 'erp_admin', 'ERPadmin2026!', 'Sistema ERP principal'),
    ('CRM Platform', 'crm_user', 'CRMpass2024!', 'Salesforce alternativo'),
    ('VPN Gateway', 'vpn_admin', 'VPNgw2026!xK', 'Cisco ASA management');
END
GO
"@
$sql_script | Out-File "C:\CorporateData\IT\database_setup_sensitive.sql" -Encoding UTF8
Write-Success "Script SQL con datos sensibles creado"

# Intentar crear la DB si SQL Server está disponible
try {
    Invoke-Sqlcmd -ServerInstance "localhost\SQLEXPRESS" -Query $sql_script -ErrorAction Stop
    Write-Success "Base de datos AtackCorpDB creada en SQL Server"
} catch {
    Write-Info "SQL Server no disponible — script SQL guardado en C:\CorporateData\IT\"
}

# ─────────────────────────────────────────────────────────────
# RESUMEN FINAL
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host " CROWN JEWELS PROVISIONING COMPLETADO — Lab-01 GHOST FOREST" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""
Write-Host " ACTIVOS DE ALTO VALOR CREADOS:" -ForegroundColor White
Write-Host ""
Write-Host "  #1 Base de datos financiera    C:\CorporateData\Finance\" -ForegroundColor Cyan
Write-Host "     → Nóminas, IBAN, presupuesto anual, accesos banca online" -ForegroundColor Gray
Write-Host ""
Write-Host "  #2 Base de datos de clientes   C:\CorporateData\Clients\" -ForegroundColor Cyan
Write-Host "     → 5 clientes con datos RGPD y valores de contrato" -ForegroundColor Gray
Write-Host ""
Write-Host "  #3 Credenciales IT             C:\CorporateData\IT\Credentials\" -ForegroundColor Cyan
Write-Host "     → Passwords de infraestructura, Azure, NAS, monitorización" -ForegroundColor Gray
Write-Host ""
Write-Host "  #4 Emails ejecutivos           C:\CorporateData\Executive\" -ForegroundColor Cyan
Write-Host "     → Adquisición M&A confidencial + credenciales Azure" -ForegroundColor Gray
Write-Host ""
Write-Host "  #5 SMB Shares                  \\DC-01\Finance, IT-Internal, Corporativo" -ForegroundColor Cyan
Write-Host "     → Shares con permisos diferenciados por rol" -ForegroundColor Gray
Write-Host ""
Write-Host "  #6 SYSVOL credential exposure  SYSVOL\scripts\install_services.ps1" -ForegroundColor Cyan
Write-Host "     → Credenciales hardcodeadas (credential hunting target)" -ForegroundColor Gray
Write-Host ""
Write-Host "  #7 SQL Database                AtackCorpDB (si SQL Server disponible)" -ForegroundColor Cyan
Write-Host "     → Datos de clientes + credenciales de aplicaciones" -ForegroundColor Gray
Write-Host ""
Write-Host " OBJETIVO DEL LAB:" -ForegroundColor Yellow
Write-Host "  Comprometer fin.garcia → acceder a \\DC-01\Finance" -ForegroundColor White
Write-Host "  Comprometer ceo.martinez → leer emails de adquisición M&A" -ForegroundColor White
Write-Host "  Comprometer DA → volcar toda la base de datos corporativa" -ForegroundColor White
Write-Host ""
Write-Host " TODOS LOS DATOS SON FICTICIOS — SOLO USO EDUCATIVO" -ForegroundColor DarkGray
Write-Host ""
