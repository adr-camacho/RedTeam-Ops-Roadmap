# Technique — Lab-11 Ghost Signal

> **Capability (eje didáctico):** Evasión I — Windows Defender, AMSI, ETW; firma vs comportamiento; el modelo de los kits de evasión de C2.
> **Bloque CRTO:** AV/EDR Evasion (el corazón del examen — sin esto, los beacons caen).
> **Arquetipo:** Concepto / Tradecraft — se construye el **porqué** y el **cómo se detecta**. El código armado (bypass/loader/kit) **no vive en el repo**: se practica en el laboratorio oficial CRTO.
> **Adversario (escenario):** Lazarus Group — ver [`emulation.md`](emulation.md). **El terreno más genuino de Lazarus en Phase-03.**

> El examen CRTO tiene Defender encendido. Lo que separa aprobar de perder el beacon no es memorizar un bypass — es entender **por qué** saltas, qué firma vs qué comportamiento te delata, y qué genera telemetría. Este lab construye ese criterio.

---

## 1. El marco: firma vs comportamiento

La distinción fundamental que ordena toda la evasión:

| Detección por firma | Detección por comportamiento |
|--------------------|-----------------------------|
| El AV compara el binario/script con una base de datos de patrones conocidos | El EDR observa lo que hace el código mientras se ejecuta |
| Se evade con ofuscación, empaquetado, encoding | Se evade cambiando cómo se hacen las cosas (no crear procesos, no tocar disco) |
| AMSI inspecciona el contenido del script en runtime | El EDR detecta inyección de proceso, carga del CLR, llamadas API sospechosas |
| **Evitar la firma no evita el comportamiento** | **Evitar el comportamiento es más difícil y más valioso** |

**La lección más importante:** ofuscar un payload evita que la firma lo case — pero si el comportamiento (inyección, API calls) sigue igual, el EDR lo ve igual. La evasión madura trabaja en ambas capas.

## 2. Windows Defender — las capas del motor

Defender no es un solo control — es un stack:

| Capa | Qué hace | Cuándo actúa |
|------|---------|--------------|
| **Signature scanning** | Compara hash/contenido con base de datos | Al escribir en disco o abrir un archivo |
| **AMSI** | Inspecciona scripts (PS, VBS, .NET) antes de ejecutarlos | En runtime, antes de la ejecución |
| **Behavioral monitoring** | Observa acciones del proceso en ejecución | Durante la ejecución |
| **Memory scanning** | Escanea regiones de memoria en busca de firmas | Periódicamente o al crear proceso |
| **Network inspection** | Inspecciona tráfico de red | En conexiones salientes |

**Tamper Protection:** desde Windows 10 1903, Defender tiene Tamper Protection activado por defecto. Intentar desactivarlo desde PowerShell/registro falla silenciosamente o dispara una alerta. **En el examen CRTO no se puede desactivar Defender** — hay que operar con él encendido.

## 3. AMSI — Application Malware Scan Interface

AMSI es el mecanismo por el que PowerShell, .NET, JScript y otros runtimes piden a Defender que inspeccione el contenido antes de ejecutarlo.

**Qué intercepta:**
- Scripts de PowerShell (`Invoke-Expression`, `IEX`, `-EncodedCommand`).
- Ensamblados .NET cargados en memoria.
- COM y WMI scripting.

**Por qué importa:** un script de PowerShell en texto claro que use strings de Mimikatz, PowerView o Empire es bloqueado por AMSI antes de ejecutarse, aunque el archivo no esté en disco.

**El concepto de neutralización (sin código armado):**
AMSI funciona como una librería (`amsi.dll`) cargada en el proceso de PowerShell. El bypass consiste en modificar esa librería en memoria para que deje de inspeccionar — hacerla retornar "limpio" siempre. El código concreto se practica en el lab del curso; lo que importa aquí es entender que es una modificación en memoria, no en disco.

