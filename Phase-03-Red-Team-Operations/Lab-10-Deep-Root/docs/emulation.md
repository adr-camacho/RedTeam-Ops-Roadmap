# Emulation Plan — DEEP ROOT (Lazarus Group)

> **Perfil del actor (clase base, no se repite aquí):** [`Lazarus.md`](../../../docs/adversaries/Lazarus.md)
> **Arquetipo:** Operación (A). Este plan emula cómo **Lazarus se afianza y eleva en un host** comprometido.

---

## Por qué Lazarus ancla este lab

A diferencia de los labs de concepto, aquí el encaje con Lazarus es **directo y documentado**. La persistencia y la escalada de host son parte explícita de su repertorio:

- **Scheduled Tasks (T1053.005)** — mecanismo de persistencia documentado en sus campañas.
- **DLL Side-Loading (T1574.002)** — una de sus técnicas firma: cargar malware vía un binario legítimo.
- **Access Token Manipulation (T1134)** — manipulación de tokens para operar con el privilegio adecuado.

Esto hace de Deep Root uno de los labs donde la emulación es más fiel: las TTPs del lab **son** TTPs de Lazarus, no solo tradecraft genérico.

## Qué es genuino de Lazarus y qué es tradecraft universal

| Elemento del lab | ¿Genuino de Lazarus? | Matiz |
|------------------|----------------------|-------|
| Scheduled Tasks para persistencia | **Sí, documentado** | T1053.005 en sus campañas |
| DLL Side-Loading | **Sí, firma del actor** | T1574.002 — técnica característica |
| Access Token Manipulation | **Sí, documentado** | T1134 |
| Potato (SeImpersonate → SYSTEM) | **Tradecraft universal** | Vía estándar en pentesting; no es firma de un actor concreto |
| UAC bypass (fodhelper, etc.) | **Tradecraft universal** | Técnica común; Lazarus opera elevado pero el bypass no es su firma |
| COM/WMI persistence | **Tradecraft de operador** | Sigiloso; usado por muchos actores avanzados |

> Donde el lab usa una técnica firma de Lazarus (side-loading, scheduled tasks, token), la emulación es fiel. Donde usa tradecraft universal (Potato, UAC bypass), se enmarca como la vía que el operador elige según el host. Honestidad ante todo.

## TTPs de Lazarus que emula ESTE lab

| Táctica | Técnica | ID | En el lab |
|---------|---------|----|-----------|
| Privilege Escalation | Access Token Manipulation | T1134 | Escalada vía token |
| Persistence | Scheduled Task/Job | T1053.005 | Persistencia por tarea programada |
| Persistence | Hijack Execution Flow: DLL Side-Loading | T1574.002 | Persistencia/ejecución vía DLL |
| Defense Evasion | (preludio) minimización de huella | — | OPSEC de los artefactos dejados |

> Repertorio completo en [`Lazarus.md`](../../../docs/adversaries/Lazarus.md).

## Puente narrativo

Deep Root es el momento en que el operador **deja de ser visitante y se vuelve residente**. Tras leer el terreno (Lab-09), aquí se eleva y se afianza — pero todo lo que hace genera artefactos que un defensor puede cazar. Por eso el siguiente bloque (Labs 11-12) es la evasión: volverse invisible para que esa residencia no se detecte. La persistencia de Deep Root sin la evasión de Ghost Signal es una residencia con las luces encendidas.

---

*Emulation Plan · Lab-10 Deep Root · especializa `Lazarus.md` (anatomía v3.1)*
