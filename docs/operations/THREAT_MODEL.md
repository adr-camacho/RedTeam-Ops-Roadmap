# THREAT_MODEL.md — Red Team Ops Roadmap
## Modelo de Amenaza — Organización Ficticia: ATACKCORP S.L.

**Versión:** 1.0 | **Fecha:** Mayo 2026 | **Autor:** Adrián Camacho  
**Clasificación:** Documento de referencia del roadmap

---

## 1. Descripción de la Organización Ficticia

### ATACKCORP S.L.

ATACKCORP S.L. es una empresa ficticia de tamaño mediano creada exclusivamente para este roadmap. Representa una empresa tecnológica española con infraestructura mixta on-prem/cloud, similar a miles de empresas reales.

| Campo | Detalle |
|-------|---------|
| **Sector** | Tecnología B2B (software corporativo y consultoría IT) |
| **Tamaño** | 50-200 empleados |
| **Sede** | Zaragoza, España |
| **Facturación** | ~3.000.000 EUR/año |
| **Infraestructura** | AD on-prem + Azure AD híbrido + SQL Server + IIS |
| **Clientes** | Sector farmacéutico, industrial y hotelero |

### Por qué este perfil de empresa

ATACKCORP representa el objetivo más común en engagements reales de Red Team en España y Europa:
- **No es un banco ni infraestructura crítica** — defensa razonable pero no extrema
- **Tiene datos valiosos** — información financiera, clientes RGPD, secretos comerciales
- **Infraestructura híbrida** — mezcla de tecnologías antiguas y modernas
- **Equipo IT pequeño** — sin SOC dedicado 24/7, monitorización básica
- **Presupuesto de seguridad limitado** — no tienen todas las defensas implementadas

---

## 2. Crown Jewels — Activos de Alto Valor

### Definición

Los crown jewels son los activos que un adversario real priorizaría comprometer. Motivan las decisiones tácticas de cada lab — no atacamos "todo", atacamos lo que tiene valor real.

### Crown Jewels por categoría

