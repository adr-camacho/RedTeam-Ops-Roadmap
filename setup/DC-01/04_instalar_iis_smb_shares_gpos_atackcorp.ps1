# =============================================================
# SCRIPT 04 — Servicios: IIS, SMB Shares, GPO vulnerable
# Ejecutar: PowerShell como Administrador del dominio
# Máquina: DC-01
# Prerequisito: Script 02 ejecutado
# =============================================================

Write-Host "`n[*] Instalando y configurando IIS..." -ForegroundColor Cyan

# ── Instalar IIS ─────────────────────────────────────────────
Install-WindowsFeature -Name Web-Server, Web-Mgmt-Tools -IncludeManagementTools

# Crear página web interna con info leak (credenciales en comentario HTML)
$webContent = @"
<html>
<head><title>AtackCorp - Portal Interno</title></head>
<body>
<h1>Portal Interno AtackCorp</h1>
<p>Bienvenido al portal corporativo interno.</p>
<p>Sistema: Windows Server 2019 -- IIS 10.0 -- ASP.NET 4.8</p>
<!-- Conexion BD: Server=dc01;Database=CorpDB;User=sql_svc;Password=SqlService123 -->
<p>Para soporte tecnico contacta: it.admin@atackcorp.local</p>
</body>
</html>
"@
Set-Content "C:\inetpub\wwwroot\index.html" $webContent
Write-Host "[!] Info Leak: credenciales MSSQL en comentario HTML de IIS" -ForegroundColor Red

Write-Host "`n[*] Creando SMB shares corporativos..." -ForegroundColor Cyan

# ── SMB Shares ───────────────────────────────────────────────
# Crear share IT$ con PowerShell puro
New-SmbShare -Name "IT$" -Path "C:\Shares\IT" `
    -FullAccess "ATACKCORP\it.admin" `
    -Description "Share restringido IT"

# Documento con credenciales expuestas (mala práctica real)
$docContent = @"
=== CREDENCIALES DE ACCESO CORPORATIVO === 
=== DOCUMENTO CONFIDENCIAL - USO INTERNO ===

Ultima actualizacion: Enero 2026

[VPN]
Servidor: vpn.atackcorp.local
Usuario:  it.admin
Password: ITAdmin2024!

[Backup]
Usuario:  backup_svc
Password: Backup2024!

[Base de datos MSSQL]
SA Password: Sa_Admin2024!
Cuenta svc:  sql_svc / SqlService123

=== FIN DEL DOCUMENTO ===
"@
Set-Content "C:\Shares\Publico\IT_Passwords_OLD.txt" $docContent

# Crear shares con permisos
if (-not (Get-SmbShare -Name "Publico" -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name "Publico" -Path "C:\Shares\Publico" `
        -ChangeAccess "Everyone" -ReadAccess "Everyone"
    Write-Host "[!] SMB Share 'Publico' creado con acceso Everyone" -ForegroundColor Red
}

if (-not (Get-SmbShare -Name "IT$" -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name "IT$" -Path "C:\Shares\IT" `
        -FullAccess "ATACKCORP\it.admin", "ATACKCORP\Domain Admins"
    Write-Host "[+] SMB Share 'IT$' creado (acceso restringido)" -ForegroundColor Green
}

Write-Host "`n[*] Configurando GPO vulnerable..." -ForegroundColor Cyan

# ── GPO abusable por Helpdesk ────────────────────────────────
Import-Module GroupPolicy

$gpoName = "IT-Baseline"
$existingGPO = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue

if (-not $existingGPO) {
    $gpo = New-GPO -Name $gpoName -Comment "Politica base equipos IT"
    New-GPLink -Name $gpoName -Target "OU=Equipos,DC=atackcorp,DC=local"
    Write-Host "[+] GPO '$gpoName' creada y enlazada a OU=Equipos" -ForegroundColor Green
} else {
    $gpo = $existingGPO
    Write-Host "[!] GPO '$gpoName' ya existe" -ForegroundColor Yellow
}

# Dar permisos de escritura al usuario helpdesk.ruiz sobre la GPO
$gpoPath = "\\atackcorp.local\SYSVOL\atackcorp.local\Policies\{$($gpo.Id)}"
if (Test-Path $gpoPath) {
    $acl = Get-Acl $gpoPath
    $helpdesk = New-Object System.Security.Principal.NTAccount("ATACKCORP\helpdesk.ruiz")
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $helpdesk, "FullControl",
        "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.AddAccessRule($rule)
    Set-Acl $gpoPath $acl
    Write-Host "[!] GPO Abuse: helpdesk.ruiz tiene FullControl sobre '$gpoName'" -ForegroundColor Red
} else {
    Write-Host "[!] Ruta SYSVOL de la GPO no encontrada. Verifica replicación." -ForegroundColor Yellow
}

Write-Host "`n[+] Script 04 completado." -ForegroundColor Green
