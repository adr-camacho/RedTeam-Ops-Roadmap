# Theory — Kerberos Fundamentals & AS-REP Roasting

> **Lab-01 · Ghost Forest**  
> Bloque CRTO: Kerberos Authentication, Credential Theft (AS-REP, Kerberoasting, DCSync)

---

## 1. Kerberos 101: The Ticket System

Kerberos es el corazón de Active Directory. No es "autenticación HTTP básica": es un **sistema de tickets** donde:

- **Usuario** solicita un **TGT (Ticket Granting Ticket)** al KDC (Key Distribution Center)
- **TGT** es válido por horas (default 10h) y permite solicitar **TGS (Ticket Granting Service)** para servicios
- **TGS** es lo que autoriza acceso a un recurso específico

**Flujo normal:**
```
User → KDC: "Dame TGT con mi contraseña"
KDC → User: "Aquí está TGT (cifrado con krbtgt hash)"
User → KDC: "Quiero TGS para servicio X"
KDC → User: "Aquí está TGS (cifrado con contraseña del servicio)"
User → Servicio X: "Aquí está TGS"
Servicio X: "TGS válido, acceso permitido"
```

**Dónde está el abuso:**
- Si un usuario tiene `PreAuthNotRequired`, **no necesita contraseña para obtener TGT** (AS-REP Roasting)
- Si un servicio tiene **SPN registrado**, puedes pedir TGS sin privilegios especiales (Kerberoasting)
- Si tienes **credenciales de admin**, puedes **replicar todos los hashes del dominio** vía DCSync

---

## 2. AS-REP Roasting (sin preautenticación)

### ¿Qué es?

Normalmente para obtener un TGT necesitas enviar tu contraseña (cifrada). Con `PreAuthNotRequired` deshabilitado, el KDC **emite el TGT sin validar contraseña**.

**Impacto:** El TGT está cifrado con el hash NTLM del usuario. Si tienes el TGT, puedes **crackear el hash offline** (offline brute-force).

### Detección de cuentas vulnerables

```bash
# Con PowerView
Get-DomainUser -UACFilter DONT_REQ_PREAUTH

# Resultado: lista de usuarios donde PreAuthNotRequired=True
```

### Explotación

```bash
# Con Impacket GetNPUsers.py
python3 GetNPUsers.py -dc-ip 10.0.2.10 -usersfile users.txt ATACKCORP/ -format john -outputfile hashes.txt

# Crack con John
john --wordlist=wordlist.txt hashes.txt
```

**Por qué funciona:** Sin preautenticación, obtienes el TGT sin saber la contraseña. El TGT está cifrado con un hash derivado de la contraseña, crackeable offline.

---

## 3. Kerberoasting (SPN Abuse)

### ¿Qué es?

Un **SPN (Service Principal Name)** es un mapeo de servicio a cuenta de usuario (p. ej. `MSSQLSvc/DC-01:1433` → sa account).

**Cualquier usuario autenticado** puede pedir un TGS para un SPN sin privilegios especiales. El TGS está cifrado con el **hash de la contraseña del servicio**.

### Diferencia vs AS-REP

| AS-REP | Kerberoasting |
|--------|---------------|
| TGT sin preauth → cifrado con **usuario hash** | TGS para SPN → cifrado con **servicio hash** |
| No requiere autenticación | Requiere usuario autenticado |
| Rápido (usuario+hash bajo valor) | Lento (servicio+hash alto valor) |

### Explotación

```bash
# Enumerar SPNs
python3 GetUserSPNs.py -dc-ip 10.0.2.10 ATACKCORP/user:pass

# Pedir TGS y guardar
python3 GetUserSPNs.py -dc-ip 10.0.2.10 ATACKCORP/user:pass -request

# Crack
hashcat -m 13100 tgs.txt wordlist.txt
```

---

## 4. DCSync (Domain Controller Replication)

### ¿Qué es?

Un **DC** (Domain Controller) replica credenciales de otros DCs vía **Directory Replication Service (DRS)**. Si tienes permisos de `Replicate Directory Changes`, puedes **simular ser DC** y descargar **todos los hashes del dominio** (incluyendo krbtgt).

### Impacto

Una vez que tienes **krbtgt hash**, puedes:
- Crear **Golden Tickets** (TGT forjado) válidos indefinidamente
- Impersonar cualquier usuario de cualquier dominio
- Persistencia a largo plazo

### Explotación

```bash
# Con Impacket secretsdump.py (desde cuenta con permisos Replicate)
python3 secretsdump.py -dc-ip 10.0.2.10 ATACKCORP/admin:pass@10.0.2.10

# Output: todos los hashes, incluyendo krbtgt
```

---

## 5. Tabla: Equivalencia CS ↔ Sliver

| Operación | Cobalt Strike | Sliver | Notas |
|-----------|---|---|---|
| **AS-REP Roasting** | Impacket via CS | `GetNPUsers.py` (Sliver shell) | Ambos usan Impacket |
| **Kerberoasting** | `shell GetUserSPNs.py` | `GetUserSPNs.py` | Mismo comando |
| **DCSync** | `dcsync` (builtin CS) | `shell secretsdump.py` | CS integrado; Sliver via Python |
| **Crack hashes** | John/Hashcat | John/Hashcat | Same tools |
| **Pass-the-Hash** | `pth` command | `pth` equivalent | Different syntax |

---

## 6. MITRE ATT&CK Mapping

| Táctica | Técnica | ID | Lab-01 |
|---------|---------|----|----|
| Credential Access | OS Credential Dumping | T1003.005 | DCSync |
| Credential Access | Steal or Forge Kerberos Tickets | T1558 | Kerberoasting, AS-REP |
| Lateral Movement | Use Alternate Authentication Material | T1550 | Pass-the-Hash, Pass-the-Ticket |
| Persistence | Forged Web Credentials | T1606 | Golden Ticket |

---

## 7. OPSEC Implications

### AS-REP Roasting
- **Sigiloso:** Solicitudes TGT sin preauth son normales (usuarios sin smartcard)
- **Riesgo:** Volume de requests anómalo es detectable

### Kerberoasting
- **Sigiloso:** Cualquier usuario puede pedir TGS (comportamiento normal)
- **Riesgo:** Múltiples TGS para mismo SPN en poco tiempo → sospechoso

### DCSync
- **Sigiloso:** Si tienes permisos legítimos, es invisible
- **Riesgo:** Sin permisos, replication requests generan alertas (Event 4662, Replication Change Notification)

---

## 8. Key Takeaways

1. **Kerberos no es magia:** Es un sistema de tickets intercambiables. Hashes = poder.
2. **PreAuthNotRequired es peligro:** AS-REP es crackeabilidad garantizada.
3. **Cualquier usuario puede Kerberoast:** No necesitas privilegios, solo autenticación.
4. **DCSync = game over:** Krbtgt hash permite Golden Tickets, persistencia indefinida.
5. **Equivalencia CS/Sliver:** Mismas herramientas (Impacket), sintaxis diferente.

---

*Theory · Lab-01 Ghost Forest · Kerberos Foundation*