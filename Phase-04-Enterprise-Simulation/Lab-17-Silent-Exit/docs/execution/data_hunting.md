# Módulo M1 · Data Hunting — localizar el valor — Lab-17 SILENT EXIT

> ### Mapa de la operación (kill-chain exfiltración — Cloud Hopper exit)
> ```
>   M1 Data Hunting   →  M2 Staging         →  M3 Exfiltración   →  M4 Salida limpia
>   (localizar valor      (RAR cifrado,          (cloud legítimo        + reporte
>    en shares)           fragmentar)            u otro canal)
> ```
> **Lectura:** kill-chain de cierre del engagement. M1 localiza; M2 empaqueta; M3 exfiltra; M4 cierra.
> APT10 documentado: RAR cifrado (M2) + Dropbox vía dbxcli (M3).
> ⚠ **Arquetipo operación:** `execution/` es el **PLAN**.

> **Módulo M1 · Ruta: `[crítica]`**
>
> **Objetivo único:** Identificar y localizar los datos de alto valor en el entorno: shares accesibles, contenido sensible (credenciales, IP, datos de negocio), bases de datos expuestas.
>
> **Prerequisito real:** acceso con credenciales de DA o equivalente (Labs 13-15).
>
> **Habilita:** lista de objetivos de datos con su ubicación — el inventario de qué exfiltrar.
>
> **TTP:** T1039 · T1135

## Plan de ejecución

PowerView: `Find-DomainShare -CheckShareAccess` + `Find-InterestingDomainShareFile`. Acceso dirigido a shares de Finance, HR, IT. SQL: consultas de datos sensibles en instancias comprometidas (Lab-13). Inventariar: nombre del share, ruta, tipo de dato, volumen estimado.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: PLAN. Captura aquí los shares encontrados, el método de staging, el canal de exfil usado y los artefactos limpiados.

---

*Módulo M1 · Lab-17 Silent Exit · Cloud Hopper exit (anatomía v3.1, arquetipo operación)*
