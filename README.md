# 🚩 Red Team Ops & CRTO Preparation Path

![Status](https://img.shields.io/badge/Status-In%20Progress-orange)
![Category](https://img.shields.io/badge/Domain-Active%20Directory%20%7C%20Red%20Team-red)
![Frameworks](https://img.shields.io/badge/C2-Sliver%20%7C%20Havoc-blueviolet)

Este repositorio contiene la documentación técnica, diagramas de ataque y metodologías desarrolladas durante mi preparación para la certificación **CRTO (Certified Red Team Operator)**. El enfoque principal es la simulación de adversarios en entornos de **Active Directory** utilizando herramientas Open Source.

## 🎯 Objetivo
Dominar las tácticas de post-explotación, movimiento lateral y evasión de defensas. Aunque el CRTO utiliza Cobalt Strike, este roadmap se centra en replicar dichas capacidades mediante **C2 Frameworks modernos y abiertos**, profundizando en el funcionamiento interno de cada técnica.

---

## 🛠️ Stack Tecnológico (Focus: Open Source)
*   **C2 Frameworks:** Sliver (BishopFox), Havoc C2.
*   **Pivotaje Avanzado:** Ligolo-ng, Chisel.
*   **Enumeración de AD:** BloodHound, PowerView, Adalanche.
*   **Ataques de Kerberos:** Rubeus, Impacket, Kerbrute.
*   **Evasión:** AMSI/EDR Bypass, Obfuscation, In-memory execution.

---

## 🗺️ Roadmap de Operaciones (3x4)

### 🟢 Fase 1: Fundamentos y Pivotaje
*  [ ] **Lab 01: Attackitive Directory (THM)** - Enumeración de protocolos base y abuso de Kerberos.
*  [ ] **Lab 02: Wreath (THM)** - Pivotaje avanzado con Ligolo-ng y evasión de segmentación.
*  [ ] **Lab 03: Gatekeeper (THM)** - Explotación de servicios y desbordamiento de memoria.

### 🟡 Fase 2: Post-Explotación y Abuso de AD
*  [ ] **Lab 04: Forest (HTB)** - Abuso de permisos de objetos y escalada a Domain Admin.
*  [ ] **Lab 05: Monteverde (HTB)** - Enumeración de Azure AD y Cloud-to-Onpremise.
*  [ ] **Lab 06: Support (HTB)** - Análisis de volcados de memoria y extracción de secretos.

### 🔴 Fase 3: Red Team & Evasión de Defensas
*  [ ] **Lab 07: Red Team Pathway (THM)** - Gestión de infraestructuras C2 y evasión de EDR/AMSI.
*  [ ] **Lab 08: AD Enumeration & Attacks (HTB Academy)** - Maestría en BloodHound y Attack Paths.
*  [ ] **Lab 09: Holo (THM)** - Simulación completa de red corporativa e infiltración.

### 🏴 Fase 4: Simulación de Infraestructura Real (Pro Labs)
*  [ ] **Lab 10: Dante (HTB Pro Lab)** - Compromiso de red masiva mixta y persistencia.
*  [ ] **Lab 11: Offshore (HTB Pro Lab)** - Escenario espejo del examen CRTO.
*  [ ] **Lab 12: Zephyr (HTB Pro Lab)** - Técnicas modernas de Red Team y ataques a bosques (Trusts).

---

## 📂 Metodología de Documentación
Cada laboratorio se organiza en su propia carpeta con la siguiente estructura:
1. **Summary:** Resumen ejecutivo y vector de entrada.
2. **Attack Path:** Mapa visual del compromiso (BloodHound/Diagrams).
3. **Exploitation:** Comandos utilizados y razonamiento técnico.
4. **Detection:** Cómo detectar estas técnicas desde la perspectiva de un Blue Team.

---
📫 **Conecta conmigo:** [https://www.linkedin.com/in/adrian-camacho-mora/] | [https://tryhackme.com/p/sapodos]
