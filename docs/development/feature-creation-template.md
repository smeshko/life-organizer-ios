# Feature Creation Template - Rulebook iOS

## 🎯 Overview

This template provides a comprehensive guide for creating new features in the Rulebook iOS project, following the **Feature-Scoped Architecture** principles outlined in the architecture documentation.

## 📁 Feature Structure Template

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
│   │   └── {Feature}AnalyticsService.swift
│   ├── Endpoints.swift         # API endpoints (optional)
│   ├── Mappers/                # DTO to Entity mapping (optional)
│   │   └── {Entity}Mapper.swift
│   └── Mocks/                  # Mock implementations for testing
│       ├── Mock{Feature}Repository.swift
│       ├── Mock{Feature}LocalDataSource.swift
│       ├── Mock{Feature}RemoteDataSource.swift
│       └── Mock{Feature}AnalyticsService.swift
└── Presentation/
    ├── {Feature}Feature.swift  # Main TCA reducer
    └── Views/                  # SwiftUI views (if feature includes views)
        ├── {Feature}View.swift
        └── {Detail}View.swift
```

## 🏗️ Step-by-Step Feature Creation Guide

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

If your feature manages a new domain concept, create it in `rulebook-kit/Sources/Entities/`:

```swift
// Sources/Entities/{Entity}.swift
import Foundation

public struct {Entity}: Codable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    // ... other properties
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        // ... other parameters
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        // ... assign other properties
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

### Step 4: Create Feature-Scoped DTO

```swift
// Sources/Features/{Feature}Feature/Data/DTOs/{Entity}DTO.swift
import Foundation

public struct {Entity}DTO: Codable, Equatable, Sendable {
    public let title: String
    // ... other API-specific properties
    
    public init(
        title: String
        // ... other parameters
    ) {
        self.title = title
        // ... assign other properties
    }
}
```

### Step 5: Create Domain Errors

```swift
// Sources/Features/{Feature}Feature/Domain/Errors/{Feature}Error.swift
import Foundation

/// Centralized error handling for {Feature}Feature
public enum {Feature}Error: LocalizedError, Sendable {
    case notFound
    case networkUnavailable
    case invalidData
    case syncFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "{Entity} not found"
        case .networkUnavailable:
            return "Network connection is unavailable"
        case .invalidData:
            return "Invalid {entity} data"
        case .syncFailed(let message):
            return "Failed to sync {entity}: \(message)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .notFound:
            return "Try searching for a different {entity}"
        case .networkUnavailable:
            return "Connect to Wi-Fi or cellular data and retry"
        case .invalidData:
            return "Clear cache and download fresh data"
        case .syncFailed:
            return "Check your internet connection and try again"
        }
    }
}

// MARK: - Equatable conformance
extension {Feature}Error: Equatable {
    public static func == (lhs: {Feature}Error, rhs: {Feature}Error) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound),
             (.networkUnavailable, .networkUnavailable),
             (.invalidData, .invalidData):
            return true
        case (.syncFailed(let lMessage), .syncFailed(let rMessage)):
            return lMessage == rMessage
        default:
            return false
        }
    }
}
```

### Step 6: Create Data Source Protocols

```swift
// Sources/Features/{Feature}Feature/Domain/Protocols/{Feature}LocalDataSourceProtocol.swift
import Foundation
import Entities

public protocol {Feature}LocalDataSourceProtocol: Sendable {
    func fetch(id: String) async throws -> {Entity}
    func save(_ entity: {Entity}) async throws
    func delete(id: String) async throws
}
```

```swift
// Sources/Features/{Feature}Feature/Domain/Protocols/{Feature}RemoteDataSourceProtocol.swift
import Foundation
import Entities

public protocol {Feature}RemoteDataSourceProtocol: Sendable {
    func fetch(id: String) async throws -> {Entity}
    func create(_ entity: {Entity}) async throws -> {Entity}
    func update(_ entity: {Entity}) async throws -> {Entity}
}
```

### Step 7: Create Repository Protocol

