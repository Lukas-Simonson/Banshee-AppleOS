
# Mobile Architecture Guidelines

## Overview

A modular, package-based architecture designed for maintainability, testability, and feature independence. This architecture emphasizes dependency inversion, reactive streams, and clear separation of concerns across independent packages.

## Core Principles

### 1. Package-Based Modularity

Each layer is a separate package that can only depend on explicitly declared dependencies. This enforces architectural boundaries and enables independent development and testing.

### 2. Dependency Inversion

Contracts (protocols/interfaces) are defined in the layer that **consumes** them, not in the layer that implements them. This allows upper layers to define their needs without depending on lower layer implementations.

### 3. Feature Independence

Features communicate only through shared repository streams, never directly. This enables parallel development and feature reusability.

## Architecture Layers

```
        ┌─────────────┐
        │     App     │
        └──────┬──────┘
       ┌───────┴───────┐
       │               │
  ┌────▼────┐    ┌─────▼──────┐
  │  Data   │    │  Feature   │
  └────┬────┘    └─────┬──────┘
       │               │
  ┌────▼────┐          │
  │Business │          │
  └────┬────┘          │
       │               │
       └───────┬───────┘
          ┌────▼────┐
          │  Core   │
          └─────────┘

```

### Core Layer

**Dependencies:** None

**Responsibilities:**

-   Domain models
-   Repository contracts
-   Interactor contracts
-   Domain validation logic
-   Shared value objects and enums

**Example:**

```swift
// Domain Models
struct User {
    let id: String
    let email: String
    let displayName: String
    let profileImageURL: URL?
}

struct AuthToken {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}

struct Session {
    let user: User
    let token: AuthToken
}

// Repository Contract
protocol AuthRepositoryContract {
    func sessionStream() -> AsyncSequence<Session?>
    func getCurrentSession() async -> Session?
    func saveSession(_ session: Session) async throws
    func clearSession() async throws
}

// Interactor Contracts
protocol LoginInteractorContract {
    func callAsFunction(email: String, password: String) async throws -> Session
}

protocol LogoutInteractorContract {
    func callAsFunction() async throws
}

```

### Business Layer

**Dependencies:** Core Layer

**Responsibilities:**

-   Repository implementations
-   Interactor implementations
-   Business logic and validation
-   Data source contracts (for Data Layer to implement)
-   DTOs (Data Transfer Objects)
-   Shared data caching and streams

**Example:**

```swift
// Repository Implementation
class AuthRepository: AuthRepositoryContract {
    private let localDataSource: LocalAuthDataSourceContract
    private let remoteDataSource: RemoteAuthDataSourceContract
    private let sessionSubject = CurrentValueSubject<Session?, Never>(nil)
    
    func sessionStream() -> AsyncSequence<Session?> {
        // Returns observable stream of authentication state
    }
    
    func saveSession(_ session: Session) async throws {
        // 1. Convert Session to SessionDTO
        // 2. Save via localDataSource
        // 3. Update sessionSubject to notify observers
    }
}

// Data Source Contracts (for Data Layer)
protocol LocalAuthDataSourceContract {
    func getSession() async throws -> SessionDTO
    func saveSession(_ session: SessionDTO) async throws
    func clearSession() async throws
}

protocol RemoteAuthDataSourceContract {
    func login(email: String, password: String) async throws -> AuthResponseDTO
    func refreshToken(_ refreshToken: String) async throws -> AuthResponseDTO
    func logout(token: String) async throws
}

// DTOs
struct SessionDTO: Codable {
    let userId: String
    let email: String
    let displayName: String
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}

struct AuthResponseDTO: Codable {
    let userId: String
    let email: String
    let displayName: String
    let accessToken: String
    let refreshToken: String
    let expiresInSeconds: Int
}

// Interactor Implementation
class LoginInteractor: LoginInteractorContract {
    private let authRepository: AuthRepositoryContract
    private let remoteDataSource: RemoteAuthDataSourceContract
    private let analyticsRepository: AnalyticsRepositoryContract
    
    func callAsFunction(email: String, password: String) async throws -> Session {
        // 1. Validate email format
        // 2. Validate password strength
        // 3. Call remoteDataSource.login()
        // 4. Convert response to Session
        // 5. Save session via authRepository
        // 6. Track login event via analyticsRepository
        // 7. Return session
    }
}

class LogoutInteractor: LogoutInteractorContract {
    private let authRepository: AuthRepositoryContract
    private let remoteDataSource: RemoteAuthDataSourceContract
    
    func callAsFunction() async throws {
        // 1. Get current session
        // 2. Call remoteDataSource.logout() to invalidate server token
        // 3. Clear local session via authRepository
        // 4. Track logout event
    }
}

```

### Data Layer

**Dependencies:** Business Layer (and transitively Core Layer)

**Responsibilities:**

-   Data source implementations
-   Entity models (database/API schemas)
-   Network/database clients
-   Entity ↔ DTO mapping
-   Platform-specific data access

