# Emulation Plan — FINAL VERDICT (APT10 / Cloud Hopper)

> **Perfil del actor (clase base, no se repite aquí):** [`APT10.md`](../../../docs/adversaries/APT10.md)
> **Arquetipo:** Operación (A) — integradora. La operación Cloud Hopper completa de extremo a extremo.

---

## El cierre del arco narrativo

Final Verdict no introduce un nuevo emulation plan — **integra los de todos los labs anteriores en una sola operación**. Lo que cada lab de Phase-03 y Phase-04 emulaba por separado, aquí converge en una cadena completa:

| Fase de la operación | Lab de referencia | APT10 en la cadena |
|---------------------|------------------|--------------------|
| C2 montado y operativo | Lab-08 | Infraestructura de operaciones |
| Foothold + recon | Lab-09, 10 | Primer acceso en la red del cliente |
| Defender evasión | Lab-11, 12 | Operación sin disparar alertas |
| Lateral vía MSSQL | Lab-13 | Cloud Hopper en SQL — salto entre sistemas |
| Domain dominance | Lab-14 | Consolidación en el dominio enterprise |
| Cross-forest | Lab-15 | **La esencia de Cloud Hopper — cruzar fronteras** |
| C2 adaptado | Lab-16 | Permanecer invisible meses/años |
| Exfiltración + cierre | Lab-17 | RAR + Dropbox — el paquete final |

## La honestidad del capstone

Final Verdict emula la **operación completa de APT10** — pero como declara el `PHASE_03_04_DESIGN.md`, esto es un currículo de examen, no la campaña Cloud Hopper literal. Lo que sí es genuino: la mentalidad de operar de forma persistente, discreta y orientada a datos, siguiendo las rutas de confianza de la infraestructura objetivo. Eso es APT10.

## Lo que el capstone prueba del arco

Si el capstone funciona de extremo a extremo, significa que el kit (Phase-03) y el despliegue (Phase-04) se integran como un operador real. Si hay huecos, el capstone los revela antes del examen real.

---

*Emulation Plan · Lab-18 Final Verdict · Cloud Hopper de extremo a extremo (anatomía v3.1)*
