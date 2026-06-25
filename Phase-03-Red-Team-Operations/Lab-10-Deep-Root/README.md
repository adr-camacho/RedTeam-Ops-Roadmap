# Lab-10 · Deep Root — Host Persistence & Privilege Escalation

![Status](https://img.shields.io/badge/Status-Operación%20v3.1%20(plan)-yellowgreen)
![Phase](https://img.shields.io/badge/Phase-03-blue)
![Adversary](https://img.shields.io/badge/Adversary-Lazarus%20Group-darkred)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Operación%20(A)-8a2be2)

> Fase: `Phase-03-Red-Team-Operations` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** Host Persistence & Privilege Escalation — afianzarse y elevar en un host antes de tocar el dominio.
**Arquetipo:** Operación (A) — kill-chain real. El contenido didáctico está completo; `execution/` es el **plan de ataque** que pasa a operativa con tus capturas al ejecutarlo.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [Lazarus](../../docs/adversaries/Lazarus.md)

---

## 🎯 Objetivo

Los dos pasos obligados tras leer el terreno (Lab-09): **elevar** privilegios y **mantener** el acceso. Sin ambos, cualquier movimiento hacia el dominio es frágil. El criterio del lab no es "qué técnica existe" sino **cuál elegir según lo que el host permite, sin ruido innecesario**.

## 📚 Qué cubre (temario CRTO)

| Bloque | Contenido |
|--------|-----------|
| **Escalada de host** | Token abuse (Potato), misconfig de servicios, UAC bypass, AlwaysInstallElevated |
| **Persistencia de host** | Run keys, scheduled tasks, services, COM hijacking, WMI event subscription |
| **Proporcionalidad / OPSEC** | Elegir el mecanismo que pasa desapercibido y sobrevive lo necesario |

## 🎓 Qué prepara

- La secuencia **elevar → persistir → validar → limpiar**, que se repite en cada host del examen.
- El criterio de proporcionalidad: el mecanismo correcto es el que el entorno no vigila de cerca, no el más exótico.
- Reconocer que SeImpersonate es la llave maestra a SYSTEM cuando está presente.

## 💡 Valor didáctico en el examen

Persistencia y escalada son **chequeos constantes** en CRTO. El examen premia elegir el mecanismo correcto sin generar ruido — exactamente el criterio que este lab construye. Y el orden importa: elevar antes de persistir da una residencia más robusta.

## 🔧 Arquetipo operación

`technique`, `emulation`, `detection` y `lessons` son entregable completo. El **`execution/` es el plan de ataque** (kill-chain de afianzamiento): describe qué ejecutar y qué esperar. Al correrlo contra el entorno CRTO, pasa a operativa real con tus capturas, hashes y decisiones.

## 📂 Estructura

```
Lab-10-Deep-Root/
├── README.md
├── docs/
│   ├── technique.md                  # ✅ Escalada + persistencia, proporcionalidad, OPSEC
│   ├── emulation.md                  # ✅ Framing Lazarus (side-loading/tasks/token = genuino)
│   ├── detection.md                  # ✅ Cómo se detecta cada vía y mecanismo
│   ├── lessons.md                    # ✅ Lecciones de criterio
│   ├── execution/                    # 🗺️ PLAN de ataque (M1-M4)
│   │   ├── privilege_escalation.md   #    M1 · escalada (token/servicio/UAC)
│   │   ├── persistence_install.md    #    M2 · persistencia proporcional
│   │   ├── persistence_validation.md #    M3 · ¿sobrevive reinicio?
│   │   └── cleanup_opsec.md          #    M4 · minimizar huella (transversal)
│   └── report/
├── loot/   ├── nmap/   └── screenshots/
```

## 🎬 Próximos pasos

1. **Leer `technique.md`** — interiorizar las vías de escalada y los mecanismos de persistencia.
2. **Leer `detection.md`** — saber qué deja rastro antes de elegir.
3. **Ejecutar el plan** (M1-M4) contra el entorno CRTO, capturando la operativa real.
4. **Completar `lessons.md`** con el vector usado, el mecanismo elegido y el resultado de la validación.

---

*DEEP ROOT · Host Persistence & Privilege Escalation · Adrián Camacho — Entorno de laboratorio, únicamente con fines educativos*
