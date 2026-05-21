# Lessons Learned — Operación DARK GATE
## Lab-03: ADCS Abuse — APT29 Emulation
**Operación:** DARK GATE | **Adversario:** APT29 | **Framework:** MITRE ATT&CK v14  
**Operador:** Adrián Camacho | **Fecha:** 16-17/05/2026

---

## Lecciones por categoría

| # | Lección | Categoría |
|---|---------|-----------|
| 1 | El nombre del usuario Administrador en español es `Administrador` no `administrator` — el UPN es case-sensitive en Certipy | ADCS |
| 2 | Certipy v5 requiere `WriteDacl` además de `GenericWrite` para ESC4 — la versión anterior solo necesitaba `GenericWrite` | ADCS |
| 3 | ESC8 relay SMB→HTTP está bloqueado en WS2022 por KB5005413 — no es un problema de configuración, es una mitigación permanente del OS | ADCS |
| 4 | Los certificados AD persisten tras rotación de contraseñas — son la técnica de persistencia más silenciosa en entornos AD modernos | Persistencia |
| 5 | PetitPotam con `-pipe all` prueba todos los pipes disponibles — más efectivo que usar solo `lsarpc` | Coerción |
| 6 | Instalar pip install impacket sobreescribe la versión del sistema — usar solo `apt install python3-impacket` en Kali | Herramientas |
| 7 | Los conflictos de versiones de impacket se resuelven eliminando `/usr/local/lib/python3.13/dist-packages/impacket*` | Herramientas |
| 8 | Documentar vulnerabilidades bloqueadas es igual de valioso que documentar exploits exitosos — refleja comportamiento real | Metodología |
| 9 | La coerción NTLM (PetitPotam) funcionó perfectamente — el problema es el relay, no la coerción | ADCS |
| 10 | ADCS es el vector más encontrado en pentests reales 2024-2026 — más del 80% de los dominios AD tienen alguna ESC | Red Team |

---

## Problemas encontrados y soluciones

| Fecha | Problema | Causa | Solución |
|-------|---------|-------|---------|
| 16/05/2026 | ADCS instalado pero CA no inicializada | Clave privada huérfana de instalación anterior | `Install-AdcsCertificationAuthority -OverwriteExistingKey` |
| 16/05/2026 | `Add-CATemplate` falla — plantilla no encontrada | Faltaba atributo `msPKI-Cert-Template-OID` | Añadir OID antes de publicar |
| 17/05/2026 | Certipy ESC1 falla — `KDC_ERR_C_PRINCIPAL_UNKNOWN` | UPN `administrator` en minúsculas (dominio en español) | Usar `Administrador@atackcorp.local` |
| 17/05/2026 | Certipy ESC4 falla — `FIN.GARCIA doesn't have permission` | Certipy v5 requiere `WriteDacl` además de `GenericWrite` | Añadir `WriteDacl + WriteProperty` desde Evil-WinRM |
| 17/05/2026 | fin.garcia credenciales inválidas | Contraseña no establecida en Lab-01 setup | `Set-ADAccountPassword -Identity fin.garcia` desde DC-01 |
| 17/05/2026 | ESC8 relay SMB→HTTP falla — `FAILED` | KB5005413 en WS2022 bloquea relay SMB→HTTP | Documentado como comportamiento real — no resoluble |
| 17/05/2026 | `impacket-ntlmrelayx` ImportError RPCRelayServer | Conflicto pip vs apt impacket | `rm -rf /usr/local/lib/python3.13/dist-packages/impacket*` |
| 17/05/2026 | Kernel-mode auth bloqueaba relay | WS2022 IIS configuración por defecto | Modificar `applicationHost.config` directamente |

---

## ADCS ESC — Guía de referencia rápida

| ESC | Condición | Herramienta | Impacto |
|-----|-----------|-------------|---------|
| ESC1 | msPKI-Certificate-Name-Flag = 1 + Client Auth | `certipy req -upn` | DA sin contraseña |
| ESC2 | Any Purpose EKU | `certipy req` | Autenticación arbitraria |
| ESC3 | Enrollment Agent | `certipy req -on-behalf-of` | DA via agent |
| ESC4 | GenericWrite + WriteDacl sobre plantilla | `certipy template` | Convertir en ESC1 |
| ESC6 | EDITF_ATTRIBUTESUBJECTALTNAME2 en CA | `certipy req -upn` | DA en cualquier plantilla |
| ESC8 | Web Enrollment HTTP + coerción NTLM | `ntlmrelayx + PetitPotam` | Cert DC → DA (bloqueado WS2022) |
| ESC11 | RPC Enrollment sin signing | `certipy relay -target rpc://` | Cert DC → DA |

---

## Comparativa Lab-01, Lab-02, Lab-03

| Aspecto | Lab-01 (APT29 — AD) | Lab-02 (APT41 — Pivoting) | Lab-03 (APT29 — ADCS) |
|---------|--------------------|--------------------------|-----------------------|
| **Vector** | Kerberos (AS-REP/Kerberoasting) | Web RCE (CVE-2019-12840) | ADCS (ESC1/ESC4/ESC8) |
| **Credenciales** | Crackeando hashes | Git history | Certificado PKI |
| **Persistencia** | Golden Ticket | schtasks + Run Key | Certificado (1 año) |
| **Detección** | Event 4768/4769 | IDS payload HTTP | Event 4886/4887 |
| **Complejidad** | Media | Alta (pivoting) | Media-Alta (PKI) |
| **Relevancia 2026** | Alta | Alta | Muy alta |

---

## Pendiente para labs futuros

| Tema | Lab objetivo |
|------|-------------|
| ESC8 en WS2019 (sin KB5005413) | Lab adicional opcional |
| ESC11 — RPC relay | Lab-04+ |
| Persistence via Shadow Credentials | Lab-05+ |
| ADCS + Forest Trusts | Lab-11 (Zephyr) |

---

*Operación DARK GATE completada — Adrián Camacho | Mayo 2026*