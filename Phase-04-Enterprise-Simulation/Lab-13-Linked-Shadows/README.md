# Lab-13 · Linked Shadows — MS SQL Server Attacks

![Status](https://img.shields.io/badge/Status-Operación%20v3.1%20(plan)-yellowgreen)
![Phase](https://img.shields.io/badge/Phase-04-orange)
![Adversary](https://img.shields.io/badge/Adversary-APT10%20Cloud%20Hopper-red)
![Arquetipo](https://img.shields.io/badge/Arquetipo-Operación%20(A)-8a2be2)

> Fase: `Phase-04-Enterprise-Simulation` · Roadmap: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)

**Capability (eje didáctico):** MSSQL Attacks — enum, linked servers, xp_cmdshell, lateral vía SQL.
**Arquetipo:** Operación (A) — kill-chain real. El contenido didáctico está completo; `execution/` es el **plan de ataque**.
**Docs:** [technique](docs/technique.md) · [emulation](docs/emulation.md) · [detection](docs/detection.md) · [lessons](docs/lessons.md) · adversario: [APT10](../../docs/adversaries/APT10.md)

---

## 🎯 Objetivo

Enumerar y abusar de MSSQL: linked servers, ejecución de comandos y movimiento lateral vía SQL. Los linked servers son literalmente Cloud Hopper aplicado a SQL — saltar entre sistemas vinculados por la cadena de confianza que los administradores crearon.

## 📚 Qué cubre (temario CRTO)

| Bloque | Contenido |
|--------|-----------|
| **MSSQL Discovery** | SPNs, instancias accesibles, PowerUpSQL |
| **Enum de privilegios SQL** | public / db_owner / sysadmin, linked servers |
| **xp_cmdshell** | Habilitar, ejecutar OS commands, beacon bajo cuenta SQL |
| **Escalada SQL** | Impersonation, linked server con creds privilegiadas |
| **Lateral vía linked servers** | OPENQUERY / AT — Cloud Hopper en SQL |

## 💡 Valor didáctico en el examen

Una vía de lateral/escalada que el examen incluye y mucha gente pasa por alto. Los linked servers son un camino barato a otro dominio o segmento que no tiene WinRM abierto. Tenerlo fluido suma objetivos. (Requiere VM SQL Server en el entorno CRTO.)

## 📂 Estructura

```
Lab-13-Linked-Shadows/
├── README.md
├── docs/
│   ├── technique.md                  # ✅ MSSQL: enum, xp_cmdshell, linked servers
│   ├── emulation.md                  # ✅ APT10 = Cloud Hopper en SQL (encaje literal)
│   ├── detection.md                  # ✅ Proceso hijo SQL, SQL Audit, cadena de conexiones
│   ├── lessons.md                    # ✅ Lecciones de criterio
│   ├── execution/                    # 🗺️ PLAN de ataque (M1-M5)
│   │   ├── sql_discovery.md          #    M1 · SPNs + instancias accesibles
│   │   ├── sql_foothold.md           #    M2 · conectar + enum privilegios
│   │   ├── sql_escalation.md         #    M3 · sysadmin vía impersonation
│   │   ├── xp_cmdshell.md            #    M4 · OS execution + beacon
│   │   └── linked_lateral.md         #    M5 · lateral vía linked servers
│   └── report/
├── loot/   ├── nmap/   └── screenshots/
```

---

*LINKED SHADOWS · MS SQL Attacks · Adrián Camacho — Entorno de laboratorio, únicamente con fines educativos*
