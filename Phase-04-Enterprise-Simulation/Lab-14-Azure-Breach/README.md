# 🔴 Lab-14: Azure Breach

![Status](https://img.shields.io/badge/Status-Pending-lightgrey)
![Phase](https://img.shields.io/badge/Phase-04-blue)
![Adversary](https://img.shields.io/badge/Adversary-APT10%20Stone%20Panda-darkred)

---

## 🎯 Resumen

| Campo | Detalle |
|-------|---------|
| **Nombre de operación** | AZURE BREACH |
| **Adversario simulado** | APT10 (Stone Panda) |
| **Técnicas principales** | Azure AD/Entra ID enumeration, PRT theft, token abuse, hybrid AD attacks |
| **Crown Jewels** | Azure Global Admin via comprometer cuenta sincronizada on-prem |
| **Estado** | ⏳ Pendiente |

---

## 📋 Técnicas planificadas

- Azure AD enumeration (AzureHound, ROADtools)
- Primary Refresh Token (PRT) theft
- Token abuse — acceso a recursos Azure sin contraseña
- Hybrid AD attacks — on-prem comprometido → cloud escalada
- Azure privilege escalation
- Conditional Access Policy bypass

---

## 🎯 Objetivo

Lab crítico para 2026 — el 90% de las empresas tienen Active Directory híbrido (on-prem + Azure AD/Entra ID). Un Red Teamer que no conoce los ataques cloud-híbridos está operando con un gap enorme.

**Posición en el roadmap:** Phase-04 — requiere dominar primero los ataques on-prem antes de abordar el vector cloud.

---

## 🏗️ Infraestructura planificada

| Componente | Detalle |
|-----------|---------|
| **Azure Tenant** | Tenant de prueba con Entra ID P2 |
| **Hybrid Join** | DC-01 sincronizado con Azure AD via Azure AD Connect |
| **Usuarios** | Cuentas sincronizadas on-prem → cloud |
| **Crown Jewel** | Cuenta Global Admin en Azure |

---

## 📂 Documentación

*Se generará al ejecutar el lab.*

---

*AZURE BREACH — Adrián Camacho*