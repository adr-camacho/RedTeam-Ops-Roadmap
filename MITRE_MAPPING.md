# 🎯 MITRE ATT&CK Mapping — Red Team Ops Roadmap

> Mapeo de todas las técnicas utilizadas en el roadmap contra el framework MITRE ATT&CK.  
> Adversario simulado: APT29 (Cozy Bear) — Actor de estado con especialización en AD y evasión de defensas.  
> Framework: MITRE ATT&CK v14 — Enterprise

---

## 🕵️ Perfil del Adversario Simulado

| Atributo | Detalle |
|---------|---------|
| **Grupo** | APT29 / Cozy Bear |
| **Origen** | Estado-nación (Rusia) |
| **Objetivos típicos** | Gobiernos, think tanks, empresas tecnológicas |
| **Motivación** | Espionaje, persistencia a largo plazo |
| **TTPs principales** | Kerberos abuse, Living-off-the-Land, C2 encubierto, evasión de EDR |
| **C2 preferido** | HTTPS con certificados legítimos, DNS tunneling |
| **Por qué este actor** | Sus técnicas cubren todo el espectro del roadmap: desde Kerberos hasta evasión avanzada |

---

## 📊 Matriz de Técnicas por Fase

### 🟢 Phase 01 — Fundamentos y Pivotaje (Labs 01-03)

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta |
|---------|---------|-------------|-----|-----|-------------|
| Reconnaissance | Network Service Discovery | — | T1046 | Lab-01 | Nmap |
| Initial Access | Valid Accounts | Domain Accounts | T1078.002 | Lab-01 | — |
| Credential Access | Steal or Forge Kerberos Tickets | AS-REP Roasting | T1558.004 | Lab-01 | Impacket GetNPUsers |
| Credential Access | Steal or Forge Kerberos Tickets | Kerberoasting | T1558.003 | Lab-01 | Impacket GetUserSPNs |
| Credential Access | Brute Force | Password Cracking | T1110.002 | Lab-01 | John / Hashcat |
| Lateral Movement | Remote Services | Windows Remote Management | T1021.006 | Lab-01 | Evil-WinRM |
| Discovery | Account Discovery | Domain Account | T1087.002 | Lab-01 | PowerView / BloodHound |
| Discovery | Domain Trust Discovery | — | T1482 | Lab-01 | BloodHound |
| Privilege Escalation | Access Token Manipulation | Token Impersonation/Theft | T1134.001 | Lab-01 | PrintSpoofer / GodPotato |
| Privilege Escalation | Hijack Execution Flow | Path Interception by Unquoted Path | T1574.009 | Lab-01/03 | — |
| Lateral Movement | Exploitation of Remote Services | — | T1210 | Lab-02 | Metasploit |
| Command & Control | Protocol Tunneling | — | T1572 | Lab-02 | Ligolo-ng / Chisel |
| Lateral Movement | Remote Services | SMB/Windows Admin Shares | T1021.002 | Lab-02 | CrackMapExec |

---

### 🟡 Phase 02 — Post-Explotación y Abuso de AD (Labs 04-06)

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta |
|---------|---------|-------------|-----|-----|-------------|
| Credential Access | OS Credential Dumping | LSASS Memory | T1003.001 | Lab-04 | Mimikatz / CrackMapExec |
| Credential Access | OS Credential Dumping | DCSync | T1003.006 | Lab-04 | Impacket secretsdump |
| Privilege Escalation | Abuse Elevation Control Mechanism | — | T1548 | Lab-04 | — |
| Persistence | Account Manipulation | — | T1098 | Lab-04 | PowerView |
| Lateral Movement | Use Alternate Authentication Material | Pass the Hash | T1550.002 | Lab-04 | CrackMapExec / Impacket |
| Lateral Movement | Use Alternate Authentication Material | Pass the Ticket | T1550.003 | Lab-04 | Rubeus / Impacket |
| Credential Access | Steal or Forge Kerberos Tickets | Golden Ticket | T1558.001 | Lab-04 | Mimikatz / Impacket ticketer |
| Credential Access | Steal or Forge Kerberos Tickets | Silver Ticket | T1558.002 | Lab-04 | Mimikatz / Impacket ticketer |
| Discovery | Cloud Infrastructure Discovery | — | T1580 | Lab-05 | AzureHound |
| Credential Access | Unsecured Credentials | Credentials in Files | T1552.001 | Lab-05/06 | — |
| Credential Access | Unsecured Credentials | Credentials in Registry | T1552.002 | Lab-06 | reg query |
| Discovery | Permission Groups Discovery | Domain Groups | T1069.002 | Lab-04 | BloodHound / PowerView |

