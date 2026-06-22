# DESIGN.md — Red Team Ops Roadmap
## Principios de Diseño, Metodología y Arquitectura

**Versión:** 3.1 | **Fecha:** 19/06/2026 | **Autor:** Adrián Camacho

---

## Historial de versiones

| Versión | Fecha | Cambios principales |
|---------|-------|---------------------|
| v1.0 | 09/05/2026 | Estructura inicial — 12 labs, 4 phases |
| v2.0 | 20/05/2026 | Rediseño completo — 14 labs, crown jewels, coverage matrix, CRTO alignment |
| v2.1 | 01/06/2026 | Infraestructura CRTO completa — 3 forests, multi-DC, TTPs avanzadas Lab-06 |
| v3.0 | 19/06/2026 | Alineación CRTO — 18 labs, estándar de producto, ROADMAP como fuente de verdad |
| v3.1 | 19/06/2026 | Modelo de dos ejes (objetivo/adversario), perfil de adversario de fuente única + herencia, anatomía y naming de industria |

> **Nota de gobernanza (v3.1).** Este documento recoge **principios, metodología y lecciones de diseño**:
> lo que cambia poco. El **plan, la cobertura y los perfiles de adversario** viven en una sola fuente de verdad
> para evitar desincronización (ver `REPOSITORY_STANDARDS.md §8`):
> - Estructura y plan de 18 labs → [`ROADMAP.md`](ROADMAP.md)
> - Mapeo de técnicas MITRE → [`../reference/MITRE_MAPPING.md`](../reference/MITRE_MAPPING.md)
> - Infraestructura detallada → [`../reference/LAB_INFRASTRUCTURE.md`](../reference/LAB_INFRASTRUCTURE.md)
> - Perfiles de adversario → [`../adversaries/`](../adversaries/)
> - Anatomía de lab, naming y Definition of Done → [`../standards/REPOSITORY_STANDARDS.md`](../standards/REPOSITORY_STANDARDS.md)

---

## 1. Filosofía de Diseño

Este roadmap no es una colección de labs — es un **programa de formación estructurado** con un objetivo claro: transformar a alguien sin experiencia en Red Team en un profesional capaz de ejecutar engagements reales contra entornos corporativos modernos.

### Principios fundamentales

**1. Comprensión sobre ejecución**
Cada técnica se entiende a nivel de protocolo antes de automatizarla. Si una herramienta falla, el operador sabe construir el exploit desde cero.

**2. OPSEC como mentalidad, no como fase**
El OPSEC no es un capítulo al final del lab — es una pregunta constante. ¿Puedo hacer esto desde Kali sin tocar el objetivo? ¿Qué logs genera este comando? ¿Cómo limpio los artefactos?

**3. Realismo sobre velocidad**
Los labs incluyen crown jewels definidos, adversarios reales con TTPs documentadas, y comportamientos defensivos que reflejan entornos corporativos modernos (PAC Validation, Defender activo, AMSI).

**4. Blue Team integrado**
Cada técnica ofensiva viene acompañada de su contrapartida defensiva: Event IDs generados, reglas SIGMA, hardening recomendado. Un buen Red Teamer conoce cómo le detectan.

**5. Progresión pedagógica incremental**
Cada lab añade exactamente una capa de complejidad sobre el anterior. Nunca se introducen dos conceptos nuevos simultáneamente si uno de ellos puede esperar.

**6. Documentación honesta**
Los fallos se documentan con la misma profundidad que los éxitos. Una técnica que no funciona en un entorno moderno es una lección más valiosa que una que sí funciona.

**7. Fidelidad al examen CRTO**
La infraestructura replica la del examen CRTO: multi-forest con trusts bidireccionales, SID Filtering configurable, child domains, y workstations unidas a dominios distintos. El objetivo no es aprobar el examen — es tener la competencia real que el examen certifica. **El temario manda** (cert-first) y **profundidad sobre cantidad** (depth-first); la narrativa APT es piel didáctica subordinada a la cobertura del temario.

---

## 2. Adversary Emulation Methodology

El roadmap sigue el framework de **adversary emulation** — no ejecutamos técnicas genéricas sino que reproducimos comportamientos de grupos APT reales documentados en MITRE ATT&CK.

### Proceso por lab

```
1. Seleccionar adversario (APT29, APT41, APT28, Lazarus, APT10)
2. Estudiar sus TTPs documentadas en MITRE ATT&CK Groups
3. Diseñar el entorno que refleje un objetivo real del adversario
4. Ejecutar reproduciendo su comportamiento (no solo las técnicas)
5. Documentar diferencias entre el comportamiento ideal y el real
6. Analizar desde perspectiva Blue Team cómo detectar al adversario
```

### Adversarios y su justificación

