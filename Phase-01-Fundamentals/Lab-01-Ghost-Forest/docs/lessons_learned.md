# Lessons Learned — Operación GHOST FOREST
## Lab-01: Ghost Forest
**Operación:** GHOST FOREST | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Fecha:** 13/05/2026 | **Operador:** Adrián Camacho

---

## Introducción

Este documento recoge las lecciones técnicas, operacionales y de infraestructura aprendidas durante la ejecución completa de la Operación GHOST FOREST. Incluye problemas encontrados, sus causas raíz, soluciones aplicadas y recomendaciones para labs futuros.

---

## 1. Infraestructura y Entorno

### L-01 — Kali necesita IP estática permanente en la red del lab

**Problema:** Kali perdía conectividad con las VMs del lab tras reinicios o cambios de configuración de red. La IP DHCP cambiaba o el adaptador eth0 no tenía ruta configurada.

**Causa:** Kali usa NetworkManager por defecto. Las IPs asignadas manualmente con `ip addr add` no persisten entre sesiones. Intentar usar `/etc/network/interfaces` en Kali con NetworkManager activo genera conflictos.

**Solución:**
```bash
sudo nmcli con add type ethernet con-name "LabRedTeam" ifname eth0 \
  ipv4.method manual \
  ipv4.addresses 10.0.2.9/24 \
  ipv4.gateway 10.0.2.1 \
  ipv4.dns 10.0.2.10 \
  connection.autoconnect yes
sudo nmcli con up LabRedTeam
```

**Lección para labs futuros:** Configurar IP estática via NetworkManager como primer paso antes de cualquier lab. El DNS apuntando al DC es crítico para que Kerberos funcione correctamente.

---

### L-02 — Windows Server en español rompe scripts que usan nombres de grupos en inglés

**Problema:** Scripts PowerShell y comandos Impacket que usaban `"Domain Admins"` fallaban con `ObjectNotFoundException` porque el dominio está en español.

**Causa:** Windows Server instalado en español traduce los nombres de grupos built-in. `Domain Admins` → `Admins. del dominio`, `Backup Operators` → `Operadores de copia de seguridad`.

**Solución:** Usar SIDs universales en lugar de nombres:
```powershell
# En lugar de "Domain Admins" usar SID-512
$daGroup = Get-ADGroup -Filter {SID -eq "S-1-5-21-XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXXX-512"}
Add-ADGroupMember -Identity $daGroup -Members "backup_svc"
```

**Lección para labs futuros:** Siempre usar SIDs para grupos built-in en scripts. Los SIDs relativos son universales: -512 (DA), -519 (EA), -518 (Schema Admins), -544 (Administrators), -551 (Backup Operators).

---

### L-03 — El nombre del usuario Administrador también está en español

**Problema:** `impacket-secretsdump -just-dc-user Administrator` fallaba con `ERROR_DS_NAME_ERROR_NOT_FOUND`.

**Causa:** En Windows instalado en español, el Administrador built-in se llama `Administrador`, no `Administrator`.

**Solución:** Usar el nombre localizado o el RID directamente:
```bash
impacket-secretsdump atackcorp.local/backup_svc:'Backup2024!'@10.0.2.10 \
  -just-dc-user Administrador -just-dc-ntlm -dc-ip 10.0.2.10
```

**Lección para labs futuros:** En entornos en español verificar siempre el nombre real de las cuentas built-in antes de ejecutar herramientas.

---

### L-04 — sessionresume de Evil-WinRM ensucian el directorio de trabajo

**Problema:** Evil-WinRM genera archivos `sessionresume_XXXXXXXX` en el directorio desde donde se ejecuta, ensuciando el repo.

**Solución:**
```bash
rm ~/Red-Team-Labs/Phase-01-Fundamentals/Lab-01-Attacktive-Directory/sessionresume_*
```

**Lección para labs futuros:** Añadir `sessionresume_*` al `.gitignore` del repo antes de empezar cada lab.

---

## 2. Técnicas Ofensivas

### L-05 — AS-REP Roasting: rockyou.txt no crackea contraseñas corporativas

**Problema:** John the Ripper con rockyou.txt no crackeó los hashes AS-REP de `ceo.martinez` ni `backup_svc`.

