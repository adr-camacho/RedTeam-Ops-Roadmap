# Detection — Lab-11 Ghost Signal

> **Capability:** detección de evasión de Defender/AMSI/ETW y de los propios bypasses.
> **Arquetipo:** Concepto · **Adversario:** Lazarus · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

> La paradoja de la evasión: **el acto de evadir genera sus propios IoCs**. El defensor maduro no busca las herramientas ofensivas — busca el intento de desactivar los controles.

---

## 1. Detección de AMSI bypass

- **Modificaciones en memoria de `amsi.dll`** dentro del proceso de PowerShell — algunos EDR con hook de API detectan escrituras en memoria de la librería.
- **PowerShell Event 4104** (Script Block Logging): bloques que intentan manipular AMSI y fallan (si el bypass es detectado antes de ejecutarse).
- Strings conocidas de bypasses comunes en logs de Script Block (si el bypass no funciona a tiempo).
- **Anomalía:** proceso de PowerShell que no genera eventos AMSI cuando debería (ausencia de telemetría = señal).

## 2. Detección de ETW patching

- **Memory integrity checks:** EDR avanzados (CrowdStrike, SentinelOne) detectan modificaciones en páginas de memoria de módulos del sistema (`ntdll.dll`, `clr.dll`) que albergan las funciones de ETW.
- **Ausencia súbita de telemetría:** si un proceso dejó de emitir eventos ETW de forma repentina, eso *es* una señal — no la ausencia de alertas.
- **Call stack anomalies:** herramientas como Sysmon con stack enrichment pueden detectar llamadas a funciones de ETW desde regiones de memoria no asociadas a módulos conocidos.

## 3. Detección de ejecución in-memory

- **Sysmon Event 7** (Image Loaded): módulos cargados desde rutas inusuales o sin imagen de disco.
- **Regiones de memoria RWX** sin módulo de disco asociado — característica de shellcode/reflective loading.
- **CLR cargado en proceso inusual:** `execute-assembly` carga el CLR (Common Language Runtime) en el proceso del beacon — detectable por EDR como comportamiento de proceso anómalo.

## 4. El meta-juego: evadir también se detecta

| Técnica de evasión | IoC que genera |
|-------------------|----------------|
| AMSI bypass | Escritura en memoria de amsi.dll; ausencia de eventos AMSI |
| ETW patching | Modificación de ntdll.dll en memoria; ausencia de telemetría ETW |
| Reflective loading | Región RWX sin módulo de disco; CLR en proceso inusual |
| Packing/ofuscación | Entropía alta en el binario; sección PE inusual |

> La evasión no es invisible — es un juego de señales. Cada técnica de evasión intercambia una señal (la firma del payload) por otra (el comportamiento del bypass). El defensor maduro busca la segunda.

---

## Limitaciones y evasión avanzada (puente a Phase-04)

| Detección | Cómo se evade | Profundiza en |
|-----------|---------------|----------------|
| EDR detecta CLR en proceso | BOFs (no cargan CLR) | Lab-16 |
| Modificación de amsi.dll detectada | Técnicas de bypass más indirectas | Lab-16 |
| Región RWX sin módulo | Module stomping (DLL legítima como cobertura) | Lab-16 |

---

*Detection · Lab-11 Ghost Signal · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
