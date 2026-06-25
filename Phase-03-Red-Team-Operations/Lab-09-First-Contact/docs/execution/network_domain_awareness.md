# Módulo 4 · ¿Qué dominio? (SIGILOSO) — Lab-09 FIRST CONTACT

> **Módulo 4 de 5 · Árbol de decisión de la primera hora**
>
> **Objetivo:** Conciencia de red y dominio con OPSEC: red local alcanzable (arp/netstat/rutas), DCs, **trusts** (insumo Phase-04), tus derechos en el dominio. Decidir si lanzar BloodHound ya o no.
>
> **Prerequisito:** módulo 2 (la postura defensiva decide si SharpHound es viable o suicidio OPSEC).
>
> **Habilita:** el mapa de hacia dónde moverte y qué trusts existen (Phase-04).
>
> **TTP:** T1016 · T1018 · T1482 · T1069.002

## Comandos núcleo

`ipconfig /all` · `arp -a` · `nltest /domain_trusts` · recon AD **dirigido** primero; mapeo masivo solo si la postura defensiva lo permite.

## Observaciones (completar al ejecutar)

> Captura aquí lo que revela el entorno CRTO real al ejecutar este módulo: salidas, hallazgos, decisiones.

---

*Módulo 4/5 · Lab-09 First Contact · playbook de Situational Awareness (anatomía v3.1)*