```swift
// Sources/Features/{Feature}Feature/Domain/Protocols/{Feature}RepositoryProtocol.swift
import Foundation
import Entities

/// Repository protocol for {feature} data access
public protocol {Feature}RepositoryProtocol: Sendable {
    /// Retrieves {entity} from local storage only
    func fetchLocal(id: String) async throws -> {Entity}
    
    /// Retrieves {entity} from remote API only
    func fetchRemote(id: String) async throws -> {Entity}
    
    /// Retrieves {entity} using optimal data source
    func fetch(id: String) async throws -> {Entity}
    
    /// Saves {entity} to local storage
    func save(_ entity: {Entity}) async throws
    
    /// Removes {entity} from local storage
    func delete(id: String) async throws
    
    /// Synchronizes {entity} with remote source
    func sync(id: String) async throws
}
```

### Step 8: Create Entity Mapper (Optional)

```swift
// Sources/Features/{Feature}Feature/Infrastructure/Mappers/{Entity}Mapper.swift
import Foundation
import Entities

protocol {Entity}Mapping {
    func toDomain(_ dto: {Entity}DTO) -> {Entity}
    func toDTO(_ entity: {Entity}) -> {Entity}DTO
}

struct {Entity}Mapper: {Entity}Mapping {
    init() {}

    func toDomain(_ dto: {Entity}DTO) -> {Entity} {
        {Entity}(
            title: dto.title
            // ... map other properties with any necessary transformations
        )
    }

    func toDTO(_ entity: {Entity}) -> {Entity}DTO {
        {Entity}DTO(
            title: entity.title
            // ... map other properties
        )
    }
}
```

### Step 9: Implement Data Sources

```swift
// Sources/Features/{Feature}Feature/Data/DataSources/{Feature}LocalDataSource.swift
import Foundation
import PersistenceService
import Dependencies
import Entities

actor {Feature}LocalDataSource: {Feature}LocalDataSourceProtocol {
    @Dependency(\.persistenceService) private var persistenceService

    init() {}

    func fetch(id: String) async throws -> {Entity} {
        guard let loaded = try await persistenceService.load({Entity}.self, forKey: id) else {
            throw {Feature}Error.notFound
        }
        return loaded
    }

    func save(_ entity: {Entity}) async throws {
        try await persistenceService.save(entity, forKey: entity.id.uuidString)
    }

    func delete(id: String) async throws {
        try await persistenceService.deleteData(forKey: id)
    }
}

// MARK: - Dependency Key
struct {Feature}LocalDataSourceKey: DependencyKey {
    static let liveValue: any {Feature}LocalDataSourceProtocol = {Feature}LocalDataSource()
    static let testValue: any {Feature}LocalDataSourceProtocol = Mock{Feature}LocalDataSource()
    static let previewValue: any {Feature}LocalDataSourceProtocol = Mock{Feature}LocalDataSource()
}

extension DependencyValues {
    var {feature}LocalDataSource: any {Feature}LocalDataSourceProtocol {
        get { self[{Feature}LocalDataSourceKey.self] }
        set { self[{Feature}LocalDataSourceKey.self] = newValue }
    }
}
```

