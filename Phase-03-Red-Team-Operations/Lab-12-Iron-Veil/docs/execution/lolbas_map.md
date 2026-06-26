# Paso 4 · Mapear el terreno LOLBAS — Lab-12 IRON VEIL

> **Paso 4 de 5 · Protocolo de observación**
>
> **Objetivo:** Identificar qué binarios del sistema (LOLBAS) están disponibles y cuáles tienen capacidad de ejecución, descarga o proxy en este entorno.
>
> **Prerequisito:** Paso 2 (saber que `%SystemRoot%` está en la whitelist, que siempre aplica).
>
> **Habilita:** las vías de ejecución alternativa disponibles incluso bajo AppLocker agresivo.
>
> **TTP:** T1218

## Qué observar / qué ejecutar

Verificar presencia de: `mshta`, `rundll32`, `regsvr32`, `certutil`, `wmic`, `installutil`, `cscript/wscript`. Cuáles tienen salida de red permitida (firewall). Cuál encaja con lo que necesitas ejecutar.

## Observaciones (completar tras practicar en el lab del curso)

> Documenta lo que viste — modo de AppLocker, CLM activo/no, LOLBAS que funcionó, por qué.

---

*Paso 4/5 · Lab-12 Iron Veil · protocolo de observación (anatomía v3.1, arquetipo concepto)*
