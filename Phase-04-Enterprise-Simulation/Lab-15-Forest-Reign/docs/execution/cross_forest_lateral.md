# Módulo M3 · Lateral cross-forest — inter-realm trust — Lab-15 FOREST REIGN

> **Módulo M3 · Ruta: `[si SID Filtering desactivado]`**
>
> **Objetivo único:** Cruzar a otro forest si el trust inter-forest tiene SID Filtering desactivado: inter-realm TGT → TGS en el forest destino.
>
> **Prerequisito real:** M1 confirmó trust abusable (sin QUARANTINED) + DA en el forest origen.
>
> **Habilita:** acceso a recursos del forest de destino con el privilegio del trust.
>
> **TTP:** T1550.003 · T1482

## Plan de ejecución

1. Solicitar inter-realm TGT (Rubeus asktgt + asktgs referral). 2. Presentar el ticket en el forest destino. 3. Si SID Filtering activo, explorar técnicas alternativas (cuentas extranjeras, delegación cross-forest).

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: PLAN. Captura aquí la cadena de trusts real, los SIDs usados, los flags cruzados.

---

*Módulo M3 · Lab-15 Forest Reign · Cloud Hopper en AD (anatomía v3.1, arquetipo operación)*
