# Common Pitfalls and Service-Specific Patterns

This document outlines common mistakes to avoid and provides guidance for testing different types of services.

## Common Pitfalls

### 1. Shared Test State

**Problem**: Using the same identifier across multiple tests causes them to interfere with each other.

**❌ Don't:**
```swift
Mock.register(for: "shared-key", data: dataA)  // Test A
Mock.register(for: "shared-key", data: dataB)  // Test B overwrites!
```

**Why it's wrong**: When tests run in parallel or in a different order, the second registration can overwrite the first, causing flaky test failures.

**✅ Do:**
```swift
Mock.register(for: "test-a-unique", data: dataA)
Mock.register(for: "test-b-unique", data: dataB)
```

**Best practice**: Use descriptive, unique keys that include the test name or purpose.

### 2. Testing Mocks Instead of Implementation

**Problem**: Tests verify that mocks work instead of verifying the service behavior.

**❌ Don't:**
```swift
let mock = TestMock(property: "value")
#expect(mock.property == "value")  // Testing the mock!
```

**Why it's wrong**: This test proves nothing about your service. It only proves that your test mock returns what you configured it to return.

**✅ Do:**
```swift
let mock = TestMock(property: "value")
let result = try await service.process(mock)
#expect(result.usedProperty == "value")  // Testing implementation!
```

**Best practice**: Always test how your service uses or transforms data, not whether test infrastructure works.

### 3. Monolithic Test Files

**Problem**: Putting all tests for a service in a single large file makes them hard to navigate and maintain.

**❌ Don't:**
```
NetworkServiceTests.swift (830 lines)
```

**Why it's wrong**:
- Hard to find specific tests
- Difficult to review in PRs
- Merge conflicts more likely
- Slower to load in IDE
- Harder to understand test organization

**✅ Do:**
```
URLRequestBuildingTests.swift (82 lines)
NetworkServiceSendRequestTests.swift (447 lines)
NetworkServiceSendAndForgetTests.swift (111 lines)
```

**Best practice**: One file per public method. If a method's tests exceed 200 lines, consider splitting by scenario type (success, errors, edge cases).

### 4. Duplicating Test Infrastructure

**Problem**: Creating the same test helpers in multiple test files instead of sharing them.

**❌ Don't:**
```swift
// In Test1.swift
struct LocalTestEndpoint: Endpoint { }

// In Test2.swift
struct LocalTestEndpoint: Endpoint { }  // Duplication!
```

**Why it's wrong**:
- Wastes time maintaining duplicate code
- Inconsistencies between duplicates
- Changes require updating multiple files
- Increases test maintenance burden

**✅ Do:**
```swift
// In Helpers/TestEndpoints.swift
struct TestPostEndpoint: Endpoint { }  // Shared!
```

**Best practice**: Create a Helpers/ directory for all shared test infrastructure (mocks, models, fixtures).

### 5. Not Resetting Mock State

**Problem**: Forgetting to reset mocks between tests or relying on test ordering.

**❌ Don't:**
```swift
@Test("First test")
func firstTest() async throws {
    Mock.register(for: "key", data: data1)
    // Test runs, but mock not cleared
}

@Test("Second test")
func secondTest() async throws {
    // Expects clean state, but "key" still has data1!
}
```

**✅ Do:**
```swift
// In Mock implementation
static func reset() {
    storage.clearAll()
}

// In tests, use unique keys per test
@Test("First test")
func firstTest() async throws {
    Mock.register(for: "first-test-key", data: data1)
}

@Test("Second test")
func secondTest() async throws {
    Mock.register(for: "second-test-key", data: data2)
}
```

### 6. Vague Test Names

**Problem**: Test names that don't clearly describe what's being tested.

**❌ Don't:**
```swift
@Test("Test 1")
func test1() async throws { }

@Test("It works")
func testItWorks() async throws { }
```

**✅ Do:**
```swift
@Test("sendRequest parses valid JSON response successfully")
func sendRequestParsesValidJSONResponse() async throws { }

@Test("sendRequest throws decodingFailed for invalid JSON")
func sendRequestThrowsDecodingFailedForInvalidJSON() async throws { }
```

### 7. Missing Error Case Coverage

**Problem**: Only testing success paths and ignoring error handling.

**❌ Don't:**
```swift
@Test("Method works")
func methodWorks() async throws {
    let result = try await service.method()
    #expect(result != nil)
}
// No error tests!
```

**✅ Do:**
```swift
// Success test
@Test("method succeeds with valid input")
func methodSucceedsWithValidInput() async throws { }

// Error tests
@Test("method throws error for invalid input")
func methodThrowsErrorForInvalidInput() async throws { }

@Test("method handles network failure")
func methodHandlesNetworkFailure() async throws { }
```

### 8. Not Following Given-When-Then

**Problem**: Mixing setup, execution, and verification without clear structure.

**❌ Don't:**
```swift
@Test("Test something")
func testSomething() async throws {
    let service = Service()
    Mock.register(for: "key", data: data)
    let result = try await service.method()
    #expect(result.isValid)
    let other = try await service.other()
    #expect(other.count > 0)
}
```

**✅ Do:**
```swift
@Test("method processes data correctly")
func methodProcessesDataCorrectly() async throws {
    // Given
    Mock.register(for: "test-key", data: testData)
    let service = Service()

    // When
    let result = try await service.method()

    // Then
    #expect(result.isValid)
    #expect(result.processedData == expectedData)
}
```

