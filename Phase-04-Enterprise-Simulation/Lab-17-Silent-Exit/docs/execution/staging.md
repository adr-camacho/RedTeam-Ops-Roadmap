# Módulo M2 · Staging — empaquetar con RAR cifrado — Lab-17 SILENT EXIT

> **Módulo M2 · Ruta: `[crítica]`**
>
> **Objetivo único:** Comprimir y cifrar los datos objetivo con RAR/7z para que el DLP no pueda inspeccionar el contenido. Fragmentar si el volumen supera umbrales de DLP de red.
>
> **Prerequisito real:** M1 (datos objetivo identificados y localizados).
>
> **Habilita:** archivo(s) listo(s) para exfiltrar — opacos al DLP.
>
> **TTP:** T1560

## Plan de ejecución

`7z a -p<password> -mhe=on loot.7z <directorio_objetivo>`. Fragmentar si necesario: `7z a -v50m loot.7z ...`. Guardar en directorio temporal (no en el share origen). APT10 documentado: RAR con contraseña fue su método.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: PLAN. Captura aquí los shares encontrados, el método de staging, el canal de exfil usado y los artefactos limpiados.

---

*Módulo M2 · Lab-17 Silent Exit · Cloud Hopper exit (anatomía v3.1, arquetipo operación)*
