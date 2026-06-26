# Paso 1 · ¿Está AppLocker activo y en qué modo? — Lab-12 IRON VEIL

> ### Protocolo de observación (arquetipo concepto — NO contiene bypasses armados)
> ```
> Paso 1 detectar AppLocker  →  Paso 2 modo Audit vs  →  Paso 3 CLM: ¿estoy
>   ¿activo? ¿en Enforce?        Enforce + rutas          restringido?
>                                  permitidas
>        →  Paso 4 LOLBAS: mapear  →  Paso 5 el contexto manda
>              el terreno              (binario legítimo + uso anómalo = detección)
> ```
> **Lectura:** protocolo de qué observar al caer en un entorno con control de aplicaciones.
> El código de bypass se practica en el lab del curso CRTO; aquí documentas *qué viste y qué decidiste*.

> **Paso 1 de 5 · Protocolo de observación**
>
> **Objetivo:** Determinar si AppLocker está activo, en modo Audit o Enforce, y qué categorías controla (EXE, Scripts, DLL…).
>
> **Prerequisito:** baliza en el host, output de Lab-09 módulo 2 (postura defensiva).
>
> **Habilita:** saber si tus binarios serán bloqueados y en qué categorías.
>
> **TTP:** T1518.001

## Qué observar / qué ejecutar

`Get-AppLockerPolicy -Effective` · comprobar `AppIDSvc` activo · revisar Event 8003/8004 en logs — si hay eventos recientes, está en Enforce. Si no los hay pero la política existe, puede ser Audit.

## Observaciones (completar tras practicar en el lab del curso)

> Documenta lo que viste — modo de AppLocker, CLM activo/no, LOLBAS que funcionó, por qué.

---

*Paso 1/5 · Lab-12 Iron Veil · protocolo de observación (anatomía v3.1, arquetipo concepto)*
