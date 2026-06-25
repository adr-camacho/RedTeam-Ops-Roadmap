# Emulation Plan — FIRST CONTACT (Lazarus Group)

> **Perfil del actor (clase base, no se repite aquí):** [`Lazarus.md`](../../../docs/adversaries/Lazarus.md)
> **Arquetipo:** Concepto / Tradecraft (B+). Describe **cómo razona un operador sigiloso al aterrizar**, no una intrusión contra una org.

---

## Por qué Lazarus ancla este lab

Lazarus opera con una paciencia notable: tras un compromiso inicial (su famoso *Operation Dream Job*), no actúa en caliente — **lee el entorno, evalúa el escudo y decide** antes de profundizar. Esa disciplina de "primera hora" es exactamente lo que enseña este lab. Un actor que invierte meses en una intrusión no quema el acceso por impaciencia en los primeros minutos.

## Qué es genuino de Lazarus y qué es tradecraft universal

| Elemento del lab | ¿Genuino de Lazarus? | Matiz |
|------------------|----------------------|-------|
| Disciplina de evaluar antes de actuar | **Coherente con su doctrina** | Operaciones largas y pacientes; no es una "técnica" sino una mentalidad documentada |
| Security Software Discovery (T1518.001) | **Tradecraft universal** | Todo operador serio enumera defensas; no es firma de un actor |
| Host/Domain recon (Discovery) | **Tradecraft universal** | Metodología estándar de la primera hora |
| OPSEC del recon (dirigido > masivo) | **Tradecraft de operador** | Principio general; Lazarus lo encarna por su perfil sigiloso |

> Situational awareness es **tradecraft universal**: ningún actor "posee" la idea de mirar antes de actuar. Lazarus es el **vehículo narrativo** que encarna la disciplina sigilosa; la capability (criterio de recon de la primera hora) es el alcance real.

## TTPs de Discovery que contextualiza el lab

| Táctica | Técnica | ID | En el lab |
|---------|---------|----|-----------|
| Discovery | Security Software Discovery | T1518.001 | Paso 2 — ¿qué me vigila? |
| Discovery | System Owner/User Discovery | T1033 | Paso 1 — ¿quién soy? |
| Discovery | Process Discovery | T1057 | Paso 3 — contexto del host |
| Discovery | Domain Trust Discovery | T1482 | Paso 4 — conciencia de dominio |

> Repertorio completo de Lazarus en [`Lazarus.md`](../../../docs/adversaries/Lazarus.md).

## Puente narrativo

First Contact es la **bisagra** entre tener el kit (Lab-08) y empezar a operar. Lo que decidas aquí —según lo que veas que te vigila— determina cómo abordas la persistencia y escalada de Lab-10, y por qué necesitarás la evasión de Labs 11-12. El árbol de decisión de este lab es el que ejecutarás, mentalmente, en cada baliza del examen.

---

*Emulation Plan · Lab-09 First Contact · especializa `Lazarus.md` (anatomía v3.1)*
