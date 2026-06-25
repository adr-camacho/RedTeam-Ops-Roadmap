# Paso 1 · Team Server — Lab-08 BLACK BEACON


> **Paso 1 de 6 · Secuencia de construcción**
>
> **Objetivo del paso:** Montar el team server (servidor C2): el núcleo que coordina listeners y balizas.
>
> **Prerequisito:** ninguno — es el inicio.
>
> **Habilita:** que existan listeners (Paso 2).
>
> ### Secuencia de construcción del kit (arquetipo concepto — no es kill-chain)
> ```
> Paso 1 Team Server  →  Paso 2 Listener HTTPS  →  Paso 3 Payloads (staged/stageless)
>        →  Paso 4 Ejecución + adquisición de baliza  →  Paso 5 Operatividad + OPSEC
>        →  Paso 6 Telemetría (Defender ON: qué se ve)
> ```
> **Lectura:** esto no es una cadena de ataque, es **montar y operar tu infraestructura C2** paso a paso.
> Cada paso habilita el siguiente: sin team server no hay listener, sin listener no hay payload que llame a casa.
> El Paso 6 cierra el círculo mirando el otro lado del espejo (`detection.md`): qué telemetría genera tu propio C2.

