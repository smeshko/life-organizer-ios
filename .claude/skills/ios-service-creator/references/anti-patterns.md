# Service Anti-Patterns to Avoid

This document outlines common anti-patterns and mistakes to avoid when implementing services in the Rulebook iOS project. Learn from past mistakes and follow best practices.

## Over-Abstraction

### What NOT to Do: Unnecessary Wrapper Services

```swift
// ❌ DON'T - Unnecessary wrapper around existing service
protocol NetworkWrapperProtocol {
    func makeRequest<T>(_ endpoint: Endpoint) async throws -> T where T: Decodable
}

struct NetworkWrapper: NetworkWrapperProtocol {
    @Dependency(\.networkService) var networkService

    func makeRequest<T>(_ endpoint: Endpoint) async throws -> T where T: Decodable {
        // Just forwarding to existing service - no value added
        return try await networkService.request(endpoint)
    }
}
```

### What TO Do: Use Existing Services Directly

```swift
// ✅ DO - Use existing NetworkServiceProtocol directly
@Reducer
public struct YourFeature {
    @Dependency(\.networkService) var networkService

    // Use networkService directly - no wrapper needed
}
```

**Why This Matters:**
- Wrappers add complexity without value
- Creates unnecessary abstraction layers
- Makes code harder to understand and maintain
- Increases cognitive load for developers

## Complex State Management

### Camera Service Anti-Pattern: Over-Engineered State Machine

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

// Complex state transitions with minimal value
func startSession() async throws {
    state = .initializing
    try await initialize()
    state = .configuringSession
    try await configure()
    state = .waitingForPermission
    try await checkPermission()
    state = .startingSession
    try await start()
    state = .running
}
```

### Camera Service Best Practice: Essential States Only

```swift
// ✅ DO - Essential states only
enum CameraState {
    case idle
    case running
    case error(CameraError)
}

// Simple, clear state transitions
func startSession() async throws {
    do {
        try await performStartup()
        state = .running
    } catch {
        state = .error(.startupFailed)
        throw error
    }
}
```

**Why This Matters:**
- Complex state machines are hard to test
- Too many states create more failure points
- Simple states are easier to reason about
- Essential states cover all real scenarios

**Camera Service Results:**
- Reduced from 7 states to 3 states
- Clearer state transitions
- Easier testing
- Better maintainability

## Stream Over-Engineering

### Camera Service Anti-Pattern: Complex AsyncStream Management

```swift
// ❌ DON'T - Complex AsyncStream management for simple properties
public class CameraService {
    private let sessionStatusContinuation: AsyncStream<CameraState>.Continuation
    public var sessionStatus: AsyncStream<CameraState>

    private let flashEnabledContinuation: AsyncStream<Bool>.Continuation
    public var flashEnabled: AsyncStream<Bool>

    init() {
        (sessionStatus, sessionStatusContinuation) = AsyncStream.makeStream()
        (flashEnabled, flashEnabledContinuation) = AsyncStream.makeStream()
    }

    func setFlashEnabled(_ enabled: Bool) {
        flashEnabledContinuation.yield(enabled)
    }
}

// Usage becomes complex
for await status in cameraService.sessionStatus {
    // Handle status changes
}
```

### Camera Service Best Practice: Direct Property Access

```swift
// ✅ DO - Direct property access with @Published
public class CameraService: ObservableObject {
    @Published public private(set) var cameraState: CameraState = .idle
    @Published public private(set) var isFlashEnabled = false

    public func setFlashEnabled(_ enabled: Bool) {
        isFlashEnabled = enabled
    }
}

// Simple, direct usage
.onChange(of: cameraService.cameraState) { state in
    // Handle state changes
}
```

**Why This Matters:**
- AsyncStreams add complexity for simple state
- @Published provides reactive updates naturally
- Direct property access is more intuitive
- Easier to test and debug

**Camera Service Results:**
- Removed unnecessary AsyncStream management
- Simpler property access patterns
- Better SwiftUI integration
- Reduced code complexity

## Global Scope Creep

### What NOT to Do: Multi-Responsibility Services

```swift
// ❌ DON'T - Service that handles multiple unrelated concerns
protocol SuperService {
    func handleNetworking() async throws
    func handlePersistence() async throws
    func handleAnalytics() async throws
    func handleCaching() async throws
    func handleLogging() async throws
}

struct SuperServiceImpl: SuperService {
    // 1000+ lines of mixed concerns
    // Hard to test, hard to maintain
    // Violates single responsibility principle
}
```

### What TO Do: Focused, Single-Responsibility Services

```swift
// ✅ DO - Focused, single-responsibility services
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

protocol PersistenceServiceProtocol {
    func save(_ data: Data, forKey key: String) async throws
    func load(forKey key: String) async throws -> Data?
}

protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent) async
}
```

**Why This Matters:**
- Single responsibility makes testing easier
- Focused services are more maintainable
- Clear boundaries prevent scope creep
- Easier to understand and modify

## Speculative Interfaces

### What NOT to Do: Methods That Aren't Used

```swift
// ❌ DON'T - Methods that aren't actually needed yet
protocol YourServiceProtocol {
    func methodWeHave() async throws
    func methodWeMightNeed() async throws // Speculative
    func methodForFutureFeature() async throws // Speculative
    func methodJustInCase() async throws // Speculative
}

// Result: Dead code that needs maintenance
// Interface larger than necessary
// More surface area for bugs
```

### What TO Do: Only Methods That Are Actively Used

```swift
// ✅ DO - Only methods that are actively used
protocol YourServiceProtocol {
    func methodWeHave() async throws
}

