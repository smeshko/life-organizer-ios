# Service Implementation Guide

This guide provides step-by-step instructions for implementing new services in the Rulebook iOS project.

## Service Architecture Pattern

All services in the Rulebook iOS project follow this consistent structure:

```
YourService/
├── Interface/
│   └── YourServiceProtocol.swift       # Protocol definition with comprehensive documentation
├── Live/
│   └── YourService.swift               # Production implementation
├── Mock/
│   └── MockYourService.swift           # Testing implementation with helpers
└── YourServiceDependency.swift         # TCA dependency registration
```

## Step 1: Create the Protocol Interface

**File**: `Interface/YourServiceProtocol.swift`

### Key Protocol Design Guidelines:
- Use comprehensive documentation with examples
- Follow async/await patterns consistently
- Include design principles section
- Make protocols `Sendable` for concurrency safety
- Use generic types where appropriate for type safety
- Document error cases thoroughly

### Protocol Structure Requirements:
- Header documentation explaining the service purpose
- Design principles section outlining key architectural decisions
- Typical usage examples showing common patterns
- Comprehensive method documentation with parameters, returns, and errors
- Example code blocks for each method

## Step 2: Implement the Live Service

**File**: `Live/YourService.swift`

### Key Implementation Guidelines:
- Use `struct` with `Sendable` conformance
- Follow consistent error handling patterns
- Transform external errors to `AppError` types
- Include private helper methods section
- Handle async operations properly
- Use dependency injection for external services

### Error Handling Pattern:
```swift
do {
    // Implementation logic
    return result
} catch let error as AppError {
    // Re-throw known app errors
    throw error
} catch SpecificErrorType {
    // Transform specific errors to AppError
    throw AppError.yourService(.specificError)
} catch {
    // Handle unexpected errors
    throw AppError.yourService(.unknownError(error.localizedDescription))
}
```

## Step 3: Create the Mock Implementation

**File**: `Mock/MockYourService.swift`

### Key Mock Guidelines:
- Use `actor` for thread-safe mock state
- Include test helpers for configuration
- Simulate realistic delays
- Provide error simulation capabilities
- Include reset functionality for clean tests
- Create specific mock error types

### Required Test Helpers:
- `setMockResult<T>(_ result: T, forMethod method: String)` - Configure mock return values
- `simulateError(_ shouldError: Bool = true)` - Enable error simulation
- `reset()` - Reset mock state between tests

### Mock State Management:
- Store mock results in a dictionary
- Track error simulation state
- Provide default mock return values
- Define custom mock error types with `LocalizedError` conformance

## Step 4: Register with TCA Dependencies

**File**: `YourServiceDependency.swift`

### Key Dependency Guidelines:
- Use private enum for dependency key
- Provide separate values for live, test, and preview
- Use clear, consistent naming for dependency accessor
- Follow existing patterns in the codebase

### Dependency Registration Pattern:
```swift
private enum YourServiceKey: DependencyKey {
    static let liveValue: YourServiceProtocol = YourService()
    static let testValue: YourServiceProtocol = MockYourService()
    static let previewValue: YourServiceProtocol = MockYourService()
}

public extension DependencyValues {
    var yourService: YourServiceProtocol {
        get { self[YourServiceKey.self] }
        set { self[YourServiceKey.self] = newValue }
    }
}
```

## Step 5: Define Service-Specific Errors (if needed)

If your service needs custom errors, add them to `Framework/AppError.swift`:

### Error Definition Pattern:
```swift
// In AppError.swift
public enum AppError: Error, Equatable {
    // ... existing cases
    case yourService(YourServiceError)
}

public enum YourServiceError: Error, Equatable {
    case operationFailed(String)
    case invalidInput
    case serviceUnavailable
    case unknownError(String)
}

extension YourServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        case .invalidInput:
            return "Invalid input provided"
        case .serviceUnavailable:
            return "Service is currently unavailable"
        case .unknownError(let message):
            return "Unknown error occurred: \(message)"
        }
    }
}
```

## Service Integration Guidelines

### Using Your Service in Features

```swift
// In a TCA Reducer
import Dependencies

@Reducer
public struct YourFeature {
    @ObservableState
    public struct State { }

    public enum Action { }

    @Dependency(\.yourService) var yourService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .performOperation:
                return .run { send in
                    do {
                        let result = try await yourService.methodName(parameter: value)
                        await send(.operationSuccess(result))
                    } catch {
                        await send(.operationFailure(error))
                    }
                }
            }
        }
    }
}
```

### Testing Your Service Integration

```swift
// In feature tests
@Test
func testFeatureUsesService() async {
    let mockService = MockYourService()
    mockService.setMockResult(expectedResult, forMethod: "methodName")

    let store = TestStore(initialState: YourFeature.State()) {
        YourFeature()
    } withDependencies: {
        $0.yourService = mockService
    }

    await store.send(.performOperation)
    await store.receive(.operationSuccess(expectedResult))
}
```

## Service Evolution Guidelines

### When to Add New Methods
1. Feature requirements clearly demand the functionality
2. The method fits within the service's single responsibility
3. The method is used by at least one feature immediately

### When to Create a New Service
1. The functionality doesn't fit existing service responsibilities
2. The service would have a clear, single responsibility
3. Multiple features would benefit from the service
4. The abstraction solves real, not hypothetical problems

### Refactoring Existing Services
1. Follow the principle of pragmatic simplification
2. Remove unused methods and interfaces
3. Consolidate related functionality
4. Maintain backward compatibility during transitions

## File Locations and Requirements

### Required Files:
1. **Protocol Interface**: `YourService/Interface/YourServiceProtocol.swift`
   - Must include comprehensive documentation
   - Must be marked `Sendable`
   - Must follow async/await patterns

2. **Live Implementation**: `YourService/Live/YourService.swift`
   - Must conform to protocol
   - Must be a `struct` marked `Sendable`
   - Must transform errors to `AppError`

3. **Mock Implementation**: `YourService/Mock/MockYourService.swift`
   - Must be an `actor` for thread safety
   - Must include test helpers
   - Must define custom mock error types

4. **Dependency Registration**: `YourService/YourServiceDependency.swift`
   - Must provide live, test, and preview values
   - Must extend `DependencyValues`

### Optional Files:
- Custom error definitions in `Framework/AppError.swift` (if service-specific errors are needed)

## Testing Guidance

### Unit Tests
- Test each service method independently
- Test error handling paths
- Test edge cases and boundary conditions
- Use mock dependencies for external services

### Integration Tests
- Test service integration with features
- Test dependency injection works correctly
- Test error propagation through the stack
- Verify mock service behavior matches live service contract

### Test Organization:
```swift
@Suite("YourService Tests")
struct YourServiceTests {
    @Test("Method performs expected operation")
    func testMethodSuccess() async throws { }

    @Test("Method handles errors correctly")
    func testMethodError() async { }

    @Test("Mock service provides test helpers")
    func testMockHelpers() async { }
}
```
