# 📐 REPOSITORY_STANDARDS.md — Estándar del producto

> Define el estándar de calidad, consistencia y gobernanza del repositorio. Su objetivo es que el repo se
> lea y se mantenga como un **producto serio y de referencia**, no como una colección de writeups.
>
> Ubicación: `docs/standards/REPOSITORY_STANDARDS.md` · Versión: 3.1 · Fecha: 19/06/2026

---

## 0. Decisiones tomadas (registro)

Estas decisiones quedan fijadas como estándar a partir de v3.1:

1. **Plan canónico:** Roadmap 18 labs. `docs/design/ROADMAP.md` es la única fuente de verdad.
2. **Modelo de dos ejes** (§3): el objetivo didáctico fija el alcance; el adversario da contexto, nunca alcance.
3. **Anatomía de lab fija** (§3), naming de industria. Toda carpeta de lab la genera `scaffold-v3`.
4. **Perfil de adversario de fuente única** (§8): se escribe una vez en `docs/adversaries/`; los labs lo heredan.
5. **Detección obligatoria:** cada técnica ofensiva se documenta con su contraparte de detección. Sin excepción.
6. **Equivalencia CS↔Sliver obligatoria** en el `technique.md` de cada lab.
7. **Documentación honesta:** los fallos se documentan con la misma profundidad que los éxitos.
8. **Posicionamiento de uso responsable** (§8): laboratorio aislado, organización ficticia, sin distribución
   de payloads armados. La implementación de evasión se practica en el curso oficial CRTO, no en el repo.
9. **Gobernanza y versionado** (§8): SemVer para el diseño; `ROADMAP`/`PROGRESS`/`README` sincronizados.

---

## 1. Principios de calidad

- **Consistencia > volumen.** Mejor menos contenido impecable y uniforme que mucho desigual.
- **Cert-first, depth-first.** Cada pieza existe para preparar el examen CRTO, en profundidad.
- **Responsabilidad única.** Cada lab construye **una** capability del temario; cada módulo (`execution/`) practica **un** paso.
- **Trazabilidad.** Toda técnica → MITRE ID, lab, y su detección.
- **Reproducibilidad.** Setup scripteado, infraestructura documentada, comandos verificables.
- **Credibilidad.** Fuentes citadas, fallos documentados, alcance y ética explícitos.
- **Naming de industria.** Se usa la jerga real del oficio; nada de nomenclatura inventada por el repo (ver §7).

---

## 2. Qué es un lab — responsabilidad única

**Un lab = una _capability_ del temario CRTO.** No una técnica suelta (eso es un módulo), ni un conjunto de
conceptos inconexos (eso sobrecarga). La capability se enseña y se practica a través de **la kill-chain más
limpia que la ejercite de principio a fin**. La kill-chain es la *forma*; la capability es la *responsabilidad*.

> La kill-chain es el examen, no la asignatura. La asignatura es la capability.

**Test de la frase (responsabilidad única).** *"¿Qué me capacita este lab?"* debe responderse con **una** frase,
sin "y además". Si aparece un "y además" de un eje distinto, el lab tiene más de una responsabilidad y se parte.

**Dos tipos de lab** (la responsabilidad es distinta en cada uno):
- **Fundamento:** la responsabilidad es **una capability**; la kill-chain es el vehículo para demostrarla. Las
  técnicas de soporte (recon, escalada puntual) están al servicio de esa única capability, no son responsabilidades añadidas.
- **Integración (capstone):** la responsabilidad **es encadenar** — operar de principio a fin por objetivo
  componiendo capabilities ya aprendidas. Aquí la kill-chain completa *sí es* la responsabilidad.

**Grano = temario, no aritmética.** No es "una capability = un lab" mecánico: el lab agrupa la unidad de
competencia que el temario CRTO trata como bloque coherente. Dos capabilities muy acopladas (p. ej. Silver +
Diamond tickets) pueden ir juntas si se entienden mejor en contraste; el árbitro es el test de la frase.

**Assumed-breach.** Muchos labs no son una cadena externo→DA completa, sino un **segmento** que arranca con un
beacon dado y ejercita la capability hasta su objetivo local — igual que el examen CRTO.