// Add methods when they're actually needed
// Keep interface minimal and focused
// Easier to maintain and test
```

**Why This Matters:**
- YAGNI (You Aren't Gonna Need It) principle
- Less code to maintain
- Smaller testing surface
- Clearer interface contracts

## Camera Service Success Story

The CameraService refactoring demonstrates successful avoidance of these anti-patterns:

### Before: Anti-Pattern Example (What NOT to Do)

**Location**: Previous CameraService implementation

```swift
// ❌ Over-engineered with anti-patterns:

// 1. Complex state machine (7 states)
enum CameraState {
    case initializing, configuringSession, waitingForPermission
    case startingSession, running, capturing, error(Error), stopping
}

// 2. Over-abstracted stream management
private let sessionStatusContinuation: AsyncStream<CameraState>.Continuation
public var sessionStatus: AsyncStream<CameraState>

// 3. Too many error types (14 errors)
enum CameraError {
    case initializationFailed, configurationFailed, permissionDenied
    case sessionStartFailed, captureSetupFailed, photoCaptureFailed
    case focusFailed, flashFailed, zoomFailed, exposureFailed
    case metadataFailed, previewFailed, cleanupFailed, unknownError
}

// 4. Speculative interfaces
func startContinuousCapture() async throws // Never used
func configureExposure(_ mode: ExposureMode) async throws // Never used
func setZoomLevel(_ level: Float) async throws // Never used
```

**Problems:**
- 2200+ lines of code
- 600+ lines in main implementation
- 8 chaotic files
- Slow initialization
- Hard to test
- Difficult to maintain

### After: Best Practice Example (What TO Do)

**Location**: `CustomCameraService/`

```swift
// ✅ Following best practices:

// 1. Simple state management (3 states)
enum CameraState {
    case idle
    case running
    case error(CameraError)
}

// 2. Direct property access
@Published public private(set) var cameraState: CameraState = .idle
@Published public private(set) var isFlashEnabled = false

// 3. Essential error types (4 errors)
enum CameraError: Error {
    case unauthorized
    case setupFailed
    case captureFailed
    case focusFailed
}

// 4. Only actively used methods
public protocol CameraServiceProtocol: Sendable {
    func startSession() async throws
    func capturePhoto() async throws -> UIImage
    func setFocusPoint(_ point: CGPoint) async throws
}
```

**Improvements:**
- 390 lines total (83% reduction)
- 4 well-organized files
- Fast initialization
- Easy to test
- Highly maintainable
- All functionality preserved

## NetworkService Example (Good Pattern)

**Location**: `NetworkService/`

### What NetworkService Does Right:

```swift
// ✅ Clean separation of concerns
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func upload(_ data: Data, to endpoint: Endpoint) async throws
}

// ✅ Generic methods with type safety
func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
    // Type-safe decoding
    // Clear error handling
    // No unnecessary abstractions
}
```

**Why It Works:**
- Single responsibility (networking only)
- Type-safe generic methods
- Clean error handling
- No over-abstraction
- Endpoint-driven architecture

## PersistenceService Example (Good Pattern)

**Location**: `PersistenceService/`

### What PersistenceService Does Right:

```swift
// ✅ Raw data methods as foundation
protocol PersistenceServiceProtocol {
    func save(_ data: Data, forKey key: String) async throws
    func load(forKey key: String) async throws -> Data?
}

// ✅ Convenient Codable extensions
extension PersistenceServiceProtocol {
    func save<T: Encodable>(_ object: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(object)
        try await save(data, forKey: key)
    }
}
```

**Why It Works:**
- Foundation methods are simple and focused
- Extensions add convenience without complexity
- Clear storage semantics
- Fallback mechanisms (documents → bundle)

## Key Lessons from Camera Service Refactoring

### Quantitative Improvements
- **83% code reduction**: From 2200+ lines to 390 lines
- **File organization**: From 8 chaotic files to 4 structured files
- **Error types**: From 14 errors to 4 essential types
- **State complexity**: From 7-state machine to 3-state enum
- **Initialization**: From slow to near-instantaneous

### Qualitative Improvements
- **Maintainability**: Much easier to understand and modify
- **Testing**: Straightforward mock with test helpers
- **Reliability**: Fewer moving parts, fewer failure points
- **Feature preservation**: All functionality maintained (including tap-to-focus)
- **Developer experience**: Clear, self-documenting interface

## Anti-Pattern Detection Questions

Before implementing a service, ask yourself:

1. **Over-Abstraction Check**
   - Am I wrapping an existing service without adding value?
   - Could this be solved by using existing services directly?

2. **State Complexity Check**
   - Do I really need all these states?
   - What's the minimal set of states that covers all scenarios?

3. **Stream Complexity Check**
   - Do I need AsyncStream or would @Published work?
   - Am I over-engineering reactive updates?

4. **Scope Check**
   - Does this service have a single, clear responsibility?
   - Am I mixing unrelated concerns?

5. **Speculation Check**
   - Are all these methods actively used by features?
   - Am I implementing "just in case" functionality?

## Summary: What Makes a Good Service

### Good Services Are:
- **Focused**: Single, clear responsibility
- **Simple**: Minimal essential complexity
- **Direct**: No unnecessary abstractions
- **Essential**: Only actively used functionality
- **Testable**: Easy to mock and verify
- **Documented**: Clear purpose and usage

### Good Services Avoid:
- Over-abstraction and wrapper services
- Complex state machines with too many states
- Over-engineered stream management
- Multi-responsibility scope creep
- Speculative interfaces and methods
- Unnecessary complexity

**Remember**: The CameraService refactoring shows that following these principles leads to:
- Massive code reduction (83%)
- Better performance
- Easier testing
- Improved maintainability
- Preserved functionality
- Better developer experience
