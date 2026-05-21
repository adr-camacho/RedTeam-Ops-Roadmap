#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Crown Jewels Provisioning — Lab-02 SILENT BRIDGE
    Crea los activos de alto valor que APT41 buscaría en un entorno segmentado.
.NOTES
    Operación:  SILENT BRIDGE | Lab: Lab-02 | Adversario: APT41
    Ejecutar:   En PC-01 como Administrador local
#>

$ErrorActionPreference = "SilentlyContinue"

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
Write-Host "║         SILENT BRIDGE — Crown Jewels Provisioning           ║" -ForegroundColor DarkCyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan

# BLOQUE 1 — Estructura de directorios
Write-Host "[*] BLOQUE 1 — Creando estructura de directorios..." -ForegroundColor Yellow
$dirs = @(
    "C:\Users\thomas\Documents\Work\Projects",
    "C:\Users\thomas\Documents\Work\Credentials",
    "C:\DevProjects\WebApp",
    "C:\DevProjects\InternalTools",
    "C:\Backups"
)
foreach ($dir in $dirs) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
Write-Host "    [+] Estructura creada" -ForegroundColor Green

# BLOQUE 2 — Credenciales almacenadas (.env file)
Write-Host "[*] BLOQUE 2 — Creando credenciales almacenadas..." -ForegroundColor Yellow
@"
# Developer credentials — thomas
GIT_USER=thomas
GIT_PASS=iamthegreatest
GIT_URL=http://10.0.3.150/thomas/webapp.git
DB_HOST=10.0.3.150
DB_USER=dev_thomas
DB_PASS=DevDB2024!
VPN_HOST=vpn.atackcorp.local
VPN_USER=thomas.dev
VPN_PASS=VPNthomas2024!
STRIPE_TEST_KEY=STRIPE_TEST_KEY_REDACTED_FOR_LAB
"@ | Out-File "C:\Users\thomas\Documents\Work\Credentials\dev_credentials.env" -Encoding UTF8

@"
[user]
    name = Thomas Developer
    email = thomas@atackcorp.local
[url "http://thomas:iamthegreatest@10.0.3.150/"]
    insteadOf = http://10.0.3.150/
"@ | Out-File "C:\Users\thomas\.gitconfig" -Encoding UTF8
Write-Host "    [+] .env + .gitconfig con credenciales creados" -ForegroundColor Green

# BLOQUE 3 — Código fuente con secretos
Write-Host "[*] BLOQUE 3 — Creando código con secretos embebidos..." -ForegroundColor Yellow
@"
<?php
// TODO: Move to env vars (tech debt #4521)
define('DB_HOST', '10.0.3.150');
define('DB_PASS', 'WebappDB2024!');
define('STRIPE_SECRET', 'STRIPE_LIVE_KEY_REDACTED_FOR_LAB');
define('SMTP_PASS', 'SMTPwebapp2024!');
define('ADMIN_BYPASS_TOKEN', 'dev_bypass_8f4a2c9e1b7d6f3a');
?>
"@ | Out-File "C:\DevProjects\WebApp\config.php" -Encoding UTF8

