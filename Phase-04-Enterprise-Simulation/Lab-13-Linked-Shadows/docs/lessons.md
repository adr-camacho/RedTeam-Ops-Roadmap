# Lessons — Lab-13 Linked Shadows

> Lecciones del bloque MSSQL. Se completan con observaciones reales tras ejecutar el plan.

---

## Lecciones de criterio

1. **MSSQL es lateral que la gente ignora.** En redes enterprise, los servidores SQL con linked servers a otros segmentos son una vía lateral que raramente se audita con el mismo rigor que SMB/WinRM.

2. **Linked servers = Cloud Hopper en SQL.** Saltar de SQL-A a SQL-B siguiendo la cadena de confianza es exactamente la filosofía de APT10. El lateral no siempre es "moverme a una máquina nueva con WinRM" — a veces es OPENQUERY.

3. **xp_cmdshell: verificar antes de habilitar.** Si ya está habilitado, no hay evento de configuración — el rastro es solo el proceso hijo. Si se habilita, queda en el SQL Error Log. Siempre comprobar el estado antes de tocar la configuración.

4. **La cuenta de servicio de SQL es el loot.** Muchas instancias SQL corren con cuentas de dominio privilegiadas o incluso con `NT AUTHORITY\SYSTEM`. Un beacon bajo esa cuenta es a menudo más valioso que el propio acceso al servidor.

5. **OPSEC SQL:** las conexiones de test masivas y las consultas LDAP de SPNs dejan rastro. Discovery dirigido primero.

## Pendiente de completar tras ejecutar

- [ ] Instancias SQL descubiertas y cuáles eran accesibles.
- [ ] ¿xp_cmdshell ya habilitado o hubo que habilitarlo?
- [ ] Linked servers descubiertos y cuáles permitían lateral.
- [ ] Cuenta de servicio SQL y sus privilegios en el dominio.
- [ ] Beacon obtenido en el servidor SQL.

---

*Lessons · Lab-13 Linked Shadows · anatomía v3.1*
