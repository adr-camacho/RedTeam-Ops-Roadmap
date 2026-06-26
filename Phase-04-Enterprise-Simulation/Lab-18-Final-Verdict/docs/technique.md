# Technique — Lab-18 Final Verdict

> **Capability (eje didáctico):** Capstone — Exam Simulation. Cadena completa Labs 08-17 bajo condiciones de examen: Defender ON, multi-dominio, por objetivos, contrarreloj.
> **Bloque CRTO:** Simulación completa del examen (48h, 6 flags mínimos para aprobar).
> **Arquetipo:** Operación (A) — integradora. No enseña técnicas nuevas: **aplica las de todos los labs anteriores bajo presión**.
> **Adversario:** APT10 / Cloud Hopper — ver [`emulation.md`](emulation.md). La operación completa de extremo a extremo.

> Este lab no es un manual de técnicas — es el ensayo general. Sirve para medir cobertura, velocidad y OPSEC bajo presión, y revelar huecos antes del día real. Si algo falla aquí, falla en condiciones controladas donde puedes remediarlo.

---

## 1. El formato del examen CRTO

- **48 horas** de acceso al entorno de examen.
- **6 flags mínimos** de un total de 8 para aprobar.
- **Defender ON** en todos los hosts — no se puede desactivar.
- **Assumed breach:** empiezas con una baliza ya dentro, no hay fase de phishing.
- **Multi-dominio/forest:** varios dominios conectados por trusts.
- **Por objetivos:** los flags están en hosts y datos específicos — hay que comprometer lo que el examen pide.

## 2. El playbook de las primeras horas (Lab-09 aplicado)

El árbol de decisión de la primera hora define el resto del examen:

```
00:00 — Baliza recibida
  → Lab-09: Self assessment (whoami /all, privilegios)
  → Lab-09: Postura defensiva (Defender ON, AMSI, CLM, Sysmon)
  → Lab-09: Host context (procesos, software, sesiones)
  → Lab-09: Domain recon dirigido (DCs, trusts, mis derechos)
  → Lab-09: Decisión — ¿primer movimiento seguro?

02:00 — Primera escalada / foothold sólido
  → Lab-10: Escalada (SeImpersonate/Potato si está, servicio, UAC)
  → Lab-10: Persistencia proporcional (no perder el acceso)

04:00 — Movimiento hacia el dominio
  → Lab-04/05: Kerberoasting, AS-REP, delegación
  → Lab-06/15: Trusts si hay multi-dominio
  → Lab-13: MSSQL si hay SQL Server con linked servers
```

## 3. La gestión del tiempo — lo que suspende

Los errores de tiempo que más suspenden CRTO no son técnicos:

| Error | Consecuencia |
|-------|-------------|
| Actuar sin leer el terreno (Lab-09 saltado) | Quemar el beacon en los primeros 30 min |
| Quedarse atascado en una vía sin pivotear | Perder 6h en algo que tiene alternativa |
| No tener persistencia antes de arriesgar | Perder el acceso a un host comprometido |
| No documentar mientras avanzas | Reescribir la cadena de ataque al final de memoria |

**La regla de las 2h:** si llevas 2h bloqueado en una técnica, pivota. El examen tiene vías alternativas; un camino bloqueado rara vez es el único camino.

## 4. Mapa de cobertura (Labs 08-17 → flags del examen)

| Bloque del examen | Labs de referencia | Crítico para aprobar |
|-------------------|-------------------|---------------------|
| C2 operativo | Lab-08 (Black Beacon) | Base de todo |
| Recon y SA | Lab-09 (First Contact) | Antes de cualquier acción |
| Privesc host | Lab-10 (Deep Root) | Flag frecuente |
| Evasión Defender | Lab-11, 12 | Operar sin perder beacons |
| Lateral AD | Lab-04, 05 (Phase-02) + Lab-15 | Flags de dominio |
| Domain Dominance | Lab-14 (Golden Throne) | Flag DC |
| Cross-forest | Lab-15 (Forest Reign) | Flags difíciles / nota alta |
| MSSQL | Lab-13 (Linked Shadows) | Flag SQL Server |
| C2 OPSEC | Lab-16 (Custom Arsenal) | Operar sin ser cazado |
| Exfil | Lab-17 (Silent Exit) | Flag de datos / cierre |

## 5. OPSEC bajo presión — lo que se rompe cuando hay prisa

El examen crea presión de tiempo que tiende a degradar el OPSEC:
- **No lanzar SharpHound a lo bruto** — aunque tengas prisa. El recon dirigido (Lab-09) es más rápido y más seguro.
- **No deshabilitar Defender** — Tamper Protection lo impide y el intento dispara una alerta.
- **Usar BOFs cuando sea posible** — especialmente para tareas de enum (Lab-16).
- **Persistir antes de arriesgar** — cada vez que vas a hacer algo ruidoso, asegura el acceso primero (Lab-10).

## 6. El documento de operación en tiempo real

El examen requiere un reporte final. La manera más eficiente es **documentar mientras avanzas**, no al final:
- Screenshot de cada flag capturado con timestamp.
- Nota del comando exacto que funcionó (no el que intentaste — el que funcionó).
- Timeline de credenciales obtenidas y de qué host.

Si documentas bien durante el examen, el reporte tarda 2h. Si no documentas, tarda 8h.

## 7. La mentalidad del capstone

Este lab no es para aprender técnicas nuevas — es para **medir dónde estás**. Si al correrlo:
- Hay Labs 08-17 donde no sabes qué hacer → ahí está el hueco.
- Hay técnicas que tardan 3h cuando deberían tardar 30 min → ahí está la práctica pendiente.
- El beacon se cae y no sabes por qué → Lab-11/12/16 necesitan más trabajo.

El valor del capstone es exactamente ese: fallar en condiciones controladas antes del día real.

## Referencias

- CRTO — Exam guide y formato oficial
- Labs 08-17 — la cadena completa de Phase-03 y Phase-04

---

*Technique · Lab-18 Final Verdict · Capstone Exam Simulation (anatomía v3.1, arquetipo operación integrador)*
