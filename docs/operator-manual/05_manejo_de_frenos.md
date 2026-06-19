# Manual del Operador — Manejo de Frenos: Cuándo Todo Falla

> **Realidad:** 40-50% de engagements hitean frenos no previstos.  
> **Habilidad crítica:** Cómo proceder cuando plan A, B, C fallan todos.

---

## Introducción: Aceptar la realidad

**Hecho:** No todo sale como planeado.

**Realidad operacional:**
- 30-40% de técnicas no funcionan (defensa mejor de lo esperado)
- Phishing no siempre funciona (usuario no abre)
- RCE no existe (app está parcheada)
- Credenciales no se encuentran (buscadas duro)
- Red está segmentada (no puedes moverse)
- Timeline se agota (objetivo no alcanzado)

**Profesionalismo:** Cómo manejas freno = diferencia entre operador competente y amateur frustrado.

**Mentalidad correcta:**
- ✅ Documenta hallazgo de freno
- ✅ Repiensa estrategia
- ✅ Comunica con cliente
- ✅ Proporciona alternativas
- ❌ NO paniquees, NO abandones

---

## Freno 1: "La defensa es impenetrable"

### Síntomas

```
Indicadores de defensa fuerte:
- Phishing no funciona (usuario no abre en 5+ días)
- Web RCE no existe (app completamente parcheada)
- Credenciales fuerza bruta fallan repetidamente
- Firewall bloquea TODOS los intentos
- EDR mata procesos instantáneamente
- WAF bloquea payload obvio
```

### Decisiones operacionales

**Opción A: Espera y reintenta (2-3 semanas)**

```
Razón: Empresas cambian staff, nuevas apps, configuraciones
Táctica: 
  - Pausa operativa (documentado en logs)
  - Monitorea cambios (nuevas IPs, certificados, apps)
  - Reintenta con nuevo vector
  
Cuándo aplicar:
  - Timeline permite espera
  - Hay indicios de cambio próximo
  - Cliente autoriza pausa
  
Cuándo NO aplicar:
  - Timeline apretado (< 3 días)
  - Defensa parece permanentemente fuerte
```

**Opción B: Pivota a insider/supply chain**

```
Lógica: Si defensa técnica es fuerte → defensa humana es débil

Táctica:
  1. Redirecciona esfuerzo a HUMINT
  2. Busca insider disconforme (LinkedIn, búsqueda investigativa)
  3. Contacto indirecto (perfil falso, intermediario)
  4. Relationship building
  5. Dinero/información como incentivo
  
Cuándo aplicar:
  - Defensa técnica definitivamente fuerte
  - Timeline permite (2-3 semanas)
  - Insider risk es identificable (ex-empleados, bajo salario)
  
Timeline: 15-25 días desde identification a compromiso
```

**Opción C: Admite fracaso técnico con recomendaciones**

```
Lógica: Defensa es tan fuerte que técnico no es viable

Táctica:
  1. Documentar TODO lo intentado
  2. Documentar POR QUÉ falló cada técnica
  3. Proporcionar recomendaciones de mejora defensa
  4. Valor para cliente: "Eres excepcionalmente defensible"
  
Ejemplo de reporte:
  "Después de 10 días, intentamos 5 vectores distintos.
   Todos fueron bloqueados por defensa sofisticada (EDR, WAF, MFA).
   
   Conclusión: Defensa técnica es muy fuerte.
   Recomendación: Mantener vigilancia en insider risk (punto débil)."
  
Cuándo aplicar:
  - Defensa excepcionalmente fuerte
  - Timeline muy corto
  - Objetivo no parece viable técnicamente
  
Valor: Cliente aprecia transparencia
```

---

## Freno 2: "Me detectaron demasiado pronto"

### Síntomas

```
- EDR alertó, proceso killed
- Blue team contactó cliente
- IDS/WAF bloqueó constantemente
- Máquina aislada de red
- Acceso bloqueado (pwd reset, account locked)
```

### Decisiones operacionales por tipo de detección

**Detección leve (IDS/WAF alert, sin isolation)**

```
Acción:
  1. Diagnostica qué los alertó
  2. Cambia técnica (payload obfuscation, evasión)
  3. Aumenta sleep entre comandos
  4. Continúa sigiloso
  5. Si objetivo aún alcanzable: procede
  
Timing: Puedes tener 24-48h antes de escalada
```

**Detección moderada (Process killed, account suspended)**

