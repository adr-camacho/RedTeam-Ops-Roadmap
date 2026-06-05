#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Crown Jewels Provisioning — Lab-03 DARK GATE
    Crea los activos de alto valor relacionados con ADCS que APT29 buscaría.
.NOTES
    Operación:  DARK GATE | Lab: Lab-03 | Adversario: APT29
    Ejecutar:   En DC-01 como Administrador del dominio
    Requisito:  Setup-Lab03-DarkGate.ps1 + ADCS instalado
#>

$ErrorActionPreference = "SilentlyContinue"

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║           DARK GATE — Crown Jewels Provisioning             ║" -ForegroundColor Magenta
Write-Host "║              Lab-03 | APT29 Emulation Target                ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta

# BLOQUE 1 — Estructura de directorios
Write-Host "[*] BLOQUE 1 — Creando estructura de directorios PKI..." -ForegroundColor Yellow
$dirs = @(
    "C:\CorporateData\Certificates",
    "C:\CorporateData\Certificates\Exported",
    "C:\CorporateData\Certificates\Archive",
    "C:\CorporateData\PKI-Admin",
    "C:\CorporateData\Legal\Contracts",
    "C:\CorporateData\RD"
)
foreach ($dir in $dirs) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
Write-Host "    [+] Estructura PKI creada" -ForegroundColor Green

# BLOQUE 2 — Documentos PKI sensibles (Crown Jewel #1)
Write-Host "[*] BLOQUE 2 — Creando documentos PKI sensibles..." -ForegroundColor Yellow
@"
ATACKCORP PKI — GUIA DE ADMINISTRACION CERTIFICADOS
====================================================
CA Name: atackcorp-CA
CA Type: Enterprise Root CA
Validez certificados usuarios: 2 años
Validez certificados equipos: 1 año

PLANTILLAS ACTIVAS:
  UserAuthentication   — Autenticacion usuarios (REVISAR — posible ESC1)
  VulnerableTemplate   — Plantilla heredada (DESACTIVAR — ESC4 confirmado)
  ComputerAuth         — Autenticacion equipos
  WebServerSSL         — Certificados IIS

EXPORTACION CA BACKUP:
  Archivo: C:\CorporateData\PKI-Admin\CA_backup_2025.p12
  Password: CAbackup2025!AtackCorp
  UBICACION CLAVE PRIVADA: C:\Windows\System32\CertSrv\CertEnroll\

PROCEDIMIENTO RENOVACION ANUAL:
  1. Exportar CA cert con clave privada
  2. Guardar en \\DC-01\IT-Internal\PKI-Backup\
  3. Password backup: CAbackup[AÑO]!AtackCorp

CONTACTO: helpdesk.ruiz@atackcorp.local
"@ | Out-File "C:\CorporateData\PKI-Admin\PKI_admin_guide.txt" -Encoding UTF8
Write-Host "    [+] Guia PKI con credenciales de backup creada" -ForegroundColor Green

# BLOQUE 3 — Certificado exportado con clave privada (Crown Jewel #2)
Write-Host "[*] BLOQUE 3 — Simulando certificados exportados almacenados..." -ForegroundColor Yellow
@"
ATENCION: Este directorio contiene certificados con clave privada exportada.
Acceso restringido a: Administrador, helpdesk.ruiz

CONTENIDO:
  Administrador_2026.pfx     — Cert autenticacion Administrador (expira 15/05/2028)
    Password: AdminCert2026!
  
  ceo_martinez_2026.pfx      — Cert autenticacion ceo.martinez (expira 10/03/2028)
    Password: CeoCert2026!
  
  code_signing_2026.pfx      — Cert firma de codigo corporativo
    Password: CodeSign2026!AtackCorp

NOTAS:
- Estos certificados permiten autenticacion incluso tras cambio de password
- NUNCA compartir passwords de .pfx fuera del equipo IT
- Revocar inmediatamente si se sospecha compromiso: certutil -revoke [SerialNumber]
"@ | Out-File "C:\CorporateData\Certificates\Exported\README_certificates.txt" -Encoding UTF8

