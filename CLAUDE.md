# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Banshee-AppleOS is an iOS/macOS podcast player application built with SwiftUI and following a clean architecture pattern. The project is organized into modular Swift packages with clear separation of concerns across Core, Business, Data, Feature, and App layers.

## Architecture

This project follows a **modular package-based architecture** with dependency inversion principles. See `ARCHITECTURE.md` for comprehensive documentation.

### Layer Dependencies

```
App → Data, Feature
Data → Business
Business → Core
Feature → Core
```

### Key Packages

- **Core**: Domain models, repository contracts, no external dependencies except swift-log
  - Contains: `User`, `AuthSession`, `Podcast`, `Episode`, `AudioQueue`, etc.
  - Defines contracts (protocols) that other layers implement

- **Business**: Repository implementations, business logic, data source contracts
  - Uses Overflow library for reactive streams (CurrentValueSubject equivalent)
  - Defines DTOs and contracts that Data layer implements
  - Contains repositories: `AuthRepository`, `PodcastRepository`, `EpisodePlayer`

- **Data**: Data source implementations (local/remote), API clients, platform-specific storage
  - Uses Cobweb for HTTP networking
  - Implements keychain storage via `KeychainService`
  - Implements `AVFoundation` audio playback via `AudioService`

- **Feature**: ViewModels, Views, UI components
  - Depends only on Core (not Business or Data)
  - Uses Brute for UI styling framework
  - Modules: Auth, Podcasts, Audio, SharedUI

- **App**: Dependency injection, coordinators, feature assembly
  - Main target: `Banshee.xcodeproj`
  - Uses custom Scaffold library for DI with `@Single` property wrapper
  - Navigation coordination via `AppCoordinator`

### External Dependencies

- **Cobweb** (github.com/Lukas-Simonson/Swift-Cobweb): HTTP networking library
- **Overflow** (github.com/Lukas-Simonson/Overflow): Reactive streams library
- **Brute** (github.com/Lukas-Simonson/Brute): UI styling framework
- **NoticeMe**: Toast/notice notification system
- **Scaffold**: Dependency injection framework (appears to be local or custom)
- **swift-log**: Standard Swift logging

## Building and Running

### Requirements

- Swift 6.2 toolchain (packages specify swift-tools-version 6.2)
- iOS 18+ / macOS 15+ targets
- Xcode (for App target build)

### Build Commands

Since this is an Xcode-based project with Swift packages:

**Build the main app:**
```bash
# Open in Xcode
open App/Banshee.xcodeproj

# Build from command line (requires Xcode)
xcodebuild -project App/Banshee.xcodeproj -scheme Banshee -configuration Debug build
```

**Build individual packages:**
```bash
# Build Core package
swift build --package-path Core

# Build Business package
swift build --package-path Business

# Build Data package
swift build --package-path Data

# Build Feature package
swift build --package-path Feature
```

### Running Tests

**Test individual packages:**
```bash
# Test Core package
swift test --package-path Core

# Test Business package
swift test --package-path Business

# Test Data package
swift test --package-path Data
```

**Test from Xcode:**
```bash
# Run all tests in Xcode
xcodebuild test -project App/Banshee.xcodeproj -scheme Banshee
```

Tests use the Swift Testing framework (not XCTest), identifiable by `@Test` annotations.

## Dependency Injection Pattern

The app uses a custom Scaffold-based DI system with feature-specific scaffolds:

### Scaffold Hierarchy

- `AppScaffold`: Root container, owns singletons like `KeychainService`, `EpisodePlayer`
- `AuthScaffold`: Auth feature dependencies (AuthRepository, etc.)
- `PodcastScaffold`: Podcast feature dependencies (PodcastRepository, etc.)
- `AudioScaffold`: Audio player dependencies

### DI Usage

The `@Single` property wrapper creates singleton instances. Scaffolds are instantiated once in `AppCoordinator.shared.scaffold`.

Example:
```swift
// In AppScaffold
@Single
func keychain() -> KeychainService {
    KeychainService(serviceName: "com.bansheeaudio.banshee")
}

// In AuthScaffold
@Single
func repository() -> AuthRepositoryContract {
    AuthRepository(
        local: LocalAuthDataSource(keychain: app.keychain(), ...),
        remote: CobwebRemoteAuthDataSource(...),
        ...
    )
}
```

## State Management

### Reactive Streams

Repositories expose AsyncSequence streams for observable state:

```swift
// AuthRepository exposes session stream
func sessionStream() -> AsyncStream<AuthSession?> { ... }

// Features observe independently
Task {
    for await session in authRepository.sessionStream {
        self.session = session
    }
}
```

The Business layer uses Overflow's `CurrentValueSubject` to manage streams.

### Observable ViewModels

ViewModels use Swift's `@Observable` macro (not `@ObservableObject`):

```swift
@Observable
class LoginViewModel {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
}
```

## Key Architectural Patterns

### Contract-Based Design

Contracts (protocols) are defined in the layer that **uses** them, not the layer that implements them:

