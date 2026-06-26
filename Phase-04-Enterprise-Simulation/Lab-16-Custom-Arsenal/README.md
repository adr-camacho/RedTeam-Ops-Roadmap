# Lab-16 · Custom Arsenal — Extending the C2

![Status](https://img.shields.io/badge/Status-Concepto%20v3.1-brightgreen)
![Phase](https://img.shields.io/badge/Phase-04-orange)
![Adversary](https://img.shields.io/badge/Adversary-APT10%20Cloud%20Hopper-red)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Concepto%2FTradecraft-555)

> Fase: `Phase-04-Enterprise-Simulation` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** Extending the C2 — Malleable C2 profiles, BOFs, Aggressor Scripts. Reducir footprint y operar con más OPSEC.
**Arquetipo:** Concepto / Tradecraft — se construye el **porqué**. El código de BOFs/Aggressor **no vive en el repo**: se practica en el laboratorio oficial CRTO.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [APT10](../../docs/adversaries/APT10.md)

---

## 🎯 Objetivo

Adaptar el C2 a OPSEC (perfiles Malleable), operar con footprint mínimo de proceso (BOFs), y automatizar el workflow de operador (Aggressor). Reducir footprint para operar como exige el examen con Defender ON.

## 📚 Qué cubre (temario CRTO)

| Bloque | Contenido |
|--------|-----------|
| **Malleable C2** | Modelar tráfico del beacon para imitar tráfico legítimo |
| **BOFs** | Ejecución en proceso del beacon sin crear proceso hijo |
| **Aggressor Scripts** | Automatización del workflow de operador |

## 💡 Relación con las otras capas de evasión

| Lab | Capa que protege |
|-----|-----------------|
| Lab-11 Ghost Signal | AV/AMSI/ETW — el payload en memoria |
| Lab-12 Iron Veil | AppLocker/CLM — qué puede ejecutarse |
| **Lab-16 Custom Arsenal** | **Tráfico de red + footprint de proceso** |

Las tres capas son complementarias. Un entorno maduro monitoriza las tres dimensiones.

## 🔧 Regla de construcción

Teoría, detección y protocolo de observación se construyen aquí. El **código de BOFs/Aggressor/perfiles** **NO** vive en el repo — se practica en el lab CRTO. Documentamos el *por qué* y la *diferencia de footprint observable*.

## 📂 Estructura

```
Lab-16-Custom-Arsenal/
├── docs/
│   ├── technique.md                  # ✅ Malleable C2, BOFs, Aggressor — porqué y cuándo
│   ├── emulation.md                  # ✅ APT10: C2 discreto para operaciones largas
│   ├── detection.md                  # ✅ JA3, jitter analysis, discrepancias User-Agent
│   ├── lessons.md                    # ✅ BOF vs execute-assembly, perfil default es detectable
│   ├── execution/                    # 🔬 Protocolo de observación (Paso 1-4)
│   │   ├── observe_default.md        #    1 · CS default — qué lo delata
│   │   ├── malleable_profile.md      #    2 · Malleable — configurar + observar tráfico
│   │   ├── bof_vs_assembly.md        #    3 · BOF vs execute-assembly — footprint comparado
│   │   └── aggressor_workflow.md     #    4 · Aggressor — automatizar checklist
│   └── report/
```

---

*CUSTOM ARSENAL · Extending the C2 · Adrián Camacho — Entorno de laboratorio, únicamente con fines educativos. El código no vive en el repo por diseño.*
