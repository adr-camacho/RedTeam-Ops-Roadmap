# Detection — Lab-12 Iron Veil

> **Capability:** detección de ejecución bajo AppLocker/CLM y abuso de LOLBAS.
> **Arquetipo:** Concepto · **Adversario:** Lazarus · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

> La paradoja de AppLocker: **los binarios que confía son también los que el atacante usa.** Detectar LOLBAS es detectar actividad legítima con contexto anómalo — un problema de señal/ruido, no de firma.

---

## 1. Detección de enumeración de política AppLocker

- **Sysmon Event 1** — `Get-AppLockerPolicy`, `AppLockerPolicyTool.exe`, o consultas al registro `HKLM\SOFTWARE\Policies\Microsoft\Windows\SrpV2`.
- Proceso de usuario ejecutando PowerShell con cmdlets de AppLocker sin contexto administrativo.

## 2. Detección de abuso de LOLBAS

La dificultad central: estos binarios son legítimos. La detección requiere **contexto**, no firma.

| LOLBAS | Señal de abuso | Event ID |
|--------|----------------|----------|
| `mshta.exe` | lanzado por un proceso no-Office con URL/script inline | Sysmon 1 |
| `rundll32.exe` | argumento apuntando a ruta de usuario o URL | Sysmon 1 |
| `regsvr32.exe` | `/s /n /u /i:http://...` (scrobj) | Sysmon 1 |
| `certutil.exe` | `-urlcache -split -f` con URL externa | Sysmon 1 |
| `wmic.exe` | `process call create` con payload | Sysmon 1 |
| `installutil.exe` | ejecutado por usuario normal con DLL no firmada | Sysmon 1 |

- **KQL/Defender:** `DeviceProcessEvents` filtrando estos binarios con argumentos anómalos (URLs, rutas de usuario, encoded commands).
- **Sysmon Event 3** (network connection) de binarios que no deberían hacer red (certutil, mshta).

## 3. Detección de CLM bypass

- **PowerShell Event 4104** (Script Block Logging): bloques que intentan invocar métodos .NET bloqueados por CLM → error de lenguaje restringido.
- Proceso lanzando `powershell.exe -version 2` (downgrade a PS2, que no soporta AMSI/CLM) — señal clásica.
- `installutil.exe` / `regasm.exe` como proxy de .NET en vez de `powershell.exe`.

## 4. Detección de bypasses de AppLocker

- **Event 8003/8004** (AppLocker) — intento bloqueado de ejecutar algo no permitido: indica que alguien está probando la política.
- Ejecución desde rutas de usuario que no deberían estar en la whitelist (señal de misconfiguración explotada).
- Proceso hijo de un binario LOLBAS que es un proceso ofensivo conocido.

## 5. Reglas de ejemplo (concepto)

- **Sigma:** `rundll32.exe` con argumento de red o ruta `%TEMP%`.
- **Sigma:** `certutil.exe` con `-urlcache` y host externo.
- **KQL:** proceso hijo de `mshta.exe` o `wscript.exe` que no sea un proceso esperado.
- **AppLocker:** alertar sobre eventos 8003/8004 de binarios de usuario.

---

## Limitaciones y evasión (puente a Phase-04)

| Detección | Cómo se evade | Profundiza en |
|-----------|---------------|----------------|
| Firma de LOLBAS por argumentos | LOLBAS menos conocidos, argumentos no firmados | — |
| Proceso hijo anómalo de LOLBAS | Técnicas que no crean proceso hijo (BOFs, in-process) | Lab-16 |
| Event 8003/8004 | Modo Audit (no Enforce) no genera estos eventos — explotar configuración débil | este lab |
| Logging PS 4104 | PowerShell unmanaged (`powerpick` en CS) evita el logging | Lab-11 / Lab-16 |

> Iron Veil y Ghost Signal cierran el bloque de evasión de Phase-03. En Phase-04, la evasión no se enseña por separado — se da por supuesta como disciplina integrada del operador.

---

*Detection · Lab-12 Iron Veil · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
