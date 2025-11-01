# Anti-Patterns to Avoid

This document outlines common mistakes and anti-patterns to avoid when creating features in the Rulebook iOS project.

## 1. Global Abstraction Creep

### DON'T: Global DTOs used by one feature

```swift
// ❌ WRONG
Sources/DTOs/{Feature}DTO.swift
```

**Why it's wrong**: Creates unnecessary coupling and makes it harder for features to evolve independently.

### DO: Feature-scoped DTOs

```swift
// ✅ CORRECT
Sources/Features/{Feature}Feature/Data/DTOs/{Feature}DTO.swift
```

**Why it's right**: Keeps DTOs scoped to the feature that uses them, allowing independent evolution.

---

## 2. Unnecessary Translation Layers

### DON'T: Mapper that just shuffles identical fields

```swift
// ❌ WRONG
func map(_ dto: DTO) -> Entity {
    return Entity(field1: dto.field1, field2: dto.field2)
}
```

**Why it's wrong**: Adds no value, just creates extra code to maintain.

### DO: Only create mappers for meaningful transformation

```swift
// ✅ CORRECT
// Only create a mapper when there's actual transformation logic:
func map(_ dto: DTO) -> Entity {
    return Entity(
        field1: dto.field1,
        field2: transformComplexData(dto.apiSpecificField),
        field3: dto.timestamp.toLocalTime()
    )
}

// Or if fields are identical, just use the same type
```

**Why it's right**: Mappers should only exist when they perform meaningful transformations between different representations.

---

## 3. Protocol Over-Engineering

### DON'T: Protocols for everything

```swift
// ❌ WRONG
protocol {Feature}NetworkServiceProtocol
protocol {Feature}ValidationServiceProtocol
protocol {Feature}PersistenceServiceProtocol

// Then wrapping existing services unnecessarily
actor {Feature}NetworkService: {Feature}NetworkServiceProtocol {
    @Dependency(\.networkService) private var networkService

    func fetch() async throws -> Data {
        // Just forwarding to the real service
        return try await networkService.sendRequest(...)
    }
}
```

**Why it's wrong**: Creates unnecessary abstraction layers that add no value and make code harder to follow.

### DO: Use existing service abstractions

```swift
// ✅ CORRECT
@Dependency(\.persistenceService)
@Dependency(\.networkService)
@Dependency(\.analyticsService)
```

**Why it's right**: Use the existing dependency injection system and service protocols. Only create feature-specific protocols for your feature's repository and data sources.

---

## 4. Complex State Management

### DON'T: Overly complex state structures

```swift
// ❌ WRONG
struct State {
    var loadingStates: [String: Bool]
    var errorStates: [String: Error?]
    var dataStates: [String: Any]
    var cacheTimestamps: [String: Date]
}
```

**Why it's wrong**: Over-engineered, hard to reason about, difficult to test, and uses type-unsafe `Any`.

### DO: Simple, focused state

```swift
// ✅ CORRECT
struct State {
    var entities: [Entity]
    var isLoading: Bool
    @Presents var alert: AlertState<Action.Alert>?
}
```

**Why it's right**: Clear, type-safe, easy to understand and test. Use TCA's built-in patterns for managing UI state.

---

## 5. Ignoring Actor Isolation

### DON'T: Non-actor types for concurrent operations

```swift
// ❌ WRONG
class {Feature}Repository: {Feature}RepositoryProtocol {
    private var cache: [String: Entity] = [:]

    func save(_ entity: Entity) async throws {
        // Race condition! Multiple concurrent calls can corrupt cache
        cache[entity.id.uuidString] = entity
    }
}
```

**Why it's wrong**: Creates potential race conditions and data corruption in concurrent environments.

### DO: Use actors for concurrent state

```swift
// ✅ CORRECT
actor {Feature}Repository: {Feature}RepositoryProtocol {
    private var cache: [String: Entity] = [:]

    func save(_ entity: Entity) async throws {
        // Safe! Actor ensures serial access
        cache[entity.id.uuidString] = entity
    }
}
```

**Why it's right**: Actors provide built-in synchronization and prevent race conditions.

---

## 6. Missing Error Handling

### DON'T: Generic or missing error handling

```swift
// ❌ WRONG
func fetch(id: String) async throws -> Entity {
    // Just letting errors bubble up without context
    return try await remoteDataSource.fetch(id: id)
}
```

**Why it's wrong**: Loses context about where and why the error occurred, making debugging difficult.

### DO: Feature-specific errors with context

```swift
// ✅ CORRECT
func fetch(id: String) async throws -> Entity {
    do {
        return try await remoteDataSource.fetch(id: id)
    } catch {
        throw {Feature}Error.fetchFailed("Could not fetch entity: \(error.localizedDescription)")
    }
}
```

