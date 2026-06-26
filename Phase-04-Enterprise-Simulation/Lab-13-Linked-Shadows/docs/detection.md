# Detection — Lab-13 Linked Shadows

> **Capability:** detección de ataques MSSQL (enum, xp_cmdshell, lateral via linked servers).
> **Arquetipo:** Operación · **Adversario:** APT10 · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

> SQL Server tiene su propio ecosistema de auditoría — aparte de Windows Event Logs y Sysmon. Un defensor maduro habilita SQL Audit y monitoriza los eventos de la instancia, no solo los del SO.

---

## 1. Detección de enumeración (SPN / conexiones de test)

- **Consultas LDAP a SPNs de MSSQL** — patrón de discovery desde un host inusual.
- Múltiples intentos de conexión a puertos 1433 desde un único origen no-DBA.
- **Sysmon Event 3** (network connection) hacia puertos SQL desde procesos inusuales.

## 2. Detección de xp_cmdshell

| Señal | Fuente |
|-------|--------|
| Habilitación de `xp_cmdshell` vía `sp_configure` | SQL Server Audit / Error Log |
| Proceso hijo de `sqlservr.exe` (cmd.exe, powershell.exe) | Sysmon Event 1 |
| Ejecución de OS commands desde contexto SQL | SQL Server Audit (si habilitado) |
| `RECONFIGURE` seguido de actividad de proceso | Correlación SQL + Sysmon |

> **La señal más clara:** proceso hijo de `sqlservr.exe` o `MSSQLSERVER` ejecutando `cmd.exe` o `powershell.exe`. Casi nunca legítimo.

## 3. Detección de abuso de linked servers

- **Consultas cross-server** (OPENQUERY, AT [servidor]) desde cuentas no esperadas.
- SQL Audit: consultas a `sys.servers` y `sp_linkedservers` desde cuentas de usuario normal.
- Patrón de "salto": misma cuenta conectando a SQL-A, luego desde SQL-A a SQL-B en cadena rápida.

## 4. Detección de escalada SQL (impersonation)

- `EXECUTE AS LOGIN` con login de sysadmin desde una cuenta de privilegio menor.
- SQL Audit Event: cambio de contexto de seguridad (`Audit Login Change Password Event`).

## 5. Reglas de ejemplo (concepto)

- **Sigma:** proceso hijo de `sqlservr.exe` siendo `cmd.exe`/`powershell.exe`.
- **KQL/Defender:** `DeviceProcessEvents` filtrando parent=SQL y child=shell.
- **SQL Audit:** alertar sobre habilitación de `xp_cmdshell` y `EXECUTE AS` hacia sysadmin.
- **Red:** conexiones SQL en cadena entre servidores internos fuera del horario/patrón normal.

---

## Limitaciones y evasión

| Detección | Cómo se evade | Profundiza en |
|-----------|---------------|----------------|
| Proceso hijo de SQL | Inyección en proceso existente (no crear cmd.exe) | Lab-16 |
| SQL Audit de xp_cmdshell | Si ya estaba habilitado, no hay evento de configuración | este lab |
| Consultas cross-server anómalas | Usar cuentas de servicio legítimas comprometidas | — |

---

*Detection · Lab-13 Linked Shadows · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
