# Emulation Plan — IRON VEIL (Lazarus Group)

> **Perfil del actor (clase base, no se repite aquí):** [`Lazarus.md`](../../../docs/adversaries/Lazarus.md)
> **Arquetipo:** Concepto / Tradecraft. Describe **cómo razona Lazarus al operar bajo control de aplicaciones**.

---

## Por qué Lazarus ancla este lab

Lazarus combina dos estrategias documentadas que conectan directamente con este lab:

- **Living-off-the-land combinado con binarios propios** — mezcla utilidades legítimas del SO (LOLBAS) con su malware para reducir huella y dificultar la detección por firma. Es una práctica documentada de su tradecraft.
- **Reducción de huella en entornos vigilados** — en entornos con controles más estrictos, Lazarus adapta su ejecución hacia técnicas que abusan de lo que el sistema ya confía.

Aquí, sin embargo, la honestidad obliga a una distinción: AppLocker como control específico no es una técnica que MITRE documente como prominente en Lazarus (su evasión se centra más en ETW/AMSI/packing, terreno de Lab-11). Lo que sí es genuino es la **mentalidad de operar con lo que el entorno permite** — el principio LOLBAS como filosofía de reducción de huella.

## Qué es genuino de Lazarus y qué es tradecraft universal

| Elemento del lab | ¿Genuino de Lazarus? | Matiz |
|------------------|----------------------|-------|
| Living-off-the-land (LOLBAS) | **Sí, documentado** | Combina binarios propios con utilidades del SO |
| Reducción de huella en entornos vigilados | **Coherente con su doctrina** | Mentalidad documentada de adaptación al entorno |
| Bypass de AppLocker específico | **Tradecraft universal** | No es técnica firma de Lazarus; lo usan muchos actores |
| Evasión de CLM | **Tradecraft universal** | Técnica estándar de operador en entornos restringidos |

> El lab honesto sobre su framing: Lazarus encarna la **filosofía LOLBAS** (usar lo que el sistema ya tiene), aunque el control de aplicaciones específico no es su seña más documentada. El vehículo narrativo es coherente, no literal como en Lab-11.

## TTPs de Lazarus que contextualizan ESTE lab

| Táctica | Técnica | ID | En el lab |
|---------|---------|----|--------------|
| Defense Evasion | System Binary Proxy Execution (LOLBAS) | T1218 | El terreno permitido bajo AppLocker |
| Defense Evasion | Obfuscated Files / LOLBAS mentality | T1027 | Reducir huella usando lo que el SO confía |
| Execution | Command and Scripting Interpreter | T1059 | Ejecución adaptada al entorno restringido |

> Repertorio completo en [`Lazarus.md`](../../../docs/adversaries/Lazarus.md).

## Puente narrativo

Iron Veil cierra Phase-03. Tras dominar la evasión de Defender/AMSI/ETW (Lab-11), aquí el operador enfrenta la segunda capa de control: qué puede ejecutar. Labs 11+12 forman el bloque de Defense Evasion que Phase-04 (APT10/Cloud Hopper) da por supuesto al operar a escala enterprise — en un entorno real, ambas capas coexisten.

---

*Emulation Plan · Lab-12 Iron Veil · especializa `Lazarus.md` (anatomía v3.1)*
