#!/usr/bin/env bash
# ============================================================
# scaffold-v3.sh — Reestructura el repo al ROADMAP v3.0 (CRTO)
# Archiva labs 08+ del plan viejo y crea la estructura nueva 08-18.
# Uso:  ./scaffold-v3.sh [RUTA_REPO]   (por defecto: directorio actual)
# Reversible: lo viejo se MUEVE a _archive_pre_v3_<fecha>/, no se borra.
# ============================================================
set -euo pipefail
REPO="${1:-.}"
STAMP="$(date +%Y%m%d)"
ARCHIVE="$REPO/_archive_pre_v3_$STAMP"

OLD_DIRS=(
  "Phase-03-Red-Team-Operations/Lab-08-Ghost-Signal"
  "Phase-03-Red-Team-Operations/Lab-09-First-Contact"
  "Phase-03-Red-Team-Operations/Lab-10-Dark-Current"
  "Phase-03-Red-Team-Operations/Lab-11-Deep-Holo"
  "Phase-04-Enterprise-Simulation/Lab-12-Red-Dante"
  "Phase-04-Enterprise-Simulation/Lab-13-Deep-Water"
  "Phase-04-Enterprise-Simulation/Lab-14-Azure-Breach"
  "Phase-04-Enterprise-Simulation/Lab-15-Operation-Zephyr"
)

# Metadatos: NUM|NAME|PHASE|TITLE|BLOCK|OBJ|PREP|VALUE|EVASION(0/1)
LABS=(
"08|Black-Beacon|Phase-03-Red-Team-Operations|C2 Foundations|C2 · CS Primer · listeners · beacons · staging · OPSEC|Construir el modelo operador de C2 (team server, listeners, gestion de beacons) y la equivalencia CS<->Sliver.|El examen se opera INTEGRAMENTE a traves del C2; este lab monta ese sistema nervioso.|Sin dominar listeners, beacons, sleep/jitter y OPSEC basico, el resto del examen es inmanejable.|0"
"09|First-Contact|Phase-03-Red-Team-Operations|Initial Access & Foothold|External Recon · Initial Compromise · Host Recon|Obtener y estabilizar el primer beacon y leer el host (situational awareness) antes de actuar.|Aunque el examen es assumed-breach, controlar acceso inicial y recon de host evita quemar el foothold.|Saber que mirar nada mas caer (privilegios, defensas, software) marca la primera hora del examen.|0"
"10|Deep-Root|Phase-03-Red-Team-Operations|Host Persistence & PrivEsc|Host Persistence · Host Privilege Escalation|Persistencia de host (run keys, servicios, tareas, COM) y escalada local (UAC, servicios, token).|Mantener acceso y elevar en un host: dos pasos obligados antes de tocar el dominio.|Son chequeos constantes en el examen; elegir el mecanismo correcto sin generar ruido innecesario.|0"
"11|Ghost-Signal|Phase-03-Red-Team-Operations|Evasion I - Defender/AMSI/ETW|Windows Defender · AMSI · ETW · Artifact/Resource Kit (concepto)|Entender Defender/AMSI/ETW, firma vs comportamiento, y el modelo de los kits de Cobalt Strike.|Operar con Defender ACTIVO sin perder beacons: el corazon del examen.|Entender POR QUE saltas separa aprobar de perder el beacon. El kit se practica en el curso; el porque, aqui.|1"
"12|Iron-Veil|Phase-03-Red-Team-Operations|Evasion II - App Control|AppLocker · Constrained Language Mode · LOLBAS|Ejecucion bajo whitelisting y CLM; rutas permitidas, LOLBAS y su deteccion.|El examen pone AppLocker; sin entender rutas y LOLBAS te quedas sin ejecucion.|Reconocer que se puede ejecutar y desde donde es la diferencia entre avanzar o atascarte.|1"
"13|Linked-Shadows|Phase-04-Enterprise-Simulation|MS SQL Server Attacks|MSSQL enum · linked servers · xp_cmdshell · escalada/lateral|Enumerar y abusar de MSSQL: linked servers, ejecucion de comandos y movimiento lateral via SQL.|Una via de lateral/escalada que el examen incluye y mucha gente pasa por alto.|Los linked servers son un camino barato a otro dominio; tenerlo fluido suma objetivos. (Requiere VM SQL Server.)|0"
"14|Golden-Throne|Phase-04-Enterprise-Simulation|Domain Dominance & Persistence|Golden/Silver/Diamond tickets · forged certs · DSRM · AdminSDHolder|Dominio total y persistencia que sobrevive a resets de credenciales.|Cierre de la fase de dominio y persistencia robusta.|Saber que variante de ticket usar segun objetivo y ruido, y como se detecta cada una.|0"
"15|Forest-Reign|Phase-04-Enterprise-Simulation|Forest & Trust Abuse|cross-forest · SID history · trusts inbound/outbound · SID filtering|Saltar entre dominios y forests abusando de trusts.|El examen es multi-forest; este es el nucleo de los flags dificiles.|Las cadenas de trust dan la nota alta; aprovecha los trusts ya montados en tu lab.|0"
"16|Custom-Arsenal|Phase-04-Enterprise-Simulation|Extending the C2|BOFs · Malleable C2 · Aggressor|Adaptar el C2 a OPSEC (perfiles Malleable) y automatizar tasking (Aggressor); concepto de BOFs.|Reducir footprint y operar mas sigiloso, tal y como exige el examen con Defender ON.|Diseno y uso aqui; el codigo de BOFs/Aggressor se practica en el lab del curso.|1"
"17|Silent-Exit|Phase-04-Enterprise-Simulation|Exfiltration & Reporting|data hunting · staging · exfil · reporte/OPSEC|Localizar el valor, sacarlo y cerrar el engagement con un reporte profesional.|El objetivo del examen suele ser data; encontrarla y documentarla es el cierre.|Consolida la mentalidad de engagement real, no solo de captura de flags.|0"
"18|Final-Verdict|Phase-04-Enterprise-Simulation|Capstone - Exam Simulation|cadena completa · Defender ON · multi-dominio · por objetivos|Simulacion de examen de extremo a extremo en condiciones reales.|El ensayo general del examen.|Mide cobertura, velocidad y OPSEC bajo presion; revela huecos antes del dia real.|0"
)

