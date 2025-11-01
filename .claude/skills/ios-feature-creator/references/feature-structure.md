# Feature Structure - Step-by-Step Implementation Guide

This document contains the detailed implementation steps for creating a new feature in the Rulebook iOS project, following the Feature-Scoped Architecture principles.

## Directory Structure

Every feature should follow this exact directory structure:

```
Sources/Features/{FeatureName}Feature/
├── Data/
│   ├── DTOs/                    # Feature-scoped Data Transfer Objects (optional)
│   │   └── {Entity}DTO.swift
│   ├── DataSources/             # Local and remote data sources
│   │   ├── {Feature}LocalDataSource.swift
│   │   └── {Feature}RemoteDataSource.swift
│   └── Repositories/            # Data access layer
│       └── {Feature}Repository.swift
├── Domain/
│   ├── Errors/                  # Feature-specific error types
│   │   └── {Feature}Error.swift
│   └── Protocols/               # Repository and data source protocols
│       ├── {Feature}RepositoryProtocol.swift
│       ├── {Feature}LocalDataSourceProtocol.swift
│       └── {Feature}RemoteDataSourceProtocol.swift
├── Infrastructure/
│   ├── Analytics/               # Feature-specific analytics
│   │   └── {Feature}Analytics.swift
│   ├── Endpoints.swift         # API endpoints (optional)
│   ├── {Entity}Mapper.swift    # DTO to Entity mapping (optional)
│   └── Mocks/                  # Mock implementations for testing
│       └── Mock{Feature}Repository.swift
└── Presentation/
    ├── {Feature}Feature.swift  # Main TCA reducer
    └── Views/                  # SwiftUI views (if feature includes views)
        ├── {Feature}View.swift
        └── {Detail}View.swift
```

## Implementation Steps

### Step 1: Define Feature Scope & Requirements

Before creating any files, document:
- **Feature Purpose**: What business problem does this solve?
- **Data Requirements**: What entities/data does this feature manage?
- **External Dependencies**: What existing services will it use?
- **User Interactions**: What actions can users perform?

### Step 2: Create Directory Structure

```bash
mkdir -p rulebook-kit/Sources/Features/{FeatureName}Feature/{Data/{DTOs,DataSources,Repositories},Domain/{Errors,Protocols},Infrastructure/{Analytics,Mocks},Presentation/Views}
```

### Step 3: Create Feature-Scoped Entity (if needed)

If your feature manages a new domain concept, create it in `rulebook-kit/Sources/Entities/`.

**Location**: `Sources/Entities/{Entity}.swift`

**Requirements**:
- Must conform to `Codable`, `Equatable`, and `Sendable`
- Include `id`, `createdAt`, and `updatedAt` properties
- Provide public initializer with default values where appropriate

### Step 4: Create Feature-Scoped DTO

**Location**: `Sources/Features/{Feature}Feature/Data/DTOs/{Entity}DTO.swift`

**Requirements**:
- Must conform to `Codable`, `Equatable`, and `Sendable`
- Contains only API-specific properties (may differ from Entity)
- Provide public initializer

### Step 5: Create Domain Errors

**Location**: `Sources/Features/{Feature}Feature/Domain/Errors/{Feature}Error.swift`

**Requirements**:
- Must conform to `LocalizedError` and `Sendable`
- Provide meaningful error descriptions
- Include recovery suggestions
- Must conform to `Equatable` for testing

### Step 6: Create Data Source Protocols

**Local Data Source Protocol**
- **Location**: `Sources/Features/{Feature}Feature/Domain/Protocols/{Feature}LocalDataSourceProtocol.swift`
- **Requirements**: Must conform to `Sendable`, define CRUD operations for local storage

**Remote Data Source Protocol**
- **Location**: `Sources/Features/{Feature}Feature/Domain/Protocols/{Feature}RemoteDataSourceProtocol.swift`
- **Requirements**: Must conform to `Sendable`, define API operations

### Step 7: Create Repository Protocol

**Location**: `Sources/Features/{Feature}Feature/Domain/Protocols/{Feature}RepositoryProtocol.swift`

**Requirements**:
- Must conform to `Sendable`
- Define methods for:
  - `fetchLocal`: Retrieves from local storage only
  - `fetchRemote`: Retrieves from remote API only
  - `fetch`: Retrieves using optimal data source
  - `save`: Saves to local storage
  - `delete`: Removes from local storage
  - `sync`: Synchronizes with remote source

### Step 8: Create Entity Mapper

**Location**: `Sources/Features/{Feature}Feature/Infrastructure/{Entity}Mapper.swift`

**Requirements**:
- Define `{Entity}Mapping` protocol with `toDomain` and `toDTO` methods
- Implement `{Entity}Mapper` struct conforming to protocol
- Provide public initializer
- Handle any necessary transformations between DTO and Entity

### Step 9: Implement Data Sources

**Local Data Source**
- **Location**: `Sources/Features/{Feature}Feature/Data/DataSources/{Feature}LocalDataSource.swift`
- **Requirements**:
  - Must be an `actor` conforming to `{Feature}LocalDataSourceProtocol`
  - Use `@Dependency(\.persistenceService)` for storage access
  - Implement CRUD operations using `persistenceService`

