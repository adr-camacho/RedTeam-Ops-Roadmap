# Detection — Lab-16 Custom Arsenal

> **Capability:** detección de C2 adaptado (Malleable profiles, BOFs, tráfico de beacon personalizado).
> **Arquetipo:** Concepto · **Adversario:** APT10 · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

> El reto del defensor: cuando el C2 está bien configurado, **ya no parece C2**. El tráfico imita Office365, los intervalos son irregulares, y no hay proceso hijo. La detección pasa de "buscar firmas de CS" a "buscar comportamiento de beaconing bajo cualquier disfraz".

---

## 1. Detección de Malleable C2 (tráfico adaptado)

- **JA3/JA3S fingerprint** del TLS handshake — aunque el URI y el User-Agent imiten Office365, la huella TLS del proceso que abre la conexión puede identificar al beacon.
- **Jitter analysis:** incluso con jitter, el intervalo de beaconing tiene una distribución estadística detectable si el volumen de datos es suficiente.
- **Discrepancia User-Agent vs proceso:** el User-Agent dice ser "Microsoft Office" pero el proceso que hace la conexión es `notepad.exe` — incoherente.
- **Dominios de C2:** JARM fingerprint del servidor C2 (aunque rote IPs, el TLS handshake del servidor puede ser constante).

## 2. Detección de BOFs

- **Sin proceso hijo:** la ausencia de `cmd.exe` / `powershell.exe` hijo no es señal de ausencia de actividad — al contrario, un beacon que hace muchas cosas sin crear procesos es más sospechoso en entornos maduros.
- **Memory scanning:** ejecución desde regiones de memoria no respaldadas en disco (RWX) dentro del proceso del beacon.
- **Call stack anómalo:** llamadas a API sensibles (LSASS, registry) desde regiones de memoria no asociadas a módulos conocidos.

## 3. Detección de perfil por defecto (lo que Custom Arsenal evita)

- Herramientas como **Beacon Kibana** o **CS-Detector** buscan patrones específicos del perfil default de CS.
- URIs con patrones `/submit.php`, `/load`, cabeceras `X-Malware-Behavior`.
- `sleeptime 60000` exacto sin jitter (comportamiento de beacon no configurado).

## 4. Reglas de ejemplo (concepto)

- **JA3:** base de datos de JA3 de procesos conocidos — detectar procesos que usan JA3 de CS en vez del de su aplicación legítima.
- **NTA:** análisis de periodicidad de conexiones a un mismo destino (beaconing aunque esté disfrazado).
- **Sigma:** proceso con User-Agent de Office pero sin ser un proceso de Office haciendo HTTP.

---

## Limitaciones y evasión (el meta-juego de Custom Arsenal)

| Detección | Cómo se evade | Implica |
|-----------|---------------|---------|
| JA3 fingerprint | Personalizar el TLS handshake en el perfil | Malleable avanzado |
| Jitter analysis | Jitter más agresivo + traffic shaping | Configuración de perfil |
| Discrepancia User-Agent/proceso | Inyectar el beacon en un proceso que SÍ hace HTTP | process-inject en el perfil |
| Memory scanning (BOF) | Module stomping, memory regions respaldadas | Técnica avanzada |

> La capa de Custom Arsenal es un juego continuo entre el operador y el defensor maduro. No existe "invisible perfecto" — existe "más difícil que el anterior beacon de CS por defecto".

---

*Detection · Lab-16 Custom Arsenal · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
