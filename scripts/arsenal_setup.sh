#!/bin/bash
# ============================================================
#  RED TEAM OPS ROADMAP — Arsenal Setup Script
#  Autor: Adrián Camacho
#  Ejecutar en Kali Linux con acceso a Internet
#  Uso: chmod +x arsenal_setup.sh && sudo ./arsenal_setup.sh
#
#  HERRAMIENTAS INSTALADAS:
#    - Impacket (suite completa)
#    - Certipy-ad (ADCS abuse)
#    - BloodHound + Neo4j
#    - Ligolo-ng (pivoting)
#    - Sliver C2
#    - Evil-WinRM
#    - NetExec (CrackMapExec successor)
#    - Kerbrute
#    - Rubeus (Windows — referencia)
#    - PetitPotam
#    - Coercer
#    - PrinterBug
#    - PowerView (referencia PowerShell)
#    - PrivescCheck
#    - WinPEAS / LinPEAS
#    - Havoc C2 (Phase-03)
# ============================================================

set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TOOLS_DIR="/opt/redteam"
mkdir -p $TOOLS_DIR

banner() {
    echo ""
    echo -e "${CYAN}============================================================${NC}"
    echo -e "${CYAN}  RED TEAM OPS ROADMAP — Arsenal Setup${NC}"
    echo -e "${CYAN}  Kali Linux — $(date '+%Y-%m-%d')${NC}"
    echo -e "${CYAN}============================================================${NC}"
    echo ""
}

ok()   { echo -e "    ${GREEN}[+]${NC} $1"; }
info() { echo -e "    ${YELLOW}[*]${NC} $1"; }
err()  { echo -e "    ${RED}[!]${NC} $1"; }
section() { echo -e "\n${CYAN}[*] $1${NC}"; }

banner

# ─────────────────────────────────────────────────────────────
# BLOQUE 0 — Actualización del sistema
# ─────────────────────────────────────────────────────────────
section "BLOQUE 0 — Actualizando sistema..."
apt-get update -qq && apt-get upgrade -y -qq
ok "Sistema actualizado"

# ─────────────────────────────────────────────────────────────
# BLOQUE 1 — Herramientas base via apt
# ─────────────────────────────────────────────────────────────
section "BLOQUE 1 — Instalando herramientas base..."

apt-get install -y -qq \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    nmap \
    netcat-traditional \
    evil-winrm \
    crackmapexec \
    bloodhound \
    neo4j \
    john \
    hashcat \
    smbclient \
    ldap-utils \
    dnsutils \
    metasploit-framework \
    gobuster \
    feroxbuster \
    responder \
    impacket-scripts \
    golang-go \
    mingw-w64 \
    2>/dev/null

ok "Herramientas base instaladas"

# ─────────────────────────────────────────────────────────────
# BLOQUE 2 — Impacket (última versión)
# ─────────────────────────────────────────────────────────────
section "BLOQUE 2 — Impacket..."

pip install impacket --break-system-packages -q 2>/dev/null && ok "Impacket actualizado" || err "Error actualizando Impacket"

# ─────────────────────────────────────────────────────────────
# BLOQUE 3 — Certipy-ad (ADCS Abuse)
# ─────────────────────────────────────────────────────────────
section "BLOQUE 3 — Certipy-ad..."

pip install certipy-ad --break-system-packages -q 2>/dev/null && ok "Certipy-ad instalado" || err "Error instalando Certipy-ad"
certipy-ad --version 2>/dev/null | head -1 && ok "certipy-ad operativo" || err "certipy-ad no encontrado en PATH"

# ─────────────────────────────────────────────────────────────
# BLOQUE 4 — NetExec (sucesor CrackMapExec)
# ─────────────────────────────────────────────────────────────
section "BLOQUE 4 — NetExec..."

pip install netexec --break-system-packages -q 2>/dev/null && ok "NetExec instalado" || {
    apt-get install -y -qq netexec 2>/dev/null && ok "NetExec instalado via apt" || err "Error instalando NetExec"
}

# ─────────────────────────────────────────────────────────────
# BLOQUE 5 — Coercion tools (PetitPotam, Coercer, PrinterBug)
# ─────────────────────────────────────────────────────────────
section "BLOQUE 5 — Herramientas de coerción NTLM..."

# PetitPotam
curl -s -o /opt/redteam/PetitPotam.py \
    https://raw.githubusercontent.com/topotam/PetitPotam/main/PetitPotam.py
ok "PetitPotam descargado → /opt/redteam/PetitPotam.py"

