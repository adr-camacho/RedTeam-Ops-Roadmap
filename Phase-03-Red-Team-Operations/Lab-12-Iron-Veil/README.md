# Lab-12 - Iron-Veil - Evasion II - App Control

> Fase: `Phase-03-Red-Team-Operations` - Estado: Pendiente - Roadmap: [`docs/design/ROADMAP.md`](../../docs/design/ROADMAP.md)

## Objetivo
Ejecucion bajo whitelisting y CLM; rutas permitidas, LOLBAS y su deteccion.

## Que cubre (temario CRTO)
AppLocker - Constrained Language Mode - LOLBAS

## Que prepara
El examen pone AppLocker; sin entender rutas y LOLBAS te quedas sin ejecucion.

## Valor didactico en el examen
Reconocer que se puede ejecutar y desde donde es la diferencia entre avanzar o atascarte.

## Regla de construccion
Teoria, deteccion, operativa y documentacion se construyen en este repo.
El **codigo armado de evasion** (bypass / loader / kit / BOF) **NO** vive en el repo: se practica en el laboratorio oficial CRTO con sus kits. Aqui documentamos el *por que* y el *como se detecta*.
## Estructura
`docs/theory` - `docs/detection` - `docs/execution` - `docs/analysis` - `docs/report` - `loot` - `nmap` - `screenshots` - `setup`
