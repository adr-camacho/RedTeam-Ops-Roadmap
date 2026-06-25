# Emulation Plan — BLACK BEACON (Lazarus Group)

> **Perfil del actor (clase base, no se repite aquí):** [`Lazarus.md`](../../../docs/adversaries/Lazarus.md)
> **Arquetipo:** Concepto / Tradecraft. Este `emulation.md` no describe una intrusión: describe **cómo razona Lazarus al montar y operar su C2**, y qué de eso adoptas tú al construir tu kit.

---

## Por qué Lazarus ancla este lab

Lab-08 enseña los **fundamentos del modelo de operador C2**. Lazarus es el ancla natural de Phase-03 porque su tradecraft *es* el C2 a medida: opera con backdoors y RATs propios (FALLCHILL, MATA, BLINDINGCAN) sobre canales HTTP/HTTPS, y **rota su infraestructura constantemente** para evadir bloqueos por IOC. Montar un team server, configurar listeners y afinar el perfil de baliza es exactamente la disciplina que un actor como Lazarus domina antes de tocar a una víctima.

## Qué es genuino de Lazarus (documentado) y qué es tradecraft universal

La honestidad técnica importa: no todo lo que enseña este lab es "firma" de Lazarus. Separémoslo.

| Elemento del lab | ¿Genuino de Lazarus? | Matiz |
|------------------|----------------------|-------|
| C2 propio sobre HTTP/HTTPS | **Sí, documentado** | Su arsenal de RATs usa canales web custom (T1071.001). |
| Rotación de infraestructura C2 | **Sí, documentado** | Infra que rota para evadir IOCs (ver `Lazarus.md`). |
| OPSEC de baliza (sleep, jitter, profiling) | **Tradecraft universal** | Principio de operador, no firma de un actor concreto. El lab lo enseña como disciplina general. |
| Equivalencia Cobalt Strike ↔ Sliver | **Marco didáctico** | CRTO usa CS; el lab usa Sliver. Ningún actor "usa el examen". |
| Staged vs stageless | **Tradecraft universal** | Decisión de operador según OPSEC/entorno, no atribuible a un actor. |

> **Regla del repo:** donde una técnica es firma documentada del actor, se cita. Donde es tradecraft de operador, se enmarca como tal. Lazarus es el **escenario y el vehículo narrativo**; la capability (fundamentos de C2) es el alcance real del lab.

## TTPs de Lazarus que dan contexto a ESTE lab

| Táctica | Técnica | ID | Cómo aparece en el lab |
|---------|---------|----|------------------------|
| Command & Control | Application Layer Protocol: Web | T1071.001 | El listener HTTPS que configuras es el canal que Lazarus usa con sus RATs |
| Command & Control | Encrypted Channel | T1573 | TLS en el listener; cifrado de baliza |
| Defense Evasion | (preludio) OPSEC de baliza | — | Sleep/jitter/profiling preparan la evasión que se profundiza en Lab-11 |

> El repertorio TTP completo de Lazarus vive en [`Lazarus.md`](../../../docs/adversaries/Lazarus.md). Aquí solo el subconjunto que este lab contextualiza.

## Puente narrativo a Phase-03

Black Beacon es el **Paso 0 del operador**: sin kit no hay operación. Lo que montas aquí (team server, listener, baliza con OPSEC básico) es la infraestructura sobre la que se ejecutan los Labs 09-12 — caer y leer el terreno (09), persistir y escalar (10), y volverse invisible ante Defender/AMSI/ETW (11-12), donde el tradecraft de evasión de Lazarus pasa a primer plano.

---

*Emulation Plan · Lab-08 Black Beacon · especializa `Lazarus.md` (anatomía v3.1)*
