# Lessons — Lab-17 Silent Exit

> Lecciones del bloque de Exfiltración y Reporting. Se completan con observaciones reales al ejecutar el plan.

---

## Lecciones de criterio

1. **El objetivo es el dato, no el flag.** La mentalidad de engagement real convierte el acceso en impacto demostrable. Un DC comprometido sin datos exfiltrados no convence a ningún cliente.

2. **Data hunting dirigido antes que masivo.** Shares de Finance, HR, IT y C-suite primero; búsqueda masiva de archivos después. El patrón masivo dispara alertas; el acceso dirigido a shares de alto valor pasa más desapercibido.

3. **Cifrar antes de exfiltrar.** El DLP es ciego al contenido cifrado. RAR/7z con contraseña + exfil por HTTPS = invisible para la mayoría de los controles de salida.

4. **Servicios cloud legítimos son los mejores canales.** El tráfico hacia Dropbox/OneDrive es indistinguible del uso legítimo salvo por el proceso que lo origina y el volumen. APT10 lo sabía: RAR + Dropbox fue su método por eso.

5. **La salida limpia es parte del OPSEC.** Los artefactos dejados son IoCs que el cliente encontrará en su revisión post-engagement. Documentar qué se limpió y qué no es parte del reporte.

6. **El reporte es el entregable real.** El cliente paga por el reporte, no por el acceso. Un engagement sin documentación es un intento, no un engagement.

## Pendiente de completar tras ejecutar

- [ ] Datos de alto valor identificados y localizados.
- [ ] Método de staging usado (RAR/7z, tamaño, cifrado).
- [ ] Canal de exfiltración elegido y justificación.
- [ ] Artefactos limpiados vs dejados.
- [ ] Borrador del reporte / timeline de la operación completa.

---

*Lessons · Lab-17 Silent Exit · anatomía v3.1*
