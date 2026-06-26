# Detection — Lab-17 Silent Exit

> **Capability:** detección de exfiltración de datos (staging, cloud exfil, limpieza de evidencias).
> **Arquetipo:** Operación · **Adversario:** APT10 · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

---

## 1. Detección de data hunting (búsqueda de shares)

- **Sysmon Event 3** (network connection) — acceso a muchos hosts en puerto 445 desde un único origen.
- `Find-DomainShare` / `Invoke-ShareFinder` generan tráfico SMB en ráfaga — patrón de enumeración.
- **Event 5140/5145** (acceso a share de red) — acceso a shares de alta sensibilidad (Finance, HR) por cuentas inusuales.

## 2. Detección de staging y compresión

- **Sysmon Event 1** — ejecución de `7z.exe`, `rar.exe`, `WinRAR.exe` con parámetros de compresión + contraseña (`-p`).
- Creación de archivos `.rar`, `.7z`, `.zip` de gran tamaño en directorios de usuario o temporales.
- **DLP:** si el DLP inspecciona el proceso de creación de archivos, puede detectar que los datos en el archivo provienen de directorios sensibles.

## 3. Detección de exfiltración vía servicios cloud

- **Sysmon Event 3** — conexiones HTTPS hacia `api.dropbox.com`, `dl.dropboxusercontent.com`, OneDrive, GitHub.
- **Proxy logs:** `dbxcli` o herramientas similares haciendo PUT de archivos grandes hacia servicios de almacenamiento cloud.
- **DLP de red:** inspección de tráfico saliente cifrado hacia destinos cloud con volúmenes anómalos.
- La señal es **contexto + volumen**: la conexión a Dropbox es legítima; un proceso no-usuario subiendo 500MB es anómala.

## 4. Detección de exfiltración vía C2

- Volumen anómalo de datos salientes desde el proceso del beacon (mayor de lo habitual para un beacon).
- **NetFlow:** tráfico de salida sostenido hacia la IP del C2 con volumen inusual.

## 5. Detección de limpieza de artefactos

- **Sysmon Event 23/26** (file delete) — eliminación masiva de archivos o herramientas en directorios del sistema.
- **Event Log tampering** (Event 1102/104): borrado del log del sistema — señal de alarm flag para el defensor.
- Ausencia súbita de telemetría de un proceso que antes generaba eventos (el proceso del beacon terminado).

## 6. Reglas de ejemplo (concepto)

- **Sigma:** `rar.exe` / `7z.exe` con argumento `-p` (contraseña) y destino de archivo fuera de rutas de trabajo.
- **Proxy/CASB:** upload PUT de archivos grandes hacia Dropbox/OneDrive desde un host no habitual.
- **DLP:** archivo comprimido con contenido de directorios de alta clasificación.

---

*Detection · Lab-17 Silent Exit · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
