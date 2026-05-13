# Enumeration Log — Operación SILENT BRIDGE
## Fases 1 y 4 — Reconnaissance externo + Enumeración red interna
**Operación:** SILENT BRIDGE | **Adversario:** APT41 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** —  
**Objetivo Fase 1:** PROD (10.0.2.200) — superficie de ataque externa  
**Objetivo Fase 4:** Red interna — GIT server + PC Windows (post-pivote)

---

## FASE 1 — Reconnaissance externo

**Táctica MITRE:** TA0043 — Reconnaissance  
**Objetivo:** Mapear servicios expuestos en PROD. Confirmar versión vulnerable de Webmin. Identificar vector de explotación.

---

### 1.1 — Network Service Discovery (Port scan completo)
**Técnica MITRE:** T1046  
**Herramienta:** Nmap  
**Captura:** `fase1-01-nmap-port-discovery.png`

```bash
nmap -p- --min-rate 5000 -oA nmap/prod_ports 10.0.2.200
```

**Resultado:**

| Puerto | Estado | Servicio |
|--------|--------|---------|
| — | — | — |

> Completar con los puertos reales identificados.

**Vectores identificados:**
- Puerto `:10000` → Webmin → **Vector principal**
- Puerto `:22` → SSH → Acceso post-explotación
- Puerto `:80/443` → HTTP/S → Reconocimiento web adicional

---

### 1.2 — Service Version Detection
**Técnica MITRE:** T1046  
**Herramienta:** Nmap -sC -sV  
**Captura:** `fase1-02-nmap-service-version.png`

```bash
nmap -sC -sV -p 22,80,443,10000 -oA nmap/prod_detailed 10.0.2.200
```

**Hallazgos clave:**

| Hallazgo | Valor | Implicación |
|----------|-------|-------------|
| Webmin versión | — | Vulnerable si < 1.920 |
| OS / Distribución | — | — |
| SSH versión | — | — |
| Título HTTP | — | — |

---

### 1.3 — Webmin Fingerprint
**Técnica MITRE:** T1592.002  
**Herramienta:** curl  
**Captura:** `fase1-03-webmin-fingerprint.png`

```bash
curl -sk https://10.0.2.200:10000/ | grep -i "version\|webmin"
curl -skI https://10.0.2.200:10000/
```

**Versión Webmin identificada:** `_______`  
**Vulnerable a CVE-2019-15107:** ✅ / ❌

---

### 1.4 — CVE Identification
**Técnica MITRE:** T1596  
**Herramienta:** searchsploit  
**Captura:** `fase1-04-cve-identification.png`

```bash
searchsploit webmin 1.890
searchsploit -x php/webapps/47293.rb
```

**CVE-2019-15107:** RCE pre-auth via `/password_change.cgi`  
**Condición:** `passwd_mode=2` activo en `miniserv.conf`  
**Tipo de acceso:** RCE como `root` sin credenciales

---

### Resumen Fase 1

```
SUPERFICIE MAPEADA — PROD (10.0.2.200)
════════════════════════════════════════════

DESCARTADO:
  ✗ [completar tras recon]

VECTORES ACTIVOS:
  ✓ Webmin :10000  → CVE-2019-15107 RCE pre-auth
  ✓ SSH :22        → Acceso post-explotación con credenciales

INFORMACIÓN OBTENIDA SIN CREDENCIALES:
  • OS:      [completar]
  • Webmin:  [versión]
  • SSH:     [versión]
```

**Criterio de éxito Fase 1:** ⏳  
→ Versión Webmin confirmada como vulnerable. CVE identificado.

---

## FASE 4 — Enumeración red interna (post-pivote)

**Táctica MITRE:** TA0007 — Discovery  
**Prerrequisito:** Túnel Ligolo-ng activo — Fase 3 completada  
**Objetivo:** Mapear todos los hosts de la red interna. Identificar servicios en GIT y PC. Obtener credenciales.

---

### 4.1 — Host Discovery — red interna
**Técnica MITRE:** T1046  
**Herramienta:** Nmap (directo a través del túnel — sin proxychains)  
**Captura:** `fase4-01-internal-host-discovery.png`

```bash
# Ajustar el rango al segmento real identificado en Fase 3
nmap -sn 10.0.2.0/24 --min-rate 3000 -oA nmap/internal_sweep
```

**Hosts vivos identificados:**

| IP | Hostname | SO (estimado) | Rol |
|----|---------|--------------|-----|
| 10.0.2.200 | PROD | Linux | Ya comprometido |
| — | — | — | GIT server |
| — | — | — | PC Windows |

---

### 4.2 — Service Discovery — GIT Server
**Técnica MITRE:** T1046  
**Herramienta:** Nmap  
**Captura:** `fase4-02-nmap-git-server.png`

```bash
nmap -sC -sV -p- --min-rate 5000 <GIT_IP> -oA nmap/git_detailed
```

**Servicios identificados:**

| Puerto | Servicio | Versión | Relevancia |
|--------|---------|---------|-----------|
| — | — | — | — |

---

### 4.3 — Service Discovery — PC Windows
**Técnica MITRE:** T1046  
**Herramienta:** Nmap  
**Captura:** `fase4-03-nmap-pc-windows.png`

```bash
nmap -sC -sV -p 80,135,139,443,445,3389,5985,8080 <PC_IP> -oA nmap/pc_detailed
```

**Servicios identificados:**

| Puerto | Servicio | Versión | Relevancia |
|--------|---------|---------|-----------|
| — | — | — | — |

**Vectores activos en PC:**
- WinRM `:5985` → ✅ / ❌
- SMB `:445` → ✅ / ❌
- RDP `:3389` → ✅ / ❌

---

### 4.4 — Enumeración Web / Git — GIT Server
**Técnica MITRE:** T1083  
**Herramienta:** curl, gobuster, git  
**Captura:** `fase4-04-git-repositories.png`

```bash
curl -s http://<GIT_IP>/
gobuster dir -u http://<GIT_IP> \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt

# Clonar repositorio accesible
git clone http://<GIT_IP>/<repo>.git /tmp/repo_wreath
cd /tmp/repo_wreath
git log --oneline --all
git show <commit_hash>
```

**Repositorios encontrados:**

| Nombre | URL | Descripción |
|--------|-----|-------------|
| — | — | — |

---

### 4.5 — Credential Discovery — Git history
**Técnica MITRE:** T1552.001  
**Captura:** `fase4-05-credentials-found.png`

```bash
cd /tmp/repo_wreath
git log -p | grep -i "password\|passwd\|secret\|key\|token"
git show <commit_antiguo>
```

**Credenciales encontradas:**

| Usuario | Contraseña | Dónde | Commit |
|---------|-----------|-------|--------|
| — | — | — | — |

---

### Resumen Fase 4

```
RED INTERNA MAPEADA
════════════════════════════════════════════════════════

HOSTS:
  PROD  10.0.2.___  Linux    [ya comprometido — pivote]
  GIT   10.0.2.___  Linux    [servicios: ___]
  PC    10.0.2.___  Windows  [WinRM: ✅/❌ | SMB: ✅/❌]

CREDENCIALES OBTENIDAS:
  [usuario] : [contraseña] — [fuente: git history]

VECTORES HACIA PC:
  ✓ WinRM con credenciales del repositorio Git
```

**Criterio de éxito Fase 4:** ⏳  
→ Hosts internos mapeados + credenciales obtenidas del repositorio Git.

---

**Siguiente:** [exploitation.md](exploitation.md) — Fase 2 | [post-exploitation.md](post-exploitation.md) — Fase 5