# Emulation Plan — GOLDEN THRONE (APT10 / Cloud Hopper)

> **Perfil del actor (clase base, no se repite aquí):** [`APT10.md`](../../../docs/adversaries/APT10.md)
> **Arquetipo:** Operación (A). Este plan emula cómo **APT10 establece persistencia de dominio robusta** en una operación enterprise.

---

## La honestidad técnica más importante de Phase-04

Este lab requiere una declaración explícita antes de cualquier otra cosa: **Golden Tickets y Diamond Tickets son técnicas firma de APT29 (Cozy Bear)**, no de APT10. APT29 es el exponente más documentado y sofisticado del abuso de krbtgt para persistencia de dominio.

APT10 **sí usa** persistencia de dominio (credenciales válidas, cuentas legítimas, tareas programadas), pero los mecanismos Kerberos avanzados de este lab son tradecraft del operador más que firma de APT10.

Dicho esto, APT10 es el vehículo narrativo correcto para Phase-04 por dos razones:
1. Sus operaciones Cloud Hopper tenían **acceso prolongado a dominios enterprise** — necesariamente usaron alguna forma de persistencia de dominio.
2. El contexto de la operación (enterprise a escala, multi-dominio) es coherente con APT10.

El `emulation.md` honesto es más valioso que uno que fuerza una atribución falsa.

## Qué es genuino de APT10 y qué es tradecraft de otros actores

| Elemento del lab | ¿Genuino de APT10? | Matiz |
|------------------|---------------------|-------|
| Persistencia prolongada en dominio | **Coherente con su doctrina** | Cloud Hopper = acceso meses/años |
| Credenciales válidas + cuentas legítimas | **Sí, documentado** | Su método principal de persistencia |
| Golden / Diamond Tickets | **Tradecraft del operador** | Exponente real: APT29. Aquí es técnica estándar de CRTO |
| Forged ADCS certs | **Tradecraft del operador** | Muchos actores avanzados lo usan; no firma de APT10 |
| DSRM backdoor | **Tradecraft del operador** | Técnica de operador avanzado, no atribuida a APT10 específicamente |
| AdminSDHolder | **Tradecraft del operador** | Técnica de persistencia silenciosa, no firma APT10 |

> **Por qué importa declararlo:** un revisor técnico de Tarlogic o Zerolynx que lea que APT10 "usa Golden Tickets como firma" detectaría el error. Declarar "Golden/Diamond son exponente APT29; aquí APT10 es el vehículo narrativo de la operación enterprise" muestra rigor. Es la diferencia entre un emulation plan creíble y uno decorativo.

## TTPs de APT10 que contextualizan el lab

| Táctica | Técnica | ID | En el lab |
|---------|---------|----|-----------|
| Persistence | Valid Accounts (domain) | T1078.002 | Acceso durable vía cuentas legítimas comprometidas |
| Persistence | Create Account | T1136 | Backdoor de cuenta de dominio |
| Credential Access | OS Credential Dumping (DCSync) | T1003.006 | Obtención del hash krbtgt para Golden Ticket |

> Los Golden/Diamond/Silver Tickets y los demás mecanismos de este lab son **técnicas CRTO estándar** que el operador necesita conocer. El lab las enseña con APT10 como marco narrativo de la operación enterprise, no como atribución forzada.

## Puente narrativo

Golden Throne es el **momento de consolidación** de Phase-04. Tras entrar por MSSQL (Lab-13), aquí APT10 cierra su posición en el dominio. Cloud Hopper no era una campaña de smash-and-grab — era acceso prolongado meses o años. La persistencia de dominio es lo que hace posible esa permanencia, sea cual sea el mecanismo técnico exacto.

---

*Emulation Plan · Lab-14 Golden Throne · especializa `APT10.md` — persistencia de dominio con honestidad técnica (anatomía v3.1)*
