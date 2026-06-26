# Módulo M2 · Extra SID Attack — child→parent forest root — Lab-15 FOREST REIGN

> **Módulo M2 · Ruta: `[crítica · siempre disponible en intra-forest]`**
>
> **Objetivo único:** Comprometer el dominio raíz del forest desde un dominio hijo mediante Extra SID Attack (no hay SID Filtering intra-forest).
>
> **Prerequisito real:** DA o krbtgt del dominio hijo comprometido.
>
> **Habilita:** Enterprise Admins en el forest raíz — acceso a todos los dominios del forest.
>
> **TTP:** T1558.001 · T1550.003

## Plan de ejecución

1. DCSync en el dominio hijo → hash krbtgt. 2. Obtener SID de Enterprise Admins del forest raíz. 3. `Rubeus.exe golden /user:Admin /domain:child.corp.local /sid:<child_SID> /krbtgt:<hash> /sids:<EA_SID> /ptt`. 4. Acceder al DC del forest raíz.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: PLAN. Captura aquí la cadena de trusts real, los SIDs usados, los flags cruzados.

---

*Módulo M2 · Lab-15 Forest Reign · Cloud Hopper en AD (anatomía v3.1, arquetipo operación)*
