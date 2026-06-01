# ⚙️ Guía de Provisioning — Red Team Ops Roadmap
## Setup completo del entorno de laboratorio

**Versión:** 2.1 | **Actualizado:** Junio 2026 | **Autor:** Adrián Camacho

---

## Requisitos de hardware

```
RAM:     32 GB mínimo (4 DCs + 2 WKSTNs + Kali simultáneos)
CPU:     8 cores — VT-x/AMD-V activo en BIOS
Disco:   400 GB libres
VM:      VirtualBox 7.x
```

---

## Arquitectura del entorno

```
Forest 1: atackcorp.local
  DC-01  10.0.2.10  Windows Server 2022  4GB  Root DC + ADCS
  DC-03  10.0.2.13  Windows Server 2022  2GB  child.atackcorp.local
  WKSTN-01  10.0.2.8  Windows 11  3GB

Forest 2: corp.local  ←──BiDir Trust──→  atackcorp.local
  DC-02  10.0.2.11  Windows Server 2022  2GB
  WKSTN-02  10.0.2.12  Windows 11  2GB

Forest 3: ext.local  ←──BiDir Trust──→  atackcorp.local
  DC-04  10.0.2.14  Windows Server 2022  2GB

Kali  10.0.2.9  Kali Linux 2026.1  8GB  Atacante / C2
Red:  NAT Network "LabRedTeam" — 10.0.2.0/24
```

---

## Orden de provisioning

> ⚠️ Ejecutar en este orden exacto. Cada script depende del anterior.

### Paso 0 — Kali: clonar repo e instalar arsenal

```bash
git clone https://github.com/adr-camacho/RedTeam-Ops-Roadmap.git ~/RedTeam-Repo
cd ~/RedTeam-Repo
bash tooling/arsenal_setup.sh
```

### Paso 1 — DC-01: instalación y promoción AD

Instalar Windows Server 2022, configurar IP estática `10.0.2.10`, luego:

```powershell
# PowerShell como Administrador local
.\setup\provisioning\01_ad_promotion.ps1
# El servidor se reinicia automáticamente
```

### Paso 2 — DC-01: usuarios, OUs y ACLs

```powershell
.\setup\provisioning\02_users_ous.ps1
.\setup\provisioning\03_acls_delegations.ps1
.\setup\provisioning\04_iis_smb_gpo.ps1
.\setup\provisioning\05_mssql.ps1
```

### Paso 3 — WKSTN-01: prerequisites manuales

```powershell
# ANTES del script — ejecutar manualmente en WKSTN-01
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
net user Administrador /active:yes
net user Administrador NuevaPassword2026!
netsh advfirewall firewall add rule name="WinRM" protocol=TCP dir=in localport=5985 action=allow
```

Luego:

```powershell
.\setup\provisioning\06_wkstn01_fixed.ps1
```

### Paso 4 — DC-02: corp.local

Instalar Windows Server 2022, configurar IP `10.0.2.11`, promover como DC de `corp.local`, luego:

```powershell
.\setup\provisioning\07_setup_DC02_Corp.ps1
```

### Paso 5 — DC-03: child.atackcorp.local

Instalar Windows Server 2022, configurar IP `10.0.2.13`, promover como child DC de `atackcorp.local`, luego:

```powershell
.\setup\provisioning\08_setup_DC03_Child.ps1
# v1.1 — incluye DNS primario → DC-01, ADWS port 9389, C:\Temp
```

### Paso 6 — DC-04: ext.local

Instalar Windows Server 2022, configurar IP `10.0.2.14`, promover como DC de `ext.local`, luego:

```powershell
.\setup\provisioning\09_setup_DC04_Ext.ps1
```

### Paso 7 — DC-01: Forest Trusts + SID Filtering

```powershell
# En DC-01 — configura trusts BiDirectional con los 3 forests
.\setup\provisioning\10_setup_Trusts_And_SIDHistory.ps1
```

