# 📋 [NOMBRE DEL LAB] — Writeup

> **Plataforma:** TryHackMe / HackTheBox / Lab Propio  
> **Dificultad:** Fácil / Media / Difícil  
> **Fecha de realización:** DD/MM/YYYY  
> **Tiempo invertido:** Xh Xmin  
> **Estado:** ✅ Completado / 🔄 En progreso

---

## 1. 📝 Summary Ejecutivo

> Resumen de 3-5 líneas orientado a negocio. Qué sistema fue comprometido, cómo, y cuál es el impacto real. Escrito como si fuera para un CISO, no para un técnico.

**Ejemplo:**
> Se ha comprometido el controlador de dominio `DC-01` del entorno `atackcorp.local` mediante el abuso de configuraciones inseguras de Kerberos. Un atacante con acceso a la red interna podría obtener credenciales de cuentas de servicio sin autenticación previa y elevar privilegios hasta Domain Admin sin interacción del usuario.

**Impacto:** Crítico / Alto / Medio / Bajo  
**Vector de entrada:** [Descripción breve del punto de entrada inicial]  
**Objetivo comprometido:** [Nombre del sistema o cuenta final comprometida]

---

## 2. 🗺️ Attack Path

> Mapa visual del camino de compromiso. Usar diagrama ASCII o enlace a imagen BloodHound.

```
[Punto de entrada]
      │
      ▼
[Técnica 1] → [Credencial/Acceso obtenido]
      │
      ▼
[Técnica 2] → [Escalada de privilegios]
      │
      ▼
[Objetivo final: DA / SYSTEM / Flag]
```

**Diagrama BloodHound:** `screenshots/bloodhound_path.png`

---

## 3. 🔍 Reconocimiento y Enumeración

### 3.1 Escaneo de Red

```bash
# Escaneo inicial
nmap -sC -sV -p- --min-rate 5000 -oA nmap/initial <IP>
```

**Puertos abiertos:**

| Puerto | Servicio | Versión | Notas |
|--------|---------|---------|-------|
| 53 | DNS | — | Domain Controller |
| 88 | Kerberos | — | Dominio AD |
| 135 | MSRPC | — | — |
| 139/445 | SMB | — | Shares accesibles |
| 389 | LDAP | — | Enumeración AD |
| 5985 | WinRM | — | Acceso remoto |

### 3.2 Enumeración SMB

```bash
# Null session
smbclient -L //<IP> -N
enum4linux-ng -A <IP>

# Con credenciales
crackmapexec smb <IP> -u <user> -p <pass> --shares
```

**Resultado:**
```
[Pegar output relevante aquí]
```

### 3.3 Enumeración LDAP / AD

```bash
# Usuarios con AS-REP Roasting habilitado
impacket-GetNPUsers <dominio>/ -dc-ip <IP> -no-pass -usersfile users.txt

# Cuentas con SPN (Kerberoasting)
impacket-GetUserSPNs <dominio>/<user>:<pass> -dc-ip <IP>

# BloodHound collection
bloodhound-python -u <user> -p <pass> -d <dominio> -dc <DC_IP> -c all
```

**Hallazgos relevantes:**
- [ ] Usuarios con `DoesNotRequirePreAuth`
- [ ] Cuentas con SPN configurado
- [ ] ACLs abusables
- [ ] Delegaciones Kerberos

---

## 4. 💥 Explotación

### 4.1 [Nombre de la Técnica — MITRE TID]

**Descripción:**
> Explicar brevemente por qué funciona esta técnica y qué condición la hace posible.

**Condición previa:** [Qué tiene que estar mal configurado]

**Comando ejecutado:**
```bash
[comando exacto utilizado]
```

**Output obtenido:**
```
[output real de la terminal — sin omitir errores intermedios]
```

**Resultado:** [Qué se obtuvo: hash, credencial, ticket, acceso]

---

### 4.2 [Nombre de la siguiente técnica]

**Descripción:**
> ...

**Comando ejecutado:**
```bash
[comando]
```

**Output:**
```
[output]
```

---

## 5. 🔓 Post-Explotación

### 5.1 Acceso inicial

