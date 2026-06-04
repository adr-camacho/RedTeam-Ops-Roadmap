# 📋 Rules of Engagement — Red Team Ops Roadmap
## Documento de Autorización y Alcance Operacional

**Clasificación:** Confidencial — Uso educativo  
**Versión:** 1.0 | **Fecha:** Junio 2026  
**Operador:** Adrián Camacho  
**Organización objetivo (ficticia):** ATACKCORP S.L.  
**Framework:** MITRE ATT&CK v14 Enterprise

> ⚠️ Este documento es ficticio y de uso exclusivamente educativo.  
> Simula el documento de Rules of Engagement que se firmaría con un cliente real antes de un engagement de Red Team.

---

## 1. Autorización

| Campo | Detalle |
|-------|---------|
| **Operador autorizado** | Adrián Camacho |
| **Organización objetivo** | ATACKCORP S.L. (entorno ficticio de laboratorio) |
| **Tipo de ejercicio** | Red Team — Adversary Emulation |
| **Adversarios simulados** | APT29, APT41, APT28, Lazarus Group, APT10 |
| **Fecha de inicio** | 11/05/2026 |
| **Fecha de finalización estimada** | Diciembre 2026 |
| **Entorno** | 100% laboratorio local — VirtualBox — sin conexión a sistemas reales |

**Declaración de autorización:**

Este documento autoriza la ejecución de técnicas ofensivas de Red Team contra el entorno de laboratorio `atackcorp.local` y dominios asociados (`corp.local`, `ext.local`, `child.atackcorp.local`) con fines exclusivamente educativos y de preparación para la certificación CRTO. Ninguna de las técnicas documentadas debe ejecutarse contra sistemas reales sin autorización explícita por escrito del propietario.

---

## 2. Alcance — Sistemas en Scope

### Infraestructura autorizada

| Host | IP | Sistema | Dominio | Autorizado |
|------|----|---------|---------|------------|
| DC-01 | 10.0.2.10 | Windows Server 2022 | atackcorp.local | ✅ |
| DC-02 | 10.0.2.11 | Windows Server 2022 | corp.local | ✅ |
| DC-03 | 10.0.2.13 | Windows Server 2022 | child.atackcorp.local | ✅ |
| DC-04 | 10.0.2.14 | Windows Server 2022 | ext.local | ✅ |
| WKSTN-01 | 10.0.2.8 | Windows 11 | atackcorp.local | ✅ |
| WKSTN-02 | 10.0.2.12 | Windows 11 | corp.local | ✅ |
| PROD | 10.0.3.10 | Ubuntu 22.04 | — | ✅ (Lab-02) |
| GIT | 10.0.3.11 | Ubuntu 22.04 | — | ✅ (Lab-02) |
| PC-01 | 10.0.3.20 | Windows 11 | — | ✅ (Lab-02) |
| Kali | 10.0.2.9 | Kali Linux | — | Atacante |

### Fuera de scope — Prohibido

| Sistema | Razón |
|---------|-------|
| Cualquier sistema fuera de 10.0.2.0/24 y 10.0.3.0/24 | No autorizado |
| Infraestructura del host físico (hypervisor) | Fuera del entorno de lab |
| Sistemas de producción reales | Prohibido absolutamente |
| Redes de otros usuarios o clientes | Prohibido absolutamente |

---

## 3. Técnicas Autorizadas por Fase

### Phase-01 — Fundamentos AD

| Técnica | Herramienta | Autorizado |
|---------|-------------|------------|
| Network scanning | Nmap | ✅ |
| LDAP/SMB enumeration | ldapsearch, enum4linux-ng | ✅ |
| AS-REP Roasting | impacket-GetNPUsers | ✅ |
| Kerberoasting | impacket-GetUserSPNs | ✅ |
| Password cracking offline | John the Ripper | ✅ |
| WinRM shell | Evil-WinRM | ✅ |
| DCSync | impacket-secretsdump | ✅ |
| Golden/Silver/Diamond Ticket | Rubeus, impacket | ✅ |
| ADCS ESC1/ESC4/ESC8 | Certipy | ✅ |
| Sliver C2 beacon | Sliver v1.7.3 | ✅ |
| Pivoting Ligolo-ng | Ligolo-ng v0.7.5 | ✅ |

### Phase-02 — AD Avanzado

| Técnica | Herramienta | Autorizado |
|---------|-------------|------------|
| BloodHound CE enumeration | SharpHound v2.5.9 | ✅ |
| WriteDACL → DCSync | impacket-dacledit | ✅ |
| ADIDNS/WPAD poisoning | dnstool + Responder | ✅ |
| RBCD + S4U2Proxy | impacket-addcomputer | ✅ |
| Shadow Credentials | pywhisker | ✅ |
| SID History Injection | DSInternals v4.14 | ✅ |
| Cross-Forest Kerberoasting | impacket-GetUserSPNs | ✅ |
| GPO Abuse | pyGPOAbuse | ✅ |
| Forest Trust Abuse | bloodyAD, smbclient | ✅ |
| LAPS password extraction | nxc, AdmPwd.PS | ✅ |
| DPAPI credential extraction | SharpDPAPI | ✅ |

