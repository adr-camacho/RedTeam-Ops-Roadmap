# Enumeration Log — Operación DARK GATE
## Fase 1 — ADCS Reconnaissance con Certipy
**Operación:** DARK GATE | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 17/05/2026

---

## FASE 1 — ADCS Reconnaissance

**Táctica MITRE:** TA0007 — Discovery  
**Técnica:** T1046 — Network Service Discovery  
**Herramienta:** Certipy v5.0.4

---

### 1.1 — ADCS Enumeration completa
> 📸 Captura: ![fase1-01](../screenshots/FASE-1-Reconnaissance/fase1-01-certipy-find-esc8.png)  
> 📸 Captura: ![fase1-02](../screenshots/FASE-1-Reconnaissance/fase1-02-certipy-find-esc1.png)

```bash
certipy-ad find \
  -u ceo.martinez@atackcorp.local \
  -p 'Direccion2024!' \
  -dc-ip 10.0.2.10 \
  -stdout
```

**Hallazgos:**

| Elemento | Valor |
|---------|-------|
| CA encontrada | `AtackCorp-CA` |
| DNS Name | `DC-01.atackcorp.local` |
| Serial | `3597D201FB489F9342B3A104DB9E7117` |
| Validez | 2026-05-16 → 2031-05-16 |
| Web Enrollment HTTP | `True` ← **ESC8** |
| Web Enrollment HTTPS | `False` |
| User Specified SAN | `Disabled` |
| Plantillas encontradas | 34 total / 12 habilitadas |

---

### 1.2 — ESC8 identificado

```
Certificate Authorities
  0
    CA Name : AtackCorp-CA
    Web Enrollment
      HTTP
        Enabled : True       ← ESC8
      HTTPS
        Enabled : False
    [!] Vulnerabilities
      ESC8 : Web Enrollment is enabled over HTTP.
```

**Impacto ESC8:** Endpoint `/certsrv/` accesible via HTTP con autenticación NTLM → relay attack posible.

---

### 1.3 — ESC1 identificado en plantilla VulnerableUser

```
Certificate Templates
  0
    Template Name              : VulnerableUser
    Enabled                    : True
    Client Authentication      : True
    Enrollee Supplies Subject  : True
    Certificate Name Flag      : EnrolleeSuppliesSubject
    Requires Manager Approval  : False
    Enrollment Rights          : ATACKCORP.LOCAL\Usuarios del dominio
    [!] Vulnerabilities
      ESC1 : Enrollee supplies subject and template allows client authentication.
```

**Impacto ESC1:** Cualquier usuario del dominio puede solicitar un certificado con UPN arbitrario (ej. `Administrador@atackcorp.local`) → obtener TGT + hash NTLM del DA sin conocer su contraseña.

---

### 1.4 — ESC4 identificado (permisos sobre plantilla)

`fin.garcia` tiene `GenericWrite` + `WriteDacl` + `WriteProperty` sobre `VulnerableUser` → puede modificar atributos de la plantilla para escalar privilegios.

---

### Resumen Fase 1

```
ADCS RECONNAISSANCE — Estado final
════════════════════════════════════════════

CA: AtackCorp-CA @ DC-01.atackcorp.local ✅

VULNERABILIDADES CONFIRMADAS:
  [ESC1] VulnerableUser
         Enrollee Supplies Subject: True
         Client Auth: True
         Enrollment: Usuarios del dominio

  [ESC4] fin.garcia
         GenericWrite + WriteDacl sobre VulnerableUser

  [ESC8] Web Enrollment HTTP
         http://10.0.2.10/certsrv/
         NTLM auth: True

TÉCNICAS MITRE:
  T1046  → Network Service Discovery
  T1592  → Gather Victim Host Info
```

**Criterio de éxito Fase 1:** ✅

---

**Siguiente:** [exploitation_esc1.md](exploitation_esc1.md) — Fase 2