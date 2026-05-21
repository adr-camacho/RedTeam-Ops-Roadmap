# 🎯 OPERATION GHOST FOREST
### Plan de Operación — Lab-01: Ghost Forest

---

## 📋 Ficha de Operación

| Campo | Detalle |
|-------|---------|
| **Nombre en clave** | GHOST FOREST |
| **Fecha de inicio** | 11/05/2026 |
| **Operador** | Adrián Camacho |
| **Adversario simulado** | APT29 (Cozy Bear) |
| **Framework** | MITRE ATT&CK v14 — Enterprise |
| **Metodología C2** | Evil-WinRM (acceso inicial) → Sliver (post-lateral movement) |
| **Objetivo primario** | Domain Admin sobre `atackcorp.local` |
| **Objetivo secundario** | DCSync — Volcado de todos los hashes del dominio |
| **Entorno** | Lab propio — VirtualBox NAT Network `LabRedTeam` |

---

## 🕵️ Perfil del Adversario — APT29 (Cozy Bear)

APT29 es un actor de amenaza persistente avanzada atribuido al Servicio de Inteligencia Exterior de Rusia (SVR). Sus operaciones se caracterizan por un enfoque metódico, sigiloso y orientado al largo plazo, priorizando la persistencia y el acceso encubierto sobre la velocidad.

### Características tácticas que se replican en esta operación

| Característica | Implementación en el lab |
|---------------|--------------------------|
| **Living-off-the-Land** | Uso de herramientas nativas de Windows (net, whoami, reg) antes de introducir binarios externos |
| **Kerberos Abuse** | AS-REP Roasting y Kerberoasting como vector primario de credenciales |
| **C2 encubierto** | Sliver con perfil HTTPS para mimetizarse con tráfico legítimo |
| **Movimiento lateral sigiloso** | Pass-the-Ticket en lugar de Pass-the-Hash para reducir ruido en logs |
| **Persistencia mediante tickets** | Golden Ticket para acceso persistente sin dependencia de contraseñas |
| **Escalada mediante delegaciones** | Abuso de Unconstrained/Constrained Delegation |

