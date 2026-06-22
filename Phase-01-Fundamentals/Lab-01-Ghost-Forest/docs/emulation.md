# Emulation Plan — GHOST FOREST (APT29)

> **Perfil del actor (clase base, no se repite aquí):** [`APT29.md`](../../../docs/adversaries/APT29.md)
> **Capability del lab (eje didáctico):** Primera kill-chain AD limpia: roasting → foothold → DCSync → Domain Admin.

## TTPs de APT29 que emula ESTE lab

| TTP | MITRE ID | Por qué encaja con el objetivo del lab |
|-----|----------|-----------------------------------------|
| AS-REP Roasting | T1558.004 | Credencial inicial sin pre-auth — punto de entrada de la cadena |
| Kerberoasting | T1558.003 | Tickets de servicio → crackeo offline para escalar |
| DCSync | T1003.006 | Replicación de credenciales del DC → control del dominio |
| Golden Ticket | T1558.001 | Forja de TGT con krbtgt — persistencia de dominio |
| Pass-the-Hash | T1550.002 | Reutilización de credenciales para movimiento lateral |

## Mapeo a comportamiento/campaña real

APT29 opera con sigilo hacia control de dominio reutilizando y forjando material de autenticación legítimo. La cadena del lab reproduce ese avance disciplinado hasta DA, priorizando credenciales sobre exploits ruidosos.

> **Nota de los dos ejes.** Kerberoasting, DCSync y la forja de tickets son TTP documentadas de APT29. Golden Ticket y PtH son técnicas estándar del temario CRTO; APT29 aporta el escenario de avance silencioso.

---

*Emulation Plan v1.0 · especializa el perfil de APT29 · ver `docs/STANDARDS.md §5`*
