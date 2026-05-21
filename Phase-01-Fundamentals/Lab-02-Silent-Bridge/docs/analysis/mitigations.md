# Mitigations — Operación SILENT BRIDGE
## Lab-02: Wreath — Perspectiva Blue Team
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 15/05/2026

---

## Mitigaciones por vector explotado

### CVE-2019-12840 — Webmin Package Updates RCE
**Técnica:** T1190 — Exploit Public-Facing Application  
**Impacto:** RCE como root en servidor de producción expuesto

**Mitigaciones:**
- Actualizar Webmin a versión ≥ 1.920 inmediatamente
- Restringir acceso a Webmin `:10000` a IPs de administración — no exponer a Internet
- Deshabilitar el módulo Package Updates si no es necesario: `Webmin → Webmin Configuration → Webmin Modules`
- WAF: alertar sobre POST a `/package-updates/update.cgi` con metacaracteres en parámetro `u`
- Principio de mínimo privilegio: Webmin no debería correr como root

**Detección:**
- Web access log: POST a `/package-updates/update.cgi` con `u=%20%7C%20` (pipe URL-encoded)
- Proceso hijo de `miniserv.pl` lanzando bash/python/nc
- Conexión saliente TCP desde el proceso de Webmin

---

### T1552.001 — Credenciales en historial Git
**Impacto:** Credenciales de usuario obtenidas sin autenticación desde repositorio interno

**Mitigaciones:**
- Implementar pre-commit hooks: `git-secrets`, `truffleHog`, `gitleaks`
- Nunca commitear credenciales — usar variables de entorno o vaults (HashiCorp Vault)
- Si ya están en historial: rotar credenciales inmediatamente + `git filter-repo` para reescribir historial
- Auditoría periódica de repositorios: `truffleHog --regex --entropy=False .`
- Formación del equipo de desarrollo en secure coding practices

**Detección:**
- Monitorizar clonaciones masivas de repositorios internos
- Alertar sobre accesos a `/commit/<hash>` que muestren archivos con patrones de credenciales

---

### T1572 — Protocol Tunneling (Ligolo-ng)
**Impacto:** Acceso transparente a red interna segmentada desde atacante externo

**Mitigaciones:**
- Monitorizar creación de interfaces `tun` en hosts Linux (auditd rule: `ip tuntap add`)
- Alertar sobre conexiones TLS salientes a puertos no estándar (11601) desde servidores
- Segmentación de red estricta: PROD no debería tener acceso saliente sin restricciones
- Inspección TLS en gateway — certificados autofirmados son indicador de tunneling
- EDR en servidores Linux con detección de procesos que abren sockets TLS persistentes

**Detección (auditd):**
```
-a always,exit -F arch=b64 -S ioctl -k tun_create
-a always,exit -F arch=b64 -S connect -F uid!=0 -k outbound_nonroot
```

**Regla Suricata:**
```
alert tls any any -> any 11601 (msg:"Possible Ligolo-ng tunnel"; sid:9000001;)
```

---

### T1021.006 — WinRM Lateral Movement
**Impacto:** Acceso interactivo a PC Windows interno con credenciales reutilizadas

**Mitigaciones:**
- No reutilizar credenciales entre servicios (Git ≠ WinRM)
- Restringir WinRM a IPs de administración conocidas via Windows Firewall
- Habilitar logging de WinRM: `wevtutil sl Microsoft-Windows-WinRM/Operational /e:true`
- Usar cuentas de servicio dedicadas con contraseñas únicas y rotación automática
- MFA para acceso remoto a sistemas críticos

**Detección:**
- Event ID 4624 (Logon Type 3) + `wsmprovhost.exe` desde IPs no habituales
- Event ID 4648 — explicit credential logon

---

### T1562.001 — Impair Defenses (Defender)
**Impacto:** Defender desactivado permitiendo ejecución de beacon sin detección

**Mitigaciones:**
- **Tamper Protection activa** — ya estaba activa en el lab, correctamente configurada
- Alertar sobre intentos de `Set-MpPreference` via WinRM (Event ID 4104 — script block logging)
- Microsoft Defender for Endpoint — detecta desactivación de Defender aunque se haga con admin local
- WDAC (Windows Defender Application Control) para whitelist de ejecutables

**Detección:**
- Event ID 5001 — Real-time protection disabled
- Sysmon Event 13 — `Set-MpPreference` en registry de Defender

---

### T1053.005 — Scheduled Task Persistence
**Impacto:** Beacon re-ejecutado en cada inicio de sesión — persistencia post-reinicio

**Mitigaciones:**
- Alertar sobre Event ID 4698 (scheduled task creada) con rutas en `C:\Users\*`
- Auditoría periódica de tareas programadas no autorizadas: `schtasks /query /fo CSV`
- Application whitelisting — solo ejecutables firmados pueden crear tareas programadas
- Revisión de tareas con nombres que imitan software legítimo ("WindowsUpdateHelper")

---

### T1003.002 — SAM Credential Dumping
**Impacto:** Hashes NTLM de todos los usuarios locales obtenidos

**Mitigaciones:**
- Credential Guard — protege hashes en memoria de forma virtualizada
- LAPS (Local Administrator Password Solution) — contraseñas únicas por máquina
- Alertar sobre `reg save HKLM\SAM` y `reg save HKLM\SYSTEM` (Sysmon Event 1)
- Monitorizar creación de archivos `.bak` en directorios de usuario

**Detección:**
```yaml
# Regla SIGMA
title: SAM Registry Hive Export
detection:
  selection:
    EventID: 1
    CommandLine|contains:
      - 'reg save'
      - 'HKLM\SAM'
      - 'HKLM\SYSTEM'
  condition: selection
level: high
```

---

## Resumen de superficie de ataque — Wreath

| Vector | Criticidad | Complejidad explotación | Mitigación disponible |
|--------|-----------|------------------------|----------------------|
| CVE-2019-12840 Webmin | 🔴 Crítica | Baja (herramienta disponible) | ✅ Patch inmediato |
| Git credentials exposure | 🔴 Alta | Baja (git show) | ✅ Pre-commit hooks + rotación |
| Protocol Tunneling (Ligolo) | 🟡 Media | Media (requiere foothold) | ⚠️ Difícil detectar |
| WinRM con creds reutilizadas | 🔴 Alta | Baja (credenciales directas) | ✅ No reutilizar + MFA |
| Defender desactivado | 🟡 Media | Baja (requiere admin local) | ✅ Tamper Protection |
| Scheduled Task persistence | 🟡 Media | Baja (schtasks nativo) | ✅ Event ID 4698 alerting |
| SAM dump (reg save) | 🔴 Alta | Baja (LOLBin nativo) | ✅ Credential Guard + LAPS |

---

*Operación SILENT BRIDGE — Adrián Camacho | Mayo 2026*