**Causa:** Las contraseñas seguían el patrón corporativo `Palabra+Año+Símbolo` (`Direccion2024!`, `Backup2024!`) — patrón predecible pero no incluido en diccionarios genéricos.

**Solución:** Crear un diccionario dirigido basado en OSINT de la empresa:
```bash
cat > loot/targeted_wordlist.txt << 'EOF'
Direccion2024!
Backup2024!
Atackcorp2024!
Admin2024!
Password2024!
Welcome2024!
EOF
john --format=krb5asrep --wordlist=loot/targeted_wordlist.txt loot/asrep_hashes.txt
```

**Lección para labs futuros:** Antes de lanzar rockyou.txt, construir siempre un diccionario dirigido con patrones corporativos (nombre empresa, año, símbolos comunes). En entornos reales el OSINT previo define el éxito del cracking.

---

### L-06 — DCSync bloqueado por token de sesión cacheado

**Problema:** `impacket-secretsdump` fallaba con `ERROR_DS_DRA_ACCESS_DENIED` para `ceo.martinez` aunque los permisos DCSync estaban correctamente asignados en la ACL.

**Causa:** Los permisos de replicación se asignaron mientras `ceo.martinez` ya tenía una sesión activa. El token de seguridad de Kerberos se genera en el momento del logon y no se actualiza hasta que el usuario inicia una nueva sesión. El DC evaluaba el token antiguo (sin permisos de replicación) en lugar de los ACEs actuales.

**Solución:** Pivotar al PATH B (Kerberoasting) en lugar de esperar a que el token expire. En un entorno real APT29 esperaría al siguiente logon del usuario.

**Lección para labs futuros:** Los permisos AD se aplican en el siguiente logon, no inmediatamente. Si se asignan permisos a una cuenta con sesión activa, hay que forzar un nuevo logon o reiniciar el servicio NTDS para que surtan efecto completo.

---

### L-07 — Kerberoasting: SPN mal registrado por bug de interpolación en PowerShell

**Problema:** El SPN de `backup_svc` quedó registrado como `MSSQLSvc/` (sin hostname) en lugar de `MSSQLSvc/DC-01.atackcorp.local:1433`.

**Causa:** En bloques `try/catch` de PowerShell, las variables definidas fuera del bloque a veces no se expanden correctamente cuando se usan en strings dentro del bloque.

**Solución:** Hardcodear el valor como literal dentro del bloque try:
```powershell
# MAL — variable puede no expandirse en try/catch
$spn = "MSSQLSvc/$DCHostname:1433"

# BIEN — literal hardcodeado
$spn = "MSSQLSvc/DC-01.atackcorp.local:1433"
```

**Lección para labs futuros:** En scripts de setup de lab, verificar siempre el SPN registrado antes de continuar:
```powershell
(Get-ADUser backup_svc -Properties ServicePrincipalName).ServicePrincipalName
```

---

### L-08 — Golden Ticket rechazado por PAC Validation en Windows Server 2022

**Problema:** El Golden Ticket forjado con `impacket-ticketer` fue rechazado con `KDC_ERR_TGT_REVOKED` tanto con NT hash como con AES256.

**Causa:** Windows Server 2022 implementa **PAC Validation** reforzada. El DC verifica la firma del PAC contra su propia base de datos antes de aceptar el ticket, detectando que fue forjado externamente.

**Solución alternativa:** Usar Pass-the-Hash directamente con el hash de Administrador obtenido via DCSync — igualmente efectivo para los objetivos de la operación.

**Lección para labs futuros:** En Windows Server 2022+ los Golden Tickets clásicos pueden fallar. Alternativas más modernas:
- **Diamond Ticket** — modifica un TGT legítimo en lugar de forjar uno nuevo
- **Sapphire Ticket** — copia el PAC de un ticket legítimo
- Para persistencia práctica en labs modernos: Pass-the-Hash o Silver Tickets

---

### L-09 — SweetPotato falla desde sesiones WinRM en Windows 11

**Problema:** Todos los métodos de SweetPotato (PrintSpoofer, DCOM, WinRM) fallaron con `No authenticated interception took place`.

**Causa:** WinRM genera **Network Logon tokens** (Logon Type 3) en lugar de Interactive tokens (Logon Type 2). Los Potato attacks requieren Named Pipe Impersonation que solo funciona con tokens interactivos o de servicio local — no de red.

