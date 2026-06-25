# Detection — Lab-09 First Contact

> **Capability:** detección de actividad de reconocimiento (Discovery) desde la perspectiva del defensor.
> **Arquetipo:** Concepto · **Adversario:** Lazarus · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

> El espejo de `technique.md`: el operador cree que "solo está mirando", pero **la enumeración deja rastro**. Saber qué genera telemetría es lo que permite hacer recon sin disparar alarmas.

---

## 1. La premisa: el recon no es invisible

El reconocimiento se percibe como inofensivo ("no estoy atacando, solo enumero"), pero para un defensor maduro es una **señal temprana de intrusión**. Detectar recon es detectar al atacante *antes* de que escale. Por eso el operador debe saber qué patrones se vigilan.

## 2. Detección de recon de AD (el más ruidoso)

### 2.1 Patrón de SharpHound / BloodHound
- **Consultas LDAP masivas** en ráfaga: un único origen consultando todos los usuarios, grupos, equipos y ACLs en segundos.
- **Event 1644** (LDAP costoso) si el logging fino está activo; volumen anómalo de consultas al DC.
- **Sesiones SAMR / NetSessionEnum** a múltiples equipos en poco tiempo (enumeración de sesiones).

### 2.2 Enumeración de trusts y dominio
- Consultas a `trustedDomain` objects, `nltest /domain_trusts`.
- Acceso secuencial a múltiples objetos sensibles del directorio.

## 3. Detección a nivel de host

### 3.1 Ejecución de herramientas de recon conocidas
- **Seatbelt, PowerView, SharpView** → assemblies con firmas conocidas; AMSI/EDR pueden detectar la carga.
- `execute-assembly` de .NET en memoria → algunos EDR detectan el CLR cargándose en procesos inusuales.

### 3.2 Comandos de descubrimiento en ráfaga
- `whoami`, `net group`, `nltest`, `tasklist`, `systeminfo` ejecutados en segundos → **comportamiento no humano**.
- **Sysmon Event 1** (Process Creation) capturando cadenas de comandos de discovery.
- **PowerShell 4104** (Script Block Logging) si el recon usa PowerShell.

## 4. Reglas de ejemplo (concepto)

- **Sigma:** múltiples comandos de discovery (whoami/net/nltest/systeminfo) del mismo proceso padre en ventana corta.
- **KQL/Defender:** `DeviceProcessEvents` filtrando binarios de discovery encadenados.
- **LDAP:** umbral de consultas por origen/minuto al DC (caza SharpHound).

## 5. Indicadores (IoCs)

- Ráfaga de consultas LDAP de un solo host no-DC.
- Carga de assemblies .NET conocidos (Seatbelt/SharpHound) en procesos no-desarrollo.
- Secuencia de comandos de discovery con timing sub-humano.
- NetSessionEnum/SAMR contra muchos equipos desde un único origen.

---

## Limitaciones y evasión (puente a Phase-03)

| Detección | Cómo se evade | Se trata en |
|-----------|---------------|-------------|
| Carga de Seatbelt/SharpHound (AMSI/firma) | Ejecución in-memory, BOFs, herramientas custom | Lab-11 |
| Ráfaga LDAP de SharpHound | Recon dirigido, throttling, colección por fases | este lab (OPSEC) |
| Timing sub-humano de comandos | Espaciado, recon manual selectivo | este lab (OPSEC) |
| Assemblies .NET conocidos | BOFs (Beacon Object Files) en vez de execute-assembly | Lab-16 |

> El recon perfecto es el que el defensor no distingue del ruido normal. La disciplina de la primera hora (dirigido, espaciado, en memoria) es la primera capa de evasión.

---

*Detection · Lab-09 First Contact · hereda de DETECTION_LIBRARY.md (anatomía v3.1)*