```
Acción:
  1. Evalúa: ¿Completé objetivo?
     - SÍ: EXFILTRACIÓN INMEDIATA + EXIT
     - NO: ¿Puedo continuar en máquina diferente?
        - SÍ: Pivota
        - NO: Prepara exfiltración de datos parciales
  
  2. Limpieza rápida
     - Event logs (especiales los últimos 24h)
     - Beacon artifacts
     - Comandos ejecutados
  
  3. SALIDA LIMPIA
     - Credenciales borradas
     - Procesos finalizados
     - Conexiones cerradas
```

**Detección severa (Full isolation, account revoked)**

```
Situación: Estás completamente bloqueado, defensa está alerta

Acción:
  1. SI tienes persistencia:
     - Pausa 24-48h
     - Espera a que SOC se calme
     - Reintenta desde persistencia
  
  2. SI NO tienes persistencia:
     - ABORT operación
     - Documenta lo que pasó
     - Análisis: qué salió mal, por qué detectaron
     - REPORTE LECCIONES APRENDIDAS
```

---

## Freno 3: "No encuentro credenciales útiles"

### Síntomas

```
- LSASS dump vacío (usuarios ya logged off)
- DPAPI keys no disponibles
- Registry sin credenciales guardadas
- Archivos típicos (.bash_history, web.config) ausentes
- Browser no tiene cookies guardadas
- Credential spray no funciona
```

### Decisiones operacionales

**Opción A: Espera a usuario loguearse**

```
Táctica:
  1. Establece C2 persistente
  2. Configura job/scheduled task
  3. Espera a que usuario objetivo loguee
  4. Captura credenciales en memoria
  
Duración: Puede ser horas, días, o semanas

Cuándo aplicar:
  - Usuario específico es target (admin, DBA)
  - Tienes persistencia establecida
  - Timeline permite espera
  
Herramientas:
  - Secretsdump (continuo)
  - Logonui hook
  - LSASS monitoring
```

**Opción B: Hunting más profundo**

```
Lugares no obvios:
  - Archivos de configuración (.env, .config, XML)
  - Backups no borrados (en shares, cloud)
  - Caches de aplicaciones (Slack, Discord, browsers)
  - Email (si tienes acceso Outlook)
  - Notas (OneNote, Sticky Notes)
  - OneDrive/Dropbox (documentos personales)
  - VSCode/IDE (configuración con credentials)
  
Búsqueda específica:
  
  $ find / -name "*.env" -o -name "web.config" 2>/dev/null
  $ grep -r "password" /etc /opt /home 2>/dev/null
  $ cat ~/.bash_history | grep -i "pass\|key\|secret"
  $ strings /proc/*/environ | grep -i "token\|key\|api"
```

**Opción C: Ataque sin credenciales (AD abuse)**

```
Técnicas que NO requieren credenciales:
  - Kerberoasting (SPN enumeration)
  - AS-REP roasting (users sin preauth)
  - BloodHound ACL abuse (sin credenciales)
  - Coercion attacks (NTLM relay)
  - Golden Ticket (si dumpeaste krbtgt hash)
  
Ejemplo:
  1. Enumera SPNs: $ GetUserSPNs.ps1
  2. Kerberoast: $ Rubeus.exe kerberoast
  3. Crack hashes offline (John, Hashcat)
  4. Use nuevas credenciales
```

**Opción D: Pivota objetivo**

```
¿Objetivo original requiere credenciales?
  - SÍ, y no las encuentro → Objetivo DIFERENTE
  
Alternativas:
  - Si objetivo es "BBDD", pero tienes SMTP → exfil vía email
  - Si objetivo es "file share", pero tienes RDP → browse shares
  - Completa objetivo "parcial" que es viable
```

---

## Freno 4: "Red está segmentada, no puedo moverse"

### Síntomas

```
- Lateral movement bloqueado (firewall interno)
- DMZ no puede hablar a intranet
- Máquina aislada (sin salida a Internet)
- Routers/switches no son alcanzables
- Puertos bloqueados entre segmentos
```

### Decisiones operacionales

**Opción A: Usa máquina comprometida como proxy**

```
Técnica: SOCKS proxy a través de máquina comprometida

Pasos:
  1. Establece proxy en máquina actual
     $ socks 5127 (Sliver)
  
  2. Proxifica tráfico desde Kali
     $ proxychains -f /etc/proxychains.conf [comando]
     $ chisel client BEACON:9001 R:5127:127.0.0.1:5127
  
  3. Ahora Kali puede alcanzar máquinas "internas"
     $ proxychains nmap -sT -p 445 192.168.1.0/24
     $ proxychains impacket-smbclient //192.168.1.10/C$ -U user%pass
  
Ventaja: Acceso a redes "unreachable" desde Kali
```

**Opción B: Busca "puentes" entre segmentos**

