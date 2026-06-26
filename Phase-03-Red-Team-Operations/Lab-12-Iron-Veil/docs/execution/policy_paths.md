# Paso 2 · Leer la política: rutas y reglas — Lab-12 IRON VEIL

> **Paso 2 de 5 · Protocolo de observación**
>
> **Objetivo:** Mapear la whitelist: qué rutas están permitidas, qué publishers, si hay rutas de usuario escribibles bajo `%SystemRoot%` que sean bypass directo.
>
> **Prerequisito:** Paso 1 (AppLocker activo y en Enforce).
>
> **Habilita:** el mapa de terreno permitido — el suelo firme donde puedes moverte.
>
> **TTP:** —

## Qué observar / qué ejecutar

`Get-AppLockerPolicy -Effective -Xml` · buscar reglas de tipo Path con rutas de usuario · comprobar si `%TEMP%` o `%APPDATA%` aparecen permitidos (bypass directo si existen).

## Observaciones (completar tras practicar en el lab del curso)

> Documenta lo que viste — modo de AppLocker, CLM activo/no, LOLBAS que funcionó, por qué.

---

*Paso 2/5 · Lab-12 Iron Veil · protocolo de observación (anatomía v3.1, arquetipo concepto)*
