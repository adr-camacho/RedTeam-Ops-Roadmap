# OPERATION GHOST SIGNAL — Lab-08
## Documento Operacional

**Clasificación:** Confidencial — Solo uso educativo  
**Adversario simulado:** Lazarus Group (RGB — Corea del Norte)  
**Operador:** Adrián Camacho  
**Entorno:** atackcorp.local — WKSTN-01 con Defender activo

---

## Objetivo de la operación

GHOST SIGNAL marca el inicio de Phase-03 — Red Team Operations. El objetivo no es comprometer el dominio sino **operar sin ser detectado por Windows Defender con Tamper Protection activo**. Cada técnica debe funcionar en un entorno defensor real sin modificar la configuración de seguridad del endpoint.

**Regla fundamental de este lab:** Tamper Protection permanece ON durante toda la operación.

---

## Credencial inicial

| Usuario | Contraseña | Dominio |
|---------|-----------|--------|
| `helpdesk.ruiz` | `Helpdesk2024!` | atackcorp.local |

---

## Progreso operacional

| Fase | Descripción | Estado | Fecha |
|------|-------------|--------|-------|
| Fase 01 | Reconocimiento con Defender activo | ⏳ Pendiente | — |
| Fase 02 | AMSI Bypass in-memory | ⏳ Pendiente | — |
| Fase 03 | Process Injection | ⏳ Pendiente | — |
| Fase 04 | Direct Syscalls + PE Evasion | ⏳ Pendiente | — |
| Fase 05 | C2 Sliver sleep obfuscation | ⏳ Pendiente | — |
| Fase 06 | OPSEC Cleanup | ⏳ Pendiente | — |

---

## Infraestructura en scope

| Sistema | IP | OS | Defender |
|---------|----|----|---------|
| DC-01 | 10.0.2.10 | Windows Server 2025 | Activo |
| WKSTN-01 | 10.0.2.8 | Windows 11 23H2+ | **Activo + Tamper Protection ON** |
| Kali | 10.0.2.9 | Kali Linux | — |

---

## Crown Jewels — Objetivos

| # | Objetivo | Técnica | Estado |
|---|----------|---------|--------|
| 1 | Beacon in-memory en WKSTN-01 sin artefactos en disco | Process Injection + sleep obfuscation | ⏳ |
| 2 | AMSI deshabilitado sin modificar configuración Defender | Patch in-memory AmsiScanBuffer | ⏳ |
| 3 | Shellcode ejecutado en proceso legítimo (svchost/explorer) | Shellcode injection | ⏳ |
| 4 | C2 activo con Defender sin alertas | Sliver + obfuscación | ⏳ |

---

## Loot

*Pendiente de ejecución*

---

## Lessons Learned

*Pendiente de ejecución*

---

*GHOST SIGNAL — Adrián Camacho | Phase-03 | Solo uso educativo*