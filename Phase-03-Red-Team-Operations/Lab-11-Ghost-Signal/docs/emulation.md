# Emulation Plan — GHOST SIGNAL (Lazarus Group)

> **Perfil del actor (clase base, no se repite aquí):** [`Lazarus.md`](../../../docs/adversaries/Lazarus.md)
> **Arquetipo:** Concepto / Tradecraft. Describe **cómo Lazarus razona sobre la evasión de Defender/AMSI/ETW**.

---

## Por qué Lazarus ancla este lab — el encaje más genuino de Phase-03

Ghost Signal no es solo el lab de evasión — es el lab donde Lazarus deja de ser vehículo narrativo y se convierte en **el exponente más documentado y literal**. Las técnicas que enseña este lab son TTPs firma de Lazarus:

- **ETW patching** (T1562.006) — documentado explícitamente en sus campañas.
- **Ejecución in-memory sin tocar disco** — característica definitoria de su arsenal.
- **Packing y ofuscación** (VMProtect, Themida) — técnica firma documentada.

Cuando el lab enseña "así se ciega ETW", está enseñando exactamente lo que Lazarus hace.

## Qué es genuino de Lazarus y qué es tradecraft del operador

| Elemento del lab | ¿Genuino de Lazarus? | Matiz |
|------------------|----------------------|-------|
| ETW patching (T1562.006) | **Sí, firma del actor** | Técnica documentada explícitamente en sus campañas |
| Ejecución in-memory (reflective loading) | **Sí, documentado** | Parte definitoria de su arsenal |
| Software packing (VMProtect/Themida) | **Sí, firma del actor** | Técnica documentada en múltiples informes |
| AMSI bypass en scripts PS | **Tradecraft universal** | Muchos actores lo usan; no es firma específica de Lazarus |
| Conceptos de firma vs comportamiento | **Marco didáctico** | Principio de operador, no TTP de un actor |

> Este lab tiene el encaje más fiel de Phase-03: ETW patching e in-memory execution son la seña de identidad técnica de Lazarus. La tabla de honestidad juega a favor — la mayoría de lo que el lab enseña *es* Lazarus.

## TTPs de Lazarus que contextualizan ESTE lab

| Táctica | Técnica | ID | En el lab |
|---------|---------|----|-----------|
| Defense Evasion | Impair Defenses: ETW patching | T1562.006 | §4 — el concepto de cegar ETW |
| Defense Evasion | Reflective Code Loading | T1620 | §3 — ejecución in-memory |
| Defense Evasion | Software Packing | T1027.002 | §1 — firma vs comportamiento |

## Puente narrativo

Ghost Signal es el clímax técnico de Phase-03. Las técnicas que enseña (ETW cegado, in-memory) son las que hacen que los Labs 09-10 sigan siendo posibles bajo Defender activo. Sin la capa de evasión de Ghost Signal, los movimientos de persistencia y escalada de Labs 10 y los movimientos de dominio de Phase-04 serían inmediatamente detectables.

---

*Emulation Plan · Lab-11 Ghost Signal · especializa `Lazarus.md` — ETW/in-memory = firma del actor (anatomía v3.1)*