```swift
// Sources/Features/{Feature}Feature/Data/DataSources/{Feature}RemoteDataSource.swift
import Foundation
import Dependencies
import Entities
import NetworkService

actor {Feature}RemoteDataSource: {Feature}RemoteDataSourceProtocol {
    @Dependency(\.networkService) private var networkService

    init() {}

    func fetch(id: String) async throws -> {Entity} {
        let dto: {Entity}DTO = try await networkService.sendRequest(
            to: {Feature}Endpoint.get{Entity}(id)
        )
        return {Entity}Mapper().toDomain(dto)
    }

    func create(_ entity: {Entity}) async throws -> {Entity} {
        let dto = {Entity}Mapper().toDTO(entity)
        let responseDTO: {Entity}DTO = try await networkService.sendRequest(
            to: {Feature}Endpoint.create{Entity}(dto)
        )
        return {Entity}Mapper().toDomain(responseDTO)
    }

    func update(_ entity: {Entity}) async throws -> {Entity} {
        let dto = {Entity}Mapper().toDTO(entity)
        let responseDTO: {Entity}DTO = try await networkService.sendRequest(
            to: {Feature}Endpoint.update{Entity}(entity.id.uuidString, dto)
        )
        return {Entity}Mapper().toDomain(responseDTO)
    }
}

// MARK: - Dependency Key
struct {Feature}RemoteDataSourceKey: DependencyKey {
    static let liveValue: any {Feature}RemoteDataSourceProtocol = {Feature}RemoteDataSource()
    static let testValue: any {Feature}RemoteDataSourceProtocol = Mock{Feature}RemoteDataSource()
    static let previewValue: any {Feature}RemoteDataSourceProtocol = Mock{Feature}RemoteDataSource()
}

extension DependencyValues {
    var {feature}RemoteDataSource: any {Feature}RemoteDataSourceProtocol {
        get { self[{Feature}RemoteDataSourceKey.self] }
        set { self[{Feature}RemoteDataSourceKey.self] = newValue }
    }
}
```

### Step 10: Implement Repository

```swift
// Sources/Features/{Feature}Feature/Data/Repositories/{Feature}Repository.swift
import Foundation
import Dependencies
import Entities

actor {Feature}Repository: {Feature}RepositoryProtocol {
    @Dependency(\.{feature}LocalDataSource) private var localDataSource
    @Dependency(\.{feature}RemoteDataSource) private var remoteDataSource

    func fetchLocal(id: String) async throws -> {Entity} {
        try await localDataSource.fetch(id: id)
    }

    func fetchRemote(id: String) async throws -> {Entity} {
        let entity = try await remoteDataSource.fetch(id: id)
        // Cache in local storage
        try await localDataSource.save(entity)
        return entity
    }

    func fetch(id: String) async throws -> {Entity} {
        do {
            return try await fetchLocal(id: id)
        } catch {
            return try await fetchRemote(id: id)
        }
    }

    func save(_ entity: {Entity}) async throws {
        try await localDataSource.save(entity)
    }

    func delete(id: String) async throws {
        try await localDataSource.delete(id: id)
    }

    func sync(id: String) async throws {
        do {
            let entity = try await remoteDataSource.fetch(id: id)
            try await localDataSource.save(entity)
        } catch {
            // Log but don't throw - offline-first approach
            #if DEBUG
            print("Failed to sync {entity}: \(error)")
            #endif
        }
    }
}

// MARK: - Dependency Key
struct {Feature}RepositoryKey: DependencyKey {
    static let liveValue: any {Feature}RepositoryProtocol = {Feature}Repository()
    static let testValue: any {Feature}RepositoryProtocol = Mock{Feature}Repository()
    static let previewValue: any {Feature}RepositoryProtocol = Mock{Feature}Repository()
}

extension DependencyValues {
    var {feature}Repository: any {Feature}RepositoryProtocol {
        get { self[{Feature}RepositoryKey.self] }
        set { self[{Feature}RepositoryKey.self] = newValue }
    }
}
```

### Step 11: Create Mock Implementations

```swift
// Sources/Features/{Feature}Feature/Infrastructure/Mocks/Mock{Feature}LocalDataSource.swift
import Foundation
import Entities

struct Mock{Feature}LocalDataSource: {Feature}LocalDataSourceProtocol {
    func fetch(id: String) async throws -> {Entity} {
        // Return mock entity
        {Entity}.mock
    }

    func save(_ entity: {Entity}) async throws {
        // No-op for mock
    }

    func delete(id: String) async throws {
        // No-op for mock
    }
}
```

```swift
// Sources/Features/{Feature}Feature/Infrastructure/Mocks/Mock{Feature}RemoteDataSource.swift
import Foundation
import Entities

struct Mock{Feature}RemoteDataSource: {Feature}RemoteDataSourceProtocol {
    func fetch(id: String) async throws -> {Entity} {
        // Return mock entity
        {Entity}.mock
    }

    func create(_ entity: {Entity}) async throws -> {Entity} {
        // Return the same entity
        entity
    }

    func update(_ entity: {Entity}) async throws -> {Entity} {
        // Return the same entity
        entity
    }
}
```

