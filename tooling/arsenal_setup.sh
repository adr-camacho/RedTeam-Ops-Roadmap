#!/bin/bash
# =============================================================
# arsenal_setup.sh — Setup del arsenal ofensivo en Kali Linux
# Red Team Ops Roadmap — atackcorp.local
# Autor: Adrian Camacho | Version: 2.3 | Junio 2026
# Changelog v2.3:
#   - Reemplazado crackmapexec por netexec (nxc)
#   - Añadido LAPSToolkit (Lab-07)
#   - Añadido nanodump (aviso manual — sin releases publicas)
#   - Añadido SharpDPAPI (aviso manual — GhostPack)
#   - Añadido ldeep via pip
#   - Nota: certipy-ad ya incluido (pip) — no instalar python3-certipy
#   - Nota: pywhisker ya incluido (pip)
# Changelog v2.2:
#   - Añadido pyGPOAbuse (Lab-06)
# Changelog v2.1:
#   - Añadido bloodyad, mimikatz, DSInternals
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

# --- Herramientas base (v2.3: netexec en lugar de crackmapexec) ---
info "Instalando herramientas base..."
sudo apt update -qq && sudo apt install -y -qq \
    evil-winrm netexec impacket-scripts responder \
    nmap masscan gobuster feroxbuster john hashcat \
    seclists enum4linux-ng krb5-user chisel \
    mingw-w64 nasm python3-pip git curl unzip jq bloodyad
success "Herramientas base OK"

# --- Herramientas Python ---
# NOTA: certipy-ad v5.0.4 — NO instalar python3-certipy (conflicto de paquetes)
# NOTA: pywhisker v0.1.2 — requiere --use-ldaps en WS2025
info "Instalando herramientas Python..."
pip install --break-system-packages -q \
    bloodhound \
    certipy-ad \
    pywhisker \
    ldeep \
    pylaps
success "Python tools OK (certipy-ad, pywhisker, ldeep, pylaps)"

# --- SharpHound v2.5.9 ---
info "SharpHound v2.5.9..."
if [ ! -f /opt/redteam/windows/SharpHound.exe ] || [ $(stat -c%s /opt/redteam/windows/SharpHound.exe) -lt 1000 ]; then
    curl -sL https://github.com/BloodHoundAD/SharpHound/releases/download/v2.5.9/SharpHound-v2.5.9.zip -o /tmp/sh.zip
    unzip -q /tmp/sh.zip -d /tmp/sh/ && sudo cp /tmp/sh/SharpHound.exe /opt/redteam/windows/ && rm -rf /tmp/sh /tmp/sh.zip
    success "SharpHound v2.5.9 instalado"
else
    success "SharpHound ya instalado"
fi

# --- mimikatz ---
info "mimikatz (desde Kali built-in)..."
if [ ! -f /opt/redteam/windows/mimikatz.exe ]; then
    if [ -f /usr/share/windows-resources/mimikatz/x64/mimikatz.exe ]; then
        sudo cp /usr/share/windows-resources/mimikatz/x64/mimikatz.exe /opt/redteam/windows/
        success "mimikatz.exe copiado"
    else
        warn "mimikatz no encontrado — instalar kali-tools-windows-resources"
    fi
else
    success "mimikatz.exe ya en /opt/redteam/windows/"
fi

# --- DSInternals v4.14 ---
info "DSInternals v4.14..."
if [ ! -f /opt/redteam/windows/DSInternals_module.zip ]; then
    curl -sL https://github.com/MichaelGrafnetter/DSInternals/releases/download/v4.14/DSInternals_v4.14.zip -o /tmp/DSInternals.zip
    unzip -q /tmp/DSInternals.zip -d /tmp/DSInternals/
    cd /tmp && zip -r DSInternals_module.zip DSInternals/DSInternals/ && cd -
    sudo cp /tmp/DSInternals_module.zip /opt/redteam/windows/
    rm -rf /tmp/DSInternals /tmp/DSInternals.zip /tmp/DSInternals_module.zip
    success "DSInternals v4.14 instalado"
else
    success "DSInternals ya instalado"
fi

# --- LAPSToolkit (Lab-07) ---
info "LAPSToolkit (LAPS password extraction — Lab-07+)..."
if [ ! -f /opt/redteam/windows/LAPSToolkit.ps1 ]; then
    curl -sL https://raw.githubusercontent.com/leoloobeek/LAPSToolkit/master/LAPSToolkit.ps1 -o /opt/redteam/windows/LAPSToolkit.ps1
    success "LAPSToolkit instalado en /opt/redteam/windows/"
else
    success "LAPSToolkit ya instalado"
fi

# --- SharpDPAPI (Lab-07) ---
info "SharpDPAPI (DPAPI credential extraction — Lab-07+)..."
if [ ! -f /opt/redteam/windows/SharpDPAPI.exe ]; then
    warn "SharpDPAPI requiere descarga manual (GhostPack no tiene releases publicas):"
    warn "  https://github.com/GhostPack/SharpDPAPI"
    warn "  Compilar y guardar en /opt/redteam/windows/SharpDPAPI.exe"
    warn "  Alternativa: usar impacket-dpapi (funciona offline desde Kali)"
