# Infrastructure Setup — Operación DARK GATE
## Lab-03: ADCS Abuse — APT29 Emulation
**Operación:** DARK GATE | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 16-17/05/2026

---

## Entorno de laboratorio

| Host | SO | IP | Rol |
|------|----|----|-----|
| DC-01 | Windows Server 2022 | `10.0.2.10` | DC + ADCS AtackCorp-CA |
| Kali | Kali Linux 2026.1 | `10.0.2.9` | Máquina operadora APT29 |

**Red:** LabRedTeam — NAT Network VirtualBox `10.0.2.0/24`  
**Dominio:** `atackcorp.local`  
**DC reutilizado de Lab-01** — usuarios y estructura AD preexistentes

---

## Instalación ADCS

### 1. Instalar rol Certification Authority

```powershell
Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools
```

### 2. Configurar Enterprise Root CA

```powershell
Install-AdcsCertificationAuthority `
    -CAType EnterpriseRootCa `
    -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
    -KeyLength 2048 `
    -HashAlgorithmName SHA256 `
    -CACommonName "AtackCorp-CA" `
    -CADistinguishedNameSuffix "DC=atackcorp,DC=local" `
    -OverwriteExistingKey `
    -Force
```

**CA instalada:** `AtackCorp-CA @ DC-01.atackcorp.local`  
**Validez:** 2026-05-16 → 2031-05-16

### 3. Verificar servicio

```powershell
Get-Service CertSvc     # → Running
certutil -getreg CA\CommonName  # → AtackCorp-CA
```

---

## Configuración de vulnerabilidades ADCS

### ESC1 — Enrollee Supplies Subject

**Plantilla creada:** `VulnerableUser`  
**Base:** Plantilla `User` del sistema

```powershell
# Crear plantilla con flag ESC1
$NewTemplate.Put("msPKI-Certificate-Name-Flag", 1)  # CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT
$NewTemplate.Put("msPKI-Enrollment-Flag", 0)         # Sin aprobación de manager
$NewTemplate.Put("msPKI-RA-Signature", 0)            # Sin firma de RA

# OID asignado
$OID = "1.3.6.1.4.1.311.21.8.3242212.7457772"

# Permisos — Domain Users pueden solicitar certificados (SID-513)
$DomainUsersSID = New-Object System.Security.Principal.SecurityIdentifier("$DomainSID-513")
# ExtendedRight GUID: 0e10c968-78fb-11d2-90d4-00c04fc2dcd2 (Certificate-Enrollment)
```

**Atributos clave:**

| Atributo | Valor | Relevancia |
|---------|-------|-----------|
| `msPKI-Certificate-Name-Flag` | `1` | EnrolleeSuppliesSubject — SAN arbitrario |
| `msPKI-Enrollment-Flag` | `0` | Sin aprobación requerida |
| Extended Key Usage | `1.3.6.1.5.5.7.3.2` | Client Authentication |
| Enrollment Rights | `Usuarios del dominio` | Cualquier usuario puede solicitar |

```powershell
# Publicar en la CA
Add-CATemplate -Name "VulnerableUser" -Force
```

---

### ESC4 — Write Permissions on Template

**Usuario vulnerable:** `fin.garcia`  
**Permisos:** `GenericWrite` + `WriteDacl` + `WriteProperty` sobre `VulnerableUser`

```powershell
# GenericWrite
$Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $FinGarciaSID,
    [System.DirectoryServices.ActiveDirectoryRights]::GenericWrite,
    [System.Security.AccessControl.AccessControlType]::Allow
)

# WriteDacl + WriteProperty (necesario para Certipy v5)
$Rule2 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $FinGarciaSID,
    [System.DirectoryServices.ActiveDirectoryRights]"WriteDacl,WriteProperty",
    [System.Security.AccessControl.AccessControlType]::Allow
)
```

**Nota:** Certipy v5 requiere `WriteDacl` además de `GenericWrite` para modificar `nTSecurityDescriptor`. Se añadió en un segundo paso durante la configuración.

---

### ESC8 — NTLM Relay to HTTP Enrollment

**Endpoint:** `http://10.0.2.10/certsrv/`

```powershell
# Instalar Web Enrollment
Install-WindowsFeature -Name ADCS-Web-Enrollment -IncludeManagementTools
Install-AdcsWebEnrollment -Force

# IIS corriendo
Start-Service W3SVC
```

**Configuraciones adicionales para el lab (desde Evil-WinRM post-ESC1):**

```powershell
# Deshabilitar EPA (Extended Protection for Authentication)
Set-WebConfigurationProperty `
    -Filter "system.webServer/security/authentication/windowsAuthentication" `
    -Name "extendedProtection.tokenChecking" `
    -PSPath "IIS:\Sites\Default Web Site\certsrv" `
    -Value "None"

# Deshabilitar kernel-mode auth (applicationHost.config)
$config = "C:\Windows\System32\inetsrv\config\applicationHost.config"
(Get-Content $config) -replace 'useKernelMode="true"', 'useKernelMode="false"' | Set-Content $config

# Bajar nivel NTLM (permite relay)
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa `
    -Name "LmCompatibilityLevel" -Value 2 -Type DWord

iisreset /noforce
```

**Resultado ESC8:** Relay SMB→HTTP bloqueado por KB5005413 en WS2022. Vulnerabilidad identificada y documentada — no explotable en WS2022 parcheado.

---

## Verificación del entorno

```bash
# Desde Kali — verificar ESC1 y ESC8
certipy-ad find \
  -u ceo.martinez@atackcorp.local \
  -p 'Direccion2024!' \
  -dc-ip 10.0.2.10 \
  -stdout
```

**Output esperado:**
```
[!] Vulnerabilities
    ESC1 : Enrollee supplies subject and template allows client authentication.
[!] Vulnerabilities  
    ESC8 : Web Enrollment is enabled over HTTP.
```

---

## Script de setup

El entorno se reproduce completamente con:

```powershell
# En DC-01 como Administrador
.\setup\Setup-Lab03-DarkGate.ps1
```

---

## Credenciales del entorno

| Usuario | Contraseña | Rol en el lab |
|---------|-----------|---------------|
| `ceo.martinez` | `Direccion2024!` | Vector ESC1 (Domain User) |
| `fin.garcia` | `Finance2024!` | Vector ESC4 (GenericWrite) |
| `Administrador` | `NuevaPassword2026!` | DA — objetivo final |

**Nota:** La contraseña del Administrador fue rotada durante la Fase 6 para demostrar persistencia via certificado.

---

*Operación DARK GATE — Adrián Camacho | Mayo 2026*