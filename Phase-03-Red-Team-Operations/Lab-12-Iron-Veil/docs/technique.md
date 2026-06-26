# Technique — Lab-12 Iron Veil

> **Capability (eje didáctico):** Evasión II — AppLocker, Constrained Language Mode (CLM) y LOLBAS; ejecución bajo whitelisting.
> **Bloque CRTO:** Application Whitelisting Bypass (el obstáculo de ejecución más frecuente tras Defender).
> **Arquetipo:** Concepto / Tradecraft — se construye el **porqué** y el **cómo se detecta**. El código de bypass **no vive en el repo**: se practica en el laboratorio oficial CRTO.
> **Adversario (escenario):** Lazarus Group — ver [`emulation.md`](emulation.md).

> El examen CRTO pone AppLocker. Sin entender **desde dónde puedes ejecutar, qué binarios están permitidos y por qué CLM te cierra PowerShell**, te quedas sin ejecución. La diferencia entre avanzar o atascarte es reconocer el escudo y conocer el terreno que sí tienes permitido.

---

## 1. La premisa: el control de aplicaciones como segunda capa

Ghost Signal (Lab-11) enseñó a operar bajo Defender/AMSI/ETW. Iron Veil añade otra capa defensiva que opera a nivel distinto: no inspecciona el *contenido* del código (eso es AMSI), sino **qué puede ejecutarse y desde dónde**.

Un entorno con AppLocker activo tiene una política que define reglas de permiso/denegación sobre:
- **Ejecutables** (EXE/COM).
- **Scripts** (PS1, VBS, JS, CMD, BAT).
- **Instaladores** (MSI/MSP).
- **DLLs** (opcional, más raro).
- **Paquetes empaquetados** (APPX).

La pregunta del operador al caer en un entorno con AppLocker no es "¿cómo lo rompo?" sino **"¿qué terreno tengo permitido?"** Las rutas de usuario escribibles que también están en la whitelist, los binarios del sistema que AppLocker confía implícitamente, y los LOLBAS que se escapan de la política son el mapa de maniobra.

## 2. AppLocker — mecánica

**Cómo funciona:** el servicio `AppIDSvc` aplica la política antes de que el proceso arranque. Las reglas pueden basarse en:
- **Path rules:** permite/deniega por ruta (ej. `%SystemRoot%\*` siempre permitido por defecto).
- **Publisher rules:** basadas en la firma digital del binario.
- **Hash rules:** hash exacto del archivo.

**Configuraciones comunes y sus implicaciones para el operador:**

| Configuración | Qué implica |
|---------------|-------------|
| `%SystemRoot%` y `%ProgramFiles%` permitidos (default) | Los binarios del sistema son whitelistados → LOLBAS |
| Modo Audit (no Enforce) | Las reglas se evalúan pero no bloquean — todo funciona, queda en log |
| Sin regla de DLL | Las DLLs no se controlan aunque los EXE sí |
| Rutas de usuario escribibles bajo `%SystemRoot%` | Si existen, son bypass directo |

**Enumeración clave:** `Get-AppLockerPolicy -Effective -Xml` para leer la política activa; comprobar si está en modo Audit o Enforce; buscar reglas con rutas escribibles.

## 3. Constrained Language Mode (CLM)

**Qué es:** un modo restringido de PowerShell que desactiva la mayoría de las capacidades ofensivas — invocación de métodos .NET arbitrarios, COM, tipos no aprobados. AppLocker lo **activa automáticamente** cuando una política de AppLocker está en modo Enforce y el script no está firmado.

**Lo que CLM bloquea en la práctica:**
- `[System.Reflection.Assembly]::Load()` → no disponible.
- `Add-Type` con código arbitrario → bloqueado.
- `$ExecutionContext.InvokeCommand.InvokeScript` sobre tipos no aprobados.
- La mayoría del PowerShell ofensivo (PowerView, Invoke-Mimikatz…) falla.

**El test inmediato:** `$ExecutionContext.SessionState.LanguageMode` — devuelve `FullLanguage` o `ConstrainedLanguage`. Es el primer check del Paso 2 de Lab-09 (postura defensiva) aplicado aquí.

**Implicación:** con CLM activo, el operador necesita rutas de ejecución que no pasen por PowerShell en modo Full, o técnicas que funcionen dentro de CLM (LOLBAS, binarios nativos, BOFs).

## 4. LOLBAS — Living Off the Land Binaries and Scripts

