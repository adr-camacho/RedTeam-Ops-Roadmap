# Detection — Lab-10 Deep Root

> **Capability:** detección de persistencia de host y escalada local desde la perspectiva del defensor.
> **Arquetipo:** Operación · **Adversario:** Lazarus · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

> El espejo de `technique.md`: cada vía de escalada y cada mecanismo de persistencia deja rastro. Operar bien es elegir el que menos delata, sabiendo qué se vigila.

---

## 1. Detección de escalada de privilegios

### 1.1 Abuso de token (Potato)
- **Sysmon Event 1** — proceso hijo con integridad SYSTEM lanzado por un proceso de integridad media/cuenta de servicio.
- Named pipes anómalos (los Potato crean pipes característicos).
- Proceso `NT AUTHORITY\SYSTEM` engendrado por IIS/MSSQL/cuenta de servicio sin justificación.

### 1.2 Misconfiguración de servicios
- **Event 7045** (servicio nuevo instalado) / **4697**.
- Modificación de `binPath` de un servicio existente (cambio de configuración).
- Escritura en rutas de servicio por usuarios no-admin (precede al hijack).

### 1.3 UAC bypass
- Claves de registro de los bypasses conocidos (fodhelper: `HKCU\...\ms-settings\shell\open\command`).
- Proceso de alta integridad lanzado por la cadena de un bypass conocido.

## 2. Detección de persistencia

| Mecanismo | Telemetría clave |
|-----------|------------------|
| Registry Run keys | **Sysmon Event 13** (registry value set) en claves `\Run` |
| Scheduled Tasks | **Event 4698** (tarea creada) · Sysmon 1 de `schtasks.exe`/`taskeng.exe` |
| Services | **Event 7045 / 4697** (servicio instalado) |
| Startup folder | creación de archivo en carpeta de inicio (Sysmon 11) |
| COM hijacking | **Sysmon Event 12/13** en claves CLSID de HKCU |
| WMI event subscription | **Sysmon Event 19/20/21** (WMI filter/consumer/binding) |

## 3. Reglas de ejemplo (concepto)

- **Sigma:** proceso SYSTEM engendrado por cuenta de servicio (caza Potato).
- **Sigma:** creación de scheduled task con comando codificado/sospechoso.
- **KQL/Defender:** `DeviceRegistryEvents` sobre claves Run y CLSID de HKCU.
- **WMI:** alerta sobre creación de `__EventFilter` + `CommandLineEventConsumer`.

## 4. Indicadores (IoCs)

- Proceso SYSTEM con padre IIS/MSSQL/cuenta de servicio.
- Named pipes característicos de PrintSpoofer/GodPotato.
- Nuevas Run keys, tareas o servicios apuntando a binarios fuera de rutas estándar.
- Suscripciones WMI permanentes nuevas.

---

## Limitaciones y evasión (puente a Phase-03)

| Detección | Cómo se evade | Se trata en |
|-----------|---------------|-------------|
| Sysmon/EDR sobre creación de proceso SYSTEM | Token theft más sutil, in-memory | Lab-11 |
| Event 4698/7045 (tarea/servicio) | Mecanismos más sigilosos (COM/WMI) elegidos por proporcionalidad | este lab |
| Run keys muy monitorizadas | COM hijacking / WMI (menos vigilados) | este lab |
| Artefactos en disco | Persistencia fileless (WMI event subscription) | este lab |

> La proporcionalidad ES evasión: elegir el mecanismo que el entorno no vigila de cerca evita la alerta sin necesidad de un bypass.

---

*Detection · Lab-10 Deep Root · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
