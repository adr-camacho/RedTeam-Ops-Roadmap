#!/bin/bash
# ============================================================
#  RED TEAM OPS ROADMAP — Lab Start Script
#  Autor: Adrian Camacho | Version: 2.0 | Junio 2026
#  Uso: ./lab_start.sh [lab-number]
#  Ejemplo: ./lab_start.sh 07
#
#  Changelog v2.0:
#    - Labs 04-07 añadidos
#    - Verificacion WKSTN usa nxc smb en lugar de nmap ICMP
#      (Windows 11 bloquea ICMP tras reinicio)
#    - bloodyad añadido a herramientas comunes
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
# Configuracion por lab
# ─────────────────────────────────────────────────────────────
lab_config() {
    case $LAB in
        "01")
            LAB_NAME="GHOST FOREST — Kerberos Abuse (APT29)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_PORT=443
            CRED_INICIAL="ceo.martinez : Direccion2024!"
            VECTORES="AS-REP Roasting → Kerberoasting → DCSync"
            ;;
        "02")
            LAB_NAME="SILENT BRIDGE — Web RCE + Pivoting (APT41)"
            TARGETS=("10.0.2.200:PROD" "10.0.3.150:GIT" "10.0.3.7:PC-01")
            NEEDS_LIGOLO=true
            LIGOLO_NETWORK="10.0.3.0/24"
            SLIVER_PORT=443
            CRED_INICIAL="CVE-2019-12840 → Webmin RCE"
            VECTORES="WebRCE → Ligolo pivoting → Git creds → AD"
            ;;
        "03")
            LAB_NAME="DARK GATE — ADCS Abuse (APT29)"
            TARGETS=("10.0.2.10:DC-01")
            NEEDS_LIGOLO=false
            SLIVER_PORT=443
            CRED_INICIAL="fin.garcia : Finance2024!"
            VECTORES="ESC1 → ESC4 → ESC8 → NTLM Relay"
            ;;
        "04")
            LAB_NAME="IRON FOREST — ACL + DCSync (APT28)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_PORT=443
            CRED_INICIAL="helpdesk.ruiz : Helpdesk2024!"
            VECTORES="BloodHound → WriteDACL → DCSync → ADIDNS"
            ;;
        "05")
            LAB_NAME="SILVER CHAIN — Delegation + Tickets (APT28)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_PORT=443
            CRED_INICIAL="helpdesk.ruiz : Helpdesk2024!"
            VECTORES="RBCD → S4U2Self → Silver Ticket → Diamond Ticket"
            ;;
        "06")
            LAB_NAME="BLACK POLICY — Cross-Forest + GPO (APT28)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.11:DC-02" "10.0.2.13:DC-03" "10.0.2.14:DC-04" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_PORT=8443
            CRED_INICIAL="helpdesk.ruiz : Helpdesk2024!"
            VECTORES="SID History → Cross-Forest Trust → GPO Abuse → DSInternals"
            ;;
        "07")
            LAB_NAME="SHADOW VAULT — LAPS DPAPI (APT28)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_PORT=8443
            CRED_INICIAL="helpdesk.ruiz : Helpdesk2024!"
            VECTORES="LAPS → LAPSToolkit → contrasena admin local | DPAPI → SharpDPAPI → credenciales cifradas | Shadow Credentials → LSASS dump sin Mimikatz"
            ;;
        *)
            err "Lab no reconocido: $LAB"
            echo "    Labs disponibles: 01, 02, 03, 04, 05, 06, 07"
            exit 1
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────
# Verificar conectividad con targets
# FIX v2.0: Workstations usan nxc smb (ICMP bloqueado tras reinicio en Win11)
# ─────────────────────────────────────────────────────────────
check_targets() {
    section "Verificando conectividad con targets..."
    local all_ok=true

    for target in "${TARGETS[@]}"; do
        IP="${target%%:*}"
        NAME="${target##*:}"

        # Workstations: verificar via SMB (ICMP bloqueado en Windows 11 tras reinicio)
        # DCs y Linux: verificar via nmap ping
        if [[ "$NAME" == WKSTN* ]] || [[ "$NAME" == PC* ]]; then
            if nxc smb "$IP" 2>/dev/null | grep -q "SMB"; then
                ok "$NAME ($IP) — accesible via SMB ✅"
            else
                err "$NAME ($IP) — NO responde ❌ — ¿VM encendida? ¿Firewall?"
                err "  Fix: Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False"
                all_ok=false
            fi
        else
            if nmap -sn -n --unprivileged "$IP" 2>/dev/null | grep -q "Host is up"; then
                ok "$NAME ($IP) — accesible ✅"
            else
                err "$NAME ($IP) — NO responde ❌ — ¿VM encendida?"
                all_ok=false
            fi
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

        if [ ! -f "/opt/ligolo/proxy" ]; then
            err "Ligolo-ng no encontrado en /opt/ligolo/ — ejecuta arsenal_setup.sh primero"
            return
        fi

        if ! ip link show ligolo &>/dev/null; then
            sudo ip tuntap add user $(whoami) mode tun ligolo 2>/dev/null
            sudo ip link set ligolo up
            ok "Interfaz ligolo creada"
        else
            ok "Interfaz ligolo ya existe"
        fi

        if ! ip route | grep -q "$LIGOLO_NETWORK"; then
            sudo ip route add "$LIGOLO_NETWORK" dev ligolo 2>/dev/null
            ok "Ruta $LIGOLO_NETWORK añadida via ligolo"
        else
            ok "Ruta $LIGOLO_NETWORK ya existe"
        fi

        echo ""
        info "Para activar el tunel:"
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
        ok "Sliver ya esta corriendo"
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
# Verificar herramientas criticas del lab
# ─────────────────────────────────────────────────────────────
check_tools() {
    section "Verificando herramientas..."

    # Herramientas comunes a todos los labs
    common_tools=("nmap" "evil-winrm" "nxc" "impacket-secretsdump" "bloodyad")
    for tool in "${common_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            ok "$tool ✅"
        else
            err "$tool ❌"
        fi
    done

    # Herramientas especificas por lab
    case $LAB in
        "02")
            if [ -f "/opt/ligolo/proxy" ]; then ok "ligolo-ng proxy ✅"; else err "ligolo-ng proxy ❌"; fi
            ;;
        "03")
            command -v certipy-ad &>/dev/null && ok "certipy-ad ✅" || err "certipy-ad ❌"
            [ -f "/opt/redteam/PetitPotam.py" ] && ok "PetitPotam ✅" || err "PetitPotam ❌"
            ;;
        "04"|"05")
            command -v certipy-ad &>/dev/null && ok "certipy-ad ✅" || err "certipy-ad ❌"
            [ -f "/opt/redteam/windows/SharpHound.exe" ] && ok "SharpHound ✅" || err "SharpHound ❌"
            ;;
        "06")
            command -v certipy-ad &>/dev/null && ok "certipy-ad ✅" || err "certipy-ad ❌"
            [ -d "/opt/redteam/pyGPOAbuse" ] && ok "pyGPOAbuse ✅" || err "pyGPOAbuse ❌"
            [ -f "/opt/redteam/windows/DSInternals_module.zip" ] && ok "DSInternals ✅" || err "DSInternals ❌"
            ;;
        "07")
            command -v pywhisker &>/dev/null && ok "pywhisker ✅" || err "pywhisker ❌"
            command -v certipy-ad &>/dev/null && ok "certipy-ad ✅" || err "certipy-ad ❌"
            [ -f "/opt/redteam/windows/LAPSToolkit.ps1" ] && ok "LAPSToolkit ✅" || err "LAPSToolkit ❌"
            command -v ldeep &>/dev/null && ok "ldeep ✅" || err "ldeep ❌"
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
    echo -e "  ${YELLOW}Credenciales de entrada:${NC}"
    echo -e "    $CRED_INICIAL"
    echo ""
    echo -e "  ${YELLOW}Vectores planificados:${NC}"
    echo -e "    $VECTORES"
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