else
    success "SharpDPAPI ya en /opt/redteam/windows/"
fi

# --- nanodump (Lab-07) ---
info "nanodump (LSASS dump sin Mimikatz — Lab-07+)..."
if [ ! -f /opt/redteam/windows/nanodump.exe ] || [ $(stat -c%s /opt/redteam/windows/nanodump.exe 2>/dev/null || echo 0) -lt 1000 ]; then
    warn "nanodump no tiene releases publicas en GitHub (repositorio sin releases):"
    warn "  https://github.com/fortra/nanodump"
    warn "  Compilar desde fuente o obtener via curso/entorno controlado"
    warn "  Alternativa: lsassy -m comsvcs (bloqueado en Windows 11 23H2+)"
    warn "  NOTA: Windows 11 23H2+ bloquea LSASS dump incluso con PPL=0 (KPP)"
    # Crear archivo vacio para evitar repetir el aviso
    touch /opt/redteam/windows/nanodump.exe
else
    success "nanodump ya en /opt/redteam/windows/"
fi

# --- pyGPOAbuse (Lab-06+) ---
info "Instalando pyGPOAbuse (GPO Abuse — Lab-06+)"
if [ ! -d /opt/redteam/pyGPOAbuse ]; then
    git clone -q https://github.com/Hackndo/pyGPOAbuse.git /opt/redteam/pyGPOAbuse/ && \
    pip install --break-system-packages -q -r /opt/redteam/pyGPOAbuse/requirements.txt && \
    success "pyGPOAbuse instalado" || warn "Error instalando pyGPOAbuse"
else
    success "pyGPOAbuse ya instalado"
fi

# --- krbrelayx / dnstool.py ---
info "krbrelayx / dnstool.py..."
[ ! -f /opt/redteam/krbrelayx/dnstool.py ] && \
    git clone -q https://github.com/dirkjanm/krbrelayx.git /opt/redteam/krbrelayx/ && \
    success "krbrelayx instalado" || success "krbrelayx ya instalado"

# --- PetitPotam ---
info "PetitPotam..."
[ ! -f /opt/redteam/PetitPotam.py ] && \
    curl -sL https://raw.githubusercontent.com/topotam/PetitPotam/main/PetitPotam.py -o /opt/redteam/PetitPotam.py && \
    success "PetitPotam instalado" || success "PetitPotam ya instalado"

# --- Ligolo-ng v0.7.5 ---
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

# --- Sliver C2 ---
info "Sliver C2..."
systemctl is-active --quiet sliver 2>/dev/null && \
    success "Sliver activo" || \
    warn "Sliver no activo — instalar: curl https://sliver.sh/install | sudo bash"

# --- Rubeus ---
info "Rubeus..."
[ -f /opt/redteam/windows/Rubeus.exe ] && \
    [ $(stat -c%s /opt/redteam/windows/Rubeus.exe) -gt 1000 ] && \
    success "Rubeus OK" || \
    warn "Rubeus pendiente — descargar en /opt/redteam/windows/Rubeus.exe"

# --- Wordlists ---
[ -f /usr/share/wordlists/rockyou.txt.gz ] && \
    sudo gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null; \
    success "rockyou.txt OK"

# --- Symlinks Sliver ---
[ -f /usr/local/bin/sliver ] && ln -sf /usr/local/bin/sliver ~/tools/c2/sliver/sliver 2>/dev/null || true
[ -f /usr/local/bin/sliver-client ] && ln -sf /usr/local/bin/sliver-client ~/tools/c2/sliver/sliver-client 2>/dev/null || true

echo -e "\n${RED}═══════════════════════════════════════════════════════${NC}"
echo -e "${RED} Arsenal Setup completado v2.3${NC}"
echo -e "${CYAN}  /opt/redteam/windows/SharpHound.exe${NC}"
echo -e "${CYAN}  /opt/redteam/windows/mimikatz.exe${NC}"
echo -e "${CYAN}  /opt/redteam/windows/DSInternals_module.zip${NC}"
echo -e "${CYAN}  /opt/redteam/windows/LAPSToolkit.ps1${NC}"
echo -e "${CYAN}  /opt/redteam/windows/SharpDPAPI.exe (manual)${NC}"
echo -e "${CYAN}  /opt/redteam/windows/nanodump.exe (manual)${NC}"
echo -e "${CYAN}  /opt/redteam/krbrelayx/dnstool.py${NC}"
echo -e "${CYAN}  /opt/redteam/PetitPotam.py${NC}"
echo -e "${CYAN}  /opt/ligolo/proxy + agent${NC}"
echo -e "${YELLOW}  NOTA: certipy-ad usar 'certipy-ad' (no 'certipy')${NC}"
echo -e "${YELLOW}  NOTA: nanodump bloqueado en Windows 11 23H2+ (KPP)${NC}"
echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