**Qué es:** el catálogo de binarios, scripts y librerías *del propio sistema operativo* que tienen capacidades de ejecución, descarga, proxy, etc. — y que AppLocker confía implícitamente (están en `%SystemRoot%`).

**Por qué importa:** AppLocker puede bloquear tus binarios, pero no puede bloquear los suyos propios sin romper el sistema. El operador que conoce LOLBAS tiene terreno de maniobra incluso bajo una política agresiva.

**Categorías y ejemplos clave para CRTO:**

| Categoría | Binario | Capacidad |
|-----------|---------|-----------|
| Ejecución | `mshta.exe` | ejecuta HTA / VBScript |
| Ejecución | `rundll32.exe` | carga y llama a DLL |
| Ejecución | `regsvr32.exe` | scrobj.dll → scripts remotos |
| Ejecución | `wmic.exe` | process call create |
| Proxy/Descarga | `certutil.exe` | descarga archivos (`-urlcache`) |
| Proxy/Descarga | `bitsadmin.exe` | BITS transfer |
| Script | `cscript/wscript.exe` | VBScript/JScript |
| .NET | `installutil.exe` | ejecuta código .NET sin firma |

> Referencia completa: [lolbas-project.github.io](https://lolbas-project.github.io)

## 5. La estrategia del operador bajo whitelisting

El árbol de decisión cuando detectas AppLocker activo (Enforce):

```
¿Está CLM activo?
   SÍ → PowerShell ofensivo directo no funciona
        → ¿Hay rutas escribibles bajo %SystemRoot%? → bypass directo
        → ¿LOLBAS disponible? → ejecución alternativa
        → ¿Puedo usar BOFs (Lab-16)? → ejecución en proceso del beacon
   NO → ¿Solo bloquea scripts o también EXE?
        → Adaptar según el alcance de la política
```

**La regla de oro:** leer la política primero (`Get-AppLockerPolicy`), identificar el modo (Audit/Enforce), y mapear el terreno permitido antes de intentar nada. El bypass no es fuerza bruta — es encontrar el hueco que la política dejó.

## 6. MITRE ATT&CK — Defense Evasion

| Táctica | Técnica | ID |
|---------|---------|----|
| Defense Evasion | System Binary Proxy Execution | T1218 |
| Defense Evasion | Trusted Developer Utilities Proxy Execution | T1127 |
| Defense Evasion | Subvert Trust Controls: Code Signing | T1553.002 |
| Defense Evasion | Impair Defenses: Disable/Modify Tools | T1562 |
| Execution | Command and Scripting Interpreter: PowerShell | T1059.001 |

## 7. Equivalencia CS ↔ Sliver (bajo AppLocker)

| Necesidad | Cobalt Strike | Sliver |
|-----------|---------------|--------|
| Ejecutar sin EXE bloqueado | BOFs (no new process) | extensiones / execute-assembly desde proceso |
| Ejecución via LOLBAS | `shell rundll32 …` / `execute` | `shell` + LOLBAS |
| PowerShell bajo CLM | `powerpick` (unmanaged PS) | PowerShell a través de execute-assembly |

## 8. Key Takeaways

1. **AppLocker controla qué se ejecuta; AMSI controla qué contiene.** Son capas ortogonales — puedes evadir una y seguir bloqueado por la otra.
2. **CLM es consecuencia de AppLocker, no independiente.** Si AppLocker está en Enforce, PowerShell ofensivo se rompe. El test `LanguageMode` es el primer indicador.
3. **Leer la política antes de atacarla.** El modo Audit vs Enforce y las rutas de la whitelist determinan todo lo demás.
4. **LOLBAS es terreno permitido, no un exploit.** AppLocker confía en sus propios binarios. Conocerlos es mapear el suelo firme donde puedes moverte.
5. **El bypass es encontrar el hueco, no forzar la puerta.** Rutas escribibles bajo `%SystemRoot%`, modo Audit inadvertido, LOLBAS — son grietas de diseño, no vulnerabilidades técnicas.

## Referencias

- LOLBAS Project: https://lolbas-project.github.io
- Microsoft — AppLocker documentation
- MITRE ATT&CK — T1218 (System Binary Proxy Execution)
- CRTO — Application Whitelisting module

---

*Technique · Lab-12 Iron Veil · Evasión II AppLocker/CLM/LOLBAS (anatomía v3.1, arquetipo concepto). El código armado no vive en el repo por diseño.*
