# Service Test Implementation Template

This template provides a step-by-step guide for implementing tests for services in the Rulebook iOS project, following the patterns established in NetworkService tests (PR #74).

## 🏗️ Test Architecture Pattern

All service tests follow this structure:

```
Tests/{ServiceName}Tests/
├── Helpers/
│   ├── Mock{Protocol}.swift              # Mock protocol implementation
│   ├── Test{Domain}Models.swift          # Test data models with sample data
│   └── Test{Service}Fixtures.swift       # Reusable test objects
├── {Service}{Method}Tests.swift          # One file per public method
└── {Service}ErrorHandlingTests.swift     # Cross-method consistency tests
```

## 📋 Step-by-Step Implementation Guide

### Step 1: Analyze Service Under Test

Document:
- **Public Methods**: What are all the public methods?
- **Dependencies**: What external services/protocols does it use?
- **Error Cases**: What errors can occur?
- **Data Types**: What inputs/outputs does it work with?

### Step 2: Create Directory Structure

```bash
mkdir -p rulebook-kit/Tests/{ServiceName}Tests/Helpers
```

### Step 3: Create Mock Protocol Implementation

**File**: `Tests/{ServiceName}Tests/Helpers/Mock{Protocol}.swift`

```swift
import Foundation

/// Mock{Protocol} intercepts {service} operations for testing.
final class Mock{Protocol}: {Protocol} {

    struct MockResponse: Sendable {
        let data: Data?
        let error: (any Error)?
    }

    // Thread-safe storage using NSLock
    private final class Storage: @unchecked Sendable {
        private let lock = NSLock()
        private var mockResponses: [String: MockResponse] = [:]

        func setMockResponse(_ mockResponse: MockResponse, for key: String) {
            lock.lock()
            defer { lock.unlock() }
            mockResponses[key] = mockResponse
        }

        func getMockResponse(for key: String) -> MockResponse? {
            lock.lock()
            defer { lock.unlock() }
            return mockResponses[key]
        }

        func clearAll() {
            lock.lock()
            defer { lock.unlock() }
            mockResponses.removeAll()
        }
    }

    private static let storage = Storage()

    /// Creates a configured mock instance
    static func createMockedInstance() -> {ServiceType} {
        // Configure and return mocked service
    }

    /// Registers a mock response
    static func registerMockResponse(
        for key: String,
        data: Data? = nil,
        error: (any Error)? = nil
    ) {
        let mockResponse = MockResponse(data: data, error: error)
        storage.setMockResponse(mockResponse, for: key)
    }

    /// Clears all registered mocks
    static func reset() {
        storage.clearAll()
    }

    // MARK: - Protocol Implementation
    // Implement protocol methods here
}
```

**Key Requirements:**
- Thread-safe with NSLock
- `Sendable` conformance for Swift 6
- Support success and error simulation
- Reset functionality for test isolation

### Step 4: Create Test Data Models

**File**: `Tests/{ServiceName}Tests/Helpers/Test{Domain}Models.swift`

```swift
import Foundation

// MARK: - Test Models

struct TestEntity: Codable, Equatable, Sendable {
    let id: Int
    let name: String
}

struct EmptyResponse: Codable, Equatable, Sendable {}

// MARK: - Sample Data Helpers

extension TestEntity {
    static func sample() -> TestEntity {
        TestEntity(id: 1, name: "Test Entity")
    }

    static func sampleJSONData() -> Data {
        """
        {
            "id": 1,
            "name": "Test Entity"
        }
        """.data(using: .utf8)!
    }
}

// MARK: - Invalid Data Helpers

extension Data {
    static func invalidJSON() -> Data {
        "{ invalid json }".data(using: .utf8)!
    }

    static func wrongStructureJSON() -> Data {
        """
        {
            "unexpected_field": "value"
        }
        """.data(using: .utf8)!
    }
}
```

### Step 5: Create Reusable Test Fixtures

**File**: `Tests/{ServiceName}Tests/Helpers/Test{Service}Fixtures.swift`

```swift
import Foundation
@testable import Framework

/// Simple {object} for testing
struct Test{Object}: {Protocol} {
    let property: String
    init(property: String = "default") {
        self.property = property
    }
}

/// {Object} with custom configuration
struct Test{CustomObject}: {Protocol} {
    let customProperty: Data?
    init(customProperty: Data? = nil) {
        self.customProperty = customProperty
    }
}

/// {Object} for testing error conditions
struct Test{InvalidObject}: {Protocol} {
    var property: String? { nil }
}
```

### Step 6: Create Method-Specific Test Files

**File**: `Tests/{ServiceName}Tests/{Service}{Method}Tests.swift`

```swift
import Testing
import Foundation
@testable import {ServiceName}
@testable import Framework

/// Test suite for {ServiceName}.{method}() method.
///
/// Tests cover {key scenarios}.
@Suite("{ServiceName} {method} Tests")
struct {Service}{Method}Tests {

    // MARK: - Success Tests

    @Test("{method} performs operation successfully")
    func {method}PerformsOperationSuccessfully() async throws {
        // Given
        let input = "test-input"
        Mock{Protocol}.registerMockResponse(
            for: "unique-test-key",
            data: expectedData
        )
        let service = {ServiceName}(dependency: Mock{Protocol}.createMockedInstance())

        // When
        let result = try await service.{method}(input: input)

        // Then
        #expect(result == expectedOutput)
    }

    // MARK: - Error Tests

    @Test("{method} throws {ErrorType} for {condition}")
    func {method}Throws{ErrorType}() async throws {
        // Given
        Mock{Protocol}.registerMockResponse(
            for: "unique-error-key",
            error: ExpectedError.case
        )
        let service = {ServiceName}(dependency: Mock{Protocol}.createMockedInstance())

        // When/Then
        do {
            _ = try await service.{method}(input: testInput)
            Issue.record("Expected error to be thrown")
        } catch let error as {ErrorType} {
            guard case .expectedCase = error else {
                Issue.record("Expected {ErrorType}.expectedCase")
                return
            }
        }
    }

    // MARK: - Edge Cases

    @Test("{method} handles edge case")
    func {method}HandlesEdgeCase() async throws {
        // Test edge case scenarios
    }
}
```

### Step 7: Create Error Handling Consistency Tests

**File**: `Tests/{ServiceName}Tests/{Service}ErrorHandlingTests.swift`

```swift
import Testing
import Foundation
@testable import {ServiceName}

/// Test suite for consistent error handling across all methods.
@Suite("{ServiceName} Error Handling Consistency Tests")
struct {Service}ErrorHandlingTests {

    @Test("All methods handle errors consistently")
    func allMethodsHandleErrorsConsistently() async throws {
        // Given
        let commonError = {ErrorType}.commonCase
        Mock{Protocol}.registerMockResponse(for: "error-test", error: commonError)
        let service = {ServiceName}(dependency: Mock{Protocol}.createMockedInstance())

        // Test method1 error handling
        do {
            _ = try await service.method1(input: "error-test")
            Issue.record("method1: Expected error")
        } catch let error as AppError {
            guard case .{service}(.expectedError) = error else {
                Issue.record("method1: Wrong error type")
                return
            }
        }

        // Test method2 error handling
        do {
            _ = try await service.method2(input: "error-test")
            Issue.record("method2: Expected error")
        } catch let error as AppError {
            guard case .{service}(.expectedError) = error else {
                Issue.record("method2: Wrong error type")
                return
            }
        }
    }
}
```

### Step 8: Update Package.swift

```swift
// In targets array:
.testTarget(
    name: "{ServiceName}Tests",
    dependencies: [
        "{ServiceName}",
        "Framework",
        .product(name: "Testing", package: "swift-testing")
    ],
    path: "Tests/{ServiceName}Tests"
)
```

## 🎯 Testing Requirements

### Coverage Checklist

For each public method, ensure you test:

**Success Scenarios:**
- [ ] Method succeeds with valid input
- [ ] Method works with different data types
- [ ] Method handles all success states

**Error Scenarios:**
- [ ] Method throws expected errors for invalid input
- [ ] Method handles dependency failures
- [ ] Method transforms external errors correctly

**Edge Cases:**
- [ ] Method handles empty/nil input
- [ ] Method handles large data sets
- [ ] Method handles concurrent calls

### Code Quality Standards

**Test Organization:**
- [ ] One file per public method (< 200 lines each)
- [ ] MARK comments group related tests
- [ ] File names clearly indicate what's being tested

**Test Independence:**
- [ ] Each test uses unique identifiers/keys
- [ ] No shared state between tests
- [ ] Tests can run in any order

**Test Clarity:**
- [ ] Descriptive test names
- [ ] Given-When-Then structure
- [ ] Tests validate implementation, not mocks

**Infrastructure:**
- [ ] Reusable mocks in Helpers/
- [ ] Sample data generators
- [ ] Thread-safe mock storage
- [ ] Swift 6 Sendable compliance

## 🚫 Common Pitfalls

### 1. Shared Test State

**❌ Don't:**
```swift
Mock.register(for: "shared-key", data: dataA)  // Test A
Mock.register(for: "shared-key", data: dataB)  // Test B overwrites!
```

**✅ Do:**
```swift
Mock.register(for: "test-a-unique", data: dataA)
Mock.register(for: "test-b-unique", data: dataB)
```

### 2. Testing Mocks Instead of Implementation

**❌ Don't:**
```swift
let mock = TestMock(property: "value")
#expect(mock.property == "value")  // Testing the mock!
```

**✅ Do:**
```swift
let mock = TestMock(property: "value")
let result = try await service.process(mock)
#expect(result.usedProperty == "value")  // Testing implementation!
```

### 3. Monolithic Test Files

**❌ Don't:**
```
NetworkServiceTests.swift (830 lines)
```

**✅ Do:**
```
URLRequestBuildingTests.swift (82 lines)
NetworkServiceSendRequestTests.swift (447 lines)
NetworkServiceSendAndForgetTests.swift (111 lines)
```

### 4. Duplicating Test Infrastructure

**❌ Don't:**
```swift
// In Test1.swift
struct LocalTestEndpoint: Endpoint { }

// In Test2.swift
struct LocalTestEndpoint: Endpoint { }  // Duplication!
```

**✅ Do:**
```swift
// In Helpers/TestEndpoints.swift
struct TestPostEndpoint: Endpoint { }  // Shared!
```

## 📊 Testing Patterns by Service Type

### Network Services
- Request building (URL, method, headers, body)
- Response handling (status codes, data parsing)
- Error transformation (URLError → AppError)
- Timeout and retry logic

### Persistence Services
- Data encoding/decoding
- File system operations
- Fallback mechanisms
- Data migration

### Camera/Media Services
- Permission handling
- Device availability
- Session lifecycle
- Resource cleanup

### Analytics Services
- Event tracking
- Property formatting
- Batching logic
- Offline queuing

## ✅ Final Verification Checklist

### Before Submitting Tests

**Infrastructure:**
- [ ] Mock implementations in Helpers/
- [ ] Test models with sample data
- [ ] Reusable fixtures created
- [ ] Thread-safe mock storage

**Organization:**
- [ ] Tests split into focused files
- [ ] One file per public method
- [ ] MARK comments for grouping
- [ ] Clear file naming

**Coverage:**
- [ ] All public methods tested
- [ ] Success scenarios covered
- [ ] Error scenarios covered
- [ ] Edge cases tested
- [ ] Cross-method consistency verified

**Quality:**
- [ ] Descriptive test names
- [ ] Given-When-Then structure
- [ ] Unique identifiers per test
- [ ] Tests validate implementation
- [ ] No test interdependencies

**Integration:**
- [ ] Package.swift updated
- [ ] All tests pass
- [ ] No Swift 6 warnings

---

*This template follows patterns from NetworkService tests (PR #74) and complements service-creation-template.md and feature-creation-template.md.*

*Last updated: 2025-10-26*
