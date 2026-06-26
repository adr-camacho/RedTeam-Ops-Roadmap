# Paso 1 · CS por defecto — qué lo delata — Lab-16 CUSTOM ARSENAL

> ### Protocolo de observación (arquetipo concepto — NO contiene código de C2)
> ```
> Paso 1 Perfil default   →  Paso 2 Malleable    →  Paso 3 BOF vs       →  Paso 4 Aggressor
>   detectar qué delata      configurar + observar   execute-assembly        automatizar workflow
>   CS sin adaptar           el tráfico adaptado     footprint comparado
> ```
> **Lectura:** protocolo de qué observar al adaptar el C2. El código de BOFs/perfiles/scripts
> se practica en el lab del curso CRTO. Aquí documentas *qué viste y qué decidiste*.

> **Paso 1 de 4 · Protocolo de observación**
>
> **Objetivo:** Observar qué genera un beacon de CS con perfil por defecto: patrones de tráfico, JA3, User-Agent, URIs, comportamiento de proceso.
>
> **Prerequisito:** beacon activo con perfil por defecto (sin Malleable).
>
> **Habilita:** la línea base de lo que hay que adaptar — saber qué se detecta antes de configurar nada.
>
> **TTP:** T1071.001

## Qué observar / qué ejecutar

Capturar tráfico del beacon default. Identificar: URI patterns, User-Agent, intervalos, JA3 del proceso. Buscar esos patrones en las reglas de detección del `detection.md`. Esto es lo que el perfil Malleable va a cambiar.

## Observaciones (completar tras practicar en el lab del curso)

> Documenta lo que viste — diferencia de tráfico, footprint de proceso, eventos Sysmon comparados.

---

*Paso 1/4 · Lab-16 Custom Arsenal · protocolo de observación (anatomía v3.1, arquetipo concepto)*