**Solución:** En entornos reales APT29 ejecutaría el beacon desde un proceso de servicio (no WinRM) o usaría un método alternativo como explotar un servicio vulnerable del sistema.

**Lección para labs futuros:** Para escalada a SYSTEM en Windows 11 via WinRM explorar:
- Ejecutar el beacon como servicio (no proceso interactivo)
- Usar `CreateService` para lanzar el exploit como servicio local
- Explotar vulnerabilidades de servicios (Unquoted Service Path, DLL Hijacking)

---

### L-10 — AMSI bloquea scripts conocidos incluso con exclusiones de carpeta

**Problema:** `Invoke-SweetPotato.ps1` fue bloqueado por AMSI (`ScriptContainedMaliciousContent`) incluso después de añadir la carpeta a las exclusiones de Defender.

**Causa:** AMSI escanea el contenido del script **en memoria** antes de ejecutarlo, independientemente de las exclusiones de carpeta en disco. Las exclusiones solo afectan al escaneo de archivos en disco, no al escaneo en tiempo de ejecución.

**Solución aplicada:** Deshabilitar Tamper Protection desde GUI + `Set-MpPreference -DisableScriptScanning $true`.

**Solución real (APT29):** Ofuscar el script o compilar un binario firmado que no tenga firma conocida en la base de datos de Defender. En entornos reales se usarían loaders custom con técnicas de evasión (donut, srdi, reflective loading).

**Lección para labs futuros:** AMSI y las exclusiones de carpeta son capas independientes. Para evadir AMSI en labs:
- `Set-MpPreference -DisableScriptScanning $true` (requiere admin + Tamper Protection off)
- Ofuscación de strings en el script
- Compilar herramientas como .exe en lugar de usar scripts .ps1

---

## 3. Operacional y Documentación

### L-11 — Importancia del diccionario dirigido vs genérico

**Observación:** El uso de rockyou.txt falló en dos ocasiones (AS-REP Roasting y Kerberoasting). En ambos casos el diccionario dirigido de 10 entradas crackeó los hashes en menos de 1 segundo.

**Lección:** En entornos corporativos reales, el OSINT previo (nombre de empresa, año, términos del sector) permite construir diccionarios de 50-100 entradas que superan ampliamente a diccionarios genéricos de millones de palabras. La calidad supera a la cantidad.

---

### L-12 — Documentar decisiones tácticas fallidas es tan importante como los éxitos

**Observación:** Las técnicas que no funcionaron (DCSync por token cacheado, Golden Ticket revocado, SweetPotato en WinRM) generaron documentación técnica más valiosa que muchas de las que sí funcionaron.

**Lección:** Un writeup de red team honesto documenta tanto los fallos como los éxitos, con análisis técnico de la causa raíz. Esto es lo que diferencia la documentación de calidad de un simple log de comandos.

---

### L-13 — Capturas organizadas por fase desde el inicio

**Observación:** Las capturas de Fase 1-3 no seguían la nomenclatura `faseX-XX-descripcion.png`. Hubo que renombrarlas posteriormente.

**Lección para labs futuros:** Definir la nomenclatura de capturas antes de empezar el lab y seguirla desde la primera captura:
```
faseX-NN-descripcion-corta.png
```

---

## 4. Resumen de Lecciones por Categoría

### Infraestructura
| ID | Lección | Impacto |
|----|---------|---------|
| L-01 | IP estática via NetworkManager, no `ip addr add` | Alto |
| L-02 | Usar SIDs para grupos built-in en entornos en español | Alto |
| L-03 | Verificar nombre localizado de cuentas built-in | Medio |
| L-04 | Añadir `sessionresume_*` al `.gitignore` | Bajo |

### Técnicas Ofensivas
| ID | Lección | Impacto |
|----|---------|---------|
| L-05 | Diccionario dirigido > rockyou.txt en entornos corporativos | Alto |
| L-06 | Permisos AD aplican en el siguiente logon | Alto |
| L-07 | Verificar SPNs registrados tras el setup | Medio |
| L-08 | Golden Ticket clásico falla en Windows Server 2022 | Alto |
| L-09 | Potato attacks requieren token interactivo, no de red | Alto |
| L-10 | AMSI es independiente de las exclusiones de carpeta | Alto |

