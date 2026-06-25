# Lab-08 · Black Beacon — C2 Foundations

![Status](https://img.shields.io/badge/Status-Concepto%20v3.1-brightgreen)
![Phase](https://img.shields.io/badge/Phase-03-blue)
![Adversary](https://img.shields.io/badge/Adversary-Lazarus%20Group-darkred)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Concepto%2FTradecraft-555)

> Fase: `Phase-03-Red-Team-Operations` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** Fundamentos de C2 — modelo de operador, listeners, payloads staged/stageless, OPSEC, CS↔Sliver.
**Arquetipo:** Concepto / Tradecraft — el contenido (technique·emulation·detection·lessons) es entregable completo; `execution/` es la **secuencia de construcción** del kit que ejecutas en tu lab / curso CRTO.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [Lazarus](../../docs/adversaries/Lazarus.md)

---

## 🎯 Objetivo

Construir el **modelo de operador de Command & Control (C2)** que sustenta todo el examen CRTO.

Sin dominar este bloque, el resto del examen es inmanejable: el C2 es el "sistema nervioso" de toda operación.

**Específicamente:**
- Qué es un team server, listeners y beacons
- Tipos de listener (HTTP/S, SMB, TCP, DNS) y cuándo usar cada uno
- Staged vs stageless payloads
- OPSEC básico de C2 (sleep, jitter, profiling)
- **Equivalencia Cobalt Strike ↔ Sliver** (el lab usa Sliver, el examen usa CS)
- **Detección:** cómo un defensor caza C2, qué telemetría es observable

---

## 📚 Qué cubre (temario CRTO)

| Bloque | Contenido |
|--------|-----------|
| **C2 / Modelo Operador** | Team server, listeners, beacons, staged/stageless |
| **Listeners** | HTTP, HTTPS, SMB, TCP, DNS — configuración y uso |
| **OPSEC de C2** | Sleep, jitter, user-agent, profiling, beaconing patterns |
| **Detección** | JA3/JARM, anomalías de proceso, Event IDs, telemetría |
| **MITRE ATT&CK** | T1071.001 (Application Layer Protocol), T1573 (Encrypted Channel) |

---

## 🎓 Qué prepara

- Entender por qué cada parámetro de C2 importa en el examen con Defender activo
- Operar con criterio, no "copiar comandos"
- Reconocer qué genera telemetría y cómo evitarla
- Adaptarse en tiempo real cuando Defender está monitoreando

**Resultado:** Cuando llegues a Lab-09, sabrás **por qué** cambias sleep/jitter, **cuándo** necesitas listener diferente, y **cómo** operar sin perder el beacon.

---

## 💡 Valor didáctico en el examen

El examen CRTO es **100% operado a través del C2.** No hay ejecución directa de comandos, no hay "shells interactivos": todo pasa por el beacon.

Por tanto:
- **Falla en C2 = falla el examen**
- Dominar C2 = 70% del examen ya está ganado

Una vez que sabes levantar un C2 con Defender activo, tareas como priv-esc, lateral movement, persistence son "solo" comandos que pasas al beacon.

---

## 📋 Estado de completitud

Arquetipo **concepto**: el contenido didáctico está completo; la operativa es una guía de construcción a ejecutar.

| Componente | Estado | Notas |
|-----------|--------|-------|
| `docs/technique.md` | ✅ | Modelo C2, listeners, staged/stageless, OPSEC, tabla CS↔Sliver |
| `docs/emulation.md` | ✅ | Framing Lazarus (C2 propio, rotación infra) + tabla de honestidad técnica |
| `docs/detection.md` | ✅ | JA3/JARM, beaconing, anomalías de proceso, Sysmon, Sigma/KQL |
| `docs/lessons.md` | ✅ | Lecciones del bloque |
| `docs/execution/` (Paso 1-6) | 🔧 | Secuencia de construcción del kit — se ejecuta en tu lab |
| `report/OPERATION_BLACK_BEACON.md` | 🔧 | Reporte tras montar el kit |

---

## 🔧 Regla de construcción

**Teoría, detección y operativa AD** se construyen en este repo.

El **código armado de evasión** (bypass, loader, kit) **NO vive en el repo**: se practica en el laboratorio oficial CRTO con sus kits (Artifact Kit, Resource Kit). 

Aquí documentamos el **por qué** y el **cómo se detecta**, no el binario evasivo.

---

## 📂 Estructura

```
Lab-08-Black-Beacon/
├── README.md                                    # Este archivo
├── docs/
│   ├── technique.md                            # ✅ Modelo C2, listeners, OPSEC, CS↔Sliver
│   ├── emulation.md                            # ✅ Framing Lazarus + honestidad técnica
│   ├── detection.md                            # ✅ Detección EDR, Event IDs, telemetría
│   ├── lessons.md                              # ✅ Lecciones del bloque
│   ├── execution/                              # 🔧 Secuencia de construcción (Paso 1-6)
│   │   ├── team_server.md                      #    Paso 1 · levantar el team server
│   │   ├── listener_http.md                    #    Paso 2 · listener HTTPS
│   │   ├── payloads.md                         #    Paso 3 · staged vs stageless
│   │   ├── execution.md                        #    Paso 4 · payload → baliza
│   │   ├── basic_operability.md                #    Paso 5 · operativa + OPSEC
│   │   └── telemetry.md                        #    Paso 6 · telemetría (Defender ON)
│   └── report/OPERATION_BLACK_BEACON.md        # 🔧 Reporte tras montar el kit
├── loot/                                       # Credenciales, hashes, datos extraídos
├── nmap/                                       # Resultados de escaneo
├── screenshots/FASE-0X-*/                      # Capturas anotadas
└── setup/                                      # Scripts de aprovisionamiento (si aplica)
```

---

## 🎬 Próximos pasos

1. **Leer `technique.md`** — entender modelo C2, listeners, staged/stageless, OPSEC
2. **Leer `detection.md`** — entender cómo se detecta, qué telemetría se genera
3. **Ejecutar fases 01-06** — levantar Sliver, crear listeners, payloads, beacon
4. **Documentar en `execution/`** — cada fase con capturas + comentarios
5. **Reporte final** — `OPERATION_BLACK_BEACON.md` con lecciones

---

*Lab-08 Black Beacon · Fase: Phase-03-Red-Team-Operations · 18/06/2026*