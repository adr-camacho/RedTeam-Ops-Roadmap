# Paso 5 · El contexto manda: binario legítimo + uso anómalo — Lab-12 IRON VEIL

> **Paso 5 de 5 · Protocolo de observación**
>
> **Objetivo:** Observar que el defensor detecta LOLBAS no por firma sino por contexto — y diseñar el uso para que sea lo menos anómalo posible.
>
> **Prerequisito:** Paso 4 (LOLBAS mapeado).
>
> **Habilita:** el criterio maduro de LOLBAS: no solo qué funciona, sino cómo usarlo sin disparar la regla de comportamiento.
>
> **TTP:** T1218 · detección

## Qué observar / qué ejecutar

Observar qué proceso padre lanza el LOLBAS, si genera conexión de red, si tiene argumentos firmados (URL, ruta de usuario). El `detection.md` lista las señales — usarlo como checklist inverso: ¿estoy haciendo exactamente lo que las reglas Sigma buscan?

## Observaciones (completar tras practicar en el lab del curso)

> Documenta lo que viste — modo de AppLocker, CLM activo/no, LOLBAS que funcionó, por qué.

---

*Paso 5/5 · Lab-12 Iron Veil · protocolo de observación (anatomía v3.1, arquetipo concepto)*
