# 🎯 MITRE ATT&CK Mapping — Red Team Ops Roadmap

> Mapeo de todas las técnicas utilizadas en el roadmap contra el framework MITRE ATT&CK.  
> Este roadmap emula **múltiples perfiles APT** — cada fase replica el comportamiento de un actor de amenaza distinto para cubrir el espectro completo de TTPs requerido por el CRTO.  
> Framework: MITRE ATT&CK v14 — Enterprise

---

## 🕵️ Perfiles de Adversario por Fase

| Fase | Labs | Adversario | Origen | Motivación | TTPs características |
|------|------|-----------|--------|------------|---------------------|
| **Phase 01** | Lab-01 | APT29 / Cozy Bear | Rusia (SVR) | Espionaje, persistencia | Kerberos abuse, LOLBins, C2 encubierto |
| **Phase 01** | Lab-02 | APT41 / Double Dragon | China (MSS) | Espionaje + económica | Web RCE, pivotaje agresivo, implantes multicapa |
| **Phase 01** | Lab-03 | FIN7 / Carbanak | Rusia (crimen org.) | Financiera | Explotación de servicios, BOf, persistencia |
| **Phase 02** | Labs 04-06 | APT28 / Fancy Bear | Rusia (GRU) | Espionaje, sabotaje | ACL Abuse, DCSync, Pass-the-Hash, Azure AD |
| **Phase 03** | Labs 07-09 | Lazarus Group | Corea del Norte (RGB) | Espionaje + financiera | EDR Evasion, AMSI Bypass, C2 avanzado |
| **Phase 04** | Labs 10-12 | APT10 / Stone Panda | China (MSS) | Espionaje, supply chain | Forest Trusts, exfiltración masiva, Pro Labs |