```
¿Hay aplicaciones que crosean segmentación?

Ejemplos:
  - Web app en DMZ que accede BD en intranet
  - Exchange que conecta a intranet
  - VPN que es gateway
  - Backup server que toca todas las redes
  - Monitoring system que escanea todo
  
Táctica:
  1. Enumera aplicaciones en máquina actual
  2. Identifica una que crosea fronteras
  3. Usa esa como pivot
  
Ejemplo:
  - Estás en web server (DMZ)
  - Web app conecta a SQL Server (intranet)
  - Usa SQL Server como escalada a intranet
```

**Opción C: Completa objetivo en segmento actual**

```
Pregunta: ¿El objetivo que necesito está en ESTE segmento?

Escenario:
  - Estás en DMZ web server
  - Objetivo es "acceso a BBDD"
  - BBDD está también en DMZ
  - No necesitas salir de DMZ
  
Acción: Completa objetivo aquí
  - Exfiltración
  - Persistence (si aplica)
  - Salida
```

---

## Freno 5: "El timeline se está acabando"

### Síntomas

```
- 5 días restantes, aún en recon fase
- Falló vector primario
- Backup también falla
- Objetivo aún no alcanzado
- Presión de cliente: "¿Dónde están los resultados?"
```

### Decisiones operacionales

**Opción A: Acelera selectivamente**

```
Cambios operacionales:
  - Reduce sleep entre comandos (30s → 5s)
  - Aumenta intento frequency
  - Acepta mayor riesgo de detección
  - Prioriza: objetivo >> OPSEC
  
Pero:
  - NO hagas "todos los cambios" a la vez
  - Monitorea detección
  - Mantén línea de exfil lista
  
Nota: Balance es crítico
  - Muy acelerado = detección garantizada
  - Muy lento = timeline expira
```

**Opción B: Reporta progreso parcial**

```
Si objetivo completo NO es viable:

Reporte incluye:
  1. Qué completamos (foothold, lateral, parcial)
  2. Qué no completamos (y por qué)
  3. Hallazgos técnicos importantes
  4. Recomendaciones para futuros tests
  
Valor para cliente:
  "No completamos X, pero descubrimos Y que es crítico"
  Cliente valora transparencia y aprendizaje
```

**Opción C: Reevalúa objetivo**

```
¿Objetivo original es alcanzable en timeline?

Si NO:
  - Propone objetivo ALTERNATIVO menos ambicioso
  - Ejemplo: "En lugar de 'acceso a 100k registros',
    podemos validar que acceso a BD es posible (POC)"
  
Comunicación:
  - Honesta con cliente
  - Propone alternativa viable
  - Mantiene valor de engagement
```

---

## Freno 6: "Encontré problema crítico no esperado"

### Síntomas

```
- RCE no explorada encontrada
- BBDD con millones de registros, sin protección
- Backup desprotegido, accesible
- Insider con acceso a TODO
- API sin autenticación
```

### Decisiones operacionales

**Opción A: Saca ventaja, pivota objetivo**

```
Nuevo objetivo = esto

Acción:
  1. Documenta descubrimiento
  2. Ajusta plan
  3. Explotación rápida
  4. Exfiltración si aplica
  5. POC documentado
```

**Opción B: Reporta cliente antes de explotar**

```
Algunos RoE requieren:
"Si encuentras CRÍTICO sin autorización, reporta antes de explotar"

Pasos:
  1. Contacta cliente inmediatamente
  2. "Encontramos X, ¿autorizas que exploremos?"
  3. Si SÍ: procede
  4. Si NO: documenta, no explotas
```

**Opción C: Documenta, proporciona POC, no explota**

```
Si RoE es estricto en scope:

Acción:
  1. Documentar hallazgo
  2. Screenshot
  3. Proporcionar POC (comando que lo demuestra)
  4. No explotación completa
  5. Respeto a contrato
```

---

## Freno 7: Filosofía: Fallo es Información

**Realidad:** 60% de engagements tiene frenos no previstos.

**Profesionalismo:** Cómo manejas freno = credibilidad del operador.

**Lo que hace un operador profesional:**
- ✅ Documenta TODO
- ✅ Reconoce limitaciones
- ✅ Proporciona alternativas
- ✅ Comunica honestamente
- ✅ Convierte fallo en lección
- ✅ Valor para cliente = aprendizaje

**Lo que hace un amateur:**
- ❌ Oculta fallo
- ❌ Culpa al cliente ("defensa muy fuerte")
- ❌ Abandona sin análisis
- ❌ Cero documentación
- ❌ Cero learning

---

*Manual del Operador · Capítulo 05: Manejo de Frenos*  
*Versión 1.0 — Pragmática, resiliente, honesta*