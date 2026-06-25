# Lab-09 · First Contact — Situational Awareness & Host Recon

![Status](https://img.shields.io/badge/Status-Concepto%20v3.1-brightgreen)
![Phase](https://img.shields.io/badge/Phase-03-blue)
![Adversary](https://img.shields.io/badge/Adversary-Lazarus%20Group-darkred)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Concepto%2FTradecraft%20(B%2B)-555)

> Fase: `Phase-03-Red-Team-Operations` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** Situational Awareness & Host Recon — la disciplina de la **primera hora** tras aterrizar.
**Arquetipo:** Concepto / Tradecraft con fuerte componente operativo (B+) — la metodología es entregable; el output real lo capturas al ejecutar el playbook.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [Lazarus](../../docs/adversaries/Lazarus.md)

---

## 🎯 Objetivo

Construir el **criterio de la primera hora**: qué mirar, en qué orden y sin hacer ruido cuando aterrizas una baliza. CRTO es assumed-breach — el examen empieza con acceso ya dentro, así que el acceso inicial externo (phishing) **queda fuera** por diseño. Lo examinable, y el oro real, es leer el terreno antes de actuar.

## 📚 Qué cubre (temario CRTO)

| Bloque | Contenido |
|--------|-----------|
| **Situational Awareness** | El árbol de decisión de la primera hora |
| **Self assessment** | Identidad, privilegios, integridad, rol del equipo |
| **Postura defensiva** | AV/EDR/AMSI/CLM/AppLocker/Sysmon — el paso crítico |
| **Host context** | Procesos, software, sesiones, tareas/servicios |
| **Conciencia de dominio** | DCs, trusts, derechos — recon AD sigiloso |
| **OPSEC del recon** | El reconocimiento también es detectable |

## 🎓 Qué prepara

- **El reflejo de evaluar antes de actuar** — el que evita quemar el foothold en el examen.
- Saber que la postura defensiva del host **dicta** qué TTPs puedes permitirte después (Labs 10-12).
- Reconocer que el recon deja rastro y cómo hacerlo dirigido en vez de masivo.

## 💡 Valor didáctico en el examen

El error que más suspende CRTO no es técnico: es **actuar antes de evaluar**. Lanzar SharpHound nada más caer, volcar LSASS sin saber si hay PPL, correr un script con AMSI activo. Este lab construye el reflejo que evita eso. El árbol de decisión de la primera hora es el que ejecutarás, mentalmente, en cada baliza del examen.

## 🔧 Regla de construcción

Arquetipo **concepto B+**: la metodología, el árbol de decisión y la detección se construyen aquí como entregable completo. El **playbook de `execution/`** es la secuencia de lectura del terreno que ejecutas en el lab — su output real (lo que ves al enumerar el entorno CRTO) lo capturas al correrlo.

## 📂 Estructura

```
Lab-09-First-Contact/
├── README.md
├── docs/
│   ├── technique.md                  # ✅ El árbol de decisión de la primera hora
│   ├── emulation.md                  # ✅ Framing Lazarus + honestidad técnica
│   ├── detection.md                  # ✅ El recon también se detecta
│   ├── lessons.md                    # ✅ Lecciones de criterio
│   ├── execution/                    # 🔧 Playbook de recon (Módulo 1-5)
│   │   ├── self_assessment.md        #    1 · ¿quién soy?
│   │   ├── defensive_posture.md      #    2 · ¿qué me vigila? (CRÍTICO)
│   │   ├── host_context.md           #    3 · ¿qué hay alrededor?
│   │   ├── network_domain_awareness.md  # 4 · ¿qué dominio? (sigiloso)
│   │   └── decision_point.md         #    5 · decisión: primer movimiento
│   └── report/
├── loot/   ├── nmap/   └── screenshots/
```

## 🎬 Próximos pasos

1. **Leer `technique.md`** — interiorizar el árbol de decisión de la primera hora.
2. **Leer `detection.md`** — entender qué hace ruido al enumerar.
3. **Ejecutar el playbook** (Módulos 1-5) contra el entorno CRTO, capturando observaciones reales.
4. **Completar `lessons.md`** con la decisión de primer movimiento tomada y su justificación.

---

*FIRST CONTACT · Situational Awareness & Host Recon · Adrián Camacho — Entorno de laboratorio, únicamente con fines educativos*
