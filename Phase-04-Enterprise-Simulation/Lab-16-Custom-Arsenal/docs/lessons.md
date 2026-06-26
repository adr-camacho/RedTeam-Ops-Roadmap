# Lessons — Lab-16 Custom Arsenal

> Lecciones del bloque de Extending C2. Se completan tras practicar en el laboratorio del curso CRTO.

---

## Lecciones de criterio

1. **CS por defecto es detectable por cualquier NTA básico.** El perfil Malleable no es un extra — es el mínimo para operar en entornos con monitorización de red.

2. **BOF > execute-assembly para OPSEC de proceso.** Sin proceso hijo, sin cargar el CLR: footprint mínimo. En entornos con EDR que monitoriza procesos hijos de beacon, los BOFs son la diferencia entre operar o ser cazado.

3. **Aggressor automatiza la consistencia.** El checklist post-baliza que el operador hace manualmente en Lab-09 puede automatizarse con Aggressor — misma disciplina, cero olvidos.

4. **Custom Arsenal ≠ Ghost Signal.** Son capas distintas: AV/AMSI/ETW (Lab-11) protege el payload en memoria; Malleable/BOFs protegen el tráfico y el footprint del proceso. Un entorno maduro detecta ambas dimensiones — hay que cubrir las dos.

5. **El diseño se entiende aquí; el código se practica en el curso.** Lo que se transfiere al examen es saber qué ajustar (perfil, inject settings, SpawnTo) cuando algo se detecta, no memorizar el código.

## Pendiente de completar tras practicar (en el lab del curso)

- [ ] Perfil Malleable configurado y tráfico observado — ¿qué cambió vs el perfil por defecto?
- [ ] BOF ejecutado vs execute-assembly equivalente — diferencia de footprint observada.
- [ ] Aggressor script de automatización probado.

---

*Lessons · Lab-16 Custom Arsenal · anatomía v3.1*