**Excepción — labs de onboarding.** Un lab de *onboarding* (p. ej. `Lab-00 C2 Primer`) es la **única**
excepción a la anatomía completa: **sin eje de adversario** y con documentación reducida (`README` + guías de
`setup`/`operación` + capturas). Su responsabilidad es **preparar al operador**, no ejercitar una capability del
temario, por lo que no lleva `technique`/`emulation`/`detection`/`report`. Se marca explícitamente como onboarding.

**Lo que entrega un lab**, atado a esa única capability:
- **Enseña** (comprensión): concepto e internals (`technique.md`), por qué el adversario lo usa (`emulation.md`), cómo se detecta (`detection.md`).
- **Aprende** (juicio del operador): por qué *esta* técnica aquí, qué habilita, qué alternativas había, cuándo aplicarla.
- **Practica** (ejecución): la kill-chain hands-on (`execution/`) en orden de dependencia, con artefactos reales y report.

---

## 3. Modelo de dos ejes

Cada lab se define sobre dos ejes que **no se mezclan**:

| Eje | Qué es | Qué fija | Dónde vive |
|-----|--------|----------|-----------|
| **Didáctico** (primario) | La capability del temario CRTO que el lab construye (p. ej. *C2 Foundations*, *ACL Abuse*) | El **alcance** (scope) del lab. Su responsabilidad única. | `technique.md` + `execution/` |
| **Emulación** (secundario) | El adversario real cuyo comportamiento da escenario y realismo | El **contexto/guion**, nunca el alcance | `emulation.md` (→ `docs/adversaries/`) |

**Regla de oro:** *el objetivo didáctico manda; el adversario es el guion.* Nunca se amplía el alcance de un
lab para "encajar" una TTP del actor; se elige del repertorio del actor lo que sirve al objetivo.

**La profundidad de la emulación escala con el tipo de lab.** Un lab de tooling/fundamentos (p. ej. montar
team server y listeners) lleva el adversario como escenario de un párrafo; un lab de ataque (initial access,
evasión, dominance) lleva mapeo TTP completo. No se fuerza un guion de adversario sobre un lab puramente de
herramienta.

---

## 4. Anatomía estándar de un lab (v3.1)

Naming alineado a la industria (ver §7). Lo genera `scaffold-v3`.

```
# NIVEL REPO (compartido, una vez)
docs/adversaries/<ACTOR>.md     # Adversary Profile / Intelligence Summary  (§4)

# NIVEL LAB
Lab-NN-Operacion/
├── README.md                   # Ficha: objetivo didáctico · scope · escenario (actor)
├── OPERATION_<NOMBRE>.md        # Operations flow + executive summary de la operación
├── docs/
│   ├── technique.md             # Base técnica del/los TTP: concepto · internals · MITRE · CS↔Sliver
│   ├── emulation.md             # Emulation plan: subconjunto de TTPs del actor + por qué · enlace al perfil
│   ├── detection.md             # Detection guidance: Event IDs · Sysmon · SIGMA/KQL · hardening
│   ├── execution/               # Operator log: un .md por fase/módulo, de principio a fin
│   │   ├── 01_<modulo>.md
│   │   ├── 02_<modulo>.md
│   │   └── ...
│   ├── lessons_learned.md        # Qué funcionó, qué falló y por qué; límites y alternativas
│   └── report/                   # Engagement report (exec summary · findings · evidence · remediation)
│       └── <NOMBRE>.pdf
├── setup/                       # Provisión específica del lab (crown jewels canónicos en setup/CrownJewels/ del repo)
├── loot/                        # Hashes, tickets y credenciales capturadas (ficticias, lab)
├── nmap/                        # Outputs de escaneo (.nmap/.gnmap/.xml)
└── screenshots/
    └── FASE-XX-Nombre/          # Evidencia por fase
```

### Módulo / operator log — cabecera estándar

Cada archivo de `execution/` es **un módulo con responsabilidad única** y abre con esta cabecera, que hace
explícita la dependencia y el orden (el "por qué A antes que B"):

```markdown
# Módulo NN — <nombre>
- **Objetivo único:** <qué consigue este módulo, una frase>
- **Prerequisito:** <qué módulo previo lo habilita> (o "ninguno")
- **Habilita:** <qué desbloquea para el siguiente módulo>
- **TTP:** <Táctica · Técnica · Sub-técnica · ID> · **Herramienta:** <...>
```

**Regla de oro:** ningún lab se da por terminado sin `technique`, `emulation`, `detection`, `execution`,
`lessons_learned` y `report` completos, y con el perfil del adversario existente en `docs/adversaries/`.

