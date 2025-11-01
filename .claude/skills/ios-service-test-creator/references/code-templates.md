# Code Templates for Service Testing

This document contains all code templates and examples for implementing service tests following the NetworkService patterns (PR #74).

## Mock Protocol Implementation

### Thread-Safe Mock with NSLock Pattern

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

## Test Data Models

### Basic Test Models with Sample Data

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

## Test Fixtures

### Reusable Test Objects

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

## Method-Specific Test File Structure

### Complete Test File Template

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

## Error Handling Test Patterns

### Consistency Test Template

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

## Given-When-Then Test Examples

### Success Test Example

```swift
@Test("sendRequest parses valid response successfully")
func sendRequestParsesValidResponse() async throws {
    // Given: Setup test data and mock response
    let endpoint = TestPostEndpoint()
    let expectedData = TestPost.sampleJSONData()
    MockURLProtocol.registerMockResponse(for: endpoint.url, data: expectedData)
    let service = NetworkService(session: MockURLProtocol.createMockedSession())

    // When: Execute the method under test
    let result: TestPost = try await service.sendRequest(for: endpoint)

    // Then: Verify the result matches expectations
    #expect(result == TestPost.sample())
}
```

### Error Test Example

```swift
@Test("sendRequest throws decodingFailed for invalid JSON")
func sendRequestThrowsDecodingFailedForInvalidJSON() async throws {
    // Given: Setup invalid data that will fail decoding
    let endpoint = TestPostEndpoint()
    let invalidData = Data.invalidJSON()
    MockURLProtocol.registerMockResponse(for: endpoint.url, data: invalidData)
    let service = NetworkService(session: MockURLProtocol.createMockedSession())

    // When/Then: Verify the expected error is thrown
    do {
        let _: TestPost = try await service.sendRequest(for: endpoint)
        Issue.record("Expected decodingFailed error to be thrown")
    } catch let error as AppError {
        guard case .network(.decodingFailed) = error else {
            Issue.record("Expected AppError.network(.decodingFailed), got \(error)")
            return
        }
    }
}
```

### Edge Case Test Example

```swift
@Test("sendRequest handles empty response body")
func sendRequestHandlesEmptyResponseBody() async throws {
    // Given: Setup endpoint expecting empty response
    let endpoint = TestDeleteEndpoint()
    MockURLProtocol.registerMockResponse(for: endpoint.url, data: Data())
    let service = NetworkService(session: MockURLProtocol.createMockedSession())

    // When: Execute request expecting EmptyResponse type
    let result: EmptyResponse = try await service.sendRequest(for: endpoint)

    // Then: Verify empty response is handled correctly
    #expect(result == EmptyResponse())
}
```

## Swift Testing Framework Patterns

### Test Suite Declaration

```swift
@Suite("Service Name Method Tests")
struct ServiceMethodTests {
    // Tests go here
}
```

### Test Function Declaration

```swift
@Test("Descriptive test name explaining what is being tested")
func methodNameTestScenario() async throws {
    // Test implementation
}
```

### Assertions with #expect

```swift
// Equality assertion
#expect(actualValue == expectedValue)

// Boolean assertion
#expect(condition == true)

// Optional unwrapping with assertion
#expect(optionalValue != nil)
```

### Error Recording

```swift
// Record failure with message
Issue.record("Expected error to be thrown")

// Record failure with context
Issue.record("Expected AppError.network(.decodingFailed), got \(error)")
```

## Package.swift Test Target

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

## Real-World Example: NetworkService (PR #74)

### Mock Implementation Example

```swift
final class MockURLProtocol: URLProtocol {
    private final class Storage: @unchecked Sendable {
        private let lock = NSLock()
        private var mockResponses: [URL: MockResponse] = [:]

        func setMockResponse(_ mockResponse: MockResponse, for url: URL) {
            lock.lock()
            defer { lock.unlock() }
            mockResponses[url] = mockResponse
        }

        func getMockResponse(for url: URL) -> MockResponse? {
            lock.lock()
            defer { lock.unlock() }
            return mockResponses[url]
        }
    }

    private static let storage = Storage()

    static func registerMockResponse(for url: URL, data: Data? = nil, error: Error? = nil) {
        let mockResponse = MockResponse(data: data, error: error)
        storage.setMockResponse(mockResponse, for: url)
    }
}
```

### Test Model Example

```swift
struct TestPost: Codable, Equatable, Sendable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

extension TestPost {
    static func sample() -> TestPost {
        TestPost(userId: 1, id: 1, title: "Test Title", body: "Test Body")
    }

    static func sampleJSONData() -> Data {
        """
        {
            "userId": 1,
            "id": 1,
            "title": "Test Title",
            "body": "Test Body"
        }
        """.data(using: .utf8)!
    }
}
```

### Fixture Example

```swift
struct TestPostEndpoint: Endpoint {
    var path: String { "/posts/1" }
    var method: HTTPMethod { .get }
    var headers: [String: String]? { nil }
    var body: Data? { nil }
}
```
