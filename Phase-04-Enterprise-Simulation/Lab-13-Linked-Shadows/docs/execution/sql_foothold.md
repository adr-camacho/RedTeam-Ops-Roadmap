# Módulo M2 · Foothold SQL — conectar y enumerar privilegios — Lab-13 LINKED SHADOWS

> **Módulo M2 · Ruta: `[crítica]`**
>
> **Objetivo único:** Conectarse a la instancia objetivo y determinar nivel de privilegio SQL (public/db_owner/sysadmin) y linked servers disponibles.
>
> **Prerequisito real:** M1 (instancia accesible identificada).
>
> **Habilita:** conocer si hay xp_cmdshell disponible y qué linked servers existen.
>
> **TTP:** T1210

## Plan de ejecución

`SELECT SYSTEM_USER, IS_SRVROLEMEMBER('sysadmin')` · `SELECT * FROM sys.servers WHERE is_linked=1` · `EXEC sp_linkedservers`. Mapa del terreno SQL.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: este módulo es el PLAN. Captura aquí la ejecución real — comandos, salidas, capturas, la cuenta de servicio SQL obtenida.

---

*Módulo M2 · Lab-13 Linked Shadows · Cloud Hopper SQL (anatomía v3.1, arquetipo operación)*
