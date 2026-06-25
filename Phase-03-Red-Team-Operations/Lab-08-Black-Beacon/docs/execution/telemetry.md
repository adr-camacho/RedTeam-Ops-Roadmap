# Fase-06 · Telemetry Observation (Defender ON)

> Bloque CRTO: Detección  
> Concepto: Reactivar Defender, observar telemetría


> **Paso 6 de 6 · Secuencia de construcción**
>
> **Objetivo del paso:** Observar la telemetría del C2 con Defender ON: qué ve el defensor.
>
> **Prerequisito:** Paso 5 (baliza operativa).
>
> **Habilita:** cierra el lab; puente a detection.md y a la evasión de Lab-11.

---

## 🎯 Objetivo

Reactivar Windows Defender, ejecutar comandos, observar telemetría generada (Event IDs).

## 📋 Prerequisitos

- Beacon activo con sleep 30s/jitter 50% (Fase 05)
- WKSTN-01 con Sysmon instalado (opcional)

## 🔨 Ejecución

### Paso 1: Reactivar Defender en WKSTN-01

```powershell
Set-MpPreference -DisableRealtimeMonitoring $false
Get-MpPreference | select DisableRealtimeMonitoring
```

**Captura:** `FASE-06/fase-06-01-defender-reactivado.png`

### Paso 2: Ejecutar comando y observar Event ID 3

```bash
sliver > BEACON_NAME > shell ipconfig /all
```

**En WKSTN-01:**
```powershell
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 10 | Where {$_.ID -eq 3}
```

**Captura:** `FASE-06/fase-06-02-event-3.png`

### Paso 3: Ejecutar PowerShell, observe Event 4104

```bash
sliver > BEACON_NAME > powershell whoami
```

**Captura:** `FASE-06/fase-06-03-event-4104.png`

### Paso 4: Check Defender Activity

```powershell
Get-MpThreatDetection
```

**Captura:** `FASE-06/fase-06-04-defender-threats.png`

## 🏁 Resultado

✅ Defender activo  
✅ Telemetría observada (Event IDs)  
✅ Entendimiento de qué genera detección