**Implicación para el operador:** con AMSI activo, los scripts en claro de herramientas conocidas (SharpHound, PowerView) fallan. Sin AMSI (o con bypass), funcionan. El estado de AMSI es parte del checklist de Lab-09 (postura defensiva).

## 4. ETW — Event Tracing for Windows

ETW es la infraestructura de telemetría nativa de Windows que alimenta a los EDRs. Procesos, llamadas API, carga de módulos, actividad de red — todo pasa por ETW.

**Por qué importa para el operador:**
- Cuando ejecutas `execute-assembly SharpHound.exe`, ETW registra la carga del ensamblado .NET, las llamadas LDAP, los procesos creados.
- Un EDR que consume ETW ve todo eso en tiempo real.

**El concepto de patching de ETW (técnica firma de Lazarus):**
ETW puede ser parcialmente cegado modificando en memoria la función que emite los eventos. Sin esa emisión, el EDR no recibe la telemetría. Lazarus usa esta técnica documentadamente (T1562.006). El código concreto es práctica de laboratorio; el concepto es: si el proceso no emite eventos ETW, el EDR trabaja a ciegas para ese proceso.

**Lo que ETW protege que AMSI no:** mientras AMSI inspecciona el contenido de scripts, ETW registra comportamiento de proceso. Un ensamblado que bypasea AMSI pero no ETW sigue generando telemetría detectable.

## 5. El modelo de kits de Cobalt Strike

Para operar con Defender ON, CS tiene un sistema de kits que permiten personalizar cómo genera artefactos:

| Kit | Qué personaliza | Por qué importa |
|-----|----------------|-----------------|
| **Artifact Kit** | Cómo se genera el stager/payload en disco | Evita las firmas del shellcode de CS por defecto |
| **Resource Kit** | Scripts de PowerShell y plantillas de CS | Evita firmas en el material de soporte |
| **Malleable C2** | Tráfico del beacon (Lab-16) | Evita que el NTA detecte el C2 por patrones |

> El código concreto de los kits se practica en el lab oficial del curso CRTO. Lo que se transfiere al examen es saber **cuándo y por qué** usar cada kit.

## 6. MITRE ATT&CK

| Táctica | Técnica | ID |
|---------|---------|----|
| Defense Evasion | Impair Defenses: Disable/Modify Tools | T1562.001 |
| Defense Evasion | Impair Defenses: Indicator Blocking (ETW) | T1562.006 |
| Defense Evasion | Obfuscated Files: Software Packing | T1027.002 |
| Defense Evasion | Reflective Code Loading | T1620 |

## 7. Key Takeaways

1. **Firma ≠ comportamiento.** Ofuscar el payload evita la firma; cambiar cómo actúa el proceso evita la detección por comportamiento. Hay que trabajar ambas capas.
2. **AMSI inspecciona el contenido en runtime.** Un script en claro con strings conocidas muere antes de ejecutarse, aunque no esté en disco.
3. **ETW es la fuente de telemetría del EDR.** Cegar ETW para el proceso del beacon deja al EDR sin visibilidad de ese proceso.
4. **Tamper Protection bloquea deshabilitar Defender.** En el examen CRTO, no se puede apagar Defender — hay que operar con él activo.
5. **El porqué se construye aquí; el código se practica en el curso.** Lo que se transfiere al examen es saber qué ajustar cuando algo se detecta, no memorizar el bypass.

## Referencias

- MITRE ATT&CK — T1562, T1620, T1027
- Cobalt Strike — Artifact Kit, Resource Kit documentación
- The Hacker Recipes — AV/EDR evasion
- Lab-12 (Iron Veil): la capa complementaria (AppLocker/CLM/LOLBAS)

---

*Technique · Lab-11 Ghost Signal · Evasión I Defender/AMSI/ETW (anatomía v3.1, arquetipo concepto). El código armado no vive en el repo por diseño.*
