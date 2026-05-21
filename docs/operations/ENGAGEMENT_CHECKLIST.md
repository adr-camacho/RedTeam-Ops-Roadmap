# ENGAGEMENT_CHECKLIST.md — Red Team Ops Roadmap
## Checklist Operacional — Pre/Durante/Post Lab

**Versión:** 1.0 | **Fecha:** Mayo 2026 | **Autor:** Adrián Camacho

---

## ✅ CHECKLIST PRE-LAB

### Entorno y VMs

```
□ VirtualBox arrancado
□ Snapshot limpio creado (antes de cualquier cambio)
□ DC-01 encendida y esperando (verificar con ping 10.0.2.10)
□ WKSTN-01 encendida si aplica al lab
□ Kali arrancada y con conectividad: ping 10.0.2.10 && ping 8.8.8.8
□ eth0 con IP 10.0.2.9 (verificar: ip a show eth0)
□ eth2 con Internet (si aplica)
□ BloodHound CE arrancado: sudo bloodhound-start (si aplica al lab)
```

### Scripts de provisioning

```
□ Setup script ejecutado en DC-01 (Setup-LabXX-v2.x.ps1)
□ Crown Jewels script ejecutado (CrownJewels-LabXX-NombreLab.ps1)
□ Verificar conectividad: evil-winrm -i 10.0.2.10 -u Administrador -p 'NuevaPassword2026!'
```

### Arsenal Kali

```
□ Herramientas del lab disponibles (ver TOOL_INDEX.md)
□ Wordlists disponibles: /usr/share/wordlists/rockyou.txt
□ Directorio de loot preparado: mkdir -p ~/loot/lab-XX
□ Directorio de herramientas: ls /opt/redteam/
□ SharpHound disponible: ls /tmp/SharpHound/SharpHound.exe (verificar tamaño > 1MB)
```

### Documentación preparada

```
□ README del lab leído (objetivos, crown jewels)
□ tradecraft.md leído completamente
□ THREAT_MODEL.md consultado (contexto del adversario)
□ TOOL_INDEX.md consultado (herramientas para este lab)
□ OPERATION_XXX.md abierto para ir actualizando
□ Nomenclatura de capturas decidida (faseXX-YY-descripcion.png)
```

---

## ✅ CHECKLIST DURANTE LA EJECUCIÓN

### Por cada técnica ejecutada

```
□ ¿He considerado la alternativa más OPSEC antes de ejecutar?
□ ¿Sé qué logs genera este comando?
□ ¿He capturado el output relevante?
□ ¿He anotado la captura correctamente?
□ ¿He nombrado la captura según la nomenclatura?
□ ¿He documentado el comando exacto en el doc de ejecución?
```

### Gestión de credenciales obtenidas

```
□ Anotar inmediatamente en ~/loot/lab-XX/credentials.txt:
    formato: [hora] cuenta:contraseña/hash (método:técnica)
□ Verificar credencial inmediatamente tras obtenerla:
    nxc smb IP -u cuenta -p 'contraseña'
□ Guardar tickets .ccache con nombre descriptivo:
    administrador_tgt.ccache, sql_svc_tgs.ccache
```

### Artefactos creados (para limpieza posterior)

```
□ ¿He creado SPNs adicionales? Anotar para limpiar
□ ¿He modificado GPOs? Anotar para restaurar
□ ¿He creado tareas programadas? Anotar para eliminar
□ ¿He modificado ACLs? Anotar para revertir
□ ¿He subido binarios al objetivo? Anotar paths para eliminar
□ ¿He creado cuentas de máquina? Anotar para eliminar
□ ¿He modificado msDS-KeyCredentialLink? Anotar para limpiar
```

### Control de tiempo

```
□ Cada 2 horas: revisar si el progreso es coherente con el plan
□ Si algo lleva > 30 minutos bloqueado: consultar lessons_learned.md y tradecraft.md
□ Documentar tiempos de cada fase para PROGRESS.md
```

---

## ✅ CHECKLIST POST-EJECUCIÓN

### Limpieza de artefactos (OPSEC — simular comportamiento real)

