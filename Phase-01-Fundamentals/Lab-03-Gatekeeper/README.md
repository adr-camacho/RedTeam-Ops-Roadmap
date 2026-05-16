# 🎯 OPERATION DARK GATE
### Plan de Operación — Lab-03: Gatekeeper

---

## 📋 Ficha de Operación

| Campo | Detalle |
|-------|---------|
| **Nombre en clave** | DARK GATE |
| **Fecha de inicio** | — |
| **Operador** | Adrián Camacho |
| **Adversario simulado** | FIN7 (Carbanak) |
| **Framework** | MITRE ATT&CK v14 — Enterprise |
| **Metodología C2** | Sliver (post-explotación) |
| **Objetivo primario** | RCE en servicio Gatekeeper via Buffer Overflow |
| **Objetivo secundario** | Escalada a SYSTEM + persistencia |
| **Entorno** | Lab propio — VirtualBox NAT Network `LabRedTeam` |

---

## 🕵️ Perfil del Adversario — FIN7 (Carbanak)

FIN7 es un grupo de cibercrimen organizado con motivación financiera, atribuido a actores de habla rusa. Sus campañas se caracterizan por la explotación manual de servicios vulnerables expuestos, el uso de herramientas personalizadas y técnicas de post-explotación orientadas a la persistencia a largo plazo en entornos corporativos.

### Características tácticas que se replican en esta operación

| Característica | Implementación en el lab |
|---------------|--------------------------|
| **Explotación de servicios expuestos** | Buffer Overflow en servicio Gatekeeper (x86 Windows) |
| **Desarrollo de exploits propios** | Construcción manual del exploit BOF en Python |
| **Evasión de protecciones básicas** | Bypass de SEH / control de EIP con badchars identificados |
| **Persistencia via servicios** | Servicio Windows malicioso para acceso persistente |
| **C2 encubierto** | Sliver beacon HTTPS post-explotación |
| **Living-off-the-Land** | Comandos nativos Windows para escalada y reconocimiento |

