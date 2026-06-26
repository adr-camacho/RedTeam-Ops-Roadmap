# Paso 3 · ¿CLM activo? ¿qué PowerShell puedo usar? — Lab-12 IRON VEIL

> **Paso 3 de 5 · Protocolo de observación**
>
> **Objetivo:** Determinar si Constrained Language Mode está activo (consecuencia de AppLocker en Enforce) y qué capacidades de PowerShell tengo disponibles.
>
> **Prerequisito:** Paso 1 (AppLocker en Enforce activa CLM automáticamente).
>
> **Habilita:** saber si PowerShell ofensivo directo funciona o necesito alternativas.
>
> **TTP:** T1059.001

## Qué observar / qué ejecutar

`$ExecutionContext.SessionState.LanguageMode` → `ConstrainedLanguage` = CLM activo. Intentar `[System.Reflection.Assembly]::Load` — si falla, CLM confirmado. PS v2 disponible (`powershell -version 2`)? → señal de misconfiguración.

## Observaciones (completar tras practicar en el lab del curso)

> Documenta lo que viste — modo de AppLocker, CLM activo/no, LOLBAS que funcionó, por qué.

---

*Paso 3/5 · Lab-12 Iron Veil · protocolo de observación (anatomía v3.1, arquetipo concepto)*
