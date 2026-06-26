# Paso 1 · Baseline: ¿qué cazan por defecto? — Lab-11 GHOST SIGNAL

> ### Protocolo de observación (arquetipo concepto — NO es código de evasión)
> ```
> Paso 1 baseline        →  Paso 2 firma vs        →  Paso 3 AMSI        →  Paso 4 ETW
>   ¿qué cazan por          comportamiento            mecánica +            mecánica +
>   defecto?                (ofusca: firma cae,       concepto de           concepto de
>                            comportamiento no)        neutralización        cegado
>                                                          │
>                                                          ▼
>                                              Paso 5 la evasión se detecta
>                                              (el propio bypass deja huella)
> ```
> **Lectura:** esto NO contiene bypasses armados — por diseño, el código se practica en el lab del curso CRTO.
> Es el **protocolo de qué observar** para interiorizar cada mecanismo: ejecutas en el entorno del curso y
> documentas aquí *qué viste y por qué*, no el one-liner.

> **Paso 1 de 5 · Protocolo de observación**
>
> **Objetivo:** Establecer la línea base: ejecutar contenido conocido-malicioso y observar qué capa lo bloquea (firma estática, AMSI, comportamiento) sin ninguna evasión.
>
> **Prerequisito:** entorno del curso CRTO con Defender ON.
>
> **Habilita:** entender contra qué evades antes de intentar nada.
>
> **TTP:** T1518.001

## Qué observar

Lanzar un script/binario ofensivo en claro y observar el punto exacto de bloqueo. La pregunta: ¿qué capa me paró?

## Observaciones (completar tras practicar en el lab del curso)

> Documenta aquí lo que viste y por qué — NO el código armado. Qué capa bloqueó, qué telemetría se generó, qué decidiste ajustar.

---

*Paso 1/5 · Lab-11 Ghost Signal · protocolo de observación (anatomía v3.1, arquetipo concepto). El código no vive en el repo por diseño.*
