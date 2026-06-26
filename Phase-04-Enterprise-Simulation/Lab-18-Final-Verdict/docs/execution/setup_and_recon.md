# Módulo M1 · Setup C2 + Recon (Horas 0-2) — Lab-18 FINAL VERDICT

> ### La operación completa (capstone — integra Labs 08-17)
> ```
>   HORA 0-2   HORA 2-6        HORA 6-16           HORA 16-36          HORA 36-48
>   Baliza +   Escalada +      Lateral de           Domain              Exfil +
>   Recon SA   Persistencia    dominio: Kerb,       Dominance +         Cleanup +
>   (L09,L10)  (L10)           ACL, MSSQL, Trust    Persistence         Report
>                              (L04-06, L13, L15)   (L14, L15)          (L17)
> ```
> **Timeline orientativo para el examen CRTO (48h, 6 flags mínimos).**
> La cadena exacta depende del entorno — el árbol de decisión de Lab-09 la define.
> ⚠ **Arquetipo operación:** `execution/` es el **PLAN integrador**.

> **Módulo M1 · Ruta: `[crítica · base de todo]`**
>
> **Objetivo único:** Montar el C2 operativo (Lab-08), aterrizar la baliza, ejecutar el árbol de decisión de la primera hora (Lab-09): SA, postura defensiva, recon de dominio y decisión de primer movimiento.
>
> **Prerequisito real:** acceso al entorno del examen.
>
> **Habilita:** imagen completa del terreno + primer movimiento seguro decidido.
>
> **TTP:** T1033 · T1082 · T1518.001

## Plan de ejecución

Lab-08: beacon activo, listener configurado, OPSEC básico. Lab-09: whoami/all → Defender/AMSI/CLM → procesos y sesiones → trusts y DCs → decisión. NO actuar ofensivamente hasta tener la imagen completa.

## Operativa real (completar durante el capstone / examen)

> ⚠ Este módulo es el PLAN integrador. Captura aquí la operativa real: timestamps, credenciales obtenidas, flags capturados, decisiones tomadas. Es la materia prima del reporte.

---

*Módulo M1 · Lab-18 Final Verdict · cadena completa (anatomía v3.1, arquetipo operación integrador)*
