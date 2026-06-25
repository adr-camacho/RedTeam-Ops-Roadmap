# Módulo M1 · Escalada de privilegios — Lab-10 DEEP ROOT

> ### Mapa de la operación (kill-chain — afianzar y elevar)
> ```
>                  ┌─ vía A: token abuse (SeImpersonate → Potato → SYSTEM)  [reina]
>   M1 Escalada ───┼─ vía B: misconfig de servicio (unquoted/binPath/DLL)
>                  └─ vía C: UAC bypass (Medium → High Integrity)
>        │
>        ▼ (contexto elevado)
>   M2 Persistencia ──→ M3 Validación (¿sobrevive reinicio/logoff?)
>        │
>        ▼
>   M4 Cleanup / OPSEC (minimizar huella — transversal)
> ```
> **Lectura:** kill-chain de "afianzamiento". M1 tiene **vías alternativas** (eliges la que el host permita);
> M2-M3 son la columna (persistir desde contexto elevado y validar); M4 es OPSEC transversal.
> ⚠ **Arquetipo operación:** este `execution/` es el **PLAN de ataque**. Pasa a operativa real con tus capturas al ejecutarlo en el lab CRTO.

> **Módulo M1 · Ruta: `[crítica · vías alternativas]`**
>
> **Objetivo único:** Elevar a SYSTEM/High Integrity por la vía que el host permita: token abuse (SeImpersonate→Potato, la reina), misconfig de servicio, o UAC bypass.
>
> **Prerequisito real:** baliza de Lab-09 con privilegios ya enumerados (sabes cuál vía aplica).
>
> **Habilita:** contexto elevado desde el que persistir de forma robusta (M2).
>
> **TTP:** T1134 · T1548.002 · T1574

## Plan de ejecución

Según `getprivs`: si hay SeImpersonate → PrintSpoofer/GodPotato → SYSTEM. Si no, misconfig de servicio o UAC bypass. La vía la decide el host, no el gusto.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: este módulo es el PLAN. Captura aquí la ejecución real contra el entorno CRTO — comandos exactos, salidas, capturas, decisiones tomadas.

---

*Módulo M1 · Lab-10 Deep Root · kill-chain de afianzamiento (anatomía v3.1, arquetipo operación)*
