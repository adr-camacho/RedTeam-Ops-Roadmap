# Operación — Primer beacon y ciclo

> Onboarding. Objetivo: entender el ciclo de una sesión de C2.

## 1. Generar y ejecutar un implante (en una VM de laboratorio propia)
<generación del implante para el listener creado>

## 2. Recibir el beacon
- Check-in: el beacon contacta con el team server.
- Entender **sleep** y **jitter**: cadencia de contacto y por qué importa para OPSEC.

## 3. Ciclo de operación
- Lanzar una tarea básica (p. ej. `whoami`, listar procesos).
- Observar el modelo asíncrono: tarea encolada → check-in → resultado.

## 4. OPSEC básico
- Qué ruido genera cada acción.
- Por qué un sleep largo es más sigiloso y qué se sacrifica.

> Cierre: con esto, Lab-01 puede usar C2 dando por entendido este ciclo.
