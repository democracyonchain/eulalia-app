<div align="center">
  <a href="https://flutter.dev/" target="_blank">
    <img src="https://storage.googleapis.com/cms-storage-bucket/flutter-logo.6a07d8a62f4308d2b854.svg" width="200" alt="Flutter Logo" />
  </a> 
</div>
<div align="center"> 
  <a href="https://flutter.dev/" target="_blank">
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter Version">
  </a>
  <a href="https://dart.dev/" target="_blank">
    <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart Version">
  </a>
  <img src="https://img.shields.io/badge/Architecture-Clean-blue" alt="Clean Architecture">
</div>

# Eulalia Mobile App - VoterID
**STATUS**: ACTIVE (Architecture & Infrastructure)

---

## (EN) English Version

### Decentralized Identity & Voting Mobile App

Eulalia is the core mobile interface of the **VoterID System**, empowering citizens with **Self-Sovereign Identity (SSI)**. It provides a secure digital wallet for managing identity credentials and facilitating political participation with absolute transparency.

### Table of Contents
1. [Actors](#actors-en)
2. [Project Phases](#project-phases-en)
3. [Functional Aspects](#functional-aspects-en)
4. [Technical Aspects](#technical-aspects-en)
5. [Installation Procedure](#installation-procedure-en)

<a name="actors-en"></a>
### Actors
* **David Tacuri** (Lead Developer)

<a name="project-phases-en"></a>
### Project Phases
- [x] **H1: Planning & Design**: Architecture and SRS definition.
- [x] **H2: Foundations & Governance**: Environment setup and repository structure.
- [/] **H3: Architecture & Infrastructure**: UI/UX finalization and Atala Prism integration (**CURRENT**).
- [ ] **H4: Proof of Concept (POC)**: Implementation of affiliation logic and interoperability tests.

<a name="functional-aspects-en"></a>
### Functional Aspects
*   **SSI Wallet**: Secure management of DIDs and Verifiable Credentials (VCs).
*   **Onboarding Flow**: 3-step secure registration process.
*   **Master Key Sovereignty**: Support for 12-word recovery phrases.
*   **Political Affiliation**: Browse and affiliate with verified political organizations.
*   **QR Scanner**: Quick scanning for identity invitations and credential verification.

<a name="technical-aspects-en"></a>
### Technical Aspects

#### Technological Platform
| Feature | Detail |
| :--- | :--- |
| **Framework** | Flutter / Dart |
| **SSI Framework** | Atala Prism (Hyperledger Identus) |
| **Blockchain** | Cardano (Preview Net) |
| **State Management** | Provider-based Session Store |
| **Network** | Dio with JWT Interceptors |

#### Prerequisites
- **Flutter SDK v3.x+**
- **Eulalia Backend**: Must be running (Default: `http://localhost:5000`).
- **Identus Cloud Agent**: Required for DID issuance.

<a name="installation-procedure-en"></a>
### Installation Procedure
1.  **Clone**: `git clone https://github.com/democracyonchain/eulalia-app.git`
2.  **Dependencies**: `flutter pub get`
3.  **Run**: `flutter run`

---

## (ES) Versión en Español

### App Móvil de Identidad y Votación Descentralizada

Eulalia es la interfaz móvil principal del **Sistema VoterID**, diseñada para empoderar a los ciudadanos con **Identidad Soberana (SSI)**. Proporciona una billetera digital segura para gestionar credenciales de identidad y facilitar la participación política con transparencia absoluta.

### Tabla de Contenidos
1. [Actores](#actores-es)
2. [Fases del Proyecto](#fases-es)
3. [Aspectos Funcionales](#aspectos-funcionales-es)
4. [Aspectos Técnicos](#aspectos-tecnicos-es)
5. [Procedimiento de Instalación](#procedimiento-instalacion-es)

<a name="actores-es"></a>
### Actores
* **David Tacuri** (Desarrollador Principal)

<a name="fases-es"></a>
### Fases del Proyecto
- [x] **H1: Planificación y Diseño**: Definición de arquitectura y SRS.
- [x] **H2: Cimientos y Gobernanza**: Configuración de entorno y estructura de repositorios.
- [/] **H3: Architecture & Infrastructure**: Finalización de UI/UX e integración con Atala Prism (**ACTUAL**).
- [ ] **H4: Prueba de Concepto (POC)**: Implementación de lógica de afiliación y pruebas de interoperabilidad.

<a name="aspectos-funcionales-es"></a>
### Aspectos Funcionales
*   **Billetera SSI**: Gestión segura de DIDs y Credenciales Verificables (VCs).
*   **Flujo de Onboarding**: Proceso de registro seguro en 3 pasos.
*   **Soberanía de Llaves**: Soporte para frases de recuperación de 12 palabras.
*   **Afiliación Política**: Búsqueda y afiliación a organizaciones políticas verificadas.
*   **Escáner QR**: Escaneo rápido de invitaciones de identidad y verificación de credenciales.

<a name="aspectos-tecnicos-es"></a>
### Aspectos Técnicos

#### Plataforma Tecnológica
| Característica | Detalle |
| :--- | :--- |
| **Framework** | Flutter / Dart |
| **Framework SSI** | Atala Prism (Hyperledger Identus) |
| **Blockchain** | Cardano (Preview Net) |
| **Gestión de Estado** | Session Store basado en Provider |
| **Red** | Dio con Interceptores JWT |

#### Requisitos Previos
- **Flutter SDK v3.x+**
- **Eulalia Backend**: Debe estar activo (Predeterminado: `http://localhost:5000`).
- **Identus Cloud Agent**: Requerido para la emisión de DIDs.

<a name="procedimiento-instalacion-es"></a>
### Procedimiento de Instalación
1.  **Clonar**: `git clone https://github.com/democracyonchain/eulalia-app.git`
2.  **Dependencies**: `flutter pub get`
3.  **Ejecutar**: `flutter run`

---
**David Tacuri** | Project Catalyst Fund 12 | 2026