### Operacional
| ID | Lección | Impacto |
|----|---------|---------|
| L-11 | OSINT define el éxito del cracking offline | Alto |
| L-12 | Documentar fallos con análisis técnico es valioso | Alto |
| L-13 | Definir nomenclatura de capturas antes de empezar | Medio |
---

## 5. Fases 11-13 — Delegation, GPO Abuse y ACL Abuse

### L-14 — Rubeus ptt falla en sesiones WinRM (Network Logon)

**Problema:** `Rubeus.exe ptt /ticket:...` devolvía `Error 1312 — La sesión de inicio especificada no existe`.

**Causa:** WinRM genera **Network Logon tokens** (Logon Type 3). Rubeus `ptt` requiere manipular la caché de tickets Kerberos de la sesión, operación que solo funciona con tokens interactivos (Logon Type 2) o de servicio. Los Network Logon tokens no tienen una sesión Kerberos asociada modificable.

**Solución:** Usar el TGT capturado directamente desde Kali con impacket, convirtiendo el base64 a formato ccache:

```python
import base64
ticket = open('/tmp/dc01.ticket').read().strip()
with open('/tmp/dc01.ccache', 'wb') as f:
    f.write(base64.b64decode(ticket))
```

**Lección:** Las limitaciones de WinRM afectan a múltiples técnicas (Potato attacks en Fase 8, ptt en Fase 11). Para operaciones que requieren manipulación de tokens Kerberos, usar sesiones RDP o consola directa, o trabajar desde Kali con impacket.

---

### L-15 — SharpHound corrupto en el arsenal — siempre verificar el tamaño del binario

**Problema:** `SharpHound.exe` en `/opt/redteam/windows/` tenía solo 12 bytes y fallaba con `not a valid application for this OS platform`.

**Causa:** El archivo placeholder en el arsenal nunca fue reemplazado por el binario real. Al hacer upload con Evil-WinRM se subió el placeholder vacío.

**Solución:** Verificar siempre el tamaño del binario antes de subir:

```bash
ls -la /opt/redteam/windows/SharpHound.exe
# Correcto: ~1.5MB | Corrupto: < 100 bytes
```

Descargar SharpHound real directamente:

```bash
curl -sL "https://github.com/BloodHoundAD/SharpHound/releases/download/v2.5.9/SharpHound-v2.5.9.zip" \
  -o /tmp/SharpHound.zip
unzip -q /tmp/SharpHound.zip -d /tmp/SharpHound
```

**Lección:** El arsenal debe contener binarios reales verificados. Añadir verificación de tamaño al script de setup. Actualizar `arsenal_setup.sh` con descarga directa de SharpHound desde GitHub.

---

### L-16 — bloodhound-python LEGACY no recolecta ACLs de GPOs ni paths ADCS

**Problema:** BloodHound mostraba "Path not found" para helpdesk.ruiz y ceo.martinez al usar datos de bloodhound-python. Con datos de SharpHound aparecían múltiples paths.

**Causa:** bloodhound-python está diseñado para BloodHound 4.x (LEGACY). No recolecta:
- ACLs sobre objetos GPO
- Permisos extendidos DCSync via ACEs
- Paths ADCS (ESC1, ESC3, etc.)
- Algunos flags de delegación en conjuntos específicos

**Solución:** Usar SharpHound para coverage completo. Usar bloodhound-python cuando el OPSEC sea prioritario (sin binarios en el objetivo).

**Lección:** Siempre complementar bloodhound-python con SharpHound en una segunda pasada cuando se tenga acceso privilegiado. bloodhound-python es ideal para la recolección inicial silenciosa, SharpHound para el análisis profundo.

---

### L-17 — Las tareas inmediatas de GPO requieren fecha de trigger futura

**Problema:** La tarea `ImmediateTaskV2` con `StartBoundary` en fecha pasada no se ejecutó al aplicar la GPO con `gpupdate /force`.

**Causa:** Windows evalúa el trigger antes de ejecutar la tarea. Si la fecha de inicio ya pasó y no hay `StartWhenAvailable`, la tarea no se ejecuta.

**Solución:**