---

## 5. Modelo de adversario — perfil de fuente única + herencia

Para emular varios labs del mismo actor (p. ej. APT28 en Labs 04–07) **sin repetir** su perfil:

- **Clase base — `docs/adversaries/<ACTOR>.md`** (Adversary Profile / Intelligence Summary). Se escribe **una
  vez**: atribución, motivación, sectores objetivo, repertorio TTP completo, doctrina (por qué opera así) y
  referencias (MITRE G-id, CISA, informes). Material perdurable e independiente del lab.
- **Especialización — `Lab-NN/docs/emulation.md`**. **No** re-explica al actor: lo **enlaza** y solo añade qué
  subconjunto de sus TTPs reproduce *este* lab, por qué encaja con el objetivo didáctico, y el mapeo a una
  campaña/comportamiento real.

**Regla de fuente única:** ningún dato del perfil del adversario se duplica dentro de un lab. Si se repite en
dos sitios, va al perfil base y el lab lo referencia.

---

## 6. Estándar de documentación

- **Naming de industria (obligatorio).** Se usa la jerga del oficio, no nomenclatura inventada:

  | Artefacto | Término de industria | Archivo |
  |-----------|----------------------|---------|
  | Perfil del actor | Adversary Profile / Intelligence Summary | `docs/adversaries/<ACTOR>.md` |
  | Plan de emulación del lab | Emulation Plan | `emulation.md` |
  | Base técnica del TTP | Technique reference | `technique.md` |
  | Guía defensiva | Detection guidance | `detection.md` |
  | Registro paso a paso | Operator log | `execution/*.md` |
  | Resumen de la operación | Operations flow + Executive summary | `OPERATION_*.md` |
  | Entregable final | Engagement report | `report/` |

  Términos correctos del oficio que el repo ya usa y se mantienen: **TTP, kill chain, OPSEC, crown jewels,
  rules of engagement / scope, lessons learned, executive summary, findings, remediation, IOCs**. Las
  operaciones con **nombre clave** (GHOST FOREST…) son práctica real y se mantienen.
  > `tradecraft.md` se **reserva** para su sentido real (craft/OPSEC del operador) y es **opcional**, no para
  > el perfil del adversario. Encaja sobre todo en Phase-03 (evasión).

- **Idioma:** español, con terminología técnica en inglés (Kerberoasting, beacon, trust…).
- **Capturas:** `faseXX-NN-descripcion.png` dentro de `screenshots/FASE-XX-Nombre/`. Anotación con recuadros.
- **Comentario didáctico** por captura, estilo `// qué demuestra técnicamente`.
- **MITRE:** toda técnica con `Táctica · Técnica · Sub-técnica · ID · Herramienta`.
- **Detección:** por técnica, al menos un Event ID o regla y la lógica (firma vs comportamiento).
- **Sin payloads armados** en el texto (ver §7): se documenta el *qué* y el *por qué*, no el binario evasivo.

---

## 7. Definition of Done (por lab)

Un lab está "terminado" cuando cumple **todo**:

- [ ] `README.md` con ficha (objetivo didáctico · scope · escenario).
- [ ] `technique.md` con concepto + internals + MITRE + equivalencia CS↔Sliver.
- [ ] `emulation.md` con el subconjunto de TTPs del actor y enlace a su perfil en `docs/adversaries/`.
- [ ] `detection.md` con detección por técnica (Event ID/regla + lógica) y hardening.
- [ ] `execution/` con módulos (cabecera de dependencia), capturas anotadas y comentarios.
- [ ] `lessons_learned.md` con límites, fallos y alternativas.
- [ ] `report/` con el engagement report (exec summary · findings · evidence · remediation).
- [ ] Perfil del adversario presente en `docs/adversaries/`.
- [ ] `PROGRESS.md`, `MITRE_MAPPING.md` y la matriz de `ROADMAP.md` actualizados.

---

## 8. Posicionamiento de uso responsable (scope & ethics)

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

## 9. Gobernanza y versionado

- **SemVer del diseño** en `DESIGN.md` (v3.1 actual).
- **Fuente de verdad:** `ROADMAP.md` (plan) y `docs/adversaries/` (perfiles de actor). El resto referencia, no duplica.
- **CHANGELOG** actualizado por cada cambio estructural.
- **Sincronía:** cualquier cambio de plan se refleja a la vez en ROADMAP + PROGRESS + README.
- **doc-lint** (objetivo): validar el Definition of Done y la sincronía de contadores antes de cada commit.

