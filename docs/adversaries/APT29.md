# APT29 — Adversary Profile / Intelligence Summary

- **Alias:** Cozy Bear · The Dukes · NOBELIUM → **Midnight Blizzard** (Microsoft) · Dark Halo · UNC2452 · StellarParticle · YTTRIUM
- **MITRE Group:** [G0016](https://attack.mitre.org/groups/G0016/)
- **Atribución:** Rusia — **SVR** (Servicio de Inteligencia Exterior). Atribución de alta confianza (EE. UU./Reino Unido, abril 2021, por SolarWinds).
- **Activo desde:** al menos 2008.
- **Motivación:** Espionaje estatal — recolección de inteligencia para la toma de decisiones de política exterior y de seguridad rusa.
- **Sectores objetivo:** Gobiernos europeos y de la OTAN, think tanks, institutos de investigación, tecnología, telecom, sanidad, energía, aviación; cada vez más entornos **cloud/identidad**.

## Doctrina — cómo y por qué opera

Si APT28 es disciplina de credenciales, **APT29 es sigilo llevado al extremo**. Su rasgo definitorio es la **paciencia**: en SolarWinds permanecieron meses dentro del pipeline de compilación antes de ser detectados. No son peligrosos por ruidosos, sino por **invisibles** — operan para mantener acceso de larga duración sin disparar una sola alarma.

Esto explica sus TTP y por qué es el adversario ideal de la **Phase-01 (fundamentos AD: Kerberos y ADCS)**:

- **Forja de material de confianza.** Donde otros roban una credencial, APT29 **falsifica la confianza**: Golden SAML, robo y forja de tokens, y abuso de certificados/federación (ADFS — FOGGYWEB/MAGICWEB). Esta mentalidad de *forjar autenticación* conecta directamente con **ADCS (Lab-03)** y con la forja de tickets Kerberos.
- **Identidad sobre exploit.** Prefiere abusar de identidades y mecanismos de autenticación legítimos antes que quemar exploits; reduce huella y detección.
- **Anti-forense y mínima huella.** Living-off-the-land, limpieza de indicadores, persistencia en capas (GoldMax/GoldFinder/Sibot) — todo orientado a no ser visto.
- **Objetivo: dwell largo y silencioso.** La meta es recolección sostenida, así que cada decisión optimiza permanecer, no avanzar rápido. Es el guion que la **kill-chain limpia de Lab-01** reproduce: avanzar hasta DA con disciplina, entendiendo cada paso.

> **Nota de los dos ejes.** La cadena concreta de Lab-01 (AS-REP/Kerberoasting → foothold → DCSync → DA) y los ESC de ADCS de Lab-03 los fija el **temario CRTO**. APT29 aporta el *escenario* —un actor que forja confianza y opera invisible—; el `emulation.md` de cada lab declara qué subconjunto de su repertorio usa y por qué.

## Repertorio TTP (MITRE ATT&CK) — relevante para Kerberos / ADCS / Phase-01

| Táctica | Técnica | ID | Notas |
|---------|---------|----|-------|
| Credential Access | Steal or Forge Kerberos Tickets: Kerberoasting | T1558.003 | Tickets de servicio → crackeo offline (→ Lab-01) |
| Credential Access | Steal or Forge Kerberos Tickets: Golden Ticket | T1558.001 | Forja de TGT con krbtgt |
| Credential Access | OS Credential Dumping: DCSync | T1003.006 | Replicación de credenciales del DC (→ Lab-01) |
| Credential Access | Steal or Forge Authentication Certificates | T1649 | Abuso de ADCS / certificados (→ Lab-03) |
| Credential Access | Forge Web Credentials: SAML Tokens | T1606.002 | Golden SAML (federación) |
| Defense Evasion | Use Alternate Authentication Material | T1550 | Pass-the-Ticket / tokens |
| Defense Evasion | Indicator Removal | T1070 | Anti-forense, limpieza de logs |
| Persistence | Account Manipulation | T1098 | Persistencia de identidad |

## Campañas / referencias

- **MITRE ATT&CK G0016**: https://attack.mitre.org/groups/G0016/
- **CISA AA21-116A** — TTPs de actores SVR: https://www.cisa.gov/news-events/cybersecurity-advisories/aa21-116a
- **CISA AA24-057A** — SVR adapta tácticas para acceso inicial en cloud: https://www.cisa.gov/news-events/cybersecurity-advisories/aa24-057a
- **SolarWinds (2020-2021)** — compromiso de cadena de suministro (SUNBURST), atribuido al SVR.
- **Microsoft** — Midnight Blizzard (perfil de actor); ataque al correo corporativo de Microsoft (2024).

## Labs que lo emulan (Phase-01)

| Lab | Capability (eje didáctico) | El `emulation.md` del lab especializa |
|-----|----------------------------|----------------------------------------|
| Lab-01 Ghost Forest | Primera kill-chain AD (roasting → DCSync → DA) | Avance sigiloso y forja de tickets |
| Lab-03 Dark Gate | ADCS (ESC1/4/8) | T1649 — forja/abuso de certificados |

> Cada lab **no repite** este perfil: lo enlaza y solo añade su subconjunto de TTPs y el porqué (ver `emulation.md`).

---

*Adversary Profile v1.0 · fuente única (herencia) · ver `docs/STANDARDS.md §5`*
