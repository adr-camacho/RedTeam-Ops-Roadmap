# 🔴 Lab-01: Ghost Forest
## Operación GHOST FOREST — APT29 Emulation

**Fase:** Phase-01 Fundamentals | **Dificultad:** Media-Alta | **Estado:** ✅ Completado  
**Fecha:** 09/05/2026 → 20/05/2026 | **Tiempo invertido:** ~40h  
**Adversario simulado:** APT29 (Cozy Bear) | **Framework:** MITRE ATT&CK v14

---

## 📝 Resumen Ejecutivo

El controlador de dominio `DC-01` y la workstation `WKSTN-01` del entorno `atackcorp.local` fueron comprometidos completamente mediante una cadena de ataque de 10 fases que replica las TTPs características de APT29.

El acceso inicial se obtuvo explotando configuraciones inseguras de Kerberos (**AS-REP Roasting**) sin necesidad de credenciales previas, obteniendo las contraseñas de dos cuentas de dominio en texto claro mediante cracking offline con diccionario dirigido basado en OSINT corporativo. Desde ese foothold, la escalada hasta **Domain Admin** se completó mediante **Kerberoasting** de una cuenta de servicio con SPN registrado y membresía en el grupo de administradores del dominio.

Posteriormente se desplegó infraestructura C2 real (**Sliver**) en la workstation, se volcaron todos los hashes NTLM del dominio via **DCSync** y se obtuvo acceso interactivo como la cuenta `Administrador` built-in mediante **Pass-the-Hash**.

**Impacto:** Crítico — compromiso total del dominio `atackcorp.local`. Acceso a todos los sistemas, datos y credenciales del entorno.

Las Fases 11-13 amplían la cadena de ataque con técnicas avanzadas de post-explotación AD: **Unconstrained/Constrained Delegation**, **GPO Abuse** y **ACL Abuse (Targeted Kerberoasting)**. Se incorpora **BloodHound CE** como herramienta metodológica central para mapear attack paths.

---

## 🗺️ Attack Path

```
Kali (10.0.2.9)
      │
      ▼
[Fase 1] Nmap + SMB + LDAP enum → atackcorp.local mapeado
      │
      ▼
[Fase 2] AS-REP Roasting → ceo.martinez:Direccion2024! + backup_svc:Backup2024!
         T1558.004 — GetNPUsers + John (diccionario dirigido OSINT)
      │
      ▼
[Fase 3] Evil-WinRM → Shell en DC-01 como ceo.martinez
         T1021.006 — WinRM acceso inicial
      │
      ▼
[Fase 4] Discovery → SPNs, grupos DA, descriptions, equipos
         T1087.002, T1069.002, T1558.003, T1018
      │
      ▼
[Fase 5] Kerberoasting → TGS backup_svc → crack → Domain Admin ✅
         T1558.003 — GetUserSPNs + John
      │
      ▼
[Fase 6] Lateral Movement → Evil-WinRM en WKSTN-01 (10.0.2.8)
         T1021.006
      │
      ▼
[Fase 7] C2 Sliver → Beacon EASY_PROFIT activo en WKSTN-01
         T1071.001, T1573.002, T1587.001
      │
      ▼
[Fase 8] LPE intento → SweetPotato (bloqueado por WinRM Network tokens)
         T1134.001 — parcial | T1562.001 — Defender deshabilitado
      │
      ▼
[Fase 9] Golden Ticket → forjado pero rechazado (PAC Validation WS2022)
         T1558.001 — parcial | T1003.006 — krbtgt hash obtenido
      │
      ▼
[Fase 10] DCSync → hash Administrador → Pass-the-Hash → DA shell ✅
          T1003.006 + T1550.002
      │
      ▼
atackcorp\Administrador — Domain Admin — DC-01 comprometido 🏆
      │
      ▼
[Fase 11] Unconstrained Delegation (sql_svc) → TGT DC-01$ capturado
          Constrained Delegation (iis_svc) → S4U2Proxy como Administrador
          BloodHound CE → Attack paths mapeados
          T1558.001, T1187, T1003.006
      │
      ▼
[Fase 12] GPO Abuse (helpdesk.ruiz → IT-Baseline → SYSTEM en WKSTN-01)
          helpdesk.ruiz → Administradores locales WKSTN-01 ✅
          T1484.001, T1053.005
      │
      ▼
[Fase 13] ACL Abuse (fin.garcia → GenericWrite → sql_svc → Kerberoast → DA)
          SQLService2024! crackeada via Targeted Kerberoasting ✅
          T1222, T1558.003, T1110.002
```