- `AuthRepositoryContract` defined in Core, implemented in Business
- `LocalAuthDataSourceContract` defined in Business, implemented in Data
- `AuthNavigationContract` defined in Feature, implemented in App

### Feature Communication

Features never communicate directly. All cross-feature state sharing happens through repository streams observed independently by each feature.

### DTO Mapping

- **Business Layer**: Maps between Core domain models and DTOs
- **Data Layer**: Maps between DTOs and API/database entities

Example flow: `UserEntity` (API) → `UserDTO` (Data) → `User` (Core domain)

## Code Organization

```
Banshee-AppleOS/
├── Core/                   # Domain layer (models + contracts)
│   ├── Sources/Core/
│   │   ├── Auth/
│   │   │   ├── Models/         (User, AuthSession, AuthToken)
│   │   │   └── Repositories/   (AuthRepositoryContract)
│   │   ├── Podcasts/
│   │   │   ├── Models/         (Podcast, Episode)
│   │   │   └── Repositories/   (PodcastRepositoryContract)
│   │   └── Audio/
│   │       ├── Models/         (AudioQueue, AudioPlayerState)
│   │       └── Players/        (EpisodePlayerContract)
│   └── Tests/CoreTests/
│
├── Business/               # Business logic layer
│   ├── Sources/Business/
│   │   ├── Auth/
│   │   │   ├── Repositories/     (AuthRepository)
│   │   │   └── DataSources/      (*DataSourceContract)
│   │   └── Podcast/
│   │       └── Repositories/     (PodcastRepository)
│   └── Tests/BusinessTests/
│
├── Data/                   # Data access layer
│   ├── Sources/Data/
│   │   ├── Auth/
│   │   │   ├── DataSources/      (KeychainLocalAuthDataSource)
│   │   │   ├── DTOs/             (UserDTO, AuthSessionDTO)
│   │   │   └── Services/         (KeychainService)
│   │   ├── Podcast/
│   │   │   ├── DataSources/      (CobwebRemotePodcastDataSource)
│   │   │   └── DTOs/             (PodcastDTO, EpisodeDTO)
│   │   └── Audio/
│   │       ├── DataSources/      (UserDefaultsLocalQueueDataSource)
│   │       └── Services/         (AudioService - AVFoundation wrapper)
│   └── Tests/DataTests/
│
├── Feature/                # UI layer
│   ├── Sources/
│   │   ├── Auth/           (LoginView, LoginVM, LoginScreen)
│   │   ├── Podcasts/       (PodcastListView, PodcastDetailView, etc.)
│   │   ├── Audio/          (PlayerView, MiniPlayerView, PlayerVM)
│   │   └── SharedUI/       (CachedImage, ImageCache, reusable components)
│   └── Tests/FeatureTests/
│
└── App/                    # Main application target
    └── Banshee/
        ├── BansheeApp.swift
        ├── RootView.swift
        ├── Coordinators/   (AppCoordinator, PodcastCoordinator)
        └── DI/             (AppScaffold, AuthScaffold, PodcastScaffold, AudioScaffold)
```

## Audio Playback

The audio system uses a multi-layer approach:

1. **AudioService** (Data layer): Wraps AVFoundation's AVPlayer/AVAudioSession
2. **EpisodePlayer** (Business layer): Manages playback state, queue, progress tracking
3. **PlayerVM** (Feature layer): UI state and user interaction handling

Queue persistence is handled via `UserDefaultsLocalQueueDataSource` which stores queue state locally.

## Navigation

Navigation uses SwiftUI's NavigationPath coordinated through feature coordinators:

- `AppCoordinator`: Top-level navigation and auth state
- `PodcastCoordinator`: Podcast feature navigation
- Navigation contracts defined in Feature layer, implemented in App layer

## Authentication Flow

1. User logs in via `LoginView` → `LoginVM`
2. `LoginVM` uses `AuthRepository` to authenticate
3. `AuthRepository` calls `CobwebRemoteAuthDataSource` for server auth
4. Session saved via `KeychainLocalAuthDataSource` (tokens in Keychain, user data in UserDefaults)
5. `AuthRepository` emits new session via `sessionStream`
6. `AppCoordinator` observes stream and updates UI

## Development Guidelines

### Adding New Features

1. Define domain models and contracts in Core
2. Create Feature module with Views/ViewModels depending only on Core
3. Implement Business layer repositories/interactors if needed
4. Implement Data layer data sources
5. Wire dependencies in App layer Scaffold
6. Add navigation in appropriate Coordinator

### Interactors vs Repositories

- Use **Repositories** for single data source CRUD and streaming
- Use **Interactors** when orchestrating multiple repositories or complex business logic

Currently the project primarily uses Repositories directly from ViewModels.

### Testing Strategy

- Test repository implementations and business logic in Business layer tests
- Test data source implementations in Data layer tests
- Feature layer focuses on UI and can mock Core contracts

### Security

- Sensitive tokens stored in Keychain via `KeychainService`
- User profile data stored in UserDefaults
- HTTP requests use Cobweb with Bearer token authentication
