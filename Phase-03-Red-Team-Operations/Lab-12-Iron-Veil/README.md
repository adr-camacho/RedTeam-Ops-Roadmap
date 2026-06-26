# Lab-12 · Iron Veil — Evasion II: AppLocker / CLM / LOLBAS

![Status](https://img.shields.io/badge/Status-Concepto%20v3.1-brightgreen)
![Phase](https://img.shields.io/badge/Phase-03-blue)
![Adversary](https://img.shields.io/badge/Adversary-Lazarus%20Group-darkred)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Concepto%2FTradecraft-555)

> Fase: `Phase-03-Red-Team-Operations` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** Evasión II — AppLocker, Constrained Language Mode (CLM) y LOLBAS; ejecución bajo whitelisting.
**Arquetipo:** Concepto / Tradecraft — se construye el **porqué** y el **cómo se detecta**. El código de bypass **no vive en el repo**: se practica en el laboratorio oficial CRTO.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [Lazarus](../../docs/adversaries/Lazarus.md)

---

## 🎯 Objetivo

El examen CRTO pone AppLocker. Sin entender **desde dónde puedes ejecutar, qué binarios están permitidos y por qué CLM cierra PowerShell ofensivo**, te quedas sin ejecución. La diferencia entre avanzar o atascarte es reconocer el escudo y conocer el terreno que sí tienes disponible.

## 📚 Qué cubre (temario CRTO)

| Bloque | Contenido |
|--------|-----------|
| **AppLocker** | Mecánica, modos Audit/Enforce, reglas de path/publisher/hash |
| **CLM** | Constrained Language Mode, relación con AppLocker, qué bloquea |
| **LOLBAS** | El catálogo de binarios del sistema con capacidad de ejecución/proxy |
| **Estrategia del operador** | Árbol de decisión bajo whitelisting activo |

## 🎓 Qué prepara

- El reflejo de **leer la política antes de atacarla** (Audit vs Enforce, rutas permitidas).
- Entender que CLM es consecuencia de AppLocker, no un control independiente.
- Conocer LOLBAS como **mapa del terreno permitido**, no como técnica de fuerza bruta.

## 💡 Valor didáctico en el examen

Reconocer qué puedes ejecutar y desde dónde es la diferencia entre avanzar o atascarte. Con AppLocker en Enforce, el operador que conoce LOLBAS tiene maniobra; el que no, se para. El criterio se construye aquí; el bypass concreto en el curso.

## 🔧 Regla de construcción

Teoría, detección y protocolo de observación se construyen en este repo. El **código de bypass** (scripts de bypass de CLM, técnicas de AppLocker) **NO** vive aquí — se practica en el laboratorio CRTO. Documentamos el *por qué* y el *cómo se detecta*.

## 📂 Estructura

```
Lab-12-Iron-Veil/
├── README.md
├── docs/
│   ├── technique.md                  # ✅ AppLocker/CLM/LOLBAS, árbol de decisión
│   ├── emulation.md                  # ✅ Framing Lazarus (LOLBAS como filosofía)
│   ├── detection.md                  # ✅ Contexto > firma; señales de LOLBAS
│   ├── lessons.md                    # ✅ Lecciones de criterio
│   ├── execution/                    # 🔬 Protocolo de observación (Paso 1-5)
│   │   ├── detect_applocker.md       #    1 · ¿activo? ¿Audit o Enforce?
│   │   ├── policy_paths.md           #    2 · leer la política: rutas y reglas
│   │   ├── clm_check.md              #    3 · ¿CLM activo?
│   │   ├── lolbas_map.md             #    4 · mapear el terreno LOLBAS
│   │   └── context_is_key.md         #    5 · el contexto manda
│   └── report/
├── loot/   ├── nmap/   └── screenshots/
```

## 🎬 Próximos pasos

1. **Leer `technique.md`** — árbol de decisión bajo whitelisting e interiorizar qué es CLM.
2. **Leer `detection.md`** — entender por qué LOLBAS se detecta por contexto, no por firma.
3. **Practicar en el lab del curso** siguiendo el protocolo de observación (Paso 1-5).
4. **Completar `lessons.md`** con modo AppLocker encontrado, CLM activo/no, LOLBAS que funcionó.

---

*IRON VEIL · Evasion II · Adrián Camacho — Entorno de laboratorio, únicamente con fines educativos. El código de bypass no vive en el repo por diseño.*
