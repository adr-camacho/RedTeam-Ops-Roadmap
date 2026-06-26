# Lab-11 · Ghost Signal — Evasion I: Defender / AMSI / ETW

![Status](https://img.shields.io/badge/Status-Concepto%20v3.1-brightgreen)
![Phase](https://img.shields.io/badge/Phase-03-blue)
![Adversary](https://img.shields.io/badge/Adversary-Lazarus%20Group-darkred)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Concepto%2FTradecraft-555)

> Fase: `Phase-03-Red-Team-Operations` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** Evasión I — Windows Defender, AMSI, ETW; firma vs comportamiento; el modelo de los kits de C2.
**Arquetipo:** Concepto / Tradecraft — se construye el **porqué** y el **cómo se detecta**. El código armado (bypass/loader/kit/BOF) **no vive en el repo**: se practica en el laboratorio oficial CRTO.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [Lazarus](../../docs/adversaries/Lazarus.md) — **su terreno firma**

---

## 🎯 Objetivo

El corazón del examen CRTO es **operar con Defender encendido sin perder balizas**. Lo que separa aprobar de perder el beacon no es memorizar un bypass — es entender **por qué** saltas, qué firma vs qué comportamiento te delata, y qué genera telemetría. Este lab construye ese criterio.

## 📚 Qué cubre (temario CRTO)

| Bloque | Contenido |
|--------|-----------|
| **Firma vs comportamiento** | El marco mental que ordena toda la evasión |
| **Windows Defender** | Las capas del motor; Tamper Protection |
| **AMSI** | Inspección de contenido en runtime; concepto de neutralización |
| **ETW** | Telemetría nativa; concepto de patching (firma de Lazarus) |
| **Modelo de kits CS** | Artifact/Resource Kit, Malleable C2 (concepto) |

## 🎓 Qué prepara

- El reflejo de pensar en **capas** (binario/script/tráfico/comportamiento) y saber cuál te bloqueó.
- Operar **con Defender ON**, no intentar apagarlo (Tamper Protection lo impide).
- Entender que **evadir es también ser detectable** — el meta-juego.

## 💡 Valor didáctico en el examen

Entender **POR QUÉ** saltas separa aprobar de perder el beacon. El kit se practica en el curso; el porqué y el cómo-se-detecta se construyen aquí. Es el clímax técnico de Phase-03: la capacidad que hace viable todo lo anterior con Defender activo.

## 🔧 Regla de construcción

**Teoría, detección y protocolo de observación** se construyen en este repo. El **código armado de evasión** (bypass / loader / kit / BOF) **NO** vive aquí: se practica en el laboratorio oficial CRTO con sus kits. Documentamos el *por qué* y el *cómo se detecta* — el `execution/` es un **protocolo de qué observar**, no código.

## 📂 Estructura

```
Lab-11-Ghost-Signal/
├── README.md
├── docs/
│   ├── technique.md                  # ✅ Firma vs comportamiento, Defender/AMSI/ETW, kits
│   ├── emulation.md                  # ✅ Lazarus = exponente LITERAL (el encaje más fiel)
│   ├── detection.md                  # ✅ El meta-juego: evadir también se detecta
│   ├── lessons.md                    # ✅ Lecciones de criterio
│   ├── execution/                    # 🔬 Protocolo de observación (Paso 1-5, SIN código)
│   │   ├── observe_baseline.md       #    1 · ¿qué cazan por defecto?
│   │   ├── signature_vs_behavior.md  #    2 · ofusca: firma cae, comportamiento no
│   │   ├── amsi_mechanics.md         #    3 · AMSI: mecánica + concepto de bypass
│   │   ├── etw_mechanics.md          #    4 · ETW: mecánica + concepto de cegado
│   │   └── evasion_is_detectable.md  #    5 · el meta-juego
│   └── report/
├── loot/   ├── nmap/   └── screenshots/
```

## 🎬 Próximos pasos

1. **Leer `technique.md`** — interiorizar firma vs comportamiento y los tres mecanismos.
2. **Leer `detection.md`** — entender el meta-juego (evadir deja huella).
3. **Practicar en el lab del curso** siguiendo el protocolo de observación (Paso 1-5).
4. **Completar `lessons.md`** con qué capa bloqueó cada intento y qué ajustaste.

---

*GHOST SIGNAL · Evasion I · Adrián Camacho — Entorno de laboratorio, únicamente con fines educativos. El código armado no vive en el repo por diseño.*
