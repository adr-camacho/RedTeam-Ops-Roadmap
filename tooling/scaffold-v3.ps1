<#
============================================================
 scaffold-v3.ps1 — Reestructura el repo al ROADMAP v3.0 (CRTO)
 Archiva labs 08+ del plan viejo y crea la estructura nueva 08-18.
 Uso:  .\scaffold-v3.ps1 -RepoRoot "C:\Users\sapod\Desktop\Red-Team_Labs"
 Reversible: lo viejo se MUEVE a _archive_pre_v3_<fecha>\, no se borra.
============================================================
#>
param([string]$RepoRoot = ".")
$ErrorActionPreference = "Stop"
$stamp   = Get-Date -Format "yyyyMMdd"
$archive = Join-Path $RepoRoot "_archive_pre_v3_$stamp"

$oldDirs = @(
  "Phase-03-Red-Team-Operations\Lab-08-Ghost-Signal",
  "Phase-03-Red-Team-Operations\Lab-09-First-Contact",
  "Phase-03-Red-Team-Operations\Lab-10-Dark-Current",
  "Phase-03-Red-Team-Operations\Lab-11-Deep-Holo",
  "Phase-04-Enterprise-Simulation\Lab-12-Red-Dante",
  "Phase-04-Enterprise-Simulation\Lab-13-Deep-Water",
  "Phase-04-Enterprise-Simulation\Lab-14-Azure-Breach",
  "Phase-04-Enterprise-Simulation\Lab-15-Operation-Zephyr"
)

$labs = @(
  [pscustomobject]@{Num="08";Name="Black-Beacon";Phase="Phase-03-Red-Team-Operations";Title="C2 Foundations";Block="C2 - CS Primer - listeners - beacons - staging - OPSEC";Obj="Construir el modelo operador de C2 (team server, listeners, gestion de beacons) y la equivalencia CS<->Sliver.";Prep="El examen se opera INTEGRAMENTE a traves del C2; este lab monta ese sistema nervioso.";Value="Sin dominar listeners, beacons, sleep/jitter y OPSEC basico, el resto del examen es inmanejable.";Evasion=$false}
  [pscustomobject]@{Num="09";Name="First-Contact";Phase="Phase-03-Red-Team-Operations";Title="Initial Access & Foothold";Block="External Recon - Initial Compromise - Host Recon";Obj="Obtener y estabilizar el primer beacon y leer el host (situational awareness) antes de actuar.";Prep="Aunque el examen es assumed-breach, controlar acceso inicial y recon de host evita quemar el foothold.";Value="Saber que mirar nada mas caer (privilegios, defensas, software) marca la primera hora del examen.";Evasion=$false}
  [pscustomobject]@{Num="10";Name="Deep-Root";Phase="Phase-03-Red-Team-Operations";Title="Host Persistence & PrivEsc";Block="Host Persistence - Host Privilege Escalation";Obj="Persistencia de host (run keys, servicios, tareas, COM) y escalada local (UAC, servicios, token).";Prep="Mantener acceso y elevar en un host: dos pasos obligados antes de tocar el dominio.";Value="Son chequeos constantes en el examen; elegir el mecanismo correcto sin generar ruido innecesario.";Evasion=$false}
  [pscustomobject]@{Num="11";Name="Ghost-Signal";Phase="Phase-03-Red-Team-Operations";Title="Evasion I - Defender/AMSI/ETW";Block="Windows Defender - AMSI - ETW - Artifact/Resource Kit (concepto)";Obj="Entender Defender/AMSI/ETW, firma vs comportamiento, y el modelo de los kits de Cobalt Strike.";Prep="Operar con Defender ACTIVO sin perder beacons: el corazon del examen.";Value="Entender POR QUE saltas separa aprobar de perder el beacon. El kit se practica en el curso; el porque, aqui.";Evasion=$true}
  [pscustomobject]@{Num="12";Name="Iron-Veil";Phase="Phase-03-Red-Team-Operations";Title="Evasion II - App Control";Block="AppLocker - Constrained Language Mode - LOLBAS";Obj="Ejecucion bajo whitelisting y CLM; rutas permitidas, LOLBAS y su deteccion.";Prep="El examen pone AppLocker; sin entender rutas y LOLBAS te quedas sin ejecucion.";Value="Reconocer que se puede ejecutar y desde donde es la diferencia entre avanzar o atascarte.";Evasion=$true}
  [pscustomobject]@{Num="13";Name="Linked-Shadows";Phase="Phase-04-Enterprise-Simulation";Title="MS SQL Server Attacks";Block="MSSQL enum - linked servers - xp_cmdshell - escalada/lateral";Obj="Enumerar y abusar de MSSQL: linked servers, ejecucion de comandos y movimiento lateral via SQL.";Prep="Una via de lateral/escalada que el examen incluye y mucha gente pasa por alto.";Value="Los linked servers son un camino barato a otro dominio; tenerlo fluido suma objetivos. (Requiere VM SQL Server.)";Evasion=$false}
  [pscustomobject]@{Num="14";Name="Golden-Throne";Phase="Phase-04-Enterprise-Simulation";Title="Domain Dominance & Persistence";Block="Golden/Silver/Diamond tickets - forged certs - DSRM - AdminSDHolder";Obj="Dominio total y persistencia que sobrevive a resets de credenciales.";Prep="Cierre de la fase de dominio y persistencia robusta.";Value="Saber que variante de ticket usar segun objetivo y ruido, y como se detecta cada una.";Evasion=$false}
  [pscustomobject]@{Num="15";Name="Forest-Reign";Phase="Phase-04-Enterprise-Simulation";Title="Forest & Trust Abuse";Block="cross-forest - SID history - trusts inbound/outbound - SID filtering";Obj="Saltar entre dominios y forests abusando de trusts.";Prep="El examen es multi-forest; este es el nucleo de los flags dificiles.";Value="Las cadenas de trust dan la nota alta; aprovecha los trusts ya montados en tu lab.";Evasion=$false}
  [pscustomobject]@{Num="16";Name="Custom-Arsenal";Phase="Phase-04-Enterprise-Simulation";Title="Extending the C2";Block="BOFs - Malleable C2 - Aggressor";Obj="Adaptar el C2 a OPSEC (perfiles Malleable) y automatizar tasking (Aggressor); concepto de BOFs.";Prep="Reducir footprint y operar mas sigiloso, tal y como exige el examen con Defender ON.";Value="Diseno y uso aqui; el codigo de BOFs/Aggressor se practica en el lab del curso.";Evasion=$true}
  [pscustomobject]@{Num="17";Name="Silent-Exit";Phase="Phase-04-Enterprise-Simulation";Title="Exfiltration & Reporting";Block="data hunting - staging - exfil - reporte/OPSEC";Obj="Localizar el valor, sacarlo y cerrar el engagement con un reporte profesional.";Prep="El objetivo del examen suele ser data; encontrarla y documentarla es el cierre.";Value="Consolida la mentalidad de engagement real, no solo de captura de flags.";Evasion=$false}
  [pscustomobject]@{Num="18";Name="Final-Verdict";Phase="Phase-04-Enterprise-Simulation";Title="Capstone - Exam Simulation";Block="cadena completa - Defender ON - multi-dominio - por objetivos";Obj="Simulacion de examen de extremo a extremo en condiciones reales.";Prep="El ensayo general del examen.";Value="Mide cobertura, velocidad y OPSEC bajo presion; revela huecos antes del dia real.";Evasion=$false}
)