## Testing Patterns by Service Type

### Network Services

**Key Testing Areas:**
- Request building (URL, method, headers, body)
- Response handling (status codes, data parsing)
- Error transformation (URLError → AppError)
- Timeout and retry logic

**Common Patterns:**
```swift
// Test URL construction
@Test("buildRequest constructs correct URL")
func buildRequestConstructsCorrectURL() async throws {
    let endpoint = TestEndpoint(path: "/api/test")
    let request = try service.buildRequest(for: endpoint)
    #expect(request.url?.absoluteString == "https://api.example.com/api/test")
}

// Test status code handling
@Test("sendRequest handles 404 status code")
func sendRequestHandles404StatusCode() async throws {
    Mock.register(for: url, statusCode: 404)
    do {
        _ = try await service.sendRequest(for: endpoint)
        Issue.record("Expected error")
    } catch let error as AppError {
        guard case .network(.notFound) = error else {
            Issue.record("Wrong error type")
            return
        }
    }
}

// Test response parsing
@Test("sendRequest parses JSON response")
func sendRequestParsesJSONResponse() async throws {
    Mock.register(for: url, data: User.sampleJSON())
    let user: User = try await service.sendRequest(for: endpoint)
    #expect(user == User.sample())
}
```

### Persistence Services

**Key Testing Areas:**
- Data encoding/decoding
- File system operations
- Fallback mechanisms
- Data migration

**Common Patterns:**
```swift
// Test data persistence
@Test("save writes data to correct location")
func saveWritesDataToCorrectLocation() async throws {
    let data = TestModel.sample()
    try await service.save(data)
    let loaded = try await service.load()
    #expect(loaded == data)
}

// Test migration
@Test("migrate converts old format to new format")
func migrateConvertsOldFormatToNewFormat() async throws {
    Mock.register(oldFormat: legacyData)
    try await service.migrate()
    let migrated = try await service.load()
    #expect(migrated.version == 2)
}

// Test fallback
@Test("load returns default when file missing")
func loadReturnsDefaultWhenFileMissing() async throws {
    Mock.simulateFileMissing()
    let result = try await service.load()
    #expect(result == TestModel.default())
}
```

### Camera/Media Services

**Key Testing Areas:**
- Permission handling
- Device availability
- Session lifecycle
- Resource cleanup

**Common Patterns:**
```swift
// Test permission checking
@Test("capture fails when permission denied")
func captureFailsWhenPermissionDenied() async throws {
    Mock.simulatePermission(.denied)
    do {
        _ = try await service.capture()
        Issue.record("Expected permission error")
    } catch let error as AppError {
        guard case .camera(.permissionDenied) = error else {
            Issue.record("Wrong error type")
            return
        }
    }
}

// Test device availability
@Test("initialize fails when camera unavailable")
func initializeFailsWhenCameraUnavailable() async throws {
    Mock.simulateDeviceAvailable(false)
    do {
        try await service.initialize()
        Issue.record("Expected device unavailable error")
    } catch { }
}

// Test session lifecycle
@Test("stop cleans up resources")
func stopCleansUpResources() async throws {
    try await service.start()
    try await service.stop()
    #expect(service.isSessionActive == false)
}
```

### Analytics Services

**Key Testing Areas:**
- Event tracking
- Property formatting
- Batching logic
- Offline queuing

**Common Patterns:**
```swift
// Test event tracking
@Test("track sends event with correct properties")
func trackSendsEventWithCorrectProperties() async throws {
    let event = TestEvent(name: "user_action")
    try await service.track(event)
    let sent = Mock.capturedEvents.first
    #expect(sent?.name == "user_action")
}

// Test batching
@Test("flush sends batched events")
func flushSendsBatchedEvents() async throws {
    try await service.track(event1)
    try await service.track(event2)
    try await service.flush()
    #expect(Mock.capturedBatches.count == 1)
    #expect(Mock.capturedBatches.first?.count == 2)
}

// Test offline queuing
@Test("track queues events when offline")
func trackQueuesEventsWhenOffline() async throws {
    Mock.simulateOffline()
    try await service.track(event)
    #expect(service.queuedEventCount == 1)
}
```

## Thread Safety Pitfalls

### Problem: Not Using Thread-Safe Storage

**❌ Don't:**
```swift
final class MockService: @unchecked Sendable {
    private var responses: [String: Data] = [:]  // Not thread-safe!

    func register(for key: String, data: Data) {
        responses[key] = data  // Race condition!
    }
}
```

**✅ Do:**
```swift
final class MockService {
    private final class Storage: @unchecked Sendable {
        private let lock = NSLock()
        private var responses: [String: Data] = [:]

        func set(_ data: Data, for key: String) {
            lock.lock()
            defer { lock.unlock() }
            responses[key] = data
        }
    }

    private static let storage = Storage()
}
```

## Swift 6 Concurrency Pitfalls

### Problem: Not Marking Test Types as Sendable

**❌ Don't:**
```swift
struct TestModel: Codable {  // Missing Sendable
    let data: String
}
```

**✅ Do:**
```swift
struct TestModel: Codable, Sendable {
    let data: String
}
```

---

*This document follows patterns from NetworkService tests (PR #74) and complements the test implementation guide.*
