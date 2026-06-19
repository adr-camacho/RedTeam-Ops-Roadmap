# Manual del Operador — Árboles de Decisión Operacional

> **Clave:** La mayoría de puntos críticos en engagement son decisiones.  
> **Herramienta:** Estos árboles documentan la lógica de decisión operacional real.

---

## Árbol 1: "¿Soy detectado? ¿Qué hago?"

```
┌─────────────────────────────────────────────────────────────┐
│ ¿Defensa me detectó (alert, EDR, SOC)?                     │
└─────────────────────────────────────────────────────────────┘
                            │
                ┌───────────┴───────────┐
                │                       │
              [SÍ]                     [NO]
                │                       │
    ┌───────────┴────────────┐    Continúa con
    │                        │    plan operacional
    │ ¿Completé objetivo?    │
    │                        │
    └────────┬───────────────┘
             │
    ┌────────┴────────┐
    │                 │
  [SÍ]              [NO]
    │                 │
    │        ┌────────┴────────┐
    │        │                 │
    │   ¿Puedo continuar    [NO → ABORT]
    │   sigiloso?
    │        │
    │   ┌────┴────┐
    │   │         │
    │ [SÍ]     [NO]
    │   │         │
    │   │    ┌────┴────────────────┐
    │   │    │ ¿Tengo persistencia?│
    │   │    └────┬───────────────┘
    │   │         │
    │   │    ┌────┴────┐
    │   │    │         │
    │   │  [SÍ]      [NO]
    │   │    │         │
    │   │    │    EXFIL RÁPIDA
    │   │    │    + LIMPIEZA
    │   │    │    + SALIDA
    │   │    │
    │   │    └─ Pausa operativa
    │   │       Espera response
    │   │       Continúa si client autoriza
    │   │
    │   └──────────────┐
    │                  │
    │         Ajusta OPSEC
    │         ┌─────────────────────────┐
    │         │ Aumenta sleep/jitter    │
    │         │ Cambia técnicas obvias  │
    │         │ Reduce frecuencia cmds  │
    │         │ Evita PowerShell        │
    │         │ Mueve a máquina nueva   │
    │         └─────────────────────────┘
    │
    └──────────────────────┬─────────────────────────┐
                           │                         │
                    EXFILTRACIÓN              PERSISTENCIA
                    INMEDIATA                 (si aplica)
                    │                         │
                    ├─ Via C2                 ├─ Beacon alt
                    │  directo                │ ├─ Scheduled task
                    ├─ Via DNS                │ ├─ Registry runkey
                    │  tunnel                 │ └─ WMI event
                    ├─ Directo                │
                    │  hacia                  └─ Limpieza
                    │  NAS/shared             ├─ Event logs
                    │                         ├─ Bash history
                    └─ SALIDA                 ├─ Logfiles
                       LIMPIA                 └─ Artifacts

DECISIÓN CRÍTICA: En momento que detectan
  → Si objetivo completado: EXIT FAST
  → Si objetivo no completado: EVALUATE
     ├─ 30% probabilidad completar antes exit?
     │   → SÍ: Continúa, asume riesgo
     │   → NO: EXIT
     └─ Documentar: qué los alertó, por qué detectaron
```

---

## Árbol 2: "¿Cuál es mi próximo movimiento lateral?"

```
┌──────────────────────────────────────────────────┐
│ ¿Estoy en objetivo final (BBDD, secrets, etc.)?  │
└──────────────────────────────────────────────────┘
                      │
            ┌─────────┴─────────┐
            │                   │
          [SÍ]                 [NO]
            │                   │
    Proceder a:          ¿Qué opciones tengo?
    - Exfil data            │
    - Persistence       ┌───┼───┬───────┬──────────┐
    - Cleanup           │   │   │       │          │
    - Exit          [A] [B] [C] [D]    [E]
                        │   │   │       │
        [A] Kerberos lateral (si AD)
        │   │
        │   ├─ ¿Tengo user hash/creds?
        │   │   ├─ SÍ: Golden/Silver/Diamond ticket
        │   │   └─ NO: Go [B]
        │   │
        │   ├─ ¿Tengo credenciales claras?
        │   │   ├─ SÍ: AS-REP roasting, Kerberoasting
        │   │   └─ NO: Enumeración BloodHound
        │   │
        │   └─ Ataque específico:
        │       ├─ S4U2Self (delegation abuse)
        │       ├─ Overpass-the-hash
        │       ├─ Pass-the-ticket
        │       └─ Unconstrained delegation
        │
        [B] SSH/RDP lateral (credenciales)
        │   │
        │   ├─ ¿Tengo credenciales?
        │   │   ├─ SÍ: Intenta RDP/SSH directo
        │   │   └─ NO: Credential hunting (ver Árbol 3)
        │   │
        │   ├─ ¿Puedo alcanzar target?
        │   │   ├─ SÍ (firewall lo permite): Conecta
        │   │   └─ NO: Pivota vía C2 proxy (SOCKS)
        │   │
        │   └─ Conexión exitosa?
        │       ├─ SÍ: Escalada si necesario
        │       └─ NO: Intenta [C]
        │
        [C] C2 Pivoting (SOCKS proxy)
        │   │
        │   ├─ Establece proxy en máquina actual
        │   │   └─ Sliver: socks 5 (tunnel bidireccional)
        │   │
        │   ├─ Proxifica tráfico desde Kali
        │   │   └─ proxychains, chisel, ligolo-ng
        │   │
        │   └─ Intenta conexiones a máquinas "unreachable"
        │       ├─ RDP via proxy
        │       ├─ LDAP enumeration
        │       ├─ SMB share access
        │       └─ Si todo falla: [D]
        │
        [D] Búsqueda de datos en máquina actual
        │   │
        │   ├─ ¿Hay datos valiosos aquí?
        │   │   ├─ SÍ: Exfiltración directo
        │   │   └─ NO: Lateral movement necesario
        │   │
        │   ├─ Búsqueda específica:
        │   │   ├─ BBDD local (SQL Server)
        │   │   ├─ Credenciales en memoria (LSASS)
        │   │   ├─ Archivos de config (web.config, .env)
        │   │   ├─ Email (si acceso Outlook)
        │   │   └─ Browser cookies/passwords
        │   │
        │   └─ Si objetivo está aquí: EXFIL
        │
        [E] Cambiar de usuario actual
            │
            ├─ ¿Qué usuario soy?
            │   ├─ Administrator: No necesario cambiar
            │   ├─ Usuario normal: Necesario escalada
            │   └─ System/NT AUTHORITY: Ya máximo
            │
            ├─ Técnicas escalada:
            │   ├─ UAC bypass (si Windows)
            │   ├─ Token impersonation (potatoes)
            │   ├─ Kernel exploit (si es old OS)
            │   ├─ Service unquote paths
            │   └─ Credential dumping (DPAPI, LSASS)
            │
            └─ Si escalada exitosa: Re-evalúa objetivos
```

