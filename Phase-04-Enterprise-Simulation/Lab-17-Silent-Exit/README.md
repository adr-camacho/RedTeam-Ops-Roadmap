# Lab-17 · Silent Exit — Exfiltration & Reporting

![Status](https://img.shields.io/badge/Status-Operación%20v3.1%20(plan)-yellowgreen)
![Phase](https://img.shields.io/badge/Phase-04-orange)
![Adversary](https://img.shields.io/badge/Adversary-APT10%20Cloud%20Hopper-red)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Operación%20(A)-8a2be2)

> Fase: `Phase-04-Enterprise-Simulation` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** Exfiltration & Reporting — data hunting, staging (RAR cifrado), exfil vía cloud legítimo, salida limpia y reporte profesional.
**Arquetipo:** Operación (A) — kill-chain real. El contenido didáctico está completo; `execution/` es el **plan de ataque**.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [APT10](../../docs/adversaries/APT10.md) — **RAR+Dropbox = APT10 documentado**

---

## 🎯 Objetivo

Localizar el valor, extraerlo con OPSEC y cerrar el engagement con un reporte profesional. El objetivo del examen CRTO suele ser data — encontrarla y documentarla es el cierre real de la operación.

## 📚 Qué cubre (temario CRTO)

| Bloque | Contenido |
|--------|-----------|
| **Data Hunting** | Localizar shares de alto valor, datos sensibles, bases de datos |
| **Staging** | RAR cifrado para opacar el contenido al DLP |
| **Exfiltración** | Dropbox/cloud legítimo vs C2 vs DNS tunneling |
| **Salida limpia** | Artefactos a limpiar, qué NO borrar, OPSEC de cierre |
| **Reporting** | El entregable real: timeline, hallazgos, evidencias, recomendaciones |

## 💡 Encaje APT10

Silent Exit es donde APT10 brilla con más precisión técnica: **RAR cifrado + Dropbox (dbxcli)** es exactamente el método documentado en los informes de Cloud Hopper. El emulation plan no necesita forzar ningún encaje — la técnica y el actor son la misma cosa.

## 📂 Estructura

```
Lab-17-Silent-Exit/
├── docs/
│   ├── technique.md                  # ✅ Data hunting, staging, exfil, reporting
│   ├── emulation.md                  # ✅ RAR+Dropbox = APT10 literal (más fiel de Phase-04)
│   ├── detection.md                  # ✅ SMB sweep, 7z con -p, cloud upload anómalo
│   ├── lessons.md                    # ✅ El dato > el flag; DLP ciego al cifrado
│   ├── execution/                    # 🗺️ PLAN (M1-M4)
│   │   ├── data_hunting.md           #    M1 · localizar valor en shares
│   │   ├── staging.md                #    M2 · RAR cifrado + fragmentar
│   │   ├── exfiltration.md           #    M3 · cloud legítimo (APT10) u otro canal
│   │   └── clean_exit.md             #    M4 · salida limpia + reporte
│   └── report/
├── loot/   ├── nmap/   └── screenshots/
```

---

*SILENT EXIT · Exfiltration & Reporting · Adrián Camacho — Entorno de laboratorio, únicamente con fines educativos*