**Example:**

```swift
// Local Data Source Implementation
class LocalAuthDataSource: LocalAuthDataSourceContract {
    private let keychain: KeychainService
    
    func getSession() async throws -> SessionDTO {
        // 1. Retrieve tokens from keychain
        // 2. Retrieve user data from UserDefaults
        // 3. Map to SessionDTO
    }
    
    func saveSession(_ session: SessionDTO) async throws {
        // 1. Save tokens to keychain (secure storage)
        // 2. Save user data to UserDefaults
    }
    
    func clearSession() async throws {
        // 1. Delete tokens from keychain
        // 2. Remove user data from UserDefaults
    }
}

// Remote Data Source Implementation
class RemoteAuthDataSource: RemoteAuthDataSourceContract {
    private let apiClient: APIClient
    
    func login(email: String, password: String) async throws -> AuthResponseDTO {
        // 1. Create LoginRequest
        // 2. POST to /auth/login endpoint
        // 3. Parse AuthResponse
        // 4. Map to AuthResponseDTO
    }
    
    func refreshToken(_ refreshToken: String) async throws -> AuthResponseDTO {
        // 1. POST to /auth/refresh endpoint with refresh token
        // 2. Parse response
        // 3. Map to AuthResponseDTO
    }
}

```

### Feature Layer

**Dependencies:** Core Layer only

**Responsibilities:**

-   ViewModels
-   Views
-   UI-specific models and state
-   Feature-specific caching
-   Navigation contracts
-   User interaction handling

**Example:**

```swift
// Login Feature
@Observable
class LoginViewModel {
    private let loginInteractor: LoginInteractorContract
    private let navigator: AuthNavigatorContract
    
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    func login() {
        // 1. Set loading state
        // 2. Call loginInteractor.execute()
        // 3. Handle success: navigate to home
        // 4. Handle error: display error message
    }
    
    func navigateToSignUp() {
        // Delegate to navigator
    }
}

// Profile Feature (observes auth state)
@Observable
class ProfileViewModel {
    private let authRepository: AuthRepositoryContract
    private let logoutInteractor: LogoutInteractorContract
    
    var user: User?
    var isLoading: Bool = false
    
    func observeAuthState() {
        // Subscribe to authRepository.sessionStream()
        // Update user when session changes
    }
    
    func logout() {
        // 1. Call logoutInteractor.execute()
        // 2. Navigate to login screen
    }
}

// Navigation Contract (defined in Feature Layer)
protocol AuthNavigatorContract {
    func navigateToHome()
    func navigateToSignUp()
    func navigateToForgotPassword()
}

```

### App Layer

**Dependencies:** All layers (Core, Business, Data, Feature)

**Responsibilities:**

-   Dependency injection / composition root
-   Feature assembly and wiring
-   Navigator/Coordinator implementations
-   Navigation between features
-   App-level configuration
-   Singleton management

**Example:**

```swift
class AppCoordinator {
    var path = NavigationPath()
    
    // Shared repositories (singletons)
    private lazy var authRepository: AuthRepositoryContract = {
        // Instantiate LocalAuthDataSource
        // Instantiate RemoteAuthDataSource
        // Return AuthRepository with both data sources
    }()
    
    func start() {
        // Observe authRepository.sessionStream()
        // Show login if session is nil
        // Show home if session exists
    }
    
    func makeLoginFeature() -> LoginViewModel {
        // 1. Create RemoteAuthDataSource
        // 2. Create LoginInteractor with dependencies
        // 3. Create LoginViewModel with interactor and navigator
    }
    
    func makeProfileFeature() -> ProfileViewModel {
        // 1. Create LogoutInteractor
        // 2. Create ProfileViewModel with dependencies
    }
}

// Navigator Implementation
extension AppCoordinator: AuthNavigatorContract {
    func navigateToHome() {
        // Push or present home screen
    }
    
    func navigateToSignUp() {
        // Create and push sign up feature
    }
    
    func navigateToForgotPassword() {
        // Create and push forgot password feature
    }
}

```

## State Management

### Reactive Streams

-   Repositories expose `AsyncSequence` (Swift) or `Flow` (Kotlin) streams for observable data
-   Features subscribe to repository streams independently
-   All cross-feature communication happens through shared repository state
-   Stream-based architecture enables reactive UI updates

### Authentication State Flow

```swift
// Repository maintains shared state
class AuthRepository: AuthRepositoryContract {
    private let sessionSubject = CurrentValueSubject<Session?, Never>(nil)
    
    func sessionStream() -> AsyncSequence<Session?> {
        // Multiple features observe this single stream
    }
}

// Multiple features observe independently
class ProfileViewModel {
    func observeAuthState() {
        // Subscribe to sessionStream, update UI when session changes
    }
}

class SettingsViewModel {
    func observeAuthState() {
        // Subscribe to sessionStream, show/hide auth-only settings
    }
}

class HomeViewModel {
    func observeAuthState() {
        // Subscribe to sessionStream, display user info
    }
}

```

