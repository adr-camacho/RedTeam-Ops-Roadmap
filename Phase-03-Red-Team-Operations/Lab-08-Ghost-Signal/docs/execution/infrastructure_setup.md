# Infrastructure Setup — Lab-08 GHOST SIGNAL
## Lazarus Group | EDR Evasion | Windows Defender Activo
**Operador:** Adrián Camacho | **Fecha:** Junio 2026

---

## Diferencial de este lab

> ⚠️ **Lab-08 es el primer lab de Phase-03.** El entorno es el mismo que Labs anteriores con una diferencia crítica: **Windows Defender permanece activo con Tamper Protection ON** durante toda la operación. No se deshabilita, no se añaden exclusiones. El objetivo es operar sin triggear alertas.

---

## Arquitectura del entorno

| Host | IP | Dominio | Rol | OS | Defender |
|------|----|---------|-----|----|---------|
| DC-01 | 10.0.2.10 | atackcorp.local | Root DC | Windows Server 2025 | Activo |
| WKSTN-01 | 10.0.2.8 | atackcorp.local | Workstation — objetivo principal | Windows 11 23H2+ | **Activo + Tamper Protection ON** |
| Kali | 10.0.2.9 | — | Atacante / C2 | Kali Linux | — |

**Red:** NAT Network `LabRedTeam` — 10.0.2.0/24

---

## Estado de Defender en WKSTN-01

| Componente | Estado | Notas |
|-----------|--------|-------|
| Real-time Protection | ✅ Activo | No se deshabilitará |
| Tamper Protection | ✅ ON | Impide modificar configuración via PS/Registry |
| Cloud Protection | ✅ Activo | Envía muestras a Microsoft |
| AMSI | ✅ Activo | Escanea scripts en memoria antes de ejecutar |
| Behavior Monitoring | ✅ Activo | Detecta patrones sospechosos |
| RunAsPPL | 0 | Deshabilitado desde Lab-07 |

> **Regla de oro:** Si una técnica requiere deshabilitar Defender → no es válida para este lab. Documentar como "bloqueada" y buscar alternativa in-memory.

---

## Credencial inicial

| Usuario | Contraseña | Dominio | Acceso |
|---------|-----------|--------|--------|
| `helpdesk.ruiz` | `Helpdesk2024!` | atackcorp.local | WinRM a WKSTN-01 |

---

## Usuarios relevantes

| Usuario | Contraseña | Grupo | Rol en lab |
|---------|-----------|-------|-----------|
| `Administrador` (local) | `@98q6$13Z{K99;` (LAPS — rota) | Administradores | Admin local WKSTN-01 |
| `helpdesk.ruiz` | `Helpdesk2024!` | — | Credencial inicial |
| `ATACKCORP\Administrador` | `NuevaPassword2026!` | Domain Admins | Admin dominio |

---

## Prerequisitos del lab

### En WKSTN-01

```powershell
# Verificar estado de Defender (DEBE estar activo)
Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled, TamperProtectionSource, AMServiceEnabled

# Verificar que Tamper Protection está ON
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name TamperProtection
# TamperProtection = 5 → ON | 4 → OFF
```

### En Kali

```bash
# Verificar herramientas necesarias
which nxc evil-winrm sliver
python3 -c "import donut" 2>/dev/null || echo "donut no instalado"

# Verificar Sliver activo
systemctl is-active sliver
```

---

## Scripts de provisioning ejecutados

```powershell
# Setup base (ya ejecutados desde Labs anteriores)
.\setup\DC-01\01_promover_controlador_de_dominio_atackcorp.ps1
.\setup\DC-01\02_crear_usuarios_ous_atackcorp.ps1
.\setup\DC-01\14_configurar_defender_exclusiones_atackcorp.ps1  # Solo exclusiones DC-01

# WKSTN-01 — Lab-08 no modifica la configuración de Defender
# El script v3.1 deja Defender ACTIVO en WKSTN-01
# setup/WKSTN-01/01_configurar_workstation_wkstn01_atackcorp.ps1 v3.1

# CrownJewels Lab-08 (no provisiona datos — los crown jewels son las técnicas)
.\setup\CrownJewels\CrownJewels-Lab08-GhostSignal.ps1
```

---

## Verificación pre-lab

```bash
# Desde Kali
bash ~/RedTeam-Repo/tooling/lab_start.sh 08
```

```powershell
# En WKSTN-01 — confirmar Defender activo (condición del lab)
Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled, TamperProtectionSource
# RealTimeProtectionEnabled : True
# TamperProtectionSource    : Signatures
```

---

## Condiciones de éxito

| Condición | Criterio |
|-----------|---------|
| AMSI bypass válido | AmsiScanBuffer parchado en memoria — PowerShell ejecuta payloads conocidos sin bloqueo |
| Process Injection válido | Shellcode ejecutándose en proceso legítimo — sin alerta de Defender |
| C2 válido | Beacon Sliver activo — Defender no genera alerta en 10 minutos de idle |
| OPSEC válido | Event Log limpio — sin EventID 4688/1116/1117 relacionados |

---

## Diferencias técnicas vs Labs anteriores

| Aspecto | Labs 01-07 | Lab-08+ |
|---------|-----------|---------|
| Defender | Deshabilitado | **Activo** |
| Tamper Protection | OFF | **ON** |
| AMSI | Sin importancia | **Crítico — bypassar antes de cargar herramientas** |
| Beacons en disco | Permitidos | **Prohibidos — solo in-memory** |
| Técnicas directas | Funcionan | **Requieren ofuscación/evasión** |

---

*GHOST SIGNAL Infrastructure Setup — Adrián Camacho | Junio 2026*