# Coercer
pip install coercer --break-system-packages -q 2>/dev/null && ok "Coercer instalado" || {
    git clone -q https://github.com/p0dalirius/Coercer.git $TOOLS_DIR/Coercer 2>/dev/null
    pip install -r $TOOLS_DIR/Coercer/requirements.txt --break-system-packages -q 2>/dev/null
    ok "Coercer instalado desde git"
}

# PrinterBug (SpoolSample)
git clone -q https://github.com/dirkjanm/krbrelayx.git $TOOLS_DIR/krbrelayx 2>/dev/null || \
    git -C $TOOLS_DIR/krbrelayx pull -q 2>/dev/null
ok "krbrelayx (printerbug) → $TOOLS_DIR/krbrelayx"

# ─────────────────────────────────────────────────────────────
# BLOQUE 6 — Ligolo-ng (Pivoting)
# ─────────────────────────────────────────────────────────────
section "BLOQUE 6 — Ligolo-ng v0.7.5..."

LIGOLO_VERSION="0.7.5"
LIGOLO_DIR="/opt/ligolo"
mkdir -p $LIGOLO_DIR

if [ ! -f "$LIGOLO_DIR/proxy" ]; then
    info "Descargando Ligolo-ng proxy (Linux amd64)..."
    curl -sL "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_proxy_${LIGOLO_VERSION}_linux_amd64.tar.gz" \
        -o /tmp/ligolo_proxy.tar.gz
    tar -xzf /tmp/ligolo_proxy.tar.gz -C $LIGOLO_DIR
    chmod +x $LIGOLO_DIR/proxy
    ok "Ligolo-ng proxy → $LIGOLO_DIR/proxy"
else
    ok "Ligolo-ng proxy ya existe"
fi

if [ ! -f "$LIGOLO_DIR/agent" ]; then
    info "Descargando Ligolo-ng agent (Linux amd64)..."
    curl -sL "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_agent_${LIGOLO_VERSION}_linux_amd64.tar.gz" \
        -o /tmp/ligolo_agent.tar.gz
    tar -xzf /tmp/ligolo_agent.tar.gz -C $LIGOLO_DIR
    chmod +x $LIGOLO_DIR/agent
    ok "Ligolo-ng agent Linux → $LIGOLO_DIR/agent"
else
    ok "Ligolo-ng agent ya existe"
fi

# Agent Windows (para pivoting a Windows)
if [ ! -f "$LIGOLO_DIR/agent.exe" ]; then
    info "Descargando Ligolo-ng agent (Windows amd64)..."
    curl -sL "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_agent_${LIGOLO_VERSION}_windows_amd64.zip" \
        -o /tmp/ligolo_agent_win.zip
    unzip -q /tmp/ligolo_agent_win.zip -d $LIGOLO_DIR
    ok "Ligolo-ng agent Windows → $LIGOLO_DIR/agent.exe"
else
    ok "Ligolo-ng agent Windows ya existe"
fi

# ─────────────────────────────────────────────────────────────
# BLOQUE 7 — Kerbrute
# ─────────────────────────────────────────────────────────────
section "BLOQUE 7 — Kerbrute..."

if [ ! -f "/opt/redteam/kerbrute" ]; then
    curl -sL "https://github.com/ropnop/kerbrute/releases/latest/download/kerbrute_linux_amd64" \
        -o /opt/redteam/kerbrute
    chmod +x /opt/redteam/kerbrute
    ok "Kerbrute → /opt/redteam/kerbrute"
else
    ok "Kerbrute ya existe"
fi

# ─────────────────────────────────────────────────────────────
# BLOQUE 8 — PowerShell scripts (PowerView, PrivescCheck, PEASS)
# ─────────────────────────────────────────────────────────────
section "BLOQUE 8 — Scripts PowerShell y PEASS..."

mkdir -p $TOOLS_DIR/powershell

# PowerView
curl -sL "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1" \
    -o $TOOLS_DIR/powershell/PowerView.ps1
ok "PowerView → $TOOLS_DIR/powershell/PowerView.ps1"

# PrivescCheck
curl -sL "https://raw.githubusercontent.com/itm4n/PrivescCheck/master/src/PrivescCheck.ps1" \
    -o $TOOLS_DIR/powershell/PrivescCheck.ps1
ok "PrivescCheck → $TOOLS_DIR/powershell/PrivescCheck.ps1"

# PEASS-ng (WinPEAS + LinPEAS)
mkdir -p $TOOLS_DIR/peass
curl -sL "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx64.exe" \
    -o $TOOLS_DIR/peass/winPEASx64.exe
curl -sL "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh" \
    -o $TOOLS_DIR/peass/linpeas.sh
