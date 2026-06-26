# Lessons — Lab-11 Ghost Signal

> Lecciones del bloque de Evasión I. Se completan tras practicar en el laboratorio del curso CRTO.

---

## Lecciones de criterio

1. **Firma ≠ comportamiento.** El error más frecuente: ofuscar el payload, Defender lo deja pasar, y luego el EDR lo detecta por comportamiento (inyección, API calls). Hay que trabajar las dos capas.

2. **El intento de evasión genera IoCs propios.** AMSI bypass escribe en memoria de amsi.dll; ETW patching modifica ntdll.dll. El defensor maduro no busca el payload — busca los intentos de desactivar los controles. Esta es la lección más importante de Ghost Signal.

3. **Tamper Protection hace lo que dice.** No intentes apagar Defender con `Set-MpPreference`. Genera alertas y no funciona. Opera con él activo.

4. **AMSI se activa en runtime, no en disco.** Un script en texto claro con strings de Mimikatz o PowerView muere antes de ejecutarse aunque el archivo no esté en disco. El contenido es la firma, no el archivo.

5. **ETW es la fuente de telemetría, no el síntoma.** Cegar ETW para el proceso del beacon no desactiva Defender — desactiva la telemetría que el EDR usa para decidir. Es una técnica de alta sofisticación (y alta detectabilidad si el EDR busca ausencias).

6. **El código se practica en el curso; el criterio se construye aquí.** Lo que vale en el examen no es recordar el one-liner del bypass — es saber qué capa te bloqueó y cuál ajustar.

## Pendiente de completar tras practicar (en el lab del curso)

- [ ] ¿Qué capa bloqueó el primer intento? (firma, AMSI, comportamiento).
- [ ] ¿El bypass de AMSI fue suficiente o el comportamiento siguió disparando alertas?
- [ ] ¿Qué telemetría generó el bypass en sí (el meta-IoC)?
- [ ] ¿Qué ajuste concreto permitió operar con Defender ON?

---

*Lessons · Lab-11 Ghost Signal · anatomía v3.1*
