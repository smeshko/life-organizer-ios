# Service Code Templates

This file contains all code templates and examples for implementing services in the Rulebook iOS project.

## Protocol Interface Pattern

### Complete Protocol Template with Documentation

```swift
import Foundation

/// Protocol defining [service purpose] for the Rulebook iOS app.
///
/// `YourServiceProtocol` provides [brief description of what the service does].
/// [Add more detailed description of service responsibilities and design philosophy].
///
/// ## Design Principles
/// - **[Principle 1]**: [Description]
/// - **[Principle 2]**: [Description]
/// - **Async-first**: All operations are asynchronous for consistent performance
/// - **[Type-safe/Error-transparent/etc.]**: [Relevant design principle]
///
/// ## Typical Usage
/// ```swift
/// // Example usage pattern
/// let result = try await yourService.performOperation(parameter: value)
/// ```
///
/// - Note: This protocol is designed to be dependency-injected throughout the app,
///   enabling easy testing through mock implementations.
public protocol YourServiceProtocol: Sendable {
    /// [Method description explaining what it does]
    ///
    /// [More detailed description of the method's behavior, parameters, and usage]
    ///
    /// - Parameter [paramName]: [Parameter description]
    /// - Returns: [Return value description]
    /// - Throws: [Types of errors that can be thrown]
    ///
    /// ## Example
    /// ```swift
    /// let result = try await yourService.methodName(parameter: value)
    /// ```
    func methodName(parameter: ParameterType) async throws -> ReturnType
}
```

### Camera Service Protocol Example (Real-World Success)

```swift
/// Protocol defining camera functionality for the Rulebook iOS app.
///
/// ## Design Principles
/// - **Simplicity**: Direct camera operations without unnecessary abstractions
/// - **Focus preservation**: Maintains tap-to-focus capability as core feature
/// - **Async-first**: All operations are asynchronous for consistent performance
public protocol CameraServiceProtocol: Sendable {
    func startSession() async throws
    func capturePhoto() async throws -> UIImage
    func setFocusPoint(_ point: CGPoint) async throws
}
```

## Live Service Implementation

### Complete Live Service Template

```swift
import Foundation
import Framework

public struct YourService: YourServiceProtocol, Sendable {
    // Dependencies (if needed)
    // @Dependency(\.dependency) private var dependency

    public func methodName(parameter: ParameterType) async throws -> ReturnType {
        do {
            // Implementation logic
            // Handle the actual work

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
    }

    // MARK: - Private Helpers

    private func helperMethod() throws {
        // Private implementation details
    }
}
```

### Error Handling Pattern

```swift
// Comprehensive error handling in service methods
public func performOperation(parameter: ParameterType) async throws -> ReturnType {
    do {
        // Implementation logic
        let result = try await externalOperation(parameter)
        return result
    } catch let error as AppError {
        // Re-throw known app errors
        throw error
    } catch URLError.networkConnectionLost {
        // Transform specific errors to AppError
        throw AppError.yourService(.networkError)
    } catch DecodingError.dataCorrupted {
        // Transform decoding errors
        throw AppError.yourService(.invalidData)
    } catch {
        // Handle unexpected errors
        throw AppError.yourService(.unknownError(error.localizedDescription))
    }
}
```

## Mock Service with Test Helpers

### Complete Mock Service Template with Actor Pattern

```swift
import Foundation

public actor MockYourService: YourServiceProtocol {
    // Mock state storage
    private var mockResults: [String: Any] = [:]
    private var shouldSimulateError = false

    public init() {}

    public func methodName(parameter: ParameterType) async throws -> ReturnType {
        // Simulate network/processing delay
        try await Task.sleep(nanoseconds: 100_000_000)

        if shouldSimulateError {
            throw MockYourServiceError.simulatedFailure
        }

        // Return mock data or configured result
        if let mockResult = mockResults["methodName"] as? ReturnType {
            return mockResult
        }

        // Default mock return value
        return defaultMockResult()
    }

    // MARK: - Test Helpers

    /// Configure mock return value for testing
    public func setMockResult<T>(_ result: T, forMethod method: String) {
        mockResults[method] = result
    }

    /// Enable error simulation for testing
    public func simulateError(_ shouldError: Bool = true) {
        shouldSimulateError = shouldError
    }

    /// Reset mock state
    public func reset() {
        mockResults.removeAll()
        shouldSimulateError = false
    }

    // MARK: - Private Helpers

    private func defaultMockResult() -> ReturnType {
        // Return sensible default for testing
    }
}

public enum MockYourServiceError: Error {
    case simulatedFailure
    case noMockData
}

extension MockYourServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .simulatedFailure:
            return "Simulated service failure for testing"
        case .noMockData:
            return "No mock data configured for this operation"
        }
    }
}
```

### Test Helper Usage Examples

```swift
// Configure mock to return specific result
let mockService = MockYourService()
await mockService.setMockResult(expectedValue, forMethod: "methodName")

