# Theory — C2 Foundations (Black Beacon)

> **Lab-08 · C2 Foundations**  
> Bloque CRTO: Command & Control · Modelo de operador Cobalt Strike  
> Enfoque: El examen es operado enteramente a través del C2. Sin dominar este bloque, el resto falla.

---

## 1. ¿Qué es un C2?

Un **Command & Control (C2)** es la infraestructura que permite a un operador **controlar remotamente** un host comprometido (o múltiples hosts). No es solo "ejecución de comandos": es un **sistema de comunicación bidireccional, resiliente y sigiloso** entre operador e implantes.

En el examen CRTO:
- **El operador está en una consola o interfaz web.**
- **Los implantes (beacons) están en los hosts comprometidos.**
- **El C2 es el "sistema nervioso" que conecta ambos lados.**

Sin C2, no hay examen. Dominar C2 es dominar **cómo se opera**.

---

## 2. Arquitectura de C2 (modelo de operador)

### 2.1 Team Server (C2 servidor)

El **team server** es la infraestructura central:
- Corre en un servidor Linux/Windows controlado por el operador.
- Escucha conexiones entrantes de los beacons en los hosts víctima.
- Almacena metadata (sesiones activas, tareas pendientes, output de comandos).
- Interfaz de operador: consola interactiva o interfaz web.

**En Cobalt Strike:**
- Team Server escucha en un puerto (ej: 50050)
- Cliente (operador) se conecta via SSH + interfaz gráfica
- Totalmente encrypted y autenticado

**En Sliver (análogo open-source):**
- Comando `server` inicia el server
- Cliente se conecta via `connect <IP>:<PUERTO>`
- Similar en funcionalidad, diferente en interfaz

**Crítico para el examen:** entender que el team server es el punto central de control. Si cae, pierdes todas las sesiones.

### 2.2 Listeners

Un **listener** es un servicio que corre en el team server y espera conexiones de beacons.

**Tipos de listener (por protocolo):**

| Listener | Transporte | Uso | OPSEC | Notas |
|----------|-----------|-----|------|-------|
| HTTP | HTTP claro | Testing, redes permisivas | Bajo | Tráfico en claro (detectable) |
| HTTPS | HTTPS encriptado | Producción | Alto | Certificado (SSL/TLS) requerido |
| SMB | Named pipes (SMB) | Lateral movement | Alto | Solo en red interna; peer-to-peer |
| TCP | Raw TCP | C2 directo o tunelado | Medio | Flexible; requiere encriptación en payload |
| DNS | DNS queries | Exfil, comando lento | Alto | Muy sigiloso; lento; evasión de firewall |

**En CRTO:**
- El examen típicamente **habilita HTTPS como listener principal.**
- Requiere un certificado válido (self-signed es aceptable en lab).
- La mayoría de operaciones van por HTTPS.

**En el lab (Sliver):**
```
# Crear listener HTTPS
listeners -l

# Ejemplo: listener HTTPS en puerto 443
https -l 0.0.0.0 -p 443
```

**Equivalencia CS ↔ Sliver:**
- CS: `listeners` (tab en consola)
- Sliver: `listeners` (comando)

---

## 3. Payloads: Staged vs Stageless

### 3.1 Staged Payload

Un **staged payload** es un pequeño "descargador" que, al ejecutarse, descarga el beacon completo desde el team server.

**Flujo:**
1. Operador genera el stager (~10-50 KB, muy pequeño)
2. Se entrega al objetivo (phishing, exploit, etc.)
3. El stager se ejecuta
4. **Conecta al listener y descarga el beacon verdadero** (~200+ KB)
5. El beacon se ejecuta en memoria
6. Sesión abierta

**Ventajas:**
- ✅ Payload muy pequeño (antivirus bypass más fácil)
- ✅ Flexible: el stage2 (beacon completo) se puede cambiar sin regenerar stager
- ✅ Menos footprint en el disco (el stager es temporal)

**Desventajas:**
- ❌ Segunda conexión visible (dos traces de tráfico)
- ❌ Si la descarga falla, no hay sesión
- ❌ Más complejidad

**En CRTO:** Staged es más común en ataques reales por su tamaño.

### 3.2 Stageless Payload

Un **stageless payload** es un binario completo que contiene toda la lógica del beacon.

**Flujo:**
1. Operador genera el payload completo (~300+ KB)
2. Se entrega al objetivo
3. Se ejecuta
4. **Conexión directa al listener**
5. Sesión abierta

**Ventajas:**
- ✅ Una sola conexión (más directo)
- ✅ Sin dependencia de descarga exitosa
- ✅ Más robusto

**Desventajas:**
- ❌ Payload más grande (antivirus más probable)
- ❌ Menos flexible (cambios requieren regenerar todo)

**En CRTO:** Stageless se usa cuando el tamaño no es problema o cuando la integridad importa más que el sigilo.

**Decisión práctica:**
- Red externa, evasión crítica → **Staged**
- Red interna, velocidad → **Stageless**

---

## 4. OPSEC Básico de C2

El objetivo de OPSEC de C2 es **minimizar la telemetría observable** sin perder funcionalidad.

### 4.1 Sleep y Jitter

Un beacon no está siempre "conectado". Cada cierto tiempo, **se "despierta", se conecta, recibe tareas, ejecuta, devuelve output, y vuelve a dormir.**

**Sleep (duración de reposo):**
- Default: 5 segundos (muy detectable)
- OPSEC: 30-60 segundos (o más en red de defensa alta)
- Mayor sleep → menos conexiones → más sigiloso, pero más lento

