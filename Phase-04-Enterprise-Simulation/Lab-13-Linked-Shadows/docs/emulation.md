# Emulation Plan — LINKED SHADOWS (APT10 / Cloud Hopper)

> **Perfil del actor (clase base, no se repite aquí):** [`APT10.md`](../../../docs/adversaries/APT10.md)
> **Arquetipo:** Operación (A). Este plan emula cómo **APT10 se mueve lateralmente a través de sistemas vinculados** en una operación enterprise.

---

## Por qué APT10 ancla este lab — el encaje más directo de Phase-04

Si Ghost Signal (Lab-11) era el encaje más fiel de Lazarus, Linked Shadows es el corazón narrativo de APT10. **Cloud Hopper** era precisamente eso: saltar de MSP a cliente a través de conexiones de confianza. Los linked servers de MSSQL son esa misma idea materializada en SQL — saltar de servidor en servidor siguiendo la cadena de confianza que los administradores configuraron.

APT10 utilizó credenciales válidas para moverse lateralmente entre sistemas vinculados (PsExec, WMI, SMB) — la misma filosofía que aquí se aplica a linked servers. Y usó `xp_cmdshell` como vía de ejecución en servidores SQL accesibles, documentado en múltiples informes de sus campañas enterprise.

## Qué es genuino de APT10 y qué es tradecraft universal

| Elemento del lab | ¿Genuino de APT10? | Matiz |
|------------------|---------------------|-------|
| Lateral via sistemas vinculados (Cloud Hopper) | **Sí, firma del actor** | La esencia de sus campañas MSP→cliente |
| xp_cmdshell para ejecución en SQL | **Sí, documentado** | Vía de ejecución en servidores SQL comprometidos |
| Credenciales válidas para moverse lateralmente | **Sí, firma del actor** | Pass-the-ticket/hash + creds válidas = su modus operandi |
| Enumeración de linked servers | **Tradecraft universal** | Metodología estándar de SQL exploitation |
| Impersonation dentro de SQL | **Tradecraft universal** | Técnica de escalada SQL, no atribuida específicamente a APT10 |

> Este lab es donde APT10 como adversario aporta más valor narrativo real. Los linked servers SON el "hopping" de Cloud Hopper aplicado a SQL. La analogía no es forzada — es literal.

## TTPs de APT10 que emula ESTE lab

| Táctica | Técnica | ID | En el lab |
|---------|---------|----|-----------|
| Lateral Movement | Use Alternate Auth Material (PTT/PTH) | T1550 | Acceso al SQL con credenciales obtenidas |
| Lateral Movement | Exploitation of Remote Services | T1210 | Lateral vía linked servers SQL |
| Execution | xp_cmdshell / Command Exec via SQL | T1059 | Beacon desde el servidor SQL |
| Discovery | Network Service Discovery | T1046 | Enum de instancias SQL en el dominio |

> Repertorio completo en [`APT10.md`](../../../docs/adversaries/APT10.md).

## Puente narrativo

Linked Shadows es el primer contacto de Phase-04 con el enterprise de ATACKCORP. APT10 (Cloud Hopper) no entra por la puerta frontal — entra por los servicios vinculados que las organizaciones comparten entre sí y que raramente se auditan con el mismo rigor que el perímetro. Un linked server de SQL entre dos segmentos es exactamente esa "puerta lateral de servicio" que Cloud Hopper explotó a escala global.

---

*Emulation Plan · Lab-13 Linked Shadows · especializa `APT10.md` — Cloud Hopper en SQL (anatomía v3.1)*
