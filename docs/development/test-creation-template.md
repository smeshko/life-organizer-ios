# Test Creation Template - Life Organizer iOS

## Quick Start

```swift
// Tests/FeatureTests/Integration/FeatureTests.swift
import Testing
@testable import FeatureName

@Suite("Feature Tests") 
struct FeatureTests {
    @Test("Handles happy path") 
    func happyPath() async throws {
        // Arrange
        let mockJSON = TestResources.loadMock("valid")
        
        // Act
        let result = try await withDependencies { $0.service = MockService(mockJSON) } 
        operation: { try await sut.action() }
        
        // Assert  
        #expect(result.value == expected)
    }
}
```

## Standard Test Structure

```
Tests/{Component}Tests/
├── Integration/
│   └── {Component}Tests.swift     # Main test scenarios
├── Unit/ (add when needed)
│   └── {Specific}Tests.swift     # Detailed unit tests
├── Resources/
│   └── mocks.json                 # Test data
└── TestHelpers.swift             # Shared utilities
```

## Core Test Templates

### 1. Integration Test Template  
```swift
// Tests/FeatureTests/Integration/FeatureTests.swift
import Testing
import Dependencies
import Foundation
import Entities
import NetworkService
@testable import FeatureName

@Suite("Feature Tests")
struct FeatureTests {
    let repository = DependencyValues.live.featureRepository

    @Test("US-{number}: {User story}")
    func userStory() async throws {
        // Arrange
        let mockJSON = TestResources.loadMock("valid")
        
        // Act
        let result = try await withDependencies {
            $0.remoteDataSource = liveRemote
            $0.networkService = MockNetworkService(mockJSON)
        } operation: {
            try await repository.method(input)
        }
        
        // Assert
        #expect(result.field == expected)
    }

    @Test("Handles error scenario")
    func errorHandling() async throws {
        let expectedError = AppError.network(.invalidResponse)
        let mockNetwork = MockNetworkService { _ in throw expectedError }

        await #expect(throws: any Error.self) {
            try await withDependencies { 
                $0.networkService = mockNetwork 
            } operation: {
                try await repository.method(input)
            }
        }
    }
}
```

### 2. Unit Test Template (add when needed)
```swift
// Tests/FeatureTests/Unit/{Component}Tests.swift
import Testing
@testable import FeatureName

@Suite("{Component} Tests")
struct ComponentTests {
    @Test("Does {thing} successfully") 
    func doesThing() async throws {
        // Arrange
        let input = TestData.validInput
        let mock = MockService()
        mock.setResult(expected)
        
        // Act
        let result = try await withDependencies { $0.service = mock } 
        operation: { try await sut.method(input) }
        
        // Assert
        #expect(result.property == expected)
    }
    
    @Test("Handles {error scenario}")
    func handlesError() async throws {
        let mock = MockService()
        mock.simulateError()
        
        await #expect(throws: Error.self) {
            try await withDependencies { $0.service = mock }
            operation: { try await sut.method() }
        }
    }
}
```

### 3. Test Helpers (minimal)
```swift
// Tests/FeatureTests/TestHelpers.swift
import Testing
import NetworkService
import Framework
import Dependencies

// MARK: - Test Data Loader
enum TestResources {
    static func loadMock(_ key: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: "mocks", withExtension: "json"),
              let json = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any],
              let responseDict = json[key] as? [String: Any] else {
            throw TestResourceError.notFound(key)
        }
        return try JSONSerialization.data(withJSONObject: responseDict)
    }
}

// MARK: - Centralized Test Data (add as needed)
enum TestData {
    static let validInput = Entity(/* fields */)
    static let expectedOutput = Entity(/* fields */)
}

// MARK: - Mock Setup
extension MockNetworkService {
    init(mockData: Data) {
        self.init(mockResponseProvider: { _ in mockData })
    }
    
    init(mockResponseProvider: @escaping (URLRequest) throws -> Data) {
        // Custom initialization
    }
}

enum TestResourceError: Error, LocalizedError {
    case notFound(String)
    var errorDescription: String? {
        return "Test resource '\(key)' not found"
    }
}
```

### 4. Mock Data Template
```json
// Tests/FeatureTests/Resources/mocks.json
{
  "valid": { /* valid response data */ },
  "error": { /* error response data */ },
  "empty": { /* empty response data */ },
  "edge_case": { /* edge case data */ }
}
```

## Quick Reference

### ✅ Always Include
- [ ] Happy path integration test
- [ ] Key error scenarios  
- [ ] One user story test

### ✅ Add When Needed
- Unit tests in `Unit/` folder
- Edge case scenarios
- Performance tests

### Common Patterns
```swift
// Arrange
let mock = MockService()
mock.setResult(expected)

// Act  
let result = try await withDependencies { $0.service = mock } 
operation: { try await sut.action() }

// Assert
#expect(result.property == expected)
```

## When You Need More

For advanced testing concepts, see: `docs/development/testing-strategies.md`

---


