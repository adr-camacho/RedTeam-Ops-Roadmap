# 🔴 Lab-02: Wreath — Pivotaje Avanzado con Ligolo-ng

![Status](https://img.shields.io/badge/Status-In%20Progress-orange)
![Platform](https://img.shields.io/badge/Platform-Lab%20Propio%20(ref.%20THM)-red)
![Phase](https://img.shields.io/badge/Phase-01%20Fundamentals-blue)
![Adversary](https://img.shields.io/badge/Adversary-APT41%20Double%20Dragon-darkred)
![Focus](https://img.shields.io/badge/Focus-Pivoting%20%7C%20Network%20Segmentation-purple)
![MITRE](https://img.shields.io/badge/MITRE%20ATT%26CK-T1572%20%7C%20T1190%20%7C%20T1090-red)

---

## 🎯 Resumen Ejecutivo

Operación de pivotaje en red segmentada de tres nodos, emulando las TTPs de **APT41 (Double Dragon)**. Se compromete una máquina de producción Linux expuesta públicamente explotando **CVE-2019-15107** (Webmin RCE pre-auth), para desde ella establecer un **túnel TLS con Ligolo-ng** hacia la red interna segmentada, alcanzar un servidor Git con credenciales expuestas y comprometer finalmente un **PC Windows no accesible desde Internet**.

| Campo | Detalle |
|-------|---------|
| **Nombre de operación** | SILENT BRIDGE |
| **Adversario simulado** | APT41 (Double Dragon) — MSS China |
| **Vector inicial** | CVE-2019-15107 — Webmin RCE (pre-auth) |
| **Técnica de pivotaje** | Ligolo-ng — TLS tunnel + kernel tuntap interface |
| **C2 final** | Sliver beacon en PC Windows (red interna) |
| **Objetivo primario** | Compromiso del PC Windows en red interna |
| **Objetivo secundario** | Persistencia + exfiltración de datos |

---

## 🗺️ Topología de Red

```
[Kali 10.0.2.9] ──── Internet ──── [PROD Linux :10000 Webmin]
                                            │
                                     Ligolo-ng TLS
                                     (tuntap tunnel)
                                            │
                              Red Interna (.X/24)
                           ┌────────────────┴───────────────┐
                           │                                │
                    [GIT Server Linux]            [PC Windows]
                    Gitea :3000                   SMB :445
                    SSH :22                       WinRM :5985
                    [credenciales en repos]        [objetivo final]
```

---

## 🔗 Attack Path

| # | Fase | Técnica | ID MITRE | Herramienta |
|---|------|---------|----------|-------------|
| 1 | Reconnaissance | Network Service Discovery | T1046 | Nmap |
| 2 | Initial Access | Exploit Public-Facing App | T1190 | CVE-2019-15107 |
| 3 | Pivoting | Protocol Tunneling | T1572 | Ligolo-ng |
| 4 | Internal Recon | Network Service Discovery | T1046 | Nmap (vía túnel) |
| 4 | Credential Discovery | Credentials in Files | T1552.001 | Git / Gitea |
| 5 | Lateral Movement | Remote Services WinRM | T1021.006 | Evil-WinRM |
| 6 | C2 | Encrypted Channel | T1573.002 | Sliver HTTPS |
| 7 | Persistence | Scheduled Task | T1053.005 | schtasks |

---

## 🛠️ Stack Tecnológico

| Categoría | Herramienta |
|-----------|-------------|
| **Explotación** | CVE-2019-15107 (Webmin RCE) |
| **Pivotaje** | Ligolo-ng v0.7.x (proxy + agent) |
| **Acceso remoto** | Evil-WinRM |
| **C2** | Sliver (BishopFox) — beacon HTTPS |
| **Escaneo** | Nmap |
| **Validación** | CrackMapExec |
| **Enumeración web** | curl, Gobuster |

---

## 📂 Documentación

| Documento | Descripción | Estado |
|-----------|-------------|--------|
| [OPERATION_SILENT_BRIDGE.md](./OPERATION_SILENT_BRIDGE.md) | Plan completo de la operación | ✅ |
| [infrastructure_setup.md](./docs/infrastructure_setup.md) | Topología, vectores y configuración | ✅ |
| [enumeration_log.md](./docs/enumeration_log.md) | Fases 1 y 4 — recon externo e interno | ✅ |
| [exploitation.md](./docs/exploitation.md) | Fase 2 — CVE-2019-12840 Webmin RCE | ✅ |
| [pivoting.md](./docs/pivoting.md) | Fase 3 — Ligolo-ng setup y túnel | ✅ |
| [post-exploitation.md](./docs/post-exploitation.md) | Fase 5 — Lateral Movement al PC | ✅ |
| [c2_sliver.md](./docs/c2_sliver.md) | Fase 6 — Beacon en red interna | ✅ |
| [persistence.md](./docs/persistence.md) | Fase 7 — Persistencia y objetivo | ✅ |

---

## 🔵 Detección (Blue Team)

| Indicador de Compromiso | Log Source | Técnica detectada |
|------------------------|-----------|-------------------|
| POST `/password_change.cgi` con payload en campo `old` | Web access log (PROD) | T1190 — Webmin RCE |
| Creación de interfaz `tun` (`ip tuntap add`) | auditd (PROD) | T1572 — Tunneling |
| Conexión TLS saliente a puerto no estándar (11601) | Firewall / NSG | T1572 — Ligolo-ng agent |
| Proceso no firmado con socket TLS persistente | EDR Linux / auditd | T1090 — Proxy |
| `beacon.exe` ejecutado con `-WindowStyle Hidden` | Sysmon Event ID 1 | T1204 — Ejecución implante |
| Nueva scheduled task con ruta no estándar | Windows Event ID 4698 | T1053.005 — Persistencia |
| Acceso a LSASS desde proceso no firmado | Sysmon Event ID 10 | T1003.001 — Credential Dump |

**Reglas SIGMA relevantes:**
- `proc_creation_win_webshell_spawn` — Proceso hijo sospechoso desde servidor web
- `net_connection_win_ligolo` — Conexiones a puerto 11601 desde hosts internos
- `sysmon_suspicious_scheduled_task_creation` — Scheduled tasks anómalas

---

## 🏴 MITRE ATT&CK Mapping

```
TA0043 Reconnaissance   → T1046 (Nmap), T1592.002 (Web fingerprint)
TA0001 Initial Access   → T1190 (CVE-2019-15107 Webmin RCE)
TA0011 C&C              → T1572 (Ligolo-ng tunnel), T1573.002 (Sliver HTTPS)
TA0011 C&C              → T1071.001 (HTTP/S C2), T1090 (Proxy via PROD)
TA0007 Discovery        → T1046 (Nmap interno), T1135 (SMB enum)
TA0006 Credential Access→ T1552.001 (Credenciales en Git repos)
TA0008 Lateral Movement → T1021.006 (WinRM al PC Windows)
TA0003 Persistence      → T1053.005 (Scheduled task), T1547.001 (Registry)
TA0009 Collection       → T1039 (Data from network shares)
```

---

*Operación SILENT BRIDGE — Adrián Camacho*  
*Entorno de laboratorio — Únicamente con fines educativos*