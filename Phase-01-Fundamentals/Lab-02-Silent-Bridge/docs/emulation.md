# Emulation Plan — SILENT BRIDGE (APT41)

> **Perfil del actor (clase base, no se repite aquí):** [`APT41.md`](../../../docs/adversaries/APT41.md)
> **Capability del lab (eje didáctico):** Acceso vía exploit de aplicación expuesta → pivotaje → session passing.

## TTPs de APT41 que emula ESTE lab

| TTP | MITRE ID | Por qué encaja con el objetivo del lab |
|-----|----------|-----------------------------------------|
| Exploit Public-Facing Application | T1190 | Vector de entrada — firma operativa de APT41 |
| Multi-hop Proxy / Pivoting | T1090 | Pivotar entre segmentos hacia la red interna |
| Protocol Tunneling | T1572 | Túnel (Ligolo-ng) para alcanzar segmentos no enrutados |
| OS Credential Dumping: LSASS | T1003.001 | Credenciales para el salto lateral |
| Scheduled Task | T1053.005 | Persistencia en el host pivote |

## Mapeo a comportamiento/campaña real

APT41 entra por tecnología expuesta a internet y pivota en profundidad entre sistemas (incl. Windows↔Linux) usando proxies multi-hop. El lab reproduce exactamente ese patrón: entrada por servicio vulnerable y pivote encadenado hacia el objetivo.

> **Nota de los dos ejes.** Aquí el actor y la capability coinciden de verdad: T1190 → pivotaje es la firma documentada de APT41, no solo piel. El stack concreto (Ligolo-ng, el exploit) lo fija el temario.

---

*Emulation Plan v1.0 · especializa el perfil de APT41 · ver `docs/STANDARDS.md §5`*