```swift
// Sources/Features/{Feature}Feature/Infrastructure/Mocks/Mock{Feature}Repository.swift
import Foundation
import Entities

actor Mock{Feature}Repository: {Feature}RepositoryProtocol {
    private var stored{Entities}: [String: {Entity}] = [:]
    var shouldFail: Bool = false
    var delay: TimeInterval = 0

    init() {}

    func fetchLocal(id: String) async throws -> {Entity} {
        if shouldFail {
            throw {Feature}Error.notFound
        }

        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        guard let entity = stored{Entities}[id] else {
            throw {Feature}Error.notFound
        }

        return entity
    }

    func fetchRemote(id: String) async throws -> {Entity} {
        if shouldFail {
            throw {Feature}Error.networkUnavailable
        }

        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        let entity = createMock{Entity}(id: id)
        stored{Entities}[id] = entity
        return entity
    }

    func fetch(id: String) async throws -> {Entity} {
        try await fetchLocal(id: id)
    }

    func save(_ entity: {Entity}) async throws {
        if shouldFail {
            throw {Feature}Error.invalidData
        }

        stored{Entities}[entity.id.uuidString] = entity
    }

    func delete(id: String) async throws {
        stored{Entities}.removeValue(forKey: id)
    }

    func sync(id: String) async throws {
        if !shouldFail {
            let entity = createMock{Entity}(id: id)
            stored{Entities}[id] = entity
        }
    }

    private func createMock{Entity}(id: String) -> {Entity} {
        {Entity}(
            id: UUID(uuidString: id) ?? UUID(),
            title: "Mock {Entity} \(id)"
            // ... other mock properties
        )
    }
}
```

### Step 12: Create Analytics Service
```swift
// Sources/Features/{Feature}Feature/Infrastructure/Analytics/{Feature}AnalyticsService.swift
import Foundation
import Dependencies
import AnalyticsService

// MARK: - Analytics Events
enum {Feature}AnalyticsEvent: AnalyticsEvent, Equatable, Sendable {
    case screenViewed
    case emptyStateShown
    case refreshRequested
    case error(error: String, context: String)

    var name: String {
        switch self {
        case .screenViewed: return "{feature}_screen_viewed"
        case .emptyStateShown: return "{feature}_empty_state_shown"
        case .refreshRequested: return "{feature}_refresh_requested"
        case .error: return "error"
        }
    }

    var properties: [String: String] {
        switch self {
        case .screenViewed:
            return [:]
        case .emptyStateShown:
            return [:]
        case .refreshRequested:
            return [:]
        case let .error(error, context):
            return ["error": error, "context": context]
        }
    }
}

protocol {Feature}AnalyticsProtocol: Sendable {
    func track(_ event: {Feature}AnalyticsEvent) async
}

// MARK: - Analytics Service
actor {Feature}AnalyticsService: {Feature}AnalyticsProtocol, Sendable {
    private var events: [{Feature}AnalyticsEvent] = []

    init() {}

    func track(_ event: {Feature}AnalyticsEvent) async {
        events.append(event)

        // Only use external analytics service in live/production mode
        // In preview/test mode, just store the event locally
        #if !DEBUG
        @Dependency(\.analyticsService) var analyticsService
        await analyticsService.track(event)
        #endif
    }

    func getEvents() -> [{Feature}AnalyticsEvent] {
        events
    }

    func clearEvents() {
        events.removeAll()
    }
}

// MARK: - Dependency Key
struct {Feature}AnalyticsKey: DependencyKey {
    static let liveValue: any {Feature}AnalyticsProtocol = {Feature}AnalyticsService()
    static let testValue: any {Feature}AnalyticsProtocol = Mock{Feature}AnalyticsService()
    static let previewValue: any {Feature}AnalyticsProtocol = Mock{Feature}AnalyticsService()
}

extension DependencyValues {
    var {feature}Analytics: any {Feature}AnalyticsProtocol {
        get { self[{Feature}AnalyticsKey.self] }
        set { self[{Feature}AnalyticsKey.self] = newValue }
    }
}
```

