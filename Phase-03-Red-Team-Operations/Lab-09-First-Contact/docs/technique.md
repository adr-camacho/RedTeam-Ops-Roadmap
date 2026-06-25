# Technique — Lab-09 First Contact

> **Capability (eje didáctico):** Situational Awareness & Host Recon — la disciplina de la **primera hora** tras aterrizar: leer el terreno antes de actuar.
> **Bloque CRTO:** Host Reconnaissance & Situational Awareness (la fase que decide todas las demás).
> **Arquetipo:** Concepto / Tradecraft con fuerte componente operativo (B+) — la metodología es entregable; el output real lo capturas al ejecutarla.
> **Adversario (escenario):** Lazarus Group — ver [`emulation.md`](emulation.md).

> CRTO es **assumed breach**: empiezas con una baliza ya dentro. Lo que separa aprobar de quemar el acceso no es saber Kerberoasting — es **saber qué mirar, en qué orden y sin hacer ruido** en los primeros minutos. Este lab construye ese criterio.

---

## 1. La premisa: por qué la primera hora decide el examen

El error que más suspende CRTO no es técnico: es **actuar antes de evaluar**. Lanzar SharpHound nada más caer, volcar LSASS sin saber si hay PPL, correr un script con AMSI activo — cada uno quema el acceso o dispara una alerta que no sabías que existía.

Un operador disciplinado invierte la primera hora en **una sola pregunta**: *¿dónde estoy, qué me vigila, y cuál es el primer movimiento seguro?* Todo lo demás (escalada, lateral, persistencia) se construye sobre esa respuesta.

## 2. El árbol de decisión del operador

```
        [ Baliza recién aterrizada ]
                    |
        ┌───────────┴───────────┐
        │  1. ¿QUIÉN SOY?        │  whoami /all · integridad · privilegios
        └───────────┬───────────┘
                    │
        ┌───────────┴───────────┐
        │  2. ¿QUÉ ME VIGILA?    │  ← EL PASO CRÍTICO
        │     AV/EDR/AMSI/CLM/   │     decide TODA tu estrategia posterior
        │     AppLocker/Sysmon   │
        └───────────┬───────────┘
                    │
          ¿Defensas activas? ──── SÍ ──→ estrategia sigilosa (in-memory, LOLBAS, evasión)
                    │
                    NO
                    │
        ┌───────────┴───────────┐
        │  3. ¿QUÉ HAY ALREDEDOR?│  procesos · software · sesiones · tareas
        └───────────┬───────────┘
                    │
        ┌───────────┴───────────┐
        │  4. ¿QUÉ DOMINIO?      │  DCs · trusts · mis derechos (recon SIGILOSO)
        └───────────┬───────────┘
                    │
        ┌───────────┴───────────┐
        │  5. DECISIÓN           │  ¿cuál es el primer movimiento SEGURO?
        │     qué NO tocar aún   │
        └────────────────────────┘
```

**La regla de oro:** el paso 2 (¿qué me vigila?) va **antes** que cualquier acción ofensiva. No sabes si puedes correr un script hasta saber si hay AMSI. No sabes si puedes volcar LSASS hasta saber si hay PPL/EDR. La postura defensiva del host **dicta el resto del árbol**.

## 3. Paso 1 — Auto-evaluación: ¿quién soy?

Lo primero, sin tocar nada del entorno: entender tu propia posición.

- **Identidad y grupos:** `whoami /all` — usuario, SID, grupos, y sobre todo **privilegios** (`SeDebugPrivilege`, `SeImpersonatePrivilege` → vías de escalada).
- **Nivel de integridad:** ¿Medium (usuario normal) o High (elevado)? Decide si necesitas UAC bypass.
- **¿Local admin? ¿SYSTEM?** Determina qué puedes hacer sin escalar.
- **Tipo de equipo:** ¿workstation o server? `hostname`, rol, OU.

> En el beacon: `getuid`, `getprivs` (Sliver) / `whoami /all` vía `shell` o `execute-assembly Seatbelt` (CS). Empieza por lo más barato y silencioso.

## 4. Paso 2 — Postura defensiva: ¿qué me vigila? (CRÍTICO)

El paso que más operadores se saltan y el que más caro se paga. Antes de cualquier TTP ofensivo, enumera el escudo:

| Control | Cómo detectarlo | Por qué importa |
|---------|-----------------|-----------------|
| **AV / Defender** | `Get-MpComputerStatus`, servicios, `sc query windefend` | ¿Real-time protection activo? Decide si tu payload sobrevive |
| **AMSI** | versión PowerShell, intentar string conocido | Si está activo, scripts en claro mueren — necesitas bypass in-memory |
| **EDR** | procesos/drivers (CrowdStrike, SentinelOne, Carbon Black…), DLLs cargadas | Define todo tu nivel de sigilo; algunos hookean APIs |
| **Constrained Language Mode** | `$ExecutionContext.SessionState.LanguageMode` | CLM bloquea casi todo PowerShell ofensivo |
| **AppLocker / WDAC** | `Get-AppLockerPolicy`, claves de registro | Decide desde dónde puedes ejecutar binarios |
| **Sysmon** | servicio, driver, `reg query` del config | Si está, tu actividad se está registrando con detalle |

