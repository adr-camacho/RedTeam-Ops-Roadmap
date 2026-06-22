# Emulation Plan — DARK GATE (APT29)

> **Perfil del actor (clase base, no se repite aquí):** [`APT29.md`](../../../docs/adversaries/APT29.md)
> **Capability del lab (eje didáctico):** Abuso de ADCS (ESC1/ESC4/ESC8) — forja/abuso de certificados.

## TTPs de APT29 que emula ESTE lab

| TTP | MITRE ID | Por qué encaja con el objetivo del lab |
|-----|----------|-----------------------------------------|
| Steal or Forge Authentication Certificates | T1649 | Núcleo del lab — emisión/abuso de certificados (ESC1/4) |
| Forced Authentication | T1187 | Coacción de autenticación hacia el relay (ESC8) |
| Adversary-in-the-Middle: LLMNR/NBT-NS | T1557 | NTLM relay hacia el endpoint de certificados |
| File and Directory Permissions Modification | T1222 | Abuso de plantillas/permisos de la CA |

## Mapeo a comportamiento/campaña real

APT29 destaca por forjar material de confianza (Golden SAML, abuso de certificados/federación). El lab reproduce esa mentalidad sobre ADCS: obtener un certificado de autenticación que permite suplantar identidades de dominio.

> **Nota de los dos ejes.** La forja de certificados (T1649) es coherente con el tradecraft de APT29. Los ESC concretos (ESC1/4/8) y el relay los fija el temario CRTO.

---

*Emulation Plan v1.0 · especializa el perfil de APT29 · ver `docs/STANDARDS.md §5`*