### Phase-03 — Red Team Operations

| Técnica | Herramienta | Autorizado |
|---------|-------------|------------|
| AMSI bypass in-memory | Custom scripts | ✅ |
| Process injection | Custom shellcode | ✅ |
| Direct syscalls | Custom loader | ✅ |
| Havoc C2 | Havoc | ✅ |
| Password spraying | Kerbrute | ✅ |
| HTML Smuggling | Custom HTML | ✅ |
| PE evasion | Custom packer | ✅ |

### Técnicas PROHIBIDAS en cualquier fase

| Técnica | Razón |
|---------|-------|
| Ransomware o cifrado de datos | Destrucción del entorno |
| Exfiltración fuera del lab | Salida de datos del entorno controlado |
| Ataques DoS/DDoS | Destrucción del entorno |
| Modificación permanente del hypervisor | Fuera del scope |
| Publicación de credenciales reales | Prohibido absolutamente |

---

## 4. Horario de Operaciones

| Campo | Detalle |
|-------|---------|
| **Horario autorizado** | Sin restricción — entorno local personal |
| **Mantenimiento programado** | No aplica |
| **Ventana de pausa** | A discreción del operador |

---

## 5. Procedimientos Operacionales

> 📋 Los procedimientos operacionales detallados — checklists pre/durante/post lab, limpieza de artefactos, gestión de credenciales y preparación para el examen CRTO — están documentados en:  
> **[ENGAGEMENT_CHECKLIST.md](ENGAGEMENT_CHECKLIST.md)**

Resumen del flujo operacional:

```
1. lab_start.sh XX  →  verificar entorno
2. Ejecutar CrownJewels  →  preparar escenario
3. Ejecutar fases  →  documentar en tiempo real
4. OPSEC cleanup  →  eliminar artefactos
5. Commit  →  push con mensaje descriptivo
```

---

## 6. Manejo de Loot y Datos Sensibles

| Tipo de dato | Tratamiento |
|-------------|-------------|
| Hashes NTLM | Solo en `loot/` — nunca en docs públicos sin redactar |
| Contraseñas en texto claro | Solo en `loot/` y `CREDENTIALS.md` (repo privado) |
| Tickets Kerberos (.ccache) | Solo en `loot/` — no commitear sin `.gitignore` |
| Screenshots | Anonimizar datos personales si los hubiera |
| Datos RGPD ficticios | Marcados como ficticios en el archivo |

> **Nota:** Este repositorio es público. Los hashes y contraseñas del entorno son ficticios y pertenecen a VMs de laboratorio sin valor fuera del entorno controlado.

---

## 7. Exclusiones y Restricciones Técnicas

### No modificar sin justificación documentada

- Scripts de provisioning (`setup/provisioning/`) — solo modificar para corregir bugs documentados
- CrownJewels ya ejecutados — no re-ejecutar sin snapshot previo
- Forest Trusts — no modificar la topología entre labs
- Credenciales de los scripts de provisioning — no cambiar sin actualizar `CREDENTIALS.md`

### Restricciones de herramientas

- **John the Ripper** sobre Hashcat — por limitaciones GPU en VirtualBox
- **Sliver** como C2 principal — Havoc reservado para Phase-03
- **pyGPOAbuse** sobre XML manual — Windows 11 no procesa GPP correctamente
- **DSInternals** sobre mimikatz — `misc::addsid` eliminado en v2.2.0+

---

## 8. Clasificación de la Información

| Documento | Clasificación |
|-----------|--------------|
| Este documento (ROE) | Educativo — público |
| `CREDENTIALS.md` | Sensible — solo entorno lab |
| `loot/*.ntds` | Sensible — solo entorno lab |
| Docs de ejecución | Educativo — público |
| Screenshots | Educativo — público |

---

## 9. Contactos de Emergencia (ficticios)

| Rol | Contacto ficticio |
|-----|------------------|
| CISO ATACKCORP | ciso@atackcorp.local |
| Red Team Lead | redteam@atackcorp.local |
| Operador | Adrián Camacho — [LinkedIn](https://www.linkedin.com/in/adrian-camacho-mora/) |

---

## 10. Control de Versiones

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0 | Junio 2026 | Versión inicial — Labs 01-07 (sección 5 referencia ENGAGEMENT_CHECKLIST) |

---

*Rules of Engagement — Red Team Ops Roadmap*  
*Adrián Camacho | APT29 · APT41 · APT28 · Lazarus · APT10*  
*Entorno 100% ficticio — Uso exclusivamente educativo*