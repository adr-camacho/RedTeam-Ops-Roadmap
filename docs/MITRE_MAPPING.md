# 🎯 MITRE ATT&CK Mapping — Red Team Ops Roadmap

> Mapeo de todas las técnicas utilizadas en el roadmap contra el framework MITRE ATT&CK.  
> Este roadmap emula **múltiples perfiles APT** — cada fase replica el comportamiento de un actor de amenaza distinto para cubrir el espectro completo de TTPs requerido para Red Team profesional.  
> Framework: MITRE ATT&CK v14 — Enterprise

---

## 🕵️ Perfiles de Adversario por Fase

| Fase | Labs | Adversario | Origen | Motivación | TTPs características |
|------|------|-----------|--------|------------|---------------------|
| **Phase-01** | Lab-01 | APT29 / Cozy Bear | Rusia (SVR) | Espionaje, persistencia | Kerberos abuse, LOLBins, C2 encubierto |
| **Phase-01** | Lab-02 | APT41 / Double Dragon | China (MSS) | Espionaje + económica | Web RCE, pivotaje agresivo, implantes multicapa |
| **Phase-01** | Lab-03 | APT29 / Cozy Bear | Rusia (SVR) | Espionaje, persistencia | ADCS Abuse, certificate persistence, NTLM relay |
| **Phase-02** | Labs 04-06 | APT28 / Fancy Bear | Rusia (GRU) | Espionaje, sabotaje | ACL Abuse, DCSync, Delegation, GPO Abuse |
| **Phase-03** | Labs 07-09 | Lazarus Group | Corea del Norte (RGB) | Espionaje + financiera | EDR Evasion, AMSI Bypass, C2 avanzado |
| **Phase-04** | Labs 10-12 | APT10 / Stone Panda | China (MSS) | Espionaje, supply chain | Forest Trusts, exfiltración masiva, Pro Labs |

