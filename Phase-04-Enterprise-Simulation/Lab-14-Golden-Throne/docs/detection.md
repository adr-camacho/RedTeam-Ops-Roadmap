# Detection — Lab-14 Golden Throne

> **Capability:** detección de tickets forjados, persistencia de dominio (DSRM, AdminSDHolder, certs).
> **Arquetipo:** Operación · **Adversario:** APT10 · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

---

## 1. Detección de Golden Ticket

- **Event 4769** (TGS request) con cuenta que no tiene TGT previo en el DC (el ticket viene de la nada).
- Campos del ticket con valores anómalos: duración de vida >10h, grupos no estándar.
- **Honeypot accounts:** cuentas con nombres atractivos (Administrator, krbtgt-old) que nunca se usan — cualquier uso es alerta.
- Solución definitiva: rotación de krbtgt **dos veces** con intervalo >10h.

## 2. Detección de Silver Ticket

- Acceso a servicio **sin Event 4768/4769** previo en el DC (el TGS no pasó por el KDC).
- Anomalías en el PAC del ticket (campos que no coinciden con los del AD).
- Más difícil de detectar que el Golden porque no genera tráfico hacia el DC.

## 3. Detección de Diamond Ticket

- Más difícil que Golden/Silver: el TGT es structuralmente válido (viene del DC real).
- Buscar discrepancias entre grupos en el ticket y grupos reales del usuario en AD.
- EDR con validación de PAC en tiempo real puede detectar la modificación.

## 4. Detección de DSRM

- **Clave de registro** `DsrmAdminLogonBehavior = 2` — cambio inusual y raramente legítimo.
- **Event 4776** (autenticación NTLM) desde la cuenta DSRM del DC fuera de modo de restauración.
- **Sysmon Event 13** sobre la clave de registro DSRM.

## 5. Detección de AdminSDHolder

- **Event 4662** sobre el objeto AdminSDHolder — modificaciones sobre este objeto son raras y sospechosas.
- Cambios de ACL en el AdminSDHolder (auditoría de objetos del directorio).
- Monitorizar el proceso SDProp (que se ejecuta cada hora y propaga las ACLs).

## 6. Detección de certificados forjados

- Nuevos certificados emitidos para cuentas con privilegios altos (monitorizar la CA).
- Autenticación con certificado para cuentas que normalmente usan contraseña/Kerberos.
- Ver `detection.md` de Lab-03 para la detección específica de ADCS abuse.

## 7. Reglas de ejemplo (concepto)

- **Sigma:** Event 4769 sin 4768 precedente en ventana de tiempo (Silver Ticket).
- **Sigma:** modificación de `DsrmAdminLogonBehavior` en registro del DC.
- **KQL:** cambios de ACL sobre `CN=AdminSDHolder,CN=System`.
- **CA Audit:** emisión de certificados para cuentas DA/EA.

---

## Limitaciones y evasión

| Detección | Cómo se evade | Profundiza en |
|-----------|---------------|----------------|
| Anomalías en Golden Ticket | Diamond Ticket (TGT estructuralmente válido) | este lab |
| Event 4769 para Silver Ticket | Uso selectivo, no masivo | este lab |
| Monitorización de DSRM | Si la política no existe, no hay alerta | este lab |
| AdminSDHolder SDProp | Difícil de evadir si hay auditoría del objeto | — |

---

*Detection · Lab-14 Golden Throne · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
