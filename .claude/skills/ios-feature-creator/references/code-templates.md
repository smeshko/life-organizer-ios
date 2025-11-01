# Code Templates

This document contains all code templates for implementing features in the Rulebook iOS project.

## Entity Structure

**Location**: `Sources/Entities/{Entity}.swift`

```swift
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

## DTO Structure

**Location**: `Sources/Features/{Feature}Feature/Data/DTOs/{Entity}DTO.swift`

```swift
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

## Error Enum

**Location**: `Sources/Features/{Feature}Feature/Domain/Errors/{Feature}Error.swift`

```swift
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

## Protocol Definitions

### Local Data Source Protocol

**Location**: `Sources/Features/{Feature}Feature/Domain/Protocols/{Feature}LocalDataSourceProtocol.swift`

```swift
import Foundation
import Entities

public protocol {Feature}LocalDataSourceProtocol: Sendable {
    func fetch(id: String) async throws -> {Entity}
    func save(_ entity: {Entity}) async throws
    func delete(id: String) async throws
}
```

### Remote Data Source Protocol

**Location**: `Sources/Features/{Feature}Feature/Domain/Protocols/{Feature}RemoteDataSourceProtocol.swift`

```swift
import Foundation
import Entities

public protocol {Feature}RemoteDataSourceProtocol: Sendable {
    func fetch(id: String) async throws -> {Entity}
    func create(_ entity: {Entity}) async throws -> {Entity}
    func update(_ entity: {Entity}) async throws -> {Entity}
}
```

### Repository Protocol

**Location**: `Sources/Features/{Feature}Feature/Domain/Protocols/{Feature}RepositoryProtocol.swift`

```swift
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

## Mapper Implementation

**Location**: `Sources/Features/{Feature}Feature/Infrastructure/{Entity}Mapper.swift`

```swift
import Foundation
import Entities

public protocol {Entity}Mapping {
    func toDomain(_ dto: {Entity}DTO) -> {Entity}
    func toDTO(_ entity: {Entity}) -> {Entity}DTO
}

public struct {Entity}Mapper: {Entity}Mapping {
    public init() {}

    public func toDomain(_ dto: {Entity}DTO) -> {Entity} {
        {Entity}(
            title: dto.title
            // ... map other properties with any necessary transformations
        )
    }

    public func toDTO(_ entity: {Entity}) -> {Entity}DTO {
        {Entity}DTO(
            title: entity.title
            // ... map other properties
        )
    }
}
```

## Data Sources

### Local Data Source

**Location**: `Sources/Features/{Feature}Feature/Data/DataSources/{Feature}LocalDataSource.swift`

```swift
import Foundation
import PersistenceService
import Dependencies
import Entities

public actor {Feature}LocalDataSource: {Feature}LocalDataSourceProtocol {
    @Dependency(\.persistenceService) private var persistenceService

    public init() {}

    public func fetch(id: String) async throws -> {Entity} {
        guard let loaded = try await persistenceService.load({Entity}.self, forKey: id) else {
            throw {Feature}Error.notFound
        }
        return loaded
    }

    public func save(_ entity: {Entity}) async throws {
        try await persistenceService.save(entity, forKey: entity.id.uuidString)
    }

    public func delete(id: String) async throws {
        try await persistenceService.deleteData(forKey: id)
    }
}
```

### Remote Data Source

**Location**: `Sources/Features/{Feature}Feature/Data/DataSources/{Feature}RemoteDataSource.swift`

```swift
import Foundation
import Dependencies
import Entities
import NetworkService

public actor {Feature}RemoteDataSource: {Feature}RemoteDataSourceProtocol {
    @Dependency(\.networkService) private var networkService

    public init() {}

    public func fetch(id: String) async throws -> {Entity} {
        let dto: {Entity}DTO = try await networkService.sendRequest(
            to: {Feature}Endpoint.get{Entity}(id)
        )
        return {Entity}Mapper().toDomain(dto)
    }

    public func create(_ entity: {Entity}) async throws -> {Entity} {
        let dto = {Entity}Mapper().toDTO(entity)
        let responseDTO: {Entity}DTO = try await networkService.sendRequest(
            to: {Feature}Endpoint.create{Entity}(dto)
        )
        return {Entity}Mapper().toDomain(responseDTO)
    }

    public func update(_ entity: {Entity}) async throws -> {Entity} {
        let dto = {Entity}Mapper().toDTO(entity)
        let responseDTO: {Entity}DTO = try await networkService.sendRequest(
            to: {Feature}Endpoint.update{Entity}(entity.id.uuidString, dto)
        )
        return {Entity}Mapper().toDomain(responseDTO)
    }
}
```

## Repository with Dependency Injection

