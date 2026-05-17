#!/bin/bash
# ============================================================
#  RED TEAM OPS ROADMAP — Lab Stop Script
#  Autor: Adrián Camacho
#  Uso: ./lab_stop.sh
#
#  Limpia el estado de Kali entre labs o sesiones:
#    - Mata listeners y procesos activos
#    - Elimina interfaz Ligolo-ng
#    - Limpia tickets Kerberos (ccache)
#    - Elimina archivos temporales sensibles
#    - Muestra resumen del estado limpio
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ok()      { echo -e "    ${GREEN}[+]${NC} $1"; }
info()    { echo -e "    ${YELLOW}[*]${NC} $1"; }
err()     { echo -e "    ${RED}[!]${NC} $1"; }
section() { echo -e "\n${CYAN}[*] $1${NC}"; }

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  RED TEAM OPS ROADMAP — Lab Stop / Cleanup${NC}"
echo -e "${CYAN}  $(date '+%Y-%m-%d %H:%M')${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# ─────────────────────────────────────────────────────────────
# Matar procesos activos del lab
# ─────────────────────────────────────────────────────────────
section "Matando procesos activos..."

# Ligolo-ng proxy
if pgrep -x "proxy" > /dev/null 2>&1; then
    pkill -x "proxy" 2>/dev/null
    ok "Ligolo-ng proxy detenido"
else
    info "Ligolo-ng proxy no estaba corriendo"
fi

# Netcat listeners
if pgrep -x "nc" > /dev/null 2>&1; then
    pkill -x "nc" 2>/dev/null
    ok "Netcat listeners detenidos"
else
    info "No había listeners netcat activos"
fi

# Certipy relay
if pgrep -f "certipy" > /dev/null 2>&1; then
    pkill -f "certipy" 2>/dev/null
    ok "Certipy relay detenido"
fi

# ntlmrelayx
if pgrep -f "ntlmrelayx" > /dev/null 2>&1; then
    pkill -f "ntlmrelayx" 2>/dev/null
    ok "ntlmrelayx detenido"
fi

# Responder
if pgrep -f "Responder" > /dev/null 2>&1; then
    pkill -f "Responder" 2>/dev/null
    ok "Responder detenido"
fi

# Liberar puertos críticos
for port in 445 4444 4445 8080 8443 11601; do
    if sudo fuser "$port/tcp" > /dev/null 2>&1; then
        sudo fuser -k "$port/tcp" 2>/dev/null
        ok "Puerto $port liberado"
    fi
done

# ─────────────────────────────────────────────────────────────
# Limpiar interfaz Ligolo-ng
# ─────────────────────────────────────────────────────────────
section "Limpiando interfaz Ligolo-ng..."

if ip link show ligolo &>/dev/null; then
    sudo ip link set ligolo down 2>/dev/null
    sudo ip link delete ligolo 2>/dev/null
    ok "Interfaz ligolo eliminada"
else
    info "Interfaz ligolo no existía"
fi

# Eliminar rutas residuales de labs
for route in "10.0.3.0/24" "10.0.4.0/24" "192.168.100.0/24"; do
    if ip route | grep -q "$route"; then
        sudo ip route del "$route" 2>/dev/null
        ok "Ruta $route eliminada"
    fi
done

# ─────────────────────────────────────────────────────────────
# Limpiar tickets Kerberos
# ─────────────────────────────────────────────────────────────
section "Limpiando tickets Kerberos..."

# Eliminar ccache files
find /tmp -name "*.ccache" 2>/dev/null | while read f; do
    rm -f "$f"
    ok "Eliminado: $f"
done

# Limpiar KRB5CCNAME
unset KRB5CCNAME
ok "KRB5CCNAME limpiado"

# ─────────────────────────────────────────────────────────────
# Limpiar archivos temporales sensibles
# ─────────────────────────────────────────────────────────────
section "Limpiando archivos temporales sensibles..."

# PFX files (certificados)
find ~ /tmp -name "*.pfx" 2>/dev/null | while read f; do
    rm -f "$f"
    ok "PFX eliminado: $f"
done

# SAM/SYSTEM dumps
find ~ /tmp -name "*.bak" -o -name "sam.bak" -o -name "system.bak" 2>/dev/null | while read f; do
    rm -f "$f"
    ok "Dump eliminado: $f"
done

# JSON de Certipy (configuraciones de plantillas)
find ~ -name "*.json" -newer /etc/passwd 2>/dev/null | grep -i "vulner\|template\|certipy" | while read f; do
    rm -f "$f"
    ok "JSON eliminado: $f"
done

# Exploits temporales
find /tmp -name "*.py" -o -name "*.exe" -o -name "*.bin" 2>/dev/null | while read f; do
    rm -f "$f"
    ok "Temporal eliminado: $f"
done

# ─────────────────────────────────────────────────────────────
# Estado final
# ─────────────────────────────────────────────────────────────
section "Estado final del sistema..."

# Verificar puertos libres
for port in 445 4444 11601; do
    if ! sudo ss -tlnp | grep -q ":$port "; then
        ok "Puerto $port libre ✅"
    else
        err "Puerto $port aún ocupado ❌"
    fi
done

# Verificar interfaz ligolo
if ! ip link show ligolo &>/dev/null; then
    ok "Interfaz ligolo eliminada ✅"
else
    err "Interfaz ligolo aún existe ❌"
fi

# Verificar ccache
if ! find /tmp -name "*.ccache" 2>/dev/null | grep -q .; then
    ok "Sin tickets Kerberos residuales ✅"
fi

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  Entorno limpio — listo para el siguiente lab${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "  ${YELLOW}Nota:${NC} Sliver sigue corriendo como servicio."
echo -e "  Para detenerlo: ${CYAN}sudo systemctl stop sliver${NC}"
echo ""
