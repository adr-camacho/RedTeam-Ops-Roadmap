# APT41 — Adversary Profile / Intelligence Summary

- **Alias:** Double Dragon · Wicked Panda · **Brass Typhoon** (Microsoft) · BARIUM · Winnti · Earth Baku · Grayfly
- **MITRE Group:** [G0096](https://attack.mitre.org/groups/G0096/)
- **Atribución:** China — vinculado al **MSS** (Ministerio de Seguridad del Estado) bajo el modelo de *contratistas* (front company Chengdu 404). Cinco nacionales chinos acusados por el DOJ (2019/2020).
- **Activo desde:** al menos 2012.
- **Motivación:** **Doble mandato** — espionaje estatal *y* cibercrimen con ánimo de lucro, simultáneamente, en los mismos entornos. Único entre los actores chinos rastreados por esta dualidad.
- **Sectores objetivo:** Más de 100 organizaciones en ~40 países — sanidad, telecom, alta tecnología, manufactura, videojuegos, gobierno.

## Doctrina — cómo y por qué opera

APT41 es **ágil, oportunista y experto en pivotaje**. Su firma operativa es entrar por una **aplicación expuesta a internet** y, desde ahí, **moverse en profundidad** por redes heterogéneas hasta su objetivo. Arma vulnerabilidades nuevas (n-day y zero-day) con rapidez y vive de la red una vez dentro.

Por eso es el adversario natural de **Lab-02 (Silent Bridge: acceso vía exploit → pivotaje → session passing)** — aquí el actor y la capability **coinciden de verdad**, no es solo piel:

- **Acceso por aplicación pública.** Explotación de tecnologías expuestas (Pulse Secure, Apache, F5 BIG-IP, productos Microsoft) como vector de entrada habitual.
- **Pivotaje a través de segmentos y SO.** Se mueve lateralmente pivotando entre sistemas **Windows y Linux** hasta alcanzar el entorno objetivo; usa proxies **multi-hop** (incluso dispositivos SOHO) como nodos operativos. Esto es exactamente el eje didáctico de Lab-02.
- **Living-off-the-land y persistencia encubierta.** DLL side-loading con binarios firmados, payloads multi-etapa, robo integral de credenciales y descubrimiento interno (p. ej. `setspn` para localizar servicios IIS/SQL/MSSQL).
- **Velocidad.** Una vez dentro, no pierde tiempo: encadena acceso inicial → escalada → movimiento → exfiltración con agilidad. Esa cadena rápida y bien orquestada es la rutina que Lab-02 reproduce.

> **Nota de los dos ejes.** El stack concreto del lab (la cadena de explotación web, Ligolo-ng para el pivote, el paso de sesiones entre C2) lo fija el **temario CRTO**. APT41 aporta el *escenario* —entrar por lo expuesto y pivotar hondo—; el `emulation.md` declara el subconjunto de TTPs y el porqué.

## Repertorio TTP (MITRE ATT&CK) — relevante para acceso/pivotaje / Lab-02

| Táctica | Técnica | ID | Notas |
|---------|---------|----|-------|
| Initial Access | Exploit Public-Facing Application | T1190 | Vector de entrada característico |
| Persistence | Server Software Component: Web Shell | T1505.003 | Foothold sobre el servicio explotado |
| Defense Evasion | Hijack Execution Flow: DLL Side-Loading | T1574.002 | Carga vía binarios firmados |
| Discovery | Network Service Discovery | T1046 | Mapeo de segmentos para pivotar |
| Lateral Movement | Remote Services | T1021 | Movimiento con credenciales válidas |
| Command and Control | Proxy: Multi-hop Proxy | T1090.003 | Nodos intermedios / pivotaje |
| Command and Control | Protocol Tunneling | T1572 | Túneles para alcanzar segmentos internos |
| Credential Access | OS Credential Dumping | T1003 | Robo integral de credenciales |

## Campañas / referencias

- **MITRE ATT&CK G0096**: https://attack.mitre.org/groups/G0096/
- **Mandiant/Google** — "APT41: A Dual Espionage and Cyber Crime Operation": https://cloud.google.com/blog/topics/threat-intelligence/apt41-dual-espionage-and-cyber-crime-operation
- **DOJ (2019/2020)** — acusaciones a cinco nacionales chinos (Chengdu 404).
- **CISA (julio 2021)** — actividad china state-sponsored contra objetivos en EE. UU.
- **Mandiant (2024)** — "APT41 Has Arisen From the DUST" (evolución de tooling).

## Labs que lo emulan (Phase-01)

| Lab | Capability (eje didáctico) | El `emulation.md` del lab especializa |
|-----|----------------------------|----------------------------------------|
| Lab-02 Silent Bridge | Acceso vía exploit + pivotaje + session passing | T1190 → T1090.003 — entrar y pivotar hondo |

> El lab **no repite** este perfil: lo enlaza y solo añade su subconjunto de TTPs y el porqué (ver `emulation.md`).

---

*Adversary Profile v1.0 · fuente única (herencia) · ver `docs/STANDARDS.md §5`*
