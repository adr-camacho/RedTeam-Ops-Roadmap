# Detection — Lab-18 Final Verdict

> **Capability:** el capstone de detección — la cadena de ataque completa vista desde el defensor.
> **Arquetipo:** Operación · **Adversario:** APT10 · **Perspectiva:** Blue Team / Purple.
> **Clase base (herencia):** [`../../docs/reference/DETECTION_LIBRARY.md`](../../docs/reference/DETECTION_LIBRARY.md).

> En un engagement real, ninguna técnica aislada dispara todas las alertas — es la **correlación de señales a lo largo de la cadena** lo que revela al atacante. El defensor maduro no busca un evento, busca un patrón a lo largo del tiempo.

---

## La cadena de detección completa (correlación temporal)

| Fase | Técnica | Señal de detección (ver lab de referencia) |
|------|---------|------------------------------------------|
| C2 activo | Beaconing | Periodicidad de conexiones, JA3 anómalo (Lab-08, Lab-16) |
| Recon de host | Discovery | Ráfaga de comandos, LDAP queries (Lab-09) |
| Privesc | Potato/servicio | Proceso SYSTEM desde cuenta de servicio (Lab-10) |
| Evasión | AMSI/ETW | Anomalías en telemetría, tampering (Lab-11) |
| LOLBAS | AppLocker bypass | Binario legítimo con contexto anómalo (Lab-12) |
| MSSQL lateral | xp_cmdshell | Proceso hijo de sqlservr.exe (Lab-13) |
| Golden Ticket | Forged TGT | Event 4769 con SIDs anómalos (Lab-14) |
| Cross-forest | Extra SID | Inter-realm tickets, ExtraSids en PAC (Lab-15) |
| C2 adaptado | Malleable | JA3 + jitter analysis (Lab-16) |
| Exfil | RAR + cloud | 7z con -p, upload a Dropbox (Lab-17) |

## La correlación que derrota al atacante avanzado

Un defensor que mira evento por evento puede perder a un operador disciplinado. El que gana es el que correlaciona:

- **Cuenta X** hizo discovery en T+0, Kerberoasting en T+2, accedió a shares de Finance en T+6, subió 500MB a Dropbox en T+8.
- **Host Y** tuvo un proceso hijo de SQL en T+3 y luego una conexión outbound inusual en T+4.

Esa correlación temporal es lo que SIEM + UEBA (User Entity Behavior Analytics) busca. El capstone, desde la perspectiva del defensor, es practicar exactamente esa correlación.

---

*Detection · Lab-18 Final Verdict · cadena de detección completa (anatomía v3.1)*
