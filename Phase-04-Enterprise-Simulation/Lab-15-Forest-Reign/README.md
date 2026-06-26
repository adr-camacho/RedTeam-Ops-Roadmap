# Lab-15 · Forest Reign — Forest & Trust Abuse

![Status](https://img.shields.io/badge/Status-Operación%20v3.1%20(plan)-yellowgreen)
![Phase](https://img.shields.io/badge/Phase-04-orange)
![Adversary](https://img.shields.io/badge/Adversary-APT10%20Cloud%20Hopper-red)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Operación%20(A)-8a2be2)

> Fase: `Phase-04-Enterprise-Simulation` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** Forest & Trust Abuse — cross-forest lateral, Extra SID Attack (child→parent), SID History, SID Filtering.
**Arquetipo:** Operación (A) — kill-chain real. El contenido didáctico está completo; `execution/` es el **plan de ataque**.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [APT10](../../docs/adversaries/APT10.md) — **el encaje más fuerte de Phase-04**

---

## 🎯 Objetivo

Saltar entre dominios y forests abusando de trusts. El examen CRTO es multi-forest — este es el núcleo de los flags difíciles. Las cadenas de trust dan la nota alta; el operador que las domina completa el examen.

## 📚 Qué cubre (temario CRTO)

| Bloque | Contenido |
|--------|-----------|
| **Enumeración de trusts** | Tipos, dirección, SID Filtering por tramo |
| **Extra SID Attack** | Child→Parent intra-forest (siempre disponible, sin SID Filtering) |
| **Cross-forest lateral** | Inter-realm trust cuando SID Filtering está desactivado |
| **SID History abuse** | SIDs privilegiados cross-domain |

## 💡 Valor didáctico en el examen

Los flags cross-forest son los más difíciles del examen y los más valorados. Dominar la cadena de trusts — cuál permite qué, cómo cruzar con el privilegio correcto — es lo que separa aprobado de notable. Y es el momento donde APT10 / Cloud Hopper se vuelve el encaje más genuino del arco.

## 📂 Estructura

```
Lab-15-Forest-Reign/
├── docs/
│   ├── technique.md                  # ✅ Trusts, SID Filtering, Extra SID, cross-forest
│   ├── emulation.md                  # ✅ APT10 = Cloud Hopper en AD (encaje más genuino)
│   ├── detection.md                  # ✅ PAC analysis, inter-realm tickets, SID History
│   ├── lessons.md                    # ✅ Child→parent, SID Filtering, nota alta CRTO
│   ├── execution/                    # 🗺️ PLAN (M1-M4)
│   │   ├── trust_enumeration.md      #    M1 · mapear la cadena de trusts
│   │   ├── extra_sid_attack.md       #    M2 · child→parent (siempre disponible)
│   │   ├── cross_forest_lateral.md   #    M3 · inter-forest (si trust abusable)
│   │   └── validate_consolidate.md   #    M4 · acceso real + documentar cadena
│   └── report/
├── loot/   ├── nmap/   └── screenshots/
```

---

*FOREST REIGN · Forest & Trust Abuse · Adrián Camacho — Entorno de laboratorio, únicamente con fines educativos*