**Why it's right**: Provides clear context for debugging and better user-facing error messages.

---

## 7. Forgetting Sendable Conformance

### DON'T: Missing Sendable conformance

```swift
// ❌ WRONG
public struct {Entity}: Codable, Equatable {
    // Missing Sendable!
}

public protocol {Feature}RepositoryProtocol {
    // Missing Sendable!
}
```

**Why it's wrong**: Can cause compiler warnings/errors when used in concurrent contexts with strict concurrency checking.

### DO: Always add Sendable conformance

```swift
// ✅ CORRECT
public struct {Entity}: Codable, Equatable, Sendable {
    // Now safe to use across actor boundaries
}

public protocol {Feature}RepositoryProtocol: Sendable {
    // Now safe to use as a dependency
}
```

**Why it's right**: Ensures type safety in concurrent code and satisfies Swift 6's strict concurrency requirements.

---

## 8. Not Using Dependency Injection

### DON'T: Hardcoded dependencies

```swift
// ❌ WRONG
actor {Feature}Repository {
    private let localDataSource = {Feature}LocalDataSource()
    private let remoteDataSource = {Feature}RemoteDataSource()

    // Impossible to test with mocks!
}
```

**Why it's wrong**: Makes testing difficult, creates tight coupling, and prevents using mocks or test doubles.

### DO: Inject dependencies via initializer

```swift
// ✅ CORRECT
actor {Feature}Repository {
    private let localDataSource: {Feature}LocalDataSourceProtocol
    private let remoteDataSource: {Feature}RemoteDataSourceProtocol

    public init(
        localDataSource: {Feature}LocalDataSourceProtocol,
        remoteDataSource: {Feature}RemoteDataSourceProtocol
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
}
```

**Why it's right**: Allows for easy testing with mocks and provides flexibility in implementation.

---

## 9. Not Providing Mock Implementations

### DON'T: Skip mock implementations

```swift
// ❌ WRONG
// No mock repository created
// Tests have to use real implementations or create their own mocks every time
```

**Why it's wrong**: Makes testing harder and leads to inconsistent test doubles across different test files.

### DO: Create mock implementations

```swift
// ✅ CORRECT
public actor Mock{Feature}Repository: {Feature}RepositoryProtocol {
    private var storedEntities: [String: Entity] = [:]
    public var shouldFail: Bool = false
    public var delay: TimeInterval = 0

    // ... implement all protocol methods with test-friendly behavior
}
```

**Why it's right**: Provides consistent, controllable test doubles that can simulate various scenarios (failures, delays, etc.).

---

## 10. Ignoring the Local-First Pattern

### DON'T: Always fetch from remote

```swift
// ❌ WRONG
func fetch(id: String) async throws -> Entity {
    // Always going to the network, even when we might have local data
    return try await remoteDataSource.fetch(id: id)
}
```

**Why it's wrong**: Poor user experience (slower), wastes network bandwidth, fails immediately when offline.

### DO: Try local first, fall back to remote

```swift
// ✅ CORRECT
func fetch(id: String) async throws -> Entity {
    do {
        return try await localDataSource.fetch(id: id)
    } catch {
        return try await remoteDataSource.fetch(id: id)
    }
}
```

**Why it's right**: Provides instant data when available, gracefully falls back to network, and works offline.

---

## 11. Missing Analytics Tracking

### DON'T: No analytics in your feature

```swift
// ❌ WRONG
// No analytics tracking for user interactions or errors
```

**Why it's wrong**: Makes it impossible to understand how users interact with the feature or debug production issues.

### DO: Track key events and errors

```swift
// ✅ CORRECT
private func handleError(error: Error, state: inout State) -> Effect<Action> {
    state.isLoading = false
    state.alert = AlertState { /* ... */ }

    return .run { [analytics] _ in
        await analytics.track(.error(
            error: error.localizedDescription,
            context: "{feature}_operation"
        ))
    }
}
```

**Why it's right**: Provides visibility into feature usage and helps debug production issues.

---

## Summary

The key principles to remember:

1. **Keep features self-contained** - Avoid global abstractions
2. **Only abstract when necessary** - Don't create layers that add no value
3. **Use existing services directly** - Don't wrap what's already abstracted
4. **Keep state simple** - Avoid over-engineering state management
5. **Embrace concurrency** - Use actors for concurrent state
6. **Handle errors properly** - Provide context and meaningful messages
7. **Always use Sendable** - Ensure thread-safety
8. **Inject dependencies** - Make code testable
9. **Provide mocks** - Make testing easier for everyone
10. **Go local-first** - Optimize for performance and offline use
11. **Track analytics** - Understand usage and debug issues
