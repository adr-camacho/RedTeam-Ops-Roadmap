# PHASE_03_04_DESIGN.md — Diseño del arco Operaciones & Enterprise

## Brújula narrativa-técnica para Labs 08–18

**Versión:** 1.0 | **Fecha:** 25/06/2026 | **Autor:** Adrián Camacho

---

> Este documento es la **fuente de verdad** para el diseño de los Labs 08–18. Define el arco de adversario,
> los dos arquetipos de lab, el principio de honestidad técnica y la ficha de cada lab. Cualquier lab de
> Phase-03/04 que se construya debe encajar aquí. No describe ejecución real: los labs marcados *operación*
> se ejecutan después; su `execution/` es un **plan** hasta que se corre de verdad.

---

## 1. El arco de adversario

Los Labs 01–07 anclaron cada técnica al actor que mejor la ejemplifica en el mundo real (APT29 = sigilo
Kerberos; APT41 = web-a-AD; APT28 = ACL/delegación/cross-forest). Phase-03 y Phase-04 continúan ese principio,
pero con un **ancla por fase** que da hilo narrativo:

| Fase | Adversario ancla | MITRE | Por qué encaja |
|------|------------------|-------|----------------|
| **Phase-03** Red Team Operations | **Lazarus Group** | G0032 | Evasión a medida (ETW patching, in-memory, packing), C2 propio, acceso inicial vía ingeniería social. Es su terreno: el operador **monta y templa su kit** con el rigor de Lazarus. |
| **Phase-04** Enterprise Simulation | **APT10 / Stone Panda** | G0045 | *Operation Cloud Hopper*: compromiso MSP → enterprise a escala, lateral con pass-the-ticket/hash, Mimikatz, exfil vía servicios legítimos. El kit se **despliega** en una operación enterprise completa. |

**Hilo narrativo:** Phase-03 = *forjas y afinas el arsenal de operador* (Lazarus). Phase-04 = *lo despliegas en
una intrusión enterprise de extremo a extremo al estilo Cloud Hopper* (APT10), culminando en el capstone (Lab-18),
donde todo converge bajo condiciones de examen.

---

## 2. Principio de honestidad técnica (no negociable)

Ningún APT real ejecuta el temario CRTO en orden — un currículo de examen no es una campaña real. Para que estos
labs resistan el escrutinio de un revisor profesional, los `emulation.md` se escriben como **emulation plans
reales**, no como teatro:

1. **Cita lo documentado.** Donde el actor ancla usa de verdad una técnica (Lazarus → ETW patching; APT10 →
   pass-the-ticket), se cita con su campaña/fuente.
2. **No fuerces atribuciones falsas.** Donde una técnica es tradecraft universal del operador (ej. Kerberoasting,
   DCSync), se enmarca como **tradecraft estándar que el operador adopta**, no como firma del actor.
3. **Reconoce los exponentes reales.** Para técnicas de AD profundo (Golden/Diamond tickets, forja de trusts), el
   `emulation.md` puede señalar que APT29/APT28 son los exponentes más puros, situando al actor ancla como el
   *vehículo narrativo* de la operación.

Esto da las dos cosas: narrativa coherente y precisión que un revisor de un equipo ofensivo reconoce como rigor.

---

## 3. Los dos arquetipos de lab

Distinción ya presente en los esqueletos (campos `## Estructura` vs `## Regla de construcción`). Se formaliza:

### Arquetipo A — Operación (hands-on)
Se **ejecuta** en el lab propio. Tiene kill-chain, capturas, loot, log real.
- Anatomía v3.1 completa: `technique · emulation · detection · lessons · execution/ · report/`
- `execution/` con cabeceras de módulo y grafo de dependencias (como Labs 01–07).
- **Honestidad:** hasta que Adrián lo ejecute, `execution/` es un **PLAN** marcado como tal; pasa a log real al correrse.
- Labs: **10, 13, 14, 15, 17, 18**.

### Arquetipo B — Concepto / Tradecraft (build-the-understanding)
La práctica de la herramienta vive en el lab del curso CRTO; **aquí se construye el porqué**: teoría, detección,
operativa, decisión de diseño. No depende de una ejecución contra una org.
- Anatomía v3.1 adaptada: `technique · emulation · detection · lessons` + `operativa/` (en vez de kill-chain).
- `emulation.md` aquí = "cómo razona el actor sobre esta capacidad" (ej. cómo evade Lazarus), no una intrusión.
- Entregable **completo** sin esperar ejecución: es comprensión documentada.
- Labs: **08, 09, 11, 12, 16**. (09 es B+: concepto con fuerte componente operativo de enumeración.)

> Ambos arquetipos mantienen los **mismos nombres de archivo** (`technique.md`, `emulation.md`, `detection.md`,
> `lessons.md`) para consistencia y navegabilidad en los 18 labs.

---

## 4. Ficha de diseño por lab

Cada fila: capability (eje didáctico) · arquetipo · cómo aplica el adversario.

