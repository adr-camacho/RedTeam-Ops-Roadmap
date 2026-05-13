# 🛠️ Arsenal de Herramientas — Red Team Ops Roadmap

> Documentación de todas las herramientas instaladas y utilizadas durante la realización del roadmap.  
> Organizado por categoría funcional, con descripción técnica, uso principal y lab de referencia.

---

## 📋 Índice

1. [C2 Frameworks](#-c2-frameworks)
2. [Enumeración de Active Directory](#-enumeración-de-active-directory)
3. [Ataques de Kerberos y Credenciales](#-ataques-de-kerberos-y-credenciales)
4. [Pivoting y Tunelización](#-pivoting-y-tunelización)
5. [Post-Explotación y Acceso Remoto](#-post-explotación-y-acceso-remoto)
6. [Evasión y Ejecución en Memoria](#-evasión-y-ejecución-en-memoria)
7. [Reconocimiento y Escaneo](#-reconocimiento-y-escaneo)
8. [Wordlists y Diccionarios](#-wordlists-y-diccionarios)
9. [Infraestructura del Lab](#-infraestructura-del-lab)

---

## 🔴 C2 Frameworks

### Sliver (BishopFox)
- **Descripción:** Framework C2 moderno de código abierto. Soporta múltiples protocolos (mTLS, HTTP/S, DNS, WireGuard) y generación dinámica de implantes.
- **Uso en el roadmap:** Reemplaza a Cobalt Strike para simulación de adversarios, gestión de beacons y operaciones de Red Team.
- **Instalación:**
  ```bash
  curl https://sliver.sh/install | sudo bash
  sudo systemctl start sliver
  sliver
  ```
- **Labs:** Lab-01, Phase-03, Phase-04

---

### Havoc C2
- **Descripción:** Framework C2 avanzado con interfaz gráfica, soporte para agentes en C y evasión de EDR mediante técnicas de syscalls directas.
- **Uso en el roadmap:** Operaciones de Red Team con evasión activa de defensas.
- **Instalación:**
  ```bash
  sudo apt install -y golang git build-essential libssl-dev libfontconfig1 mingw-w64 nasm musl-tools
  git clone https://github.com/HavocFramework/Havoc /opt/havoc
  ```
- **Labs:** Phase-03, Phase-04

---

## 🔍 Enumeración de Active Directory

### BloodHound (v9 + AzureHound + SharpHound)
- **Descripción:** Suite de análisis de grafos de Active Directory. Identifica attack paths hacia Domain Admin mediante relaciones entre objetos de AD.
- **Uso en el roadmap:** Mapeo de attack paths, identificación de cuentas con privilegios delegados y relaciones de confianza entre dominios.
- **Instalación:**
  ```bash
  sudo apt install -y bloodhound sharphound
  ```
- **Inicio:**
  ```bash
  sudo neo4j start
  bloodhound
  ```
- **Labs:** Lab-01, Lab-04, Lab-08

---

### PowerView
- **Descripción:** Módulo PowerShell de PowerSploit para enumeración ofensiva de AD. Enumera usuarios, grupos, GPOs, ACLs y trusts.
- **Uso en el roadmap:** Enumeración manual de objetos AD, identificación de ACEs abusables.
- **Instalación:**
  ```bash
  sudo apt install -y powersploit
  # Ruta: /usr/share/windows-resources/powersploit/Recon/PowerView.ps1
  ```
- **Labs:** Lab-01, Lab-04, Lab-05

---

### Adalanche
- **Descripción:** Alternativa open source a BloodHound. Análisis offline de dumps de AD sin necesidad de agente en el dominio.
- **Uso en el roadmap:** Análisis de entornos donde no es posible ejecutar SharpHound.
- **Instalación:**
  ```bash
  wget https://github.com/lkarlslund/Adalanche/releases/latest/download/adalanche-linux-x64 \
    -O /opt/adalanche && chmod +x /opt/adalanche
  ```
- **Labs:** Lab-08, Lab-12

---

### enum4linux-ng
- **Descripción:** Reescritura moderna de enum4linux. Enumera información SMB/RPC: usuarios, shares, políticas de contraseñas.
- **Instalación:**
  ```bash
  sudo apt install -y enum4linux-ng
  ```
- **Labs:** Lab-01, Lab-02

---

## 🎫 Ataques de Kerberos y Credenciales

### Impacket
- **Descripción:** Suite de scripts Python para interacción con protocolos de red Windows (SMB, MSRPC, Kerberos, LDAP).
- **Herramientas clave:**
  | Script | Función |
  |--------|---------|
  | `GetNPUsers.py` | AS-REP Roasting |
  | `GetUserSPNs.py` | Kerberoasting |
  | `secretsdump.py` | Volcado de hashes NTLM via DCSync |
  | `psexec.py` | Ejecución remota vía SMB |
  | `wmiexec.py` | Ejecución remota vía WMI |
  | `ticketer.py` | Forja de tickets Kerberos (Golden/Silver) |
  | `lookupsid.py` | Enumeración de SIDs del dominio |
- **Instalación:**
  ```bash
  sudo apt install -y impacket-scripts
  ```
- **Labs:** Lab-01, Lab-04, Lab-05, Lab-10, Lab-11

---

### Rubeus
- **Descripción:** Herramienta C# para interacción ofensiva con Kerberos. Soporta AS-REP Roasting, Kerberoasting, Pass-the-Ticket, Over-Pass-the-Hash y más.
- **Instalación:**
  ```bash
  mkdir -p /opt/rubeus
  wget https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe \
    -O /opt/rubeus/Rubeus.exe
  ```
- **Labs:** Lab-04, Lab-07, Lab-11, Lab-12

---

### Kerbrute
- **Descripción:** Herramienta Go para enumeración y fuerza bruta de usuarios de Kerberos sin generar eventos de login fallido (4625).
- **Instalación:**
  ```bash
  sudo apt install -y kerbrute
  ```
- **Labs:** Lab-01, Lab-04

---

### Hashcat
- **Descripción:** Cracker de hashes GPU/CPU. Soporta más de 300 tipos de hash incluyendo Kerberos (krb5asrep, krb5tgs), NTLM y NTLMv2.
- **Nota:** En entornos VirtualBox sin GPU, usar John the Ripper como alternativa CPU.
- **Instalación:**
  ```bash
  sudo apt install -y hashcat
  ```
- **Uso típico:**
  ```bash
  hashcat -m 18200 hash.txt /usr/share/wordlists/rockyou.txt  # AS-REP
  hashcat -m 13100 hash.txt /usr/share/wordlists/rockyou.txt  # Kerberoasting
  ```
- **Labs:** Lab-01, Lab-04, Lab-05

---

### John the Ripper
- **Descripción:** Cracker de contraseñas clásico. Alternativa CPU a Hashcat — preferido en entornos VirtualBox sin GPU.
- **Instalación:**
  ```bash
  sudo apt install -y john
  ```
- **Uso típico:**
  ```bash
  john --format=krb5asrep --wordlist=loot/targeted_wordlist.txt loot/asrep_hashes.txt
  john --format=krb5tgs --wordlist=loot/targeted_wordlist.txt loot/kerberoast_hashes.txt
  john hash.txt --show
  ```
- **Labs:** Lab-01, Lab-03

---

## 🔀 Pivoting y Tunelización

### Ligolo-ng
- **Descripción:** Herramienta de tunneling avanzada. Crea interfaces TUN en el atacante para enrutar tráfico a redes internas sin SOCKS proxy.
- **Uso en el roadmap:** Pivoting transparente en redes segmentadas. Más eficiente que Chisel para tráfico masivo.
- **Instalación:**
  ```bash
  mkdir -p /opt/ligolo
  wget https://github.com/nicocha30/ligolo-ng/releases/latest/download/proxy_linux_amd64 \
    -O /opt/ligolo/proxy && chmod +x /opt/ligolo/proxy
  wget https://github.com/nicocha30/ligolo-ng/releases/latest/download/agent_windows_amd64.exe \
    -O /opt/ligolo/agent.exe
  ```
- **Labs:** Lab-02, Lab-09, Lab-10

---

### Chisel
- **Descripción:** Túnel TCP/UDP sobre HTTP con soporte SOCKS5. Útil para pivoting cuando solo hay salida HTTP.
- **Instalación:**
  ```bash
  sudo apt install -y chisel
  ```
- **Labs:** Lab-02, Lab-09

---

## 💻 Post-Explotación y Acceso Remoto

### Evil-WinRM
- **Descripción:** Cliente WinRM ofensivo. Proporciona shell interactiva con soporte para carga de archivos, ejecución de scripts PowerShell y bypass de AMSI integrado.
- **Instalación:**
  ```bash
  sudo apt install -y evil-winrm
  ```
- **Uso típico:**
  ```bash
  # Con contraseña
  evil-winrm -i 10.0.2.10 -u backup_svc -p 'Backup2024!'
  # Pass-the-Hash
  evil-winrm -i 10.0.2.10 -u Administrador -H b73fdfe10e87b4ca5c0d957f81de6863
  ```
- **Labs:** Lab-01, Lab-04, Lab-05, Lab-06

---

### CrackMapExec (CME) / NetExec
- **Descripción:** Suite de post-explotación para redes Windows. Permite validación masiva de credenciales, ejecución de comandos y enumeración sobre SMB, WinRM, LDAP y MSSQL.
- **Instalación:**
  ```bash
  sudo apt install -y crackmapexec
  ```
- **Uso típico:**
  ```bash
  # Validar credenciales
  crackmapexec smb 10.0.2.10 -u ceo.martinez -p 'Direccion2024!'
  # Enumerar shares
  crackmapexec smb 10.0.2.10 -u '' -p '' --shares
  ```
- **Labs:** Lab-01, Lab-04, Lab-10, Lab-11

---

### Metasploit Framework
- **Descripción:** Plataforma de explotación modular. Usada principalmente para post-explotación, generación de payloads y pivoting.
- **Instalación:**
  ```bash
  sudo apt install -y metasploit-framework
  ```
- **Labs:** Lab-03, Lab-09, Lab-10

---

## 🥷 Evasión y Ejecución en Memoria

### AMSI Bypass
- **Descripción:** Técnicas para deshabilitar el Antimalware Scan Interface de Windows, permitiendo ejecución de herramientas ofensivas en memoria sin detección.
- **Técnicas documentadas:**
  - Patch de `amsi.dll` en memoria mediante PowerShell
  - Ofuscación de strings con `[Char]` casting
  - `Set-MpPreference -DisableScriptScanning $true` (requiere admin + Tamper Protection off)
- **Nota:** En Windows 11 con Tamper Protection activa, el bypass en memoria también es bloqueado. Desactivar Tamper Protection desde GUI primero.
- **Labs:** Lab-01, Lab-07, Lab-09

---

### Donut
- **Descripción:** Convierte ejecutables (.exe, .dll) y scripts (.NET) en shellcode independiente de posición (PIC) para inyección en memoria.
- **Instalación:**
  ```bash
  sudo apt install -y python3-donut
  ```
- **Labs:** Lab-07, Phase-03

---

### mingw-w64
- **Descripción:** Compilador cruzado para generar binarios Windows (.exe, .dll) desde Linux. Esencial para compilar implantes y droppers personalizados.
- **Instalación:**
  ```bash
  sudo apt install -y mingw-w64
  ```
- **Labs:** Phase-03, Phase-04

---

## 🌐 Reconocimiento y Escaneo

### Nmap
- **Descripción:** Escáner de red estándar. Detección de puertos, servicios, versiones y ejecución de scripts NSE.
- **Instalación:**
  ```bash
  sudo apt install -y nmap
  ```
- **Uso típico:**
  ```bash
  # Port discovery
  nmap -p- --min-rate 5000 -oA nmap/ports 10.0.2.10
  # Service version
  nmap -sC -sV -p <puertos> -oA nmap/detailed 10.0.2.10
  ```
- **Labs:** Todos

---

### Masscan
- **Descripción:** Escáner de puertos de alta velocidad. Complementa a Nmap en redes grandes (Pro Labs).
- **Instalación:**
  ```bash
  sudo apt install -y masscan
  ```
- **Labs:** Lab-10, Lab-11, Lab-12

---

### Gobuster / Feroxbuster
- **Descripción:** Herramientas de fuzzing de directorios y subdominios web. Feroxbuster soporta recursividad automática.
- **Instalación:**
  ```bash
  sudo apt install -y gobuster feroxbuster
  ```
- **Labs:** Lab-03, Lab-09

---

## 📚 Wordlists y Diccionarios

### SecLists
- **Descripción:** Colección de listas para fuzzing, enumeración de usuarios, contraseñas y payloads web. Referencia en Red Team.
- **Instalación:**
  ```bash
  sudo apt install -y seclists
  # Ruta: /usr/share/seclists/
  ```
- **Labs:** Todos

---

### RockYou
- **Descripción:** Diccionario clásico de 14M de contraseñas. Efectivo para crackeo de hashes Kerberos en labs con contraseñas débiles.
- **Nota:** En entornos corporativos reales, complementar con diccionarios dirigidos basados en OSINT de la empresa.
- **Instalación:**
  ```bash
  sudo gunzip /usr/share/wordlists/rockyou.txt.gz
  ```
- **Labs:** Lab-01, Lab-03, Lab-04

---

## 🏗️ Infraestructura del Lab

### Oracle VM VirtualBox `7.0`
- **Descripción:** Hipervisor utilizado para el despliegue y aislamiento del entorno de laboratorio local.
- **Red:** NAT Network `LabRedTeam` — Segmento `10.0.2.0/24`

### Máquinas del entorno

| Host | Sistema Operativo | IP | Rol |
|------|------------------|----|-----|
| DC-01 | Windows Server 2022 Standard Evaluation | `10.0.2.10` | Domain Controller |
| WKSTN-01 | Windows 11 Enterprise Evaluation | `10.0.2.8` | Workstation corporativa |
| Kali | Kali Linux 2026.1 | `10.0.2.9` | Máquina atacante |

### Configuración de red permanente en Kali

```bash
# IP estática via NetworkManager (persiste entre reinicios)
sudo nmcli con add type ethernet con-name "LabRedTeam" ifname eth0 \
  ipv4.method manual \
  ipv4.addresses 10.0.2.9/24 \
  ipv4.gateway 10.0.2.1 \
  ipv4.dns 10.0.2.10 \
  connection.autoconnect yes
sudo nmcli con up LabRedTeam
```

---

## 📊 Estado de Instalación

| Categoría | Herramienta | Estado |
|-----------|-------------|--------|
| C2 | Sliver v1.7.3 | ✅ Instalado |
| C2 | Havoc C2 | 🔄 Pendiente compilación |
| AD Enum | BloodHound 9.0 | ✅ Instalado |
| AD Enum | SharpHound | ✅ Instalado |
| AD Enum | PowerView | ✅ Instalado |
| AD Enum | Adalanche | ✅ Instalado |
| AD Enum | enum4linux-ng | ✅ Instalado |
| Kerberos | Impacket v0.14 | ✅ Instalado |
| Kerberos | Rubeus | ✅ Instalado |
| Kerberos | Kerbrute | ✅ Instalado |
| Cracking | Hashcat | ✅ Instalado |
| Cracking | John the Ripper | ✅ Instalado |
| Pivoting | Ligolo-ng | ✅ Instalado |
| Pivoting | Chisel | ✅ Instalado |
| Post-Explot | Evil-WinRM v3.9 | ✅ Instalado |
| Post-Explot | CrackMapExec | ✅ Instalado |
| Post-Explot | Metasploit | ✅ Instalado |
| Evasión | Donut | ✅ Instalado |
| Evasión | mingw-w64 | ✅ Instalado |
| Escaneo | Nmap 7.99 | ✅ Instalado |
| Escaneo | Masscan | ✅ Instalado |
| Escaneo | Gobuster / Feroxbuster | ✅ Instalado |
| Wordlists | SecLists | ✅ Instalado |
| Wordlists | RockYou | ✅ Instalado |

---

*Última actualización: Mayo 2026 — Adrián Camacho*