---

## 🎯 Objetivos

| Objetivo | Estado |
|---------|--------|
| Acceso inicial al dominio | ✅ |
| Shell interactiva en DC-01 | ✅ |
| Domain Admin | ✅ |
| Volcado de hashes del dominio (DCSync) | ✅ |
| C2 activo en WKSTN-01 | ✅ |
| Escalada a SYSTEM (LPE) | ⚠️ Bloqueado por WinRM/Win11 |
| Golden Ticket persistencia | ⚠️ Bloqueado por PAC Validation WS2022 |
| Unconstrained Delegation (sql_svc) | ✅ |
| Constrained Delegation (iis_svc) | ✅ |
| BloodHound CE — attack paths | ✅ |
| GPO Abuse (helpdesk.ruiz → WKSTN-01) | ✅ |
| ACL Abuse (fin.garcia → sql_svc → DA) | ✅ |

---

## 🛠️ Técnicas MITRE ATT&CK

| Fase | Técnica | ID | Resultado |
|------|---------|-----|-----------|
| Recon | Network Service Discovery | T1046 | ✅ |
| Recon | Network Share Discovery | T1135 | ✅ |
| Credential Access | AS-REP Roasting | T1558.004 | ✅ |
| Credential Access | Password Cracking | T1110.002 | ✅ |
| Execution | WinRM | T1021.006 | ✅ |
| Discovery | Account Discovery | T1087.002 | ✅ |
| Discovery | Permission Groups Discovery | T1069.002 | ✅ |
| Discovery | Remote System Discovery | T1018 | ✅ |
| Credential Access | Kerberoasting | T1558.003 | ✅ |
| Lateral Movement | WinRM | T1021.006 | ✅ |
| C2 | HTTPS Protocol | T1071.001 | ✅ |
| C2 | Encrypted Channel | T1573.002 | ✅ |
| Defense Evasion | Impair Defenses | T1562.001 | ✅ |
| Privilege Escalation | Token Impersonation | T1134.001 | ⚠️ Parcial |
| Persistence | Golden Ticket | T1558.001 | ⚠️ Parcial |
| Credential Access | DCSync | T1003.006 | ✅ |
| Lateral Movement | Pass-the-Hash | T1550.002 | ✅ |
| Credential Access | Unconstrained Delegation | T1558.001 | ✅ |
| Credential Access | Forced Authentication (PetitPotam) | T1187 | ✅ |
| Credential Access | Constrained Delegation (S4U2Proxy) | T1558.001 | ✅ |
| Privilege Escalation | Group Policy Modification | T1484.001 | ✅ |
| Execution | Scheduled Task via GPO | T1053.005 | ✅ |
| Credential Access | ACL Abuse (GenericWrite→SPN) | T1222 | ✅ |
| Credential Access | Targeted Kerberoasting | T1558.003 | ✅ |

---

## 🔑 Credenciales Comprometidas