**Jitter (variabilidad aleatoria):**
- Si sleep es exactamente 30s cada vez, el patrón es obvio (telemetría).
- Jitter añade aleatoridad: "30s ± 30%" = conexión cada 21-39s aleatoriamente.
- Rompe patrones, reduce detectabilidad.

**En Cobalt Strike:**
```
beacon> sleep 30 50
// "Duerme 30 segundos con 50% de jitter"
```

**En Sliver:**
```
implant config set --BeaconInterval 30000 --BeaconJitter 0.50
```

**Impacto en el examen:**
- Sleep corto (5-10s): Rápido, pero muy visible (telemetría clara)
- Sleep largo (60s+): Sigiloso, pero lento para responder
- **Recomendación:** empezar en 30-45s, ajustar según defensas observadas

### 4.2 User-Agent y Profiling

El beacon se comunica vía HTTP/S, y **cada solicitud HTTP tiene un User-Agent.**

**Default (muy sospechoso):**
```
Mozilla/4.0 (compatible; ms-rpc/2.0)  ← Obviamente malware
```

**OPSEC (imitar navegador legítimo):**
```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
```

**En Cobalt Strike:**
- Profile Malleable C2 permite personalizar user-agent, headers HTTP, beacon behavior
- Ver §5 (detección) para cómo esto impacta lo observable

### 4.3 Patrón de Comunicación (Beaconing)

**Qué es observable:**
- IP de origen (host víctima)
- IP de destino (listener)
- Puerto de destino
- Hora de conexión
- Volumen de datos
- Headers HTTP / respuestas TLS

**Sigiloso:**
- Conexiones espaciadas (jitter)
- Volúmenes pequeños (sin burst)
- Headers que parecen navegación legítima
- HTTPS (cifra contenido)

---

## 5. Tabla de Equivalencia: Cobalt Strike ↔ Sliver

| Acción | Cobalt Strike | Sliver | Notas |
|--------|---|---|---|
| **Iniciar team server** | `./teamserver <ip> <pass>` | `server --lhost 0.0.0.0 --lport 31337` | CS requiere password; Sliver genera token |
| **Conectar como operador** | Client GUI (SSH tunnel) | `connect <ip>:<puerto>` en consola | |
| **Crear listener HTTPS** | `listeners` tab → HTTP/S/SMB/etc | `https -l 0.0.0.0 -p 443` | Ambos requieren cert válido |
| **Generar payload staged** | `Attacks → Packages → Windows Exe (Staged)` | `generate --os windows --arch amd64 --format exe` + listener | CS UI; Sliver CLI |
| **Generar payload stageless** | `Attacks → Packages → Windows Exe` | `generate --os windows --arch amd64 --format exe` (sin staged) | |
| **Ejecutar comando** | `shell whoami` | `shell whoami` | Sintaxis idéntica en muchos casos |
| **Session listing** | `sessions` | `sessions` | Mismo resultado visual |
| **Cambiar sleep/jitter** | `sleep 30 50` | `implant config set --BeaconInterval 30000 --BeaconJitter 0.50` | CS: segundos; Sliver: milisegundos |
| **PowerShell execution** | `powershell <script>` | `powershell <script>` | Similar |
| **Download/Upload** | `download <path>` / `upload <local>` | `download <path>` / `upload <local>` | Similar |
| **In-memory execution** | `execute-assembly` (BOFs) | `execute <binary>` | Different naming |
| **Lateral movement (WinRM)** | `jump psexec64 <target> <listener>` | `session create --host <target>` (vía Sliver relay) | CS integrado; Sliver vía relay |

**Punto clave:** La **lógica es idéntica**, la sintaxis puede variar. Dominar Cobalt Strike en el curso oficial te permite operar Sliver aquí, y viceversa.

---

## 6. MITRE ATT&CK Mapping

| Táctica | Técnica | ID | Contexto C2 |
|---------|---------|----|----|
| Command & Control | Ingress Tool Transfer | T1105 | Descarga de payload/stage2 |
| Command & Control | Application Layer Protocol | T1071.001 | HTTP/HTTPS beacon traffic |
| Command & Control | Encrypted Channel | T1573 | Cifrado de comunicaciones beacon |
| Command & Control | Proxy | T1090 | Tunelado/pivotaje de C2 |
| Defense Evasion | Obfuscated Files/Information | T1027 | Payload ofuscado, stager comprimido |
| Execution | Command and Scripting Interpreter | T1059 | Ejecución de comandos vía beacon |

---

## 7. Conceptos Clave para el Examen

1. **El C2 es el eje central.** Sin sesión abierta, no haces nada.
2. **Sleep/Jitter es OPSEC real.** Con Defender activo, un beacon en clear visibility (5s sleep) es detectado en segundos. Ajusta según entorno.
3. **Listener choice importa.** HTTPS en externo, SMB en lateral movement, DNS para covert channel.
4. **Payload generation es flexible.** Puedes adaptar tamaño/tipo según objetivo.
5. **Las herramientas cambian, la lógica no.** Cobalt Strike en el examen, Sliver aquí: ambos responden a los mismos principios.

---

## 8. Próximos Pasos (Labs 09+)

- **Lab-09:** Delivery de payload (phishing, web RCE) y obtención del primer beacon
- **Lab-10:** Persistencia local del beacon (para que sobreviva reinicio)
- **Lab-11:** Evasión Defender/AMSI mientras beacon comunica
- **Lab-12+:** Movimiento lateral y escalada de dominio **vía comandos del beacon**

---

*Theory · Lab-08 Black Beacon · 18/06/2026*