```swift
// Sources/Features/{Feature}Feature/Infrastructure/Mocks/Mock{Feature}AnalyticsService.swift
import Foundation

actor Mock{Feature}AnalyticsService: {Feature}AnalyticsProtocol {
    private var events: [{Feature}AnalyticsEvent] = []

    init() {}

    func track(_ event: {Feature}AnalyticsEvent) async {
        events.append(event)
    }

    func getEvents() -> [{Feature}AnalyticsEvent] {
        events
    }

    func clearEvents() {
        events.removeAll()
    }
}
```

### Step 13: Create TCA Feature Reducer

```swift
// Sources/Features/{Feature}Feature/Presentation/{Feature}Feature.swift
import ComposableArchitecture
import Dependencies
import SwiftUI
import Entities

@Reducer
public struct {Feature}Feature: Sendable {
    // MARK: - State
    @ObservableState
    public struct State: Equatable {
        public var entities: [{Entity}] = []
        public var selectedEntity: {Entity}?
        public var isLoading: Bool = false
        public var searchQuery: String = ""
        @Presents public var alert: AlertState<Action.Alert>?
        
        public init() {}
    }
    
    // MARK: - Action
    public enum Action {
        // View Lifecycle
        case onAppear
        case onDisappear
        
        // User Actions
        case searchQueryChanged(String)
        case selectEntity({Entity})
        case refresh
        case save({Entity})
        case delete(String)
        
        // System Responses
        case entitiesResponse(TaskResult<[{Entity}]>)
        case saveResponse(TaskResult<Void>)
        case deleteResponse(TaskResult<Void>)
        
        // Child Actions
        case alert(PresentationAction<Alert>)
        
        // Delegate Actions
        case delegate(Delegate)
        
        @CasePathable
        public enum Alert: Equatable {
            case retry
            case dismiss
        }
        
        @CasePathable
        public enum Delegate: Equatable {
            case entity{Selected}({Entity})
            case dismiss
        }
    }
    
    // MARK: - Dependencies
    @Dependency(\.{feature}Repository) var repository: {Feature}RepositoryProtocol
    @Dependency(\.analytics) var analytics: AnalyticsProtocol
    
    public init() {}
    
    // MARK: - Reducer Body
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return handleOnAppear(&state)
                
            case .onDisappear:
                return .none
                
            case let .searchQueryChanged(query):
                state.searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                return .none
                
            case let .selectEntity(entity):
                state.selectedEntity = entity
                return .send(.delegate(.entity{Selected}(entity)))
                
            case .refresh:
                return handleRefresh(&state)
                
            case let .save(entity):
                return handleSave(entity)
                
            case let .delete(id):
                return handleDelete(id: id, state: &state)
                
            case let .entitiesResponse(.success(entities)):
                state.isLoading = false
                state.entities = entities
                return .none
                
            case let .entitiesResponse(.failure(error)):
                return handleError(error: error, state: &state)
                
            case .saveResponse(.success):
                return .none
                
            case let .saveResponse(.failure(error)):
                return handleError(error: error, state: &state)
                
            case .deleteResponse(.success):
                return .none
                
            case let .deleteResponse(.failure(error)):
                return handleError(error: error, state: &state)
                
            case .alert(.presented(.retry)):
                state.alert = nil
                return .send(.refresh)
                
            case .alert:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    // MARK: - Private Methods
    private func handleOnAppear(_ state: inout State) -> Effect<Action> {
        guard state.entities.isEmpty else { return .none }
        
        state.isLoading = true
        
        return .run { send in
            // For this template, we'll assume a method to fetch all entities
            // Adjust based on your specific feature requirements
            await send(.entitiesResponse(
                await TaskResult {
                    // This would need to be implemented in your repository
                    // For now, return empty array as placeholder
                    return [{Entity}]()
                }
            ))
        }
    }
    
    private func handleRefresh(_ state: inout State) -> Effect<Action> {
        state.isLoading = true
        
        return .run { send in
            await send(.entitiesResponse(
                await TaskResult {
                    // Implement refresh logic
                    return [{Entity}]()
                }
            ))
        }
    }
    
    private func handleSave(_ entity: {Entity}) -> Effect<Action> {
        return .run { send in
            await send(.saveResponse(
                await TaskResult {
                    try await repository.save(entity)
                }
            ))
        }
    }
    
    private func handleDelete(id: String, state: inout State) -> Effect<Action> {
        state.entities.removeAll { $0.id.uuidString == id }
        
        return .run { send in
            await send(.deleteResponse(
                await TaskResult {
                    try await repository.delete(id: id)
                }
            ))
        }
    }
    
    private func handleError(error: Error, state: inout State) -> Effect<Action> {
        state.isLoading = false
        state.alert = AlertState {
            TextState("Error")
        } actions: {
            ButtonState(action: .retry) {
                TextState("Retry")
            }
            ButtonState(role: .cancel, action: .dismiss) {
                TextState("Cancel")
            }
        } message: {
            TextState(error.localizedDescription)
        }
        
        return .run { [analytics] _ in
            await analytics.track(.error(
                error: error.localizedDescription,
                context: "{feature}_operation"
            ))
        }
    }
}
```

