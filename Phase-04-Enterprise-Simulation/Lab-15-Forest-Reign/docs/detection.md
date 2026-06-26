# Detection — Lab-15 Forest Reign

> **Capability:** detección de abuso de trusts, Extra SID Attack y lateral cross-forest.
> **Arquetipo:** Operación · **Adversario:** APT10 · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

---

## 1. Detección de enumeración de trusts

- **Event 4769 / LDAP:** consultas a objetos `trustedDomain` desde cuentas de usuario normal.
- `nltest /domain_trusts` ejecutado por una cuenta de usuario no-admin (Sysmon Event 1).
- PowerShell Script Block (4104) con `Get-DomainTrust` o similares.

## 2. Detección de Extra SID Attack (child→parent)

- **Event 4769** en el DC del dominio padre con un TGT que contiene SIDs de Enterprise Admins procedentes de un dominio hijo.
- Análisis del PAC del ticket: SIDs en el campo `ExtraSids` que corresponden a grupos del dominio padre pero emitidos desde el dominio hijo.
- Acceso a recursos del dominio padre desde cuentas del dominio hijo sin tráfico Kerberos normal previo.

## 3. Detección de lateral cross-forest

- **Inter-realm TGT** (ticket con referral hacia otro forest): el KDC del dominio origen emite un ticket de referencia — Event 4768 con campos de dominio distintos al local.
- Acceso a recursos del forest B desde el forest A con tickets que provienen de un forest diferente.
- **SID Filtering:** si está activo y se produce un intento de incluir SIDs filtrados, el KDC genera un evento de rechazo.

## 4. Señales de SID History abuse

- Usuarios con atributo `SIDHistory` poblado con SIDs de grupos privilegiados de otro dominio.
- Event 4765 / 4766 (SID History añadido a cuenta).
- Tickets de autenticación que incluyen SIDs de grupos privilegiados de dominios externos.

## 5. Reglas de ejemplo (concepto)

- **Sigma:** Event 4769 con ExtraSids conteniendo SIDs de EA/DA del dominio padre emitido desde DC hijo.
- **Sigma:** `nltest.exe` ejecutado por usuario no-admin.
- **KQL:** inter-realm tickets (campos de referral) en tiempo fuera del horario normal de administración.

---

## Limitaciones y evasión

| Detección | Cómo se evade | Profundiza en |
|-----------|---------------|----------------|
| Análisis PAC del ticket | Diamond Ticket con estructura válida | Lab-14 |
| Event 4769 con SIDs anómalos | Uso de cuentas legítimas ya comprometidas del forest destino | — |
| nltest / Get-DomainTrust | Consultas LDAP directas sin herramientas conocidas | Lab-09 (recon sigiloso) |

---

*Detection · Lab-15 Forest Reign · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
