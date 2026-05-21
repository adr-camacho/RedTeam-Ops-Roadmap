# Lessons Learned — Operación SILENT BRIDGE
## Lab-02: Silent Bridge — APT41 Emulation
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 13-15/05/2026

---

## Lecciones por categoría

| # | Lección | Categoría |
|---|---------|-----------|
| 1 | Ubuntu 26.04 incompatible con Webmin 1.890 — usar Ubuntu 22.04 LTS para labs con software legacy | Infraestructura |
| 2 | `50-cloud-init.yaml` sobreescribe netplan — eliminarlo siempre + añadir `dhcp4: false` | Infraestructura |
| 3 | Interfaces tuntap de Ligolo-ng no persisten entre reinicios — recrear al arrancar el lab | Pivoting |
| 4 | Verificar `tunnel_list` antes de operar — el túnel puede caerse sin aviso | Pivoting |
| 5 | Ligolo-ng v0.7.5 usa `session` con selección interactiva — distinto a versiones anteriores | Pivoting |
| 6 | Beacon Sliver en red interna necesita relay — `listener_add` en Ligolo-ng en PROD | C2 |
| 7 | CVE-2019-15107 bloqueado por `MINISERV_INTERNAL` — pivotar a CVE-2019-12840 | Explotación |
| 8 | Metasploit inoperativo — reconstruir exploit desde análisis del módulo Ruby de ExploitDB | Explotación |
| 9 | WinRM en Windows 11 con red Pública requiere `winrm quickconfig -force` | Acceso remoto |
| 10 | Tamper Protection solo se desactiva desde GUI — no remotamente via PowerShell | Evasión |
| 11 | `reg save HKLM\SAM` más silencioso que LSASS dump — no genera alertas de Mimikatz | Credential Access |
| 12 | Git history preserva credenciales aunque se limpien en commits posteriores | Credential Discovery |
| 13 | ICMP no funciona en túnel Ligolo-ng — usar `nmap --unprivileged` para host discovery | Reconocimiento |
| 14 | Nombrar beacons en `C:\Users\<user>\Documents\` es detectable — usar rutas más discretas | OPSEC |

---

## Problemas encontrados y soluciones

| Fecha | Problema | Causa | Solución |
|-------|---------|-------|---------|
| 13/05/2026 | Ubuntu 26.04 incompatible con Webmin 1.890 | perlapi-5.38.2 vs perl 5.40 instalado | Reinstalar PROD con Ubuntu 22.04 LTS |
| 14/05/2026 | `50-cloud-init.yaml` sobreescribe IPs estáticas | Cloud-init fuerza DHCP con prioridad numérica mayor | Eliminar `50-cloud-init.yaml` + `dhcp4: false` |
| 14/05/2026 | CVE-2019-15107 bloqueado | `MINISERV_INTERNAL` check línea 8 del CGI | Pivotar a CVE-2019-12840 autenticado |
| 14/05/2026 | Metasploit `uninitialized constant HTTP` | Bug namespace Ruby sin actualizar | Exploit Python construido desde `46984.rb` |
| 14/05/2026 | Ligolo-ng interfaz `linkdown` | Sesión caída sin limpiar interfaz | `ip link delete ligolo` + reinicio proxy |
| 15/05/2026 | Evil-WinRM timeout en PC-01 | Perfil de red Público bloquea WinRM | `winrm quickconfig -force` en PC-01 |
| 15/05/2026 | Beacon Sliver v1 no conecta | PC-01 sin visibilidad hacia Kali (10.0.2.x) | `listener_add` Ligolo-ng + beacon v2 → PROD |
| 15/05/2026 | Tamper Protection bloquea `Set-MpPreference` | Windows 11 protege Defender remotamente | Desactivar Tamper Protection desde GUI |

---

## Comparativa Lab-01 vs Lab-02

| Aspecto | Lab-01 (APT29 — AD) | Lab-02 (APT41 — Silent Bridge) |
|---------|--------------------|-----------------------|
| **Vector inicial** | Kerberos sin autenticación | Web RCE (CVE-2019-12840) |
| **Weaponización** | Herramientas estándar (Impacket) | Exploit Python construido manualmente |
| **Topología** | Red plana (un segmento) | Red segmentada (tres nodos, dos segmentos) |
| **Pivoting** | No necesario | Ligolo-ng TLS tunnel |
| **Credenciales** | AS-REP Roasting / Kerberoasting | Git history |
| **C2** | Sliver directo en WKSTN-01 | Sliver via relay (Ligolo listener en PROD) |
| **Credential dump** | DCSync (dominio completo) | SAM/SYSTEM (local) |
| **Adversario** | APT29 (SVR Rusia) | APT41 (MSS China) |

---

## Conceptos técnicos consolidados

**Ligolo-ng vs Chisel:** Ligolo-ng opera a nivel de kernel (tuntap) — tráfico transparente para cualquier herramienta sin proxychains. Chisel requiere proxychains y limita Nmap a connect scan.

**Relay C2 con Ligolo-ng listener:** `listener_add --addr 0.0.0.0:443 --to 10.0.2.9:443` en PROD reenvía el tráfico del beacon hacia Kali. Arquitectura multicapa característica de operaciones APT reales en redes segmentadas.

**reg save vs LSASS dump:** `reg save HKLM\SAM + SYSTEM` usa la shadow copy del registro — más silencioso que acceder a LSASS. Solo requiere `reg.exe` (LOLBin) + `impacket-secretsdump` offline.

**Git history como vector:** Un commit que "limpia" credenciales no las elimina del historial. `git show <commit>` las recupera siempre. Solución real: rotar credenciales + `git filter-repo`.

---

## Pendiente para labs futuros

| Tema | Lab objetivo |
|------|-------------|
| AMSI bypass en memoria sin GUI | Lab-07 (Lazarus) |
| Process injection + syscalls directas | Lab-07 (Lazarus) |
| Beacon con evasión de PE header | Lab-07 (Lazarus) |
| Segundo pivote (tres segmentos) | Lab-09 (Holo) |

---

*Operación SILENT BRIDGE completada — Adrián Camacho | Mayo 2026*