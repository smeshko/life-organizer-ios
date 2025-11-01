# Service Implementation Template

This document provides a comprehensive template for implementing new services in the Rulebook iOS project, based on the existing NetworkService and PersistenceService patterns and the project's Feature-Scoped Architecture principles.

## 🏗️ Service Architecture Pattern

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

## 📋 Step-by-Step Implementation Guide

### 1. Create the Protocol Interface

**File**: `Interface/YourServiceProtocol.swift`

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

**Key Protocol Design Guidelines:**
- Use comprehensive documentation with examples
- Follow async/await patterns consistently
- Include design principles section
- Make protocols `Sendable` for concurrency safety
- Use generic types where appropriate for type safety
- Document error cases thoroughly

### 2. Implement the Live Service

**File**: `Live/YourService.swift`

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

**Key Implementation Guidelines:**
- Use `struct` with `Sendable` conformance
- Follow consistent error handling patterns
- Transform external errors to `AppError` types
- Include private helper methods section
- Handle async operations properly
- Use dependency injection for external services

### 3. Create the Mock Implementation

**File**: `Mock/MockYourService.swift`

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

**Key Mock Guidelines:**
- Use `actor` for thread-safe mock state
- Include test helpers for configuration
- Simulate realistic delays
- Provide error simulation capabilities
- Include reset functionality for clean tests
- Create specific mock error types

### 4. Register with TCA Dependencies

**File**: `YourServiceDependency.swift`

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

**Key Dependency Guidelines:**
- Use private enum for dependency key
- Provide separate values for live, test, and preview
- Use clear, consistent naming for dependency accessor
- Follow existing patterns in the codebase

### 5. Define Service-Specific Errors (if needed)

If your service needs custom errors, add them to `Framework/AppError.swift`:

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

## 🎯 Service Integration Guidelines

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

## ✅ Implementation Checklist

### Protocol Definition
- [ ] Comprehensive documentation with examples
- [ ] Design principles clearly stated
- [ ] All methods documented with parameters and return values
- [ ] Error cases documented
- [ ] `Sendable` conformance for concurrency safety

### Live Implementation
- [ ] Consistent error handling using `AppError`
- [ ] Proper async/await usage
- [ ] Dependencies injected through initializer
- [ ] Private helper methods organized
- [ ] `Sendable` conformance

### Mock Implementation
- [ ] `actor` for thread safety
- [ ] Test helper methods provided
- [ ] Error simulation capabilities
- [ ] Realistic delay simulation
- [ ] Clean reset functionality
- [ ] Custom mock error types

### Dependency Registration
- [ ] Private dependency key enum
- [ ] Live, test, and preview values configured
- [ ] Public extension on `DependencyValues`
- [ ] Consistent naming conventions

### Integration
- [ ] Service used in at least one feature
- [ ] Unit tests written for service
- [ ] Integration tests with features
- [ ] Error handling tested

## 🚫 Common Anti-Patterns to Avoid

### Over-Abstraction
```swift
// ❌ DON'T - Unnecessary wrapper around existing service
protocol NetworkWrapperProtocol {
    func makeRequest<T>(_ endpoint: Endpoint) async throws -> T where T: Decodable
}

// ✅ DO - Use existing NetworkServiceProtocol directly
@Dependency(\.networkService) var networkService
```

### Complex State Management (Camera Service Lesson)
```swift
// ❌ DON'T - Over-engineered state machine
enum CameraState {
    case initializing
    case configuringSession
    case waitingForPermission
    case startingSession
    case running
    case capturing
    case error(Error)
    case stopping
}

// ✅ DO - Essential states only
enum CameraState {
    case idle
    case running
    case error(CameraError)
}
```

### Stream Over-Engineering (Camera Service Lesson)
```swift
// ❌ DON'T - Complex AsyncStream management for simple properties
public var sessionStatus: AsyncStream<CameraState> { /* complex implementation */ }
public var flashEnabled: AsyncStream<Bool> { /* more complexity */ }

// ✅ DO - Direct property access with @Published
@Published public private(set) var cameraState: CameraState = .idle
@Published public private(set) var isFlashEnabled = false
```

### Global Scope Creep
```swift
// ❌ DON'T - Service that handles multiple unrelated concerns
protocol SuperService {
    func handleNetworking() async throws
    func handlePersistence() async throws
    func handleAnalytics() async throws
}

// ✅ DO - Focused, single-responsibility services
protocol NetworkServiceProtocol { /* networking only */ }
protocol PersistenceServiceProtocol { /* persistence only */ }
```

### Speculative Interfaces
```swift
// ❌ DON'T - Methods that aren't actually needed yet
protocol YourServiceProtocol {
    func methodWeHave() async throws
    func methodWeMightNeed() async throws // Speculative
    func methodForFutureFeature() async throws // Speculative
}

// ✅ DO - Only methods that are actively used
protocol YourServiceProtocol {
    func methodWeHave() async throws
}
```

## 📚 Examples from Existing Services

### Camera Service Pattern (Exemplary Implementation)
**Location**: `CustomCameraService/`

The CameraService demonstrates successful application of the service template pattern:

#### Interface (`Interface/CameraServiceProtocol.swift`)
- **Comprehensive Documentation**: Each method includes examples and error descriptions
- **Design Principles**: Clear statement of simplicity and focus preservation
- **Type Safety**: `Sendable` conformance and proper error typing
- **Essential Operations**: Only methods actively used by features

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

#### Live Implementation (`Live/CameraService.swift`)
- **Direct Dependencies**: Uses AVFoundation directly, no wrapper abstractions
- **Essential Error Handling**: 4 focused error types instead of 14
- **Simple State**: 3-state enum instead of 7-state machine
- **Performance Optimized**: ~200 lines vs. previous 600+ lines

#### Mock Implementation (`Mock/MockCameraService.swift`)
- **Actor-Based**: Thread-safe mock state management
- **Test Helpers**: Configurable error simulation and result mocking
- **Realistic Behavior**: Simulated delays and proper cleanup

#### Benefits Achieved
- **83% Code Reduction**: From 2200+ lines to 390 lines
- **Improved Testing**: Clear mock interface with comprehensive helpers
- **Better Performance**: Faster initialization and reduced memory footprint
- **Enhanced Maintainability**: Focus on essential functionality

### NetworkService Pattern
- Clean separation of concerns (networking only)
- Generic methods with type safety
- Comprehensive error handling
- Endpoint-driven architecture

### PersistenceService Pattern  
- Raw data methods as foundation
- Convenient Codable extensions
- Fallback mechanisms (documents → bundle)
- Clear storage semantics

## 🔄 Service Evolution Guidelines

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

## 🎆 Camera Service Success Metrics

The CameraService simplification demonstrates the value of following this template:

### Quantitative Improvements
- **Code Reduction**: 83% reduction (2200+ → 390 lines)
- **File Organization**: 8 chaotic files → 4 structured files
- **Error Types**: 14 → 4 essential types
- **State Complexity**: 7-state machine → 3-state enum
- **Initialization Time**: Slow → Near-instantaneous

### Qualitative Improvements
- **Maintainability**: Much easier to understand and modify
- **Testing**: Straightforward mock with test helpers
- **Reliability**: Fewer moving parts, fewer failure points
- **Feature Preservation**: All functionality maintained (including tap-to-focus)
- **Developer Experience**: Clear, self-documenting interface

---

*This template should be used for all new service implementations in the Rulebook iOS project. The CameraService demonstrates how following these patterns leads to significant improvements in code quality, maintainability, and performance.*