> **Referencia:** [MITRE ATT&CK Groups](https://attack.mitre.org/groups/)

---

### Justificación de la selección de adversarios

| Adversario | Por qué en este lab |
|-----------|---------------------|
| **APT29** (Lab-01) | Maestría en Kerberos abuse y Living-off-the-Land — el perfil canónico para entornos AD |
| **APT41** (Lab-02) | Especialización en explotación web + pivotaje de red — encaja con el vector Webmin y Ligolo-ng |
| **FIN7** (Lab-03) | Histórico de explotación de servicios con buffer overflows y técnicas de post-explotación financiera |
| **APT28** (Lab-04/05/06) | ACL Abuse, DCSync y Azure AD son TTPs documentadas en las campañas de Fancy Bear |
| **Lazarus** (Lab-07/08/09) | Grupo de referencia para evasión de EDR, obfuscación y C2 avanzado |
| **APT10** (Lab-10/11/12) | Campañas de supply chain y compromiso de infraestructuras complejas con Forest Trusts |

---

## 📊 Matriz de Técnicas por Fase

---

### 🟢 Phase 01 — Fundamentos y Pivotaje (Labs 01-03)

#### Lab-01 — Attacktive Directory | Adversario: APT29 (Cozy Bear)

| Táctica | Técnica | Sub-técnica | ID | Herramienta | Estado |
|---------|---------|-------------|-----|-------------|--------|
| Reconnaissance | Network Service Discovery | — | T1046 | Nmap | ✅ |
| Reconnaissance | Network Share Discovery | — | T1135 | smbclient, enum4linux-ng | ✅ |
| Reconnaissance | Account Discovery | Domain Account | T1087.002 | ldapsearch | ✅ |
| Credential Access | Steal/Forge Kerberos Tickets | AS-REP Roasting | T1558.004 | Impacket GetNPUsers | ✅ |
| Credential Access | Brute Force | Password Cracking | T1110.002 | John / Hashcat | ✅ |
| Credential Access | Steal/Forge Kerberos Tickets | Kerberoasting | T1558.003 | Impacket GetUserSPNs | ✅ |
| Execution | Remote Services | Windows Remote Management | T1021.006 | Evil-WinRM | ✅ |
| Execution | Valid Accounts | Domain Accounts | T1078.002 | CrackMapExec | ✅ |
| Discovery | System Information Discovery | — | T1082 | systeminfo, hostname | ✅ |
| Discovery | Account Discovery | Domain Account | T1087.002 | net user /domain | ✅ |
| Discovery | Permission Groups Discovery | Domain Groups | T1069.002 | net group / BloodHound | ✅ |
| Discovery | Domain Trust Discovery | — | T1482 | nltest / BloodHound | ✅ |
| Credential Access | Unsecured Credentials | Credentials in Files | T1552.001 | dir, type | ✅ |
| Credential Access | Unsecured Credentials | Credentials in Registry | T1552.002 | reg query | ✅ |
| Lateral Movement | Use Alternate Auth Material | Pass the Ticket | T1550.003 | Rubeus / Impacket | ✅ |
| Lateral Movement | Remote Services | Windows Remote Management | T1021.006 | Evil-WinRM | ✅ |
| Command & Control | Application Layer Protocol | Web Protocols | T1071.001 | Sliver HTTPS | ✅ |
| Command & Control | Encrypted Channel | Asymmetric Cryptography | T1573.002 | Sliver mTLS | ✅ |
| Command & Control | Develop Capabilities | Malware | T1587.001 | Sliver generate | ✅ |
| Privilege Escalation | Access Token Manipulation | Token Impersonation | T1134.001 | PrintSpoofer / GodPotato | ⏳ |
| Privilege Escalation | Hijack Execution Flow | Unquoted Service Path | T1574.009 | sc query / icacls | ⏳ |
| Privilege Escalation | Abuse Elevation Control | AlwaysInstallElevated | T1548.002 | msiexec | ⏳ |
| Credential Access | OS Credential Dumping | DCSync | T1003.006 | Impacket secretsdump | ⏳ |
| Persistence | Steal/Forge Kerberos Tickets | Golden Ticket | T1558.001 | Impacket ticketer | ⏳ |
| Credential Access | OS Credential Dumping | DCSync | T1003.006 | secretsdump | ⏳ |

---

#### Lab-02 — Wreath | Adversario: APT41 (Double Dragon)

| Táctica | Técnica | Sub-técnica | ID | Herramienta | Estado |
|---------|---------|-------------|-----|-------------|--------|
| Reconnaissance | Network Service Discovery | — | T1046 | Nmap | ⏳ |
| Reconnaissance | Gather Victim Host Info | Software | T1592.002 | curl / whatweb | ⏳ |
| Reconnaissance | Search Open Technical Databases | — | T1596 | searchsploit / exploitdb | ⏳ |
| Initial Access | Exploit Public-Facing Application | — | T1190 | CVE-2019-15107 Webmin | ⏳ |
| Execution | Command and Scripting Interpreter | Unix Shell | T1059.004 | Bash reverse shell | ⏳ |
| Discovery | System Network Configuration | — | T1016 | ip addr, ip route | ⏳ |
| Discovery | System Information Discovery | — | T1082 | id, uname, hostname | ⏳ |
| Command & Control | Protocol Tunneling | — | T1572 | Ligolo-ng (proxy+agent) | ⏳ |
| Command & Control | Proxy | — | T1090 | Ligolo-ng (routing) | ⏳ |
| Command & Control | Ingress Tool Transfer | — | T1105 | wget / curl (agent a PROD) | ⏳ |
| Discovery | Network Service Discovery | — | T1046 | Nmap (vía túnel) | ⏳ |
| Discovery | Network Share Discovery | — | T1135 | smbclient / CrackMapExec | ⏳ |
| Credential Access | Unsecured Credentials | Credentials in Files | T1552.001 | Git repos / Gitea | ⏳ |
| Lateral Movement | Remote Services | Windows Remote Management | T1021.006 | Evil-WinRM | ⏳ |
| Lateral Movement | Remote Services | SMB/Windows Admin Shares | T1021.002 | CrackMapExec | ⏳ |
| Command & Control | Application Layer Protocol | Web Protocols | T1071.001 | Sliver HTTPS | ⏳ |
| Command & Control | Encrypted Channel | Asymmetric Cryptography | T1573.002 | Sliver mTLS | ⏳ |
| Command & Control | Develop Capabilities | Malware | T1587.001 | Sliver generate (Windows) | ⏳ |
| Execution | User Execution | Malicious File | T1204.002 | Start-Process -Hidden | ⏳ |
| Persistence | Scheduled Task/Job | Scheduled Task | T1053.005 | schtasks | ⏳ |
| Persistence | Boot or Logon Autostart | Registry Run Keys | T1547.001 | reg add | ⏳ |
| Credential Access | OS Credential Dumping | LSASS Memory | T1003.001 | Mimikatz / Sliver hashdump | ⏳ |
| Collection | Data from Network Shared Drive | — | T1039 | SMB / Evil-WinRM download | ⏳ |

---

#### Lab-03 — Gatekeeper | Adversario: FIN7 (Carbanak)

| Táctica | Técnica | Sub-técnica | ID | Herramienta | Estado |
|---------|---------|-------------|-----|-------------|--------|
| Reconnaissance | Network Service Discovery | — | T1046 | Nmap | ⏳ |
| Initial Access | Exploit Public-Facing Application | — | T1190 | Buffer Overflow manual | ⏳ |
| Execution | Exploitation for Client Execution | — | T1203 | Buffer Overflow (EIP control) | ⏳ |
| Privilege Escalation | Hijack Execution Flow | Unquoted Service Path | T1574.009 | sc query / icacls | ⏳ |
| Persistence | Create or Modify System Process | Windows Service | T1543.003 | sc create | ⏳ |
| Command & Control | Application Layer Protocol | Web Protocols | T1071.001 | Sliver / Metasploit | ⏳ |

---

### 🟡 Phase 02 — Post-Explotación y Abuso de AD (Labs 04-06) | Adversario: APT28 (Fancy Bear)

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta | Estado |
|---------|---------|-------------|-----|-----|-------------|--------|
| Credential Access | OS Credential Dumping | LSASS Memory | T1003.001 | Lab-04 | Mimikatz / CrackMapExec | ⏳ |
| Credential Access | OS Credential Dumping | DCSync | T1003.006 | Lab-04 | Impacket secretsdump | ⏳ |
| Persistence | Account Manipulation | — | T1098 | Lab-04 | PowerView | ⏳ |
| Lateral Movement | Use Alternate Auth Material | Pass the Hash | T1550.002 | Lab-04 | CrackMapExec / Impacket | ⏳ |
| Lateral Movement | Use Alternate Auth Material | Pass the Ticket | T1550.003 | Lab-04 | Rubeus / Impacket | ⏳ |
| Credential Access | Steal/Forge Kerberos Tickets | Golden Ticket | T1558.001 | Lab-04 | Mimikatz / ticketer | ⏳ |
| Credential Access | Steal/Forge Kerberos Tickets | Silver Ticket | T1558.002 | Lab-04 | Mimikatz / ticketer | ⏳ |
| Privilege Escalation | Domain Policy Modification | Group Policy Modification | T1484.001 | Lab-04 | — | ⏳ |
| Discovery | Permission Groups Discovery | Domain Groups | T1069.002 | Lab-04 | BloodHound / PowerView | ⏳ |
| Discovery | Cloud Infrastructure Discovery | — | T1580 | Lab-05 | AzureHound | ⏳ |
| Credential Access | Unsecured Credentials | Credentials in Files | T1552.001 | Lab-05/06 | — | ⏳ |
| Credential Access | Unsecured Credentials | Credentials in Registry | T1552.002 | Lab-06 | reg query | ⏳ |

---

### 🔴 Phase 03 — Red Team & Evasión de Defensas (Labs 07-09) | Adversario: Lazarus Group

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta | Estado |
|---------|---------|-------------|-----|-----|-------------|--------|
| Defense Evasion | Impair Defenses | Disable or Modify Tools | T1562.001 | Lab-07 | AMSI Bypass | ⏳ |
| Defense Evasion | Obfuscated Files or Information | — | T1027 | Lab-07 | Invoke-Obfuscation | ⏳ |
| Defense Evasion | Process Injection | — | T1055 | Lab-07 | Donut / Sliver | ⏳ |
| Defense Evasion | Modify Registry | — | T1112 | Lab-07 | — | ⏳ |
| Command & Control | Application Layer Protocol | Web Protocols | T1071.001 | Lab-07 | Sliver HTTPS | ⏳ |
| Command & Control | Application Layer Protocol | DNS | T1071.004 | Lab-07 | Sliver DNS | ⏳ |
| Command & Control | Encrypted Channel | Asymmetric Cryptography | T1573.002 | Lab-07 | Sliver mTLS | ⏳ |
| Execution | Command and Scripting Interpreter | PowerShell | T1059.001 | Lab-07 | — | ⏳ |
| Execution | System Services | Service Execution | T1569.002 | Lab-07 | — | ⏳ |
| Privilege Escalation | Domain Policy Modification | Group Policy Modification | T1484.001 | Lab-08 | — | ⏳ |
| Lateral Movement | Remote Services | DCOM | T1021.003 | Lab-09 | — | ⏳ |
| Persistence | Create or Modify System Process | Windows Service | T1543.003 | Lab-09 | — | ⏳ |

---

### 🏴 Phase 04 — Simulación de Infraestructura Real (Labs 10-12) | Adversario: APT10 (Stone Panda)

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta | Estado |
|---------|---------|-------------|-----|-----|-------------|--------|
| Persistence | Account Manipulation | Additional Cloud Credentials | T1098.001 | Lab-10 | — | ⏳ |
| Lateral Movement | Exploitation of Remote Services | — | T1210 | Lab-10 | Metasploit | ⏳ |
| Collection | Data from Network Shared Drive | — | T1039 | Lab-10 | — | ⏳ |
| Exfiltration | Exfiltration Over C2 Channel | — | T1041 | Lab-10 | Sliver | ⏳ |
| Credential Access | Steal/Forge Kerberos Tickets | Kerberoasting | T1558.003 | Lab-11 | Rubeus | ⏳ |
| Defense Evasion | Valid Accounts | — | T1078 | Lab-11 | — | ⏳ |
| Credential Access | OS Credential Dumping | DCSync | T1003.006 | Lab-11/12 | secretsdump | ⏳ |
| Privilege Escalation | Domain Policy Modification | Domain Trust Modification | T1484.002 | Lab-12 | — | ⏳ |
| Privilege Escalation | Abuse Elevation Control | Bypass UAC | T1548.002 | Lab-12 | — | ⏳ |

---

## 🗂️ Índice Completo de Técnicas (ordenado por ID)

| ID | Técnica | Sub-técnica | Fase | Labs | Adversario |
|----|---------|-------------|------|------|-----------|
| T1003.001 | OS Credential Dumping | LSASS Memory | Phase-01/02 | Lab-02, Lab-04 | APT41, APT28 |
| T1003.006 | OS Credential Dumping | DCSync | Phase-01/02/04 | Lab-01, Lab-04, Lab-11, Lab-12 | APT29, APT28, APT10 |
| T1016 | System Network Configuration Discovery | — | Phase-01 | Lab-02 | APT41 |
| T1021.002 | Remote Services | SMB/Admin Shares | Phase-01 | Lab-02 | APT41 |
| T1021.003 | Remote Services | DCOM | Phase-03 | Lab-09 | Lazarus |
| T1021.006 | Remote Services | WinRM | Phase-01 | Lab-01, Lab-02 | APT29, APT41 |
| T1027 | Obfuscated Files or Information | — | Phase-03 | Lab-07 | Lazarus |
| T1039 | Data from Network Shared Drive | — | Phase-01/04 | Lab-02, Lab-10 | APT41, APT10 |
| T1041 | Exfiltration Over C2 Channel | — | Phase-04 | Lab-10 | APT10 |
| T1046 | Network Service Discovery | — | Phase-01 | Lab-01, Lab-02 | APT29, APT41 |
| T1053.005 | Scheduled Task/Job | Scheduled Task | Phase-01 | Lab-02 | APT41 |
| T1055 | Process Injection | — | Phase-03 | Lab-07 | Lazarus |
| T1059.001 | Command and Scripting Interpreter | PowerShell | Phase-03 | Lab-07 | Lazarus |
| T1059.004 | Command and Scripting Interpreter | Unix Shell | Phase-01 | Lab-02 | APT41 |
| T1069.002 | Permission Groups Discovery | Domain Groups | Phase-01/02 | Lab-01, Lab-04 | APT29, APT28 |
| T1071.001 | Application Layer Protocol | Web Protocols | Phase-01/03 | Lab-01, Lab-02, Lab-07 | APT29, APT41, Lazarus |
| T1071.004 | Application Layer Protocol | DNS | Phase-03 | Lab-07 | Lazarus |
| T1078.002 | Valid Accounts | Domain Accounts | Phase-01 | Lab-01 | APT29 |
| T1082 | System Information Discovery | — | Phase-01 | Lab-01, Lab-02 | APT29, APT41 |
| T1087.002 | Account Discovery | Domain Account | Phase-01 | Lab-01 | APT29 |
| T1090 | Proxy | — | Phase-01 | Lab-02 | APT41 |
| T1098 | Account Manipulation | — | Phase-02 | Lab-04 | APT28 |
| T1098.001 | Account Manipulation | Additional Cloud Credentials | Phase-04 | Lab-10 | APT10 |
| T1105 | Ingress Tool Transfer | — | Phase-01 | Lab-02 | APT41 |
| T1110.002 | Brute Force | Password Cracking | Phase-01 | Lab-01 | APT29 |
| T1112 | Modify Registry | — | Phase-03 | Lab-07 | Lazarus |
| T1134.001 | Access Token Manipulation | Token Impersonation | Phase-01 | Lab-01 | APT29 |
| T1135 | Network Share Discovery | — | Phase-01 | Lab-01, Lab-02 | APT29, APT41 |
| T1190 | Exploit Public-Facing Application | — | Phase-01 | Lab-02, Lab-03 | APT41, FIN7 |
| T1203 | Exploitation for Client Execution | — | Phase-01 | Lab-03 | FIN7 |
| T1204.002 | User Execution | Malicious File | Phase-01 | Lab-02 | APT41 |
| T1210 | Exploitation of Remote Services | — | Phase-04 | Lab-10 | APT10 |
| T1482 | Domain Trust Discovery | — | Phase-01 | Lab-01 | APT29 |
| T1484.001 | Domain Policy Modification | Group Policy Modification | Phase-02/03 | Lab-04, Lab-08 | APT28, Lazarus |
| T1484.002 | Domain Policy Modification | Domain Trust Modification | Phase-04 | Lab-12 | APT10 |
| T1543.003 | Create or Modify System Process | Windows Service | Phase-01/03 | Lab-03, Lab-09 | FIN7, Lazarus |
| T1547.001 | Boot or Logon Autostart | Registry Run Keys | Phase-01 | Lab-02 | APT41 |
| T1548.002 | Abuse Elevation Control | Bypass UAC / AlwaysInstallElevated | Phase-01/04 | Lab-01, Lab-12 | APT29, APT10 |
| T1550.002 | Use Alternate Auth Material | Pass the Hash | Phase-02 | Lab-04 | APT28 |
| T1550.003 | Use Alternate Auth Material | Pass the Ticket | Phase-01/02 | Lab-01, Lab-04 | APT29, APT28 |
| T1552.001 | Unsecured Credentials | Credentials in Files | Phase-01/02 | Lab-02, Lab-05, Lab-06 | APT41, APT28 |
| T1552.002 | Unsecured Credentials | Credentials in Registry | Phase-01/02 | Lab-01, Lab-06 | APT29, APT28 |
| T1558.001 | Steal/Forge Kerberos Tickets | Golden Ticket | Phase-01/02 | Lab-01, Lab-04 | APT29, APT28 |
| T1558.002 | Steal/Forge Kerberos Tickets | Silver Ticket | Phase-02 | Lab-04 | APT28 |
| T1558.003 | Steal/Forge Kerberos Tickets | Kerberoasting | Phase-01/04 | Lab-01, Lab-11 | APT29, APT10 |
| T1558.004 | Steal/Forge Kerberos Tickets | AS-REP Roasting | Phase-01 | Lab-01 | APT29 |
| T1562.001 | Impair Defenses | Disable/Modify Tools | Phase-03 | Lab-07 | Lazarus |
| T1569.002 | System Services | Service Execution | Phase-03 | Lab-07 | Lazarus |
| T1572 | Protocol Tunneling | — | Phase-01 | Lab-02 | APT41 |
| T1573.002 | Encrypted Channel | Asymmetric Cryptography | Phase-01/03 | Lab-01, Lab-02, Lab-07 | APT29, APT41, Lazarus |
| T1574.009 | Hijack Execution Flow | Unquoted Service Path | Phase-01 | Lab-01, Lab-03 | APT29, FIN7 |
| T1580 | Cloud Infrastructure Discovery | — | Phase-02 | Lab-05 | APT28 |
| T1587.001 | Develop Capabilities | Malware | Phase-01 | Lab-01, Lab-02 | APT29, APT41 |
| T1592.002 | Gather Victim Host Info | Software | Phase-01 | Lab-02 | APT41 |
| T1596 | Search Open Technical Databases | — | Phase-01 | Lab-02 | APT41 |

---

## 📈 Estadísticas del Roadmap

| Métrica | Valor |
|---------|-------|
| **Total de técnicas únicas** | 47 |
| **Sub-técnicas mapeadas** | 28 |
| **Tácticas MITRE cubiertas** | 10 / 14 |
| **Adversarios emulados** | 6 (APT29, APT41, FIN7, APT28, Lazarus, APT10) |
| **Labs completados** | 1 / 12 |
| **Técnicas ejecutadas** | 14 / 47 |

### Tácticas cubiertas

| Táctica | ID | Labs | Estado |
|---------|-----|------|--------|
| Reconnaissance | TA0043 | Lab-01, Lab-02 | ✅ Iniciado |
| Initial Access | TA0001 | Lab-02, Lab-03 | ⏳ |
| Execution | TA0002 | Lab-01, Lab-02 | ✅ Iniciado |
| Persistence | TA0003 | Lab-01, Lab-02, Lab-03 | ⏳ |
| Privilege Escalation | TA0004 | Lab-01, Lab-03, Lab-04 | ⏳ |
| Defense Evasion | TA0005 | Lab-07, Lab-08 | ⏳ |
| Credential Access | TA0006 | Lab-01, Lab-02, Lab-04 | ✅ Iniciado |
| Discovery | TA0007 | Lab-01, Lab-02, Lab-04 | ✅ Iniciado |
| Lateral Movement | TA0008 | Lab-01, Lab-02, Lab-04 | ✅ Iniciado |
| Collection | TA0009 | Lab-02, Lab-10 | ⏳ |
| Command & Control | TA0011 | Lab-01, Lab-02, Lab-07 | ✅ Iniciado |
| Exfiltration | TA0010 | Lab-10 | ⏳ |

> Tácticas no cubiertas intencionalmente: **TA0042** (Resource Development) y **TA0040** (Impact) — fuera del scope CRTO.

---

## 🔗 Referencias

- [MITRE ATT&CK Enterprise Matrix](https://attack.mitre.org/matrices/enterprise/)
- [APT29 — G0016](https://attack.mitre.org/groups/G0016/)
- [APT41 — G0096](https://attack.mitre.org/groups/G0096/)
- [APT28 — G0007](https://attack.mitre.org/groups/G0007/)
- [Lazarus Group — G0032](https://attack.mitre.org/groups/G0032/)
- [APT10 — G0045](https://attack.mitre.org/groups/G0045/)
- [FIN7 — G0046](https://attack.mitre.org/groups/G0046/)
- [MITRE D3FEND — Contramedidas](https://d3fend.mitre.org/)
- [Atomic Red Team — Tests por técnica](https://github.com/redcanaryco/atomic-red-team)

---

*Última actualización: Mayo 2026 — Lab-02 Wreath (APT41) añadido — Adrián Camacho*