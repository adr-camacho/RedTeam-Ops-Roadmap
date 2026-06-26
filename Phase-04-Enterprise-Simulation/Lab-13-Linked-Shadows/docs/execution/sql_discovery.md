# Módulo M1 · Discovery — instancias SQL en el dominio — Lab-13 LINKED SHADOWS

> ### Mapa de la operación (kill-chain SQL — Cloud Hopper en linked servers)
> ```
>   M1 Discovery    →  M2 Foothold SQL   →  M3 Escalada SQL   →  M4 xp_cmdshell
>   (SPNs + test       (conexión + enum      (sysadmin vía        (beacon bajo
>    instancias)        privilegios)          impersonation)        cuenta SQL)
>                                                  │
>                                                  ▼ (si hay linked servers)
>                                            M5 Lateral vía linked servers
>                                            (SQL-A → SQL-B → beacon en servidor remoto)
> ```
> **Lectura:** M1-M4 son la columna; M5 es el lateral implícito si hay linked servers.
> El objetivo final es **un beacon bajo la cuenta de servicio SQL** en el servidor de destino.
> ⚠ **Arquetipo operación:** `execution/` es el **PLAN de ataque**. Pasa a operativa real con tus capturas.

> **Módulo M1 · Ruta: `[crítica]`**
>
> **Objetivo único:** Enumerar instancias MSSQL accesibles en el dominio vía SPNs LDAP y test de conectividad.
>
> **Prerequisito real:** baliza en el dominio con credenciales de usuario.
>
> **Habilita:** lista de instancias accesibles y con qué credenciales.
>
> **TTP:** T1046 · T1018

## Plan de ejecución

PowerUpSQL: `Get-SQLInstanceDomain` + `Get-SQLConnectionTestThreaded`. Primero LDAP (silencioso), luego test selectivo de conexión.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: este módulo es el PLAN. Captura aquí la ejecución real — comandos, salidas, capturas, la cuenta de servicio SQL obtenida.

---

*Módulo M1 · Lab-13 Linked Shadows · Cloud Hopper SQL (anatomía v3.1, arquetipo operación)*