> **Esto no es opcional ni "para más tarde".** El resultado de este paso cambia literalmente qué comandos puedes permitirte en los pasos 3-5. Es el nodo del que cuelga el árbol entero.

## 5. Paso 3 — Contexto del host: ¿qué hay alrededor?

Con la postura defensiva clara, lee el entorno inmediato:

- **Procesos:** `ps` — agentes EDR, software interesante, sesiones de otros usuarios, navegadores (cookies/tokens).
- **Software y parches:** programas instalados, versiones vulnerables, hotfixes (`systeminfo`).
- **Sesiones y usuarios:** ¿quién más está logueado? ¿hay un admin con sesión activa que puedas suplantar?
- **Tareas y servicios:** scheduled tasks, servicios con rutas sin comillas o permisos débiles (vías de persistencia/escalada para Lab-10).

## 6. Paso 4 — Conciencia de red y dominio (SIGILOSO)

Aquí entra el recon de AD — pero con disciplina, porque es el más ruidoso:

- **Red local:** `ipconfig /all`, `arp -a`, `netstat`, rutas — ¿a dónde puedo llegar?
- **Dominio:** DCs, nombre de dominio, **trusts** (insumo para Phase-04), tu propia membresía y derechos.
- **OPSEC del recon AD:** consultas LDAP masivas y SharpHound dejan rastro. Un operador sigiloso hace recon dirigido primero (¿qué necesito saber AHORA?) y reserva el mapeo masivo para cuando entiende qué lo vigila.

> **Decisión clave de este paso:** *¿lanzo BloodHound ya, o todavía no?* La respuesta depende del Paso 2. Con EDR agresivo, el SharpHound a lo bruto es un suicidio de OPSEC.

## 7. Paso 5 — El punto de decisión

Sintetiza lo aprendido en **un plan de primer movimiento**:

- ¿Cuál es la vía de escalada más probable según privilegios/software vistos? (→ Lab-10)
- ¿Qué controles defensivos condicionan ese movimiento? (→ Labs 11-12)
- ¿Qué **NO** toco todavía? (no volcar LSASS si hay PPL sin plan; no SharpHound si hay EDR sin evasión)
- ¿Necesito persistencia antes de arriesgar? (→ Lab-10)

> El entregable mental de la primera hora no es loot — es **un plan informado**. Ese es el oro de examen.

## 8. Equivalencia CS ↔ Sliver (recon)

| Acción | Cobalt Strike | Sliver |
|--------|---------------|--------|
| Identidad / privilegios | `getuid`, `execute-assembly Seatbelt.exe` | `getuid`, `getprivs` |
| Procesos | `ps` | `ps` |
| Postura defensiva | `execute-assembly Seatbelt.exe -group=system` | `shell` + queries nativas |
| Recon AD dirigido | `execute-assembly SharpView.exe` / PowerView BOF | vía `execute-assembly` o relay |
| Mapeo AD masivo | `execute-assembly SharpHound.exe` (con OPSEC) | SharpHound vía `execute-assembly` |

> **Punto clave:** la lógica es idéntica; la herramienta cambia. El examen usa CS; el lab usa Sliver. Lo que se transfiere es el **criterio de qué enumerar y cuándo**.

## 9. MITRE ATT&CK — Discovery

| Táctica | Técnica | ID |
|---------|---------|-----|
| Discovery | System Owner/User Discovery | T1033 |
| Discovery | System Information Discovery | T1082 |
| Discovery | Security Software Discovery | T1518.001 |
| Discovery | Process Discovery | T1057 |
| Discovery | Permission Groups Discovery | T1069 |
| Discovery | Domain Trust Discovery | T1482 |
| Discovery | System Network Configuration Discovery | T1016 |

## 10. OPSEC: el recon también hace ruido

Un error frecuente: creer que "solo estoy mirando, no ataco". Falso — la enumeración **es** actividad detectable:

- Consultas LDAP masivas → patrón clásico de SharpHound (detectable, ver `detection.md`).
- Ejecución de Seatbelt/PowerView → assemblies conocidos, AMSI/EDR pueden firmarlos.
- Spray de comandos en segundos → comportamiento no humano.

**Disciplina:** recon dirigido antes que masivo, en memoria donde puedas, y espaciado. La primera hora es de lectura paciente, no de spray.

## 11. Key Takeaways

1. **Evalúa antes de actuar.** El primer movimiento ofensivo va después de entender quién eres y qué te vigila.
2. **El Paso 2 (¿qué me vigila?) manda.** La postura defensiva del host dicta qué puedes permitirte.
3. **El recon es ruidoso.** Dirigido > masivo; en memoria > en disco; paciente > spray.
4. **El entregable es un plan, no loot.** La primera hora produce criterio, no credenciales.
5. **La herramienta cambia, el criterio no.** CS o Sliver: qué enumerar y cuándo es lo que se transfiere.

## Referencias

- The Hacker Recipes — Active Directory / Reconnaissance
- MITRE ATT&CK — Discovery (TA0007)
- Seatbelt, SharpView/PowerView — documentación de los proyectos
- CRTO — Host Reconnaissance & Situational Awareness

---

*Technique · Lab-09 First Contact · Situational Awareness & Host Recon (anatomía v3.1, arquetipo concepto B+)*
