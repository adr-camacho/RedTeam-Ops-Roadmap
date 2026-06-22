# Detection — Lab-01 Ghost Forest

> **Capability:** primera kill-chain AD (AS-REP/Kerberoasting → DCSync → DA).
> **Operación:** GHOST FOREST · **Adversario:** APT29 · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** reglas SIGMA consolidadas y transversales en
> [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md) — fuente de verdad del
> texto de las reglas. Aquí, la detección **específica de esta operación**, por técnica y en orden de kill-chain.

Para cada técnica: **telemetría** (Event IDs) · **detección** (regla) · **hardening** · y al final el puente de
**limitaciones y evasión** hacia los labs de Phase-03.

---

## Fase 1 — Reconnaissance

### T1046 — Network Service Discovery (Nmap)

**Detección:**
| Event ID | Fuente | Descripción |
|----------|--------|-------------|
| 5156 | Security | Windows Filtering Platform — conexiones de red permitidas. Múltiples conexiones en puertos variados desde una misma IP en corto tiempo |
| 4625 | Security | Intentos de conexión fallidos en masa |

```yaml
# Regla SIGMA — Port Scan Detection
title: Network Port Scan Detected
status: experimental
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 5156
  timeframe: 60s
  condition: selection | count(DestinationPort) by SourceIP > 50
level: medium
```

**Mitigación:**
- Implementar IDS/IPS (Snort, Suricata) con reglas de detección de escaneo
- Limitar exposición de puertos con Windows Firewall — principio de mínimo privilegio
- Segmentar redes — Kali no debería tener acceso directo al DC

---

### T1135 — Network Share Discovery (SMB Null Session)

**Detección:**
| Event ID | Fuente | Descripción |
|----------|--------|-------------|
| 4624 | Security | Logon anónimo (Logon Type 3, Account Name: ANONYMOUS LOGON) |
| 4625 | Security | Intento de acceso anónimo denegado |

**Mitigación:**
- Deshabilitar sesiones nulas SMB:
```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
  -Name "RestrictNullSessAccess" -Value 1
```
- Deshabilitar SMBv1:
```powershell
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
```
- Requerir firma SMB (ya activo en el lab — SMB signing: required)

---

## Fase 2 — Credential Access

### T1558.004 — AS-REP Roasting

**Detección:**
| Event ID | Fuente | Descripción |
|----------|--------|-------------|
| **4768** | Security | Kerberos TGT request — buscar RC4 encryption (0x17) sin preauth |
| 4771 | Security | Kerberos pre-authentication failed |

```yaml
# Regla SIGMA — AS-REP Roasting Detection
title: AS-REP Roasting Attack
status: stable
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4768
    TicketEncryptionType: '0x17'  # RC4 — débil, usado en AS-REP roasting
    PreAuthType: '0'              # Sin preautenticación
  condition: selection
falsepositives:
  - Sistemas legacy que no soportan AES
level: high
```

**Mitigación:**
- **Habilitar preautenticación Kerberos** en todas las cuentas:
```powershell
# Verificar cuentas vulnerables
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth

# Habilitar preauth en todas las cuentas
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} | 
  Set-ADUser -KerberosEncryptionType AES256
```
- Usar contraseñas largas (>25 caracteres) en cuentas de servicio para dificultar el cracking
- Añadir cuentas de servicio al grupo **Protected Users**

---

### T1110.002 — Password Cracking (Diccionario dirigido)

**Detección:** El cracking ocurre offline — no genera eventos en el DC. La única detección posible es preventiva.

**Mitigación:**
- Política de contraseñas: mínimo 15 caracteres, complejidad alta, rotación cada 90 días
- Usar **Fine-Grained Password Policies** para cuentas privilegiadas:
```powershell
New-ADFineGrainedPasswordPolicy -Name "ServiceAccountPolicy" `
  -MinPasswordLength 20 `
  -ComplexityEnabled $true `
  -PasswordHistoryCount 24 `
  -MaxPasswordAge "90.00:00:00" `
  -Precedence 10
```
- Monitorizar uso de wordlists corporativas — las contraseñas siguieron el patrón `Empresa+Año+Símbolo`

---

## Fase 3 — Initial Access

### T1021.006 — Remote Services: WinRM

**Detección:**
| Event ID | Fuente | Descripción |
|----------|--------|-------------|
| **4624** | Security | Logon Type 3 (Network) desde IP externa |
| **4648** | Security | Logon usando credenciales explícitas |
| 800 | PowerShell | Pipeline execution — comandos ejecutados via WinRM |
| 4103 | PowerShell | Module logging |
| 4104 | PowerShell | Script block logging |

```powershell
# Habilitar PowerShell Script Block Logging (recomendado)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" `
  -Name "EnableScriptBlockLogging" -Value 1