| Adversario | Grupo MITRE | Fase | Justificación |
|-----------|-------------|------|---------------|
| **APT29** (Cozy Bear) | G0016 | Phase-01 (Lab-01, 03) | Especialistas en AD, Kerberos y ADCS — fundamentos ideales |
| **APT41** (Double Dragon) | G0096 | Phase-01 (Lab-02) | Pivoting y acceso inicial vía exploits públicos |
| **APT28** (Fancy Bear) | G0007 | Phase-02 (Lab-04–07) | AD avanzado, Forest Trusts, GPO, SID History, LAPS/DPAPI |
| **Lazarus Group** | G0032 | Phase-03 (Lab-08–12) | EDR evasion, C2 avanzado, OPSEC extremo |
| **APT10** (Stone Panda) | G0045 | Phase-04 (Lab-13–18) | Simulaciones largas, infraestructura compleja, capstone |

### Modelo de dos ejes

Cada lab se construye sobre dos ejes que no se mezclan:

- **Eje didáctico (primario):** la *capability* del temario CRTO que el lab construye. Fija el **alcance** del
  lab y es su **responsabilidad única**. Vive en `technique.md` + `execution/`.
- **Eje de emulación (secundario):** el adversario cuyo comportamiento da **escenario y realismo**. Da
  **contexto/guion, nunca alcance**. Vive en `emulation.md`.

**Regla:** *el objetivo didáctico manda; el adversario es el guion.* Del repertorio del actor se elige lo que
sirve al objetivo del lab; nunca se amplía el lab para encajar una TTP. La profundidad de la emulación escala
con el tipo de lab (tooling/fundamentos → escenario breve; ataque → mapeo TTP completo).

### Perfil de adversario — fuente única y herencia

Para emular varios labs del mismo actor (p. ej. APT28 en Labs 04–07) sin repetir su perfil, se aplica un
modelo de **herencia**:

- **Clase base:** el perfil del actor se escribe **una vez** en `docs/adversaries/<ACTOR>.md`
  (*Adversary Profile / Intelligence Summary*): atribución, motivación, repertorio TTP, doctrina y referencias.
- **Especialización:** el `emulation.md` de cada lab **enlaza** ese perfil y solo añade qué subconjunto de TTPs
  reproduce *ese* lab y por qué encaja con su objetivo. Ningún dato del perfil se duplica en el lab.

Detalle operativo (anatomía, naming, Definition of Done) en `REPOSITORY_STANDARDS.md §3–§6`.

---

## 3. Infraestructura

Entorno multi-forest que replica el examen CRTO. Resumen; el detalle vive en
[`../reference/LAB_INFRASTRUCTURE.md`](../reference/LAB_INFRASTRUCTURE.md) y el diagrama en el `README.md` raíz.

```
FOREST 1 — atackcorp.local : DC-01 (root, ADCS, LAPS) · DC-03 (child) · WKSTN-01
            │ Trust bidireccional (SID Filtering OFF)
FOREST 2 — corp.local      : DC-02 (root) · WKSTN-02
            │ Trust bidireccional (SID Filtering OFF)
FOREST 3 — ext.local       : DC-04 (root)
Kali (10.0.2.9) — Atacante / C2 · Red: NAT LabRedTeam 10.0.2.0/24 (+ ruta 10.0.3.0/24)
```

| VM | IP | OS | RAM | Rol |
|----|----|----|-----|-----|
| DC-01 | 10.0.2.10 | Windows Server 2025 | 22GB | Root DC atackcorp.local + ADCS + Windows LAPS |
| DC-02 | 10.0.2.11 | Windows Server 2022 | 3GB | Root DC corp.local |
| DC-03 | 10.0.2.13 | Windows Server 2022 | 3GB | Child DC child.atackcorp.local |
| DC-04 | 10.0.2.14 | Windows Server 2022 | 2GB | Root DC ext.local |
| WKSTN-01 | 10.0.2.8 | Windows 11 | 3GB | Workstation atackcorp.local |
| WKSTN-02 | 10.0.2.12 | Windows 11 | 3GB | Workstation corp.local |
| Kali | 10.0.2.9 | Kali Linux 2026.1 | 8GB | Atacante / C2 Server |

> Provisioning scripteado por máquina en `setup/DC-01..04/`, `setup/WKSTN-01..02/` y crown jewels en
> `setup/CrownJewels/`. Guía completa en `setup/README.md`.

---

## 4. Estructura del programa y cobertura

> **Fuente de verdad.** Para no duplicar (y desincronizar) el plan, la estructura de las 4 fases y 18 labs,
> la matriz de cobertura CRTO y el estado de cada lab se mantienen **únicamente** en:
> - [`ROADMAP.md`](ROADMAP.md) — plan canónico de 18 labs + matriz de cobertura CRTO.
> - [`../reference/MITRE_MAPPING.md`](../reference/MITRE_MAPPING.md) — técnicas por lab contra ATT&CK v14.
> - [`../progress/PROGRESS.md`](../progress/PROGRESS.md) — diario de sesiones y estado de ejecución.

Resumen de fases (detalle en ROADMAP):

| Fase | Labs | Foco | Adversario |
|------|------|------|-----------|
| Phase-01 · Fundamentals | 01–03 | Fundamentos AD, Kerberos, ADCS, pivotaje | APT29 / APT41 |
| Phase-02 · Post-Exploitation | 04–07 | AD avanzado: ACLs, tickets, GPO, LAPS/DPAPI | APT28 |
| Phase-03 · Red Team Operations | 08–12 | C2, operativa de host, evasión | Lazarus |
| Phase-04 · Enterprise & Exam | 13–18 | Maestría AD, C2 avanzado, capstone | APT10 |