---

## 10. Backlog de madurez (priorizado)

**P0 — hecho / en curso**
- ✅ Roadmap 18 labs (fuente de verdad) · ✅ Estándar v3.1 (anatomía + dos ejes + adversario) · ✅ Guía de estudio.

**P1 — siguiente**
- Aplicar anatomía v3.1 a Labs 01–07: fusionar `theory`/`tradecraft` → `technique.md`, crear `emulation.md`,
  migrar `analysis/mitigations.md` → `detection.md`, cabeceras de módulo en `execution/`, fichas README.
- Crear perfiles base en `docs/adversaries/` (APT29, APT41, APT28; luego Lazarus, APT10).
- Rebalanceo Phase-01: recortar Lab-01 a su kill-chain y añadir on-ramp (Lab-00 primer).
- Sincronizar README/PROGRESS y cerrar `GLOSSARY.md` / `REFERENCES.md`.

**P2 — después**
- `scaffold-v3` genera la anatomía v3.1 exacta.
- **doc-lint como suite de tests** (elevado): tests de estructura (DoD), integridad referencial (sin enlaces rotos), consistencia (contadores ↔ fuente de verdad), convención (naming) y herencia (cada `emulation.md` enlaza a un perfil existente).
- Construir Labs 08–18 al estándar (Lazarus / APT10), con objective-based ops y reporting.

**P3 — credibilidad y mantenibilidad** *(registrado; no urgente)*
- Afirmaciones defensivas con **fecha de validación + fuente** (KB/CVE/build) — su mayor activo de credibilidad.
- **Threat model del repo como producto público** (no solo del entorno de lab): posicionamiento ético explícito.
- **Trazabilidad bidireccional** capability ↔ examen (índice navegable temario→lab y viceversa).
- **Estado de madurez por lab** (borrador / completo / validado-v3.1 + fecha).
- Sección **"Cómo usar este repositorio"** (rutas por perfil: estudiante / reclutador / red teamer).

**Herencia — extensiones aprobadas** *(aplicar al construir)*
- Heredar (clase base → especialización): infra (`LAB_INFRASTRUCTURE`), arsenal (`ARSENAL`), telemetría base (`DETECTION_LIBRARY`), tabla maestra CS↔Sliver, OPSEC genérico (`OPSEC_NOTES`).
- Límite anti-indirección: heredar lo estable e idéntico; mantener local lo pedagógico y específico.
- Principios de software nombrados en `DESIGN.md` solo donde aportan intención real (SRP, Open/Closed, DIP, Template Method, Composite, Facade).

---

## Apéndice A — Plantilla: Adversary Profile (`docs/adversaries/<ACTOR>.md`)

```markdown
# <ACTOR> — Adversary Profile / Intelligence Summary
- **Alias:** <Cozy Bear, ...>   · **MITRE Group:** <G00xx>   · **Atribución:** <país / agencia>
- **Motivación:** <espionaje / financiera / sabotaje>   · **Sectores objetivo:** <...>

## Doctrina — cómo y por qué opera
<Qué caracteriza su forma de operar y por qué elige esas TTPs y no otras.>

## Repertorio TTP (MITRE ATT&CK)
| Táctica | Técnica | ID | Notas |
|---------|---------|----|-------|

## Campañas / referencias
- MITRE ATT&CK Groups: <enlace>   · CISA / informes: <enlaces>

## Labs que lo emulan
<Lab-NN ...>  (cada uno especializa en su emulation.md)
```

## Apéndice B — Plantilla: Emulation Plan del lab (`Lab-NN/docs/emulation.md`)

```markdown
# Emulation Plan — <OPERACIÓN> (<ACTOR>)
> Perfil del actor: ../../docs/adversaries/<ACTOR>.md  (no se repite aquí)

## TTPs de <ACTOR> que emula ESTE lab
| TTP | MITRE ID | Por qué encaja con el objetivo del lab |
|-----|----------|-----------------------------------------|

## Mapeo a comportamiento/campaña real
<Cómo se corresponde lo que hacemos en el lab con una operación real del actor.>
```

---

*Estándar del producto v3.1 · 19/06/2026*