**Remote Data Source**
- **Location**: `Sources/Features/{Feature}Feature/Data/DataSources/{Feature}RemoteDataSource.swift`
- **Requirements**:
  - Must be an `actor` conforming to `{Feature}RemoteDataSourceProtocol`
  - Use `@Dependency(\.networkService)` for API access
  - Use mapper to convert between DTOs and Entities
  - Make requests using defined endpoints

### Step 10: Implement Repository

**Location**: `Sources/Features/{Feature}Feature/Data/Repositories/{Feature}Repository.swift`

**Requirements**:
- Must be an `actor` conforming to `{Feature}RepositoryProtocol`
- Accept data sources via dependency injection in initializer
- Implement local-first data fetching strategy
- Automatically cache remote data to local storage
- Implement graceful sync (don't throw on sync failures)
- Register with `DependencyKey` for TCA integration
- Extend `DependencyValues` to expose repository

**Key Patterns**:
- **Local-first approach**: Always try local data first, fall back to remote
- **Automatic caching**: Remote fetches automatically save to local storage
- **Graceful sync**: Sync operations don't throw errors, just log failures

### Step 11: Create Mock Repository

**Location**: `Sources/Features/{Feature}Feature/Infrastructure/Mocks/Mock{Feature}Repository.swift`

**Requirements**:
- Must be an `actor` conforming to `{Feature}RepositoryProtocol`
- Maintain in-memory storage of entities
- Provide `shouldFail` and `delay` properties for testing scenarios
- Implement all protocol methods
- Include helper method to create mock entities

### Step 12: Create Analytics Service

**Location**: `Sources/Features/{Feature}Feature/Infrastructure/Analytics/{Feature}Analytics.swift`

**Requirements**:
- Define `{Feature}AnalyticsEvent` enum conforming to `AnalyticsEvent`
- Each event must have `name` and `properties`
- Create `{Feature}Analytics` struct conforming to `Sendable`
- Use `@Dependency(\.analyticsService)` for analytics access
- Register with `DependencyKey`
- Extend `DependencyValues` to expose analytics

### Step 13: Create TCA Feature Reducer

**Location**: `Sources/Features/{Feature}Feature/Presentation/{Feature}Feature.swift`

**Requirements**:
- Must be a `@Reducer` struct conforming to `Sendable`
- Define `@ObservableState` struct for feature state
- Define comprehensive `Action` enum with:
  - View lifecycle actions
  - User actions
  - System responses
  - Child actions (alerts, sheets)
  - Delegate actions
- Inject dependencies using `@Dependency` wrapper
- Implement reducer body with proper effect handling
- Extract complex logic into private methods
- Handle errors with user-friendly alerts

**TCA Patterns**:
- **State separation**: Keep UI state separate from business data
- **Effect composition**: Use `TaskResult` for async operations
- **Presentation management**: Use `@Presents` for alerts and sheets
- **Delegate pattern**: Communicate with parent features via delegate actions

### Step 14: Create API Endpoints (if needed)

**Location**: `Sources/Features/{Feature}Feature/Infrastructure/Endpoints.swift`

**Requirements**:
- Define `{Feature}Endpoint` enum with all API operations
- Conform to `APIEndpoint` protocol
- Implement `path`, `method`, and `body` properties
- Use proper HTTP methods (GET, POST, PUT, DELETE)

### Step 15: Update Package.swift

Add your new feature to the Package.swift file:

**In products array**:
```swift
.library(name: "{Feature}Feature", targets: ["{Feature}Feature"])
```

**In targets array**:
```swift
.target(
    name: "{Feature}Feature",
    dependencies: [
        "Entities",
        "Framework",
        "PersistenceService",
        "NetworkService",
        tca
    ],
    path: "Sources/Features/{Feature}Feature"
)
```

**Add test target**:
```swift
.testTarget(
    name: "{Feature}FeatureTests",
    dependencies: ["{Feature}Feature"],
    path: "Tests/{Feature}FeatureTests"
)
```

### Step 16: Create Basic Tests

**Location**: `Tests/{Feature}FeatureTests/{Feature}FeatureTests.swift`

**Requirements**:
- Import `XCTest` and `ComposableArchitecture`
- Use `TestStore` for testing TCA features
- Replace real dependencies with mocks using `withDependencies`
- Test state mutations and effects
- Test user flows and edge cases

**Testing Strategy**:
- **Mock repositories**: Create simple mocks that mirror real interfaces
- **TestStore usage**: Use TCA's TestStore for predictable testing
- **Dependency injection**: Replace real dependencies with test doubles
- **Focused scenarios**: Test specific user flows and edge cases

## Implementation Order and Dependencies

1. **Start with Domain Layer**: Entities, Errors, Protocols
2. **Build Infrastructure**: Mappers, Endpoints, Analytics
3. **Implement Data Layer**: Data Sources, Repository
4. **Create Presentation Layer**: TCA Reducer, Views
5. **Add Testing Support**: Mocks, Tests
6. **Integrate with Package**: Update Package.swift

Each step builds upon the previous one, ensuring a logical and dependency-aware implementation order.
