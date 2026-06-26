# Emulation Plan — CUSTOM ARSENAL (APT10 / Cloud Hopper)

> **Perfil del actor (clase base, no se repite aquí):** [`APT10.md`](../../../docs/adversaries/APT10.md)
> **Arquetipo:** Concepto / Tradecraft. Describe **cómo APT10 adapta su C2 para operar de forma duradera sin ser detectado**.

---

## Por qué APT10 ancla este lab

APT10 es un actor de **persistencia prolongada** — sus campañas Cloud Hopper duraron meses o años en las redes objetivo. Esa permanencia exige exactamente lo que este lab enseña: un C2 que no llame la atención, tráfico que parezca legítimo, y operaciones que dejen el mínimo rastro posible.

APT10 usó Cobalt Strike como parte de su arsenal en sus campañas más documentadas. El uso de perfiles de comunicación adaptados para reducir la detección es coherente con su doctrina de operaciones largas y discretas.

## Qué es genuino de APT10 y qué es tradecraft del operador

| Elemento del lab | ¿Genuino de APT10? | Matiz |
|------------------|---------------------|-------|
| Cobalt Strike como herramienta | **Sí, documentado** | Parte de su arsenal en campañas enterprise |
| Operaciones de larga duración que requieren C2 discreto | **Sí, doctrina** | Cloud Hopper = meses/años en redes objetivo |
| Malleable C2 profiles específicos | **Tradecraft del operador** | El concepto de C2 adaptado es universal; los perfiles concretos de APT10 no son públicos |
| BOFs como técnica | **Tradecraft del operador** | Técnica estándar de operador avanzado; no atribuida específicamente a APT10 |
| Aggressor scripts de automatización | **Tradecraft del operador** | Workflow de operador; no firma de APT10 |

> El framing es coherente: APT10 necesita un C2 discreto para operar meses en redes vigiladas. La implementación específica (Malleable, BOFs, Aggressor) es tradecraft del operador que encaja con esa necesidad.

## TTPs de APT10 que contextualizan este lab

| Táctica | Técnica | ID | En el lab |
|---------|---------|----|-----------|
| C2 | Application Layer Protocol: Web | T1071.001 | Malleable profile modela el tráfico |
| Defense Evasion | Reflective Code Loading | T1620 | BOFs en proceso del beacon |
| Defense Evasion | Obfuscated Files | T1027 | Perfiles que disfrazan el tráfico |

## Puente narrativo

Custom Arsenal es la **capa de invisibilidad** que hace posible todo lo demás. Labs 13-15 comprometieron MSSQL, establecieron dominancia de dominio y cruzaron forests. Sin un C2 adaptado, ese acceso se habría perdido ante un NTA o un analista de red en los primeros días. APT10 operó durante meses porque sabía hacer esto. Lab-17 (Silent Exit) cierra el ciclo con la exfiltración final.

---

*Emulation Plan · Lab-16 Custom Arsenal · especializa `APT10.md` (anatomía v3.1)*
