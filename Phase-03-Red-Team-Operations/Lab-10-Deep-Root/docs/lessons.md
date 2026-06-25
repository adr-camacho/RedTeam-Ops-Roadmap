# Lessons — Lab-10 Deep Root

> Lecciones del bloque de Persistencia y Escalada de host. Se completan con observaciones reales tras ejecutar el plan de ataque.

---

## Lecciones de criterio

1. **Elevar antes de persistir.** La persistencia creada desde un contexto elevado es más robusta y privilegiada. El orden no es arbitrario.

2. **SeImpersonate es la llave maestra.** Si `whoami /priv` lo muestra (común en cuentas de servicio), Potato → SYSTEM es la vía más limpia — preferible a un exploit de kernel ruidoso con Defender ON.

3. **Persistencia proporcional, no exótica.** El mecanismo correcto no es el más sofisticado (WMI/COM) por defecto, sino el que pasa desapercibido en ESE entorno y sobrevive lo necesario. La elección depende de lo que viste en Lab-09 (¿qué me vigila?).

4. **Validar o no cuenta.** Una persistencia que no aguanta reinicio/logoff no es persistencia. La validación es parte del trabajo, no un extra.

5. **Persistir y limpiar son la misma disciplina.** Cada artefacto que dejas (Run key, tarea, servicio) es un IoC. Operar bien incluye saber qué huella dejas y minimizarla.

## Pendiente de completar tras ejecutar

- [ ] Vector de escalada que el host CRTO permitió y por qué.
- [ ] Mecanismo de persistencia elegido y su justificación de proporcionalidad.
- [ ] Resultado de la validación (¿sobrevivió al reinicio?).
- [ ] Artefactos dejados y plan de limpieza.

---

*Lessons · Lab-10 Deep Root · anatomía v3.1*
