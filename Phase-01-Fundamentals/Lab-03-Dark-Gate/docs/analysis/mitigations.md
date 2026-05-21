# Mitigations — Operación DARK GATE
## Lab-03: ADCS Abuse — Perspectiva Blue Team
**Operación:** DARK GATE | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 17/05/2026

---

## Mitigaciones por vector explotado

### ESC1 — Enrollee Supplies Subject
**Técnica:** T1649  
**Impacto:** Cualquier usuario del dominio puede obtener certificado como DA

**Mitigaciones:**
- Deshabilitar `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` en todas las plantillas que no lo requieran explícitamente
- Revisar periódicamente plantillas con `msPKI-Certificate-Name-Flag = 1`
- Requerir aprobación de manager en plantillas que permitan SAN arbitrario (`msPKI-Enrollment-Flag = 2`)
- Implementar CA Manager Approval para todas las solicitudes de certificado con SAN personalizado
- Auditar con Certipy: `certipy find -stdout` — cualquier `ESC1` es crítico

**Detección:**
- Event ID 4886 — Certificate request received
- Event ID 4887 — Certificate approved and issued (con UPN diferente al solicitante)
- Alertar cuando el UPN en el certificado difiere del usuario que lo solicita

```yaml
# Regla SIGMA — ESC1 Detection
title: ADCS Certificate Request with Arbitrary SAN
detection:
  selection:
    EventID: 4887
    RequestAttributes|contains: 'SAN:'
  condition: selection
level: high
```

---

### ESC4 — Write Permissions on Certificate Template
**Técnica:** T1222 + T1649  
**Impacto:** Usuario de bajo privilegio modifica plantillas para escalar

**Mitigaciones:**
- Auditar ACLs de plantillas de certificado regularmente
- Solo Administrators y Enterprise Admins deben tener WriteDacl/GenericWrite sobre plantillas
- Implementar alertas sobre cambios en plantillas de certificado (Event ID 4899)
- Usar `Get-ACL` + PowerShell para identificar permisos anómalos en plantillas

```powershell
# Auditoría de permisos en plantillas
$ConfigContext = ([ADSI]"LDAP://RootDSE").configurationNamingContext
$Templates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"
$Templates.Children | ForEach-Object {
    $acl = $_.ObjectSecurity.Access | Where-Object {
        $_.IdentityReference -notmatch "Admin|System|Enterprise"
    }
    if ($acl) { Write-Host "ALERTA: $($_.Name) tiene permisos no estándar" }
}
```

**Detección:**
- Event ID 4899 — Certificate template modified
- Alertar sobre cualquier modificación de plantilla fuera de ventanas de mantenimiento

---

### ESC8 — NTLM Relay to HTTP Web Enrollment
**Técnica:** T1557.001  
**Impacto:** Relay de auth NTLM del DC → certificado del DC → DA  
**Estado en WS2022:** Bloqueado por KB5005413

**Mitigaciones:**
- Migrar Web Enrollment de HTTP a HTTPS (elimina el vector de relay)
- Deshabilitar NTLM en IIS certsrv — usar solo Kerberos
- Habilitar EPA (Extended Protection for Authentication) — `tokenChecking = Require`
- Si Web Enrollment no se usa, desinstalarlo: `Uninstall-AdcsWebEnrollment`
- Aplicar KB5005413 en WS2016/WS2019 (ya incluido en WS2022)

```powershell
# Deshabilitar Web Enrollment si no se usa
Uninstall-AdcsWebEnrollment -Force

# O migrar a HTTPS
# 1. Instalar certificado SSL en IIS
# 2. Crear binding HTTPS en certsrv
# 3. Eliminar binding HTTP
```

**Detección:**
- Monitorizar conexiones NTLM entrantes al puerto 80 de certsrv desde IPs inusuales
- Alertar sobre solicitudes POST a `/certsrv/certfnsh.asp` desde IPs que no son workstations

---

### Persistencia via Certificado
**Técnica:** T1649  
**Impacto:** Acceso persistente incluso tras rotación de contraseñas

**Mitigaciones:**
- Implementar Certificate Revocation List (CRL) y OCSP — revocar certificados comprometidos
- Acortar validez de certificados de usuario (de 1 año a 90 días)
- Monitorizar el uso de certificados para autenticación Kerberos (PKINIT)
- Implementar alertas cuando un certificado autentica a un usuario cuya contraseña cambió recientemente

```powershell
# Revocar certificado comprometido
$CA = "DC-01\AtackCorp-CA"
# Obtener serial del certificado
certutil -view -restrict "RequesterName=ATACKCORP\administrador" -out "RequestID,SerialNumber"
# Revocar
certutil -revoke <SerialNumber> 1  # 1 = Key Compromise
```

**Detección:**
- Event ID 4768 con `Pre-Authentication Type: 16` (PKINIT) — autenticación con certificado
- Correlacionar con cambios de contraseña recientes (Event ID 4723/4724)
- Alertar cuando un usuario autentique con certificado tras cambio de contraseña

---

## Herramientas de auditoría ADCS recomendadas

| Herramienta | Uso |
|-------------|-----|
| **Certipy** | `certipy find` — auditoría completa ESC1-ESC13 |
| **PSPKIAudit** | PowerShell — auditoría detallada de PKI |
| **LockSmith** | Detección de misconfiguraciones ADCS |
| **PingCastle** | Auditoría general AD + ADCS |

```bash
# Auditoría rápida desde Kali (perspectiva atacante/defensor)
certipy-ad find \
  -u auditor@dominio.local \
  -p 'Password123' \
  -dc-ip 10.0.0.1 \
  -stdout 2>&1 | grep -A5 "Vulnerabilities"
```

---

## Resumen de superficie de ataque ADCS

| Vector | Criticidad | Explotable WS2022 | Mitigación disponible |
|--------|-----------|-------------------|----------------------|
| ESC1 — SAN arbitrario | 🔴 Crítica | ✅ Sí | ✅ Deshabilitar flag |
| ESC4 — Write on template | 🔴 Alta | ✅ Sí | ✅ Auditar ACLs |
| ESC8 — NTLM Relay HTTP | 🟡 Alta | ❌ KB5005413 | ✅ HTTPS + EPA |
| Cert persistence | 🔴 Alta | ✅ Sí | ⚠️ CRL + OCSP |

---

*Operación DARK GATE — Adrián Camacho | Mayo 2026*