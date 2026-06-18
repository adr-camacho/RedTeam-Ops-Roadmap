# 📖 GLOSSARY.md — Glosario técnico

> Definiciones concisas de la terminología usada en el repo. Pensado como referencia rápida y para
> homogeneizar el vocabulario entre labs. Términos técnicos en inglés, definición en español.
>
> Ubicación: `docs/reference/GLOSSARY.md` · Fecha: 18/06/2026

---

## 🛰️ C2 y operativa

- **C2 (Command & Control):** infraestructura desde la que el operador controla los hosts comprometidos.
- **Beacon / implant:** agente que corre en la víctima y se comunica con el C2 (en este repo, Sliver).
- **Listener:** servicio del C2 que recibe las conexiones de los beacons (HTTP/S, SMB, TCP…).
- **Staged vs stageless:** payload en dos fases (descarga el cuerpo) vs payload completo de una pieza.
- **Sleep / jitter:** intervalo de espera del beacon y su aleatorización, para reducir patrón de baliza.
- **Malleable C2:** perfil que modela el tráfico del C2 para imitar tráfico legítimo (OPSEC).
- **BOF (Beacon Object File):** módulo que se ejecuta en memoria dentro del beacon, sin proceso nuevo.
- **Aggressor:** lenguaje de scripting de Cobalt Strike para automatizar tareas del operador.
- **OPSEC:** disciplina de operar minimizando la huella y la telemetría generada.

## 🏰 Active Directory y Kerberos

- **TGT / TGS:** ticket de concesión de tickets / ticket de servicio en Kerberos.
- **AS-REP Roasting:** abuso de cuentas sin preautenticación para obtener hashes crackeables.
- **Kerberoasting:** solicitud de TGS de cuentas con SPN para crackear su contraseña offline.
- **Targeted Kerberoasting:** forzar un SPN sobre una cuenta (vía GenericWrite/All) para kerberoastearla.
- **DCSync:** simular un DC para replicar credenciales del dominio (incl. krbtgt).
- **Pass-the-Hash / -Ticket / Overpass-the-Hash:** autenticación reutilizando hash NTLM, ticket Kerberos
  o hash→TGT, sin conocer la contraseña en claro.
- **Golden / Silver / Diamond Ticket:** tickets Kerberos forjados (con krbtgt, con clave de servicio, o
  modificando un TGT real) para persistencia/impersonación.
- **Delegación (Unconstrained / Constrained / RBCD):** mecanismos de delegación Kerberos abusables;
  **S4U2Self / S4U2Proxy** son las extensiones que permiten impersonar usuarios.
- **SID History:** atributo que arrastra SIDs de otro dominio; su inyección permite escalada cross-domain.
- **BloodHound / SharpHound:** recolección y análisis de rutas de ataque en AD.
- **ACL / DACL · WriteDACL / GenericAll / GenericWrite:** permisos sobre objetos AD cuyo abuso habilita
  escaladas (p. ej. concederse DCSync o resetear credenciales).

## 🔐 ADCS y certificados

- **ADCS:** servicios de certificados de Active Directory.
- **ESC1 / ESC4 / ESC8:** configuraciones vulnerables de plantillas/endpoints de ADCS (SAN arbitrario,
  plantilla modificable, relay a Web Enrollment).
- **Shadow Credentials:** abuso de `msDS-KeyCredentialLink` para autenticarse como el objeto víctima.
- **PKINIT:** autenticación Kerberos basada en certificado.

## 🗝️ Credenciales y secretos

- **LSASS:** proceso que custodia credenciales en memoria.
- **SAM:** base de credenciales locales del host.
- **LAPS:** solución de Microsoft que rota la contraseña de administrador local por host.
- **DPAPI:** API de Windows para proteger secretos de usuario/máquina (extraíbles offline con la clave).
- **Hash NTLM · ccache / kirbi:** representaciones de credencial/ticket usadas en ataques pass-the-*.

## 🛡️ Evasión y detección (conceptos)

- **AMSI:** interfaz de Windows que permite a las defensas inspeccionar contenido en tiempo de ejecución.
- **ETW:** telemetría de eventos de Windows usada por EDR para detección por comportamiento.
- **AppLocker / CLM:** control de aplicaciones permitidas / modo de lenguaje restringido de PowerShell.
- **LOLBAS:** binarios/firmados legítimos del sistema reutilizables para ejecución ("living off the land").
- **Artifact Kit / Resource Kit:** componentes de Cobalt Strike para modelar artefactos y plantillas.
- **PPL / KPP:** protección de procesos (p. ej. LSASS) y protección del kernel que limitan el acceso.
- **Sysmon / Event ID / SIGMA:** fuentes y formato estándar de telemetría y reglas de detección.

## 🌐 Red y movimiento

- **Pivoting / SOCKS / reverse port forward:** técnicas para enrutar tráfico a través de un host pivote.
- **Ligolo-ng:** herramienta de tunelado usada en el repo para pivotaje.
- **NTLM relay / coerción (PetitPotam):** retransmisión de autenticación NTLM y técnicas para forzarla.

## 🗄️ MS SQL

- **Linked server:** enlace entre instancias SQL que permite saltar de una a otra (y de un dominio a otro).
- **xp_cmdshell:** procedimiento que ejecuta comandos del SO desde SQL Server (si está habilitado).

---

*Glosario · 18/06/2026 · Ampliable a medida que avanzan los labs 08–18*