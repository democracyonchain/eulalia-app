<div align="center">
  <h1>Eulalia Mobile App</h1>
  <p><b>Digital Voter ID Solution</b></p>
</div>

<div align="center">
  <img src="https://img.shields.io/badge/built%20with-Flutter-blue.svg" alt="Built with Flutter">
  <img src="https://img.shields.io/badge/blockchain-Cardano-blue" alt="Cardano">
  <img src="https://img.shields.io/badge/ssi-Identus-indigo" alt="Identus">
</div>

---

### English Version
# Project Digital Voter ID: Eulalia App
**STATUS**: ACTIVE (Milestone 3)

### Table of Contents
1. [Actors](#actors)
2. [Project Phases](#project-phases)
3. [Objective](#objective)
4. [Functional Aspects](#functional-aspects)
5. [Technical Aspects](#technical-aspects)
6. [Installation Procedure](#installation-procedure)
7. [Other Documents](#other-documents)

## Actors
* **David Tacuri**

## Project Phases
- [x] Planning (H1)
- [x] Foundations & Governance (H2)
- [/] Architecture & Infrastructure (H3 - CURRENT)
- [ ] Proof of Concept - PoC (H4)
- [ ] Project Closure

### Objective:
Mobile application for citizens (Holders) to manage their Self-Sovereign Identity (SSI) and affiliate with political parties securely using the Cardano blockchain and Identus (Atala PRISM).

### Target Audience:
Citizens eligible for voting and political organizations.

## Functional Aspects
* **SSI Onboarding**: Decentralized identity creation through a 3-step secure process.
* **Master Key Management**: Generation of 12-word seed phrases for self-sovereignty.
* **Digital Wallet**: Secure storage and display of Decentralized Identifiers (DIDs) and Verifiable Credentials (VCs).
* **Blockchain Anchoring**: Simulation and real anchoring of identities on the Cardano network.

## Technical Aspects

### Technological Platform
| Feature               | Detail                                              |
|-----------------------|-----------------------------------------------------|
| Application Type      | Mobile Application (Flutter)                        |
| Development Framework | Flutter / Dart                                      |
| SSI Framework         | Atala Prism (Hyperledger Identus)                   |
| Blockchain Network    | Cardano (Preview Net)                               |
| State Management      | Custom UserSession Store                            |

### Prerequisites
* [Flutter SDK v3.x+](https://docs.flutter.dev/get-started/install)
* [Dart SDK](https://dart.dev/get-dart)
* Android Studio / Xcode for emulators and building.

## Installation
* Clone the repository:
```bash
git clone https://github.com/democracyonchain/eulalia-app.git
```
* Install dependencies:
```bash
flutter pub get
```
* Run the application:
```bash
flutter run
```

---

### Spanish Version
# Proyecto Digital Voter ID: Eulalia App
**ESTADO**: ACTIVO (Hito 3)

### Tabla de Contenidos
1. [Actores](#actores-es)
2. [Fases del Proyecto](#fases-es)
3. [Objetivo](#objetivo-es)
4. [Aspectos Funcionales](#aspectos-funcionales-es)
5. [Aspectos Técnicos](#aspectos-técnicos-es)
6. [Procedimiento de Instalación](#procedimiento-de-instalación-es)
7. [Otros Documentos](#otros-documentos-es)

<a name="actores-es"></a>
## Actores
* **David Tacuri**

<a name="fases-es"></a>
## Fases del Proyecto
- [x] Planificación (H1)
- [x] Cimientos y Gobernanza (H2)
- [/] Arquitectura e Infraestructura (H3 - ACTUAL)
- [ ] Prueba de Concepto - PoC (H4)
- [ ] Cierre del Proyecto

<a name="objetivo-es"></a>
### Objetivo:
Aplicación móvil para ciudadanos (Holders) que permite gestionar su Identidad Auto-Soberana (SSI) y afiliarse a organizaciones políticas de forma segura utilizando la blockchain de Cardano e Identus (Atala PRISM).

### A quién va dirigido:
Ciudadanos aptos para votar y organizaciones políticas.

<a name="aspectos-funcionales-es"></a>
## Aspectos Funcionales
* **Onboarding SSI**: Creación de identidad descentralizada mediante un proceso seguro de 3 pasos.
* **Gestión de Llave Maestra**: Generación de frases semilla de 12 palabras para la auto-soberanía.
* **Billetera Digital**: Almacenamiento y visualización segura de Identificadores Descentralizados (DIDs) y Credenciales Verificables (VCs).
* **Anclaje en Blockchain**: Simulación y anclaje real de identidades en la red Cardano.

<a name="aspectos-técnicos-es"></a>
## Aspectos Técnicos

### Plataforma Tecnológica
| Característica         | Detalle                                             |
|------------------------|-----------------------------------------------------|
| Tipo de Aplicación     | Aplicación Móvil (Flutter)                          |
| Framework Desarrollo   | Flutter / Dart                                      |
| Framework SSI          | Atala Prism (Hyperledger Identus)                   |
| Red Blockchain         | Cardano (Preview Net)                               |
| Gestión de Estado      | UserSession Store Personalizado                     |

### Prerrequisitos
* [Flutter SDK v3.x+](https://docs.flutter.dev/get-started/install)
* [Dart SDK](https://dart.dev/get-dart)
* Android Studio / Xcode para emuladores y compilación.

<a name="procedimiento-de-instalación-es"></a>
## Instalación
* Clonar el repositorio:
```bash
git clone https://github.com/democracyonchain/eulalia-app.git
```
* Instalar dependencias:
```bash
flutter pub get
```
* Ejecutar la aplicación:
```bash
flutter run
```

<a name="otros-documentos-es"></a>
## Otros Documentos
* [Plan de Hitos](.requirements/VoterId_Milestone.md)
* [Requerimientos de Software](.requirements/VoterId_Software_Requirements.md)
* [Reportes de Progreso](.reportsAgents/)
