# ============================================================
#  SILENT BRIDGE — Lab-02 Silent Bridge
#  Setup Script: Entorno de red segmentada (tres nodos)
#  Operación: APT41 Emulation | MITRE ATT&CK v14
#  Autor: Red Team Ops Roadmap — Adrián Camacho
#
#  TOPOLOGÍA:
#    Kali (10.0.2.9) → PROD Linux (10.0.2.200) → Red interna
#                                                  ├── GIT Linux (10.0.3.150)
#                                                  └── PC-01 Windows (10.0.3.7)
#
#  ESTE SCRIPT configura:
#    [1] PROD  — Webmin vulnerable (CVE-2019-12840) + SSH
#    [2] GIT   — Gitea con credenciales en repositorio
#    [3] PC    — WinRM + usuario con credenciales del repo
#
#  REQUISITOS PREVIOS:
#    - PROD: Linux (Ubuntu/CentOS) con Webmin instalado
#    - GIT:  Linux con Gitea o Git bare repo instalado
#    - PC:   Windows 10/11 unido o standalone (workgroup)
#    - Red interna entre PROD, GIT y PC configurada
# ============================================================

# ──────────────────────────────────────────────────────────────
# BLOQUE 0 — VERIFICACIÓN DE TOPOLOGÍA ANTES DE COMENZAR
# ──────────────────────────────────────────────────────────────
# Ejecutar desde Kali para verificar que PROD es alcanzable

: '
# Verificación de conectividad inicial (bash — ejecutar en Kali)
echo "[*] Verificando conectividad con PROD..."
ping -c 2 10.0.2.200 && echo "[+] PROD alcanzable" || echo "[!] PROD no responde"

echo "[*] Verificando Webmin en PROD..."
curl -sk https://10.0.2.200:10000/ | grep -i "webmin\|version" | head -5

echo "[*] Verificando SSH en PROD..."
nc -zv 10.0.2.200 22 2>&1
'

# ──────────────────────────────────────────────────────────────
# BLOQUE 1 — PROD: Downgrade Webmin a versión vulnerable
# CVE-2019-12840 — RCE pre-auth via /password_change.cgi
# Afecta a Webmin < 1.920 con passwd_mode habilitado
# ──────────────────────────────────────────────────────────────

: '
# Ejecutar en PROD como root (bash)
# ─────────────────────────────────────────────────────────────
# Opción A — Instalar Webmin 1.890 (versión vulnerable conocida)
wget https://sourceforge.net/projects/webadmin/files/webmin/1.890/webmin_1.890_all.deb
dpkg -i webmin_1.890_all.deb

# Verificar versión instalada
grep "^version=" /etc/webmin/version || cat /usr/share/webmin/version

# Habilitar passwd_mode (necesario para CVE-2019-12840)
# En /etc/webmin/miniserv.conf añadir o verificar:
grep "passwd_mode" /etc/webmin/miniserv.conf || echo "passwd_mode=2" >> /etc/webmin/miniserv.conf

# Reiniciar Webmin
service webmin restart || systemctl restart webmin

# Verificar que Webmin escucha en :10000
ss -tlnp | grep 10000

# ─────────────────────────────────────────────────────────────
# Opción B — Webmin ya instalado: verificar si es vulnerable
curl -sk https://localhost:10000/ | grep -i "version"
# Si la versión es >= 1.920, hay que downgradearlo (Opción A)
'

# ──────────────────────────────────────────────────────────────
# BLOQUE 2 — GIT SERVER: Repositorio con credenciales expuestas
# T1552.001 — Credentials in Files (Git repository)
# ──────────────────────────────────────────────────────────────

: '
# Ejecutar en GIT SERVER como root (bash)
# ─────────────────────────────────────────────────────────────

# Instalar Git si no está instalado
apt install -y git || yum install -y git

# Crear usuario de desarrollo
useradd -m -s /bin/bash thomas
echo "thomas:thomas" | chpasswd

# Crear repositorio con credenciales hardcodeadas en el código fuente
mkdir -p /home/thomas/wreath-web
cd /home/thomas/wreath-web
git init
git config user.email "thomas@wreath.thm"
git config user.name "Thomas Wreath"

# Archivo de configuración con credenciales expuestas
cat > index.php << '"'"'EOF'"'"'
<?php
    // Database connection
    $db_host = "localhost";
    $db_user = "root";
    $db_pass = "iamthegreatest";     // ← CREDENCIAL EXPUESTA [vector]
    $db_name = "webserver";

    $connection = new mysqli($db_host, $db_user, $db_pass, $db_name);
    if ($connection->connect_error) {
        die("Connection failed: " . $connection->connect_error);
    }
?>
<html>
<head><title>Wreath Management System</title></head>
<body>
    <h1>Internal Management Portal</h1>
    <p>Welcome to the Wreath family network management system.</p>
</body>
</html>
EOF

# Commitear el archivo (la credencial queda en el historial git)
git add index.php
git commit -m "Initial web application setup"

