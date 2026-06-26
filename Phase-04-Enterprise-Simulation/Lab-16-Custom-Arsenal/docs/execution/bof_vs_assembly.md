# Paso 3 · BOF vs execute-assembly — footprint comparado — Lab-16 CUSTOM ARSENAL

> **Paso 3 de 4 · Protocolo de observación**
>
> **Objetivo:** Ejecutar la misma acción con execute-assembly y con un BOF equivalente; observar la diferencia de footprint (proceso hijo, carga de CLR, eventos Sysmon).
>
> **Prerequisito:** Paso 2 (beacon adaptado y activo).
>
> **Habilita:** el criterio de cuándo usar BOF vs execute-assembly según el nivel de OPSEC requerido.
>
> **TTP:** T1620 · T1055

## Qué observar / qué ejecutar

Ejecutar SharpHound (execute-assembly) y un BOF de enumeración equivalente. Comparar en Sysmon: ¿cuántos procesos hijo? ¿Se cargó el CLR? ¿Qué eventos generó cada uno? La diferencia es la lección.

## Observaciones (completar tras practicar en el lab del curso)

> Documenta lo que viste — diferencia de tráfico, footprint de proceso, eventos Sysmon comparados.

---

*Paso 3/4 · Lab-16 Custom Arsenal · protocolo de observación (anatomía v3.1, arquetipo concepto)*
