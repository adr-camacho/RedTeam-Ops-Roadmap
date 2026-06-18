# 🎓 STUDY_GUIDE.md — Cómo usar este repo para preparar CRTO

> Guía didáctica: cómo estudiar con el repo, en qué orden, y una **autoevaluación** por tema para saber
> cuándo estás listo para el examen.
>
> Ubicación: `docs/learning/STUDY_GUIDE.md` · Fecha: 18/06/2026

---

## 1. Filosofía de estudio

El examen CRTO no premia memorizar comandos: premia **operar con criterio y sin ruido** en un entorno
multi-dominio con Defender activo. Por eso este repo prioriza *entender por qué* y *cómo se detecta*, no
solo *cómo se lanza*. El método que mejor funciona para CRTO, validado por quienes aprueban, tiene cuatro pasos:

1. **Leer y anotar** el tema con tus palabras (teoría primero).
2. **Practicar con defensas apagadas** para fijar la mecánica del ataque.
3. **Repetir con Defender/AppLocker activos** para adquirir el reflejo OPSEC.
4. **Consolidar en una wiki de técnicas** buscable (pre-requisitos · enumeración · pasos · limpieza · detección).

Este repo es esa wiki, estructurada y orientada al temario.

---

## 2. Ruta de estudio recomendada

| Etapa | Labs | Qué consolidas |
|------|------|----------------|
| **Fundamentos AD** | 01–07 (✅) | Kerberos, ACLs, ADCS, LAPS, DPAPI, GPO, DCSync, pivoting |
| **Operativa de C2 y host** | 08–10 | Modelo C2, acceso inicial, persistencia y priv-esc de host |
| **Evasión** | 11–12 | Defender/AMSI/ETW y AppLocker/CLM/LOLBAS (entender y detectar) |
| **Maestría AD** | 13–15 | MSSQL, domain dominance/persistencia, trusts |
| **C2 avanzado y cierre** | 16–17 | Extender C2 (BOFs/Malleable/Aggressor), exfil y reporte |
| **Examen** | 18 | Simulación completa, Defender ON, por objetivos |

> Recomendación: no avances de etapa sin tener la **autoevaluación** (§3) de la anterior en verde.

---

## 3. Autoevaluación por tema (¿lo dominas sin ayuda?)

> Marca solo lo que harías **sin notas**. Cada ítem enlaza al lab donde se entrena.

**C2 y operativa (Lab-08/09)**
- [ ] Levanto team server y elijo el listener adecuado según objetivo y OPSEC.
- [ ] Gestiono beacons (sleep/jitter), entiendo staged vs stageless.
- [ ] Traduzco una acción de Cobalt Strike a su equivalente en Sliver y viceversa.
- [ ] Hago situational awareness de un host recién comprometido y decido el siguiente paso.

**Host (Lab-10)**
- [ ] Establezco persistencia de host eligiendo el mecanismo con mejor relación sigilo/fiabilidad.
- [ ] Escalo privilegios localmente y sé qué telemetría genero al hacerlo.

**Evasión (Lab-11/12)**
- [ ] Explico cómo funcionan AMSI/ETW y por qué una acción concreta dispara (o no) Defender.
- [ ] Sé diagnosticar *por qué* he perdido un beacon y cómo ajustar para no perderlo.
- [ ] Ejecuto bajo AppLocker/CLM identificando rutas permitidas y LOLBAS válidos.

**Maestría AD (Lab-13/14/15)**
- [ ] Enumero MSSQL y encadeno linked servers para moverme/escalar.
- [ ] Elijo la variante de ticket (Golden/Silver/Diamond) según objetivo y detectabilidad.
- [ ] Abuso de trusts inbound/outbound y escalo entre forests entendiendo SID filtering.

**Cierre (Lab-16/17/18)**
- [ ] Adapto un perfil Malleable C2 para reducir footprint y justifico cada opción.
- [ ] Localizo y exfiltro el dato objetivo y produzco un reporte de engagement.
- [ ] Completo una cadena multi-dominio con Defender ON dentro de un tiempo acotado.

> **Listo para el examen** cuando toda esta lista está en verde y has hecho al menos una pasada del Lab-18.

---

## 4. Simulacro de examen (Lab-18)

Reproduce las condiciones reales: *assumed breach*, multi-dominio, **Defender activo**, objetivos por
resultado y presión de tiempo (el examen se desarrolla en una ventana de varios días con horas activas).
Consejos:

- **Si te atascas, pivota de enfoque** en lugar de forzar una técnica: prueba otra vía de Kerberos, otro
  método de lateral o un perfil de C2 más silencioso.
- **Micro-playbooks:** ten, por técnica, una secuencia de 5–10 pasos (comando + razón) lista para ejecutar.
- **OPSEC constante:** antes de cada acción, pregúntate qué log genera y si hay una vía más silenciosa.

---

## 5. Material complementario

- **Curso oficial Red Team Ops (ZPS):** es el vehículo de la parte específica de Cobalt Strike (Artifact/
  Resource Kit, Malleable C2, BOFs) y de la evasión práctica. Este repo lo complementa, no lo sustituye.
- **MITRE ATT&CK:** para mapear y entender el comportamiento de cada técnica (ver `MITRE_MAPPING.md`).
- **Profundización opcional** (más allá de CRTO): rutas tipo OSEP / cursos de maldev para primitivas de
  bajo nivel — fuera del alcance del examen, pero útiles a largo plazo.

---

*Guía de estudio · 18/06/2026*