> Este script requiere que DC-02, DC-03 y DC-04 estén operativos.

### Paso 8 — WKSTN-02: corp.local

```powershell
# Prerequisites manuales primero (igual que WKSTN-01)
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
net user Administrador /active:yes
net user Administrador Admin1234!
netsh advfirewall firewall add rule name="WinRM" protocol=TCP dir=in localport=5985 action=allow

# Luego el script
.\setup\provisioning\11_Setup_WKSTN02_Corp_fixed.ps1
```

### Paso 9 — Crown Jewels por lab

Antes de ejecutar cada lab, ejecutar el CrownJewels correspondiente en DC-01:

```powershell
# Lab-01
.\Phase-01-Fundamentals\Lab-01-Ghost-Forest\setup\CrownJewels-Lab01-GhostForest.ps1

# Lab-04
.\Phase-02-Post-Exploitation\Lab-04-Iron-Forest\setup\CrownJewels-Lab04-IronForest.ps1

# Lab-05
.\Phase-02-Post-Exploitation\Lab-05-Silver-Chain\setup\CrownJewels-Lab05-SilverChain.ps1

# Lab-06
.\Phase-02-Post-Exploitation\Lab-06-Black-Policy\setup\CrownJewels-Lab06-BlackPolicy.ps1
```

### Paso 10 — Kali: /etc/hosts

```bash
sudo bash -c 'cat >> /etc/hosts << EOF
10.0.2.10  DC-01.atackcorp.local  atackcorp.local  DC-01
10.0.2.11  corp.local  DC-02.corp.local
10.0.2.13  child.atackcorp.local  DC-03.child.atackcorp.local
10.0.2.14  ext.local  DC-04.ext.local
10.0.2.8   WKSTN-01.atackcorp.local  WKSTN-01
10.0.2.12  WKSTN-02.corp.local  WKSTN-02
EOF'
```

---

## Verificación del entorno

```bash
# Desde Kali — verificar conectividad completa
for ip in 10.0.2.10 10.0.2.11 10.0.2.13 10.0.2.14 10.0.2.8 10.0.2.12; do
    ping -c 1 -W 1 $ip > /dev/null && echo "✅ $ip" || echo "❌ $ip"
done

# Verificar acceso WinRM
evil-winrm -i 10.0.2.10 -u helpdesk.ruiz -p 'Helpdesk2024!'

# Verificar trusts desde DC-01
Get-ADTrust -Filter * | Select-Object Name, Direction, TrustType
```

---

## Credenciales de acceso rápido

| VM | Usuario | Contraseña | Uso |
|----|---------|-----------|-----|
| DC-01 | Administrador | NuevaPassword2026! | Admin dominio |
| DC-02 | Administrador | Admin1234! | Admin corp.local |
| DC-03 | Administrador | Admin1234! | Admin child domain |
| DC-04 | Administrador | Admin1234! | Admin ext.local |
| WKSTN-01 | Administrador | NuevaPassword2026! | Admin local |
| WKSTN-02 | Administrador | Admin1234! | Admin local |
| Kali | kali | kali | — |

---

## Problemas conocidos y soluciones

| Problema | Causa | Solución |
|----------|-------|---------|
| `Enable-PSRemoting` en script corta Evil-WinRM | PSRemoting reinicia el stack WinRM | Ejecutar manualmente antes del script |
| Cuenta Administrador inactiva en Windows 11 | Windows 11 deshabilita admin local por defecto | `net user Administrador /active:yes` |
| DC-03 ADWS cross-domain falla | DNS primario incorrecto | Script 08 v1.1 lo corrige automáticamente |
| mimikatz bloqueado por Defender | Firma conocida | `Set-MpPreference -DisableRealtimeMonitoring $true` antes del upload |
| `impacket-GetUserSPNs` cross-forest sin hashes | Falta TGT | `impacket-getTGT` + `export KRB5CCNAME` primero |

---

*Red Team Ops Roadmap v2.1 — Adrián Camacho | Junio 2026*