### TTPs de referencia (MITRE)
- [G0016 — APT29](https://attack.mitre.org/groups/G0016/)

---

## 🏗️ Entorno de Operación

```
┌─────────────────────────────────────────────────────┐
│              RED NAT — LabRedTeam                   │
│               Segmento: 10.0.2.0/24                 │
│                                                     │
│   ┌─────────────┐          ┌─────────────────────┐  │
│   │    DC-01    │          │      WKSTN-01       │  │
│   │  10.0.2.10  │◄────────►│     10.0.2.8       │  │
│   │  WS 2022    │          │    Windows 11 Enterprise  │  │
│   │  DC / DNS   │          │    [objetivo LPE]   │  │
│   │  MSSQL/IIS  │          └─────────────────────┘  │
│   └─────────────┘                    ▲              │
│          ▲                           │              │
│          │                           │              │
│   ┌──────┴───────────────────────────┴────────────┐ │
│   │                  Kali Linux                   │ │
│   │               10.0.2.9 (fijo)                 │ │
│   │           Máquina operadora APT29             │ │
│   └───────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘

Dominio objetivo: atackcorp.local
```

### Máquinas del entorno

| Host | SO | IP | Rol en la operación |
|------|----|----|---------------------|
| DC-01 | Windows Server 2022 Standard Evaluation | `10.0.2.10` | Objetivo principal — Domain Controller |
| WKSTN-01 | Windows 11 Enterprise | `10.0.2.8` | Objetivo intermedio — LPE + C2 staging |
| Kali | Kali Linux 2026.1 | 10.0.2.9 | Máquina operadora |

---

## 🗺️ Plan de Operación — Fases

La operación sigue la cadena de ataque completa de APT29, estructurada sobre MITRE ATT&CK v14. Cada fase tiene un objetivo claro, técnicas asignadas y criterio de éxito definido.

---

### FASE 1 — Reconnaissance
**Táctica MITRE:** TA0043 — Reconnaissance  
**Objetivo:** Mapear la superficie de ataque del entorno. Identificar servicios expuestos, versiones y posibles vectores de entrada sin autenticación.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 1.1 | Network Service Discovery | T1046 | Nmap | ✅ Output completo del escaneo |
| 1.2 | SMB Enumeration | T1135 | smbclient, enum4linux-ng | ✅ Shares accesibles |
| 1.3 | LDAP Enumeration | T1087.002 | ldapsearch | ✅ Usuarios del dominio |

**Criterio de éxito:** Mapa completo de puertos, servicios y usuarios del dominio sin autenticación.

---

### FASE 2 — Initial Access (Credential Access)
**Táctica MITRE:** TA0006 — Credential Access  
**Objetivo:** Obtener credenciales válidas del dominio mediante abuso de configuraciones inseguras de Kerberos.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 2.1 | AS-REP Roasting | T1558.004 | Impacket GetNPUsers | ✅ Hash extraído |
| 2.2 | Password Cracking | T1110.002 | Hashcat / John | ✅ Contraseña en claro |
| 2.3 | Kerberoasting | T1558.003 | Impacket GetUserSPNs | ✅ Hash TGS extraído |
| 2.4 | Password Cracking (TGS) | T1110.002 | Hashcat | ✅ Contraseña sql_svc |

**Criterio de éxito:** Mínimo dos pares de credenciales válidas del dominio obtenidas offline.

---

### FASE 3 — Execution / Initial Foothold
**Táctica MITRE:** TA0002 — Execution  
**Objetivo:** Establecer acceso interactivo al DC usando las credenciales comprometidas.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 3.1 | Remote Services — WinRM | T1021.006 | Evil-WinRM | ✅ Shell interactiva |
| 3.2 | Validación de credenciales | T1078.002 | CrackMapExec | ✅ Output CME con [+] |

**Criterio de éxito:** Shell interactiva como usuario de dominio comprometido.

---

### FASE 4 — Discovery
**Táctica MITRE:** TA0007 — Discovery  
**Objetivo:** Enumerar el entorno AD completo para identificar attack paths hacia Domain Admin. Fase Living-off-the-Land — priorizar comandos nativos.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 4.1 | System Information Discovery | T1082 | systeminfo, hostname | ✅ Info del sistema |
| 4.2 | Account Discovery — Domain | T1087.002 | net user /domain | ✅ Lista de usuarios |
| 4.3 | Permission Groups Discovery | T1069.002 | net group /domain | ✅ Grupos y miembros |
| 4.4 | Domain Trust Discovery | T1482 | nltest /domain_trusts | ✅ Trusts del dominio |
| 4.5 | BloodHound Collection | T1087.002 | SharpHound / bloodhound-python | ✅ Grafo de attack path |
| 4.6 | ACL Enumeration | T1222 | PowerView | ✅ ACEs abusables |

**Criterio de éxito:** Grafo BloodHound completo con attack path identificado hacia DA.

---

### FASE 5 — Credential Access (Ampliada)
**Táctica MITRE:** TA0006 — Credential Access  
**Objetivo:** Ampliar el conjunto de credenciales mediante técnicas adicionales desde el foothold.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 5.1 | Credentials in Files | T1552.001 | dir, type | ✅ Credenciales en shares/IIS |
| 5.2 | Credentials in Registry | T1552.002 | reg query | ✅ Autologon keys |
| 5.3 | MSSQL xp_cmdshell | T1505.001 | Impacket mssqlclient | ✅ Ejecución de comandos |

**Criterio de éxito:** Credenciales adicionales y acceso a MSSQL con xp_cmdshell.

---

### FASE 6 — Lateral Movement
**Táctica MITRE:** TA0008 — Lateral Movement  
**Objetivo:** Moverse desde DC-01 a WKSTN-01 usando técnicas de autenticación alternativa.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 6.1 | Pass-the-Ticket | T1550.003 | Rubeus / Impacket | ✅ Ticket importado |
| 6.2 | Remote Services — WinRM | T1021.006 | Evil-WinRM | ✅ Shell en WKSTN-01 |
| 6.3 | SMB Lateral Movement | T1021.002 | CrackMapExec | ✅ Ejecución remota |

**Criterio de éxito:** Shell interactiva en WKSTN-01 como usuario de dominio.

---

### FASE 7 — C2 Establishment
**Táctica MITRE:** TA0011 — Command and Control  
**Objetivo:** Desplegar beacon Sliver en WKSTN-01 para operar el resto de la cadena con C2 real, replicando el comportamiento de APT29.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 7.1 | C2 HTTPS Listener | T1071.001 | Sliver server | ✅ Listener activo |
| 7.2 | Implant Generation | T1587.001 | Sliver generate | ✅ Beacon generado |
| 7.3 | Implant Execution | T1204 | Evil-WinRM upload | ✅ Beacon conectado |
| 7.4 | Encrypted Channel | T1573.002 | Sliver mTLS/HTTPS | ✅ Sesión Sliver activa |

**Criterio de éxito:** Sesión Sliver activa desde WKSTN-01 hacia Kali.

---

### FASE 8 — Privilege Escalation
**Táctica MITRE:** TA0004 — Privilege Escalation  
**Objetivo:** Elevar privilegios a SYSTEM en WKSTN-01 mediante abuso de tokens y configuraciones inseguras.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 8.1 | Token Impersonation | T1134.001 | PrintSpoofer / GodPotato | ✅ whoami = SYSTEM |
| 8.2 | Unquoted Service Path | T1574.009 | sc query + icacls | ✅ Binario plantado |
| 8.3 | AlwaysInstallElevated | T1548.002 | msiexec | ✅ Ejecución como SYSTEM |

**Criterio de éxito:** Shell SYSTEM en WKSTN-01 desde sesión Sliver.

---

### FASE 9 — Persistence
**Táctica MITRE:** TA0003 — Persistence  
**Objetivo:** Establecer persistencia mediante Golden Ticket para mantener acceso al dominio independientemente de cambios de contraseñas.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 9.1 | Dump KRBTGT hash | T1003.006 | secretsdump / Mimikatz | ✅ Hash KRBTGT |
| 9.2 | Golden Ticket Forge | T1558.001 | Impacket ticketer | ✅ Ticket forjado |
| 9.3 | Golden Ticket Use | T1550.003 | Impacket psexec | ✅ Acceso como DA |

**Criterio de éxito:** Acceso como Domain Admin mediante ticket forjado offline.

---

### FASE 10 — Objective Completion
**Táctica MITRE:** TA0006 + TA0009 — Credential Access + Collection  
**Objetivo:** Completar el objetivo primario — Domain Admin y volcado total de credenciales del dominio.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 10.1 | DCSync | T1003.006 | Impacket secretsdump | ✅ Todos los hashes NT del dominio |
| 10.2 | Domain Admin shell | T1078.002 | psexec / wmiexec | ✅ whoami = Administrator |
| 10.3 | Data Collection | T1039 | SMB / Evil-WinRM | ✅ Acceso a shares sensibles |

**Criterio de éxito:** Hash NT del Administrator + acceso interactivo como DA.

---


---

### FASE 11 — Unconstrained + Constrained Delegation
**Táctica MITRE:** TA0006 — Credential Access  
**Objetivo:** Abusar de configuraciones de delegación para obtener TGTs de usuarios privilegiados.

| # | Técnica | ID MITRE | Herramienta | Estado |
|---|---------|----------|-------------|--------|
| 11.1 | Unconstrained Delegation — sql_svc | T1558.001 | Rubeus monitor | ✅ |
| 11.2 | Forzar autenticación DC (SpoolSample/PetitPotam) | T1187 | PetitPotam | ✅ |
| 11.3 | Extraer TGT del DC desde memoria sql_svc | T1558.001 | Rubeus dump | ✅ |
| 11.4 | Constrained Delegation — iis_svc (S4U2Proxy) | T1558.001 | Rubeus s4u | ✅ |
| 11.5 | Obtener TGS como Administrador → MSSQLSvc/DC-01 | T1558.001 | impacket getST | ✅ |

**Criterio de éxito:** TGT del DC obtenido via Unconstrained + TGS DA via Constrained.

---

### FASE 12 — GPO Abuse
**Táctica MITRE:** TA0004 — Privilege Escalation  
**Objetivo:** Abusar de permisos FullControl de helpdesk.ruiz sobre IT-Baseline GPO para ejecutar código como SYSTEM en equipos del OU IT.

| # | Técnica | ID MITRE | Herramienta | Estado |
|---|---------|----------|-------------|--------|
| 12.1 | Identificar GPO con permisos abusables | T1484.001 | Get-GPPermission | ✅ |
| 12.2 | Escribir ScheduledTasks.xml en SYSVOL | T1484.001 | PowerShell directo | ✅ |
| 12.3 | Añadir tarea inmediata a la GPO | T1053.005 | XML en SYSVOL | ✅ |
| 12.4 | Forzar gpupdate en WKSTN-01 | T1484.001 | gpupdate /force | ✅ |
| 12.5 | helpdesk.ruiz → Admin local WKSTN-01 | T1484.001 | net localgroup | ✅ |

**Criterio de éxito:** Ejecución de código como SYSTEM via GPO en equipos del OU IT.

---

### FASE 13 — ACL Abuse (GenericWrite)
**Táctica MITRE:** TA0004 — Privilege Escalation  
**Objetivo:** fin.garcia tiene GenericWrite sobre sql_svc — añadir SPN para Kerberoastear sql_svc y obtener su contraseña, luego abusar de sql_svc (Unconstrained Delegation).

| # | Técnica | ID MITRE | Herramienta | Estado |
|---|---------|----------|-------------|--------|
| 13.1 | Identificar GenericWrite de fin.garcia sobre sql_svc | T1222 | dacledit | ✅ |
| 13.2 | Añadir SPN a sql_svc (targeted Kerberoasting) | T1558.003 | bloodyAD | ✅ |
| 13.3 | Kerberoastear sql_svc con nuevo SPN | T1558.003 | GetUserSPNs | ✅ |
| 13.4 | Crackear hash TGS de sql_svc | T1110.002 | John + wordlist OSINT | ✅ |
| 13.5 | sql_svc comprometida → Unconstrained Delegation → DA | T1558.001 | impacket | ✅ |

**Criterio de éxito:** Domain Admin via cadena fin.garcia → GenericWrite → SPN → Kerberoast → sql_svc → Unconstrained Delegation.


---

## 📸 Capturas Obligatorias por Fase

| Fase | Archivo | Descripción |
|------|---------|-------------|
| 1 | `01_nmap_full.png` | Output completo Nmap |
| 1 | `02_smb_enum.png` | Shares SMB accesibles |
| 1 | `03_ldap_users.png` | Usuarios enumerados via LDAP |
| 2 | `04_asrep_hash.png` | Hash AS-REP extraído |
| 2 | `05_asrep_cracked.png` | Contraseña crackeada |
| 2 | `06_kerberoast_hash.png` | Hash TGS extraído |
| 2 | `07_kerberoast_cracked.png` | Contraseña sql_svc crackeada |
| 3 | `08_winrm_shell.png` | Shell Evil-WinRM activa |
| 4 | `09_domain_enum.png` | Enumeración AD (usuarios/grupos) |
| 4 | `10_bloodhound_path.png` | Attack path en BloodHound |
| 5 | `11_credentials_found.png` | Credenciales adicionales |
| 6 | `12_lateral_wkstn.png` | Shell en WKSTN-01 |
| 7 | `13_sliver_session.png` | Sesión Sliver activa |
| 8 | `14_system_shell.png` | Shell SYSTEM |
| 9 | `15_golden_ticket.png` | Golden Ticket forjado |
| 10 | `16_dcsync.png` | DCSync — todos los hashes |
| 10 | `17_domain_admin.png` | Shell como Domain Admin |
| 11 | `fase11-01-unconstrained-monitor.png` | Rubeus monitor en sql_svc |
| 11 | `fase11-02-dc-tgt-captured.png` | TGT del DC capturado |
| 11 | `fase11-03-constrained-s4u.png` | TGS DA via S4U2Proxy |
| 12 | `fase12-01-gpo-permissions.png` | helpdesk.ruiz FullControl IT-Baseline |
| 12 | `fase12-02-gpo-task-added.png` | Tarea inmediata añadida a GPO |
| 12 | `fase12-03-gpo-system-rce.png` | Ejecución SYSTEM via GPO |
| 13 | `fase13-01-genericwrite-bloodhound.png` | fin.garcia GenericWrite en BloodHound |
| 13 | `fase13-02-spn-added.png` | SPN añadido a sql_svc |
| 13 | `fase13-03-kerberoast-sqlsvc.png` | TGS sql_svc crackeado |

---

## 📄 Documentos a generar al finalizar

| Documento | Descripción |
|-----------|-------------|
| `enumeration_log.md` | Bitácora completa de reconocimiento y discovery |
| `exploitation.md` | Fases 2-3: Kerberos attacks y acceso inicial |
| `post-exploitation.md` | Fases 4-8: Discovery, lateral movement, LPE |
| `persistence.md` | Fase 9: Golden Ticket y persistencia |
| `infrastructure_setup.md` | Configuración del entorno y vectores inyectados |
| `Reporte_GHOST_FOREST.pdf` | Informe ejecutivo completo de la operación |

---

## 🛡️ Notas Operacionales (OPSEC APT29)

Durante la operación se seguirán las siguientes restricciones para mantener fidelidad al perfil del adversario:

1. **Priorizar LOLBins** — Antes de subir cualquier herramienta externa, intentar con binarios nativos de Windows (`net`, `nltest`, `reg`, `wmic`, `certutil`).
2. **Minimizar ruido en Kerberos** — No hacer fuerza bruta de usuarios. Solo solicitar tickets de cuentas ya identificadas.
3. **C2 solo en WKSTN-01** — El beacon Sliver no se despliega en el DC para evitar detección en el activo más crítico.
4. **Pass-the-Ticket sobre Pass-the-Hash** — PtT genera menos eventos sospechosos en entornos con NTLM deshabilitado.
5. **Documentar todo en tiempo real** — Cada comando ejecutado se registra con su output antes de continuar.

---

*Operación GHOST FOREST — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*