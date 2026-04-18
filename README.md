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
**STATUS**: ACTIVE (MVP - Registro 360 + SSI + Wallet Local + Biometría On-device)

---

## (EN) English Version

### Decentralized Identity & Voting Mobile App

Eulalia is the mobile interface of the **VoterID System**. It enables citizens to complete a sovereign onboarding flow using **traditional registration + SSI + on-device facial biometrics**, and then proceed to political affiliation and voting flows.

The app includes an **integrated wallet** that generates cryptographic keys locally for signing transactions (voting).

### Table of Contents
1. [Actors](#actors-en)
2. [Project Phases](#project-phases-en)
3. [Functional Aspects](#functional-aspects-en)
4. [Technical Aspects](#technical-aspects-en)
5. [Installation Procedure](#installation-procedure-en)
6. [API Endpoints](#api-endpoints-en)
7. [Wallet Integration](#wallet-integration-en)

<a name="actors-en"></a>
### Actors
* **David Tacuri** (Lead Developer)

<a name="project-phases-en"></a>
### Project Phases
- [x] **H1: Planning & Design**: Architecture and SRS definition.
- [x] **H2: Foundations & Governance**: Environment setup and repository structure.
- [x] **H3: Architecture & Infrastructure**: Core UI/UX and backend connectivity.
- [x] **H4: MVP Operational Flows (COMPLETE)**: Registro 360, SSI invitation/status, biometric self-enrollment, affiliation gating, integrated wallet.
- [ ] **H5: Production Hardening**: stronger anti-spoofing models, advanced telemetry, extended mobile matrix.

<a name="functional-aspects-en"></a>
### Functional Aspects
* **Citizen Registration 360**: End-to-end onboarding flow with 4 steps.
* **Traditional Registration**: Creates citizen user and authenticates with backend JWT.
* **Integrated Wallet**: Generates local cryptographic keys (HMAC-SHA256) for transaction signing (voting).
* **SSI Wallet Integration**: Requests invitation and checks SSI status from backend.
* **On-device Biometrics**: Front-camera capture, passive liveness heuristic, local embedding generation, secure upload.
* **Registration Status API**: Consolidated status (`base_ok`, `ssi_ok`, `bio_ok`, `ready_for_affiliation`).
* **Political Affiliation Gating**: Affiliation is blocked if SSI/biometrics are incomplete.
* **QR Code Display**: Shows invitationUrl as QR for wallet scanning.

<a name="technical-aspects-en"></a>
### Technical Aspects

#### Technological Platform
| Feature | Detail |
| :--- | :--- |
| **Framework** | Flutter / Dart 3.x |
| **SSI Framework** | Hyperledger Identus integration through backend |
| **State Management** | Session Store |
| **Network** | Dio with JWT interceptor |
| **Biometric Capture** | `camera` package |
| **Image Processing** | `image` package |
| **Secure Storage** | `flutter_secure_storage` for wallet keys |
| **QR Generation** | `qr_flutter` package |
| **Crypto** | `crypto` (HMAC-SHA256 for signing) |

#### Prerequisites
- **Flutter SDK v3.x+**
- **Android toolchain**: AGP `8.6.1`, Gradle `8.7`, Kotlin `2.1.0`, Java `17`
- **Eulalia Backend running**: Default app base URL is `http://localhost:5219`
- **Identus/SSI backend integration available** for invitation/status endpoints
- **PostgreSQL** running on port 5432

#### Environment Variables
```
API_BASE_URL=http://localhost:5219
```

<a name="installation-procedure-en"></a>
### Installation Procedure
1. **Clone**: `git clone https://github.com/democracyonchain/eulalia-app.git`
2. **Install dependencies**: `flutter pub get`
3. **Configure**: Create `.env` file with `API_BASE_URL`
4. **Build**: `flutter build apk` or `flutter build ios`
5. **Run**: `flutter run`

<a name="api-endpoints-en"></a>
### API Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| POST | `/api/Usuario/crear-usuario-ciudadano` | Create citizen user |
| POST | `/api/Auth/login` | Login and get JWT |
| POST | `/api/SSI/invitation/{cedula}` | Request SSI invitation |
| GET | `/api/SSI/status/{cedula}` | Get SSI status |
| POST | `/api/SSI/webhook` | Webhook for SSI events |
| GET | `/api/RegistroCiudadano/estado/{cedula}` | Get registration status |
| POST | `/api/Biometria/register` | Register biometric |
| POST | `/api/Afiliacion` | Create affiliation |

<a name="wallet-integration-en"></a>
### Integrated Wallet

The app includes a **SecureWalletService** that generates cryptographic keys locally:

```dart
final walletService = SecureWalletService();

// Generate wallet on first use
final wallet = await walletService.generateWallet();
// Returns: (publicKey, did)

// Check if wallet exists
final hasWallet = await walletService.hasWallet();

// Sign a transaction
final signature = await walletService.signTransaction("voto:candidatoX");

// Verify signature
final isValid = await walletService.verifySignature("voto:candidatoX", signature);
```

The wallet uses:
- **Key Generation**: Random 256-bit key via `Random.secure()`
- **Signing**: HMAC-SHA256
- **DID Format**: `did:eulalia:0x{hash}`
- **Storage**: `flutter_secure_storage` (Android Keystore / iOS Keychain)

---

## (ES) Versión en Español

### App Móvil de Identidad y Votación Descentralizada

Eulalia es la interfaz móvil del **Sistema VoterID**. Permite a los ciudadanos completar un onboarding soberano con **registro tradicional + SSI + biometría facial on-device**, y luego continuar a flujos de afiliación política y votación.

La app incluye una **wallet integrada** que genera claves criptográficas localmente para firmar transacciones (votación).

### Tabla de Contenidos
1. [Actores](#actores-es)
2. [Fases del Proyecto](#fases-es)
3. [Aspectos Funcionales](#aspectos-funcionales-es)
4. [Aspectos Técnicos](#aspectos-tecnicos-es)
5. [Procedimiento de Instalación](#procedimiento-instalacion-es)
6. [Endpoints de API](#endpoints-es)
7. [Integración de Wallet](#wallet-integrada-es)

<a name="actores-es"></a>
### Actores
* **David Tacuri** (Desarrollador Principal)

<a name="fases-es"></a>
### Fases del Proyecto
- [x] **H1: Planificación y Diseño**: Definición de arquitectura y SRS.
- [x] **H2: Cimientos y Gobernanza**: Configuración de entorno y estructura de repositorios.
- [x] **H3: Arquitectura e Infraestructura**: UI/UX base y conectividad con backend.
- [x] **H4: Flujos Operativos MVP (COMPLETO)**: Registro 360, invitación/estado SSI, enrolamiento biométrico, bloqueo de afiliación, wallet integrada.
- [ ] **H5: Endurecimiento Productivo**: modelos anti-spoofing más robustos, telemetría avanzada.

<a name="aspectos-funcionales-es"></a>
### Aspectos Funcionales
* **Registro Ciudadano 360**: onboarding end-to-end en 4 pasos.
* **Registro Tradicional**: crea usuario ciudadano y autentica con JWT del backend.
* **Wallet Integrada**: genera claves criptográficas localmente (HMAC-SHA256) para firmar transacciones (votación).
* **Integración SSI Wallet**: solicita invitación y consulta estado SSI vía backend.
* **Biometría On-device**: captura con cámara frontal, liveness pasivo heurístico, embedding local y carga segura.
* **Estado Unificado de Registro**: estado consolidado (`base_ok`, `ssi_ok`, `bio_ok`, `ready_for_affiliation`).
* **Bloqueo de Afiliación**: no permite afiliación si SSI/biometría están incompletos.
* **Código QR**: Muestra invitationUrl como QR para escaneo por wallet.

<a name="aspectos-tecnicos-es"></a>
### Aspectos Técnicos

#### Plataforma Tecnológica
| Característica | Detalle |
| :--- | :--- |
| **Framework** | Flutter / Dart 3.x |
| **Framework SSI** | Integración con Hyperledger Identus a través del backend |
| **Gestión de Estado** | Session Store |
| **Red** | Dio con interceptor JWT |
| **Captura Biométrica** | paquete `camera` |
| **Procesamiento de Imagen** | paquete `image` |
| **Almacenamiento Seguro** | `flutter_secure_storage` para claves de wallet |
| **Generación QR** | paquete `qr_flutter` |
| **Criptografía** | `crypto` (HMAC-SHA256 para firmar) |

#### Requisitos Previos
- **Flutter SDK v3.x+**
- **Toolchain Android**: AGP `8.6.1`, Gradle `8.7`, Kotlin `2.1.0`, Java `17`
- **Backend Eulalia activo**: URL base por defecto `http://localhost:5219`
- **Integración Identus/SSI disponible** para endpoints de invitación/estado
- **PostgreSQL** corriendo en puerto 5432

#### Variables de Entorno
```
API_BASE_URL=http://localhost:5219
```

<a name="procedimiento-instalacion-es"></a>
### Procedimiento de Instalación
1. **Clonar**: `git clone https://github.com/democracyonchain/eulalia-app.git`
2. **Instalar dependencias**: `flutter pub get`
3. **Configurar**: Crear archivo `.env` con `API_BASE_URL`
4. **Compilar**: `flutter build apk` o `flutter build ios`
5. **Ejecutar**: `flutter run`

<a name="endpoints-es"></a>
### Endpoints de API
| Método | Endpoint | Descripción |
| :--- | :--- | :--- |
| POST | `/api/Usuario/crear-usuario-ciudadano` | Crear usuario ciudadano |
| POST | `/api/Auth/login` | Login y obtener JWT |
| POST | `/api/SSI/invitation/{cedula}` | Solicitar invitación SSI |
| GET | `/api/SSI/status/{cedula}` | Obtener estado SSI |
| POST | `/api/SSI/webhook` | Webhook para eventos SSI |
| GET | `/api/RegistroCiudadano/estado/{cedula}` | Obtener estado de registro |
| POST | `/api/Biometria/register` | Registrar biométricos |
| POST | `/api/Afiliacion` | Crear afiliación |

<a name="wallet-integrada-es"></a>
### Wallet Integrada

La app incluye un **SecureWalletService** que genera claves criptográficas localmente:

```dart
final walletService = SecureWalletService();

// Generar wallet en primer uso
final wallet = await walletService.generateWallet();
// Retorna: (publicKey, did)

// Verificar si existe wallet
final hasWallet = await walletService.hasWallet();

// Firmar una transacción
final signature = await walletService.signTransaction("voto:candidatoX");

// Verificar firma
final isValid = await walletService.verifySignature("voto:candidatoX", signature);
```

La wallet usa:
- **Generación de clave**: Clave aleatoria de 256 bits via `Random.secure()`
- **Firma**: HMAC-SHA256
- **Formato DID**: `did:eulalia:0x{hash}`
- **Almacenamiento**: `flutter_secure_storage` (Android Keystore / iOS Keychain)

---

##  Quick Start

```bash
# Clone and install
git clone https://github.com/democracyonchain/eulalia-app.git
cd eulalia-app
flutter pub get

# Run
flutter run

# Build APK
flutter build apk --debug
```

## Conexiones

- **Backend**: [eulalia-backend](https://github.com/democracyonchain/eulalia-backend)
- **Identus**: [eulalia-identus](https://github.com/democracyonchain/eulalia-identus)
- **PostgreSQL**: puerto 5432 (local)

---

## Servicios Requeridos

Para que la app funcione correctamente, los siguientes servicios deben estar activos:

| Servicio | Puerto | Descripción |
| :--- | :--- | :--- |
| **Backend .NET** | 5219 | API REST de Eulalia |
| **Cloud Agent** | 8080 | Identus Cloud Agent |
| **PostgreSQL** | 5432 | Base de datos local (voterid) |
| **PostgreSQL** | 5433 | Base de datos Docker (Identus) |

### Iniciar Servicios

```bash
# 1. Iniciar PostgreSQL local (puerto 5432)
# (configurar manualmente)

# 2. Iniciar Docker con Identus
cd eulalia-identus/cloud-agent/infrastructure/shared
docker compose --env-file .env up -d

# 3. Iniciar Backend
cd eulalia-backend
dotnet run --project eulalia-backend.Api
```

---

## Autor

**David Tacuri** – Lead Developer

