# Lessons — Lab-12 Iron Veil

> Lecciones del bloque de Evasión II (AppLocker/CLM/LOLBAS). Se completan con observaciones reales tras practicar en el laboratorio del curso CRTO.

---

## Lecciones de criterio

1. **AppLocker y AMSI son capas ortogonales.** Evadir AMSI (Lab-11) no te da ejecución si AppLocker bloquea tu binario. Ambas capas coexisten y hay que conocer cuál te bloqueó.

2. **Leer la política antes de atacarla.** El modo Audit vs Enforce y las rutas de la whitelist determinan todo lo demás. Un entorno en Audit da falsa sensación de restricción — tus binarios funcionan aunque generen logs.

3. **CLM es síntoma, no causa.** Si PowerShell ofensivo falla y `LanguageMode` devuelve `ConstrainedLanguage`, el problema es AppLocker (en Enforce). Tratar CLM sin entender AppLocker es atacar el síntoma.

4. **LOLBAS es terreno, no exploit.** El sistema ya confía en estos binarios. Conocerlos es mapear el suelo firme donde puedes moverte, no forzar una puerta. Esa mentalidad (operar con lo que el entorno permite) es la filosofía de evasión madura.

5. **La detección de LOLBAS es un problema de señal/ruido.** No hay firma que disparar — hay contexto anómalo en binarios legítimos. Por eso el defensor usa reglas de comportamiento, no de firma.

## Pendiente de completar tras practicar (en el lab del curso)

- [ ] ¿AppLocker en Audit o Enforce? ¿Cómo lo detectaste?
- [ ] ¿Estaba CLM activo? Test `LanguageMode`.
- [ ] LOLBAS que funcionó en el entorno y por qué estaba en la whitelist.
- [ ] Qué intentaste que AppLocker bloqueó (Event 8003/8004 observado).

---

*Lessons · Lab-12 Iron Veil · anatomía v3.1*