```
□ Eliminar SPNs añadidos para Targeted Kerberoasting:
    bloodyAD set object cuenta servicePrincipalName -v "SPN_ORIGINAL"
□ Restaurar plantillas ADCS modificadas (ESC4):
    certipy template -u user -p pass -template NOMBRE -configuration backup.json
□ Eliminar tareas GPO añadidas:
    Remove-Item "\\DC\SYSVOL\...\ScheduledTasks.xml"
□ Eliminar binarios subidos al objetivo:
    Remove-Item C:\Temp\SharpHound.exe, C:\Temp\Rubeus.exe
□ Eliminar cuentas de máquina creadas para RBCD:
    impacket-addcomputer dom/user:pass -computer-name 'ATTACKER$' -delete
□ Limpiar historial de PowerShell en el objetivo:
    Clear-History; Remove-Item (Get-PSReadlineOption).HistorySavePath
□ Eliminar Shadow Credentials añadidas:
    certipy shadow remove -u user -p pass -account objetivo -device-id ID
□ Verificar que no quedan tickets en /tmp:
    ls /tmp/*.ccache → eliminar los del lab
```

### Documentación

```
□ post_exploitation.md actualizado con todas las fases
□ lessons_learned.md con mínimo 3 lecciones nuevas
□ mitigations.md con contramedidas específicas del lab
□ OPERATION_XXX.md con todas las fases marcadas ✅
□ MITRE_MAPPING.md con nuevas técnicas añadidas
□ OPSEC_NOTES.md con nuevos insights si los hay
□ PROGRESS.md con horas invertidas y sesiones
□ CHANGELOG.md con entrada del lab
```

### Capturas

```
□ Todas las capturas con nombre correcto (faseXX-YY-descripcion.png)
□ Todas las capturas con anotaciones visibles
□ Capturas en screenshots/ del lab correspondiente
□ Ninguna captura contiene información personal real
□ Capturas sensibles (hashes reales) protegidas si el repo es público
```

### VMs

```
□ Snapshot post-lab creado en VirtualBox
□ VMs apagadas correctamente (no suspendidas)
□ Estado de las VMs documentado en infrastructure.md si hubo cambios
```

### Commit

```
□ git status — verificar qué archivos cambiaron
□ git add . — añadir todos los cambios
□ git commit -m "feat: Lab-XX NOMBRE — [resumen]"
□ git push — subir al repositorio remoto
□ Verificar en GitHub que el push fue exitoso
```

---

## ✅ CHECKLIST PRE-EXAMEN CRTO

### Una semana antes

```
□ Revisar todos los tradecraft.md de Labs 01-13
□ Completar el checklist de habilidades CRTO (en Deep Water tradecraft)
□ Practicar la metodología completa sin guía en Lab-01
□ Verificar que conoces los comandos de memoria para:
    □ Configurar C2 listener y generar payload
    □ Kerberoasting y AS-REP Roasting
    □ Unconstrained/Constrained Delegation
    □ DCSync
    □ ADCS ESC1/ESC4
    □ BloodHound pathfinding
    □ Forest Trust ExtraSids
    □ AMSI bypass básico
```

### El día antes

```
□ Descanso completo — no estudiar en las últimas 12 horas
□ Entorno de examen verificado (conexión VPN a SnapLabs)
□ Cobalt Strike familiarización (diferencias vs Sliver)
□ Bloc de notas preparado para documentar durante el examen
□ Comida y agua disponibles
```

### Durante el examen (48h)

```
□ Empezar con reconocimiento completo (BloodHound primero)
□ No empezar a explotar antes de entender el entorno completo
□ Documentar TODO en tiempo real (no confiar en la memoria)
□ Descansar cada 4-6 horas (la fatiga genera errores)
□ Si llevas > 30 min bloqueado en algo → pasar a otro objetivo y volver
□ Capturas de evidencias para el reporte final
□ Guardar todos los hashes y tickets obtenidos
```

---

## Referencias rápidas

### Comandos de verificación de entorno

```bash
# Verificar conectividad básica
ping -c 1 10.0.2.10 && ping -c 1 8.8.8.8

# Verificar WinRM
evil-winrm -i 10.0.2.10 -u Administrador -p 'NuevaPassword2026!'

# Verificar BloodHound
curl -s http://localhost:8080 2>/dev/null | head -3

# Verificar SharpHound
ls -la /tmp/SharpHound/SharpHound.exe
```

### Reset de entorno si algo falla

```bash
# Restaurar snapshot limpio desde VirtualBox
# → Seleccionar VM → Snapshots → Restaurar snapshot pre-lab

# O desde línea de comandos
VBoxManage snapshot "DC-01" restore "pre-lab-XX"
VBoxManage startvm "DC-01" --type headless
```

---

*Red Team Ops Roadmap — Adrián Camacho | Mayo 2026*  
*Checklist operacional — Únicamente con fines educativos*