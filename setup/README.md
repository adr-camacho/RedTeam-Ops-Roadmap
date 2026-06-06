# Setup Guide — Red Team Ops Roadmap
## Guia completa de aprovisionamiento del entorno

**Version:** 3.0 | **Actualizado:** Junio 2026  
**Autor:** Adrian Camacho

> Esta guia cubre el aprovisionamiento completo del entorno de laboratorio.
> El README principal del proyecto esta en la raiz del repositorio.

---

## Infraestructura

| Maquina   | IP         | OS                    | RAM   | Rol                              |
|-----------|------------|-----------------------|-------|----------------------------------|
| DC-01     | 10.0.2.10  | Windows Server 2025   | 22GB  | Root DC atackcorp.local + ADCS + Windows LAPS |
| DC-02     | 10.0.2.11  | Windows Server 2022   | 4GB   | DC corp.local (Forest 2)         |
| DC-03     | 10.0.2.13  | Windows Server 2022   | 4GB   | DC child.atackcorp.local         |
| DC-04     | 10.0.2.14  | Windows Server 2022   | 4GB   | DC ext.local (Forest 3)          |
| WKSTN-01  | 10.0.2.8   | Windows 11            | 4GB   | Workstation atackcorp.local       |
| WKSTN-02  | 10.0.2.12  | Windows 11            | 4GB   | Workstation corp.local            |
| Kali      | 10.0.2.9   | Kali Linux            | 4GB   | Atacante                         |

**Red VirtualBox:** NAT Network "LabRedTeam" (10.0.2.0/24)

---

## Estructura de scripts

```
setup/
├── DC-01/          Scripts para DC-01 (atackcorp.local)
│   ├── 01_promover_controlador_de_dominio_atackcorp.ps1
│   ├── 02_crear_usuarios_ous_atackcorp.ps1
│   ├── 03_configurar_acls_delegaciones_atackcorp.ps1
│   ├── 04_instalar_iis_smb_shares_gpos_atackcorp.ps1
│   ├── 05_instalar_sql_server_express_atackcorp.ps1
│   ├── 10_configurar_forest_trusts_sid_filtering.ps1
│   ├── 12_configurar_windows_laps_atackcorp.ps1
│   ├── 13_instalar_adcs_ca_atackcorp.ps1
│   └── 14_configurar_defender_exclusiones_atackcorp.ps1
├── DC-02/          Scripts para DC-02 (corp.local)
├── DC-03/          Scripts para DC-03 (child.atackcorp.local)
├── DC-04/          Scripts para DC-04 (ext.local)
├── WKSTN-01/       Scripts para WKSTN-01
├── WKSTN-02/       Scripts para WKSTN-02
├── CrownJewels/    Crown Jewels Labs 01-15
└── README.md       Esta guia
```

---

## Orden de ejecucion

> Ejecutar cada script en la maquina indicada. Todos requieren PowerShell como Administrador.

### FASE 1 — DC-01 base

#### Paso 1 — Promover DC-01
```
Maquina: DC-01
Script:  DC-01/01_promover_controlador_de_dominio_atackcorp.ps1
Notas:   Renombrar equipo a DC-01 y reiniciar ANTES de ejecutar
```

#### Paso 2 — Usuarios y OUs
```
Maquina: DC-01 (tras reinicio post-promocion)
Script:  DC-01/02_crear_usuarios_ous_atackcorp.ps1
```

#### Paso 3 — ACLs y delegaciones
```
Maquina: DC-01
Script:  DC-01/03_configurar_acls_delegaciones_atackcorp.ps1
Notas:   Re-ejecutar despues de unir WKSTN-01 al dominio
```

#### Paso 4 — IIS, SMB, GPOs
```
Maquina: DC-01
Script:  DC-01/04_instalar_iis_smb_shares_gpos_atackcorp.ps1
```

#### Paso 5 — SQL Server Express
```
Maquina: DC-01
Script:  DC-01/05_instalar_sql_server_express_atackcorp.ps1
PREREQUISITO: SQL Server 2022 Express instalado via GUI
Notas:   Instalacion silenciosa bloquea PS con RAM < 12GB
         Usar GUI o tarea programada SYSTEM
```

---

### FASE 2 — Workstations

#### Paso 6 — WKSTN-01
```
Maquina: WKSTN-01 (unida a atackcorp.local)
Script:  WKSTN-01/01_configurar_workstation_wkstn01_atackcorp.ps1
Prerequisito manual:
  Enable-PSRemoting -Force
  net user Administrador /active:yes
  net user Administrador NuevaPassword2026!
  netsh advfirewall firewall add rule name="WinRM" protocol=TCP dir=in localport=5985 action=allow
```

