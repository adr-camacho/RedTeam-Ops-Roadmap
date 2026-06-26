# Lessons — Lab-18 Final Verdict

> Lecciones del capstone. Se completan después de ejecutar la simulación completa.

---

## Lo que el capstone revela

1. **Los huecos son los silencios.** Donde el capstone se para, ahí está el lab que necesita más práctica. Es más valioso encontrarlo aquí que en el examen real.

2. **El OPSEC se degrada bajo presión.** La prisa tiende a saltarse el recon, lanzar SharpHound a lo bruto, o no persistir antes de arriesgar. El capstone entrena la disciplina de mantener el proceso aunque haya contrarreloj.

3. **La cadena es tan fuerte como su eslabón más débil.** Si Lab-11 no está sólido, el beacon caerá al intentar evasión. Si Lab-09 se saltó, la primera acción ofensiva puede quemar el acceso.

4. **Documentar mientras avanzas es no-negociable.** El reporte del examen se escribe durante el examen, no al final. El capstone es el momento de forjar ese hábito.

5. **48h es mucho tiempo si sabes qué hacer.** Los candidatos que suspenden no se quedan sin tiempo — se quedan bloqueados en un camino sin pivotear. La regla de las 2h (si llevas 2h bloqueado, pivota) salva el examen.

---

## Checklist de estado antes del examen real

El criterio: cada lab debe ser **SÍ** antes de presentar el CRTO. Los labs 01-07 son los que ya ejecutaste — su "SÍ" viene de haberlos corrido de verdad. Los labs 08-18 son los que ejecutarás con el curso CRTO.

### Phase-01 & Phase-02 — Labs ejecutados (Phase-01 y Phase-02)

- [ ] **Lab-01 Ghost Forest** · AS-REP Roasting, Kerberoasting, Sliver C2, DCSync, Pass-the-Hash
  - ¿Puedo AS-REP Roastear y crackear un hash sin saber el usuario de antemano?
  - ¿Sé correr un beacon Sliver y operar desde él?
  - ¿Tengo claro DCSync → Pass-the-Hash para acceso lateral?

- [ ] **Lab-02 Silent Bridge** · Web RCE → pivoting, movimiento lateral desde web
  - ¿Entiendo la cadena web shell → beacon → pivoting al segmento interno?

- [ ] **Lab-03 Dark Gate** · ADCS ESC1/4/8, certificados como vector de escalada
  - ¿Sé enumerar templates vulnerables con Certify/Certipy?
  - ¿Puedo explotar ESC1 (template con SAN arbitrario) y obtener TGT?

- [ ] **Lab-04 Iron Forest** · BloodHound, ACL abuse, GenericWrite → Targeted Kerberoasting
  - ¿Sé leer un grafo de BloodHound y seguir el path hasta DA?
  - ¿Puedo explotar GenericWrite (cambiar SPN → Targeted Kerberoast)?

- [ ] **Lab-05 Silver Chain** · Delegación (Unconstrained/Constrained/RBCD), Shadow Credentials
  - ¿Distingo Unconstrained de Constrained de RBCD y sé cuándo atacar cada una?
  - ¿Sé hacer RBCD de 0 si tengo permisos de escritura sobre el objeto?
  - ¿Puedo explotar Shadow Credentials (msDS-KeyCredentialLink)?

- [ ] **Lab-06 Black Policy** · GPO cross-forest, SID History, abuso de trusts GPO
  - ¿Sé crear/modificar una GPO y forzar su aplicación?
  - ¿Entiendo cómo la GPO cross-forest propaga privilegios?

- [ ] **Lab-07 Shadow Vault** · LAPS, DPAPI, LSASS (bloqueado por PPL), Shadow Creds
  - ¿Sé leer contraseñas LAPS si tengo permiso sobre msLAPS-Password?
  - ¿Sé descifrar blobs DPAPI con la Master Key del usuario?
  - ¿Entiendo por qué LSASS falla con PPL activo y cuál es la alternativa (Shadow Creds)?

### Phase-03 — Operaciones (kit de operador)

- [ ] **Lab-08 Black Beacon** · C2 operativo
  - ¿Puedo montar un beacon y configurar un listener en <15 min?

- [ ] **Lab-09 First Contact** · Situational Awareness
  - ¿Tengo el árbol de decisión de la primera hora automatizado en la cabeza?
  - ¿Identifico Defender/AMSI/CLM/AppLocker antes de actuar?

- [ ] **Lab-10 Deep Root** · PrivEsc + Persistencia de host
  - ¿Reconozco SeImpersonate en `getprivs` y sé ir directo a Potato?
  - ¿Elijo el mecanismo de persistencia proporcional al entorno?

- [ ] **Lab-11 Ghost Signal** · Evasión Defender/AMSI/ETW
  - ¿Opero con Defender ON sin perder el beacon?
  - ¿Entiendo la diferencia entre evadir firma y evadir comportamiento?

- [ ] **Lab-12 Iron Veil** · AppLocker/CLM/LOLBAS
  - ¿Detecto si AppLocker está en Enforce o Audit?
  - ¿Mapeo qué LOLBAS están disponibles como terreno de ejecución?

### Phase-04 — Enterprise Simulation

- [ ] **Lab-13 Linked Shadows** · MSSQL
  - ¿Sé enumerar instancias SQL vía SPN y llegar a xp_cmdshell?
  - ¿Entiendo cómo los linked servers permiten lateral cross-segment?

- [ ] **Lab-14 Golden Throne** · Domain Dominance
  - ¿Sé hacer DCSync y elegir el mecanismo de persistencia según el entorno?
  - ¿Entiendo por qué el doble reset de krbtgt invalida Golden Tickets?

- [ ] **Lab-15 Forest Reign** · Forest & Trust Abuse
  - ¿Sé hacer el Extra SID Attack child→parent (siempre disponible en intra-forest)?
  - ¿Mapeo la cadena de trusts antes de intentar cruzarlos?

- [ ] **Lab-16 Custom Arsenal** · Extending C2
  - ¿Sé cuándo usar BOF vs execute-assembly según OPSEC requerido?
  - ¿Entiendo qué parte del C2 delata el perfil por defecto?

- [ ] **Lab-17 Silent Exit** · Exfil + Reporting
  - ¿Sé localizar shares de valor y exfiltrar con RAR cifrado?
  - ¿Documento capturas + credenciales + timeline en tiempo real?

### El criterio final

**Todos los checks en SÍ → presenta el examen.**

Si hay algún NO en Labs 01-07 → ejecuta ese lab de nuevo en tu entorno (ya tienes la infra montada).
Si hay algún NO en Labs 08-18 → practica ese bloque en el curso CRTO hasta que fluya.

El capstone (este lab) es el simulacro. El examen real es la validación.

---

*Lessons · Lab-18 Final Verdict · checklist pre-examen completo (Labs 01-18) · anatomía v3.1*
