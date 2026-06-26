# Lessons — Lab-14 Golden Throne

> Lecciones del bloque de Domain Dominance. Se completan con observaciones reales tras ejecutar el plan.

---

## Lecciones de criterio

1. **DA es temporal; la persistencia de dominio es permanente.** Un reset de cuenta te deja fuera. Un Golden Ticket, un cert forjado o una clave DSRM te mantienen dentro aunque cambien todas las contraseñas.

2. **Elegir el mecanismo según objetivo y ruido.** Golden = general pero detectable; Silver = silencioso para acceso puntual; Diamond = difícil de detectar si el entorno tiene detección de Golden; Cert = sobrevive a todo; DSRM = silencioso si no hay política.

3. **El doble reset de krbtgt es la defensa real contra Golden Tickets.** Solo un reset no invalida los tickets en circulación — los tickets tienen una ventana de validez y el hash anterior se cachea. Este error frecuente del defensor da tiempo al operador.

4. **AdminSDHolder es set-and-forget.** Se añaden los permisos una vez; el SDProp los restaura cada hora aunque el defensor los elimine de las cuentas protegidas. Es persistencia que se auto-mantiene.

5. **DSRM es el olvido más rentable.** Pocas organizaciones rotan la contraseña DSRM, pocas la monitorizan. Con DsrmAdminLogonBehavior=2 y el hash, tienes backdoor en el DC independiente del dominio.

## Pendiente de completar tras ejecutar

- [ ] Hash krbtgt obtenido (vía DCSync).
- [ ] Mecanismo de persistencia elegido y justificación (según OPSEC del entorno).
- [ ] ¿Validaste que la persistencia sobrevive a un reset de la cuenta DA?
- [ ] Artefactos dejados (tarea, cert, ACL) y plan de limpieza.

---

*Lessons · Lab-14 Golden Throne · anatomía v3.1*