---

### FASE 3 — Dominios secundarios

#### Paso 7 — DC-02 (corp.local)
```
Maquina: DC-02
Script:  DC-02/01_configurar_dominio_corp_local.ps1
```

#### Paso 8 — DC-03 (child.atackcorp.local)
```
Maquina: DC-03
Script:  DC-03/01_configurar_dominio_child_atackcorp.ps1
Notas:   DC-03 debe estar encendido al extender schema AD en DC-01
```

#### Paso 9 — DC-04 (ext.local)
```
Maquina: DC-04
Script:  DC-04/01_configurar_dominio_ext_local.ps1
```

---

### FASE 4 — Forest Trusts

#### Paso 10 — Trusts + SID Filtering OFF
```
Maquina: DC-01
Script:  DC-01/10_configurar_forest_trusts_sid_filtering.ps1
Prerequisito: DC-02, DC-03, DC-04 operativos
Notas:   Usa .NET — netdom /quarantine falla en WS2025
         DNS Conditional Forwarders se crean automaticamente
```

---

### FASE 5 — WKSTN-02

#### Paso 11 — WKSTN-02
```
Maquina: WKSTN-02 (unida a corp.local)
Script:  WKSTN-02/01_configurar_workstation_wkstn02_corp.ps1
```

---

### FASE 6 — Servicios avanzados DC-01

#### Paso 12 — Windows LAPS
```
Maquina: DC-01
Script:  DC-01/12_configurar_windows_laps_atackcorp.ps1
Prerequisito: WS2025 (Windows LAPS nativo)
              OU path: OU=IT,DC=atackcorp,DC=local
Tras ejecutar: gpupdate /force en WKSTN-01
Verificar: Get-LapsADPassword -Identity WKSTN-01 -AsPlainText
```

#### Paso 13 — ADCS
```
Maquina: DC-01
Script:  DC-01/13_instalar_adcs_ca_atackcorp.ps1
Notas:   Templates ESC1/ESC4 via GUI (certsrv.msc) en Lab-03
```

#### Paso 14 — Defender
```
Maquina: DC-01
Script:  DC-01/14_configurar_defender_exclusiones_atackcorp.ps1
```

---

### FASE 7 — Crown Jewels

Ejecutar en DC-01 antes del lab correspondiente:

```powershell
# Lab-01
.\setup\CrownJewels\CrownJewels-Lab01-GhostForest.ps1

# Lab-02 (ejecutar en PC-01 de la red 10.0.3.x)
# Lab-03
.\setup\CrownJewels\CrownJewels-Lab03-DarkGate.ps1

# Labs 04-07
.\setup\CrownJewels\CrownJewels-Lab04-IronForest.ps1
.\setup\CrownJewels\CrownJewels-Lab05-SilverChain.ps1
.\setup\CrownJewels\CrownJewels-Lab06-BlackPolicy_v2.ps1
.\setup\CrownJewels\CrownJewels-Lab07-ShadowVault_clean.ps1
```

---

## Credenciales resumidas

| Sistema | Usuario | Contrasena |
|---------|---------|-----------|
| Todos los DCs | Administrador | `NuevaPassword2026!` |
| ATACKCORP\ceo.martinez | ceo.martinez | `Direccion2024!` |
| ATACKCORP\helpdesk.ruiz | helpdesk.ruiz | `Helpdesk2024!` |
| ATACKCORP\fin.garcia | fin.garcia | `Finance2024!` |
| ATACKCORP\sql_svc | sql_svc | `SQLSvc2024!` |
| SQL Server SA | sa | `Sa_Admin2024!` |
| CORP\corp.admin | corp.admin | `CorpAdmin2024!` |

> Credenciales completas en: `docs/reference/CREDENTIALS.md`

---

## Notas tecnicas importantes

- **WS2025 y LAPS:** Windows LAPS nativo incluido — no instalar MSI legacy
- **WS2025 y Trusts:** New-ADTrust no existe — usar .NET DirectoryServices
- **SQL Server:** Instalacion silenciosa bloquea con RAM < 12GB — usar GUI
- **C:\Temp SID:** *S-1-1-0 falla en WS2025 — usar WellKnownSidType.WorldSid
- **DC-03:** Necesario encendido para extender schema AD
- **WKSTN firewall:** ICMP bloqueado tras reinicio — usar nxc smb para verificar

---

*Red Team Ops Roadmap — Adrian Camacho | Junio 2026*