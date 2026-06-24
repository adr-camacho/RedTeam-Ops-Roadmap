# Infrastructure Setup — Operación DARK GATE
## Entorno de Lab + Configuración ADCS Vulnerable

**Operación:** DARK GATE | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 16/05/2026  
**Repositorio:** github.com/adr-camacho/RedTeam-Ops-Roadmap


> **Módulo M0 · Ruta: `[setup]`**
>
> **Objetivo único:** Entorno con ADCS y plantillas vulnerables (ESC1/4/8) sembradas.
>
> **Prerequisito real:** ninguno.
>
> **Habilita:** que existan plantillas vulnerables que enumerar (M1).
>
> **TTP:** — (provisión)
>
> ### Mapa de la operación (ESCs como rutas alternativas)
> ```
> M0 setup → M1 recon (Certipy) → ┌─ M2 ESC1 (SAN → Administrator) ─┐
>                                  ├─ M3 ESC4 (template mod → DA)    ─┼─→ M5 C2 → M6 persistencia+objetivo
>                                  └─ M4 ESC8 (NTLM relay → BLOQUEADO KB5005413)
> ```
> **Lectura:** las tres ESC son **rutas alternativas al mismo privilegio** — basta una para escalar. No es una
> cadena (Lab-02) ni ramas-side-quest (Lab-01): son **caminos distintos a lo alto de la misma colina**. ESC8 queda
> documentada como **bloqueada** (KB5005413/EPA), que es en sí una lección de defensa moderna.

---

## 1. Topología de Red

