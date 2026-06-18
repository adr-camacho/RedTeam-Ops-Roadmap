# Fase-05 · Basic Operability & OPSEC Tuning

> Bloque CRTO: Operativa base y OPSEC  
> Concepto: Ajustar sleep/jitter, ejecutar comandos

---

## 🎯 Objetivo

Operar el beacon con OPSEC básico: cambiar sleep/jitter, ejecutar recon commands.

## 📋 Prerequisitos

- Beacon activo (Fase 04)
- Sesión seleccionada

## 🔨 Ejecución

### Paso 1: Verificar sleep/jitter actual

```bash
sliver > BEACON_NAME > config
```

**Captura:** `FASE-05/fase-05-01-config-default.png`

### Paso 2: Cambiar sleep y jitter

```bash
sliver > BEACON_NAME > set beacon-interval 30000 --jitter 0.50
```

**Captura:** `FASE-05/fase-05-02-sleep-jitter.png`

### Paso 3: Ejecutar recon commands

```bash
sliver > BEACON_NAME > shell whoami
sliver > BEACON_NAME > shell ipconfig /all
sliver > BEACON_NAME > shell net user
```

**Capturas:** `FASE-05/fase-05-03-whoami.png`, `fase-05-04-ipconfig.png`, `fase-05-05-netuser.png`

## 🏁 Resultado

✅ Sleep ajustado a 30s con 50% jitter  
✅ Beacon operativo con OPSEC básico  
✅ Recon commands ejecutados