```

**Mitigación:**
- Restringir WinRM a IPs de administración conocidas via GPO
- Requerir autenticación con certificado para WinRM en lugar de usuario/contraseña
- Deshabilitar WinRM en máquinas que no lo necesiten:
```powershell
Disable-PSRemoting -Force
Stop-Service WinRM
Set-Service WinRM -StartupType Disabled
```

---

## Fase 4 — Discovery

### T1087.002 — Account Discovery: Domain Account

**Detección:**
| Event ID | Fuente | Descripción |
|----------|--------|-------------|
| 4661 | Security | Acceso a objetos de AD (enumeración de usuarios) |
| 4662 | Security | Operación sobre objeto de directorio |

**Mitigación:**
- Restringir quién puede leer atributos sensibles de AD:
```powershell
# Eliminar permisos de lectura de descriptions para usuarios estándar
# (evita passwords en claro en el campo description)
```
- **Nunca almacenar contraseñas en el campo Description** de usuarios AD
- Implementar **Tiering Model** — separar cuentas de admin, servicio y usuario

---

### T1558.003 — Kerberoasting

**Detección:**
| Event ID | Fuente | Descripción |
|----------|--------|-------------|
| **4769** | Security | Kerberos Service Ticket request — buscar RC4 (0x17) para SPNs de cuentas de usuario |

```yaml
# Regla SIGMA — Kerberoasting Detection
title: Kerberoasting Attack
status: stable
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4769
    TicketEncryptionType: '0x17'  # RC4
    ServiceName|endswith: '$'     # Excluir cuentas de máquina
  filter:
    ServiceName: 'krbtgt'
  condition: selection and not filter
falsepositives:
  - Sistemas legacy con RC4
level: high
```

**Mitigación:**
- Usar **Managed Service Accounts (gMSA)** — contraseñas automáticas de 120 caracteres:
```powershell
New-ADServiceAccount -Name "sql_gmsa" `
  -DNSHostName "DC-01.atackcorp.local" `
  -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers"
```
- Forzar AES256 en cuentas con SPN:
```powershell
Set-ADUser backup_svc -KerberosEncryptionType AES256
```
- Añadir cuentas de servicio privilegiadas al grupo **Protected Users**
- Rotar contraseñas de cuentas con SPN regularmente (>25 caracteres)

---

## Fase 5-6 — Lateral Movement

### T1021.006 — WinRM Lateral Movement

**Detección:** Mismo Event ID 4624 pero ahora el origen es el DC (10.0.2.10) hacia WKSTN-01 (10.0.2.8) — movimiento este-oeste sospechoso.

**Mitigación:**
- Implementar **Local Administrator Password Solution (LAPS)** — contraseñas únicas por máquina
- Segmentar red para que el DC no pueda iniciar conexiones hacia workstations
- Implementar **Privileged Access Workstations (PAW)**

---

## Fase 7 — C2

### T1071.001 — C2 via HTTPS

**Detección:**
- Analizar certificados TLS auto-firmados en tráfico HTTPS saliente
- Beacons periódicos — conexiones regulares a la misma IP cada ~60 segundos
- DNS queries a dominios no categorizados

```yaml
# Regla SIGMA — Beacon Detection
title: Periodic HTTPS Beacon
status: experimental
logsource:
  product: zeek
  service: http
detection:
  selection:
    resp_mime_types|contains: 'application/octet-stream'
  timeframe: 5m
  condition: selection | count() by id.orig_h, id.resp_h > 4
level: medium
```

**Mitigación:**
- Implementar **proxy SSL inspection** para inspeccionar tráfico HTTPS
- Bloquear conexiones directas a internet desde workstations — forzar proxy
- Implementar **DNS filtering** (Umbrella, Pi-hole empresarial)
- EDR con detección de beacons (Elastic, CrowdStrike, SentinelOne)

---

## Fase 8 — Privilege Escalation

### T1562.001 — Impair Defenses (Defender + Tamper Protection)

**Detección:**
| Event ID | Fuente | Descripción |
|----------|--------|-------------|
| **5001** | Windows Defender | Real-time protection disabled |
| **5010** | Windows Defender | Anti-malware disabled |
| 4657 | Security | Modificación de clave de registro (Defender policies) |

```yaml
title: Windows Defender Disabled
status: stable
logsource:
  product: windows
  service: windefend
detection:
  selection:
    EventID:
      - 5001
      - 5010
      - 5007
  condition: selection