### Caching Strategy

**Repository Level (Business Layer)**

-   Cache data shared across multiple features
-   Maintain single source of truth
-   Emit streams when data changes
-   Examples: Authentication session, user profile, app configuration

**Feature Level (Feature Layer)**

-   Cache UI-specific state and derived data
-   Subscribe to repository streams for shared data
-   Examples: Form input, validation errors, UI selections, pagination state

**Decision Rule:** Cache at the lowest level where sharing is needed.

## Data Models & DTOs

### Standard Pattern (Recommended)

Use separate models at each layer for maximum flexibility:

**Core Layer:** Domain models (`User`, `Session`, `AuthToken`)

-   Pure business entities
-   No serialization concerns
-   Rich domain behavior

**Business Layer:** DTOs (`SessionDTO`, `AuthResponseDTO`)

-   Data transfer contracts between Business and Data layers
-   Simple, serializable structures

**Data Layer:** Entity models (`SessionEntity`, `AuthResponse`)

-   Database/API schemas
-   Platform-specific annotations

**Mapping Responsibilities:**

-   Business Layer: DTO ↔ Domain mapping
-   Data Layer: Entity ↔ DTO mapping

**When to use:**

-   Large or complex applications
-   Multiple data sources with different schemas
-   Need to evolve layers independently
-   Maximum isolation and rewritability

### Pragmatic Alternative

For simpler applications, Data Layer can use Core domain models directly, accepting tighter coupling for reduced complexity.

**When to use:**

-   Small to medium applications
-   Single data source
-   Stable domain models
-   Rapid prototyping

## Decision Guides

### When to Use Interactors

**Use Interactors when:**

-   Business logic involves multiple repositories
-   Complex validation or business rules needed
-   Multi-step workflows or transactions
-   Logic should be reusable across features

**Skip Interactors when:**

-   Simple CRUD operations
-   Direct repository access is sufficient
-   Minimal business logic
-   Single data source involved

### Repository vs Interactor

**Repositories:**

-   Single data source coordination
-   CRUD operations
-   Data caching and streaming
-   Simple queries

**Interactors:**

-   Multi-repository orchestration
-   Complex business rules
-   Transaction management
-   Domain workflows

## Project Structure

```
MyApp/
├── Core/
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Session.swift
│   │   └── AuthToken.swift
│   ├── Contracts/
│   │   ├── AuthRepositoryContract.swift
│   │   ├── LoginInteractorContract.swift
│   │   └── LogoutInteractorContract.swift
│   └── Errors/
│       └── AuthError.swift
│
├── Business/
│   ├── Repositories/
│   │   └── AuthRepository.swift
│   ├── Interactors/
│   │   ├── LoginInteractor.swift
│   │   └── LogoutInteractor.swift
│   ├── Contracts/
│   │   ├── LocalAuthDataSourceContract.swift
│   │   └── RemoteAuthDataSourceContract.swift
│   └── DTOs/
│       ├── SessionDTO.swift
│       └── AuthResponseDTO.swift
│
├── Data/
│   ├── Local/
│   │   └── LocalAuthDataSource.swift
│   └── Remote/
│       └── RemoteAuthDataSource.swift
│
├── Feature/
│   ├── Login/
│   │   ├── LoginViewModel.swift
│   │   ├── LoginView.swift
│   │   └── AuthNavigatorContract.swift
│   └── Profile/
│       ├── ProfileViewModel.swift
│       └── ProfileView.swift
│
└── App/
    ├── Coordinators/
    │   └── AppCoordinator.swift
    └── AppDelegate.swift

```

## Benefits

### Architectural Benefits

-   True layer independence - each layer can be rewritten without affecting others
-   Clean, unidirectional dependency graph with no circular dependencies
-   Parallel development across layers
-   Feature reusability across applications

### Development Benefits

-   Easy to test each layer in isolation
-   Flexibility to choose pragmatic or strict patterns
-   Architecture scales from simple to complex
-   Clear responsibilities reduce cognitive load

### Team Benefits

-   Well-defined interfaces between layers
-   Layers can be versioned independently
-   Consistent structure aids onboarding
-   Architectural violations easily spotted in code review

## Getting Started

1.  **Define domain:** Start with Core Layer models and contracts
2.  **Build features:** Create Feature Layer modules depending only on Core
3.  **Implement business logic:** Add Business Layer repositories and interactors
4.  **Add data sources:** Implement Data Layer for persistence/networking
5.  **Wire together:** Create App Layer coordinators to compose everything

## Best Practices

-   Start simple with direct repository access; add interactors when needed
-   Keep contracts focused with single, clear responsibilities
-   Build complex features by composing simple interactors
-   Focus testing on repository implementations and interactors
-   Document architectural decisions and trade-offs
-   Regularly audit package dependencies
-   Use secure platform-specific storage for sensitive data
-   Let features reactively respond to state changes via streams
