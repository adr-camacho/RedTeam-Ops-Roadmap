# Bitácora de Enumeración

## 📡 Escaneo Inicial (WinRM)
Se confirmó acceso remoto mediante **Evil-WinRM** con credenciales comprometidas previamente:
* **Usuario**: `svcadmin`
* **Privilegios**: `SeMachineAccountPrivilege`, `SeChangeNotifyPrivilege`.

## 👥 Censo de Usuarios y Grupos
Tras enumerar el dominio, se identificaron:
* **Administrador**: Único miembro de `Admins. del dominio`.
* **Usuarios Activos**: `maria`, `alberto`, `mgarcia`, `lperez`, `jgarcia`, `sql_svc`.

## 🛡️ Defensas Observadas
* **UAC**: Activo.
* **Restricciones**: El comando `systeminfo` devuelve "Acceso denegado" para usuarios no administradores.
* **Localización**: Los comandos deben adaptarse a nombres de grupos en español.