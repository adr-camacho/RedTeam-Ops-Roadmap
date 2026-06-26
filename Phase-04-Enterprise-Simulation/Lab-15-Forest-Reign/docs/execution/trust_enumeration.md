# Módulo M1 · Enumeración de trusts — mapear el territorio — Lab-15 FOREST REIGN

> ### Mapa de la operación (kill-chain cross-forest — Cloud Hopper en AD)
> ```
>   M1 Trust enum   →  M2 Intra-forest    →  M3 Cross-forest    →  M4 Validar +
>   (cadena, SID        child→parent           (si trust inter-       consolidar
>    Filtering)         Extra SID Attack        forest abusable)
> ```
> **Lectura:** M1 mapea el terreno; M2 es el ataque más rentable (siempre disponible en multi-dominio);
> M3 es el salto entre forests si el trust lo permite. El camino lo define la cadena de trusts mapeada en M1.
> ⚠ **Arquetipo operación:** `execution/` es el **PLAN de ataque**.

> **Módulo M1 · Ruta: `[crítica]`**
>
> **Objetivo único:** Mapear la cadena de trusts completa del entorno: qué dominios/forests existen, dirección de cada trust, si SID Filtering está activo en cada tramo.
>
> **Prerequisito real:** baliza en cualquier dominio del entorno.
>
> **Habilita:** el mapa completo del lateral enterprise — qué caminos existen y cuáles son abusables.
>
> **TTP:** T1482

## Plan de ejecución

PowerView: `Get-DomainTrust` en cada dominio con baliza. `nltest /domain_trusts`. Verificar `TrustAttributes` para QUARANTINED (SID Filtering activo). Dibujar el grafo de trusts antes de actuar.

## Operativa real (completar al ejecutar)

> ⚠ Arquetipo operación: PLAN. Captura aquí la cadena de trusts real, los SIDs usados, los flags cruzados.

---

*Módulo M1 · Lab-15 Forest Reign · Cloud Hopper en AD (anatomía v3.1, arquetipo operación)*