```
┌─────────────────────────────────────────────────────────────┐
│                  RED NAT — LabRedTeam                       │
│                   Segmento: 10.0.2.0/24                     │
│                                                             │
│   ┌──────────────────────────────────────┐                  │
│   │              DC-01                   │                  │
│   │           10.0.2.10                  │                  │
│   │         Windows Server 2022          │                  │
│   │                                      │                  │
│   │  ┌─────────────────────────────┐     │                  │
│   │  │    ADCS — Enterprise CA     │     │                  │
│   │  │   atackcorp-CA              │     │                  │
│   │  │   Plantillas vulnerables:   │     │                  │
│   │  │   - VulnerableTemplate(ESC1)│     │                  │
│   │  │   - UserAuthentication(ESC4)│     │                  │
│   │  │   Endpoint HTTP: /certsrv   │     │                  │
│   │  └─────────────────────────────┘     │                  │
│   │                                      │                  │
│   │  AD DS + DNS + MSSQL + IIS           │                  │
│   └──────────────────────────────────────┘                  │
│                        ▲                                    │
│           ┌────────────┴────────────┐                       │
│           │       Kali Linux        │                       │
│           │     10.0.2.9 (fijo)     │                       │
│           │  Certipy | impacket     │                       │
│           └─────────────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Especificaciones de los Sistemas

### DC-01 — Domain Controller + CA Enterprise

| Campo | Detalle |
|-------|---------|
| **Hostname** | DC-01 |
| **IP** | 10.0.2.10 |
| **SO** | Windows Server 2022 Datacenter |
| **RAM** | 4 GB |
| **Roles** | AD DS, DNS, ADCS (Enterprise CA), IIS, MSSQL |
| **Dominio** | atackcorp.local |
| **CA Name** | atackcorp-CA |
| **CA Type** | Enterprise Root CA |

### Kali Linux — Máquina operadora

| Campo | Detalle |
|-------|---------|
| **IP** | 10.0.2.9 (fijo via NetworkManager) |
| **Herramientas clave** | Certipy, impacket, evil-winrm, bloodyAD |
| **Internet** | Via eth2 (NAT), metric 50 |

---

## 3. Configuración ADCS — Plantillas Vulnerables

### Plantilla: VulnerableTemplate (ESC1)

| Atributo | Valor | Por qué es vulnerable |
|----------|-------|----------------------|
| `msPKI-Certificate-Name-Flag` | `0x1` (ENROLLEE_SUPPLIES_SUBJECT) | Solicitante puede especificar SAN arbitrario |
| EKU | Client Authentication (1.3.6.1.5.5.7.3.2) | Permite autenticación Kerberos |
| Enrolamiento | Domain Users | Cualquier usuario del dominio puede solicitar |
| Aprobación CA Manager | No requerida | Emisión automática sin revisión |

**Vector:** `fin.garcia` (Domain User) → solicita cert con `SAN=Administrador@atackcorp.local` → PKINIT → TGT + hash NT de Administrador

### Plantilla: UserAuthentication (ESC4)

| Atributo | Valor | Por qué es vulnerable |
|----------|-------|----------------------|
| Permisos | `fin.garcia` tiene `WriteProperty` | Puede modificar atributos de la plantilla |
| Modificación | Añadir `ENROLLEE_SUPPLIES_SUBJECT` | Convierte la plantilla en ESC1 |
| Restauración | Posible tras exploit | OPSEC: restaurar configuración original |

**Vector:** `fin.garcia` → modifica plantilla → ESC1 temporal → cert DA → restaurar plantilla

### ESC8 — NTLM Relay a ADCS (identificado)

| Atributo | Estado |
|----------|--------|
| Endpoint HTTP `/certsrv` | Activo |
| Autenticación NTLM | Habilitada |
| EPA (Extended Protection) | Deshabilitado |
| KB5005413 | No aplicado |

**Limitación en este lab:** Relay SMB→HTTP bloqueado en mismo segmento en WS2022. Documentado como vector potencial en entornos con CA en servidor separado.

---

## 4. Credenciales del Entorno

| Cuenta | Contraseña / Hash | Rol | Relevancia para el lab |
|--------|------------------|-----|------------------------|
| `Administrador` | `NuevaPassword2026!` | Domain Admin | Objetivo final |
| `fin.garcia` | `Finance2024!` | Domain User | Tiene permisos ESC1 + ESC4 |
| `helpdesk.ruiz` | `Helpdesk2024!` | IT Helpdesk | Usuario con enrolamiento |
| `ceo.martinez` | `Direccion2024!` | Domain User | Usuario de prueba |
| `krbtgt` | `d5237a2e43cb315c90679e2a5dae34ad` | Cuenta KDC | Obtenido en Lab-01 |

---

## 5. Vulnerabilidades Configuradas

| ID | Vulnerabilidad | Componente | Técnica MITRE |
|----|---------------|------------|---------------|
| V-01 | ESC1 — SAN arbitrario en VulnerableTemplate | ADCS | T1649 |
| V-04 | ESC4 — fin.garcia con WriteProperty sobre UserAuthentication | ADCS | T1484 |
| V-05 | ESC8 — endpoint HTTP ADCS sin EPA | ADCS | T1557 |
| V-06 | Certificados exportados con clave privada almacenados en disco | PKI | T1552 |
| V-07 | Permisos PKI-Admin share con acceso excesivo | AD | T1039 |

---

## 6. Crown Jewels del Lab

| Asset | Ubicación | Valor |
|-------|-----------|-------|
| Certificado Administrador (.pfx) | ADCS emisión via ESC1/ESC4 | Persistencia post-IR |
| Documentos R&D Proyecto Nexus | `C:\CorporateData\RD\` | Secreto comercial |
| Contrato M&A borrador | `C:\CorporateData\Legal\` | Información privilegiada |
| Share `PKI-Admin` | `\\DC-01\PKI-Admin` | Guía PKI + CA backup password |
| Share `Legal-Confidential` | `\\DC-01\Legal-Confidential` | Solo CEO + DA |

---

## 7. Verificación del Entorno

```bash
# Verificar conectividad
ping -c 1 10.0.2.10

# Verificar ADCS accesible
curl -k https://10.0.2.10/certsrv/ -I 2>/dev/null | head -3

# Enumerar CA y plantillas vulnerables
certipy find -u fin.garcia@atackcorp.local -p 'Finance2024!' \
  -dc-ip 10.0.2.10 -vulnerable -stdout

# Verificar credenciales
nxc smb 10.0.2.10 -u fin.garcia -p 'Finance2024!'
```

**Output esperado de certipy find:**
```
Certificate Templates
  Template Name: VulnerableTemplate
  [!] Vulnerabilities
    ESC1: 'ATACKCORP.LOCAL\Domain Users' can enroll, template allows SAN
  Template Name: UserAuthentication  
  [!] Vulnerabilities
    ESC4: 'ATACKCORP.LOCAL\fin.garcia' has dangerous permissions
```

---

## 8. Scripts de Provisioning

| Script | Ubicación | Función |
|--------|-----------|---------|
| `Setup-Lab01-GhostForest-v2.ps1` | `setup/provisioning/` | Infraestructura AD base |
| `CrownJewels-Lab03-DarkGate.ps1` | `setup/` | Datos confidenciales + shares PKI |

> ⚠️ Lab-03 reutiliza el mismo entorno AD de Lab-01. No requiere setup adicional — solo ejecutar el script de Crown Jewels y verificar que ADCS está instalado y activo en DC-01.

---

*Operación DARK GATE — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*