| Cuenta | Contraseña / Hash | Método | Privilegio |
|--------|------------------|--------|-----------|
| `ceo.martinez` | `Direccion2024!` | AS-REP Roasting | Usuario dominio |
| `backup_svc` | `Backup2024!` | AS-REP Roasting + Kerberoasting | **Domain Admin** |
| `krbtgt` | `d5237a2e43cb315c90679e2a5dae34ad` (NT) | DCSync | — |
| `Administrador` | `b73fdfe10e87b4ca5c0d957f81de6863` (NT) | DCSync | **Domain Admin** |
| `sql_svc` | `SQLService2024!` | Targeted Kerberoasting (fin.garcia GenericWrite) | Unconstrained Delegation |
| `helpdesk.ruiz` | `Helpdesk2024!` | GPO Abuse (admin local WKSTN-01) | Admin local WKSTN-01 |

---

## 🏗️ Entorno

| Host | SO | IP | Rol |
|------|----|----|-----|
| DC-01 | Windows Server 2022 Standard Evaluation | 10.0.2.10 | Domain Controller |
| WKSTN-01 | Windows 11 Enterprise Evaluation | 10.0.2.8 | Workstation |
| Kali | Kali Linux 2026.1 | 10.0.2.9 | Máquina atacante |

**Dominio:** `atackcorp.local` | **Red:** NAT Network `LabRedTeam` — `10.0.2.0/24`

---

## 📂 Documentación

| Documento | Descripción |
|-----------|-------------|
| [infrastructure_setup.md](docs/infrastructure_setup.md) | Entorno, vectores inyectados y script de setup |
| [enumeration_log.md](docs/enumeration_log.md) | Fase 1: Reconnaissance |
| [exploitation.md](docs/exploitation.md) | Fases 2-3: AS-REP Roasting + foothold |
| [post-exploitation.md](docs/post-exploitation.md) | Fases 4-5: Discovery + Kerberoasting → DA |
| [lateral_movement.md](docs/lateral_movement.md) | Fases 6-7: Lateral Movement + C2 Sliver |
| [privilege_escalation.md](docs/privilege_escalation.md) | Fase 8: LPE WKSTN-01 |
| [persistence.md](docs/persistence.md) | Fase 9: Golden Ticket |
| [objective_completion.md](docs/objective_completion.md) | Fase 10: DCSync + Pass-the-Hash |
| [mitigations.md](docs/mitigations.md) | Blue Team: detección, SIGMA rules, hardening |
| [delegation.md](docs/delegation.md) | Fase 11: Unconstrained + Constrained Delegation |
| [gpo_abuse.md](docs/gpo_abuse.md) | Fase 12: GPO Abuse via helpdesk.ruiz |
| [acl_abuse.md](docs/acl_abuse.md) | Fase 13: ACL Abuse + Targeted Kerberoasting |
| [bloodhound.md](docs/bloodhound.md) | BloodHound CE — metodología y attack paths |
| [lessons_learned.md](docs/lessons_learned.md) | 19 lecciones técnicas con causa raíz |

---

## 🧠 Lecciones Clave

1. **Diccionario dirigido > rockyou.txt** — Las contraseñas corporativas siguen patrones predecibles que no están en diccionarios genéricos. OSINT previo define el éxito del cracking.
2. **Token cacheado bloquea DCSync** — Los permisos AD aplican en el siguiente logon. Si se asignan con sesión activa hay que forzar re-autenticación.
3. **Potato attacks fallan en WinRM/Win11** — WinRM genera Network tokens incompatibles con Named Pipe Impersonation. Requieren sesión interactiva.
4. **Golden Ticket rechazado en WS2022** — PAC Validation reforzada en Windows Server 2022. Usar Diamond Ticket o Pass-the-Hash como alternativa.
5. **IP estática Kali via NetworkManager** — `ip addr add` no persiste. Usar `nmcli con add` para configuración permanente.

> 📄 Lecciones completas: [lessons_learned.md](docs/lessons_learned.md)

---

*Writeup por Adrián Camacho | [LinkedIn](https://www.linkedin.com/in/adrian-camacho-mora/) | [TryHackMe](https://tryhackme.com/p/sapodos)*