### Step 14: Create API Endpoints (if needed)

```swift
// Sources/Features/{Feature}Feature/Infrastructure/Endpoints.swift
import Foundation
import NetworkService

public enum {Feature}Endpoint {
    case get{Entity}(String)
    case create{Entity}({Entity}DTO)
    case update{Entity}(String, {Entity}DTO)
    case delete{Entity}(String)
}

extension {Feature}Endpoint: APIEndpoint {
    public var path: String {
        switch self {
        case let .get{Entity}(id):
            return "/{features}/\(id)"
        case .create{Entity}:
            return "/{features}"
        case let .update{Entity}(id, _):
            return "/{features}/\(id)"
        case let .delete{Entity}(id):
            return "/{features}/\(id)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .get{Entity}:
            return .GET
        case .create{Entity}:
            return .POST
        case .update{Entity}:
            return .PUT
        case .delete{Entity}:
            return .DELETE
        }
    }
    
    public var body: Data? {
        switch self {
        case let .create{Entity}(dto):
            return try? JSONEncoder().encode(dto)
        case let .update{Entity}(_, dto):
            return try? JSONEncoder().encode(dto)
        default:
            return nil
        }
    }
}
```

### Step 15: Update Package.swift

Add your new feature to the Package.swift file:

```swift
// In products array:
.library(name: "{Feature}Feature", targets: ["{Feature}Feature"]),

// In targets array:
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
),

// Add test target:
.testTarget(
    name: "{Feature}FeatureTests",
    dependencies: ["{Feature}Feature"],
    path: "Tests/{Feature}FeatureTests"
)
```

### Step 16: Create Basic Tests

```swift
// Tests/{Feature}FeatureTests/{Feature}FeatureTests.swift
import XCTest
import ComposableArchitecture
@testable import {Feature}Feature

final class {Feature}FeatureTests: XCTestCase {
    @MainActor
    func testBasicFunctionality() async {
        let store = TestStore(initialState: {Feature}Feature.State()) {
            {Feature}Feature()
        } withDependencies: {
            $0.{feature}Repository = Mock{Feature}Repository()
        }
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(.entitiesResponse(.success([]))) {
            $0.isLoading = false
            $0.entities = []
        }
    }
}
```

## 🎯 Architecture Compliance Checklist

Before considering your feature complete, verify:

### ✅ Feature-Scoped Architecture
- [ ] DTOs are in `Sources/Features/{Feature}Feature/Data/DTOs/`
- [ ] Mappers are in `Sources/Features/{Feature}Feature/Infrastructure/`
- [ ] No global abstractions unless shared across multiple features
- [ ] Feature can evolve independently

### ✅ Pragmatic Simplification
- [ ] Only create abstractions that add meaningful value
- [ ] Direct usage of existing services via `@Dependency`
- [ ] No translation layers that just shuffle fields
- [ ] Minimal, focused interfaces