```xml
<TimeTrigger>
  <StartBoundary>FECHA-FUTURA</StartBoundary>
  <EndBoundary>FECHA-FUTURA+1DIA</EndBoundary>
  <Enabled>true</Enabled>
</TimeTrigger>
<Settings>
  <StartWhenAvailable>true</StartWhenAvailable>
  <DeleteExpiredTaskAfter>PT0S</DeleteExpiredTaskAfter>
</Settings>
```

**Lección para labs futuros:** Cuando se configure GPO Abuse con tareas inmediatas, usar siempre una fecha de StartBoundary en el futuro inmediato y activar `StartWhenAvailable`. Alternativamente, ejecutar el payload directamente via Evil-WinRM si ya se tiene acceso.

---

### L-18 — bloodyAD como alternativa OPSEC a impacket-addspn

**Observación:** `impacket-addspn` no estaba disponible en la instalación actual de impacket. `bloodyAD` proporciona la misma funcionalidad desde Kali sin necesidad de binarios adicionales.

**Solución:**

```bash
# Añadir SPN via bloodyAD (OPSEC — solo tráfico LDAP desde Kali)
bloodyAD -u fin.garcia -p 'Finance2024!' -d atackcorp.local \
  --host 10.0.2.10 \
  set object sql_svc servicePrincipalName -v "fake/dc01.atackcorp.local"
```

**Lección:** Conocer múltiples herramientas para cada técnica. Si una no está disponible, otra puede hacer lo mismo. El arsenal no debe depender de una sola herramienta por técnica.

---

### L-19 — Kali necesita Adaptador 3 NAT para Internet permanente en el lab

**Problema:** Kali perdía acceso a Internet al reiniciar porque la default route apuntaba a eth0 (red del lab) en lugar de eth2 (NAT Internet).

**Solución permanente via NetworkManager:**

```bash
# eth0 — red del lab, nunca default gateway
sudo nmcli con modify "LabRedTeam" ipv4.never-default yes
sudo nmcli con modify "LabRedTeam" +ipv4.routes "10.0.3.0/24 10.0.2.1"

# eth2 — NAT Internet, default gateway con métrica baja
sudo nmcli con modify "Wired connection 1" ipv4.route-metric 50
```

**Lección:** Configurar las rutas via NetworkManager (permanentes) en lugar de `ip route` (temporales). La métrica determina qué ruta se usa como default: la de menor métrica gana.

---

## 6. Actualización del Resumen de Lecciones

### Infraestructura (actualizado)

| ID | Lección | Impacto |
|----|---------|---------|
| L-01 | IP estática via NetworkManager, no `ip addr add` | Alto |
| L-02 | Usar SIDs para grupos built-in en entornos en español | Alto |
| L-03 | Verificar nombre localizado de cuentas built-in | Medio |
| L-04 | Añadir `sessionresume_*` al `.gitignore` | Bajo |
| L-15 | Verificar tamaño de binarios antes de subir | Alto |
| L-19 | Kali NAT Internet via Adaptador 3 + NetworkManager | Alto |

### Técnicas Ofensivas (actualizado)

| ID | Lección | Impacto |
|----|---------|---------|
| L-05 | Diccionario dirigido > rockyou.txt en entornos corporativos | Alto |
| L-06 | Permisos AD aplican en el siguiente logon | Alto |
| L-07 | Verificar SPNs registrados tras el setup | Medio |
| L-08 | Golden Ticket clásico falla en Windows Server 2022 | Alto |
| L-09 | Potato attacks requieren token interactivo, no de red | Alto |
| L-10 | AMSI es independiente de las exclusiones de carpeta | Alto |
| L-14 | Rubeus ptt falla en sesiones WinRM (Network Logon) | Alto |
| L-17 | GPO ImmediateTask requiere fecha futura en trigger | Medio |
| L-18 | bloodyAD como alternativa a impacket-addspn | Medio |

### BloodHound y Metodología

| ID | Lección | Impacto |
|----|---------|---------|
| L-16 | bloodhound-python LEGACY no recolecta ACLs de GPOs | Alto |

### Operacional (actualizado)

| ID | Lección | Impacto |
|----|---------|---------|
| L-11 | OSINT define el éxito del cracking offline | Alto |
| L-12 | Documentar fallos con análisis técnico es valioso | Alto |
| L-13 | Definir nomenclatura de capturas antes de empezar | Medio |