---

## Árbol 3: "¿Dónde encuentro credenciales?"

```
┌─────────────────────────────────────────────┐
│ Necesito credenciales para movimiento      │
│ ¿Dónde busco?                              │
└─────────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┬──────────────┐
        │           │           │              │
    [LSASS]     [FILES]     [MEMORY]      [REGISTRY]
        │           │           │              │
        │           │           │              │
        │       ┌───┴───┐   ┌───┴────┐    ┌───┴────┐
        │       │       │   │        │    │        │
    Dump via  .conf  Browser  Process  SAM/  RunKey
    - Proc    files  cache    environ  SECURITY
    - Mini    web.   history  JAVA    LSA
      dump    config unifi    prop
    - Raw     .bat   Discord  TOMCAT
      syscall .ps1   Chrome
            .env    AWS SDK
            .sh
            .pem

    Orden de prioridad:
    1. LSASS dump (contraseñas en plaintext)
    2. Registry SAM (hashes locales)
    3. Config files (.env, web.config)
    4. Browser (emails, accesos cloud)
    5. Process memory (Java properties, etc.)

    Si LSASS dump falla (PPL, Defender):
    → Intenta process dump → RDP credenciales
    → Intenta DPAPI extraction
    → Intenta config file mining
    → Espera usuario nuevo login → captura credenciales

    Si nada funciona:
    → Credential spray (si tienes lista de passwords)
    → Espera más tiempo (usuario loguea)
    → Intenta técnica alternativa (Árbol 2)
```

---

## Árbol 4: "¿Continúo o paro el engagement?"

```
Estado actual: [A] = Fase actual del engagement

┌──────────────────────────────────────────────────┐
│ CHECKPOINT DE DECISIÓN (cada 2-3 días)           │
└──────────────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
    [PROGRESO]   [RIESGO]    [TIMELINE]
        │           │           │
    ¿Avancé    ¿Risk/reward  ¿Tengo tiempo
    hacia     está balance?  para objetivo?
    objetivo?      │           │
        │          │           │
    ┌───┴───┐  ┌───┴───┐  ┌────┴────┐
    │       │  │       │  │         │
   [SÍ]   [NO] [SÍ]   [NO] [SÍ]    [NO]
    │       │   │       │   │        │
    │       │   │       │   │    Acción:
    │       │   │       │   │    ├─ Acelera
    │   Contin Contin ABORT Contin │ reduciendo
    │   +OK    +CHECK +DOC  +OK   │ OPSEC
    │        │                    │
    │        │                    ├─ O ABORT
    │        │                    │
    │        │                    └─ O pivota
    │        │                      objetivo
    │        │
    │    ¿Tengo alternativa
    │    si esto falla?
    │        │
    │    ┌───┴────┐
    │    │        │
    │  [SÍ]    [NO]
    │    │        │
    │    OK    Prepara
    │         alternativa
    │         ANTES de
    │         continuar
    │
    └────────────┬────────────────┘
             CONTINÚA
             ENGAGEMENT
             con mejor
             información
```

---

## Árbol 5: "¿Qué hago si credential hunting falla?"

```
┌────────────────────────────────────────────┐
│ He intentado TODO para obtener credenciales│
│ Y NADA funcionó. ¿Ahora?                    │
└────────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
    [ESPERA]              [PIVOTA]
        │                       │
    ┌───┴──────────────┐   ┌────┴────────┐
    │                  │   │             │
  Espera a que:      Nuevo
  - Usuario loguee    vector
  - Evento trigger
  - Cambios en sistema
        │
    ┌───┴────────────┐
    │                │
  [Horas]         [Días]
    │                │
  Monitor          Recon
  logons,          alternativa:
  services         ├─ Web RCE
  restarts         ├─ Supply chain
                   ├─ Insider
                   └─ Physical

    Si espera no es viab
le (timeline apretado):
    → ABORT
    → Documentar: hallazgos parciales
    → Reporte: "Llegamos a X, recomendamos Y"
```

---

*Manual del Operador · Capítulo 04: Árboles de Decisión*  
*Versión 1.0 — Lógica operacional, pragmática*