---

## Principios de diseño de software aplicados

El repo aplica deliberadamente principios de ingeniería de software donde el problema que resuelven existe de
verdad. No es decoración: da a un revisor un vocabulario para entender *por qué* está estructurado así.

- **Single Responsibility (SRP).** Un lab = una capability. Si "qué me capacita" no cabe en una frase, se parte.
- **Open/Closed.** El repo se **extiende** (nuevo lab, nuevo APT) **sin modificar** lo existente: se estampa la anatomía con `scaffold-v3`, no se tocan labs previos.
- **Dependency Inversion.** Los labs dependen de **abstracciones** (perfil de adversario, `ARSENAL`, `LAB_INFRASTRUCTURE`), no de copias concretas — es la herencia con fuente única.
- **Template Method.** La anatomía del lab es una plantilla de estructura fija con pasos rellenados por cada lab.
- **Composite.** Jerarquía uniforme técnica → módulo → lab → phase → repo (ver `LEARNING_PATH.md`).
- **Facade.** El `README` de cada lab y el `docs/` aplanado son fachadas: una entrada simple que oculta complejidad (principio "mando a distancia").

> Se evita el *cargo cult*: no se importan patrones de runtime (Singleton, Factory, Observer…) ni arquitecturas de
> ejecución, porque un repositorio estático no tiene el problema que resuelven. Su intención (fuente única, capas,
> bajo acoplamiento) ya está cubierta. Los **tests** sí entran como `doc-lint`, porque la deriva es un problema real.

---

## 5. Lecciones de Diseño

### Evil-WinRM — Limitaciones token de red
`Get-ADGroup -Server cross-domain` falla en sesiones Evil-WinRM por token Network Logon (Type 3).
ADWS no acepta consultas autenticadas con este token. Alternativa funcional:

```powershell
([System.Security.Principal.NTAccount]"DOMAIN\Group").Translate(
    [System.Security.Principal.SecurityIdentifier]).Value
```

### SID History — Atributo protegido en AD
`sIDHistory` no puede modificarse vía LDAP estándar aunque se sea DA. Requiere:
- **DSInternals `Add-ADDBSidHistory`** — modificación directa ntds.dit (Stop NTDS requerido)
- **impacket** vía DS-Replication — sin parar NTDS (más silencioso)
- **bloodyAD** — NO funciona para sIDHistory (protegido por AD por diseño, no limitación de la herramienta)

### mimikatz `misc::addsid` eliminado
mimikatz 2.2.0+ (incluido en Kali) no incluye `misc::addsid`. Herramienta correcta: DSInternals.
Para manipulación LDAP remota: bloodyAD (cuando el atributo lo permite).

### DNS en child domains
DC-03 (child domain) necesita DC-01 como DNS primario para consultas cross-forest.
Sin esto, consultas ADWS cross-domain fallan intermitentemente aunque la IP sea accesible.
Fix: `Set-DnsClientServerAddress -ServerAddresses ("10.0.2.10","10.0.2.13")`

### Defender bloquea herramientas en upload
Windows Defender detecta y elimina mimikatz durante o inmediatamente después del upload vía Evil-WinRM.
Deshabilitar antes del upload: `Set-MpPreference -DisableRealtimeMonitoring $true`
En labs Phase-03 (Lazarus) se trabajará evasión real sin deshabilitar Tamper Protection.

### Enable-PSRemoting en scripts vía Evil-WinRM
`Enable-PSRemoting -Force` dentro de un script ejecutado vía Evil-WinRM corta la conexión.
Ejecutar manualmente en la VM antes de lanzar el script de provisioning.

### Windows Server 2025 — LAPS con GKDI
WS2025 cifra LAPSv2 con GKDI por defecto; las herramientas Linux no descifran sin
`ADPasswordEncryptionEnabled=0`. pywhisker requiere `--use-ldaps` en WS2025. (Lab-07.)

### Windows 11 23H2+ — KPP bloquea LSASS
Build 26100+ bloquea el acceso a LSASS incluso con PPL=0 vía Kernel Patch Protection.
Documentado para abordarse con evasión real en Labs 08–11. (Lab-07.)

---

## 6. Recursos de Referencia

### Frameworks
- [MITRE ATT&CK Enterprise](https://attack.mitre.org/matrices/enterprise/)
- [MITRE ATT&CK Groups](https://attack.mitre.org/groups/)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)

### Certificación objetivo
- **CRTO** (Certified Red Team Operator) — el programa completo está orientado a su temario; Lab-18 (capstone) es la simulación de examen.

### Documentación de adversarios
- APT29: [CISA Advisory AA21-116A](https://www.cisa.gov/news-events/cybersecurity-advisories/aa21-116a)
- APT28: [MITRE G0007](https://attack.mitre.org/groups/G0007/)
- Lazarus: [CISA Advisory AA22-108A](https://www.cisa.gov/news-events/cybersecurity-advisories/aa22-108a)
