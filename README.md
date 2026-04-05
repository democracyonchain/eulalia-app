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
**STATUS**: ACTIVE (MVP Registration 360 + SSI + On-device Biometrics)

---

## (EN) English Version

### Decentralized Identity & Voting Mobile App

Eulalia is the mobile interface of the **VoterID System**. It enables citizens to complete a sovereign onboarding flow using **traditional registration + SSI + on-device facial biometrics**, and then continue to political affiliation flows.

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
- [x] **H3: Architecture & Infrastructure**: Core UI/UX and backend connectivity.
- [/] **H4: MVP Operational Flows (CURRENT)**: Registro 360, SSI invitation/status, biometric self-enrollment, affiliation gating.
- [ ] **H5: Production Hardening**: stronger anti-spoofing models, advanced telemetry, extended mobile matrix.

<a name="functional-aspects-en"></a>
### Functional Aspects
* **Citizen Registration 360**: End-to-end onboarding flow with 4 steps.
* **Traditional Registration**: Creates citizen user and authenticates with backend JWT.
* **SSI Wallet Integration**: Requests invitation and checks SSI status from backend.
* **On-device Biometrics (MVP)**: Front-camera capture, passive liveness heuristic, local embedding generation, secure upload.
* **Registration Status API**: Consolidated status (`base_ok`, `ssi_ok`, `bio_ok`, `ready_for_affiliation`).
* **Political Affiliation Gating**: Affiliation is blocked if SSI/biometrics are incomplete.

<a name="technical-aspects-en"></a>
### Technical Aspects

#### Technological Platform
| Feature | Detail |
| :--- | :--- |
| **Framework** | Flutter / Dart |
| **SSI Framework** | Hyperledger Identus integration through backend |
| **State Management** | Session Store |
| **Network** | Dio with JWT interceptor |
| **Biometric Capture** | `camera` package |
| **Image Processing** | `image` package |

#### Prerequisites
- **Flutter SDK v3.x+**
- **Android toolchain**: AGP `8.6.1`, Gradle `8.7`, Kotlin `2.1.0`, Java `17`
- **Eulalia Backend running**: Default app base URL is `http://localhost:5219`
- **Identus/SSI backend integration available** for invitation/status endpoints

<a name="installation-procedure-en"></a>
### Installation Procedure
1. **Clone**: `git clone https://github.com/democracyonchain/eulalia-app.git`
2. **Dependencies**: `flutter pub get`
3. **Run**:
   - Standard: `flutter run`
   - If Gradle cache metadata is corrupted (Windows):
     - PowerShell: ``$env:GRADLE_USER_HOME="$PWD\.gradle-home"; flutter run``

---

## (ES) Versión en Español

### App Móvil de Identidad y Votación Descentralizada

Eulalia es la interfaz móvil del **Sistema VoterID**. Permite a los ciudadanos completar un onboarding soberano con **registro tradicional + SSI + biometría facial on-device**, y luego continuar a flujos de afiliación política.

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
- [x] **H3: Arquitectura e Infraestructura**: UI/UX base y conectividad con backend.
- [/] **H4: Flujos Operativos MVP (ACTUAL)**: Registro 360, invitación/estado SSI, enrolamiento biométrico self-service, bloqueo de afiliación.
- [ ] **H5: Endurecimiento Productivo**: modelos anti-spoofing más robustos, telemetría avanzada, matriz extendida de dispositivos.

<a name="aspectos-funcionales-es"></a>
### Aspectos Funcionales
* **Registro Ciudadano 360**: onboarding end-to-end en 4 pasos.
* **Registro Tradicional**: crea usuario ciudadano y autentica con JWT del backend.
* **Integración SSI Wallet**: solicita invitación y consulta estado SSI vía backend.
* **Biometría On-device (MVP)**: captura con cámara frontal, liveness pasivo heurístico, embedding local y carga segura.
* **Estado Unificado de Registro**: estado consolidado (`base_ok`, `ssi_ok`, `bio_ok`, `ready_for_affiliation`).
* **Bloqueo de Afiliación**: no permite afiliación si SSI/biometría están incompletos.

<a name="aspectos-tecnicos-es"></a>
### Aspectos Técnicos

#### Plataforma Tecnológica
| Característica | Detalle |
| :--- | :--- |
| **Framework** | Flutter / Dart |
| **Framework SSI** | Integración con Hyperledger Identus a través del backend |
| **Gestión de Estado** | Session Store |
| **Red** | Dio con interceptor JWT |
| **Captura Biométrica** | paquete `camera` |
| **Procesamiento de Imagen** | paquete `image` |

#### Requisitos Previos
- **Flutter SDK v3.x+**
- **Toolchain Android**: AGP `8.6.1`, Gradle `8.7`, Kotlin `2.1.0`, Java `17`
- **Backend Eulalia activo**: URL base por defecto de la app `http://localhost:5219`
- **Integración Identus/SSI disponible** para endpoints de invitación/estado

<a name="procedimiento-instalacion-es"></a>
### Procedimiento de Instalación
1. **Clonar**: `git clone https://github.com/democracyonchain/eulalia-app.git`
2. **Dependencias**: `flutter pub get`
3. **Ejecutar**:
   - Estándar: `flutter run`
   - Si el caché de Gradle está corrupto (Windows):
     - PowerShell: ``$env:GRADLE_USER_HOME="$PWD\.gradle-home"; flutter run``
