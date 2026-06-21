# 📚 REFERENCES.md — Referencias y bibliografía

> Fuentes de referencia usadas y recomendadas en el repo. Citar fuentes de calidad es parte de lo que
> distingue un recurso serio. Prioriza documentación oficial y proyectos reconocidos del sector.
>
> Ubicación: `docs/reference/REFERENCES.md` · Fecha: 18/06/2026

---

## 🎯 Marcos de referencia

- **MITRE ATT&CK** — taxonomía de tácticas y técnicas (`attack.mitre.org`). Base del `MITRE_MAPPING.md`.
- **MITRE ATT&CK Navigator** — para visualizar cobertura de TTPs por lab.
- **The Unified Kill Chain / Cyber Kill Chain** — modelos de fases de un ataque.

## 🏰 Active Directory y red team

- **The Hacker Recipes** (`thehacker.recipes`) — referencia abierta de TTPs de AD, Kerberos, ADCS, NTLM.
- **ired.team** — notas técnicas de red team y abuso de Windows/AD.
- **SpecterOps — blog y documentación de BloodHound** — rutas de ataque, ACLs, delegación.
- **ADSecurity** (Sean Metcalf) — Kerberos, dominio/forest, persistencia.
- **Certified Pre-Owned (SpecterOps)** — investigación de referencia sobre abuso de ADCS (ESC1–ESC8).

## 🪟 Documentación oficial de Microsoft

- **Microsoft Learn** — Kerberos, Windows LAPS, AppLocker, AMSI, Constrained Language Mode, ADCS.
- **Windows Security Baselines** — para entender configuraciones por defecto y endurecidas.

## 🎓 Certificación

- **Zero-Point Security — Red Team Ops (CRTO)** — curso y laboratorio oficial; vehículo de la parte de
  Cobalt Strike y de la evasión práctica. Es la fuente de los kits/payloads que **no** viven en este repo.

## 🔎 Detección y blue team

- **Sysinternals — Sysmon** — telemetría de endpoint; base de muchas reglas de detección.
- **SIGMA (SigmaHQ)** — formato estándar de reglas de detección; ver `docs/reference/DETECTION_LIBRARY.md`.
- **MITRE ATT&CK — Detections & Data Sources** — qué telemetría observa cada técnica.
- **Repositorios de reglas (Elastic, Splunk Security Content)** — ejemplos de detecciones por comportamiento.

## 🧰 Documentación oficial de herramientas usadas

- **Sliver** (BishopFox) — C2 del lab.
- **Impacket** — suite de protocolos/ataques (secretsdump, getTGT, smbclient…).
- **BloodHound CE / SharpHound** — enumeración de rutas de ataque.
- **Rubeus** — operaciones Kerberos.
- **Certipy** — enumeración y abuso de ADCS.
- **NetExec (nxc)** — operaciones SMB/LDAP/WinRM a escala.
- **PowerView / PowerSploit** — enumeración de AD.
- **Ligolo-ng** — tunelado y pivotaje.
- **DSInternals** — manipulación de objetos de directorio.

## 📈 Profundización (opcional, fuera del alcance de CRTO)

- Rutas de desarrollo de evasión a bajo nivel (tipo OSEP / cursos de maldev) — útiles a largo plazo, no
  requisito del examen. Se mencionan a nivel de orientación, no como dependencia del repo.

---

> **Nota de uso:** cita aquí (con enlace y fecha de consulta) cualquier fuente concreta que sustente una
> técnica o una decisión de detección en un lab, para mantener la trazabilidad del producto.

*Referencias · 18/06/2026 · Documento vivo*