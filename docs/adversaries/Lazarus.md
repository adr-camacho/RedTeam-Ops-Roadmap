# Lazarus Group — Adversary Profile / Intelligence Summary

- **Alias:** Hidden Cobra · Guardians of Peace · Labyrinth Chollima · ZINC → **Diamond Sleet** (Microsoft) · NICKEL ACADEMY · TraderTraitor (umbrella DPRK)
- **MITRE Group:** [G0032](https://attack.mitre.org/groups/G0032/)
- **Atribución:** Corea del Norte — **Reconnaissance General Bureau (RGB)**. Atribución de alta confianza, respaldada por acusaciones del DOJ (Park Jin Hyok, 2018) y advisories de CISA (AA22-108A, AA21-048A).
- **Activo desde:** al menos 2009 (atribuido al ataque destructivo a Sony Pictures, 2014).
- **Motivación:** Doble — **espionaje estatal** (defensa, aeroespacial, gobierno) y **operaciones financieras a gran escala** (banca, exchanges de criptomonedas, VASPs) para financiar al régimen.
- **Sectores objetivo:** Defensa y aeroespacial, finanzas y banca, criptomonedas/blockchain, investigadores de seguridad, medios; campañas globales (Asia, América, Europa, Oriente Medio).

## Doctrina — cómo y por qué opera

Lazarus es un actor **de tradecraft propio y evasión a medida**. A diferencia de un actor *credential-centric* como APT28, su sello es el **arsenal de herramientas custom** (más de 100 documentadas) y una obsesión por **operar sin ser detectado** mediante ofuscación, ejecución en memoria y manipulación de la telemetría del sistema. Es un actor *tooling-and-evasion-centric*.

Esto explica sus elecciones de TTP y por qué encaja como adversario ancla de la **Phase-03 (operaciones: montar y templar el kit del operador)**:

- **Acceso inicial vía ingeniería social de alta calidad.** Su firma absoluta: *Operation Dream Job* (falsos reclutadores con ofertas de empleo weaponizadas) y compromisos de cadena de suministro. Es **el** especialista documentado en acceso inicial dirigido.
- **Evasión como prioridad de diseño.** Packing (VMProtect, Themida), binary padding, DLL side-loading, ejecución de payloads en memoria, y **patching de ETW** para cegar la telemetría del defensor. La evasión no es un añadido: es el núcleo de su tradecraft.
- **C2 propio y rotación de infraestructura.** Backdoors y RATs custom (FALLCHILL, MATA, BLINDINGCAN…) sobre canales HTTP/HTTPS, con infraestructura que rota constantemente para evadir bloqueos por IOC.
- **Living-off-the-land combinado con binarios propios.** Mezcla utilidades legítimas del SO con su malware para reducir la huella y dificultar la detección por firma.

> **Nota de los dos ejes (honestidad técnica).** Phase-03 enseña el temario CRTO sobre Cobalt Strike/Sliver — un currículo de examen, no una campaña real de Lazarus. Este perfil lista el repertorio **documentado** del actor; cada `emulation.md` declara qué subconjunto es **genuino de Lazarus** (evasión, acceso inicial, C2 propio) y qué es **tradecraft universal del operador** que el lab adopta sin atribuírselo falsamente. Lazarus es el escenario y el vehículo narrativo; la capability es el alcance.

## Repertorio TTP (MITRE ATT&CK) — relevante para Phase-03

| Táctica | Técnica | ID | Notas |
|---------|---------|----|-------|
| Initial Access | Phishing: Spearphishing Attachment/Link | T1566 | *Operation Dream Job* — falsos reclutadores (firma del actor) |
| Initial Access | Drive-by / Supply Chain Compromise | T1189 / T1195 | Watering holes, instaladores troyanizados |
| Defense Evasion | Obfuscated Files: Software Packing | T1027.002 | VMProtect, Themida |
| Defense Evasion | Obfuscated Files: Binary Padding | T1027.001 | Relleno de datos basura para evadir firmas |
| Defense Evasion | Impair Defenses: Indicator Blocking (ETW) | T1562.006 | **Patching de ETW** — cegar telemetría (núcleo de Lab-11) |
| Defense Evasion | Hijack Execution Flow: DLL Side-Loading | T1574.002 | Carga de DLL maliciosa vía binario legítimo |
| Defense Evasion | Reflective / In-Memory Execution | T1620 | Payloads en memoria, sin tocar disco |
| Defense Evasion | Access Token Manipulation | T1134 | Create Process with Token |
| Execution | Living-off-the-Land Binaries (LOLBAS) | — | Utilidades del SO + binarios propios (Lab-12) |
| Persistence | Scheduled Task/Job | T1053.005 | Persistencia de host |
| Command & Control | Application Layer Protocol: Web | T1071.001 | C2 HTTP/HTTPS con backdoors custom |
| Exfiltration | Exfiltration Over C2 / Web Services | T1041 / T1567 | RAR + servicios cloud (Dropbox con dbxcli) |

## Campañas / referencias

- **MITRE ATT&CK G0032** — entrada de grupo (técnicas, software, citaciones): https://attack.mitre.org/groups/G0032/
- **Operation Dream Job (C0022)** — espionaje vía falsos reclutadores contra defensa/aeroespacial.
- **CISA AA22-108A** — actividad cibernética DPRK (Lazarus) contra blockchain/criptomonedas.
- **Novetta — Operation Blockbuster** — análisis del ataque a Sony Pictures (2014).
- **DOJ (2018)** — acusación de Park Jin Hyok (RGB) por Sony, WannaCry y robos bancarios.
- **JPCERT/CC — Lazarus research** — mapeo MITRE ATT&CK detallado (packing, timestomp, SMB lateral).

## Labs que lo emulan (Phase-03)

| Lab | Capability (eje didáctico) | El `emulation.md` del lab especializa |
|-----|----------------------------|----------------------------------------|
| Lab-08 Black Beacon | Fundamentos de C2 | Montar infra C2 con rigor de actor de C2 propio |
| Lab-09 Situational Awareness | Host/dominio recon + detección de controles | Razonamiento sigiloso del operador al aterrizar |
| Lab-10 Deep Root | Persistencia de host + privesc | Scheduled tasks, DLL side-loading, token (genuino) |
| Lab-11 Ghost Signal | Evasión Defender/AMSI/ETW | **ETW patching, in-memory, packing — firma del actor** |
| Lab-12 Iron Veil | Evasión AppLocker/CLM/LOLBAS | Living-off-the-land para reducir huella |

> Cada lab **no repite** este perfil: lo enlaza y solo añade su subconjunto de TTPs y el porqué (ver `emulation.md`).

---

*Adversary Profile v1.0 · fuente única (herencia) · ver `docs/STANDARDS.md §5`*
