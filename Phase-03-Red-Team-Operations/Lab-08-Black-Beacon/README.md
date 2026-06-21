# Lab-08 · Black Beacon — C2 Foundations

> Fase: `Phase-03-Red-Team-Operations` · Estado: ⏳ En progreso (theory + detection completos)  
> Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

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

| Componente | Estado | Notas |
|-----------|--------|-------|
| `README.md` (ficha) | ✅ | Este archivo |
| `theory.md` | ✅ | 8 secciones, 280+ líneas. Modelo C2, tipos listener, OPSEC, tabla CS↔Sliver |
| `detection.md` | ✅ | 10 secciones, 320+ líneas. Cómo detecta EDR, Event IDs, OPSEC implications |
| `execution/` (6 fases) | ⏳ | Pendiente: levantar Sliver, listeners, payloads, telemetría |
| `lessons_learned.md` | ⏳ | Pendiente: llenar tras ejecutar |
| `OPERATION_BLACK_BEACON.md` | ⏳ | Pendiente: reporte final |

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
│   ├── theory/theory.md                        # ✅ Modelo C2, listeners, OPSEC, CS↔Sliver
│   ├── detection/detection.md                  # ✅ Detección EDR, Event IDs, telemetría
│   ├── execution/
│   │   ├── fase-01-team-server.md              # ⏳ Levantar Sliver
│   │   ├── fase-02-listener-https.md           # ⏳ Crear listener HTTPS
│   │   ├── fase-03-payloads.md                 # ⏳ Staged vs stageless
│   │   ├── fase-04-ejecucion.md                # ⏳ Payload → beacon
│   │   ├── fase-05-operativa-basica.md         # ⏳ Comandos, sleep/jitter
│   │   └── fase-06-telemetria.md               # ⏳ Observar con Defender ON
│   ├── analysis/lessons_learned.md             # ⏳ Lecciones del lab
│   └── report/OPERATION_BLACK_BEACON.md        # ⏳ Reporte final
├── loot/                                       # Credenciales, hashes, datos extraídos
├── nmap/                                       # Resultados de escaneo
├── screenshots/FASE-0X-*/                      # Capturas anotadas
└── setup/                                      # Scripts de aprovisionamiento (si aplica)
```

---

## 🎬 Próximos pasos

1. **Leer `theory.md`** — entender modelo C2, listeners, staged/stageless, OPSEC
2. **Leer `detection.md`** — entender cómo se detecta, qué telemetría se genera
3. **Ejecutar fases 01-06** — levantar Sliver, crear listeners, payloads, beacon
4. **Documentar en `execution/`** — cada fase con capturas + comentarios
5. **Reporte final** — `OPERATION_BLACK_BEACON.md` con lecciones

---

*Lab-08 Black Beacon · Fase: Phase-03-Red-Team-Operations · 18/06/2026*