---

### 🔴 Phase 03 — Red Team & Evasión de Defensas (Labs 07-09)

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta |
|---------|---------|-------------|-----|-----|-------------|
| Defense Evasion | Impair Defenses | Disable or Modify Tools | T1562.001 | Lab-07 | AMSI Bypass |
| Defense Evasion | Obfuscated Files or Information | — | T1027 | Lab-07 | Invoke-Obfuscation |
| Defense Evasion | Process Injection | — | T1055 | Lab-07 | Donut / Sliver |
| Defense Evasion | Modify Registry | — | T1112 | Lab-07 | — |
| Command & Control | Application Layer Protocol | Web Protocols | T1071.001 | Lab-07 | Sliver HTTPS |
| Command & Control | Application Layer Protocol | DNS | T1071.004 | Lab-07 | Sliver DNS |
| Command & Control | Encrypted Channel | Asymmetric Cryptography | T1573.002 | Lab-07 | Sliver mTLS |
| Execution | Command and Scripting Interpreter | PowerShell | T1059.001 | Lab-07 | — |
| Execution | System Services | Service Execution | T1569.002 | Lab-07 | — |
| Privilege Escalation | Domain Policy Modification | Group Policy Modification | T1484.001 | Lab-08 | — |
| Lateral Movement | Remote Services | Distributed Component Object Model | T1021.003 | Lab-09 | — |
| Persistence | Create or Modify System Process | Windows Service | T1543.003 | Lab-09 | — |

---

### 🏴 Phase 04 — Simulación de Infraestructura Real (Labs 10-12)

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta |
|---------|---------|-------------|-----|-----|-------------|
| Persistence | Account Manipulation | Additional Cloud Credentials | T1098.001 | Lab-10 | — |
| Credential Access | Steal or Forge Kerberos Tickets | Kerberoasting | T1558.003 | Lab-11 | Rubeus |
| Privilege Escalation | Domain Policy Modification | Domain Trust Modification | T1484.002 | Lab-12 | — |
| Lateral Movement | Exploitation of Remote Services | — | T1210 | Lab-10 | Metasploit |
| Collection | Data from Network Shared Drive | — | T1039 | Lab-10 | — |
| Exfiltration | Exfiltration Over C2 Channel | — | T1041 | Lab-10 | Sliver |
| Defense Evasion | Valid Accounts | — | T1078 | Lab-11 | — |
| Credential Access | OS Credential Dumping | DCSync | T1003.006 | Lab-11/12 | secretsdump |
| Privilege Escalation | Abuse Elevation Control Mechanism | Bypass User Account Control | T1548.002 | Lab-12 | — |

---

## 🗂️ Índice Completo de Técnicas (ordenado por ID)

