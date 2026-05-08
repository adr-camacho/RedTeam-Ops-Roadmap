# Lab 01: Attackitive Directory (TryHackMe)

## 📝 Resumen Ejecutivo
Simulación de un ataque dirigido contra un controlador de dominio Windows basado en vulnerabilidades de configuración comunes en Active Directory. El objetivo final es el compromiso total del dominio (Domain Admin).

## 🛰️ Fases del Ataque

### 1. Enumeración y Reconocimiento
* **Protocolos detectados:** SMB (445), Kerberos (88), RPC (135).
* **Herramientas:** `Enum4linux-ng`, `nmap`.
* **Hallazgo clave:** Descubrimiento de nombres de usuario mediante la enumeración de SID y listas de nombres comunes.

### 2. Acceso Inicial
* **Técnica:** **AS-REP Roasting**.
* **Descripción:** Aprovechamiento de usuarios con la propiedad `Do not require Kerberos preauthentication` activa.
* **Herramienta:** `GetNPUsers.py` (Impacket).
* **Resultado:** Hash obtenido y crackeado mediante `hashcat` (Modo 18200).

### 3. Movimiento Lateral y Escalada de Privilegios
* **Técnica:** Enumeración de comparticiones SMB y extracción de credenciales en archivos de configuración / SYSVOL.
* **Abuso de Secretos:** Uso de `secretsdump.py` para realizar un ataque de **Pass-the-Hash** tras obtener el hash NT del Administrador.

---

## 🛡️ Detección y Mitigación (Blue Team Notes)
1.  **Mitigación:** Asegurar que ningún usuario tenga activa la preautenticación de Kerberos deshabilitada.
2.  **Detección:** Monitorizar eventos de Windows ID 4768 (Solicitud de TGT) sospechosos, especialmente aquellos que no requieren preautenticación.
3.  **Hardenning:** Implementar contraseñas robustas para mitigar ataques de fuerza bruta offline sobre hashes Kerberos.

---
**Attack Path Visual:**
`Recon` ➔ `AS-REP Roasting` ➔ `SMB Enumeration` ➔ `PrivEsc` ➔ `Domain Admin`