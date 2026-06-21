# 🔵 Detection Rules — Red Team Ops Roadmap

> Reglas de detección consolidadas para todas las técnicas del roadmap.  
> Perspectiva Blue Team — cómo detectar cada TTP ejecutado en los labs.  
> Organizado por táctica MITRE. Incluye Event IDs, reglas SIGMA y notas de evasión.

---

## 📋 Índice

1. [Reconnaissance](#1-reconnaissance)
2. [Initial Access](#2-initial-access)
3. [Credential Access — Kerberos](#3-credential-access--kerberos)
4. [Credential Access — Dumping](#4-credential-access--dumping)
5. [Lateral Movement](#5-lateral-movement)
6. [Command & Control — Tunneling](#6-command--control--tunneling)
7. [Command & Control — C2 Beacons](#7-command--control--c2-beacons)
8. [Privilege Escalation](#8-privilege-escalation)
9. [Persistence](#9-persistence)
10. [Defense Evasion](#10-defense-evasion)
11.  [ACL Abuse & Delegation](#11-acl-abuse--delegation)

---

## 1. Reconnaissance

### T1046 — Network Service Discovery (Nmap)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| N/A | IDS/NDR | Nmap no genera eventos Windows — solo visible en red |

**Indicadores de red:**
- Múltiples conexiones TCP SYN a puertos distintos desde la misma IP en corto intervalo
- Patrones de escaneo: puertos secuenciales, TTL anómalo, User-Agent de Nmap scripts NSE
- Source port constante con destination ports variables

**Regla SIGMA:**
```yaml
title: Nmap Port Scan Detection
id: nmap-port-scan-01
status: experimental
description: Detects potential port scanning activity based on connection patterns
logsource:
    category: network_connection
    product: windows
detection:
    selection:
        Initiated: 'true'
    timeframe: 10s
    condition: selection | count(DestinationPort) by SourceIp > 20
falsepositives:
    - Vulnerability scanners legítimos
    - Monitorización de red interna
level: medium
tags:
    - attack.reconnaissance
    - attack.t1046
```

**Mitigación:** Network segmentation + IDS/NDR (Zeek, Suricata). No es detectable a nivel de host sin agente de red.

---

## 2. Initial Access

### T1190 — Exploit Public-Facing Application (CVE-2019-15107 Webmin)

**Lab:** Lab-02 (APT41)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| N/A | Web access log | POST a `/password_change.cgi` con payload en campo `old` |

**Indicadores:**
- `POST /password_change.cgi` con campo `old` conteniendo `|`, `;`, `$()` u otros metacaracteres de shell
- Proceso hijo de Webmin (`miniserv.pl`) lanzando `/bin/bash`, `python`, `curl`, `wget`
- Conexión saliente desde el proceso del servidor web hacia IP externa en puerto no estándar

**Regla SIGMA:**
```yaml
title: Webmin CVE-2019-15107 Exploitation Attempt
id: webmin-rce-01
status: experimental
description: Detects exploitation of CVE-2019-15107 Webmin RCE via password_change.cgi
logsource:
    category: webserver
detection:
    selection:
        cs-method: 'POST'
        cs-uri-stem|contains: '/password_change.cgi'
        cs-post-body|contains:
            - '|'
            - '$('
            - '`'
            - ';bash'
            - 'nc '
    condition: selection
falsepositives:
    - Muy improbable — estos metacaracteres no deberían aparecer en cambios de contraseña legítimos
level: critical
tags:
    - attack.initial_access
    - attack.t1190
    - cve.2019-15107
```

**Regla auditd (Linux) — proceso hijo sospechoso de Webmin:**
```
-a always,exit -F arch=b64 -S execve -F ppid=$(pgrep miniserv.pl) -k webmin_child_exec
```

---

## 3. Credential Access — Kerberos

### T1558.004 — AS-REP Roasting

**Lab:** Lab-01 (APT29)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4768** | Security (DC) | Kerberos TGT request — campo `Pre-Authentication Type: 0` indica AS-REP Roasting |

**Condición de detección:** `Event 4768` con `PreAuthType = 0x0` (sin preautenticación)

**Regla SIGMA:**
```yaml
title: AS-REP Roasting Activity
id: asrep-roasting-01
status: stable
description: Detects AS-REP Roasting — TGT requested without Kerberos pre-authentication
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4768
        PreAuthType: '0'
        Status: '0x0'
    condition: selection
falsepositives:
    - Sistemas legacy que requieren RC4 sin preautenticación (documentar excepciones)
level: high
tags:
    - attack.credential_access
    - attack.t1558.004
```

**Mitigación:** Habilitar `Require Kerberos preauthentication` en todas las cuentas. Usar `Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true}` para auditoría regular.

---

### T1558.003 — Kerberoasting

**Lab:** Lab-01 (APT29)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4769** | Security (DC) | Kerberos TGS request — cifrado RC4 (0x17) es indicador de Kerberoasting |

**Condición de detección:** `Event 4769` con `TicketEncryptionType = 0x17 (RC4)` desde cuentas no de servicio

**Regla SIGMA:**
```yaml
title: Kerberoasting via RC4 TGS Request
id: kerberoasting-01
status: stable
description: Detects Kerberoasting — TGS requested with RC4 encryption (weak, offline-crackable)
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4769
        TicketEncryptionType: '0x17'
        ServiceName|endswith: '$'
    filter:
        ServiceName:
            - 'krbtgt'
            - '*$'
    condition: selection and not filter
falsepositives:
    - Sistemas legacy que no soportan AES
level: high
tags:
    - attack.credential_access
    - attack.t1558.003
```

**Mitigación:** Configurar cuentas de servicio con contraseñas de >25 caracteres + aleatorias (MSA/gMSA). Forzar AES en cuentas con SPN: `Set-ADUser -KerberosEncryptionType AES128,AES256`.

---

### T1558.001 — Golden Ticket

**Lab:** Lab-01 (APT29)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4769** | Security (DC) | TGS con lifetime anómalo (>10h) o desde cuenta inexistente |
| **4672** | Security (DC) | Asignación de privilegios especiales a cuenta con ticket forjado |

**Indicadores difíciles de detectar:**
- Lifetime del ticket superior al máximo de la política (default: 10h ticket, 7 días renewal)
- RID de la cuenta en el ticket no coincide con ninguna cuenta del dominio
- Cifrado RC4 en ticket de cuenta que debería usar AES256

> **Nota Lab-01:** En Windows Server 2022 con PAC Validation activa, el Golden Ticket clásico genera `KDC_ERR_TGT_REVOKED`. La detección es efectiva en entornos modernos.

**Regla SIGMA:**
```yaml
title: Golden Ticket Indicators
id: golden-ticket-01
status: experimental
description: Detects potential Golden Ticket usage via anomalous Kerberos ticket properties
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4769
        TicketEncryptionType: '0x17'
    timeframe: 1h
    condition: selection | count() by SubjectUserName > 10
falsepositives:
    - Sistemas legacy con múltiples solicitudes RC4
level: high
tags:
    - attack.credential_access
    - attack.t1558.001
```

---

## 4. Credential Access — Dumping

### T1003.006 — DCSync

**Lab:** Lab-01 (APT29)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4662** | Security (DC) | Operación realizada sobre objeto AD — GUID de replicación |

**GUIDs a monitorizar en Event 4662:**
- `1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` — DS-Replication-Get-Changes
- `1131f6ab-9c07-11d1-f79f-00c04fc2dcd2` — DS-Replication-Get-Changes-All ← el más crítico

**Regla SIGMA:**
```yaml
title: DCSync Replication Rights Abuse
id: dcsync-01
status: stable
description: Detects DCSync attack via DS-Replication-Get-Changes-All permission usage
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4662
        ObjectType: '%{19195a5b-6da0-11d0-afd3-00c04fd930c9}'
        AccessMask: '0x100'
        Properties|contains:
            - '1131f6ab-9c07-11d1-f79f-00c04fc2dcd2'
    filter:
        SubjectUserName|endswith: '$'
    condition: selection and not filter
falsepositives:
    - Domain Controllers legítimos realizando replicación (filtrar por cuenta $)
    - Azure AD Connect con permisos de sincronización
level: critical
tags:
    - attack.credential_access
    - attack.t1003.006
```

**Mitigación:** Auditar regularmente cuentas con `DS-Replication-Get-Changes-All` sobre el objeto raíz del dominio. Solo DCs y cuentas de sincronización (Azure AD Connect) deberían tener este permiso.

---

### T1003.001 — LSASS Memory Dump

**Lab:** Lab-02 (APT41)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **Sysmon 10** | Sysmon | Process access — acceso a `lsass.exe` desde proceso no firmado |
| **4656** | Security | Handle solicitado sobre LSASS con `PROCESS_VM_READ` |

**Regla SIGMA:**
```yaml
title: LSASS Memory Access by Non-System Process
id: lsass-dump-01
status: stable
description: Detects suspicious access to LSASS process memory
logsource:
    category: process_access
    product: windows
detection:
    selection:
        TargetImage|endswith: '\lsass.exe'
        GrantedAccess|contains:
            - '0x1010'
            - '0x1410'
            - '0x147a'
            - '0x143a'
    filter:
        SourceImage|startswith:
            - 'C:\Windows\System32\'
            - 'C:\Windows\SysWOW64\'
            - 'C:\Program Files\Windows Defender\'
    condition: selection and not filter
falsepositives:
    - Antivirus / EDR accediendo a LSASS para protección
level: critical
tags:
    - attack.credential_access
    - attack.t1003.001
```

---

## 5. Lateral Movement

### T1021.006 — Windows Remote Management (WinRM)

**Labs:** Lab-01, Lab-02

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4624** | Security | Logon Type 3 (Network) — autenticación WinRM |
| **4648** | Security | Explicit credential logon — uso de credenciales alternativas |
| **Microsoft-Windows-WinRM/Operational** | WinRM | Conexión establecida — Event ID 6 (WSMan) |

**Regla SIGMA:**
```yaml
title: WinRM Lateral Movement
id: winrm-lateral-01
status: experimental
description: Detects lateral movement via WinRM from non-standard source
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4624
        LogonType: 3
        AuthenticationPackageName: 'Kerberos'
        ProcessName: 'C:\Windows\System32\wsmprovhost.exe'
    filter:
        SubjectUserName|endswith: '$'
    condition: selection and not filter
falsepositives:
    - Administración remota legítima via WinRM
    - Ansible / DSC / scripts de automatización IT
level: medium
tags:
    - attack.lateral_movement
    - attack.t1021.006
```

---

### T1550.002 — Pass-the-Hash

**Lab:** Lab-01 (APT29)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4624** | Security | Logon Type 3 con NTLM — sin contraseña en texto claro |
| **4625** | Security | Logon fallido — intentos PtH erróneos |

**Indicadores específicos de PtH:**
- Logon Type 3 + AuthPackage NTLM + SubjectUserName vacío o con ANONYMOUS
- Autenticación NTLM en dominio que debería usar Kerberos exclusivamente

**Regla SIGMA:**
```yaml
title: Pass-the-Hash Activity
id: pth-01
status: experimental
description: Detects potential Pass-the-Hash via NTLM network logon anomalies
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4624
        LogonType: 3
        AuthenticationPackageName: 'NTLM'
    filter:
        SubjectUserName: 'ANONYMOUS LOGON'
    condition: selection and not filter
falsepositives:
    - Autenticación NTLM legítima en entornos mixtos
    - Impresoras y dispositivos sin soporte Kerberos
level: medium
tags:
    - attack.lateral_movement
    - attack.t1550.002
```

**Mitigación:** Habilitar `Restrict NTLM: Outgoing NTLM traffic` + Protected Users Security Group para cuentas privilegiadas.

---

## 6. Command & Control — Tunneling

### T1572 — Protocol Tunneling (Ligolo-ng)

**Lab:** Lab-02 (APT41)

**Indicadores en host comprometido (Linux — auditd):**
```
# Creación de interfaz TUN
-a always,exit -F arch=b64 -S ioctl -k tun_create

# Proceso con conexión TLS saliente en puerto no estándar
-a always,exit -F arch=b64 -S connect -F uid!=0 -k outbound_connect
```

**Indicadores de red:**
- Conexión TLS saliente desde servidor/workstation comprometido a IP externa en puerto 11601 (u otro no estándar)
- Handshake TLS con certificado autofirmado (sin CA reconocida)
- Tráfico TLS persistente de baja latencia desde un host que normalmente no genera tráfico saliente cifrado

**Regla SIGMA (host Linux):**
```yaml
title: Ligolo-ng Agent Execution
id: ligolo-agent-01
status: experimental
description: Detects Ligolo-ng agent execution via process and network indicators
logsource:
    category: process_creation
    product: linux
detection:
    selection:
        CommandLine|contains:
            - '-connect'
            - '-ignore-cert'
            - 'ligolo'
    condition: selection
falsepositives:
    - Herramientas de tunneling legítimas en entornos de desarrollo
level: high
tags:
    - attack.command_and_control
    - attack.t1572
```

**Regla de red (Suricata/Zeek):**
```
alert tls any any -> any 11601 (msg:"Possible Ligolo-ng C2 tunnel"; sid:9000001; rev:1;)
alert tls any any -> any any (msg:"TLS with self-signed cert to non-standard port"; \
  tls.cert_issuer; content:"self-signed"; sid:9000002; rev:1;)
```

---

### T1090 — Proxy (Ligolo-ng routing)

**Indicadores:**
- Tráfico hacia segmentos de red internos originado desde un host que no debería tener visibilidad hacia esos segmentos
- Rutas de red anómalas en tablas de routing de hosts comprometidos (`ip route` mostrando rutas inyectadas)

---

## 7. Command & Control — C2 Beacons

### T1071.001 + T1573.002 — C2 HTTPS / Sliver Beacon

**Labs:** Lab-01, Lab-02

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **Sysmon 3** | Sysmon | Network connection — proceso no firmado haciendo conexión HTTPS saliente |
| **Sysmon 1** | Sysmon | Process creation — beacon.exe ejecutado con `-WindowStyle Hidden` |
| **Sysmon 7** | Sysmon | Image loaded — DLLs cargadas por el beacon |

**Indicadores de Sliver beacon:**
- Proceso no firmado con conexiones HTTPS periódicas a IP sin dominio conocido
- Intervalo de check-in regular (~60s ± jitter) — patrón de beaconing
- Certificado TLS autofirmado o con CN anómalo (Sliver genera CAs propias)
- Proceso con nombre sospechoso en `C:\Users\<user>\Documents\` o `C:\Windows\Temp\`

**Regla SIGMA — proceso sospechoso con conexión HTTPS:**
```yaml
title: Suspicious Process HTTPS Beaconing
id: sliver-beacon-01
status: experimental
description: Detects C2 beaconing via HTTPS from unsigned process in user directories
logsource:
    category: network_connection
    product: windows
detection:
    selection:
        Initiated: 'true'
        DestinationPort: 443
        Image|contains:
            - '\Users\'
            - '\Temp\'
            - '\AppData\'
    filter:
        Image|startswith:
            - 'C:\Program Files\'
            - 'C:\Program Files (x86)\'
            - 'C:\Windows\System32\'
    condition: selection and not filter
falsepositives:
    - Aplicaciones portables legítimas en directorios de usuario
    - Instaladores temporales
level: high
tags:
    - attack.command_and_control
    - attack.t1071.001
    - attack.t1573.002
```

**Regla SIGMA — ejecución con WindowStyle Hidden:**
```yaml
title: Process Execution with Hidden Window Style
id: hidden-window-01
status: stable
description: Detects process execution with hidden window — common C2 implant technique
logsource:
    category: process_creation
    product: windows
detection:
    selection:
        CommandLine|contains:
            - '-WindowStyle Hidden'
            - '-W Hidden'
            - '-windowstyle hidden'
    condition: selection
falsepositives:
    - Scripts de administración legítimos
    - Tareas programadas que no necesitan UI
level: medium
tags:
    - attack.execution
    - attack.t1204.002
```

---

## 8. Privilege Escalation

### T1134.001 — Token Impersonation (Potato attacks)

**Lab:** Lab-01 (APT29) — parcial

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4672** | Security | Asignación de privilegios especiales (SeImpersonatePrivilege) |
| **Sysmon 1** | Sysmon | PrintSpoofer / GodPotato ejecutados como child process de servicio |

**Regla SIGMA:**
```yaml
title: Token Impersonation via Potato Attack Tools
id: potato-attack-01
status: experimental
description: Detects common Potato attack tool execution patterns
logsource:
    category: process_creation
    product: windows
detection:
    selection:
        Image|endswith:
            - '\PrintSpoofer.exe'
            - '\GodPotato.exe'
            - '\SweetPotato.exe'
            - '\JuicyPotato.exe'
            - '\RoguePotato.exe'
    condition: selection
falsepositives:
    - Entornos de prueba de seguridad
level: critical
tags:
    - attack.privilege_escalation
    - attack.t1134.001
```

---

### T1548.002 — AlwaysInstallElevated

**Lab:** Lab-01 (APT29) — pendiente

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **Sysmon 1** | Sysmon | `msiexec.exe` ejecutado por usuario no privilegiado resultando en proceso SYSTEM |
| **11707** | MsiInstaller | Instalación completada — verificar si la ejecutó un usuario estándar |

**Regla SIGMA:**
```yaml
title: AlwaysInstallElevated Privilege Escalation
id: always-install-elevated-01
status: stable
description: Detects privilege escalation via AlwaysInstallElevated MSI policy
logsource:
    category: process_creation
    product: windows
detection:
    selection:
        ParentImage|endswith: '\msiexec.exe'
        IntegrityLevel: 'System'
    filter:
        Image|startswith: 'C:\Windows\System32\'
    condition: selection and not filter
falsepositives:
    - Instalaciones legítimas de software en sistemas con esta política activa
level: high
tags:
    - attack.privilege_escalation
    - attack.t1548.002
```

---

## 9. Persistence

### T1053.005 — Scheduled Task

**Lab:** Lab-02 (APT41)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4698** | Security | Scheduled task creada |
| **4702** | Security | Scheduled task modificada |
| **4699** | Security | Scheduled task eliminada (limpieza) |

**Regla SIGMA:**
```yaml
title: Suspicious Scheduled Task Creation
id: schtask-persistence-01
status: stable
description: Detects scheduled task creation with suspicious executable paths
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4698
    suspicious_paths:
        TaskContent|contains:
            - '\Users\'
            - '\Temp\'
            - '\AppData\'
            - 'powershell'
            - 'cmd.exe /c'
    condition: selection and suspicious_paths
falsepositives:
    - Software legítimo que crea tareas programadas en directorio de usuario
level: high
tags:
    - attack.persistence
    - attack.t1053.005
```

---

### T1547.001 — Registry Run Keys

**Lab:** Lab-02 (APT41)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **Sysmon 13** | Sysmon | Registry value set — claves Run/RunOnce modificadas |

**Claves a monitorizar:**
```
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
```

**Regla SIGMA:**
```yaml
title: Registry Run Key Persistence
id: run-key-persistence-01
status: stable
description: Detects persistence via Registry Run keys modification
logsource:
    category: registry_set
    product: windows
detection:
    selection:
        TargetObject|contains:
            - '\CurrentVersion\Run\'
            - '\CurrentVersion\RunOnce\'
    filter:
        Image|startswith:
            - 'C:\Program Files\'
            - 'C:\Windows\System32\'
    condition: selection and not filter
falsepositives:
    - Software legítimo que registra autorun
level: medium
tags:
    - attack.persistence
    - attack.t1547.001
```

---

## 10. Defense Evasion

### T1562.001 — AMSI Bypass / Impair Defenses

**Lab:** Lab-01 (APT29)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4657** | Security | Registry key value modified — `DisableScriptScanning` |
| **Sysmon 13** | Sysmon | `Set-MpPreference` modificando configuración de Defender |

> **Nota Lab-01:** `Set-MpPreference -DisableScriptScanning $true` requiere que Tamper Protection esté deshabilitada. Si Tamper Protection está activa, este comando falla silenciosamente. En Windows 11, Tamper Protection está activa por defecto.

**Regla SIGMA — deshabilitado de Defender via PowerShell:**
```yaml
title: Windows Defender Disabled via PowerShell
id: defender-disabled-01
status: stable
description: Detects attempts to disable Windows Defender components via Set-MpPreference
logsource:
    category: process_creation
    product: windows
detection:
    selection:
        Image|endswith: '\powershell.exe'
        CommandLine|contains:
            - 'Set-MpPreference'
            - 'DisableRealtimeMonitoring'
            - 'DisableScriptScanning'
            - 'DisableIOAVProtection'
    condition: selection
falsepositives:
    - Scripts de administración de seguridad legítimos
    - GPOs de gestión de Defender
level: high
tags:
    - attack.defense_evasion
    - attack.t1562.001
```

---

## 📊 Resumen de Event IDs por lab

### Lab-01 — Ghost Forest (APT29)

| TTP | Event ID | Fuente | Prioridad |
|-----|----------|--------|-----------|
| AS-REP Roasting | 4768 (PreAuthType=0) | DC Security | 🔴 Alta |
| Kerberoasting | 4769 (EncType=0x17) | DC Security | 🔴 Alta |
| DCSync | 4662 (GUID replicación) | DC Security | 🔴 Crítica |
| WinRM Lateral | 4624 (Type 3, wsmprovhost) | Host Security | 🟡 Media |
| Pass-the-Hash | 4624 (Type 3, NTLM) | Host Security | 🟡 Media |
| Token Impersonation | 4672 | Host Security | 🟡 Media |
| C2 Beacon | Sysmon 1, 3 | Sysmon | 🔴 Alta |
| Golden Ticket | 4769 (lifetime anómalo) | DC Security | 🔴 Alta |
| AMSI Bypass | Sysmon 13 | Sysmon | 🟡 Media |

### Lab-02 — Silent Bridge (APT41)

| TTP | Event ID | Fuente | Prioridad |
|-----|----------|--------|-----------|
| Webmin RCE | Web access log | Web server | 🔴 Crítica |
| Ligolo-ng agent | auditd (ioctl tun) | auditd Linux | 🔴 Alta |
| C2 Tunnel | Firewall (outbound :11601) | Network | 🔴 Alta |
| WinRM Lateral | 4624 (Type 3, wsmprovhost) | Host Security | 🟡 Media |
| C2 Beacon | Sysmon 1, 3 | Sysmon | 🔴 Alta |
| Scheduled Task | 4698 | Host Security | 🟡 Media |
| Registry Run Key | Sysmon 13 | Sysmon | 🟡 Media |
| LSASS Dump | Sysmon 10 | Sysmon | 🔴 Alta |

---

## 11. ACL Abuse & Delegation

### T1222 — WriteDACL Abuse → DCSync (Lab-04)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4670** | Security (DC) | Permissions on an object were changed |
| **4662** | Security (DC) | Operation performed on AD object — ACE modificada |

**Regla SIGMA:**
```yaml
title: WriteDACL Abuse - DCSync Rights Added
id: writedacl-dcsync-01
status: experimental
description: Detects addition of DCSync replication rights to non-DC account via dacledit
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4662
        Properties|contains:
            - '1131f6aa-9c07-11d1-f79f-00c04fc2dcd2'
            - '1131f6ab-9c07-11d1-f79f-00c04fc2dcd2'
        AccessMask: '0x40000'
    filter:
        SubjectUserName|endswith: '$'
    condition: selection and not filter
falsepositives:
    - Azure AD Connect legítimo
    - Administradores configurando replicación
level: critical
tags:
    - attack.privilege_escalation
    - attack.t1222
```

---

### T1558.001 — RBCD Abuse (Lab-05)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4741** | Security (DC) | Computer account created — ATTACKER$ via MAQ |
| **4742** | Security (DC) | Computer account changed — msDS-AllowedToActOnBehalfOfOtherIdentity modificado |
| **4769** | Security (DC) | S4U2Self + S4U2Proxy — TGS requests anómalos |

**Regla SIGMA — cuenta de máquina creada por usuario no-admin:**
```yaml
title: RBCD Abuse - Machine Account Created by Non-Admin User
id: rbcd-machine-account-01
status: experimental
description: Detects potential RBCD abuse via MachineAccountQuota — machine account created by standard user
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4741
    filter:
        SubjectUserName|endswith: '$'
    condition: selection and not filter
falsepositives:
    - Administradores creando cuentas de máquina legítimas
level: high
tags:
    - attack.persistence
    - attack.t1136.002
```

**Regla SIGMA — msDS-AllowedToActOnBehalfOfOtherIdentity modificado:**
```yaml
title: RBCD - msDS-AllowedToActOnBehalfOfOtherIdentity Modified
id: rbcd-attribute-01
status: experimental
description: Detects modification of msDS-AllowedToActOnBehalfOfOtherIdentity attribute — RBCD setup
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4742
        AttributeLDAPDisplayName: 'msDS-AllowedToActOnBehalfOfOtherIdentity'
    condition: selection
falsepositives:
    - Configuración legítima de RBCD por administradores
level: high
tags:
    - attack.privilege_escalation
    - attack.t1558.001
```

**Mitigación:** Reducir `MachineAccountQuota` a 0. Monitorizar cambios en `msDS-AllowedToActOnBehalfOfOtherIdentity`.

---

### T1556 — Shadow Credentials (Lab-05)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4662** | Security (DC) | WriteProperty sobre msDS-KeyCredentialLink (GUID: 5b47d60f-...) |
| **4768** | Security (DC) | PKINIT TGT request — campo Certificate Info presente |

**Regla SIGMA:**
```yaml
title: Shadow Credentials - msDS-KeyCredentialLink Modified
id: shadow-credentials-01
status: experimental
description: Detects modification of msDS-KeyCredentialLink attribute — Shadow Credentials attack
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4662
        Properties|contains: '5b47d60f-6090-40b2-9f37-2a4de88f3063'
        AccessMask: '0x40'
    condition: selection
falsepositives:
    - Windows Hello for Business configuración legítima
    - Azure AD Certificate-based auth setup
level: high
tags:
    - attack.credential_access
    - attack.t1556
```

**Mitigación:** Restringir WriteProperty sobre msDS-KeyCredentialLink. Monitorizar autenticación PKINIT en cuentas de servicio.

---

### T1558.002 — Silver Ticket (Lab-05)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| N/A | DC Security | Silver Ticket **NO contacta al KDC** — ausencia de Event 4768 antes de 4769 |
| **4624** | Security (servicio) | Logon en el servicio destino sin TGT previo observable |

> ⚠️ **Dificultad de detección:** El Silver Ticket es el ticket más difícil de detectar porque no requiere contactar al KDC. La detección requiere correlación de eventos o soluciones PAM avanzadas.

**Indicadores:**
- Event 4769 (TGS) sin Event 4768 (TGT) previo en la misma fuente
- Ticket con lifetime anómalo (Silver Tickets forjados suelen tener 10 años)
- Acceso a servicio desde host sin autenticación previa al dominio

**Regla SIGMA:**
```yaml
title: Silver Ticket - Kerberos Service Ticket Without Prior TGT
id: silver-ticket-01
status: experimental
description: Detects potential Silver Ticket via Kerberos service access without TGT
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4769
        TicketEncryptionType: '0x17'
    condition: selection
falsepositives:
    - Sistemas legacy con RC4
level: medium
tags:
    - attack.credential_access
    - attack.t1558.002
```

**Mitigación:** Rotar contraseñas de cuentas de servicio regularmente. Usar MSA/gMSA para rotación automática. Implementar Microsoft Defender for Identity.

---

### T1558.001 — Diamond Ticket (Lab-05)

**Event IDs relevantes:**
| ID | Fuente | Descripción |
|----|--------|-------------|
| **4768** | Security (DC) | TGT request con Certificate Authentication — PKINIT |
| **4769** | Security (DC) | TGS request — PAC anómalo si Defender for Identity está activo |

> ⚠️ **Dificultad de detección:** El Diamond Ticket es casi indistinguible de autenticación legítima — el TGT es real y válido. Solo Microsoft Defender for Identity puede detectar inconsistencias en el PAC.

**Indicadores:**
- Event 4768 con PKINIT desde host que normalmente no usa certificados
- Microsoft Defender for Identity: alerta "Suspected Golden Ticket usage"
- PAC con grupos que no coinciden con la cuenta real (requiere correlación avanzada)

**Mitigación:** Implementar Microsoft Defender for Identity. Rotar krbtgt dos veces para invalidar tickets existentes tras incidente.

---

## 📊 Resumen de Event IDs — Labs 03-05

### Lab-03 — Dark Gate (APT29)

| TTP | Event ID | Fuente | Prioridad |
|-----|----------|--------|-----------|
| ADCS Enum (Certipy) | 4662 (object read) | DC Security | 🟡 Media |
| ESC1 — SAN Abuse | 4887 (cert issued) | CA Security | 🔴 Alta |
| ESC4 — Template Write | 4899 (template modified) | CA Security | 🔴 Crítica |
| ESC8 — NTLM Relay | 4624 (Type 3, NTLM→HTTP) | DC Security | 🔴 Alta |
| Certificate Persistence | 4768 (PKINIT post-rotation) | DC Security | 🔴 Alta |

### Lab-04 — Iron Forest (APT28)

| TTP | Event ID | Fuente | Prioridad |
|-----|----------|--------|-----------|
| WriteDACL → DCSync | 4662 (ACE replicación) | DC Security | 🔴 Crítica |
| DCSync | 4662 (GUID replicación) | DC Security | 🔴 Crítica |
| ADIDNS — WPAD | DNS debug logs | DNS Server | 🔴 Alta |
| Responder NTLMv2 | 4776 (NTLM auth) | DC Security | 🟡 Media |

### Lab-05 — Silver Chain (APT28)

| TTP | Event ID | Fuente | Prioridad |
|-----|----------|--------|-----------|
| RBCD — MAQ | 4741 (computer created) | DC Security | 🔴 Alta |
| RBCD — Attribute | 4742 (msDS-AllowedToAct...) | DC Security | 🔴 Alta |
| Shadow Credentials | 4662 (msDS-KeyCredLink) | DC Security | 🔴 Alta |
| PKINIT auth | 4768 (cert info) | DC Security | 🟡 Media |
| Silver Ticket | Ausencia 4768 antes 4769 | DC Security | 🔴 Alta |
| Diamond Ticket | Defender for Identity | MDA | 🔴 Alta |
| Machine Account | 4741 (non-admin subject) | DC Security | 🔴 Alta |

---

## 🔗 Referencias

- [MITRE ATT&CK Detection — por técnica](https://attack.mitre.org/techniques/enterprise/)
- [Sigma Rules Repository — SigmaHQ](https://github.com/SigmaHQ/sigma)
- [Sysmon Config (SwiftOnSecurity)](https://github.com/SwiftOnSecurity/sysmon-config)
- [Windows Security Auditing — Microsoft Docs](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/)
- [MITRE D3FEND — Contramedidas](https://d3fend.mitre.org/)
- [Elastic Detection Rules](https://github.com/elastic/detection-rules)

---

*Última actualización: Mayo 2026 — Labs 03-05 añadidos (ADCS, WriteDACL, RBCD, Shadow Creds, Silver/Diamond Ticket) — Adrián Camacho*
---

## Lab-06 — BLACK POLICY | APT28 (Fancy Bear)

---

### T1134.005 — SID-History Injection

**Event IDs clave:**

| Event ID | Descripcion |
|----------|-------------|
| **4765** | SID History added to an account — alerta critica inmediata |
| **4766** | Attempt to add SID History failed |
| 7045 | NTDS service stopped (DSInternals requiere parar NTDS) |

```yaml
title: SID History Added to Account
id: sid-history-injection-001
status: stable
description: Detecta adicion de SID History a cualquier cuenta AD
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID:
      - 4765
      - 4766
  condition: selection
falsepositives:
  - Migraciones AD legitimas (muy raras en produccion)
level: critical
tags:
  - attack.privilege_escalation
  - attack.t1134.005
```

**Hardening:**
```powershell
# Habilitar SID Filtering en todos los trusts
netdom trust atackcorp.local /domain:corp.local /quarantine:Yes
netdom trust atackcorp.local /domain:ext.local /quarantine:Yes

# Auditar cuentas con sIDHistory no vacio
Get-ADUser -Filter * -Properties sIDHistory |
    Where-Object {$_.sIDHistory.Count -gt 0} |
    Select-Object SamAccountName, sIDHistory
```

---

### T1558.003 — Kerberoasting Cross-Forest + Targeted Kerberoasting

**Event IDs clave:**

| Event ID | Descripcion |
|----------|-------------|
| **4769** | Kerberos TGS request — buscar EncryptionType 0x17 (RC4) desde IPs externas al dominio |
| **4738** | User account changed — servicePrincipalName modificado (Targeted Kerberoasting) |

```yaml
title: Targeted Kerberoasting via SPN Injection
id: targeted-kerberoast-001
status: experimental
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4738
    ServicePrincipalName|contains: 'fake/'
  condition: selection
level: high
tags:
  - attack.credential_access
  - attack.t1558.003
```

```yaml
title: Cross-Forest RC4 Kerberoasting
id: crossforest-kerberoast-001
status: experimental
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4769
    TicketEncryptionType: '0x17'
  filter_local:
    IpAddress|startswith: '10.0.2.'
  filter_dc:
    IpAddress: '::1'
  condition: selection and not filter_local and not filter_dc
level: high
tags:
  - attack.credential_access
  - attack.t1558.003
```

---

### T1484.001 — GPO Modification via pyGPOAbuse

**Event IDs clave:**

| Event ID | Descripcion |
|----------|-------------|
| **5136** | Directory service object modified — GPO DACL o GPT.INI modificado |
| **4698** | Scheduled task was created — tarea creada por GPO en workstation |
| **4702** | Scheduled task was updated |
| 4699 | Scheduled task was deleted (cleanup) |
| 4700 | Scheduled task was enabled |

```yaml
title: GPO Modified - Potential GPO Abuse
id: gpo-abuse-001
status: experimental
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 5136
    ObjectClass: groupPolicyContainer
    AttributeLDAPDisplayName:
      - nTSecurityDescriptor
      - gPCMachineExtensionNames
      - versionNumber
  condition: selection
falsepositives:
  - Administradores modificando GPOs legitimamente
level: high
tags:
  - attack.privilege_escalation
  - attack.t1484.001
```

```yaml
title: Unexpected ScheduledTask Created via GPO
id: gpo-schedtask-001
status: experimental
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4698
  filter_legitimate:
    TaskName|startswith:
      - '\Microsoft\'
      - '\Windows\'
  condition: selection and not filter_legitimate
level: medium
tags:
  - attack.privilege_escalation
  - attack.t1053.005
```

---

### T1482 — Domain Trust Discovery

**Event IDs clave:**

| Event ID | Descripcion |
|----------|-------------|
| 4662 | Operation on AD object — enumeracion de objetos trustedDomain |
| 4624 | Logon con Type 3 desde IPs externas al dominio |

```yaml
title: Domain Trust Enumeration via LDAP
id: trust-discovery-001
status: experimental
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4662
    ObjectType: trustedDomain
    AccessMask: '0x20000'
  condition: selection
level: low
tags:
  - attack.reconnaissance
  - attack.t1482
```

---

### Resumen Event IDs Lab-06

| Tecnica | MITRE | Event ID | Nivel |
|---------|-------|----------|-------|
| SID History Injection | T1134.005 | **4765**, 4766 | Critico |
| NTDS detenido (DSInternals) | T1003.003 | 7045 | Alto |
| GPO DACL modificado | T1484.001 | **5136** | Alto |
| ScheduledTask creada via GPO | T1053.005 | **4698** | Medio |
| Targeted Kerberoasting SPN | T1558.003 | **4738** | Alto |
| Cross-Forest Kerberoasting RC4 | T1558.003 | **4769** | Alto |
| Trust Discovery | T1482 | 4662 | Bajo |
| DCSync multi-forest | T1003.006 | **4662** DS-Replication | Alto |

---

*Ultima actualizacion: Junio 2026 — Lab-06 BLACK POLICY añadido (SID History, GPO Abuse, Cross-Forest Kerberoasting) — Adrian Camacho*