level: critical
```

**Mitigación:**
- **Tamper Protection habilitada** — impide modificación de Defender sin acceso físico
- Centralizar logs de Defender en SIEM
- Alertas inmediatas si Defender se deshabilita en cualquier máquina

---

## Fase 9-10 — Credential Access & Objective

### T1003.006 — DCSync

**Detección:**
| Event ID | Fuente | Descripción |
|----------|--------|-------------|
| **4662** | Security | Operación sobre objeto AD con permisos de replicación |

```yaml
title: DCSync Attack
status: stable
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4662
    Properties|contains:
      - '1131f6aa-9c07-11d1-f79f-00c04fc2dcd2'  # DS-Replication-Get-Changes
      - '1131f6ab-9c07-11d1-f79f-00c04fc2dcd2'  # DS-Replication-Get-Changes-All
  filter:
    SubjectUserName|endswith: '$'  # Excluir cuentas de máquina (DCs legítimos)
  condition: selection and not filter
falsepositives:
  - Domain Controllers legítimos replicando
level: critical
```

**Mitigación:**
- **Auditar regularmente** permisos de replicación sobre el objeto raíz del dominio:
```powershell
(Get-Acl "AD:\DC=atackcorp,DC=local").Access | Where-Object {
  $_.ActiveDirectoryRights -match "ExtendedRight" -and
  $_.ObjectType -match "1131f6aa|1131f6ab|89e95b76"
} | Select IdentityReference, ActiveDirectoryRights
```
- Ningún usuario que no sea un DC debería tener permisos de replicación
- Añadir **Administrador** al grupo **Protected Users**
- Implementar **Credential Guard** en el DC

### T1550.002 — Pass-the-Hash

**Detección:**
| Event ID | Fuente | Descripción |
|----------|--------|-------------|
| 4624 | Security | Logon Type 3 con NTLM (NtLmSsp) en lugar de Kerberos |
| 4625 | Security | Fallos de autenticación NTLM |

**Mitigación:**
- Habilitar **Kerberos only** — deshabilitar NTLM en el dominio:
```powershell
# GPO: Network security: Restrict NTLM: NTLM authentication in this domain
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" `
  -Name "RestrictReceivingNTLMTraffic" -Value 2
```
- Implementar **Credential Guard** — protege hashes NTLM en memoria
- Rotar contraseña de Administrador built-in regularmente con LAPS

---

---

## Limitaciones y evasión (puente a Phase-03)

Toda la detección anterior asume **defensas activas y sin evadir** — es la pasada "off". Un operador real se
enfrenta a la pasada "on", y cada detección de arriba tiene su evasión, que se practica en los labs de evasión:

| Detección de este lab | Cómo se evade | Se trata en |
|-----------------------|---------------|-------------|
| AS-REP/Kerberoasting por RC4 (0x17) | Solicitar tickets AES (0x12) para no destacar | Lab-11 (evasión) |
| DCSync por Event 4662 (replicación) | Timing, origen desde un DC legítimo comprometido | Lab-11/12 |
| Defender deshabilitado (5001/5010) | No tocar Tamper Protection: AMSI/ETW bypass en memoria | Lab-11 (Defender/AMSI) |
| Beacon HTTPS periódico | Malleable C2, jitter alto, perfiles legítimos | Lab-08/11 |

> Esta tabla materializa el modelo "off, then on" del `LEARNING_PATH.md`: aquí ves la técnica con la defensa
> despierta; allí, cómo operarla sin que te vea.

---

## Resumen de Hardening Prioritario

```
PRIORIDAD CRÍTICA (implementar inmediatamente)
════════════════════════════════════════════════════════
1. Habilitar preautenticación Kerberos en TODAS las cuentas
2. Eliminar contraseñas del campo Description de usuarios AD
3. Implementar gMSA para cuentas de servicio con SPN
4. Habilitar Tamper Protection en todos los endpoints
5. Auditar permisos de replicación AD — ningún usuario normal
6. Implementar Credential Guard en DC y servidores críticos

PRIORIDAD ALTA
════════════════════════════════════════════════════════
7. Habilitar PowerShell Script Block Logging (Event 4104)
8. Implementar LAPS para contraseñas de admin local
9. Añadir cuentas privilegiadas a Protected Users
10. Restringir WinRM a IPs de administración conocidas
11. Implementar Tiering Model (Tier 0/1/2)
12. Segmentar red — DC no debe iniciar conexiones a workstations

PRIORIDAD MEDIA
════════════════════════════════════════════════════════
13. Proxy SSL inspection para tráfico HTTPS
14. DNS filtering
15. IDS/IPS con reglas de detección de escaneo
16. SIEM centralizado con reglas SIGMA implementadas
17. EDR con detección de beacons
18. Fine-Grained Password Policies para cuentas privilegiadas
```

---

*Detection · Lab-01 Ghost Forest · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
