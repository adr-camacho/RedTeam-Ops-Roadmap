# Emulation Plan — FOREST REIGN (APT10 / Cloud Hopper)

> **Perfil del actor (clase base, no se repite aquí):** [`APT10.md`](../../../docs/adversaries/APT10.md)
> **Arquetipo:** Operación (A). Este plan emula cómo **APT10 cruza fronteras de forest y organización** siguiendo los trusts.

---

## Por qué APT10 ancla este lab — el encaje más fuerte de Phase-04

Forest Reign es donde APT10 deja de ser vehículo narrativo y se convierte en **el exponente más literal de la técnica**. Cloud Hopper era exactamente esto: saltar de una organización a otra a través de los vínculos de confianza que las conectaban (relaciones MSP-cliente, acuerdos de federación, conexiones de servicio compartido).

En Active Directory, esos vínculos de confianza se llaman **forest trusts**. APT10 cruzaba las fronteras organizativas siguiendo las rutas de servicio; el operador de este lab cruza las fronteras de forest siguiendo los trusts de AD. La analogía no es poética — es estructural.

## Qué es genuino de APT10 y qué es tradecraft universal

| Elemento del lab | ¿Genuino de APT10? | Matiz |
|------------------|---------------------|-------|
| Saltar entre organizations via relaciones de confianza | **Sí, firma del actor** | La esencia documentada de Cloud Hopper |
| Uso de credenciales válidas para cruzar fronteras | **Sí, documentado** | Pass-the-ticket/hash entre orgs |
| Abuso de SID Filtering desactivado | **Tradecraft del operador** | Técnica estándar cuando el trust lo permite |
| Extra SID Attack (child→parent) | **Tradecraft del operador** | Técnica estándar de intra-forest; no firma específica de APT10 |
| Enumeración de trusts (T1482) | **Sí, documentado** | Domain Trust Discovery es parte de su metodología |

> Este lab tiene el encaje más genuino de toda la operación APT10: la técnica (cruzar fronteras de confianza) y la doctrina del actor (Cloud Hopper) son la misma cosa a distinto nivel de abstracción.

## TTPs de APT10 que emula ESTE lab

| Táctica | Técnica | ID | En el lab |
|---------|---------|----|-----------|
| Discovery | Domain Trust Discovery | T1482 | Mapear la cadena de trusts del entorno |
| Lateral Movement | Use Alternate Auth: Pass-the-Ticket | T1550.003 | Cruzar el trust con ticket inter-realm |
| Credential Access | Forge Kerberos Tickets | T1558.001 | Extra SID Attack child→parent |
| Persistence | Valid Accounts (cross-forest) | T1078.002 | Acceso con cuentas válidas del dominio confiado |

## Puente narrativo

Forest Reign es el clímax técnico de APT10 en Phase-04. Tras entrar por MSSQL (Lab-13) y consolidar en el dominio (Lab-14), aquí APT10 demuestra la capacidad que define Cloud Hopper: cruzar de un dominio a otro, de un forest a otro, siguiendo la cadena de confianza hasta comprometer el perímetro completo de la organización. El Lab-18 (Final Verdict) lo integrará todo en una operación de extremo a extremo.

---

*Emulation Plan · Lab-15 Forest Reign · especializa `APT10.md` — Cloud Hopper a nivel AD (anatomía v3.1)*
