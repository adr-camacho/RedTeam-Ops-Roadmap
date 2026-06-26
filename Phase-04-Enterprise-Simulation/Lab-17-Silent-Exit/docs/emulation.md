# Emulation Plan — SILENT EXIT (APT10 / Cloud Hopper)

> **Perfil del actor (clase base, no se repite aquí):** [`APT10.md`](../../../docs/adversaries/APT10.md)
> **Arquetipo:** Operación (A). Este plan emula cómo **APT10 exfiltra datos y cierra su presencia** en una operación enterprise prolongada.

---

## Por qué APT10 ancla este lab — exfil documentada con precisión

La exfiltración de APT10 en las campañas Cloud Hopper está documentada con detalle inusual:

- **RAR con contraseña** para comprimir y cifrar los datos robados antes de la extracción.
- **Dropbox (dbxcli)** como canal de exfiltración — tráfico HTTPS hacia un dominio de confianza ampliamente permitido.
- **Staging local** antes de exfiltrar — los datos se acumulan en un directorio temporal del host comprometido antes de salir.

Este lab es donde el emulation plan de APT10 es **más literal de toda Phase-04**: las técnicas que describe el `technique.md` (RAR cifrado + servicios cloud legítimos) son exactamente las documentadas en los informes de Cloud Hopper.

## Qué es genuino de APT10 y qué es tradecraft universal

| Elemento del lab | ¿Genuino de APT10? | Matiz |
|------------------|---------------------|-------|
| RAR cifrado para staging | **Sí, firma documentada** | Método explícito en informes de Cloud Hopper |
| Exfiltración vía Dropbox (dbxcli) | **Sí, documentado** | T1567 atribuido directamente a APT10 |
| Data hunting en shares de red | **Sí, documentado** | Recolección de datos de negocio e IP |
| DNS tunneling / C2 exfil | **Tradecraft universal** | APT10 prefería cloud; otras vías son del operador |
| Reporting del engagement | **Marco didáctico** | El reporte es un entregable de consultoría, no una TTP del actor |

> Este es el lab donde la emulación es más fiel: RAR + Dropbox es la firma de Cloud Hopper en la fase de exfiltración. No hay que forzar nada.

## TTPs de APT10 que emula ESTE lab

| Táctica | Técnica | ID | En el lab |
|---------|---------|----|-----------|
| Collection | Archive Collected Data | T1560 | RAR cifrado con contraseña |
| Exfiltration | Exfiltration over Web Service: Cloud Storage | T1567.002 | Dropbox (dbxcli) |
| Collection | Data from Network Shared Drives | T1039 | Data hunting en shares |
| Defense Evasion | Indicator Removal | T1070 | Limpieza de artefactos al salir |

## Puente narrativo

Silent Exit es el cierre de Cloud Hopper. Tras meses de acceso (Labs 13-16), APT10 extrae los datos de alto valor, limpia su presencia y desaparece. El reporte del engagement es el equivalente del operador al "paquete" que APT10 envía a sus controladores: la evidencia de lo conseguido. Lab-18 (Final Verdict) pondrá a prueba toda la cadena en condiciones de examen.

---

*Emulation Plan · Lab-17 Silent Exit · especializa `APT10.md` — RAR + Dropbox = APT10 documentado (anatomía v3.1)*