### ✅ Dependency-Driven Design
- [ ] All dependencies injected via `@Dependency` wrapper
- [ ] Repository registered with `DependencyKey`
- [ ] Protocol interfaces where abstraction adds value
- [ ] Clean separation between interface and implementation

### ✅ Entity-First Domain Modeling
- [ ] Domain entity is the single source of truth
- [ ] Codable entities serve multiple purposes
- [ ] Business logic embedded in entities where appropriate
- [ ] No artificial data/domain boundaries

### ✅ Quality Standards
- [ ] All async functions marked properly
- [ ] Actor-based concurrent design where needed
- [ ] Comprehensive error handling with meaningful messages
- [ ] Analytics tracking for user interactions
- [ ] Mock implementations for testing
- [ ] Basic unit tests written

### ✅ Package Integration
- [ ] Feature added to Package.swift products and targets
- [ ] Dependencies correctly specified
- [ ] Test target created and configured
- [ ] No circular dependencies

## 🔧 Common Patterns & Best Practices

### Repository Pattern Implementation
- **Local-first approach**: Always try local data first, fall back to remote
- **Automatic caching**: Remote fetches automatically save to local storage
- **Graceful sync**: Sync operations don't throw errors, just log failures
- **Consistent naming**: Use domain terminology (`gameTitle` not `gameId`)

### Error Handling Strategy
- **Feature-specific errors**: Create dedicated error enums for each feature
- **Meaningful messages**: Provide clear error descriptions and recovery suggestions
- **User-friendly presentation**: Transform technical errors into actionable user messages
- **Analytics integration**: Track errors for debugging and product insights

### TCA Patterns
- **State separation**: Keep UI state separate from business data
- **Effect composition**: Use `TaskResult` for async operations
- **Presentation management**: Use `@Presents` for alerts and sheets
- **Delegate pattern**: Communicate with parent features via delegate actions

### Testing Strategy
- **Mock repositories**: Create simple mocks that mirror real interfaces
- **TestStore usage**: Use TCA's TestStore for predictable testing
- **Dependency injection**: Replace real dependencies with test doubles
- **Focused scenarios**: Test specific user flows and edge cases

## 🚫 Anti-Patterns to Avoid

### 1. Global Abstraction Creep
```swift
// ❌ DON'T: Global DTOs used by one feature
Sources/DTOs/{Feature}DTO.swift

// ✅ DO: Feature-scoped DTOs
Sources/Features/{Feature}Feature/Data/DTOs/{Feature}DTO.swift
```

### 2. Unnecessary Translation Layers
```swift
// ❌ DON'T: Mapper that just shuffles identical fields
func map(_ dto: DTO) -> Entity {
    return Entity(field1: dto.field1, field2: dto.field2)
}

// ✅ DO: Only create mappers for meaningful transformation
```

### 3. Protocol Over-Engineering
```swift
// ❌ DON'T: Protocols for everything
protocol {Feature}NetworkServiceProtocol
protocol {Feature}ValidationServiceProtocol

// ✅ DO: Use existing service abstractions
@Dependency(\.persistenceService)
@Dependency(\.networkService)
```

### 4. Complex State Management
```swift
// ❌ DON'T: Overly complex state structures
struct State {
    var loadingStates: [String: Bool]
    var errorStates: [String: Error?]
    var dataStates: [String: Any]
}

// ✅ DO: Simple, focused state
struct State {
    var entities: [Entity]
    var isLoading: Bool
    @Presents var alert: AlertState<Action.Alert>?
}
```

## 📚 Additional Resources

- **Architecture Overview**: `docs/architecture/architecture-overview.md`
- **TCA Documentation**: [pointfreeco/swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture)
- **Swift Dependencies**: [pointfreeco/swift-dependencies](https://github.com/pointfreeco/swift-dependencies)
- **Existing Features**: Study `RulesFeature` as a reference implementation

---

*This template represents the current architectural standards and will evolve as new patterns emerge.*

*Last updated: 2025-08-25*
*Follows Feature-Scoped Architecture principles*