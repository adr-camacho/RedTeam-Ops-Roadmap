#Requires -RunAsAdministrator
<#
.SYNOPSIS Crown Jewels — Lab-06 BLACK POLICY (APT28)
.VERSION 1.1 | Actualizado: Junio 2026
.NOTES
    FIX v1.1: New-SmbShare Enterprise-Strategy falla con nombre de grupo en entornos
    multi-forest con trust degradado. Usar SID directo del grupo Domain Admins.
    
    Domain Admins SID atackcorp.local: S-1-5-21-768292631-183641691-1245477636-512
    Enterprise Admins SID:             S-1-5-21-768292631-183641691-1245477636-519
#>
$ErrorActionPreference = "SilentlyContinue"
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor DarkGreen
Write-Host "║    BLACK POLICY — Crown Jewels Provisioning     ║" -ForegroundColor DarkGreen
Write-Host "║    Version 1.1 — Junio 2026                     ║" -ForegroundColor DarkGreen
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor DarkGreen

# --- BLOQUE 1 — Documentacion de arquitectura multi-forest ---
Write-Host "[*] Creando documentacion de arquitectura multi-forest..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\CorporateData\IT\Forest-Architecture" -Force | Out-Null
@"
ATACKCORP — ARQUITECTURA FOREST AD — CONFIDENCIAL IT
=====================================================
Forest Root: atackcorp.local (DC-01: 10.0.2.10)
Dominio hijo: child.atackcorp.local (DC-03: 10.0.2.13)
Forest 2: corp.local (DC-02: 10.0.2.11)
Forest 3: ext.local (DC-04: 10.0.2.14)

TRUST configurado:
  atackcorp <-> corp.local  (Bidireccional)
  atackcorp <-> ext.local   (Bidireccional)
  atackcorp <-> child       (Parent-Child)
  
