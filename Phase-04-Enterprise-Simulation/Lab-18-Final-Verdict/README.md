# Lab-18 · Final Verdict — Capstone: Exam Simulation

![Status](https://img.shields.io/badge/Status-Operación%20v3.1%20(plan)-yellowgreen)
![Phase](https://img.shields.io/badge/Phase-04-orange)
![Adversary](https://img.shields.io/badge/Adversary-APT10%20Cloud%20Hopper-red)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Operación%20Integradora-8a2be2)

> Fase: `Phase-04-Enterprise-Simulation` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability:** Capstone — Exam Simulation. Cadena completa Labs 08-17 bajo condiciones de examen (Defender ON, multi-dominio, contrarreloj, por objetivos).
**Arquetipo:** Operación integradora (A) — no enseña técnicas nuevas; aplica todas las anteriores bajo presión.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [APT10](../../docs/adversaries/APT10.md)

---

## 🎯 Objetivo

Simular el examen CRTO de extremo a extremo: 48h, Defender ON, multi-dominio, 6 flags mínimos para aprobar. Medir cobertura, velocidad y OPSEC bajo presión. Revelar huecos antes del día real.

## 📋 Formato del examen CRTO

| Parámetro | Valor |
|-----------|-------|
| Duración | 48 horas |
| Flags para aprobar | 6 de 8 mínimo |
| Defender | **ON** en todos los hosts |
| Modelo | Assumed breach (baliza ya dentro) |
| Entorno | Multi-dominio / multi-forest |

## 🗺️ La cadena integrada (Labs 08-17)

```
Lab-08 C2 → Lab-09 SA → Lab-10 PrivEsc → Lab-11/12 Evasión
    → Lab-13 MSSQL → Lab-14 DomDom → Lab-15 Cross-Forest
    → Lab-16 Arsenal → Lab-17 Exfil
         ↓
    Lab-18 FINAL VERDICT (todos juntos, bajo presión)
```

## 💡 Checklist pre-examen

El `lessons.md` contiene el checklist completo. Antes de presentar el examen, cada lab debe ser SÍ. Si alguno es NO — más ejecución real antes del examen.

## 📂 Estructura

```
Lab-18-Final-Verdict/
├── docs/
│   ├── technique.md                  # ✅ Playbook de examen (48h, timeline, errores frecuentes)
│   ├── emulation.md                  # ✅ Cloud Hopper completo de extremo a extremo
│   ├── detection.md                  # ✅ La cadena de detección correlacionada
│   ├── lessons.md                    # ✅ Checklist pre-examen (Lab-08 → Lab-17)
│   ├── execution/                    # 🗺️ PLAN integrador (M1-M5)
│   │   ├── setup_and_recon.md        #    M1 · C2 + SA (Horas 0-2)
│   │   ├── escalation_persistence.md #    M2 · PrivEsc + Persist (Horas 2-6)
│   │   ├── domain_lateral.md         #    M3 · Lateral dominio (Horas 6-16)
│   │   ├── domain_dominance.md       #    M4 · Domain Dominance (Horas 16-36)
│   │   └── exfil_and_report.md       #    M5 · Exfil + Reporte (Horas 36-48)
│   └── report/
├── loot/   ├── nmap/   └── screenshots/
```

---

*FINAL VERDICT · Capstone · Adrián Camacho — El cierre del roadmap. Cuando este lab funcione de extremo a extremo, el examen CRTO está listo.*
