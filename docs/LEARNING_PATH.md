# 🧭 LEARNING_PATH.md — Ruta de aprendizaje (grafo de dependencias)

> **Propósito.** Fijar el **orden** en que se recorren las capabilities y **por qué ese orden y no otro**: cada
> capability se introduce en el punto donde un límite anterior la hace necesaria. Define la secuencia de labs
> como un grafo de dependencias, no como una numeración.
>
> Complementa: `CRTO_COVERAGE.md` (qué cubre cada lab) y `REPOSITORY_STANDARDS.md §2` (qué es un lab).
> Modelo elegido: **lineal por capas, con ganchos explícitos a la evasión** (ver §4).
>
> Ubicación: `docs/design/LEARNING_PATH.md` · Versión: 1.0 · Fecha: 19/06/2026

---

## 1. Principio de ordenación

**Una capability va después de otra si la primera genera su prerequisito, o si el muro contra el que choca la
primera es justo lo que la segunda derriba.** El orden lo fija el **grafo de dependencias**, no el número de lab.

Cada lab, al terminar, deja un **muro** explícito ("hasta aquí llegó y por qué paró") que es el gancho del
siguiente. Así una capability ilumina a la próxima y le da sentido retroactivo a la anterior.

---

## 2. Los tres motores de progresión

Lab a lab crecen tres cosas a la vez. Se documentan donde se indica:

| Motor | Qué es | Dónde vive |
|-------|--------|-----------|
| **Muro** | Por qué la kill-chain paró: sin escalada, objetivo local, faltó una credencial, el salto exigía otra capability | `lessons_learned.md` → "hasta dónde llegó y por qué" |
| **Botín** | Cómo un movimiento revaloriza objetivos pasados: el foothold "absurdo" de ayer es el prerequisito del botín de hoy | `OPERATION_*.md` (crown jewels) |
| **Juego** | De kill-chain lineal (un camino) a varios caminos al mismo objetivo → aparece la **decisión** (sigilo, artefactos, evasión) | `emulation.md` + OPSEC del lab |

La curva objetivo: de un botín minúsculo (un usuario sin privilegios) a la exfiltración de los activos críticos
de la empresa, entendiendo en cada paso el **cómo · por qué · hasta dónde · por qué no más · qué haría falta para seguir**.

---

## 3. El recorrido por tramos (grafo de dependencias)

Cada tramo deriva del muro del anterior.

### Tramo 0 — Saber operar
**Capabilities:** modelo de C2 (beacon, listener, OPSEC básico).
**Muro que resuelve:** no puedes ejecutar ni documentar nada sin entender la herramienta con la que operas.
**Habilita:** que toda kill-chain posterior use C2 *después* de haberlo explicado (resuelve el hallazgo F5).

### Tramo 1 — Entrar y orientarse
**Capabilities:** Initial Access → Host Reconnaissance.
**Muro:** tienes un punto de apoyo, pero a ciegas y sin privilegios.
**Botín:** un foothold mínimo.

### Tramo 2 — Convertir el foothold en algo
**Capabilities:** Credenciales (roasting, password cracking) → Movimiento lateral.
**Muro del tramo 1 que derriba:** estabas atrapado en un host; con credenciales te mueves.
**Hito:** la primera kill-chain AD limpia e integrada (el Lab-01 recortado).

### Tramo 3 — Profundizar el dominio del directorio
**Capabilities:** ACL abuse → Delegación/tickets → ADCS → Group Policy → LAPS/DPAPI.
**Muro:** moverte no basta; necesitas *poseer* el directorio, y cada misconfiguración es una **ruta distinta** a DA.
**Juego:** primera vez que hay varias rutas al mismo objetivo → el alumno empieza a **elegir ruta**.

### Tramo 4 — Permanecer y dominar
**Capabilities:** Domain Dominance (Golden/DSRM) → Forest & Trusts → MSSQL.
**Muro:** tienes DA hoy, pero lo pierdes con una rotación de contraseña; y el dominio no es el límite, hay otros bosques.
**Botín:** salta de "un dominio" a "el bosque / la empresa".

### Tramo 5 — Operar contra defensas reales
**Capabilities:** Evasión Defender/AMSI/ETW → AppLocker/CLM → Extending the C2 (BOFs/Malleable).
**Muro:** todo lo anterior se hizo con las defensas relajadas; en real, el EDR te ve.
**Juego (máximo):** mismas capabilities, ahora con un **oponente activo** → el ajedrez real.

### Tramo 6 — Cerrar la operación
**Capabilities:** Exfiltración → Reporting → Capstone (Defender ON).
**Muro:** comprometer no es el trabajo; exfiltrar el activo objetivo y comunicarlo, sí.
**Cierre:** integración de todo (lab de integración).

---

## 4. La doble pasada — "off, then on" (modelo lineal con ganchos)

Los tramos **1–4 se aprenden con las defensas relajadas** (para entender la mecánica pura); el **tramo 5
re-recorre** esas mismas capabilities con el oponente despierto. Es como enseña CRTO: *primero con las
herramientas apagadas, luego encendidas* — lo que convierte "sé hacer la técnica" en "sé hacerla sin que me vean".

**Modelo elegido: A) lineal por capas, con ganchos.** Se mantiene el orden lineal (una pasada por tema, simple
de seguir y construir), pero **cada lab del tramo 5 referencia explícitamente** qué lab anterior re-visita y
"ahora con Defender ON". Se consigue el efecto espiral sin duplicar visitas ni complicar el grafo.

> Implementación del gancho: en el `README`/`emulation.md` del lab de evasión, una línea
> *"Re-visita: Lab-NN (capability X), ahora con Defender ON · qué cambia: …"*.

---

## 5. Orden de labs resultante (a validar contra el rediseño de Phase-01)

| Tramo | Labs (orden de dependencia) |
|-------|------------------------------|
| 0 | C2 primer (`Lab-00`) |
| 1 | Initial Access · Host Recon |
| 2 | Credenciales/roasting · Lateral  → **primera kill-chain AD integrada (Lab-01 recortado)** |
| 3 | ACL · Delegación/tickets · ADCS · GPO · LAPS/DPAPI |
| 4 | Domain Dominance · Trusts · MSSQL |
| 5 | Evasión Defender/AMSI · AppLocker/CLM · Extending C2 |
| 6 | Exfiltración · Reporting · **Capstone (integración)** |

> El mapeo tramo→números de lab definitivos se cierra en el rediseño de Phase-01 (F1+F5): el `Lab-00` y el
> recorte de Lab-01 son las dos primeras piezas de este grafo.

---

*Ruta de aprendizaje v1.0 · 19/06/2026 · complementa CRTO_COVERAGE.md y REPOSITORY_STANDARDS.md §2*
