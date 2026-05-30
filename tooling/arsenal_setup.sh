#!/bin/bash
# =============================================================
# arsenal_setup.sh — Setup del arsenal ofensivo en Kali Linux
# Red Team Ops Roadmap — atackcorp.local
# Autor: Adrián Camacho | Versión: 2.0 | Mayo 2026
# =============================================================

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }

echo -e "${RED}╔══════════════════════════════════════════════════════╗"
echo "║       Arsenal Setup — Red Team Ops Roadmap          ║"
echo -e "╚══════════════════════════════════════════════════════╝${NC}"

sudo mkdir -p /opt/redteam/{windows,linux,scripts,krbrelayx}
sudo chown -R kali:kali /opt/redteam
mkdir -p ~/tools/ad/bloodhound-ce ~/tools/c2/sliver

info "Instalando herramientas base..."
sudo apt update -qq && sudo apt install -y -qq evil-winrm crackmapexec impacket-scripts responder nmap masscan gobuster feroxbuster john hashcat seclists enum4linux-ng krb5-user chisel mingw-w64 nasm python3-pip git curl unzip jq
success "Herramientas base OK"

info "Instalando herramientas Python..."
pip install --break-system-packages -q bloodhound certipy-ad bloodyad pywhisker
success "Python tools OK"

info "SharpHound v2.5.9..."
if [ ! -f /opt/redteam/windows/SharpHound.exe ] || [ $(stat -c%s /opt/redteam/windows/SharpHound.exe) -lt 1000 ]; then
    curl -sL https://github.com/BloodHoundAD/SharpHound/releases/download/v2.5.9/SharpHound-v2.5.9.zip -o /tmp/sh.zip
    unzip -q /tmp/sh.zip -d /tmp/sh/ && sudo cp /tmp/sh/SharpHound.exe /opt/redteam/windows/ && rm -rf /tmp/sh /tmp/sh.zip
    success "SharpHound v2.5.9 instalado"
else
    success "SharpHound ya instalado"
fi

info "krbrelayx / dnstool.py..."
[ ! -f /opt/redteam/krbrelayx/dnstool.py ] && git clone -q https://github.com/dirkjanm/krbrelayx.git /opt/redteam/krbrelayx/ && success "krbrelayx instalado" || success "krbrelayx ya instalado"

info "PetitPotam..."
[ ! -f /opt/redteam/PetitPotam.py ] && curl -sL https://raw.githubusercontent.com/topotam/PetitPotam/main/PetitPotam.py -o /opt/redteam/PetitPotam.py && success "PetitPotam instalado" || success "PetitPotam ya instalado"

info "Ligolo-ng v0.7.5..."
if [ ! -f /opt/ligolo/proxy ]; then
    mkdir -p /opt/ligolo
    curl -sL "https://github.com/nicocha30/ligolo-ng/releases/download/v0.7.5/ligolo-ng_proxy_0.7.5_linux_amd64.tar.gz" -o /tmp/lp.tar.gz
    curl -sL "https://github.com/nicocha30/ligolo-ng/releases/download/v0.7.5/ligolo-ng_agent_0.7.5_linux_amd64.tar.gz" -o /tmp/la.tar.gz
    tar -xzf /tmp/lp.tar.gz -C /opt/ligolo/ && tar -xzf /tmp/la.tar.gz -C /opt/ligolo/
    rm -f /tmp/lp.tar.gz /tmp/la.tar.gz
    success "Ligolo-ng instalado"
else
    success "Ligolo-ng ya instalado"
fi

info "Sliver C2..."
systemctl is-active --quiet sliver 2>/dev/null && success "Sliver activo" || warn "Sliver no activo — instalar: curl https://sliver.sh/install | sudo bash"

info "Rubeus..."
[ -f /opt/redteam/windows/Rubeus.exe ] && [ $(stat -c%s /opt/redteam/windows/Rubeus.exe) -gt 1000 ] && success "Rubeus OK" || warn "Rubeus pendiente — descargar manualmente en /opt/redteam/windows/Rubeus.exe"

[ -f /usr/share/wordlists/rockyou.txt.gz ] && sudo gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null; success "rockyou.txt OK"

[ -f /usr/local/bin/sliver ] && ln -sf /usr/local/bin/sliver ~/tools/c2/sliver/sliver 2>/dev/null || true
[ -f /usr/local/bin/sliver-client ] && ln -sf /usr/local/bin/sliver-client ~/tools/c2/sliver/sliver-client 2>/dev/null || true

echo -e "\n${RED}═══════════════════════════════════════════════════════${NC}"
echo -e "${RED} Arsenal Setup completado${NC}"
echo -e "${CYAN}  /opt/redteam/windows/SharpHound.exe${NC}"
echo -e "${CYAN}  /opt/redteam/krbrelayx/dnstool.py${NC}"
echo -e "${CYAN}  /opt/redteam/PetitPotam.py${NC}"
echo -e "${CYAN}  /opt/ligolo/proxy + agent${NC}"
echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