### TTPs de referencia (MITRE)
- [G0046 — FIN7](https://attack.mitre.org/groups/G0046/)

---

## 🏗️ Entorno de Operación

```
┌─────────────────────────────────────────────────────┐
│              RED NAT — LabRedTeam                   │
│               Segmento: 10.0.2.0/24                 │
│                                                     │
│   ┌─────────────────────────────────────────────┐   │
│   │            GATE-01 (Windows)                │   │
│   │            10.0.2.X                         │   │
│   │            Windows 10/11                    │   │
│   │            Servicio Gatekeeper :31337        │   │
│   │            [objetivo BOF]                   │   │
│   └─────────────────────────────────────────────┘   │
│                        ▲                            │
│                        │                            │
│   ┌────────────────────┴────────────────────────┐   │
│   │                  Kali Linux                 │   │
│   │               10.0.2.9 (fijo)               │   │
│   │           Máquina operadora FIN7            │   │
│   └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Máquinas del entorno

| Host | SO | IP | Rol en la operación |
|------|----|----|---------------------|
| GATE-01 | Windows 10/11 x86 | `10.0.2.X` (DHCP → fijar) | Objetivo — servicio Gatekeeper vulnerable |
| Kali | Kali Linux 2026.1 | `10.0.2.9` | Máquina operadora FIN7 |

---

## 🗺️ Plan de Operación — Fases

---

### FASE 1 — Reconnaissance
**Táctica MITRE:** TA0043 — Reconnaissance  
**Objetivo:** Identificar el servicio Gatekeeper expuesto y confirmar que es explotable.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 1.1 | Network Service Discovery | T1046 | Nmap (port scan completo) | ✅ Output completo |
| 1.2 | Service Version Detection | T1046 | Nmap -sC -sV | ✅ Servicio Gatekeeper :31337 |
| 1.3 | Service Interaction | T1046 | nc / Python socket | ✅ Banner del servicio |

**Criterio de éxito:** Servicio Gatekeeper identificado en puerto `:31337`. Confirmar que acepta conexiones TCP.

---

### FASE 2 — Vulnerability Research (BOF)
**Táctica MITRE:** TA0043 — Reconnaissance / TA0001 — Initial Access  
**Objetivo:** Desarrollar el exploit de Buffer Overflow paso a paso — fuzzing, offset, badchars, shellcode.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 2.1 | Fuzzing — crash del servicio | T1588.006 | Python script fuzzer | ✅ Servicio crasheado |
| 2.2 | EIP offset — cyclic pattern | T1588.006 | msf-pattern_create/offset | ✅ EIP offset identificado |
| 2.3 | Badchars identification | T1588.006 | Python + Immunity Debugger | ✅ Lista de badchars |
| 2.4 | JMP ESP — return address | T1588.006 | mona.py / msf-nasm_shell | ✅ Dirección JMP ESP |
| 2.5 | Shellcode generation | T1587.001 | msfvenom | ✅ Shellcode generado |
| 2.6 | Exploit completo | T1203 | Python exploit script | ✅ Shell reversa obtenida |

**Criterio de éxito:** Shell reversa en GATE-01 mediante exploit BOF propio.

---

### FASE 3 — Initial Access (Exploitation)
**Táctica MITRE:** TA0001 — Initial Access  
**Objetivo:** Ejecutar el exploit BOF contra el servicio Gatekeeper en producción y obtener shell.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 3.1 | Exploit Public-Facing Application | T1203 | Python exploit script | ✅ Shell reversa activa |
| 3.2 | System Information Discovery | T1082 | whoami, systeminfo | ✅ Contexto del sistema |
| 3.3 | Network Configuration Discovery | T1016 | ipconfig | ✅ IPs y red |

**Criterio de éxito:** Shell reversa estable en GATE-01.

---

### FASE 4 — Privilege Escalation
**Táctica MITRE:** TA0004 — Privilege Escalation  
**Objetivo:** Escalar desde el usuario del servicio hasta SYSTEM.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 4.1 | Token Impersonation | T1134.001 | PrintSpoofer / GodPotato | ✅ whoami = SYSTEM |
| 4.2 | Unquoted Service Path | T1574.009 | sc query + icacls | ✅ Vector identificado |
| 4.3 | Weak Service Permissions | T1574.011 | accesschk / sc sdshow | ✅ Permisos abusables |
| 4.4 | AlwaysInstallElevated | T1548.002 | reg query + msiexec | ✅ Ejecución como SYSTEM |

**Criterio de éxito:** Shell como SYSTEM en GATE-01.

---

### FASE 5 — C2 Establishment
**Táctica MITRE:** TA0011 — Command and Control  
**Objetivo:** Desplegar beacon Sliver en GATE-01 para operar con C2 real.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 5.1 | C2 HTTPS Listener | T1071.001 | Sliver server | ✅ Listener activo |
| 5.2 | Implant Generation | T1587.001 | Sliver generate | ✅ Beacon generado |
| 5.3 | Implant Transfer | T1105 | Python HTTP server | ✅ Beacon transferido |
| 5.4 | Implant Execution | T1204 | cmd.exe / PowerShell | ✅ Beacon conectado |

**Criterio de éxito:** Sesión Sliver activa desde GATE-01.

---

### FASE 6 — Persistence
**Táctica MITRE:** TA0003 — Persistence  
**Objetivo:** Establecer persistencia mediante servicio Windows malicioso.

| # | Técnica | ID MITRE | Herramienta | Captura requerida |
|---|---------|----------|-------------|-------------------|
| 6.1 | Create Windows Service | T1543.003 | sc create | ✅ Servicio creado |
| 6.2 | Registry Run Key | T1547.001 | reg add | ✅ Run Key añadida |
| 6.3 | Credential Dumping | T1003.002 | reg save SAM/SYSTEM | ✅ Hashes obtenidos |
| 6.4 | Objective Proof | — | whoami + hostname | ✅ Prueba final |

**Criterio de éxito:** Persistencia establecida + hashes obtenidos + prueba de compromiso.

---

## 📸 Capturas Obligatorias por Fase

| Fase | Archivo | Descripción |
|------|---------|-------------|
| 1 | `fase1-01-nmap-port-discovery.png` | Port scan completo GATE-01 |
| 1 | `fase1-02-nmap-service-version.png` | Servicio Gatekeeper :31337 identificado |
| 1 | `fase1-03-service-banner.png` | Banner del servicio via netcat |
| 2 | `fase2-01-fuzzing-crash.png` | Servicio crasheado con fuzzer |
| 2 | `fase2-02-eip-offset.png` | EIP offset identificado |
| 2 | `fase2-03-badchars.png` | Lista de badchars identificados |
| 2 | `fase2-04-jmp-esp.png` | Dirección JMP ESP encontrada |
| 2 | `fase2-05-shellcode.png` | Shellcode generado con msfvenom |
| 3 | `fase3-01-shell-reversa.png` | Shell reversa obtenida via BOF |
| 3 | `fase3-02-sysinfo.png` | whoami + systeminfo |
| 4 | `fase4-01-privesc-vector.png` | Vector de escalada identificado |
| 4 | `fase4-02-system-shell.png` | Shell como SYSTEM |
| 5 | `fase5-01-sliver-listener.png` | Listener Sliver activo |
| 5 | `fase5-02-beacon-generated.png` | Beacon generado |
| 5 | `fase5-03-beacon-connected.png` | Sesión Sliver activa |
| 6 | `fase6-01-persistence.png` | Servicio Windows creado |
| 6 | `fase6-02-credential-dump.png` | Hashes NTLM obtenidos |
| 6 | `fase6-03-objective-proof.png` | Prueba final de compromiso |

---

## 📄 Documentos a generar al finalizar

| Documento | Descripción |
|-----------|-------------|
| `enumeration_log.md` | Fase 1: Reconnaissance + banner grabbing |
| `bof_development.md` | Fase 2: Desarrollo completo del exploit BOF |
| `exploitation.md` | Fase 3: Ejecución del exploit en producción |
| `privilege_escalation.md` | Fase 4: Escalada a SYSTEM |
| `c2_sliver.md` | Fase 5: Beacon Sliver en GATE-01 |
| `persistence.md` | Fase 6: Persistencia + objective completion |
| `infrastructure_setup.md` | Configuración del entorno y servicio Gatekeeper |
| `lessons_learned.md` | Lecciones aprendidas post-operación |
| `mitigations.md` | Mitigaciones Blue Team |

---

## 🛡️ Notas Operacionales (OPSEC FIN7)

1. **Desarrollo del exploit en entorno controlado** — desarrollar y probar el BOF contra una copia local del servicio antes de ejecutarlo en producción (evita crashes innecesarios que alertan al Blue Team)
2. **Shellcode stageless** — usar shellcode completo en el payload (no stager) para evitar una segunda conexión de red detectable
3. **NOP sled generoso** — añadir NOP sled (`\x90` × 16-32) antes del shellcode para compensar variaciones de stack en entornos reales
4. **C2 solo post-SYSTEM** — el beacon Sliver se despliega únicamente tras escalar a SYSTEM — máximo acceso desde el inicio del C2
5. **Documentar cada paso del BOF** — el desarrollo del exploit es la parte más técnica del lab — documentar offset, badchars, JMP ESP y shellcode con capturas individuales

---

## 🔵 Detección (Blue Team)

| Indicador | Log Source | Regla |
|-----------|-----------|-------|
| Conexión TCP repetida a :31337 con payloads grandes | Network/IDS | Alert payload > 1000 bytes en puerto servicio |
| Crash del proceso Gatekeeper | Windows Event 1000 | Application Error — gatekeeper.exe |
| Conexión saliente desde gatekeeper.exe | Sysmon Event 3 | Network connection desde proceso de servicio |
| Nuevo servicio Windows creado | Event ID 7045 | New service installed |
| reg save HKLM\SAM | Sysmon Event 1 | CommandLine contains reg save SAM |

---

*Operación DARK GATE — Adrián Camacho*  
*Entorno de laboratorio — Únicamente con fines educativos*