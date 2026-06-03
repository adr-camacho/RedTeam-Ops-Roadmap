#!/bin/bash
# ============================================================
#  RED TEAM OPS ROADMAP — Kali Network Check
#  Autor: Adrián Camacho
#  Uso: ./kali_network_check.sh
#
#  Verifica el estado de red de Kali antes de empezar una sesión:
#    - IP de Kali en cada interfaz
#    - Conectividad con todas las VMs de todos los labs
#    - Estado de Ligolo-ng
#    - Estado de Sliver
# ============================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "    ${GREEN}[+]${NC} $1"; }
err()  { echo -e "    ${RED}[!]${NC} $1"; }
info() { echo -e "    ${YELLOW}[*]${NC} $1"; }

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  RED TEAM OPS ROADMAP — Network Check${NC}"
echo -e "${CYAN}  $(date '+%Y-%m-%d %H:%M')${NC}"
echo -e "${CYAN}============================================================${NC}"

# ─────────────────────────────────────────────────────────────
# IPs de Kali
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}[*] Interfaces de Kali:${NC}"
ip -4 addr | grep inet | grep -v "127.0.0" | awk '{print "    "$2" ("$NF")"}' | sed 's/scope.*//'

# Verificar IP fija en LabRedTeam
if ip addr | grep -q "10.0.2.9"; then
    ok "IP fija 10.0.2.9 en LabRedTeam ✅"
else
    err "IP 10.0.2.9 NO encontrada — verificar NetworkManager"
fi

# ─────────────────────────────────────────────────────────────
# Conectividad con VMs de labs
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}[*] Estado de VMs por lab:${NC}"

# Infraestructura principal (Labs 01-06)
declare -A CORE_VMS=(
    ["DC-01 — atackcorp.local"]="10.0.2.10"
    ["DC-02 — corp.local"]="10.0.2.11"
    ["DC-03 — child.atackcorp.local"]="10.0.2.13"
    ["DC-04 — ext.local"]="10.0.2.14"
    ["WKSTN-01 — atackcorp.local"]="10.0.2.8"
    ["WKSTN-02 — corp.local"]="10.0.2.12"
)

echo ""
echo -e "  ${CYAN}Infraestructura principal (10.0.2.0/24):${NC}"
for name in "DC-01 — atackcorp.local" "DC-02 — corp.local" "DC-03 — child.atackcorp.local" "DC-04 — ext.local" "WKSTN-01 — atackcorp.local" "WKSTN-02 — corp.local"; do
    ip="${CORE_VMS[$name]}"
    if ping -c 1 -W 1 "$ip" &>/dev/null 2>&1; then
        ok "$name ($ip) — ENCENDIDA ✅"
    else
        info "$name ($ip) — apagada"
    fi
done

# Red interna Lab-02
echo ""
echo -e "  ${CYAN}Red interna Lab-02 (10.0.3.0/24 via Ligolo):${NC}"
declare -A LAB02_VMS=(
    ["PROD — Linux Server"]="10.0.3.10"
    ["GIT — Linux Server"]="10.0.3.11"
    ["PC-01 — Windows"]="10.0.3.20"
)
for name in "PROD — Linux Server" "GIT — Linux Server" "PC-01 — Windows"; do
    ip="${LAB02_VMS[$name]}"
    if ping -c 1 -W 1 "$ip" &>/dev/null 2>&1; then
        ok "$name ($ip) — ENCENDIDA ✅"
    else
        info "$name ($ip) — apagada (solo accesible via Ligolo tunnel)"
    fi
done

# ─────────────────────────────────────────────────────────────
# Estado Ligolo-ng
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}[*] Estado Ligolo-ng:${NC}"

if ip link show ligolo &>/dev/null; then
    STATE=$(ip link show ligolo | grep -oP "state \K\w+")
    if [ "$STATE" = "UP" ]; then
        ok "Interfaz ligolo UP ✅"
    else
        info "Interfaz ligolo existe pero está $STATE"
    fi

    ROUTES=$(ip route | grep ligolo)
    if [ -n "$ROUTES" ]; then
        ok "Rutas activas via ligolo:"
        echo "$ROUTES" | while read r; do echo "      $r"; done
    else
        info "Sin rutas activas via ligolo"
    fi
else
    info "Interfaz ligolo no existe — usar lab_start.sh para crearla"
fi

# Verificar si proxy está corriendo
if pgrep -f "ligolo.*proxy" > /dev/null 2>&1; then
    ok "Ligolo-ng proxy corriendo ✅"
else
    info "Ligolo-ng proxy no está corriendo"
fi

# ─────────────────────────────────────────────────────────────
# Estado Sliver
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}[*] Estado Sliver C2:${NC}"

if systemctl is-active --quiet sliver 2>/dev/null; then
    ok "Sliver corriendo como servicio ✅"
elif pgrep -x sliver > /dev/null 2>&1; then
    ok "Sliver corriendo (proceso manual) ✅"
else
    info "Sliver no está corriendo — usar: sudo systemctl start sliver"
fi

# ─────────────────────────────────────────────────────────────
# Puertos en uso
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}[*] Puertos activos relevantes:${NC}"
sudo ss -tlnp 2>/dev/null | grep -E ":(443|445|4444|8080|8443|11601|5985) " | while read line; do
    echo "    $line"
done

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  Check completado${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
