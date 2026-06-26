# Technique — Lab-16 Custom Arsenal

> **Capability (eje didáctico):** Extending the C2 — Malleable C2 profiles, BOFs (Beacon Object Files), Aggressor Scripts. Reducir footprint y operar con más OPSEC.
> **Bloque CRTO:** Extending Cobalt Strike (la capa que hace al operador invisible dentro del C2 que ya usa).
> **Arquetipo:** Concepto / Tradecraft — se construye el **porqué** de cada pieza. El código de BOFs/Aggressor **no vive en el repo**: se practica en el laboratorio oficial CRTO.
> **Adversario (escenario):** APT10 / Cloud Hopper — ver [`emulation.md`](emulation.md).

> Ghost Signal (Lab-11) enseñó a evadir el AV/AMSI/ETW. Custom Arsenal enseña a **adaptar el C2 propio** para que su tráfico, su beacon y sus operaciones no parezcan Cobalt Strike por defecto. Son capas distintas: la evasión de Lab-11 protege contra el AV; esto protege contra el analista de red y el EDR que busca patrones de C2 conocidos.

---

## 1. La premisa: Cobalt Strike por defecto es detectable

Un beacon de CS con perfil por defecto genera:
- **Tráfico HTTP/S con patrones de User-Agent, URIs y cabeceras específicos** de CS.
- **Intervalos de sleep predictables** que los IDS/NTA detectan como beaconing.
- **Artefactos en disco** (shellcode, staging) con firmas conocidas.
- **Comportamiento de proceso** (execute-assembly carga el CLR) detectable por EDR.

La solución es **adaptar cada capa** del C2 para que deje de parecerse a sí mismo. Eso es lo que enseña este lab.

## 2. Malleable C2 Profile

Un perfil Malleable es un archivo de configuración que controla **cómo el beacon se comunica y qué artefactos genera**. Permite modelar el tráfico del beacon para que imite a una aplicación legítima conocida (Office365, Slack, Google Analytics, cualquier cosa).

**Qué controla:**

| Sección del perfil | Qué define |
|-------------------|------------|
| `http-get / http-post` | URI, cabeceras, User-Agent, formato del cuerpo |
| `sleeptime / jitter` | Intervalo base y aleatoriedad (anti-beaconing-detection) |
| `stage` | Cómo el beacon se inyecta en memoria, reflective loading |
| `process-inject` | Cómo hace process injection (alloc/write/execute) |
| `post-ex` | Cómo hace `execute-assembly` y SpawnTo |

**Ejemplo conceptual (no código armado):**
Un perfil que imita Office365 define:
- User-Agent de Word/Excel.
- URIs que parecen llamadas a Graph API.
- Cabeceras Authorization con tokens falsos pero plausibles.
- `sleeptime 60000` (1 min) + `jitter 20` (20% de variación).

**Por qué importa en el examen:** un beacon con perfil bien configurado no dispara las reglas NTA/IDS que buscan patrones de CS por defecto. El examen espera que sepas que los perfiles existen y para qué sirven.

## 3. BOFs — Beacon Object Files

**Qué son:** pequeños programas en C compilados como object files que se ejecutan **directamente en el proceso del beacon**, sin crear un nuevo proceso hijo.

**Por qué importan:**
- `execute-assembly` carga el CLR en el proceso — detectable por EDR.
- `shell` / `run` crean un proceso hijo (`cmd.exe`) — muy visible.
- Un **BOF se ejecuta en el contexto del beacon** sin crear proceso hijo, sin cargar el CLR, con footprint mínimo.

**Cuándo usar BOF vs execute-assembly:**

| Situación | execute-assembly | BOF |
|-----------|-----------------|-----|
| Herramienta .NET existente (SharpHound) | ✓ | — (no es .NET) |
| OPSEC crítico, no quiero cargar CLR | — | ✓ |
| Acción pequeña y rápida (enum, callback) | — | ✓ |
| Tarea compleja con mucho código | ✓ | — |

**Ejemplos de BOFs del ecosistema público (concepto, no código):**
- `TrustedSec/CS-Situational-Awareness-BOF` — enumeración sin crear procesos.
- `WheresMyImplant/BOF` — interacción con AD sin execute-assembly.
- BOFs de TrustedSec para operaciones de credenciales.

## 4. Aggressor Scripts

**Qué son:** scripts en el lenguaje Sleep (propio de CS) que automatizan el teamserver y personalizan la interfaz y el workflow del operador.

**Para qué sirven:**
- **Automatizar post-explotación:** al recibir una nueva baliza, ejecutar automáticamente un checklist (getuid, getprivs, ps).
- **Personalizar aliases:** crear comandos propios del operador.
- **Integrar herramientas externas** en el workflow de CS.
- **Notificaciones:** alertar al operador cuando cae un beacon nuevo.

**Por qué importa el concepto:** saber que Aggressor existe y qué automatiza permite al operador diseñar un workflow eficiente. El código específico es práctica de laboratorio.

## 5. La relación con la evasión (Labs 11-12)

| Lab | Qué capa protege |
|-----|-----------------|
| **Lab-11** (Ghost Signal) | AV/AMSI/ETW — el payload en memoria |
| **Lab-12** (Iron Veil) | AppLocker/CLM — qué puede ejecutarse |
| **Lab-16** (Custom Arsenal) | Tráfico de red + footprint del beacon + comportamiento del proceso |

Las tres capas son complementarias. Un operador que solo tiene Lab-11 puede evadir el AV pero sigue siendo detectable por NTA. Con las tres capas, opera invisible en múltiples dimensiones.

## 6. MITRE ATT&CK

| Táctica | Técnica | ID |
|---------|---------|----|
| Defense Evasion | Reflective Code Loading | T1620 |
| Defense Evasion | Process Injection (via BOF) | T1055 |
| C2 | Application Layer Protocol (Malleable) | T1071.001 |
| C2 | Non-Standard Port / Encrypted Channel | T1573 |

## 7. Key Takeaways

1. **CS por defecto es detectable.** El perfil Malleable es lo que lo hace invisible al NTA/IDS.
2. **BOF > execute-assembly para OPSEC.** Sin proceso hijo, sin CLR — footprint mínimo.
3. **Aggressor automatiza el workflow.** Checklist automático al recibir baliza = consistencia operacional.
4. **Son capas distintas a Ghost Signal.** AV/AMSI/ETW (Lab-11) ≠ tráfico + beacon footprint (Lab-16).
5. **El diseño se entiende aquí; el código se practica en el curso.** Lo que se transfiere al examen es saber qué ajustar cuando algo se detecta.

## Referencias

- Cobalt Strike — Malleable C2 documentation
- TrustedSec — CS-Situational-Awareness-BOF
- CRTO — Extending Cobalt Strike module
- Lab-11 (Ghost Signal): la capa de AV/AMSI/ETW (complementaria)

---

*Technique · Lab-16 Custom Arsenal · Extending C2 (anatomía v3.1, arquetipo concepto). El código no vive en el repo por diseño.*
