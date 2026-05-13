# Mitigations — Operación SILENT BRIDGE
## Lab-02: Wreath — Perspectiva Blue Team
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** — (completar al finalizar)

> Completar este documento tras ejecutar todas las fases.  
> Para cada vector explotado, documentar la mitigación técnica concreta.

---

## Mitigaciones por vector

### CVE-2019-15107 — Webmin RCE
- Actualizar Webmin a versión ≥ 1.920
- Deshabilitar `passwd_mode` si no es necesario: eliminar o establecer `passwd_mode=0` en `miniserv.conf`
- Restringir acceso a Webmin (:10000) a IPs de administración — no exponer a Internet
- Web Application Firewall: alertar sobre POST a `/password_change.cgi` con metacaracteres

### Credenciales en repositorio Git
- Implementar pre-commit hooks que detecten patrones de credenciales (`git-secrets`, `truffleHog`)
- Rotar credenciales inmediatamente si se detectan en historial — el historial git persiste aunque se elimine el archivo
- Usar variables de entorno o vaults (HashiCorp Vault, AWS Secrets Manager) para credenciales
- Auditoría periódica de repositorios con `truffleHog` o `gitleaks`

### Ligolo-ng — Protocol Tunneling
- Monitorizar creación de interfaces `tun` en hosts Linux (auditd)
- Alertar sobre conexiones TLS salientes a puertos no estándar desde servidores
- Network segmentation estricta: PROD no debería tener acceso saliente a Internet salvo puertos necesarios
- Inspección TLS en gateway si es posible (certificados autofirmados son indicador)

### WinRM — Lateral Movement
- Restringir WinRM a IPs de administración conocidas via Windows Firewall
- Habilitar logging de WinRM: `wevtutil sl Microsoft-Windows-WinRM/Operational /e:true`
- Alertar sobre logons tipo 3 con wsmprovhost.exe desde IPs no habituales

### Sliver Beacon — C2 HTTPS
- EDR con detección de comportamiento (no solo firmas) — Sliver usa obfuscación de símbolos
- Alertar sobre procesos no firmados en directorios de usuario con conexiones HTTPS periódicas
- Network monitoring: patrón de beaconing (conexiones regulares a misma IP externa)
- Application whitelisting: solo ejecutables firmados en rutas de usuario

### Scheduled Task — Persistence
- Auditar Event ID 4698 (scheduled task creada) en todos los endpoints
- Alertar sobre tareas con ejecutables en rutas de usuario (`C:\Users\*`)
- Revisar periódicamente tareas programadas no autorizadas: `schtasks /query /fo LIST /v`

---

## Resumen de superficie de ataque — Wreath

| Vector | Criticidad | Complejidad explotación | Mitigación disponible |
|--------|-----------|------------------------|----------------------|
| CVE-2019-15107 | Crítica | Baja (pre-auth, sin creds) | ✅ Patch disponible |
| Git credentials exposure | Alta | Baja (lectura historial) | ✅ git-secrets / vault |
| WinRM con creds reusadas | Alta | Baja (creds directas) | ✅ Segmentación + MFA |
| Protocol Tunneling | Media | Media (requiere foothold) | ⚠️ Difícil detectar |
| C2 Beacon HTTPS | Media | Media (requiere foothold) | ⚠️ Requiere EDR avanzado |

---

*Completar con valores reales tras ejecutar la operación — Adrián Camacho*