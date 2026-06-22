# Tradecraft — Operación GHOST FOREST
## Lab-01: Fundamentos de Active Directory Attacks

**Operación:** GHOST FOREST | **Adversario:** APT29 | **Nivel:** Fundamentals  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [Active Directory — Arquitectura y modelo de confianza](#1-active-directory)
2. [Kerberos — El protocolo de autenticación de AD](#2-kerberos)
3. [AS-REP Roasting — Por qué funciona](#3-as-rep-roasting)
4. [Kerberoasting — Por qué funciona](#4-kerberoasting)
5. [Pass-the-Hash y Pass-the-Ticket](#5-pass-the-hash-y-pass-the-ticket)
6. [DCSync — Replicación como arma](#6-dcsync)
7. [Delegation Abuse — Unconstrained y Constrained](#7-delegation-abuse)
8. [GPO Abuse — Group Policy como vector](#8-gpo-abuse)
9. [ACL Abuse — Permisos AD como attack path](#9-acl-abuse)
10. [BloodHound — Teoría del grafo aplicada a AD](#10-bloodhound)
11. [Golden Ticket — Por qué falla en entornos modernos](#11-golden-ticket)
12. [OPSEC — Principios para operar en AD](#12-opsec)

---

## 1. Active Directory — Arquitectura y modelo de confianza

### ¿Qué es Active Directory?

Active Directory (AD) es un servicio de directorio de Microsoft que gestiona **identidades** (usuarios, equipos, grupos) y **políticas** (contraseñas, accesos, configuraciones) en un entorno Windows corporativo.

El concepto fundamental es el **dominio** — una unidad administrativa con un nombre DNS (`atackcorp.local`) y un **Domain Controller** que actúa como autoridad central de autenticación y autorización.

### Por qué AD es el objetivo principal de un Red Teamer

AD es el corazón de la mayoría de infraestructuras corporativas. Comprometer el Domain Controller significa:

1. **Control total de identidades** — cualquier usuario, cualquier equipo
2. **Acceso a todos los recursos** — shares, bases de datos, aplicaciones
3. **Persistencia indefinida** — Golden Ticket, certificados, shadow credentials
4. **Movimiento lateral sin límites** — cualquier sistema del dominio

La pregunta no es *si* se puede comprometer AD — es *cuánto tiempo lleva* encontrar el path.

### Objetos clave en AD

| Objeto | Descripción | Por qué interesa al atacante |
|--------|-------------|------------------------------|
| **Usuario** | Cuenta de persona o servicio | Credenciales, SPNs, ACLs |
| **Equipo** | Cuenta de máquina (DC$, WKSTN-01$) | TGTs, delegación, lateral movement |
| **Grupo** | Colección de objetos | Domain Admins, Administrators, grupos con ACLs |
| **OU** | Unidad organizativa | Scope de GPOs |
| **GPO** | Group Policy Object | Configuración que se aplica a OUs enteras |
| **ACE/DACL** | Access Control Entry / List | Permisos sobre objetos AD |
| **SPN** | Service Principal Name | Target de Kerberoasting |

### Modelo de privilegios — Tier Model

Microsoft recomienda el **Tier Model** para proteger AD:

```
Tier 0: Domain Controllers, AD infrastructure (máximo privilegio)
Tier 1: Servidores de aplicaciones, servicios críticos
Tier 2: Workstations, usuarios finales
```

Como atacante, el objetivo es siempre **Tier 0**. El camino suele ir de Tier 2 → Tier 1 → Tier 0.

---

## 2. Kerberos — El protocolo de autenticación de AD

Kerberos es el protocolo de autenticación principal de AD desde Windows 2000. Entenderlo a fondo es imprescindible — la mayoría de los ataques AD abusan de Kerberos.

### Flujo de autenticación Kerberos

```
Cliente                    KDC (DC-01)                    Servicio
   |                           |                              |
   |--AS-REQ (usuario)-------->|                              |
   |<-AS-REP (TGT)-------------|                              |
   |                           |                              |
   |--TGS-REQ (TGT + SPN)----->|                              |
   |<-TGS-REP (TGT de servicio)|                              |
   |                           |                              |
   |--AP-REQ (TGS)-------------|----------------------------->|
   |<-AP-REP (acceso)----------|------------------------------|
```

### Componentes clave

**TGT (Ticket Granting Ticket)**
- Emitido por el KDC tras la autenticación inicial
- Cifrado con el hash de **krbtgt** — la cuenta más crítica del dominio
- Válido 10 horas por defecto (renovable hasta 7 días)
- Prueba de identidad del usuario ante el KDC

**TGS (Ticket Granting Service)**
- Emitido por el KDC en respuesta a una solicitud de acceso a un servicio
- Cifrado con el hash de la **cuenta de servicio** (SPN)
- Contiene la identidad del usuario y sus privilegios (PAC)
- Solo el servicio destino puede descifrarlo

**KDC (Key Distribution Center)**
- Componente del Domain Controller
- Dos partes: AS (Authentication Service) y TGS (Ticket Granting Service)
- Toda la confianza del dominio pasa por él

**PAC (Privilege Attribute Certificate)**
- Estructura dentro de los tickets que contiene grupos del usuario
- Firmado por el KDC con la clave de krbtgt
- Permite que el servicio de destino verifique los privilegios sin contactar el KDC

### Pre-autenticación Kerberos

La pre-autenticación es un mecanismo de seguridad que exige que el cliente demuestre que conoce su contraseña **antes** de que el KDC emita el TGT.

Sin pre-autenticación:
1. El cliente envía solo su nombre de usuario
2. El KDC responde con un TGT cifrado con el hash del usuario
3. **Cualquiera puede solicitar ese TGT y crackearlo offline**

Este es el fundamento del **AS-REP Roasting**.

---

## 3. AS-REP Roasting — Por qué funciona

### Condición necesaria

La cuenta objetivo debe tener habilitado `DONT_REQUIRE_PREAUTH` en `userAccountControl`. Este atributo existe por compatibilidad con sistemas legados que no soportaban pre-autenticación.

### Flujo del ataque

```
1. Atacante → KDC: AS-REQ con username (sin pre-auth, sin contraseña)
2. KDC → Atacante: AS-REP con TGT cifrado con hash NT del usuario
3. Atacante: hashcat/john offline → contraseña en claro
```

### Por qué el KDC responde

El KDC no puede distinguir entre un cliente legítimo sin pre-auth y un atacante. Si la cuenta tiene `DONT_REQUIRE_PREAUTH`, simplemente cumple el protocolo y responde.

### Formato del hash

```
$krb5asrep$23$usuario@DOMINIO:...
```

El `$23$` indica RC4-HMAC — el cifrado más débil y el más fácil de crackear.

### Defensa

- **Nunca** habilitar `DONT_REQUIRE_PREAUTH` salvo necesidad absoluta
- Monitorizar Event ID 4768 con `Pre-authentication Type: 0`
- Usar contraseñas largas y aleatorias en cuentas con este flag

### Variantes del ataque

| Variante | Condición | Herramienta |
|----------|-----------|-------------|
| Sin credenciales | Lista de usuarios conocidos | `GetNPUsers.py -no-pass -usersfile` |
| Con credenciales | Acceso LDAP al dominio | `GetNPUsers.py -request` |
| Desde Windows | Acceso al dominio | `Rubeus.exe asreproast` |

---

## 4. Kerberoasting — Por qué funciona

### Condición necesaria

La cuenta objetivo debe tener un **SPN (Service Principal Name)** registrado. Los SPNs identifican instancias de servicios (SQL Server, IIS, etc.) y son necesarios para la autenticación Kerberos de servicios.

### Flujo del ataque

```
1. Atacante (autenticado) → KDC: TGS-REQ para SPN/servicio
2. KDC → Atacante: TGS cifrado con el hash NT de la cuenta de servicio
3. Atacante: hashcat/john offline → contraseña de la cuenta de servicio
```

### Por qué el KDC responde con el TGS

El protocolo Kerberos **requiere** que el KDC emita un TGS a cualquier usuario autenticado que lo solicite para un SPN válido. El KDC no verifica si el solicitante realmente necesita acceder al servicio — simplemente emite el ticket.

### La debilidad fundamental

Las cuentas de servicio suelen tener contraseñas:
1. **Predecibles** — `Nombre_del_servicio + año + !`
2. **Sin rotación automática** — pueden llevar años sin cambiar
3. **Gestionadas por humanos** — no por MSAS (Managed Service Accounts)

### Diferencia con AS-REP Roasting

| | AS-REP Roasting | Kerberoasting |
|--|-----------------|---------------|
| **Credenciales requeridas** | No (con flag) | Sí (cualquier usuario del dominio) |
| **Target** | Usuarios con `DONT_REQUIRE_PREAUTH` | Cuentas con SPNs |
| **Hash tipo** | `$krb5asrep$23$` | `$krb5tgs$23$` |
| **Detectabilidad** | Menor | Mayor (TGS-REQ por cuenta no habitual) |

### Targeted Kerberoasting (se ejecuta en profundidad en Lab-04 · ACL abuse)

Con **GenericWrite** sobre una cuenta, podemos añadirle un SPN arbitrario y convertirla en objetivo de Kerberoasting bajo demanda. Esto permite atacar cuentas que normalmente no serían Kerberoasteables.

```
GenericWrite → Set servicePrincipalName → TGS-REQ → crack offline
```

### Defensa

- Usar **Managed Service Accounts (MSA)** o **Group Managed Service Accounts (gMSA)** — contraseñas de 240 caracteres rotadas automáticamente
- Contraseñas de +25 caracteres aleatorios en SPNs que no pueden usar gMSA
- Monitorizar Event ID 4769 con Ticket Encryption Type RC4 (0x17)

---

## 5. Pass-the-Hash y Pass-the-Ticket

### Pass-the-Hash (PtH)

Windows almacena las contraseñas como hashes NT en SAM (local) o NTDS.dit (AD). El protocolo NTLM acepta directamente el hash NT para autenticación — **no necesita la contraseña en claro**.

```
hash NT → autenticación NTLM directa → acceso
```

**Por qué funciona:** NTLM es un protocolo challenge-response. El servidor envía un reto, el cliente responde con `HMAC-MD5(hash_NT, reto)`. Con el hash NT se puede calcular esa respuesta sin conocer la contraseña.

**Limitación:** Solo funciona con NTLM. Si el entorno requiere Kerberos exclusivamente, PtH no funciona.

### Pass-the-Ticket (PtT)

Los tickets Kerberos (TGT o TGS) son credenciales de sesión válidas. Si los extraemos de memoria, podemos importarlos en otra sesión y autenticarnos como el usuario propietario.

```
TGT en memoria → extracción → importación → autenticación Kerberos
```

**Por qué funciona:** El KDC no puede distinguir entre el usuario legítimo usando su TGT y un atacante que lo robó. El ticket es la prueba de identidad.

**Ventaja sobre PtH:** Genera eventos Kerberos (menos sospechosos) en lugar de eventos NTLM.

### Overpass-the-Hash (OtH)

Convierte un hash NT en un TGT Kerberos.

```
hash NT → solicitar TGT al KDC (usando el hash como credencial) → TGT → autenticación Kerberos
```

**Por qué funciona:** El AS-REQ puede usar el hash NT directamente como clave de cifrado para la pre-autenticación.

---

## 6. DCSync — Replicación como arma

### Fundamento técnico

Los Domain Controllers replican entre sí los datos de AD usando el protocolo **MS-DRSR (Directory Replication Service Remote Protocol)**. El mecanismo principal es **DRSGetNCChanges** — una función que devuelve todos los cambios desde una fecha dada, incluyendo hashes de contraseñas.

### ¿Por qué puede usarlo un atacante?

DRSGetNCChanges requiere permisos de replicación sobre el objeto dominio:
- `DS-Replication-Get-Changes` (00299570-246d-11d0-a768-00aa006e0529)
- `DS-Replication-Get-Changes-All` (1131f6ad-9c07-11d1-f79f-00c04fc2dcd2)

Por defecto estos permisos solo los tienen los Domain Controllers, Domain Admins y Enterprise Admins. Pero si un atacante consigue estos permisos (via WriteDACL, por ejemplo), puede ejecutar DCSync.

### Diferencia con extraer NTDS.dit

| | DCSync | NTDS.dit |
|--|--------|----------|
| **Método** | Protocolo de replicación | Acceso directo al archivo |
| **Requiere acceso físico al DC** | No | Sí |
| **Detectabilidad** | Event ID 4662 (replicación desde IP no-DC) | Muy ruidoso (Shadow Copy) |
| **Selectividad** | Puede pedir hashes individuales | Todo o nada |

### Por qué krbtgt es el hash más valioso

Con el hash de `krbtgt` se pueden forjar **Golden Tickets** — TGTs válidos para cualquier usuario, con cualquier privilegio, sin contactar el KDC. La única mitigación efectiva es resetear el hash de krbtgt **dos veces** (por la replicación de DCs).

---

## 7. Delegation Abuse — Unconstrained y Constrained

### ¿Por qué existe la delegación Kerberos?

Escenario legítimo: un usuario se autentica en un servidor web (IIS). El servidor web necesita acceder a SQL Server **en nombre del usuario**. Para ello necesita un mecanismo que le permita obtener tickets de servicio actuando como el usuario.

### Unconstrained Delegation

**Cómo funciona:**
Cuando un usuario se autentica contra una cuenta con Unconstrained Delegation, el KDC incluye el TGT del usuario en el TGS que envía. La cuenta de servicio recibe y puede usar ese TGT para suplantar al usuario en **cualquier servicio**.

```
Usuario → [TGS + TGT del usuario] → Cuenta con UC Delegation
                                          ↓
                              Usa el TGT para acceder a cualquier recurso
```

**Por qué es peligroso:**
Si un atacante compromete una cuenta con UC Delegation y fuerza a un Domain Controller a autenticarse (PetitPotam, SpoolSample), obtiene el TGT del DC$ y puede ejecutar DCSync.

**`userAccountControl: 524800`** = `NORMAL_ACCOUNT (0x200)` + `TRUSTED_FOR_DELEGATION (0x80000)`

### Constrained Delegation

**Cómo funciona:**
La delegación solo puede usarse hacia SPNs específicos definidos en `msDS-AllowedToDelegateTo`. Usa el protocolo **S4U** (Service for User):

- **S4U2Self**: La cuenta obtiene un TGS para sí misma en nombre de cualquier usuario (sin necesitar el TGT del usuario)
- **S4U2Proxy**: Usa ese TGS para solicitar un TGS hacia el SPN destino en nombre del usuario

```
iis_svc → S4U2Self: TGS para Administrador @ iis_svc
        → S4U2Proxy: TGS para Administrador @ MSSQLSvc/dc01:1433
```

**`userAccountControl: 16777728`** = `NORMAL_ACCOUNT (0x200)` + `TRUSTED_TO_AUTH_FOR_DELEGATION (0x1000000)`

**Por qué S4U2Self es peligroso:**
Permite impersonar a cualquier usuario, incluyendo Administrador, sin necesitar sus credenciales ni su TGT. Solo necesitas comprometer la cuenta con Constrained Delegation.

### Resource-Based Constrained Delegation (RBCD)

La delegación se configura en el **recurso destino** (no en la cuenta de origen). Si un atacante tiene `GenericWrite` sobre un objeto computer, puede configurarlo para que acepte delegación desde cualquier cuenta que controle. Se cubre en Lab-05.

---

## 8. GPO Abuse — Group Policy como vector

### ¿Qué es una GPO?

Una Group Policy Object es un conjunto de configuraciones que se aplica automáticamente a todos los objetos (equipos y usuarios) en el scope de una OU. Controla desde el fondo de escritorio hasta la instalación de software, scripts de inicio y tareas programadas.

### La estructura en SYSVOL

Cada GPO tiene una representación en SYSVOL:

```
\\dominio\SYSVOL\dominio\Policies\{GUID-GPO}\
    Machine\
        Preferences\
            ScheduledTasks\
                ScheduledTasks.xml   ← aquí van las tareas inmediatas
        Scripts\
    User\
```

Cualquier objeto con `GpoEditDeleteModifySecurity` puede escribir en esta ruta directamente, sin necesitar la consola GPMC.

### Tareas inmediatas (ImmediateTaskV2)

Las tareas en GPO Preferences se ejecutan como `NT AUTHORITY\SYSTEM` cuando la GPO se aplica. Una tarea inmediata se ejecuta una sola vez, la próxima vez que el equipo procesa la política.

```xml
<ImmediateTaskV2 ... runAs="NT AUTHORITY\System" logonType="S4U">
    <Actions>
        <Exec>
            <Command>cmd.exe</Command>
            <Arguments>/c net localgroup Administrators DOMINIO\usuario /add</Arguments>
        </Exec>
    </Actions>
</ImmediateTaskV2>
```

### Por qué es poderoso

El código se ejecuta como SYSTEM en **todos los equipos del scope** de la GPO. Un `gpupdate /force` lo activa inmediatamente. El proceso padre es `svchost.exe` — completamente legítimo.

### Permisos GPO relevantes para atacantes

| Permiso | Qué permite |
|---------|-------------|
| `GpoEditDeleteModifySecurity` | Modificar contenido, borrar, cambiar permisos |
| `GpoEdit` | Solo modificar contenido |
| `GpoApply` | Recibir la GPO (usuarios/equipos normales) |

---

## 9. ACL Abuse — Permisos AD como attack path

### ¿Qué son las ACLs en AD?

Cada objeto en AD tiene una DACL (Discretionary Access Control List) compuesta de ACEs (Access Control Entries). Cada ACE define qué puede hacer un principal (usuario/grupo) sobre ese objeto.

### Los permisos más abusables

| Permiso | GUID | Qué permite | Ataque |
|---------|------|-------------|--------|
| `GenericAll` | — | Control total sobre el objeto | Cambiar contraseña, añadir SPNs, etc. |
| `GenericWrite` | — | Modificar atributos no protegidos | Targeted Kerberoasting, Shadow Credentials |
| `WriteProperty` | — | Modificar atributos específicos | Depende del atributo |
| `WriteDACL` | — | Modificar la DACL del objeto | Añadirse permisos de DCSync |
| `WriteOwner` | — | Cambiar el propietario del objeto | Tomar control total |
| `ForceChangePassword` | ab721a53-... | Cambiar contraseña sin conocer la actual | Comprometer la cuenta directamente |
| `AllExtendedRights` | — | Todos los derechos extendidos | DCSync, ForceChangePassword |
| `DS-Replication-Get-Changes-All` | 1131f6ad-... | Replicar hashes de contraseñas | DCSync |

### ¿Por qué existen permisos tan peligrosos?

AD fue diseñado para ser flexible en la delegación de administración. Un admin de RRHH puede tener permisos para resetear contraseñas de usuarios de su OU. Un sistema de backup puede necesitar permisos de lectura extendida. Estos permisos se acumulan con el tiempo y raramente se auditan.

### GenericWrite sobre una cuenta de usuario — Por qué permite Kerberoasting

`GenericWrite` incluye el derecho a escribir en `servicePrincipalName`. Añadir un SPN a una cuenta hace que el KDC emita TGS para esa cuenta, cifrados con su hash NT. Esos TGS son crackeables offline.

### WriteDACL — La escalada más peligrosa

Con `WriteDACL` sobre el objeto dominio se pueden añadir los permisos:
- `DS-Replication-Get-Changes`
- `DS-Replication-Get-Changes-All`

Con esos permisos → DCSync → todos los hashes del dominio → DA.

### Cómo enumerar ACLs

```bash
# Desde Kali
impacket-dacledit atackcorp.local/usuario:password -action read -target objetivo -dc-ip IP

# Desde Windows (PowerView)
Get-ObjectAcl -SamAccountName "sql_svc" -ResolveGUIDs | Where-Object {$_.ActiveDirectoryRights -match "Write"}
```

---

## 10. BloodHound — Teoría del grafo aplicada a AD

### ¿Por qué un grafo?

AD es fundamentalmente una red de relaciones entre objetos. `fin.garcia` tiene `GenericWrite` sobre `sql_svc`, que tiene `TrustedForDelegation`, que permite capturar TGTs del DC, que permiten DCSync. Esta cadena es un **grafo dirigido** — exactamente lo que BloodHound modela.

### Componentes

**Neo4j** — Base de datos de grafos que almacena nodos (usuarios, grupos, equipos) y aristas (relaciones: MemberOf, GenericWrite, HasSession, etc.)

**SharpHound/bloodhound-python** — Collectors que recopilan datos del dominio vía LDAP y los convierten a JSON para importar en Neo4j.

**BloodHound UI** — Interfaz que permite visualizar el grafo y ejecutar queries predefinidas.

### Las queries más importantes

| Query | Qué encuentra |
|-------|---------------|
| Shortest Paths to DA | El camino más corto desde cualquier nodo hasta DA |
| Find All DA Principals | Quién es DA directamente o por herencia |
| Find Principals with DCSync Rights | Quién puede ejecutar DCSync |
| Shortest Paths from Kerberoastable Users | Qué puedes hacer si crackeas un hash TGS |
| Find AS-REP Roastable Users | Cuentas sin pre-autenticación |

### Cypher — El lenguaje de consulta

```cypher
// Caminos desde fin.garcia hasta DA
MATCH p=shortestPath(
  (u:User {name:"FIN.GARCIA@ATACKCORP.LOCAL"})-[*1..10]->
  (g:Group {name:"ADMINS. DEL DOMINIO@ATACKCORP.LOCAL"})
)
RETURN p
```

### bloodhound-python vs SharpHound

| | bloodhound-python | SharpHound |
|--|-------------------|------------|
| Ejecución | Desde Kali (LDAP remoto) | En el objetivo (Windows) |
| ACLs de GPOs | ❌ No recolecta | ✅ Completo |
| Paths ADCS | ❌ No | ✅ Sí |
| OPSEC | ✅ Alto (solo tráfico LDAP) | ⚠️ Medio (binario en disco) |

---

## 11. Golden Ticket — Por qué falla en entornos modernos

### Fundamento

El TGT está cifrado con el hash de `krbtgt`. Si conocemos ese hash, podemos **forjar** un TGT para cualquier usuario, con cualquier grupo, con cualquier SID, sin contactar el KDC.

```
krbtgt hash + usuario + grupos → TGT forjado → acceso como DA
```

### Por qué falló en este lab

Windows Server 2016+ implementa **PAC Validation** — el servicio de destino contacta al KDC para verificar el PAC del ticket antes de conceder acceso. Si el ticket fue forjado offline, el KDC detecta inconsistencias.

**Específicamente:** El KDC verifica que el `LogonTime` y otros campos del PAC sean consistentes con lo que él emitió. Un ticket forjado con campos incorrectos falla la validación.

### Mitigaciones modernas

- **PAC Validation** (Windows Server 2016+) — verifica tickets con el KDC
- **Protected Users Security Group** — deshabilita RC4, requiere AES256
- **KRBTGT AES keys** — hace el cracking del hash mucho más difícil
- **Credential Guard** — protege los hashes en memoria con Hyper-V

### Alternativas al Golden Ticket

| Técnica | Requisito | Detectabilidad |
|---------|-----------|----------------|
| Diamond Ticket | krbtgt hash | Baja (modifica PAC existente) |
| Sapphire Ticket | krbtgt hash | Muy baja (copia PAC real) |
| Certificado DA (ADCS) | CA comprometida | Baja |
| Shadow Credentials | GenericWrite | Baja |

---

## 12. OPSEC — Principios para operar en AD

### Regla 1: Kali antes que Windows

Siempre priorizar operaciones desde Kali sobre ejecutar binarios en el objetivo. `bloodhound-python` desde Kali genera solo tráfico LDAP legítimo. `SharpHound.exe` en el DC genera eventos de proceso y puede ser detectado por AV/EDR.

### Regla 2: LOLBins antes que herramientas externas

Antes de subir Mimikatz, intentar con `reg save HKLM\SAM`. Antes de subir PowerView, intentar con `net user /domain` y `nltest`.

### Regla 3: Entender qué logs genera cada comando

| Acción | Event ID | Log |
|--------|----------|-----|
| Autenticación correcta | 4624 | Security |
| Autenticación fallida | 4625 | Security |
| TGT emitido | 4768 | Security (DC) |
| TGS emitido | 4769 | Security (DC) |
| DCSync (DRSGetNCChanges) | 4662 | Security (DC) |
| Nuevo proceso | 4688 / Sysmon 1 | Security / Sysmon |
| Acceso a objeto AD | 4662 | Security (DC) |
| Cambio en DACL | 4670 | Security |
| Miembro añadido a grupo | 4728/4732 | Security |
| GPO modificada | 5136 | Security |

### Regla 4: Limpiar artefactos

- Eliminar binarios subidos al objetivo
- Eliminar SPNs añadidos para Targeted Kerberoasting
- Eliminar tareas GPO añadidas
- Eliminar archivos en SYSVOL
- Limpiar historial de PowerShell (`Clear-History`, `Remove-Item (Get-PSReadlineOption).HistorySavePath`)

### Regla 5: Timing

- Operar durante horario de negocio si el objetivo tiene alertas fuera de horario
- Operar fuera de horario si el objetivo tiene más monitorización durante el día
- Espaciar solicitudes de tickets para evitar patrones anómalos

---

## Referencias

- [MS-KILE: Kerberos Protocol Extensions](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-kile)
- [MS-DRSR: Directory Replication Service Remote Protocol](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-drsr)
- [MITRE ATT&CK — APT29](https://attack.mitre.org/groups/G0016/)
- [SpecterOps BloodHound Documentation](https://bloodhound.readthedocs.io/)
- [Harmj0y — The Most Important BloodHound Update Ever](https://blog.harmj0y.net/)
- [Sean Metcalf — Kerberos & Attacks 101](https://adsecurity.org/)

---

*Operación GHOST FOREST — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*