# Segunda versión — intento de "limpiar" la credencial (sigue en historial)
cat > index.php << '"'"'EOF'"'"'
<?php
    $db_host = "localhost";
    $db_user = "root";
    $db_pass = getenv("DB_PASS");    // intento de fix — credencial ya en historial
    $db_name = "webserver";
    $connection = new mysqli($db_host, $db_user, $db_pass, $db_name);
?>
<html><body><h1>Internal Management Portal</h1></body></html>
EOF

git add index.php
git commit -m "Security fix: moved credentials to environment variables"

echo "[!] Repositorio creado con credenciales en historial git"
echo "[!] Credencial expuesta: root / iamthegreatest"
git log --oneline

# ─────────────────────────────────────────────────────────────
# Hacer el repositorio accesible via HTTP (git daemon o Gitea)
# Opción simple: git daemon
git daemon --base-path=/home/thomas --export-all --reuseaddr --verbose &
echo "[+] Git daemon escuchando en :9418"

# O via HTTP con Apache/Nginx:
# mv /home/thomas/wreath-web /var/www/html/wreath.git
# git --bare init /var/www/html/wreath.git
# chown -R www-data: /var/www/html/wreath.git
'

# ──────────────────────────────────────────────────────────────
# BLOQUE 3 — PC WINDOWS: Usuario y WinRM habilitado
# T1021.006 — Remote Services: Windows Remote Management
# Las credenciales coinciden con las del repositorio Git
# ──────────────────────────────────────────────────────────────

: '
# Ejecutar en PC WINDOWS como Administrador (PowerShell)
# ─────────────────────────────────────────────────────────────

# Habilitar WinRM
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true

# Crear usuario con la misma contraseña que el repositorio Git
# (reutilización de credenciales — vector realista APT41)
$pass = ConvertTo-SecureString "iamthegreatest" -AsPlainText -Force
New-LocalUser -Name "thomas" -Password $pass -FullName "Thomas Wreath" `
    -Description "Local admin account"
Add-LocalGroupMember -Group "Administrators" -Member "thomas"
Add-LocalGroupMember -Group "Remote Management Users" -Member "thomas"

Write-Host "[!] Usuario thomas creado: thomas / iamthegreatest"
Write-Host "[!] WinRM habilitado — puerto 5985"

# Verificar WinRM
Get-Service WinRM
Test-WSMan localhost
'

# ──────────────────────────────────────────────────────────────
# BLOQUE 4 — VERIFICACIÓN FINAL DEL ESCENARIO
# Ejecutar desde Kali tras configurar los tres nodos
# ──────────────────────────────────────────────────────────────

: '
# bash — ejecutar en Kali
echo ""
echo "============================================================"
echo "  SILENT BRIDGE — Verificación del escenario"
echo "============================================================"
echo ""

# PROD — Webmin
echo "[*] PROD — Webmin :10000"
curl -sk https://10.0.2.200:10000/ | grep -i "version\|webmin" | head -3
echo ""

# PROD — SSH
echo "[*] PROD — SSH :22"
nc -zv 10.0.2.200 22 2>&1
echo ""

# GIT — Puerto Git o HTTP
echo "[*] GIT — Repositorio accesible"
# Ajustar IP real del GIT server
curl -s http://10.0.3.150/ | head -5
echo ""

# PC — WinRM
echo "[*] PC — WinRM :5985"
# Ajustar IP real del PC Windows
nc -zv 10.0.3.7 5985 2>&1
echo ""

echo "============================================================"
echo "  Kill Chain disponible:"
echo "  PROD (CVE-2019-12840) → Ligolo-ng → GIT (git history)"
echo "  → credenciales thomas:iamthegreatest → PC WinRM → DA"
echo "============================================================"
'

# ──────────────────────────────────────────────────────────────
# RESUMEN — Kill Chain y credenciales del entorno
# ──────────────────────────────────────────────────────────────

: '
ENTORNO WREATH — SILENT BRIDGE
════════════════════════════════════════════════════════════

HOSTS:
  PROD    10.0.2.200  Linux    Webmin 1.890 vulnerable
  GIT     10.0.3.150  Linux    Git repo con credenciales
  PC-01   10.0.3.7    Windows  WinRM habilitado
  Kali    10.0.2.9    Linux    Atacante

CREDENCIALES:
  PROD root   → acceso via CVE-2019-12840 (no requiere credenciales)
  GIT  thomas → thomas:thomas (SSH local)
  PC   thomas → thomas:iamthegreatest (WinRM — reutilización)

VECTORES:
  [V1] CVE-2019-12840 → RCE en PROD sin autenticación
  [V2] Git history    → credenciales en commit antiguo
  [V3] WinRM + PtH/creds → acceso al PC Windows

KILL CHAIN:
  Nmap PROD → CVE-2019-12840 → shell PROD
    → Ligolo-ng agent → túnel TLS
    → Enumeración interna → GIT server
    → git log / git show → thomas:iamthegreatest
    → Evil-WinRM PC → shell thomas (admin local)
    → Sliver beacon → C2 en red interna
    → Persistencia + exfiltración

IPs DEFINITIVAS (completar tras levantar el lab):
  PROD: 10.0.2.___
  GIT:  10.0.2.___
  PC:   10.0.2.___
  Red interna: 10.0.2.___ /24
'