### Phase-03 — Lazarus Group (montar y templar el kit)

| Lab | Capability | Arq. | Framing Lazarus |
|-----|-----------|------|-----------------|
| **08 Black Beacon** | Fundamentos de C2: modelo de operador, listeners, staged/stageless, OPSEC, CS↔Sliver | B | Montas tu infraestructura C2 con el rigor de un actor que opera con C2 propio y rota infra constantemente. |
| **09 Situational Awareness** | La primera hora tras caer: host/dominio recon, detección de controles (Defender/AMSI/AppLocker/EDR), árbol de decisión del operador — todo con OPSEC | B+ | Cómo razona un operador sigiloso al aterrizar: qué mirar, qué NO tocar aún, por dónde empezar según el terreno. El acceso inicial externo (phishing) queda fuera: CRTO es assumed breach. |
| **10 Deep Root** | Persistencia de host + escalada local (run keys, servicios, tareas, COM; UAC, token) | A | Lazarus usa scheduled tasks, DLL side-loading, manipulación de token — persistencia documentada. |
| **11 Ghost Signal** | Evasión I: Defender/AMSI/ETW, firma vs comportamiento, modelo de kits | B | **Terreno estrella de Lazarus**: ETW patching, ejecución en memoria, packing/ofuscación. El "porqué" de la evasión. |
| **12 Iron Veil** | Evasión II: AppLocker, Constrained Language Mode, LOLBAS | B | Living-off-the-land para reducir huella; Lazarus combina binarios propios con utilidades del SO. |

### Nota de diseño — por qué no hay lab de acceso inicial externo

CRTO es **assumed breach**: el examen entrega un beacon ya dentro, sin fase de phishing ni explotación de
servicio externo. En el trabajo red team español el acceso inicial suele venir dado por contrato o lo lleva
personal muy senior con infraestructura propia. Por eso **Lab-09 se reconvirtió** de "First Contact / Initial
Access" a **Situational Awareness & Host Recon**: la disciplina de la primera hora (leer el terreno, detectar
controles, decidir sin hacer ruido) es lo más examinable de CRTO y lo que un equipo valora en un junior —
criterio operativo, no solo herramientas. El acceso inicial externo, si se quisiera por completitud, iría como
lab opcional, nunca como pieza central de la preparación.

---

### Phase-04 — APT10 / Cloud Hopper (desplegar en enterprise)

| Lab | Capability | Arq. | Framing APT10 |
|-----|-----------|------|----------------|
| **13 Linked Shadows** | MSSQL: enum, linked servers, xp_cmdshell, lateral vía SQL | A | Lateral a escala enterprise — el corazón de Cloud Hopper (saltar entre organizaciones vinculadas). |
| **14 Golden Throne** | Dominio total y persistencia (Golden/Silver/Diamond, forged certs, DSRM, AdminSDHolder) | A | Dominancia de dominio; *honestidad*: Golden/Diamond son exponente APT29 — APT10 es el vehículo narrativo, tradecraft estándar. |
| **15 Forest Reign** | Abuso de forest y trusts (cross-forest, SID history, SID filtering) | A | Saltar entre dominios/forests = la esencia de Cloud Hopper (MSP→cliente). Encaje narrativo fuerte. |
| **16 Custom Arsenal** | Extender el C2: perfiles Malleable, BOFs, Aggressor | B | Adaptar el kit a OPSEC; reduce footprint como exige operar con Defender ON. |
| **17 Silent Exit** | Exfiltración y reporting: data hunting, staging, exfil, reporte | A | APT10 exfiltra vía servicios legítimos (Dropbox) — exfil documentada. Cierre de engagement profesional. |
| **18 Final Verdict** | Capstone: cadena completa, Defender ON, multi-dominio, por objetivos | A | La operación Cloud Hopper completa de extremo a extremo. Ensayo general del examen CRTO. |

---

## 5. Perfiles de adversario a crear

Siguiendo el molde de `docs/adversaries/APT28.md` (Doctrina · Repertorio TTP · Campañas · Labs que lo emulan),
contrastados con MITRE ATT&CK y CISA/Mandiant:

- `docs/adversaries/Lazarus.md` (G0032) — ancla Phase-03. Énfasis: evasión, C2 propio, acceso inicial.
- `docs/adversaries/APT10.md` (G0045) — ancla Phase-04. Énfasis: Cloud Hopper, lateral enterprise, exfil.

---

## 6. Orden de construcción sugerido

1. Perfiles `Lazarus.md` + `APT10.md` (base de los emulation plans).
2. Phase-03 en orden (08→12): primero el kit, luego acceso/persistencia, luego evasión.
3. Phase-04 en orden (13→17), capstone (18) al final — integra todo lo anterior.

Cada lab pasa por su mini-auditoría de arranque y se entrega con bundle blindado, igual que el retrofit.

---

*Diseño del arco Phase-03/04 · brújula para Labs 08–18 · v1.0*