| ID | Técnica | Sub-técnica | Fase | Labs |
|----|---------|-------------|------|------|
| T1003.001 | OS Credential Dumping | LSASS Memory | Phase-02 | Lab-04 |
| T1003.006 | OS Credential Dumping | DCSync | Phase-02/04 | Lab-04, Lab-11, Lab-12 |
| T1021.002 | Remote Services | SMB/Admin Shares | Phase-01 | Lab-02 |
| T1021.003 | Remote Services | DCOM | Phase-03 | Lab-09 |
| T1021.006 | Remote Services | WinRM | Phase-01 | Lab-01 |
| T1027 | Obfuscated Files or Information | — | Phase-03 | Lab-07 |
| T1039 | Data from Network Shared Drive | — | Phase-04 | Lab-10 |
| T1041 | Exfiltration Over C2 Channel | — | Phase-04 | Lab-10 |
| T1046 | Network Service Discovery | — | Phase-01 | Lab-01 |
| T1055 | Process Injection | — | Phase-03 | Lab-07 |
| T1059.001 | Command and Scripting Interpreter | PowerShell | Phase-03 | Lab-07 |
| T1069.002 | Permission Groups Discovery | Domain Groups | Phase-02 | Lab-04 |
| T1071.001 | Application Layer Protocol | Web Protocols | Phase-03 | Lab-07 |
| T1071.004 | Application Layer Protocol | DNS | Phase-03 | Lab-07 |
| T1078.002 | Valid Accounts | Domain Accounts | Phase-01 | Lab-01 |
| T1087.002 | Account Discovery | Domain Account | Phase-01 | Lab-01 |
| T1098 | Account Manipulation | — | Phase-02 | Lab-04 |
| T1110.002 | Brute Force | Password Cracking | Phase-01 | Lab-01 |
| T1112 | Modify Registry | — | Phase-03 | Lab-07 |
| T1134.001 | Access Token Manipulation | Token Impersonation | Phase-01 | Lab-01 |
| T1210 | Exploitation of Remote Services | — | Phase-01/04 | Lab-02, Lab-10 |
| T1482 | Domain Trust Discovery | — | Phase-01 | Lab-01 |
| T1484.001 | Domain Policy Modification | Group Policy Modification | Phase-03 | Lab-08 |
| T1484.002 | Domain Policy Modification | Domain Trust Modification | Phase-04 | Lab-12 |
| T1543.003 | Create or Modify System Process | Windows Service | Phase-03 | Lab-09 |
| T1548.002 | Abuse Elevation Control | Bypass UAC | Phase-04 | Lab-12 |
| T1550.002 | Use Alternate Auth Material | Pass the Hash | Phase-02 | Lab-04 |
| T1550.003 | Use Alternate Auth Material | Pass the Ticket | Phase-02 | Lab-04 |
| T1552.001 | Unsecured Credentials | Credentials in Files | Phase-02 | Lab-05, Lab-06 |
| T1552.002 | Unsecured Credentials | Credentials in Registry | Phase-02 | Lab-06 |
| T1558.001 | Steal/Forge Kerberos Tickets | Golden Ticket | Phase-02 | Lab-04 |
| T1558.002 | Steal/Forge Kerberos Tickets | Silver Ticket | Phase-02 | Lab-04 |
| T1558.003 | Steal/Forge Kerberos Tickets | Kerberoasting | Phase-01/04 | Lab-01, Lab-11 |
| T1558.004 | Steal/Forge Kerberos Tickets | AS-REP Roasting | Phase-01 | Lab-01 |
| T1562.001 | Impair Defenses | Disable/Modify Tools | Phase-03 | Lab-07 |
| T1569.002 | System Services | Service Execution | Phase-03 | Lab-07 |
| T1572 | Protocol Tunneling | — | Phase-01 | Lab-02 |
| T1573.002 | Encrypted Channel | Asymmetric Cryptography | Phase-03 | Lab-07 |
| T1574.009 | Hijack Execution Flow | Unquoted Service Path | Phase-01 | Lab-01, Lab-03 |
| T1580 | Cloud Infrastructure Discovery | — | Phase-02 | Lab-05 |

---

## 🔗 Referencias

- [MITRE ATT&CK Enterprise Matrix](https://attack.mitre.org/matrices/enterprise/)
- [APT29 Group Profile](https://attack.mitre.org/groups/G0016/)
- [MITRE D3FEND — Contramedidas](https://d3fend.mitre.org/)
- [Atomic Red Team — Tests por técnica](https://github.com/redcanaryco/atomic-red-team)

---

*Última actualización: Mayo 2026 — Adrián Camacho*