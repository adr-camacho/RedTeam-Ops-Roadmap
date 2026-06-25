# APT10 — Adversary Profile / Intelligence Summary

- **Alias:** Stone Panda · menuPass · Cicada · POTASSIUM · Red Apollo · CVNX · HOGFISH → **Bronze Riverside** (Secureworks)
- **MITRE Group:** [G0045](https://attack.mitre.org/groups/G0045/)
- **Atribución:** China — **Ministry of State Security (MSS)**, contratado a través del Tianjin State Security Bureau. Atribución de alta confianza, respaldada por acusación del DOJ (Zhu Hua y Zhang Shilong, 2018) y el informe Operation Cloud Hopper (PwC/BAE, 2017).
- **Activo desde:** al menos 2009.
- **Motivación:** Espionaje estatal — robo de propiedad intelectual, secretos comerciales y datos sensibles, alineado con prioridades económicas y estratégicas chinas.
- **Sectores objetivo:** Proveedores de servicios gestionados (MSP) y sus clientes downstream, aeroespacial y defensa, ingeniería y manufactura, telecomunicaciones, salud, gobierno; campañas en 30+ países (Asia, Europa, Norteamérica).

## Doctrina — cómo y por qué opera

APT10 es un actor **de escala enterprise y abuso de confianza**. Su sello no es una técnica concreta sino una **estrategia de apalancamiento**: comprometer un punto de confianza —típicamente un MSP— y desde él **saltar a decenas de redes cliente** a través de las conexiones IT legítimas que ya existen. Es paciente, sigiloso y orientado a permanencia prolongada para recolección masiva.

Esto explica sus elecciones de TTP y por qué encaja como adversario ancla de la **Phase-04 (simulación enterprise: desplegar el kit en una operación completa)**:

- **Abuso de relaciones de confianza a escala.** *Operation Cloud Hopper*: hopping de proveedor a cliente usando rutas IT de confianza. Esta mentalidad —explotar trusts y conexiones legítimas para cruzar fronteras organizativas— es el corazón narrativo de los labs de forest/trust de Phase-04.
- **Toolset que es, literalmente, el stack de CRTO.** BloodHound (mapeo AD), Cobalt Strike (post-explotación), Mimikatz/LaZagne (credenciales), PowerSploit/PowerView, PsExec/WMI (lateral), certutil (staging). Un actor real cuyo arsenal documentado coincide con lo que el examen evalúa.
- **Credenciales válidas + lateral con protocolos nativos.** Pass-the-hash/ticket, PsExec, WMI, SMB — moverse como un administrador legítimo entre dominios y bosques.
- **Persistencia durable y exfil discreta.** Cuentas admin, tareas programadas, DLL side-loading; staging con RAR y exfiltración por canales cifrados/servicios legítimos.

> **Nota de los dos ejes (honestidad técnica).** Phase-04 enseña el temario CRTO sobre Cobalt Strike/Sliver — un currículo de examen, no la campaña Cloud Hopper literal. Este perfil lista el repertorio **documentado** del actor; cada `emulation.md` declara qué es **genuino de APT10** (abuso de trusts/MSP, BloodHound, lateral con credenciales válidas, exfil) y qué es **tradecraft de AD donde el exponente más puro es otro actor** (p. ej. la forja de Golden/Diamond tickets es firma de APT29). Donde aplica, el lab lo dice: APT10 es el vehículo narrativo de la operación enterprise; la capability es el alcance.

## Repertorio TTP (MITRE ATT&CK) — relevante para Phase-04

| Táctica | Técnica | ID | Notas |
|---------|---------|----|-------|
| Initial Access | Trusted Relationship | T1199 | **Cloud Hopper** — abuso de MSP para alcanzar clientes (firma del actor) |
| Initial Access | Valid Accounts | T1078 | Credenciales legítimas para cruzar fronteras organizativas |
| Credential Access | OS Credential Dumping | T1003 | Mimikatz, LaZagne, pwdump |
| Credential Access | Kerberoasting | T1558.003 | Solicitud/crackeo de tickets de servicio (tradecraft estándar) |
| Discovery | Domain/Account/Remote System Discovery | T1087 / T1018 | **BloodHound** para mapear rutas de privilegio en AD |
| Lateral Movement | Use Alternate Authentication Material | T1550 | Pass-the-Hash / Pass-the-Ticket |
| Lateral Movement | Remote Services (PsExec/WMI/SMB) | T1021 | Ejecución remota con credenciales válidas |
| Execution | LOLBAS / System Tools | — | certutil (staging), wmic, rundll32 |
| Persistence | Create Account / Scheduled Task | T1136 / T1053.005 | Cuentas admin y tareas para acceso durable |
| Persistence | Hijack Execution Flow: DLL Side-Loading | T1574.002 | Carga de malware vía binario legítimo |
| Collection / Exfil | Archive Collected Data + Exfil Over Web | T1560 / T1567 | RAR + servicios cloud/canales cifrados |

## Campañas / referencias

- **MITRE ATT&CK G0045** — entrada de grupo (técnicas, software, citaciones): https://attack.mitre.org/groups/G0045/
- **Operation Cloud Hopper (PwC/BAE, 2017)** — compromiso de MSPs a escala global; el informe que define al actor.
- **A41APT (Kaspersky/GReAT, 2021)** — campaña con malware fileless (SodaMaster, P8RAT, Ecipekac).
- **DOJ (2018)** — acusación de Zhu Hua y Zhang Shilong (MSS, Tianjin SSB).
- **Symantec (2020)** — campaña sofisticada y prolongada contra organizaciones vinculadas a Japón (Cicada).

## Labs que lo emulan (Phase-04)

| Lab | Capability (eje didáctico) | El `emulation.md` del lab especializa |
|-----|----------------------------|----------------------------------------|
| Lab-13 Linked Shadows | MSSQL + linked servers | Lateral entre sistemas vinculados (núcleo Cloud Hopper) |
| Lab-14 Golden Throne | Domain dominance + persistencia | Tradecraft estándar; Golden/Diamond = exponente APT29 (declarado) |
| Lab-15 Forest Reign | Forest & trust abuse | **Abuso de confianza cross-forest — esencia del actor** |
| Lab-16 Custom Arsenal | Extender el C2 (Malleable/BOFs) | OPSEC del operador para reducir footprint |
| Lab-17 Silent Exit | Exfiltración + reporting | Staging RAR + exfil por canal cifrado (genuino) |
| Lab-18 Final Verdict | Capstone — cadena completa | La operación Cloud Hopper de extremo a extremo |

> Cada lab **no repite** este perfil: lo enlaza y solo añade su subconjunto de TTPs y el porqué (ver `emulation.md`).

---

*Adversary Profile v1.0 · fuente única (herencia) · ver `docs/STANDARDS.md §5`*
