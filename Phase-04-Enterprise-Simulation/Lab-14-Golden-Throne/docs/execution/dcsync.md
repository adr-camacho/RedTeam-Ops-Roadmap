# Módulo M1 · DCSync — obtener hash krbtgt y cuentas SA — Lab-14 GOLDEN THRONE

> ### Mapa de la operación (kill-chain domain dominance)
> ```
>   M1 DCSync          →  M2 Persistence    ←── elegir según OPSEC del entorno:
>   (hash krbtgt +         mecanismo         │   a) Golden/Diamond Ticket (Kerberos)
>    cuentas SA)           proporcional  ────┤   b) Forged cert (ADCS)
>                                            │   c) DSRM backdoor (DC local)
>                                            └   d) AdminSDHolder (ACL persistente)
>        │
>        ▼
>   M3 Validación (¿la persistencia sobrevive a reset de DA?)
>        │
>        ▼
>   M4 Cleanup / OPSEC (mínima huella, máxima durabilidad)
> ```
> **Lectura:** M1 obtiene el material; M2 elige el mecanismo (vías alternativas según entorno);
> M3 valida que la persistencia es real; M4 minimiza huella.
> ⚠ **Arquetipo operación:** `execution/` es el **PLAN de ataque**.

> **Módulo M1 · Ruta: `[crítica]`**
>
> **Objetivo único:** Volcar el hash de krbtgt y cuentas de servicio clave vía DCSync (replicación de dominio). Es el material base para Golden Ticket y necesario para evaluar opciones de persistencia.
>
> **Prerequisito real:** DA o privilegios de replicación (GetChangesAll).
>
> **Habilita:** hash de krbtgt → Golden/Diamond Ticket; hashes SA → Silver Ticket; evaluación de opciones.
>
> **TTP:** T1003.006

## Plan de ejecución

`Invoke-Mimikatz -Command '"lsadump::dcsync /domain:corp.local /user:krbtgt"'` · o con Impacket secretsdump. OPSEC: DCSync genera Event 4662 en el DC — exactamente igual que una replicación legítima, pero desde una cuenta de usuario normal es anómalo.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: este módulo es el PLAN. Captura aquí la ejecución real — comandos, hashes obtenidos, mecanismo elegido y justificado.

---

*Módulo M1 · Lab-14 Golden Throne · Domain Dominance (anatomía v3.1, arquetipo operación)*
