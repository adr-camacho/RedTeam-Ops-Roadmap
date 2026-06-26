# Lab-14 · Golden Throne — Domain Dominance & Persistence

![Status](https://img.shields.io/badge/Status-Operación%20v3.1%20(plan)-yellowgreen)
![Phase](https://img.shields.io/badge/Phase-04-orange)
![Adversary](https://img.shields.io/badge/Adversary-APT10%20Cloud%20Hopper-red)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Operación%20(A)-8a2be2)

> Fase: `Phase-04-Enterprise-Simulation` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** Domain Dominance & Persistence — tickets forjados (Golden/Silver/Diamond), certs fraudulentos (ADCS), DSRM, AdminSDHolder. Persistencia que sobrevive a resets de credenciales.
**Arquetipo:** Operación (A) — kill-chain real. El contenido didáctico está completo; `execution/` es el **plan de ataque**.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [APT10](../../docs/adversaries/APT10.md)

> **Nota de honestidad:** Golden/Diamond Tickets son técnica firma de **APT29**, no de APT10. El `emulation.md` lo declara explícitamente — APT10 es el vehículo narrativo de la operación enterprise; la técnica es tradecraft estándar de CRTO. Ver emulation.md.

---

## 🎯 Objetivo

Pasar de "tengo DA" a "tengo el dominio para siempre": persistencia que sobrevive a resets de contraseñas, cambios de cuentas y rotaciones. Saber qué variante usar según objetivo, ruido y lo que el defensor detecta.

## 📚 Qué cubre (temario CRTO)

| Mecanismo | Depende de | Sobrevive a |
|-----------|-----------|-------------|
| **Golden Ticket** | hash de krbtgt | cambios de cuentas DA |
| **Silver Ticket** | hash de cuenta de servicio | resto de resets |
| **Diamond Ticket** | TGT real + modificación | detección de Golden |
| **Forged cert (ADCS)** | CA privkey | resets + cambios krbtgt |
| **DSRM backdoor** | password DSRM del DC | resets de dominio |
| **AdminSDHolder** | ACL del SDHolder | cambios en ACLs protegidas |

## 📂 Estructura

```
Lab-14-Golden-Throne/
├── docs/
│   ├── technique.md                  # ✅ Los 6 mecanismos + cuándo usar cada uno
│   ├── emulation.md                  # ✅ APT10 vehículo narrativo; Golden = APT29 (declarado)
│   ├── detection.md                  # ✅ Cómo se detecta cada mecanismo
│   ├── lessons.md                    # ✅ El doble reset, AdminSDHolder, DSRM
│   ├── execution/                    # 🗺️ PLAN (M1-M4)
│   │   ├── dcsync.md                 #    M1 · DCSync → hash krbtgt
│   │   ├── persistence_choice.md     #    M2 · elegir e implementar mecanismo
│   │   ├── persistence_validation.md #    M3 · ¿sobrevive al reset?
│   │   └── cleanup_opsec.md          #    M4 · mínima huella
│   └── report/
├── loot/   ├── nmap/   └── screenshots/
```

---

*GOLDEN THRONE · Domain Dominance & Persistence · Adrián Camacho — Entorno de laboratorio, únicamente con fines educativos*