SUBDIRS=(docs/theory docs/detection docs/execution docs/analysis docs/report loot nmap screenshots setup)

echo "==> Repo: $REPO"
echo "==> [1/2] Archivando estructura vieja (08+) en: $ARCHIVE"
mkdir -p "$ARCHIVE"
for d in "${OLD_DIRS[@]}"; do
  if [ -d "$REPO/$d" ]; then
    mkdir -p "$ARCHIVE/$(dirname "$d")"
    mv "$REPO/$d" "$ARCHIVE/$d"
    echo "    [archivado] $d"
  fi
done

echo "==> [2/2] Creando estructura nueva 08-18"
for row in "${LABS[@]}"; do
  IFS='|' read -r NUM NAME PHASE TITLE BLOCK OBJ PREP VALUE EVA <<< "$row"
  LABDIR="$REPO/$PHASE/Lab-$NUM-$NAME"
  for s in "${SUBDIRS[@]}"; do mkdir -p "$LABDIR/$s"; done
  for k in loot nmap screenshots; do touch "$LABDIR/$k/.gitkeep"; done
  for s in docs/theory docs/detection docs/execution docs/analysis docs/report; do touch "$LABDIR/$s/.gitkeep"; done

  EVA_BLOCK=""
  if [ "$EVA" = "1" ]; then
    EVA_BLOCK=$'\n## 🔧 Regla de construccion\nTeoria, deteccion, operativa y documentacion se construyen en este repo.\nEl **codigo armado de evasion** (bypass / loader / kit / BOF) **NO** vive en el repo: se practica en el laboratorio oficial CRTO con sus kits. Aqui documentamos el *por que* y el *como se detecta*.\n'
  fi

  cat > "$LABDIR/README.md" << EOF
# Lab-$NUM · $NAME — $TITLE

> Fase: \`$PHASE\` · Estado: ⏳ Pendiente · Roadmap: [\`docs/design/ROADMAP.md\`](../../docs/design/ROADMAP.md)

## 🎯 Objetivo
$OBJ

## 📚 Que cubre (temario CRTO)
$BLOCK

## 🎓 Que prepara
$PREP

## 💡 Valor didactico en el examen
$VALUE
$EVA_BLOCK
## 🗂️ Estructura
\`docs/theory\` · \`docs/detection\` · \`docs/execution\` · \`docs/analysis\` · \`docs/report\` · \`loot\` · \`nmap\` · \`screenshots\` · \`setup\`
EOF
  echo "    [creado] $PHASE/Lab-$NUM-$NAME"
done

echo "==> Hecho. Estructura v3.0 lista. Lo viejo esta en $ARCHIVE (borralo cuando confirmes)."
