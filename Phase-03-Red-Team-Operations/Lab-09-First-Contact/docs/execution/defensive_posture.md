# Módulo 2 · ¿Qué me vigila? (NODO CRÍTICO) — Lab-09 FIRST CONTACT

> **Módulo 2 de 5 · Árbol de decisión de la primera hora**
>
> **Objetivo:** Enumerar el escudo ANTES de cualquier acción ofensiva: AV/Defender, AMSI, EDR, Constrained Language Mode, AppLocker/WDAC, Sysmon.
>
> **Prerequisito:** módulo 1 (saber con qué privilegios enumeras).
>
> **Habilita:** la decisión de qué TTPs puedes permitirte en el resto del lab y en Labs 10-12.
>
> **TTP:** T1518.001 · T1518

## Comandos núcleo

`Get-MpComputerStatus` · `$ExecutionContext.SessionState.LanguageMode` · `Get-AppLockerPolicy` · Seatbelt -group=system · check Sysmon. **Este resultado dicta toda tu estrategia.**

## Observaciones (completar al ejecutar)

> Captura aquí lo que revela el entorno CRTO real al ejecutar este módulo: salidas, hallazgos, decisiones.

---

*Módulo 2/5 · Lab-09 First Contact · playbook de Situational Awareness (anatomía v3.1)*
