# Módulo M3 · Escalada SQL — conseguir sysadmin — Lab-13 LINKED SHADOWS

> **Módulo M3 · Ruta: `[crítica si no eres sysadmin]`**
>
> **Objetivo único:** Escalar a sysadmin dentro de SQL si el acceso inicial es de privilegio menor (public/db_owner): impersonation, linked server con creds privilegiadas.
>
> **Prerequisito real:** M2 (conectado, privilegio menor).
>
> **Habilita:** sysadmin → acceso a xp_cmdshell y control total de la instancia.
>
> **TTP:** T1548

## Plan de ejecución

Chequear impersonation disponible: `SELECT * FROM fn_my_permissions(NULL,'SERVER')` · `EXECUTE AS LOGIN='sa'`. Si linked server tiene sysadmin, usar AT [linked] para escalar.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: este módulo es el PLAN. Captura aquí la ejecución real — comandos, salidas, capturas, la cuenta de servicio SQL obtenida.

---

*Módulo M3 · Lab-13 Linked Shadows · Cloud Hopper SQL (anatomía v3.1, arquetipo operación)*