SID Filtering: DESHABILITADO (por compatibilidad legacy — TICKET IT#4521 pendiente)

RIESGO IDENTIFICADO:
  SID Filtering deshabilitado permite SID History injection y ExtraSids attack
  Comprometer krbtgt de child -> Golden Ticket con DA SID -> Forest Root comprometido
  ACCION REQUERIDA: Habilitar SID Filtering — Prioridad ALTA

Enterprise Admins SID: S-1-5-21-768292631-183641691-1245477636-519
Domain Admins SID:     S-1-5-21-768292631-183641691-1245477636-512
"@ | Out-File "C:\CorporateData\IT\Forest-Architecture\forest_trust_config.txt" -Encoding UTF8
Write-Host "    [+] Documentacion de trust multi-forest creada" -ForegroundColor Green

# --- BLOQUE 2 — Verificar sIDHistory (informativo) ---
Write-Host "[*] Verificando sIDHistory en cuentas del dominio..." -ForegroundColor Yellow
try {
    Import-Module ActiveDirectory
    $user = Get-ADUser "fin.garcia" -Properties sIDHistory
    Write-Host "    [i] sIDHistory de fin.garcia: $($user.sIDHistory)" -ForegroundColor Cyan
    Write-Host "    [i] En Lab-06 Fase 02: child.user recibe SID de DA via DSInternals" -ForegroundColor Cyan
} catch { Write-Host "    [*] No se pudo leer sIDHistory" -ForegroundColor Yellow }

# --- BLOQUE 3 — Crown Jewel: Enterprise-Strategy share ---
Write-Host "[*] Creando Crown Jewel — Enterprise-Strategy share..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\CorporateData\Enterprise-Strategy" -Force | Out-Null
@"
ATACKCORP ENTERPRISE — ESTRATEGIA CORPORATIVA 2026-2028 — TOP SECRET
======================================================================
EXPANSION INTERNACIONAL:
  Q3 2026: Apertura oficina Alemania (Munich) — inversion 500.000 EUR
  Q4 2026: Adquisicion TechStartup SL completada
  2027: IPO en BME (Bolsa Madrid) — valoracion objetivo 15M EUR

ALIANZAS ESTRATEGICAS:
  PharmaTech GmbH: partnership exclusivo farmaceutico EU (NDA hasta 2029)
  MedData Inc: acuerdo datos IA — valor 2.4M USD
  
DATOS FINANCIEROS CONSOLIDADOS:
  Cash disponible: 2.1M EUR
  Deuda: 0 EUR
  Valoracion actual (DCF): 8.7M EUR

SOLO ACCESIBLE PARA: Board + CEO + CFO
CLASIFICACION: TOP SECRET — filtracion puede colapsar negociaciones IPO
"@ | Out-File "C:\CorporateData\Enterprise-Strategy\IPO_strategy_2026.txt" -Encoding UTF8

# FIX v1.1: Usar SID directo — nombre de grupo falla en entornos multi-forest
# con trust degradado y en Windows Server en espanol
try {
    New-SmbShare -Name "Enterprise-Strategy" `
      -Path "C:\CorporateData\Enterprise-Strategy" `
      -NoAccess "*S-1-1-0" `
      -FullAccess "*S-1-5-21-768292631-183641691-1245477636-512" `
      -ErrorAction Stop | Out-Null
    Write-Host "    [+] Share Enterprise-Strategy creado (FullAccess DA via SID)" -ForegroundColor Green
} catch {
    Write-Host "    [*] Share ya existe o error: $_" -ForegroundColor Yellow
}

# --- BLOQUE 4 — Guia de ataque (referencia) ---
Write-Host "[*] Creando guia de ataque cross-forest..." -ForegroundColor Yellow
@"
GUIA ATAQUE CROSS-FOREST — LAB-06 BLACK POLICY
================================================
FASE 02 — SID History Injection:
  1. Evil-WinRM DC-03 como child.admin
  2. Obtener SID DA atackcorp: .NET NTAccount.Translate()
  3. Stop-Service NTDS; DSInternals Add-ADDBSidHistory; Start-Service NTDS
  4. Evil-WinRM DC-01 como child.user -> DA via SID History
  5. DCSync krbtgt atackcorp.local

FASE 03 — Cross-Forest Trust:
  Path A (corp.local): john.smith GenericAll -> bloodyAD SPN -> Targeted Kerberoast -> corp.admin
  Path B (ext.local):  smbclient Ext-Data -> credenciales ext.admin en texto claro

FASE 04 — GPO Abuse:
  1. ldapsearch -> GPO IT-Baseline {163A5B0F-F487-475B-B536-370A00E15A8B}
  2. dacledit write FullControl helpdesk.ruiz sobre GPO
  3. pyGPOAbuse -> ScheduledTask -> helpdesk.ruiz admin local WKSTN-01
  4. Cleanup: pyGPOAbuse --cleanup + dacledit restore

CROWN JEWEL FINAL:
  smbclient //DC-01/Enterprise-Strategy -U 'atackcorp.local\backup_svc%Backup2024!'
  -> IPO_strategy_2026.txt TOP SECRET
"@ | Out-File "C:\CorporateData\IT\Forest-Architecture\attack_guide_reference.txt" -Encoding UTF8
Write-Host "    [+] Guia de ataque cross-forest creada" -ForegroundColor Green

# --- RESUMEN ---
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor DarkGreen
Write-Host " CROWN JEWELS — Lab-06 BLACK POLICY (v1.1)" -ForegroundColor DarkGreen
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor DarkGreen
Write-Host "  #1 Forest trust config     C:\CorporateData\IT\Forest-Architecture\" -ForegroundColor Cyan
Write-Host "     -> SID Filtering deshabilitado documentado" -ForegroundColor Gray
Write-Host "  #2 IPO Strategy            C:\CorporateData\Enterprise-Strategy\" -ForegroundColor Cyan
Write-Host "     -> Share FullAccess DA via SID (FIX v1.1)" -ForegroundColor Gray
Write-Host "  #3 Attack guide            attack_guide_reference.txt" -ForegroundColor Cyan
Write-Host " OBJETIVO: SID History + GPO Abuse + Forest Trust -> Enterprise-Strategy" -ForegroundColor Yellow
Write-Host " DATOS FICTICIOS — SOLO USO EDUCATIVO" -ForegroundColor DarkGray