# Simular archivo de registro de certificados emitidos
@"
REGISTRO DE CERTIFICADOS EMITIDOS — atackcorp-CA
=================================================
Fecha        | Solicitante          | Plantilla            | SAN/UPN                    | Serie
15/01/2026   | Administrador        | UserAuthentication   | Administrador@atackcorp.local | 1A2B3C4D
10/03/2026   | ceo.martinez         | UserAuthentication   | ceo.martinez@atackcorp.local  | 2B3C4D5E
20/04/2026   | fin.garcia           | VulnerableTemplate   | Administrador@atackcorp.local | 3C4D5E6F  <- ANOMALIA
01/05/2026   | helpdesk.ruiz        | UserAuthentication   | helpdesk.ruiz@atackcorp.local | 4D5E6F7G

ANOMALIA DETECTADA (20/04/2026):
  fin.garcia solicito certificado con UPN de Administrador usando VulnerableTemplate
  Estado: ACTIVO (pendiente revocacion — ticket IT #8821)
  ACCION REQUERIDA: Revocar certificado serie 3C4D5E6F URGENTE
"@ | Out-File "C:\CorporateData\PKI-Admin\certificate_registry.txt" -Encoding UTF8
Write-Host "    [+] Registro de certificados con anomalia ESC1 documentada" -ForegroundColor Green

# BLOQUE 4 — Documentos R&D confidenciales (Crown Jewel #3)
Write-Host "[*] BLOQUE 4 — Creando documentos R&D confidenciales..." -ForegroundColor Yellow
@"
ATACKCORP — PROYECTO NEXUS — ESTRICTAMENTE CONFIDENCIAL
========================================================
Clasificacion: SECRETO COMERCIAL
Acceso: Solo CEO, CTO, Consejo de Administracion

DESCRIPCION:
  Desarrollo de plataforma SaaS propietaria para sector farmaceutico.
  Inversion total: 800.000 EUR (2024-2026)
  Revenue proyectado año 1: 2.400.000 EUR

PROPIEDAD INTELECTUAL:
  - Algoritmo de analisis de ensayos clinicos (patente pendiente ES2024/12345)
  - Dataset entrenamiento IA: 50.000 registros anonimizados
  - Codigo fuente: 180.000 lineas Python/React

PARTNERS ESTRATEGICOS (NDA firmado):
  - PharmaTech GmbH (Alemania) — distribucion europea
  - MedData Inc (USA) — datos de entrenamiento
  
ESTADO: Beta testing con cliente piloto Farmaceutica Levante SA
FECHA LANZAMIENTO: Q4 2026

*** FILTRACION DE ESTE DOCUMENTO PUEDE CAUSAR DANO IRREPARABLE ***
"@ | Out-File "C:\CorporateData\RD\proyecto_nexus_confidencial.txt" -Encoding UTF8
Write-Host "    [+] Documentos R&D con secreto comercial creados" -ForegroundColor Green

# BLOQUE 5 — Contratos legales sensibles (Crown Jewel #4)
Write-Host "[*] BLOQUE 5 — Creando contratos sensibles..." -ForegroundColor Yellow
@"
CONTRATO DE ADQUISICION — BORRADOR CONFIDENCIAL
================================================
PARTES:
  COMPRADORA: ATACKCORP S.L. (CIF: B50123456)
  VENDEDORA:  TECHSTARTUP S.L. (CIF: B87654321)

OBJETO: Adquisicion del 100% de las participaciones de TechStartup S.L.
PRECIO: 1.200.000 EUR (UN MILLON DOSCIENTOS MIL EUROS)

CONDICIONES:
  - Clausula no competencia: 3 años, radio 500km
  - Retencion empleados clave: min. 18 meses
  - Garantias: 12 meses sobre deuda oculta

ESTADO: BORRADOR — Pendiente revision legal externa
FECHA FIRMA PREVISTA: 01/06/2026

CONFIDENCIALIDAD: Este documento es CONFIDENCIAL hasta la firma definitiva.
Distribucion no autorizada puede frustrar la operacion y generar
responsabilidad legal para el distribuidor.
"@ | Out-File "C:\CorporateData\Legal\Contracts\adquisicion_techstartup_borrador.txt" -Encoding UTF8
Write-Host "    [+] Borrador contrato adquisicion M&A creado" -ForegroundColor Green

# BLOQUE 6 — SMB Share PKI (solo admins)
Write-Host "[*] BLOQUE 6 — Configurando SMB Share PKI-Admin..." -ForegroundColor Yellow
try {
    New-SmbShare -Name "PKI-Admin" `
        -Path "C:\CorporateData\PKI-Admin" `
        -Description "Administracion PKI — Acceso restringido" `
        -FullAccess "ATACKCORP\Admins. del dominio" `
        -NoAccess "Everyone" -ErrorAction Stop | Out-Null
    Write-Host "    [+] Share \\DC-01\PKI-Admin creado (solo DA)" -ForegroundColor Green
} catch {
    Write-Host "    [*] Share PKI-Admin ya existe o error" -ForegroundColor Yellow
}

try {
    New-SmbShare -Name "Legal-Confidential" `
        -Path "C:\CorporateData\Legal" `
        -Description "Documentos legales confidenciales" `
        -FullAccess "ATACKCORP\Admins. del dominio" `
        -ReadAccess "ATACKCORP\ceo.martinez" -ErrorAction Stop | Out-Null
    Write-Host "    [+] Share \\DC-01\Legal-Confidential creado (CEO + DA)" -ForegroundColor Green
} catch {
    Write-Host "    [*] Share Legal-Confidential ya existe o error" -ForegroundColor Yellow
}

# BLOQUE 7 — Registro de eventos PKI simulado
Write-Host "[*] BLOQUE 7 — Creando logs PKI simulados..." -ForegroundColor Yellow
@"
[2026-04-20 14:32:11] CERT_ISSUED | Requestor: fin.garcia | Template: VulnerableTemplate | UPN: Administrador@atackcorp.local | Serial: 3C4D5E6F
[2026-04-20 14:32:11] WARNING: SAN differs from requestor identity
[2026-04-20 14:35:22] CERT_AUTH | User: fin.garcia | Cert: 3C4D5E6F | Auth as: Administrador
[2026-04-20 14:35:23] DCSYNC | Source IP: 10.0.2.9 | User: Administrador | Hashes requested: ALL
[2026-05-01 09:12:44] CERT_ISSUED | Requestor: helpdesk.ruiz | Template: VulnerableTemplate | UPN: Administrador@atackcorp.local | Serial: 5E6F7G8H
[2026-05-01 09:12:44] WARNING: SAN differs from requestor identity
"@ | Out-File "C:\CorporateData\PKI-Admin\pki_audit_log.txt" -Encoding UTF8
Write-Host "    [+] Logs PKI con evidencias de ESC1 creados" -ForegroundColor Green

# RESUMEN
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host " CROWN JEWELS COMPLETADO — Lab-03 DARK GATE" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  #1 Guia PKI          C:\CorporateData\PKI-Admin\ (CA backup password)" -ForegroundColor Cyan
Write-Host "  #2 Certs exportados  C:\CorporateData\Certificates\Exported\ (.pfx + passwords)" -ForegroundColor Cyan
Write-Host "  #3 Registro certs    certificate_registry.txt (anomalia ESC1 documentada)" -ForegroundColor Cyan
Write-Host "  #4 R&D confidencial  C:\CorporateData\RD\ (secreto comercial Proyecto Nexus)" -ForegroundColor Cyan
Write-Host "  #5 Contrato M&A      C:\CorporateData\Legal\ (adquisicion 1.2M EUR borrador)" -ForegroundColor Cyan
Write-Host "  #6 SMB Shares        PKI-Admin (solo DA) + Legal-Confidential (CEO + DA)" -ForegroundColor Cyan
Write-Host "  #7 PKI audit log     evidencias de ESC1 previo en logs" -ForegroundColor Cyan
Write-Host ""
Write-Host " OBJETIVO: ESC1/ESC4 -> cert Administrador -> acceder PKI-Admin + Legal-Confidential" -ForegroundColor Yellow
Write-Host " PERSISTENCIA: cert valido tras rotacion de passwords (crown jewel real de APT29)" -ForegroundColor Yellow
Write-Host " TODOS LOS DATOS SON FICTICIOS — SOLO USO EDUCATIVO" -ForegroundColor DarkGray