```bash
# Acceso interactivo
evil-winrm -i <IP> -u <user> -p <pass>
```

### 5.2 Enumeración post-compromiso

```powershell
# Whoami y privilegios
whoami /all

# Usuarios del dominio
net user /domain

# Grupos del dominio
net group "Domain Admins" /domain

# Información del sistema
systeminfo
```

**Privilegios habilitados:**

| Privilegio | Estado | Vector LPE |
|-----------|--------|------------|
| SeImpersonatePrivilege | Habilitado | PrintSpoofer / GodPotato |
| SeDebugPrivilege | Habilitado | Dump LSASS |
| SeBackupPrivilege | Habilitado | Leer archivos protegidos |

### 5.3 Movimiento lateral

```bash
# Pass-the-Hash
crackmapexec smb <IP> -u <user> -H <NTLM_hash>

# Pass-the-Ticket
impacket-psexec -k -no-pass <dominio>/<user>@<target>
```

### 5.4 Escalada a Domain Admin

```bash
[Comandos utilizados para la escalada final]
```

**Evidencia de DA:**
```
[Output de whoami /groups o similar mostrando DA]
```

**Screenshot:** `screenshots/domain_admin.png`

---

## 6. 🎯 Flags / Objetivos

| Objetivo | Valor | Ruta |
|---------|-------|------|
| User flag | `[HASH/FLAG]` | `C:\Users\<user>\Desktop\user.txt` |
| Root / Admin flag | `[HASH/FLAG]` | `C:\Users\Administrator\Desktop\root.txt` |
| Hash NT de DA | `[HASH]` | Volcado con secretsdump |

---

## 7. 🛡️ Detección y Mitigaciones

> Esta sección es la que diferencia un Red Team writeup de un simple CTF writeup. Escrito desde la perspectiva del Blue Team.

### 7.1 ¿Cómo detectar estas técnicas?

| Técnica | Evento Windows | Descripción |
|---------|---------------|-------------|
| AS-REP Roasting | Event ID 4768 | TGT solicitado sin pre-autenticación |
| Kerberoasting | Event ID 4769 | TGS solicitado para cuenta de servicio |
| Pass-the-Hash | Event ID 4624 (Logon Type 3) | Login NTLM sin contraseña en texto claro |
| Token Impersonation | Event ID 4672 | Asignación de privilegios especiales |
| DCSync | Event ID 4662 | Replicación de directorio (DS-Replication-Get-Changes) |

### 7.2 Mitigaciones recomendadas

**[Técnica 1]:**
- Mitigación específica
- Configuración recomendada
- Referencia: [MITRE D3FEND / CIS Controls]

**[Técnica 2]:**
- Mitigación específica

### 7.3 Reglas SIGMA / Detección SIEM

```yaml
# Ejemplo regla SIGMA para AS-REP Roasting
title: AS-REP Roasting Activity
status: experimental
description: Detects AS-REP roasting attempts via Kerberos
logsource:
    product: windows
    service: security
detection:
    selection:
        EventID: 4768
        TicketEncryptionType: '0x17'
        TargetUserName|endswith: '$'
    condition: selection
falsepositives:
    - Legacy systems requiring RC4
level: medium
tags:
    - attack.credential_access
    - attack.t1558.004
```

---

## 8. 📚 Referencias

| Recurso | URL | Relevancia |
|---------|-----|-----------|
| HackTricks | https://book.hacktricks.xyz | Técnicas generales |
| ired.team | https://www.ired.team | AD attacks |
| MITRE ATT&CK | https://attack.mitre.org | Mapping de técnicas |
| [Recurso específico] | [URL] | [Por qué fue útil] |

---

## 9. 🧠 Lecciones Aprendidas

> Máximo 5 puntos. Cosas que no sabías antes, errores cometidos, o insights que cambiarían tu enfoque la próxima vez.

1. **[Lección 1]:** Descripción breve de lo aprendido.
2. **[Lección 2]:** Descripción breve.
3. **[Lección 3]:** Descripción breve.

---

*Writeup por Adrián Camacho | [LinkedIn](https://www.linkedin.com/in/adrian-camacho-mora/) | [TryHackMe](https://tryhackme.com/p/sapodos)*