> **Referencia:** [MITRE ATT&CK Groups](https://attack.mitre.org/groups/)

---

### Justificación de la selección de adversarios

| Adversario | Por qué en este lab |
|-----------|---------------------|
| **APT29** (Lab-01, Lab-03) | Maestría en Kerberos abuse, ADCS y Living-off-the-Land — el perfil canónico para entornos AD |
| **APT41** (Lab-02) | Especialización en explotación web + pivotaje de red — encaja con el vector Webmin y Ligolo-ng |
| **APT28** (Lab-04/05/06) | ACL Abuse, DCSync, Delegation y GPO Abuse son TTPs documentadas en campañas de Fancy Bear |
| **Lazarus** (Lab-07/08/09) | Grupo de referencia para evasión de EDR, obfuscación y C2 avanzado |
| **APT10** (Lab-10/11/12) | Campañas de supply chain y compromiso de infraestructuras complejas con Forest Trusts |

---

## 📊 Matriz de Técnicas por Fase

---

### 🟢 Phase-01 — Fundamentos y Pivotaje (Labs 01-03)

#### Lab-01 — Ghost Forest | Adversario: APT29 (Cozy Bear)

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
| Discovery | Permission Groups Discovery | Domain Groups | T1069.002 | net group / BloodHound | ✅ |
| Discovery | Domain Trust Discovery | — | T1482 | nltest / BloodHound | ✅ |
| Credential Access | Unsecured Credentials | Credentials in Files | T1552.001 | dir, type | ✅ |
| Lateral Movement | Use Alternate Auth Material | Pass the Hash | T1550.002 | Impacket | ✅ |
| Lateral Movement | Remote Services | Windows Remote Management | T1021.006 | Evil-WinRM | ✅ |
| Command & Control | Application Layer Protocol | Web Protocols | T1071.001 | Sliver HTTPS | ✅ |
| Command & Control | Encrypted Channel | Asymmetric Cryptography | T1573.002 | Sliver mTLS | ✅ |
| Command & Control | Develop Capabilities | Malware | T1587.001 | Sliver generate | ✅ |
| Credential Access | OS Credential Dumping | DCSync | T1003.006 | Impacket secretsdump | ✅ |
| Persistence | Steal/Forge Kerberos Tickets | Golden Ticket | T1558.001 | Impacket ticketer | 🔄 |
| Privilege Escalation | Access Token Manipulation | Token Impersonation | T1134.001 | PrintSpoofer | 🔄 |

---

#### Lab-02 — Silent Bridge | Adversario: APT41 (Double Dragon)

| Táctica | Técnica | Sub-técnica | ID | Herramienta | Estado |
|---------|---------|-------------|-----|-------------|--------|
| Reconnaissance | Network Service Discovery | — | T1046 | Nmap | ✅ |
| Reconnaissance | Gather Victim Host Info | Software | T1592.002 | curl / whatweb | ✅ |
| Reconnaissance | Search Open Technical Databases | — | T1596 | searchsploit / exploitdb | ✅ |
| Initial Access | Exploit Public-Facing Application | — | T1190 | CVE-2019-12840 Webmin | ✅ |
| Execution | Command and Scripting Interpreter | Unix Shell | T1059.004 | Bash reverse shell | ✅ |
| Discovery | System Network Configuration | — | T1016 | ip addr, ip route | ✅ |
| Discovery | System Information Discovery | — | T1082 | id, uname, hostname | ✅ |
| Command & Control | Protocol Tunneling | — | T1572 | Ligolo-ng (proxy+agent) | ✅ |
| Command & Control | Proxy | — | T1090 | Ligolo-ng (routing) | ✅ |
| Command & Control | Ingress Tool Transfer | — | T1105 | scp (agent a PROD) | ✅ |
| Discovery | Network Service Discovery | — | T1046 | Nmap (vía túnel) | ✅ |
| Credential Access | Unsecured Credentials | Credentials in Files | T1552.001 | Git history | ✅ |
| Lateral Movement | Remote Services | Windows Remote Management | T1021.006 | Evil-WinRM | ✅ |
| Lateral Movement | Remote Services | SMB/Windows Admin Shares | T1021.002 | CrackMapExec | ❌ |
| Command & Control | Application Layer Protocol | Web Protocols | T1071.001 | Sliver HTTPS | ✅ |
| Command & Control | Encrypted Channel | Asymmetric Cryptography | T1573.002 | Sliver mTLS | ✅ |
| Command & Control | Develop Capabilities | Malware | T1587.001 | Sliver generate (Windows) | ✅ |
| Execution | User Execution | Malicious File | T1204.002 | Start-Process -Hidden | ✅ |
| Persistence | Scheduled Task/Job | Scheduled Task | T1053.005 | schtasks | ✅ |
| Persistence | Boot or Logon Autostart | Registry Run Keys | T1547.001 | reg add | ✅ |
| Credential Access | OS Credential Dumping | Security Account Manager | T1003.002 | reg save + impacket-secretsdump | ✅ |
| Collection | Data from Network Shared Drive | — | T1039 | Evil-WinRM download | ✅ |

---

#### Lab-03 — ADCS Abuse | Adversario: APT29 (Cozy Bear)

| Táctica | Técnica | Sub-técnica | ID | Herramienta | Estado |
|---------|---------|-------------|-----|-------------|--------|
| Discovery | Network Service Discovery | — | T1046 | Certipy find | ✅ |
| Credential Access | Steal or Forge Auth Certificates | ESC1 — SAN Abuse | T1649 | Certipy req | ✅ |
| Privilege Escalation | File and Dir Permissions Modification | — | T1222 | Certipy template | ✅ |
| Credential Access | Steal or Forge Auth Certificates | ESC4 — Template Write | T1649 | Certipy template + req | ✅ |
| Credential Access | Adversary-in-the-Middle | NTLM Relay (ESC8) | T1557.001 | ntlmrelayx + PetitPotam | ✅ |
| Credential Access | Forced Authentication | — | T1187 | PetitPotam | ✅ |
| Lateral Movement | Use Alternate Auth Material | Pass the Hash | T1550.002 | Evil-WinRM | ✅ |
| Lateral Movement | Remote Services | Windows Remote Management | T1021.006 | Evil-WinRM | ✅ |
| Defense Evasion | Impair Defenses | Disable/Modify Tools | T1562.001 | Set-MpPreference | ✅ |
| Command & Control | Ingress Tool Transfer | — | T1105 | Evil-WinRM upload | ✅ |
| Command & Control | Develop Capabilities | Malware | T1587.001 | Sliver generate | ✅ |
| Execution | User Execution | Malicious File | T1204.002 | Start-Process -Hidden | ✅ |
| Command & Control | Application Layer Protocol | Web Protocols | T1071.001 | Sliver HTTPS | ✅ |
| Command & Control | Encrypted Channel | Asymmetric Cryptography | T1573.002 | Sliver mTLS | ✅ |
| Persistence | Steal or Forge Auth Certificates | Certificate Persistence | T1649 | administrador.pfx | ✅ |

> **Nota ESC8:** Relay SMB→HTTP identificado y confirmado (PetitPotam exitoso). Bloqueado por KB5005413 en WS2022. Documentado como comportamiento real en entornos modernos.

---

### 🟡 Phase-02 — AD Avanzado (Labs 04-06) | Adversario: APT28 (Fancy Bear)

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta | Estado |
|---------|---------|-------------|-----|-----|-------------|--------|
| Credential Access | OS Credential Dumping | LSASS Memory | T1003.001 | Lab-04 | Mimikatz | ⏳ |
| Credential Access | OS Credential Dumping | DCSync | T1003.006 | Lab-04 | secretsdump | ⏳ |
| Persistence | Account Manipulation | — | T1098 | Lab-04 | PowerView | ⏳ |
| Lateral Movement | Use Alternate Auth Material | Pass the Hash | T1550.002 | Lab-04 | CrackMapExec | ⏳ |
| Credential Access | Steal/Forge Kerberos Tickets | Golden Ticket | T1558.001 | Lab-04 | ticketer | ⏳ |
| Privilege Escalation | Domain Policy Modification | Group Policy | T1484.001 | Lab-04/06 | — | ⏳ |
| Credential Access | Steal/Forge Kerberos Tickets | Unconstrained Delegation | T1558.001 | Lab-05 | Rubeus | ⏳ |
| Credential Access | Steal/Forge Kerberos Tickets | Constrained Delegation | T1558.001 | Lab-05 | Rubeus S4U | ⏳ |
| Privilege Escalation | Domain Policy Modification | Domain Trust Modification | T1484.002 | Lab-06 | — | ⏳ |

---

### 🔴 Phase-03 — Red Team & Evasión (Labs 07-09) | Adversario: Lazarus Group

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta | Estado |
|---------|---------|-------------|-----|-----|-------------|--------|
| Defense Evasion | Impair Defenses | Disable/Modify Tools | T1562.001 | Lab-07 | AMSI Bypass | ⏳ |
| Defense Evasion | Obfuscated Files | — | T1027 | Lab-07 | Invoke-Obfuscation | ⏳ |
| Defense Evasion | Process Injection | — | T1055 | Lab-07 | Donut / Sliver | ⏳ |
| Execution | Command and Scripting Interpreter | PowerShell | T1059.001 | Lab-07 | — | ⏳ |
| Command & Control | Application Layer Protocol | Web Protocols | T1071.001 | Lab-08 | Havoc C2 | ⏳ |
| Command & Control | Encrypted Channel | Asymmetric Cryptography | T1573.002 | Lab-08 | Havoc mTLS | ⏳ |
| Lateral Movement | Remote Services | DCOM | T1021.003 | Lab-09 | — | ⏳ |
| Persistence | Create or Modify System Process | Windows Service | T1543.003 | Lab-09 | — | ⏳ |

---

### 🏴 Phase-04 — Simulación Real (Labs 10-12) | Adversario: APT10 (Stone Panda)

| Táctica | Técnica | Sub-técnica | ID | Lab | Herramienta | Estado |
|---------|---------|-------------|-----|-----|-------------|--------|
| Lateral Movement | Exploitation of Remote Services | — | T1210 | Lab-10 | Metasploit | ⏳ |
| Collection | Data from Network Shared Drive | — | T1039 | Lab-10 | — | ⏳ |
| Exfiltration | Exfiltration Over C2 Channel | — | T1041 | Lab-10 | Sliver | ⏳ |
| Credential Access | Steal/Forge Kerberos Tickets | Kerberoasting | T1558.003 | Lab-11 | Rubeus | ⏳ |
| Credential Access | OS Credential Dumping | DCSync | T1003.006 | Lab-11/12 | secretsdump | ⏳ |
| Privilege Escalation | Domain Policy Modification | Domain Trust Modification | T1484.002 | Lab-12 | — | ⏳ |

---

## 📈 Estadísticas del Roadmap

| Métrica | Valor |
|---------|-------|
| **Total de técnicas únicas** | 49 |
| **Sub-técnicas mapeadas** | 29 |
| **Tácticas MITRE cubiertas** | 11 / 14 |
| **Adversarios emulados** | 5 (APT29, APT41, APT28, Lazarus, APT10) |
| **Labs completados** | 3 / 12 |
| **Técnicas ejecutadas** | 36 / 49 |

### Tácticas cubiertas

| Táctica | ID | Labs | Estado |
|---------|-----|------|--------|
| Reconnaissance | TA0043 | Lab-01, Lab-02, Lab-03 | ✅ |
| Initial Access | TA0001 | Lab-02 | ✅ |
| Execution | TA0002 | Lab-01, Lab-02, Lab-03 | ✅ |
| Persistence | TA0003 | Lab-01, Lab-02, Lab-03 | ✅ |
| Privilege Escalation | TA0004 | Lab-03, Lab-04+ | ✅ Iniciado |
| Defense Evasion | TA0005 | Lab-03, Lab-07+ | ✅ Iniciado |
| Credential Access | TA0006 | Lab-01, Lab-02, Lab-03 | ✅ |
| Discovery | TA0007 | Lab-01, Lab-02, Lab-03 | ✅ |
| Lateral Movement | TA0008 | Lab-01, Lab-02, Lab-03 | ✅ |
| Collection | TA0009 | Lab-02, Lab-10 | ✅ Iniciado |
| Command & Control | TA0011 | Lab-01, Lab-02, Lab-03 | ✅ |
| Exfiltration | TA0010 | Lab-10 | ⏳ |

> Tácticas no cubiertas intencionalmente: **TA0042** (Resource Development) y **TA0040** (Impact) — fuera del scope Red Team / CRTO.

---

## 🔗 Referencias

- [MITRE ATT&CK Enterprise Matrix](https://attack.mitre.org/matrices/enterprise/)
- [APT29 — G0016](https://attack.mitre.org/groups/G0016/)
- [APT41 — G0096](https://attack.mitre.org/groups/G0096/)
- [APT28 — G0007](https://attack.mitre.org/groups/G0007/)
- [Lazarus Group — G0032](https://attack.mitre.org/groups/G0032/)
- [APT10 — G0045](https://attack.mitre.org/groups/G0045/)
- [MITRE D3FEND — Contramedidas](https://d3fend.mitre.org/)
- [Atomic Red Team — Tests por técnica](https://github.com/redcanaryco/atomic-red-team)

---

*Última actualización: Mayo 2026 — Lab-03 DARK GATE (APT29 ADCS) añadido — Adrián Camacho*