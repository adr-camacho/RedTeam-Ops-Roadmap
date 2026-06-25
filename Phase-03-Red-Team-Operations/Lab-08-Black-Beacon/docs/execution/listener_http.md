# Fase-02 · Listener HTTPS Configuration

> Bloque CRTO: Listeners  
> Concepto: Crear un listener HTTPS que acepte conexiones de beacons


> **Paso 2 de 6 · Secuencia de construcción**
>
> **Objetivo del paso:** Configurar un listener HTTPS: el canal por el que la baliza habla con el team server.
>
> **Prerequisito:** Paso 1 (team server activo).
>
> **Habilita:** generar payloads que apunten a este listener (Paso 3).

---

## 🎯 Objetivo

Configurar un **listener HTTPS** en el team server. Los beacons se conectarán a este listener para recibir comandos.

## 📋 Prerequisitos

- Team server activo (Fase 01)
- Operador conectado
- Certificado HTTPS (self-signed es válido para lab)

## 🔨 Ejecución

### Paso 1: Crear listener HTTPS

```bash
sliver > https -l 0.0.0.0 -p 443
```

**Esperado:**
```
[*] HTTPS listener started on 0.0.0.0:443
[*] Certificate CN: sliver.local (self-signed)
[*] Valid from: 2026-06-18 to 2027-06-18
[*] Listeners: 1 (HTTPS/0.0.0.0:443)
```

**Captura:** `FASE-02/fase-02-01-listener-https-creado.png`  
**Anotación:** Confirmación de listener activo en puerto 443, certificado

### Paso 2: Verificar listener

```bash
sliver > listeners
```

**Esperado:**
```
[*] Active Listeners:
  ID    Type      Host         Port  Online
  ----  ----      ----         ----  ------
  1     HTTPS     0.0.0.0      443   ✓
```

**Captura:** `FASE-02/fase-02-02-listeners-status.png`

## 🏁 Resultado

✅ Listener HTTPS activo en puerto 443  
✅ Certificate auto-generado  
✅ Sistema listo para recibir conexiones de beacons

## 📝 Notas

- **Puertos:** 443 es estándar; alternativas: 8443, 8080 (HTTP), según red
- **Certificate:** Para OPSEC real, genera cert con CN legítimo (p. ej. "microsoft.com")
- **Multiple listeners:** Puedes crear varios listeners simultáneamente