**Location**: `Sources/Features/{Feature}Feature/Data/Repositories/{Feature}Repository.swift`

```swift
import Foundation
import Dependencies
import Entities

public actor {Feature}Repository: {Feature}RepositoryProtocol {
    private let localDataSource: {Feature}LocalDataSourceProtocol
    private let remoteDataSource: {Feature}RemoteDataSourceProtocol

    public init(
        localDataSource: {Feature}LocalDataSourceProtocol,
        remoteDataSource: {Feature}RemoteDataSourceProtocol
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    public func fetchLocal(id: String) async throws -> {Entity} {
        try await localDataSource.fetch(id: id)
    }

    public func fetchRemote(id: String) async throws -> {Entity} {
        let entity = try await remoteDataSource.fetch(id: id)
        // Cache in local storage
        try await localDataSource.save(entity)
        return entity
    }

    public func fetch(id: String) async throws -> {Entity} {
        do {
            return try await fetchLocal(id: id)
        } catch {
            return try await fetchRemote(id: id)
        }
    }

    public func save(_ entity: {Entity}) async throws {
        try await localDataSource.save(entity)
    }

    public func delete(id: String) async throws {
        try await localDataSource.delete(id: id)
    }

    public func sync(id: String) async throws {
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
public struct {Feature}RepositoryKey: DependencyKey {
    public static let liveValue: {Feature}RepositoryProtocol = {Feature}Repository(
        localDataSource: {Feature}LocalDataSource(),
        remoteDataSource: {Feature}RemoteDataSource()
    )

    public static let testValue: {Feature}RepositoryProtocol = Mock{Feature}Repository()
}

extension DependencyValues {
    public var {feature}Repository: {Feature}RepositoryProtocol {
        get { self[{Feature}RepositoryKey.self] }
        set { self[{Feature}RepositoryKey.self] = newValue }
    }
}
```

## Mock Repository

**Location**: `Sources/Features/{Feature}Feature/Infrastructure/Mocks/Mock{Feature}Repository.swift`

```swift
import Foundation
import Entities

public actor Mock{Feature}Repository: {Feature}RepositoryProtocol {
    private var stored{Entities}: [String: {Entity}] = [:]
    public var shouldFail: Bool = false
    public var delay: TimeInterval = 0

    public init() {}

    public func fetchLocal(id: String) async throws -> {Entity} {
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

    public func fetchRemote(id: String) async throws -> {Entity} {
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

    public func fetch(id: String) async throws -> {Entity} {
        try await fetchLocal(id: id)
    }

    public func save(_ entity: {Entity}) async throws {
        if shouldFail {
            throw {Feature}Error.invalidData
        }

        stored{Entities}[entity.id.uuidString] = entity
    }

    public func delete(id: String) async throws {
        stored{Entities}.removeValue(forKey: id)
    }

    public func sync(id: String) async throws {
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

## Analytics Service

**Location**: `Sources/Features/{Feature}Feature/Infrastructure/Analytics/{Feature}Analytics.swift`

```swift
public enum {Feature}AnalyticsEvent: AnalyticsEvent {
    case screenViewed
    case emptyStateShown
    case refreshRequested

    public var name: String {
        switch self {
        case .screenViewed: return "{feature}_screen_viewed"
        case .emptyStateShown: return "{feature}_empty_state_shown"
        case .refreshRequested: return "{feature}_refresh_requested"
        }
    }

    public var properties: [String: String] {
        switch self {
        case .screenViewed:
            return [:]
        case .emptyStateShown:
            return [:]
        case .refreshRequested:
            return [:]
        }
    }
}

public struct {Feature}Analytics: Sendable {
    @Dependency(\.analyticsService) private var analyticsService

    public init() {}

    public func track(_ event: {Feature}AnalyticsEvent) async {
        await analyticsService.track(event)
    }
}

// MARK: - Dependency Key for {Feature}Analytics
public enum {Feature}AnalyticsKey: DependencyKey {
    public static let liveValue = {Feature}Analytics()
    public static let testValue = {Feature}Analytics()
}

extension DependencyValues {
    public var {feature}Analytics: {Feature}Analytics {
        get { self[{Feature}AnalyticsKey.self] }
        set { self[{Feature}AnalyticsKey.self] = newValue }
    }
}
```

## TCA Reducer

**Location**: `Sources/Features/{Feature}Feature/Presentation/{Feature}Feature.swift`

```swift
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

## API Endpoints

**Location**: `Sources/Features/{Feature}Feature/Infrastructure/Endpoints.swift`

```swift
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

## Test Structure

**Location**: `Tests/{Feature}FeatureTests/{Feature}FeatureTests.swift`

```swift
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