$subdirs = @("docs\theory","docs\detection","docs\execution","docs\analysis","docs\report","loot","nmap","screenshots","setup")
$keep    = @("loot","nmap","screenshots","docs\theory","docs\detection","docs\execution","docs\analysis","docs\report")

Write-Host "==> Repo: $RepoRoot"
Write-Host "==> [1/2] Archivando estructura vieja (08+) en: $archive" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $archive | Out-Null
foreach ($d in $oldDirs) {
  $src = Join-Path $RepoRoot $d
  if (Test-Path $src) {
    $dst = Join-Path $archive $d
    New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
    Move-Item -Path $src -Destination $dst
    Write-Host "    [archivado] $d" -ForegroundColor DarkGray
  }
}

Write-Host "==> [2/2] Creando estructura nueva 08-18" -ForegroundColor Cyan
foreach ($lab in $labs) {
  $labdir = Join-Path $RepoRoot (Join-Path $lab.Phase ("Lab-{0}-{1}" -f $lab.Num, $lab.Name))
  foreach ($s in $subdirs) { New-Item -ItemType Directory -Force -Path (Join-Path $labdir $s) | Out-Null }
  foreach ($k in $keep)    { New-Item -ItemType File -Force -Path (Join-Path $labdir (Join-Path $k ".gitkeep")) | Out-Null }

  $eva = ""
  if ($lab.Evasion) {
$eva = @"

## Regla de construccion
Teoria, deteccion, operativa y documentacion se construyen en este repo.
El **codigo armado de evasion** (bypass / loader / kit / BOF) **NO** vive en el repo: se practica en el laboratorio oficial CRTO con sus kits. Aqui documentamos el *por que* y el *como se detecta*.
"@
  }

$readme = @"
# Lab-$($lab.Num) - $($lab.Name) - $($lab.Title)

> Fase: ``$($lab.Phase)`` - Estado: Pendiente - Roadmap: [``docs/design/ROADMAP.md``](../../docs/design/ROADMAP.md)

## Objetivo
$($lab.Obj)

## Que cubre (temario CRTO)
$($lab.Block)

## Que prepara
$($lab.Prep)

## Valor didactico en el examen
$($lab.Value)
$eva
## Estructura
``docs/theory`` - ``docs/detection`` - ``docs/execution`` - ``docs/analysis`` - ``docs/report`` - ``loot`` - ``nmap`` - ``screenshots`` - ``setup``
"@
  Set-Content -Path (Join-Path $labdir "README.md") -Value $readme -Encoding UTF8
  Write-Host ("    [creado] {0}\Lab-{1}-{2}" -f $lab.Phase, $lab.Num, $lab.Name) -ForegroundColor Green
}

Write-Host "==> Hecho. Estructura v3.0 lista. Lo viejo esta en $archive (borralo cuando confirmes)." -ForegroundColor Yellow
