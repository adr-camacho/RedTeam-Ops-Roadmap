# Lessons — Lab-15 Forest Reign

> Lecciones del bloque de Forest & Trust Abuse. Se completan con observaciones reales al ejecutar el plan.

---

## Lecciones de criterio

1. **Mapear antes de atacar.** La cadena de trusts (¿quién confía en quién?, ¿qué SID Filtering hay en cada tramo?) determina el camino completo. Atacar sin entender los trusts es moverse a ciegas.

2. **Child→Parent es el ataque más rentable del examen.** Dentro de un forest no hay SID Filtering — comprometer el dominio hijo da el forest raíz mediante Extra SID Attack. Es el camino más directo a Enterprise Admins.

3. **SID Filtering activo no es el fin.** Hay técnicas que funcionan aunque SID Filtering esté activo: abuso de cuentas extranjeras, coerción cross-forest, o explotar relaciones de confianza con permisos delegados.

4. **Los trusts son el mapa del lateral enterprise.** En un entorno multi-forest, los trusts definen exactamente las rutas disponibles. El operador que los lee tiene el mapa del territorio; el que no, se para en la primera frontera.

5. **Las cadenas de trust dan la nota alta en CRTO.** Los flags cross-forest son los más difíciles del examen y los más valorados. Dominarlos marca la diferencia entre aprobado y notable.

## Pendiente de completar tras ejecutar

- [ ] Cadena de trusts enumerada (tipos, dirección, SID Filtering en cada tramo).
- [ ] ¿Extra SID Attack child→parent funcionó? SID de EA usado.
- [ ] ¿Hubo trusts inter-forest abusables? ¿SID Filtering desactivado?
- [ ] Flags cruzados y ruta que se siguió.

---

*Lessons · Lab-15 Forest Reign · anatomía v3.1*