// Simulate error condition
await mockService.simulateError(true)

// Reset mock state between tests
await mockService.reset()
```

## Dependency Registration

### Complete Dependency Registration Template

```swift
import Dependencies

// MARK: - Dependency Key
private enum YourServiceKey: DependencyKey {
    static let liveValue: YourServiceProtocol = YourService()
    static let testValue: YourServiceProtocol = MockYourService()
    static let previewValue: YourServiceProtocol = MockYourService()
}

// MARK: - Dependency Values Extension
public extension DependencyValues {
    var yourService: YourServiceProtocol {
        get { self[YourServiceKey.self] }
        set { self[YourServiceKey.self] = newValue }
    }
}
```

### Using Dependencies in Features

```swift
import Dependencies

@Reducer
public struct YourFeature {
    @Dependency(\.yourService) var yourService

    // Feature implementation
}
```

## Error Definitions

### Complete Error Definition Template

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

### Error Handling in Features

```swift
do {
    let result = try await yourService.methodName(parameter: value)
    // Handle success
} catch let error as AppError {
    // Handle app-specific errors
    switch error {
    case .yourService(let serviceError):
        // Handle service-specific error
        break
    default:
        // Handle other app errors
        break
    }
} catch {
    // Handle unexpected errors
}
```

## Feature Integration Examples

### TCA Reducer Integration

```swift
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

### Feature Testing with Mock Service

```swift
@Test
func testFeatureUsesService() async {
    let mockService = MockYourService()
    await mockService.setMockResult(expectedResult, forMethod: "methodName")

    let store = TestStore(initialState: YourFeature.State()) {
        YourFeature()
    } withDependencies: {
        $0.yourService = mockService
    }

    await store.send(.performOperation)
    await store.receive(.operationSuccess(expectedResult))
}
```

### Testing Error Handling

```swift
@Test
func testFeatureHandlesServiceError() async {
    let mockService = MockYourService()
    await mockService.simulateError(true)

    let store = TestStore(initialState: YourFeature.State()) {
        YourFeature()
    } withDependencies: {
        $0.yourService = mockService
    }

    await store.send(.performOperation)
    await store.receive(.operationFailure) { error in
        // Verify error handling
    }
}
```

## Camera Service Success Example

The CameraService demonstrates excellent application of these templates:

### Interface Design
```swift
/// Protocol defining camera functionality for the Rulebook iOS app.
///
/// ## Design Principles
/// - **Simplicity**: Direct camera operations without unnecessary abstractions
/// - **Focus preservation**: Maintains tap-to-focus capability as core feature
/// - **Async-first**: All operations are asynchronous for consistent performance
public protocol CameraServiceProtocol: Sendable {
    func startSession() async throws
    func capturePhoto() async throws -> UIImage
    func setFocusPoint(_ point: CGPoint) async throws
}
```

### Live Implementation Highlights
- Direct AVFoundation usage (no wrapper abstractions)
- 4 focused error types (instead of 14)
- 3-state enum (instead of 7-state machine)
- ~200 lines (vs. previous 600+ lines)

### Mock Implementation Highlights
- Actor-based thread safety
- Comprehensive test helpers
- Realistic delay simulation
- Clean reset functionality

### Results Achieved
- 83% code reduction (2200+ → 390 lines)
- Faster initialization
- Better testability
- Improved maintainability
- All functionality preserved

## Service Architecture Patterns

### NetworkService Pattern
```swift
// Clean separation of concerns (networking only)
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func upload(_ data: Data, to endpoint: Endpoint) async throws
}
```

### PersistenceService Pattern
```swift
// Raw data methods as foundation
protocol PersistenceServiceProtocol {
    func save(_ data: Data, forKey key: String) async throws
    func load(forKey key: String) async throws -> Data?
}

// Convenient Codable extensions
extension PersistenceServiceProtocol {
    func save<T: Encodable>(_ object: T, forKey key: String) async throws
    func load<T: Decodable>(forKey key: String) async throws -> T?
}
```

## Test Suite Structure

```swift
@Suite("YourService Tests")
struct YourServiceTests {
    @Test("Method performs expected operation")
    func testMethodSuccess() async throws {
        let service = YourService()
        let result = try await service.methodName(parameter: testValue)
        #expect(result == expectedResult)
    }

    @Test("Method handles errors correctly")
    func testMethodError() async {
        let service = YourService()
        await #expect(throws: AppError.yourService(.invalidInput)) {
            try await service.methodName(parameter: invalidValue)
        }
    }

    @Test("Mock service provides test helpers")
    func testMockHelpers() async {
        let mockService = MockYourService()
        await mockService.setMockResult(testResult, forMethod: "methodName")

        let result = try await mockService.methodName(parameter: testValue)
        #expect(result == testResult)
    }
}
```
