# 📐 REPOSITORY_STANDARDS.md — Estándar del producto

> Define el estándar de calidad, consistencia y gobernanza del repositorio. Su objetivo es que el repo se
> lea y se mantenga como un **producto serio y de referencia**, no como una colección de writeups.
>
> Ubicación: `docs/standards/REPOSITORY_STANDARDS.md` · Versión: 1.0 · Fecha: 18/06/2026

---

## 0. Decisiones tomadas (registro)

Estas decisiones se aplican a partir de v3.0 y quedan fijadas como estándar:

1. **Plan canónico:** Roadmap v3.0 (18 labs) es el plan. `docs/design/ROADMAP.md` es la única fuente de verdad.
2. **Anatomía de lab fija** (§2). Toda nueva carpeta de lab la genera `scaffold-v3` para garantizar consistencia.
3. **Detección obligatoria:** cada técnica ofensiva se documenta con su contraparte de detección. Sin excepción.
4. **Equivalencia CS↔Sliver obligatoria** en cada `theory.md` de los labs nuevos.
5. **Documentación honesta:** los fallos se documentan con la misma profundidad que los éxitos.
6. **Posicionamiento de uso responsable** (§5): laboratorio aislado, organización ficticia, sin distribución
   de payloads armados. La implementación de evasión se practica en el curso oficial CRTO, no en el repo.
7. **Gobernanza y versionado** (§6): SemVer para el diseño; `ROADMAP`/`PROGRESS`/`README` sincronizados.

---

## 1. Principios de calidad

- **Consistencia > volumen.** Mejor menos contenido impecable y uniforme que mucho desigual.
- **Cert-first, depth-first.** Cada pieza existe para preparar el examen, en profundidad.
- **Trazabilidad.** Toda técnica → MITRE ID, lab, y su detección.
- **Reproducibilidad.** Setup scripteado, infraestructura documentada, comandos verificables.
- **Credibilidad.** Fuentes citadas, fallos documentados, alcance y ética explícitos.

---

## 2. Anatomía estándar de un lab

```
Lab-NN-Operacion/
├── README.md                 # Ficha: objetivo · cubre · prepara · valor didáctico
├── docs/
│   ├── theory/theory.md      # Concepto + internals + MITRE + equivalencia CS↔Sliver
│   ├── detection/detection.md# Event IDs, Sysmon, SIGMA/KQL, comportamiento
│   ├── execution/*.md        # Pasos, comandos, capturas, comentarios didácticos
│   ├── analysis/lessons_learned.md
│   └── report/OPERATION_NN.md
├── setup/                    # Scripts de provisión / crown jewels
├── loot/  ├── nmap/  └── screenshots/
```

**Regla de oro:** ningún lab se da por terminado sin `theory`, `detection`, `execution`, `lessons_learned`
y `report` completos.

---

## 3. Estándar de documentación

- **Idioma:** español, con terminología técnica en inglés (Kerberoasting, beacon, trust…).
- **Capturas:** `faseXX-NN-descripcion.png` dentro de `screenshots/FASE-XX-Nombre/`. Anotación con recuadros.
- **Comentario didáctico** por captura, estilo `// qué demuestra técnicamente`.
- **MITRE:** toda técnica con `Táctica · Técnica · Sub-técnica · ID · Herramienta`.
- **Detección:** por técnica, al menos un Event ID o regla y la lógica (firma vs comportamiento).
- **Sin payloads armados** en el texto (ver §5): se documenta el *qué* y el *por qué*, no el binario evasivo.

---

## 4. Definition of Done (por lab)

Un lab está "terminado" cuando cumple **todo**:

- [ ] `README.md` con ficha completa.
- [ ] `theory.md` con internals + MITRE + equivalencia CS↔Sliver.
- [ ] `detection.md` con detección por técnica.
- [ ] `execution/` con pasos, capturas anotadas y comentarios.
- [ ] `lessons_learned.md` con límites, fallos y alternativas.
- [ ] `report/OPERATION_NN.md` con el reporte de la operación.
- [ ] `PROGRESS.md`, `MITRE_MAPPING.md` y la matriz de `ROADMAP.md` actualizados.

---

## 5. Posicionamiento de uso responsable (scope & ethics)

Este apartado **da credibilidad** al repo y delimita su alcance como producto serio:

- **Entorno 100% aislado.** Todo se ejecuta contra VMs locales de una organización **ficticia** (ATACKCORP S.L.).
- **Fin exclusivamente educativo** y de preparación de certificación.
- **No se distribuyen payloads armados** (loaders, bypasses, crypters, kits de evasión). El repo documenta
  el **fundamento** de cada técnica y **cómo se detecta**; la implementación evasiva se aprende y practica
  en el **laboratorio oficial CRTO** (Cobalt Strike + Artifact/Resource Kit), bajo su licencia.
- **Blue team integrado.** Cada técnica ofensiva viene con su detección — el repo sirve igual a red y purple.

> Este alcance no es una limitación: es lo que diferencia un recurso de referencia de un volcado de exploits.
> Los repos serios del sector se posicionan exactamente así.

---

## 6. Gobernanza y versionado

- **SemVer del diseño** en `DESIGN.md` (v3.0 actual).
- **Fuente de verdad:** `ROADMAP.md`. `README.md` y `PROGRESS.md` la referencian, no la duplican.
- **CHANGELOG** actualizado por cada cambio estructural.
- **Sincronía:** cualquier cambio de plan se refleja a la vez en ROADMAP + PROGRESS + README.

---

## 7. Backlog de madurez (priorizado)

**P0 — hecho / en curso**
- ✅ Roadmap v3.0 (fuente de verdad) · ✅ Estructura 08–18 scripteada · ✅ Este estándar · ✅ Guía de estudio.

**P1 — siguiente**
- Retrofit de Labs 01–07 al estándar (añadir `detection.md` y `README` ficha donde falten).
- Sincronizar `README.md` (enlazar ROADMAP, 18 labs) y `PROGRESS.md` (tabla a 18 labs).
- `GLOSSARY.md` y `REFERENCES.md` (bibliografía: MITRE, papers, blogs de referencia).
- Validar contenido de Lab-05 y alcance ADCS de Lab-03 (cerrar matriz).

**P2 — después**
- Arrancar Lab-08 (`theory.md` + `detection.md`) y seguir el roadmap.
- Librería consolidada de reglas de detección (SIGMA) transversal.
- Checklist de "doc-lint" para validar el Definition of Done antes de cada commit.

---

*Estándar del producto v1.0 · 18/06/2026*