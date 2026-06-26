# Módulo M4 · Salida limpia + reporte — Lab-17 SILENT EXIT

> **Módulo M4 · Ruta: `[crítica]`**
>
> **Objetivo único:** Eliminar artefactos de staging y herramientas dejadas en los hosts; cerrar beacons ordenadamente; documentar qué se limpió y qué quedó; producir el reporte/timeline del engagement.
>
> **Prerequisito real:** M3 (datos exfiltrados y verificados).
>
> **Habilita:** cierre del engagement con la menor superficie de detección posible + entregable de reporte.
>
> **TTP:** T1070

## Plan de ejecución

1. Eliminar archivos de staging temporales. 2. Cerrar beacons (no crash). 3. No borrar Event Logs (es detectable y contraproducente). 4. Documentar en el reporte: timeline de la operación, credenciales obtenidas, sistemas comprometidos, datos exfiltrados, artefactos dejados/limpiados, recomendaciones.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: PLAN. Captura aquí los shares encontrados, el método de staging, el canal de exfil usado y los artefactos limpiados.

---

*Módulo M4 · Lab-17 Silent Exit · Cloud Hopper exit (anatomía v3.1, arquetipo operación)*
