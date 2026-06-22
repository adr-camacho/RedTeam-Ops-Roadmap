# APT28 — Adversary Profile / Intelligence Summary

- **Alias:** Fancy Bear · Sofacy · Sednit · STRONTIUM → **Forest Blizzard** (Microsoft) · BlueDelta · Fighting Ursa · Pawn Storm · Tsar Team
- **MITRE Group:** [G0007](https://attack.mitre.org/groups/G0007/)
- **Atribución:** Rusia — GRU (inteligencia militar), Unidad **26165** (85th GTsSS). Atribución de alta confianza, respaldada por acusación del DOJ (2018) y advisories multi-agencia.
- **Activo desde:** ~2007–2008.
- **Motivación:** Espionaje estatal alineado con objetivos militares y de política exterior rusos.
- **Sectores objetivo:** Gobiernos, defensa y aeroespacial, diplomacia, OTAN y organizaciones asociadas, medios, organismos deportivos/antidopaje; desde 2022, intensamente entidades de logística y tecnología que apoyan a Ucrania.

## Doctrina — cómo y por qué opera

APT28 es un actor **paciente, persistente y disciplinado en credenciales**. Tras casi dos décadas de operación continua pese a indictments y atribuciones públicas, su sello es la **constancia operativa** alineada a objetivos de inteligencia: buscan acceso **durable y silencioso** para recolección, no impacto ruidoso.

Esto explica sus elecciones de TTP y por qué encaja como adversario de la **Phase-02 (post-explotación en AD)**:

- **Prioriza credenciales legítimas sobre malware ruidoso.** Recolección y reutilización de credenciales (password spraying, NTLM relay, robo de hashes/tickets) para moverse como un usuario válido y reducir detección. Es un actor *credential-centric*.
- **Explotación de CVE para escalar.** Cuando necesita privilegio, recurre a exploits concretos — p. ej. **GooseEgg** (CVE-2022-38028) para SYSTEM, o la fuga NTLM de Outlook (**CVE-2023-23397**) para forzar autenticación y capturar credenciales.
- **Combina tradecraft probado con vectores novedosos.** Desde phishing de credenciales (Pawn Storm) hasta el ataque *Nearest Neighbor* (pivotar por Wi-Fi de edificios adyacentes), demostrando adaptabilidad sin abandonar lo que funciona.
- **Objetivo manda sobre técnica.** Cada operación se alinea a una necesidad de inteligencia; no "hacen ruido por hacerlo". Esta mentalidad es la que los labs 04-07 reproducen como *guion*: operar en AD con disciplina de credenciales hacia un objetivo concreto.

> **Nota de los dos ejes.** Varias técnicas didácticas de los labs (RBCD, Shadow Credentials, SID History cross-forest) las fija el **temario CRTO**, no son firma exclusiva de APT28. El perfil lista el repertorio **documentado** del actor; el `emulation.md` de cada lab declara qué subconjunto usa y por qué encaja con el objetivo del lab. APT28 es el escenario; la capability es el alcance.

## Repertorio TTP (MITRE ATT&CK) — relevante para AD / Phase-02

| Táctica | Técnica | ID | Notas |
|---------|---------|----|-------|
| Credential Access | Brute Force / Password Spraying | T1110 | Spraying contra cuentas de dominio |
| Credential Access | Kerberoasting | T1558.003 | Solicitud y crackeo de tickets de servicio |
| Credential Access | Forced Authentication | T1187 | Fuga NTLM (CVE-2023-23397); coacción de autenticación |
| Credential Access | OS Credential Dumping | T1003 | Volcado de credenciales/hashes |
| Credential Access | Credentials from Password Stores: DPAPI | T1555.004 | Secretos protegidos por DPAPI (→ Lab-07) |
| Privilege Escalation | Exploitation for Privilege Escalation | T1068 | GooseEgg / CVE-2022-38028 → SYSTEM |
| Privilege Escalation | Domain Policy Modification: GPO | T1484.001 | Abuso de Group Policy (→ Lab-06) |
| Privilege Escalation | Access Token Manipulation | T1134 | Incl. SID-History en abuso cross-forest (→ Lab-06) |
| Lateral Movement | Use Alternate Authentication Material | T1550 | Pass-the-Hash / Pass-the-Ticket |
| Lateral Movement | Remote Services | T1021 | WinRM/SMB/RDP con credenciales válidas |
| Persistence | Account Manipulation | T1098 | Incl. abuso de ACLs/delegación para acceso durable (→ Lab-04/05) |

## Campañas / referencias

- **MITRE ATT&CK G0007** — entrada de grupo (técnicas, software, citaciones): https://attack.mitre.org/groups/G0007/
- **CISA AA23-108** — explotación de routers Cisco (reconocimiento/despliegue): https://www.cisa.gov/news-events/cybersecurity-advisories/aa23-108
- **Microsoft** — GooseEgg / explotación de CVE-2022-38028 por Forest Blizzard.
- **Unit 42** — explotación de CVE-2023-23397 (fuga NTLM de Outlook).
- **Advisory multi-agencia (mayo 2025)** — GRU Unit 26165 contra logística y tecnología occidentales ligadas a Ucrania.
- **DOJ (2018)** — acusación de oficiales del GRU (Unidad 26165).

## Labs que lo emulan (Phase-02)

| Lab | Capability (eje didáctico) | El `emulation.md` del lab especializa |
|-----|----------------------------|----------------------------------------|
| Lab-04 Iron Forest | ACL abuse | Acceso durable vía manipulación de ACLs |
| Lab-05 Silver Chain | Delegación + ticket forging | Reutilización de credenciales/tickets |
| Lab-06 Black Policy | GPO abuse + SID History cross-forest | T1484.001 / T1134 en trust |
| Lab-07 Shadow Vault | LAPS + DPAPI | T1555.004 — secretos DPAPI |

> Cada lab **no repite** este perfil: lo enlaza y solo añade su subconjunto de TTPs y el porqué (ver `emulation.md`).

---

*Adversary Profile v1.0 · fuente única (herencia) · ver `docs/STANDARDS.md §5`*