chmod +x $TOOLS_DIR/peass/linpeas.sh
ok "WinPEAS + LinPEAS → $TOOLS_DIR/peass/"

# ─────────────────────────────────────────────────────────────
# BLOQUE 9 — Rubeus (Windows binary — referencia)
# ─────────────────────────────────────────────────────────────
section "BLOQUE 9 — Rubeus (binario Windows)..."

mkdir -p $TOOLS_DIR/windows
curl -sL "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe" \
    -o $TOOLS_DIR/windows/Rubeus.exe
ok "Rubeus → $TOOLS_DIR/windows/Rubeus.exe"

# SharpHound (BloodHound collector)
curl -sL "https://github.com/BloodHoundAD/SharpHound/releases/latest/download/SharpHound.exe" \
    -o $TOOLS_DIR/windows/SharpHound.exe
ok "SharpHound → $TOOLS_DIR/windows/SharpHound.exe"

# ─────────────────────────────────────────────────────────────
# BLOQUE 10 — Sliver C2
# ─────────────────────────────────────────────────────────────
section "BLOQUE 10 — Sliver C2..."

if command -v sliver &>/dev/null; then
    ok "Sliver ya instalado: $(sliver version 2>/dev/null | head -1)"
else
    info "Instalando Sliver C2..."
    curl -sL https://sliver.sh/install | sudo bash
    ok "Sliver instalado"
fi

# ─────────────────────────────────────────────────────────────
# BLOQUE 11 — Configuración de aliases útiles
# ─────────────────────────────────────────────────────────────
section "BLOQUE 11 — Configurando aliases..."

cat >> /home/kali/.zshrc << 'ALIASES'

# ─────────────────────────────────────────────────────────────
# RED TEAM OPS ROADMAP — Aliases
# ─────────────────────────────────────────────────────────────
alias petitpotam='python3 /opt/redteam/PetitPotam.py'
alias kerbrute='/opt/redteam/kerbrute'
alias ligolo-proxy='/opt/ligolo/proxy'
alias ligolo-agent='/opt/ligolo/agent'
alias winpeas='/opt/redteam/peass/winPEASx64.exe'
alias linpeas='/opt/redteam/peass/linpeas.sh'
alias powerview='cat /opt/redteam/powershell/PowerView.ps1'

# Ligolo-ng — setup rápido
alias ligolo-setup='sudo ip tuntap add user $(whoami) mode tun ligolo 2>/dev/null; sudo ip link set ligolo up; echo "[+] Interface ligolo lista"'
alias ligolo-route='sudo ip route add'

# Sliver
alias sliver-start='sudo systemctl start sliver && sliver'
ALIASES

ok "Aliases añadidos a .zshrc"

# ─────────────────────────────────────────────────────────────
# BLOQUE 12 — Verificación final
# ─────────────────────────────────────────────────────────────
section "BLOQUE 12 — Verificación del arsenal..."

echo ""
tools=(
    "nmap:nmap --version | head -1"
    "evil-winrm:evil-winrm --version"
    "certipy-ad:certipy-ad --version 2>/dev/null | head -1"
    "nxc:nxc --version 2>/dev/null | head -1"
    "impacket:impacket-secretsdump --help 2>/dev/null | head -1"
    "bloodhound:bloodhound --version 2>/dev/null | head -1"
    "responder:responder --version 2>/dev/null | head -1"
    "kerbrute:/opt/redteam/kerbrute version 2>/dev/null | head -1"
    "ligolo-proxy:/opt/ligolo/proxy --version 2>/dev/null | head -1"
)

for tool in "${tools[@]}"; do
    name="${tool%%:*}"
    cmd="${tool##*:}"
    if eval "$cmd" &>/dev/null; then
        ok "$name ✅"
    else
        err "$name ❌ — revisar instalación"
    fi
done

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  Arsenal listo — estructura en /opt/redteam/${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${YELLOW}  Directorios:${NC}"
echo -e "    /opt/ligolo/          → Ligolo-ng proxy + agents"
echo -e "    /opt/redteam/windows/ → Rubeus, SharpHound"
echo -e "    /opt/redteam/peass/   → WinPEAS, LinPEAS"
echo -e "    /opt/redteam/powershell/ → PowerView, PrivescCheck"
echo -e "    /opt/redteam/         → PetitPotam, Kerbrute, Coercer"
echo ""
echo -e "${YELLOW}  Aliases disponibles (recargar shell: source ~/.zshrc):${NC}"
echo -e "    petitpotam, kerbrute, ligolo-proxy, ligolo-agent"
echo -e "    ligolo-setup, winpeas, linpeas"
echo ""