#### Datos financieros (Impacto: Crítico)
| Activo | Ubicación | Valor para el adversario |
|--------|-----------|--------------------------|
| Nóminas y datos bancarios | `\\DC-01\Finance\Payroll\` | Fraude financiero, chantaje |
| Cuentas bancarias online | `C:\CorporateData\Finance\accesos_banca_online.txt` | Acceso directo a cuentas |
| Presupuesto anual | `C:\CorporateData\Finance\2026\` | Ventaja competitiva, insider trading |

#### Datos de clientes (Impacto: Alto — RGPD)
| Activo | Ubicación | Valor para el adversario |
|--------|-----------|--------------------------|
| Base de datos de clientes | `\\DC-01\Corporativo\clientes_activos_2026.txt` | Venta en dark web, competencia |
| Datos de contacto + NDA | SQL Server `AtackCorpDB.Clientes` | Violación RGPD + multa reputacional |

#### Propiedad intelectual (Impacto: Crítico)
| Activo | Ubicación | Valor para el adversario |
|--------|-----------|--------------------------|
| Proyecto Nexus (R&D) | `C:\CorporateData\RD\` | Ventaja competitiva directa |
| Algoritmos propietarios | Repositorio Git interno | Robo de IP, competencia |
| Código fuente WebApp | GIT-Server (10.0.3.150) | Análisis de vulnerabilidades |

#### Operaciones estratégicas (Impacto: Alto)
| Activo | Ubicación | Valor para el adversario |
|--------|-----------|--------------------------|
| Contrato M&A (1.2M EUR) | `C:\CorporateData\Legal\` | Insider trading, sabotaje |
| Pipeline de clientes | CRM interno | Robo de clientes por competencia |

#### Infraestructura IT (Impacto: Crítico)
| Activo | Ubicación | Valor para el adversario |
|--------|-----------|--------------------------|
| Hash krbtgt | AD — NTDS.dit | Persistencia indefinida (Golden Ticket) |
| Certificados DA (ADCS) | PKI CA | Persistencia post-IR |
| Credenciales de todos los sistemas | `C:\CorporateData\IT\Credentials\` | Acceso total a infraestructura |

---

## 3. Perfil de Adversarios

### ¿Por qué ATACKCORP sería un objetivo?

| Motivación | Adversario típico | Vector de ataque |
|-----------|-----------------|-----------------|
| Espionaje industrial (Proyecto Nexus) | Competidor + actor estatal | APT29, APT10 |
| Ransomware + extorsión | Grupos criminales (Lockbit, BlackCat) | Phishing, spraying |
| Datos de clientes (RGPD extorsión) | Grupos criminales | Web exploits, phishing |
| Acceso a clientes farmacéuticos vía supply chain | Actores estatales (APT41) | Supply chain compromise |

### Adversarios emulados en el roadmap

#### APT29 — Cozy Bear (SVR Rusia)
- **Motivación:** Espionaje — información estratégica de empresas tecnológicas europeas
- **TTPs características:** Kerberos abuse, ADCS, Living-off-the-Land, C2 sigiloso
- **Por qué ATACKCORP:** Clientes farmacéuticos + Proyecto Nexus son objetivos de espionaje industrial
- **Labs:** Lab-01 (GHOST FOREST), Lab-03 (DARK GATE)

#### APT41 — Double Dragon (MSS China)
- **Motivación:** Espionaje + beneficio económico — robo de IP + acceso a infraestructura de clientes
- **TTPs características:** Web exploits, pivoting agresivo, implantes multicapa
- **Por qué ATACKCORP:** Supply chain — comprometer ATACKCORP da acceso a sus clientes
- **Labs:** Lab-02 (SILENT BRIDGE)

#### APT28 — Fancy Bear (GRU Rusia)
- **Motivación:** Sabotaje + espionaje — disrupción de operaciones empresariales
- **TTPs características:** ACL abuse, GPO, Forest Trusts, credential theft masivo
- **Por qué ATACKCORP:** Empresa con clientes en sectores críticos (farmacéutico, industrial)
- **Labs:** Lab-04/05/06/07

#### Lazarus Group (RGB Corea del Norte)
- **Motivación:** Financiera + espionaje — robo de fondos + tecnología
- **TTPs características:** EDR evasion avanzada, C2 sofisticado, Initial Access via phishing
- **Por qué ATACKCORP:** Acceso a cuentas bancarias + datos financieros
- **Labs:** Lab-08/09/10/11

#### APT10 — Stone Panda (MSS China)
- **Motivación:** Espionaje a largo plazo — comprometer MSPs para acceder a sus clientes
- **TTPs características:** Operaciones largas, LOTL extremo, exfiltración gradual
- **Por qué ATACKCORP:** ATACKCORP es un MSP de facto para sus clientes — comprometer ATACKCORP da acceso a ellos
- **Labs:** Lab-12/13/14/15

---

## 4. Superficie de Ataque

### Vectores de entrada externos

| Vector | Servicio | Exposición | Labs que lo cubren |
|--------|---------|------------|-------------------|
| Web pública | WebApp en PROD (10.0.3.200) | Alta | Lab-02 |
| Panel de administración | Webmin puerto 10000 | Alta | Lab-02 |
| VPN corporativa | Portal web | Media | Lab-09 |
| Email corporativo | Exchange / Microsoft 365 | Alta | Lab-09 |
| Repositorios públicos | Git si mal configurado | Media | Lab-02 |

### Vectores de entrada internos (post-foothold)

| Vector | Descripción | Labs que lo cubren |
|--------|-------------|-------------------|
| AD Kerberos abuse | AS-REP Roasting, Kerberoasting | Lab-01 |
| Credenciales débiles | Contraseñas predecibles por patrón | Lab-01/09 |
| ACL misconfiguration | GenericWrite, WriteDACL sobre objetos AD | Lab-01/04/05 |
| Delegation misconfiguration | Unconstrained/Constrained | Lab-01/05 |
| ADCS misconfiguration | ESC1/ESC4/ESC8 | Lab-03 |
| GPO permissions | GpoEditDeleteModifySecurity | Lab-01/06 |
| Credential exposure | SYSVOL, Git history, PS history | Lab-01/02/04 |
| LAPS misconfiguration | Permisos de lectura excesivos | Lab-07 |
| Azure AD misconfiguration | App permissions, PRT exposure | Lab-14 |

---

## 5. Controles de Seguridad Existentes

### Lo que ATACKCORP tiene implementado (y sus gaps)

| Control | Estado | Gap explotable |
|---------|--------|----------------|
| Antivirus (Defender) | ✅ Activo | Sin EDR avanzado — evasión básica suficiente |
| Firewall perimetral | ✅ Activo | Sin inspección SSL saliente |
| AD con GPOs | ✅ Activo | Sin hardening de Kerberos (pre-auth no requerida) |
| Logging básico | ✅ Activo | Sin SIEM — logs no correlacionados |
| MFA en email | ⚠️ Parcial | No en VPN ni en sistemas internos |
| LAPS | ⚠️ Parcial | Solo en servidores, no en workstations |
| ADCS | ✅ Activo | Plantillas vulnerables (ESC1/ESC4) |
| Backup | ✅ Activo | Cuenta backup_svc sin protección suficiente |
| Segmentación de red | ⚠️ Parcial | Solo entre prod y office, no dentro |
| Patch management | ⚠️ Irregular | Webmin 1.890 sin parchear |
| Azure AD Conditional Access | ❌ No | Sin políticas de acceso condicional |
| Privileged Access Management | ❌ No | Sin PAM, credenciales en texto claro |

---

## 6. Impacto por Escenario de Compromiso

| Escenario | Impacto técnico | Impacto de negocio |
|-----------|----------------|-------------------|
| Compromiso de workstation | Credenciales de usuario, datos locales | Bajo |
| Compromiso de domain user | Acceso a shares, emails, aplicaciones | Medio |
| Compromiso de service account | Lateral movement, acceso a servicios | Alto |
| Domain Admin | Control total del dominio | Crítico |
| ADCS certificado DA | Persistencia post-IR indefinida | Crítico |
| Azure Global Admin | Control total del tenant cloud | Crítico |
| Exfiltración datos clientes | Multa RGPD + daño reputacional | Crítico |
| Ransomware | Cifrado de toda la infraestructura | Catastrófico |

---

## 7. Conexión con el Roadmap

### Cómo el threat model guía los labs

Cada lab tiene un contexto narrativo definido por este threat model:

```
Lab-01: APT29 entra via credenciales débiles (AS-REP) → espionaje Proyecto Nexus
Lab-02: APT41 explota Webmin → pivota a red interna → roba código fuente
Lab-03: APT29 abusa ADCS → persistencia via certificado → survives IR
Lab-04: APT28 escala via WriteDACL → DCSync → acceso total
Lab-05: APT28 usa RBCD/Shadow Creds → persistencia sin contraseña
Lab-06: APT28 explota Forest Trust → escala a dominio padre
Lab-07: APT28 roba LAPS passwords + DPAPI → credenciales de todo el entorno
Lab-08: Lazarus evade Defender → beacon persistente en DC
Lab-09: Lazarus hace spraying + phishing → foothold inicial
Lab-10: Lazarus establece C2 avanzado → operación larga sin detección
Lab-11: Lazarus construye infraestructura → engagement de semanas
Lab-12: APT10 simula engagement completo → exfiltra crown jewels gradualmente
Lab-13: APT10 escala via Forest Trust → compromete forest raíz
Lab-14: APT10 pivota a Azure → Global Admin → acceso a todos los clientes cloud
Lab-15: Simulación CRTO completa — todos los adversarios, todos los vectores
```

---

*Red Team Ops Roadmap — Adrián Camacho | Mayo 2026*  
*Documento de referencia del roadmap — Únicamente con fines educativos*