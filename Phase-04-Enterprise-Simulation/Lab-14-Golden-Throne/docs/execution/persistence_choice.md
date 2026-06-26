# Módulo M2 · Persistencia de dominio — elegir e implementar — Lab-14 GOLDEN THRONE

> **Módulo M2 · Ruta: `[crítica · vías alternativas]`**
>
> **Objetivo único:** Elegir e implementar el mecanismo de persistencia proporcional al entorno: Golden/Diamond Ticket, cert forjado (si hay ADCS), DSRM backdoor, o AdminSDHolder.
>
> **Prerequisito real:** M1 (hash krbtgt obtenido y evaluación del entorno).
>
> **Habilita:** acceso durable que sobrevive a resets de contraseñas de cuentas DA.
>
> **TTP:** T1558.001 · T1649 · T1556.004 · T1484

## Plan de ejecución

Elegir según lo que el entorno tiene y detecta (ver `technique.md` §8). Implementar el mecanismo elegido. Si hay ADCS disponible, el forged cert es la opción más robusta. DSRM si quieres backdoor en el DC silencioso. AdminSDHolder si quieres que los permisos se auto-restauren.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: este módulo es el PLAN. Captura aquí la ejecución real — comandos, hashes obtenidos, mecanismo elegido y justificado.

---

*Módulo M2 · Lab-14 Golden Throne · Domain Dominance (anatomía v3.1, arquetipo operación)*
