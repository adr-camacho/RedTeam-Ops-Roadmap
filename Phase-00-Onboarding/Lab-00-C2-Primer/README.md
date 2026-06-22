# Lab-00 — C2 Primer

> **Tipo:** Onboarding (no es un lab de fundamento del temario — ver `docs/STANDARDS.md §2`).
> **Carga estimada:** ~2–4 h · **Eje de adversario:** ninguno (es la rampa de entrada).

## Objetivo
Saber **operar el C2** antes de atacar nada: entender qué es un team server, un listener y un beacon,
y el ciclo básico de una sesión, con OPSEC mínimo. Es el **tramo 0** del `docs/LEARNING_PATH.md`.

## Qué NO es
- No ataca Active Directory ni emula a ningún adversario.
- No tiene `technique`/`emulation`/`detection`/`report`: su responsabilidad es preparar al operador, no
  ejercitar una capability del temario. Es la **única excepción** a la anatomía estándar, y es deliberada.

## Capability
- Montar el C2 (team server + listener).
- Recibir y manejar un beacon (check-in, sleep/jitter, tareas básicas).
- Entender el ciclo de operación y el OPSEC fundamental (qué ruido genera operar).

## Muro que resuelve
Ninguna kill-chain posterior debe usar C2 sin haberlo explicado. Este lab cierra esa dependencia (hallazgo
**F5** de `docs/reference/CRTO_COVERAGE.md`) antes de que Lab-01 use C2 por primera vez.

## Contenido
- `docs/setup.md` — montar el team server y un listener.
- `docs/operation.md` — recibir el beacon, ciclo de operación, OPSEC básico.
- `screenshots/` — evidencia del primer beacon.

## Prerequisitos
- Entorno de laboratorio operativo (ver `docs/LAB_INFRASTRUCTURE.md`).

## Habilita
- **Lab-01** (primera kill-chain AD): ya puede usar C2 con el ciclo entendido.
