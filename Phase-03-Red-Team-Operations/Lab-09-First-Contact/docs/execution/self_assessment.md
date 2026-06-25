# Módulo 1 · ¿Quién soy? — Lab-09 FIRST CONTACT

> ### Árbol de decisión de la primera hora (playbook de recon)
> ```
> 1 self_assessment  →  2 defensive_posture  →  3 host_context  →  4 network_domain  →  5 decision_point
>    ¿quién soy?         ¿qué me vigila?         ¿qué hay           ¿qué dominio,        ¿primer movimiento
>                        (NODO CRÍTICO)          alrededor?          sigiloso?            seguro? qué NO tocar
> ```
> **Lectura:** esto NO es una kill-chain — es la **secuencia de lectura del terreno** que ejecutas en cada baliza.
> El módulo 2 (postura defensiva) condiciona los módulos 3-5: lo que veas que te vigila decide qué puedes permitirte.

> **Módulo 1 de 5 · Árbol de decisión de la primera hora**
>
> **Objetivo:** Establecer tu propia posición: identidad, grupos, **privilegios** (SeDebug/SeImpersonate), nivel de integridad, ¿local admin/SYSTEM?, ¿workstation o server?
>
> **Prerequisito:** baliza recién aterrizada.
>
> **Habilita:** el contexto para interpretar el resto del recon.
>
> **TTP:** T1033 · T1082

## Comandos núcleo

`whoami /all` · `getuid` / `getprivs` (Sliver) · integridad y privilegios primero, es lo más barato y silencioso.

## Observaciones (completar al ejecutar)

> Captura aquí lo que revela el entorno CRTO real al ejecutar este módulo: salidas, hallazgos, decisiones.

---

*Módulo 1/5 · Lab-09 First Contact · playbook de Situational Awareness (anatomía v3.1)*