@"
#!/bin/bash
SERVER="10.0.3.150"
sshpass -p "DeployPass2024!" rsync -avz ./src/ deploy_user@`$SERVER:/var/www/webapp/
"@ | Out-File "C:\DevProjects\WebApp\deploy.sh" -Encoding UTF8
Write-Host "    [+] config.php + deploy.sh con credenciales creados" -ForegroundColor Green

# BLOQUE 4 — Windows Credential Manager
Write-Host "[*] BLOQUE 4 — Almacenando en Windows Credential Manager..." -ForegroundColor Yellow
& cmdkey /add:"10.0.3.150" /user:"thomas" /pass:"iamthegreatest" | Out-Null
& cmdkey /add:"GIT:http://10.0.3.150" /user:"thomas" /pass:"iamthegreatest" | Out-Null
Write-Host "    [+] Credenciales en Windows Credential Manager" -ForegroundColor Green

# BLOQUE 5 — Documentos internos sensibles
Write-Host "[*] BLOQUE 5 — Creando documentos internos..." -ForegroundColor Yellow
@"
ATACKCORP — MAPA DE RED INTERNA — CONFIDENCIAL IT
==================================================
RED PRODUCCION (10.0.3.0/24):
  10.0.3.7    PC-01 (thomas) — Workstation developer
  10.0.3.150  GIT-SERVER — GitLab CE / MySQL
  10.0.3.200  PROD-SERVER — Ubuntu / Webmin 1.890 (VULNERABLE - actualizar!)
RED CORPORATIVA (10.0.2.0/24):
  10.0.2.8    WKSTN-01 | 10.0.2.9 KALI | 10.0.2.10 DC-01
CREDENCIALES SSH:
  PROD root password: ProdRoot2024! (cambiar 30/05/2026)
  GIT thomas: iamthegreatest
"@ | Out-File "C:\Users\thomas\Documents\Work\network_map_internal.txt" -Encoding UTF8

@"
PROYECTO WEBAPP — NOTAS TECNICAS
==================================
PENDIENTE CRITICO:
- Actualizar Webmin en PROD (version actual: 1.890 — VULNERABLE CVE-2019-12840)
- Mover credenciales DB fuera del codigo (tech debt #4521)
ACCESOS TEMPORALES:
- thomas tiene acceso root PROD hasta 30/05/2026: ProdRoot2024!
BACKUP: backup_svc / Backup2024! -> \\DC-01\Backups\webapp\
"@ | Out-File "C:\Users\thomas\Documents\Work\Projects\webapp_notes.txt" -Encoding UTF8
Write-Host "    [+] Mapa de red + notas con credenciales root creados" -ForegroundColor Green

# BLOQUE 6 — Historial PowerShell con credenciales
Write-Host "[*] BLOQUE 6 — Creando historial de comandos..." -ForegroundColor Yellow
$historyPath = "C:\Users\thomas\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine"
New-Item -ItemType Directory -Path $historyPath -Force | Out-Null
@"
net use \\DC-01\Finance /user:ATACKCORP\fin.garcia Finance2024!
mysql -h 10.0.3.150 -u webapp_db -pWebappDB2024! atackcorp_prod
git clone http://thomas:iamthegreatest@10.0.3.150/thomas/webapp.git
cmdkey /add:10.0.3.150 /user:thomas /pass:iamthegreatest
ssh thomas@10.0.3.150 -i C:\Users\thomas\.ssh\id_rsa
"@ | Out-File "$historyPath\ConsoleHost_history.txt" -Encoding UTF8
Write-Host "    [+] Historial PowerShell con credenciales creado" -ForegroundColor Green

# RESUMEN
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host " CROWN JEWELS COMPLETADO — Lab-02 SILENT BRIDGE" -ForegroundColor DarkCyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host "  #1 .env file         C:\Users\thomas\Documents\Work\Credentials\" -ForegroundColor Cyan
Write-Host "  #2 .gitconfig        C:\Users\thomas\.gitconfig (thomas:iamthegreatest)" -ForegroundColor Cyan
Write-Host "  #3 config.php        C:\DevProjects\WebApp\ (DB/Stripe/SMTP passwords)" -ForegroundColor Cyan
Write-Host "  #4 Credential Mgr    cmdkey entries (10.0.3.150)" -ForegroundColor Cyan
Write-Host "  #5 network_map       C:\Users\thomas\Documents\Work\ (PROD root pass)" -ForegroundColor Cyan
Write-Host "  #6 PS History        ConsoleHost_history.txt (comandos con creds)" -ForegroundColor Cyan
Write-Host ""
Write-Host " OBJETIVO: CVE-2019-12840 → PROD → pivot → Git history → thomas:iamthegreatest → PC-01" -ForegroundColor Yellow
Write-Host " TODOS LOS DATOS SON FICTICIOS — SOLO USO EDUCATIVO" -ForegroundColor DarkGray
