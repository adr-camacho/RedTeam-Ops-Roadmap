# Lab 02: Wreath (TryHackMe)

## 📝 Resumen Ejecutivo
Este laboratorio se centra en el compromiso de una red corporativa segmentada. El reto principal radica en la necesidad de realizar **Pivoting** avanzado para alcanzar objetivos que no tienen visibilidad directa desde la máquina del atacante.

## 🛰️ Fases del Ataque

### 1. Compromiso Inicial (Explotación Web)
* **Vector:** Explotación de vulnerabilidad en servicio orientado a internet (ej. MiniServ/Webmin).
* **Acceso:** Obtención de shell reversa y escalada local para ganar persistencia.

### 2. Pivotaje Avanzado (Técnica Maestra)
* **Herramienta:** **Ligolo-ng**.
* **Configuración:** * Creación de interfaz `tun0` en el host atacante.
    * Ejecución del `agent` en el equipo comprometido (pivote).
    * Establecimiento de rutas estáticas para tunelizar el tráfico hacia la red interna.
* **Ventaja:** Permite realizar escaneos de `nmap` y uso de herramientas como si estuviéramos conectados físicamente a la red interna.

### 3. Enumeración y Movimiento Lateral
* **Hallazgo:** Identificación de una máquina Windows secundaria mediante el túnel de Ligolo.
* **Técnica:** Explotación de servicios internos y extracción de hashes.

---

## 🛡️ Detección y Mitigación (Blue Team Notes)
1. **Detección:** Monitorizar la creación de interfaces de red inusuales (TUN/TAP) en servidores.
2. **Mitigación:** Implementar el principio de mínimo privilegio en comunicaciones entre segmentos de red (Micro-segmentación).
3. **Anomalías:** Analizar tráfico saliente hacia puertos no estándar que podrían indicar conexiones de C2 o agentes de pivotaje.

---
**Attack Path Visual:**
`Initial Access` ➔ `Ligolo-ng Tunnel` ➔ `Internal Network Scan` ➔ `Lateral Movement`