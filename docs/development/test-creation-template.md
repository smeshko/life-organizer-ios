# Test Creation Template - Life Organizer iOS

## 🎯 Overview

This template provides a systematic approach for creating comprehensive test coverage in the Life Organizer iOS project using Swift Testing framework. All tests follow a consistent structure and naming convention.

## 📁 Test Structure Template

```
Tests/{Component}Tests/
├── Unit/                           # Unit tests for individual components
│   ├── Mappers/                   # Mapper transformation tests
│   │   ├── {Entity}MapperTests.swift
│   │   └── {Response}MapperTests.swift
│   ├── DataSources/               # Data source tests
│   │   ├── {Feature}LocalDataSourceTests.swift
│   │   └── {Feature}RemoteDataSourceTests.swift
│   └── Repositories/              # Repository tests
│       └── {Feature}RepositoryTests.swift
├── Integration/                   # Integration and end-to-end tests
│   ├── EndToEndTests.swift       # User story scenarios
│   ├── ErrorScenarioTests.swift  # Error handling flows
│   └── EdgeCaseTests.swift       # Boundary conditions
├── Resources/                     # Test resources and fixtures
│   ├── mock-responses.json       # JSON test data
│   └── {TestFile}.{ext}         # Other test files
└── TestHelpers.swift             # Shared test utilities
```

## 🧪 Test File Templates

### 1. Mapper Tests Template

```swift
// Tests/{Feature}FeatureTests/Unit/Mappers/{Entity}MapperTests.swift
import Testing
import Foundation
import Entities
import Framework
@testable import {Feature}Feature

@Suite("{Entity}Mapper Tests")
struct {Entity}MapperTests {

    // MARK: - Valid Mapping Tests

    @Test("Maps valid {entity} DTO to domain entity")
    func mapsValid{Entity}DTO() throws {
        // Arrange
        let dto = {Entity}DTO(
            field1: "value1",
            field2: "value2"
            // ... all fields
        )

        // Act
        let result = try {Entity}Mapper.toDomain(dto)

        // Assert
        #expect(result.field1 == "value1")
        #expect(result.field2 == "value2")
        // ... verify all mapped fields
    }

    @Test("Maps {entity} with optional fields")
    func mapsWithOptionalFields() throws {
        // Arrange
        let dto = {Entity}DTO(
            requiredField: "value",
            optionalField: nil
        )

        // Act
        let result = try {Entity}Mapper.toDomain(dto)

        // Assert
        #expect(result.requiredField == "value")
        #expect(result.optionalField == nil)
    }

    // MARK: - Error Handling Tests

    @Test("Throws error for invalid {field}")
    func throwsErrorForInvalid{Field}() throws {
        // Arrange
        let dto = {Entity}DTO(
            field: "invalid-value"
        )

        // Act & Assert
        #expect(throws: AppError.self) {
            try {Entity}Mapper.toDomain(dto)
        }
    }

    @Test("Throws specific error message for {error case}")
    func throwsSpecificErrorFor{ErrorCase}() throws {
        // Arrange
        let dto = {Entity}DTO(
            field: "invalid-value"
        )

        // Act & Assert
        do {
            _ = try {Entity}Mapper.toDomain(dto)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .{featureError}(let specificError) = error,
                  case .{errorCase}(let message) = specificError else {
                Issue.record("Expected {feature}.{errorCase} error")
                return
            }
            #expect(message.contains("expected string"))
        }
    }

    // MARK: - Edge Case Tests

    @Test("Maps edge case: {description}")
    func mapsEdgeCase{Name}() throws {
        // Arrange
        let dto = {Entity}DTO(
            field: edgeCaseValue
        )

        // Act
        let result = try {Entity}Mapper.toDomain(dto)

        // Assert
        #expect(result.field == expectedValue)
    }

    @Test("Maps all valid {category} values")
    func mapsAllValid{Category}Values() throws {
        let validValues = ["value1", "value2", "value3"]

        for value in validValues {
            let dto = {Entity}DTO(field: value)
            let result = try {Entity}Mapper.toDomain(dto)
            #expect(result.field.rawValue == value)
        }
    }

    // MARK: - Integration Tests

    @Test("Correctly transforms complex nested structure")
    func transformsComplexStructure() throws {
        // Arrange
        let complexDTO = {Entity}DTO(
            nestedField: NestedDTO(
                subField1: "value1",
                subField2: 42
            )
        )

        // Act
        let result = try {Entity}Mapper.toDomain(complexDTO)

        // Assert
        #expect(result.nestedField.subField1 == "value1")
        #expect(result.nestedField.subField2 == 42)
    }
}
```

### 2. Data Source Tests Template

```swift
// Tests/{Feature}FeatureTests/Unit/DataSources/{Feature}RemoteDataSourceTests.swift
import Testing
import Foundation
import Dependencies
import Entities
import NetworkService
@testable import {Feature}Feature

@Suite("{Feature}RemoteDataSource Tests")
struct {Feature}RemoteDataSourceTests {

    // MARK: - Fetch Tests

    @Test("Fetches {entity} from API successfully")
    func fetches{Entity}Successfully() async throws {
        // Arrange
        let expectedDTO = {Entity}DTO(/* fields */)
        let mockJSON = try JSONEncoder().encode(expectedDTO)
        let mockNetwork = MockNetworkService(mockData: mockJSON)

        let dataSource = await withDependencies {
            $0.networkService = mockNetwork
        } operation: {
            {Feature}RemoteDataSource()
        }

        // Act
        let result = try await dataSource.fetch(id: "test-id")

        // Assert
        #expect(result.id.uuidString == "test-id")
        // ... verify mapped fields
    }

    @Test("Throws error when network request fails")
    func throwsErrorOnNetworkFailure() async throws {
        // Arrange
        let mockNetwork = MockNetworkService(mockResponseProvider: { _ in
            throw AppError.network(.requestFailed("Network error"))
        })

        let dataSource = await withDependencies {
            $0.networkService = mockNetwork
        } operation: {
            {Feature}RemoteDataSource()
        }

        // Act & Assert
        await #expect(throws: (any Error).self) {
            try await dataSource.fetch(id: "test-id")
        }
    }

    // MARK: - Create Tests

    @Test("Creates {entity} via API")
    func creates{Entity}() async throws {
        // Arrange
        let entity = {Entity}(/* fields */)
        let responseDTO = {Entity}DTO(/* fields */)
        let mockJSON = try JSONEncoder().encode(responseDTO)
        let mockNetwork = MockNetworkService(mockData: mockJSON)

        let dataSource = await withDependencies {
            $0.networkService = mockNetwork
        } operation: {
            {Feature}RemoteDataSource()
        }

        // Act
        let result = try await dataSource.create(entity)

        // Assert
        #expect(result.id == entity.id)
    }

    // MARK: - Update Tests

    @Test("Updates {entity} via API")
    func updates{Entity}() async throws {
        // Arrange
        let entity = {Entity}(/* fields */)
        let responseDTO = {Entity}DTO(/* updated fields */)
        let mockJSON = try JSONEncoder().encode(responseDTO)
        let mockNetwork = MockNetworkService(mockData: mockJSON)

        let dataSource = await withDependencies {
            $0.networkService = mockNetwork
        } operation: {
            {Feature}RemoteDataSource()
        }

        // Act
        let result = try await dataSource.update(entity)

        // Assert
        #expect(result.id == entity.id)
    }

    // MARK: - Error Propagation Tests

    @Test("Propagates decoding errors")
    func propagatesDecodingErrors() async throws {
        // Arrange
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        let mockNetwork = MockNetworkService(mockData: invalidJSON)

        let dataSource = await withDependencies {
            $0.networkService = mockNetwork
        } operation: {
            {Feature}RemoteDataSource()
        }

        // Act & Assert
        await #expect(throws: (any Error).self) {
            try await dataSource.fetch(id: "test-id")
        }
    }
}
```

### 3. Repository Tests Template

```swift
// Tests/{Feature}FeatureTests/Unit/Repositories/{Feature}RepositoryTests.swift
import Testing
import Foundation
import Dependencies
import Entities
@testable import {Feature}Feature

@Suite("{Feature}Repository Tests")
struct {Feature}RepositoryTests {

    // MARK: - Fetch Local Tests

    @Test("Fetches {entity} from local storage")
    func fetchesFromLocalStorage() async throws {
        // Arrange
        let expected{Entity} = {Entity}(/* fields */)
        let mockLocal = Mock{Feature}LocalDataSource()
        await mockLocal.setMockResult(expected{Entity}, forMethod: "fetch")

        let repository = await withDependencies {
            $0.{feature}LocalDataSource = mockLocal
        } operation: {
            {Feature}Repository()
        }

        // Act
        let result = try await repository.fetchLocal(id: "test-id")

        // Assert
        #expect(result.id == expected{Entity}.id)
    }

    @Test("Throws error when local fetch fails")
    func throwsErrorOnLocalFetchFailure() async throws {
        // Arrange
        let mockLocal = Mock{Feature}LocalDataSource()
        await mockLocal.simulateError()

        let repository = await withDependencies {
            $0.{feature}LocalDataSource = mockLocal
        } operation: {
            {Feature}Repository()
        }

        // Act & Assert
        await #expect(throws: {Feature}Error.self) {
            try await repository.fetchLocal(id: "test-id")
        }
    }

    // MARK: - Fetch Remote Tests

    @Test("Fetches {entity} from remote and caches locally")
    func fetchesFromRemoteAndCaches() async throws {
        // Arrange
        let expected{Entity} = {Entity}(/* fields */)
        let mockRemote = Mock{Feature}RemoteDataSource()
        let mockLocal = Mock{Feature}LocalDataSource()
        await mockRemote.setMockResult(expected{Entity}, forMethod: "fetch")

        let repository = await withDependencies {
            $0.{feature}LocalDataSource = mockLocal
            $0.{feature}RemoteDataSource = mockRemote
        } operation: {
            {Feature}Repository()
        }

        // Act
        let result = try await repository.fetchRemote(id: "test-id")

        // Assert
        #expect(result.id == expected{Entity}.id)

        // Verify cached locally
        let cached = try await mockLocal.fetch(id: "test-id")
        #expect(cached.id == expected{Entity}.id)
    }

    // MARK: - Smart Fetch Tests

    @Test("Falls back to remote when local fails")
    func fallsBackToRemote() async throws {
        // Arrange
        let expected{Entity} = {Entity}(/* fields */)
        let mockLocal = Mock{Feature}LocalDataSource()
        let mockRemote = Mock{Feature}RemoteDataSource()
        await mockLocal.simulateError()
        await mockRemote.setMockResult(expected{Entity}, forMethod: "fetch")

        let repository = await withDependencies {
            $0.{feature}LocalDataSource = mockLocal
            $0.{feature}RemoteDataSource = mockRemote
        } operation: {
            {Feature}Repository()
        }

        // Act
        let result = try await repository.fetch(id: "test-id")

        // Assert
        #expect(result.id == expected{Entity}.id)
    }

    // MARK: - Save Tests

    @Test("Saves {entity} to local storage")
    func savesToLocalStorage() async throws {
        // Arrange
        let entity = {Entity}(/* fields */)
        let mockLocal = Mock{Feature}LocalDataSource()

        let repository = await withDependencies {
            $0.{feature}LocalDataSource = mockLocal
        } operation: {
            {Feature}Repository()
        }

        // Act
        try await repository.save(entity)

        // Assert - verify saved
        let saved = try await mockLocal.fetch(id: entity.id.uuidString)
        #expect(saved.id == entity.id)
    }

    // MARK: - Delete Tests

    @Test("Deletes {entity} from local storage")
    func deletesFromLocalStorage() async throws {
        // Arrange
        let entity = {Entity}(/* fields */)
        let mockLocal = Mock{Feature}LocalDataSource()
        await mockLocal.save(entity)

        let repository = await withDependencies {
            $0.{feature}LocalDataSource = mockLocal
        } operation: {
            {Feature}Repository()
        }

        // Act
        try await repository.delete(id: entity.id.uuidString)

        // Assert - verify deleted
        await #expect(throws: {Feature}Error.notFound) {
            try await mockLocal.fetch(id: entity.id.uuidString)
        }
    }

    // MARK: - Sync Tests

    @Test("Syncs {entity} from remote to local")
    func syncsFromRemoteToLocal() async throws {
        // Arrange
        let remoteEntity = {Entity}(/* fields */)
        let mockRemote = Mock{Feature}RemoteDataSource()
        let mockLocal = Mock{Feature}LocalDataSource()
        await mockRemote.setMockResult(remoteEntity, forMethod: "fetch")

        let repository = await withDependencies {
            $0.{feature}LocalDataSource = mockLocal
            $0.{feature}RemoteDataSource = mockRemote
        } operation: {
            {Feature}Repository()
        }

        // Act
        try await repository.sync(id: "test-id")

        // Assert - verify synced to local
        let local = try await mockLocal.fetch(id: "test-id")
        #expect(local.id == remoteEntity.id)
    }

    @Test("Gracefully handles sync failures")
    func handlesSync Failures() async throws {
        // Arrange
        let mockRemote = Mock{Feature}RemoteDataSource()
        let mockLocal = Mock{Feature}LocalDataSource()
        await mockRemote.simulateError()

        let repository = await withDependencies {
            $0.{feature}LocalDataSource = mockLocal
            $0.{feature}RemoteDataSource = mockRemote
        } operation: {
            {Feature}Repository()
        }

        // Act - Should not throw
        try await repository.sync(id: "test-id")

        // Assert - No error thrown (graceful failure)
    }
}
```

### 4. Integration Tests Template

```swift
// Tests/{Feature}FeatureTests/Integration/EndToEndTests.swift
import Testing
import Dependencies
import Foundation
import Entities
import NetworkService
@testable import {Feature}Feature

@Suite("End-to-End Integration Tests")
struct EndToEndTests {
    let repository = DependencyValues.live.{feature}Repository

    // MARK: - User Story Tests

    @Test("US-{number}: {User story description}")
    func userStory{Name}() async throws {
        // Arrange: Load mock response from file
        let mockJSON = try TestResources.loadMockResponse("scenario_key")

        // Act: Process with live repository using mocked network service
        let result = try await withDependencies {
            // Force all dependencies to use live values
            $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.{method}(parameter: "value")
        }

        // Assert: Verify complete flow
        #expect(result.{field} == expectedValue)
        #expect(result.{otherField} == otherExpectedValue)

        // Assert nested structures if needed
        guard case .{enumCase}(let nestedValue) = result.{nestedField} else {
            Issue.record("Expected {enumCase}, got: \(String(describing: result.{nestedField}))")
            return
        }

        #expect(nestedValue.{property} == expectedNestedValue)
    }

    @Test("{Scenario description}")
    func {scenarioName}() async throws {
        // Arrange
        let mockJSON = try TestResources.loadMockResponse("scenario_key")

        // Act
        let result = try await withDependencies {
            $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.{method}(parameter: "value")
        }

        // Assert
        #expect(result.{field} == expectedValue)
    }

    // MARK: - Data Validation Tests

    @Test("All {entity} {property} values are supported")
    func all{Property}ValuesSupported() {
        let allValues: [{Type}] = [
            .value1, .value2, .value3,
            // ... all enum cases
        ]

        #expect(allValues.count == expectedCount)
    }

    @Test("{Entity} {property} map correctly from API strings")
    func {property}Mapping() throws {
        let testCases: [(String, {Type})] = [
            ("api_value1", .domainValue1),
            ("api_value2", .domainValue2),
            // ... test cases
        ]

        for (apiString, expected) in testCases {
            let mapped = {Type}(rawValue: apiString)
            #expect(mapped == expected, "Failed to map '\(apiString)' to \(expected)")
        }
    }
}
```

### 5. Error Scenario Tests Template

```swift
// Tests/{Feature}FeatureTests/Integration/ErrorScenarioTests.swift
import Testing
import Dependencies
import Foundation
import Framework
import Entities
import NetworkService
@testable import {Feature}Feature

@Suite("Error Scenario Tests")
struct ErrorScenarioTests {
    let repository = DependencyValues.live.{feature}Repository

    @Test("Network error propagates correctly")
    func networkErrorHandling() async throws {
        // Arrange: Create mock network service that throws an error
        let expectedError = AppError.network(.invalidResponse)
        let mockNetworkService = MockNetworkService(mockResponseProvider: { _ in
            throw expectedError
        })

        // Act & Assert: Verify error propagates through the full stack
        await #expect(throws: (any Error).self) {
            try await withDependencies {
                $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
                $0.networkService = mockNetworkService
            } operation: {
                try await self.repository.{method}(parameter: "value")
            }
        }
    }

    @Test("Invalid JSON response throws decoding error")
    func invalidJSONResponse() async throws {
        // Arrange: Return invalid JSON
        let invalidJSON = "{ invalid json }".data(using: .utf8)!

        // Act & Assert
        await #expect(throws: (any Error).self) {
            try await withDependencies {
                $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
                $0.networkService = MockNetworkService(mockData: invalidJSON)
            } operation: {
                try await self.repository.{method}(parameter: "value")
            }
        }
    }

    @Test("Missing required field throws validation error")
    func missingRequiredField() async throws {
        // Arrange: JSON missing required field
        let incompleteJSON = """
        {
            "field1": "value1"
            // missing required field2
        }
        """.data(using: .utf8)!

        // Act & Assert
        await #expect(throws: (any Error).self) {
            try await withDependencies {
                $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
                $0.networkService = MockNetworkService(mockData: incompleteJSON)
            } operation: {
                try await self.repository.{method}(parameter: "value")
            }
        }
    }

    @Test("Valid response is successfully processed through full stack")
    func successfulEndToEndProcessing() async throws {
        // Arrange: Load valid mock response
        let validJSON = try TestResources.loadMockResponse("valid_scenario")

        // Act: Process through live repository with mocked network
        let result = try await withDependencies {
            $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
            $0.networkService = MockNetworkService(mockData: validJSON)
        } operation: {
            try await self.repository.{method}(parameter: "value")
        }

        // Assert: Verify successful processing
        #expect(result.{field} == expectedValue)
    }

    @Test("{Specific error case} is handled correctly")
    func {errorCase}Handling() async throws {
        // Arrange
        let errorJSON = try TestResources.loadMockResponse("error_scenario")

        // Act
        do {
            _ = try await withDependencies {
                $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
                $0.networkService = MockNetworkService(mockData: errorJSON)
            } operation: {
                try await self.repository.{method}(parameter: "value")
            }
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            // Assert: Verify correct error type and message
            guard case .{featureError}(let specificError) = error else {
                Issue.record("Expected {feature} error, got: \(error)")
                return
            }

            switch specificError {
            case .{errorCase}(let message):
                #expect(message.contains("expected string"))
            default:
                Issue.record("Expected {errorCase}, got: \(specificError)")
            }
        }
    }
}
```

### 6. Edge Case Tests Template

```swift
// Tests/{Feature}FeatureTests/Integration/EdgeCaseTests.swift
import Testing
import Dependencies
import Foundation
import Entities
import NetworkService
@testable import {Feature}Feature

@Suite("Edge Case Tests")
struct EdgeCaseTests {
    let repository = DependencyValues.live.{feature}Repository

    @Test("Handles empty response correctly")
    func handlesEmptyResponse() async throws {
        // Arrange
        let emptyJSON = try TestResources.loadMockResponse("empty_response")

        // Act
        let result = try await withDependencies {
            $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
            $0.networkService = MockNetworkService(mockData: emptyJSON)
        } operation: {
            try await self.repository.{method}(parameter: "value")
        }

        // Assert
        #expect(result.{collection}.isEmpty)
    }

    @Test("Handles very large {entity} count")
    func handlesLarge{Entity}Count() async throws {
        // Arrange
        let largeJSON = try TestResources.loadMockResponse("large_dataset")

        // Act
        let result = try await withDependencies {
            $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
            $0.networkService = MockNetworkService(mockData: largeJSON)
        } operation: {
            try await self.repository.{method}(parameter: "value")
        }

        // Assert
        #expect(result.{collection}.count > 1000)
    }

    @Test("Handles Unicode and special characters")
    func handlesUnicodeCharacters() async throws {
        // Arrange
        let unicodeJSON = try TestResources.loadMockResponse("unicode_data")

        // Act
        let result = try await withDependencies {
            $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
            $0.networkService = MockNetworkService(mockData: unicodeJSON)
        } operation: {
            try await self.repository.{method}(parameter: "value")
        }

        // Assert
        #expect(result.{field}.contains("émoji"))
        #expect(result.{field}.contains("中文"))
    }

    @Test("Handles boundary values for {field}")
    func handlesBoundaryValues() async throws {
        let testCases: [(value: Any, key: String)] = [
            (value: 0, key: "zero_value"),
            (value: Int.max, key: "max_value"),
            (value: Double.infinity, key: "infinity"),
            // ... boundary cases
        ]

        for testCase in testCases {
            let mockJSON = try TestResources.loadMockResponse(testCase.key)

            let result = try await withDependencies {
                $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
                $0.networkService = MockNetworkService(mockData: mockJSON)
            } operation: {
                try await self.repository.{method}(parameter: "value")
            }

            // Assert based on test case
            #expect(result.{field} != nil)
        }
    }

    @Test("Handles missing optional fields gracefully")
    func handlesMissingOptionalFields() async throws {
        // Arrange
        let minimalJSON = try TestResources.loadMockResponse("minimal_data")

        // Act
        let result = try await withDependencies {
            $0.{feature}RemoteDataSource = DependencyValues.live.{feature}RemoteDataSource
            $0.networkService = MockNetworkService(mockData: minimalJSON)
        } operation: {
            try await self.repository.{method}(parameter: "value")
        }

        // Assert - all optional fields should be nil
        #expect(result.optionalField1 == nil)
        #expect(result.optionalField2 == nil)

        // Required fields should still be present
        #expect(result.requiredField != nil)
    }
}
```

### 7. Test Helpers Template

```swift
// Tests/{Feature}FeatureTests/TestHelpers.swift
import Foundation
import NetworkService
import Framework
import Dependencies

// MARK: - Test Helpers

extension MockNetworkService {
    init(mockData: Data) {
        self.init(mockResponseProvider: { _ in mockData })
    }
}

// MARK: - JSON Resource Loader

enum TestResources {
    static func loadMockResponse(_ key: String) throws -> Data {
        // Use SPM's generated Bundle.module
        guard let url = Bundle.module.url(forResource: "mock-responses", withExtension: "json") else {
            throw TestResourceError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseDict = json[key] as? [String: Any] else {
            throw TestResourceError.responseNotFound(key)
        }

        return try JSONSerialization.data(withJSONObject: responseDict)
    }

    static func loadTestFile(_ filename: String, extension ext: String) throws -> URL {
        guard let url = Bundle.module.url(forResource: filename, withExtension: ext) else {
            throw TestResourceError.fileNotFound
        }
        return url
    }

    static func createTemporaryCopy(of resourceName: String, extension ext: String) throws -> URL {
        let sourceURL = try loadTestFile(resourceName, extension: ext)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).\(ext)")

        try FileManager.default.copyItem(at: sourceURL, to: tempURL)
        return tempURL
    }
}

enum TestResourceError: Error, LocalizedError {
    case fileNotFound
    case responseNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Test resource file not found"
        case .responseNotFound(let key):
            return "Response key '\(key)' not found in mock-responses.json"
        }
    }
}

// MARK: - Mock Entity Helpers

extension {Entity} {
    static var mock: Self {
        {Entity}(
            id: UUID(),
            field1: "mock-value1",
            field2: "mock-value2"
            // ... mock values for all fields
        )
    }

    static func mock(with overrides: ({Entity}) -> {Entity}) -> Self {
        overrides(Self.mock)
    }
}
```

### 8. Mock Responses JSON Template

```json
// Tests/{Feature}FeatureTests/Resources/mock-responses.json
{
  "valid_scenario": {
    "field1": "value1",
    "field2": "value2",
    "nested_object": {
      "sub_field1": "sub_value1",
      "sub_field2": 42
    }
  },
  "error_scenario": {
    "success": false,
    "error": "Error message",
    "error_code": "ERROR_CODE"
  },
  "empty_response": {
    "items": [],
    "count": 0
  },
  "edge_case_unicode": {
    "field": "Café ☕️ 中文 émoji"
  },
  "edge_case_large_number": {
    "amount": 999999999.99
  },
  "edge_case_minimal": {
    "required_field": "value"
    // All optional fields omitted
  }
}
```

## 📋 Test Coverage Checklist

### ✅ Mapper Tests
- [ ] Valid mapping scenarios for all fields
- [ ] Optional field handling (nil and present)
- [ ] Error cases for invalid input
- [ ] Specific error messages verified
- [ ] Edge cases (large numbers, special characters, etc.)
- [ ] All enum value mappings tested
- [ ] Complex nested structure transformations
- [ ] Graceful degradation (unknown values → fallback)

### ✅ Data Source Tests
- [ ] Successful fetch operations
- [ ] Successful create operations
- [ ] Successful update operations
- [ ] Network error propagation
- [ ] Decoding error handling
- [ ] Invalid response handling
- [ ] Timeout scenarios (if applicable)

### ✅ Repository Tests
- [ ] Local fetch success and failure
- [ ] Remote fetch success and failure
- [ ] Local-first fallback logic
- [ ] Automatic caching on remote fetch
- [ ] Save operations
- [ ] Delete operations
- [ ] Sync operations
- [ ] Graceful sync failure handling

### ✅ Integration Tests
- [ ] Complete user story flows
- [ ] End-to-end data flow verification
- [ ] Multiple dependency coordination
- [ ] Real-world scenario coverage
- [ ] Data validation across layers

### ✅ Error Scenario Tests
- [ ] Network errors propagate correctly
- [ ] Invalid JSON handling
- [ ] Missing required fields
- [ ] Malformed data handling
- [ ] Specific error types and messages
- [ ] Error recovery paths

### ✅ Edge Case Tests
- [ ] Empty responses
- [ ] Large datasets
- [ ] Unicode and special characters
- [ ] Boundary values (min, max, zero, infinity)
- [ ] Missing optional fields
- [ ] Concurrent operations (if applicable)
- [ ] Rate limiting (if applicable)

### ✅ Test Infrastructure
- [ ] Mock responses in JSON file
- [ ] Test helpers for common operations
- [ ] Mock entity factories
- [ ] Temporary file management (if needed)
- [ ] Proper test isolation
- [ ] Clean resource cleanup

## 🎯 Swift Testing Patterns

### Test Suite Organization
```swift
@Suite("Descriptive Suite Name")
struct ComponentTests {
    // Group tests logically with MARK comments
}
```

### Test Naming Convention
```swift
@Test("Clear description of what is being tested")
func descriptiveFunctionName() async throws {
    // Test implementation
}
```

### Assertion Patterns
```swift
// Simple assertions
#expect(value == expected)
#expect(value != unexpected)
#expect(collection.isEmpty)
#expect(collection.count == 5)

// Error assertions
#expect(throws: SpecificError.self) {
    try functionThatThrows()
}

await #expect(throws: (any Error).self) {
    try await asyncFunctionThatThrows()
}

// Complex assertions with Issue.record
guard case .enumCase(let associated) = value else {
    Issue.record("Expected .enumCase, got: \(value)")
    return
}
#expect(associated.property == expected)
```

### Arrange-Act-Assert Pattern
```swift
@Test("Description")
func testName() async throws {
    // Arrange: Set up test data and dependencies
    let input = /* test data */
    let mockDependency = /* mock setup */

    // Act: Execute the operation being tested
    let result = try await systemUnderTest.operation(input)

    // Assert: Verify the outcome
    #expect(result.property == expectedValue)
}
```

### Dependency Injection for Testing
```swift
let result = try await withDependencies {
    $0.dependency1 = mockDependency1
    $0.dependency2 = mockDependency2
} operation: {
    try await systemUnderTest.operation()
}
```

## 🚫 Anti-Patterns to Avoid

### 1. Testing Implementation Details
```swift
// ❌ DON'T: Test private implementation
@Test("Private helper is called")
func testPrivateHelper() {
    // Testing private methods
}

// ✅ DO: Test public behavior
@Test("Public method returns correct result")
func testPublicBehavior() {
    // Test observable outcomes
}
```

### 2. Property Validation in Integration Tests
```swift
// ❌ DON'T: Test property counts in integration tests
@Test("All 23 categories are supported")  // In EndToEndTests
func allCategoriesSupported() {
    let allCategories: [Category] = [.cat1, .cat2, /* ... */]
    #expect(allCategories.count == 23)
}

// ✅ DO: Test properties in unit tests or domain tests
// In CategoryTests.swift
@Test("BudgetCategory enum has all expected cases")
func allCategoriesDefined() {
    // Test domain model properties separately
}
```

### 3. Duplicate Test Data
```swift
// ❌ DON'T: Define identical test data in multiple files
// In MapperTests.swift
let dto = BudgetActionDTO(amount: 234.6, /* ... */)

// In IntegrationTests.swift
let dto = BudgetActionDTO(amount: 234.6, /* ... */)

// ✅ DO: Centralize test data
// In TestHelpers.swift
enum TestData {
    enum BudgetDTOs {
        static let validExpense = BudgetActionDTO(amount: 234.6, /* ... */)
    }
}

// Use everywhere
let dto = TestData.BudgetDTOs.validExpense
```

### 4. Brittle Tests
```swift
// ❌ DON'T: Depend on specific order or timing
@Test("Items are in specific order")
func testOrder() {
    #expect(result[0] == item1)
    #expect(result[1] == item2)
}

// ✅ DO: Test logical properties
@Test("All expected items are present")
func testPresence() {
    #expect(result.contains(item1))
    #expect(result.contains(item2))
}
```

### 5. Shared Mutable State
```swift
// ❌ DON'T: Share state between tests
struct Tests {
    var sharedState = /* ... */

    @Test func test1() { /* modifies sharedState */ }
    @Test func test2() { /* depends on sharedState */ }
}

// ✅ DO: Isolate each test
struct Tests {
    @Test func test1() {
        let localState = /* ... */
    }

    @Test func test2() {
        let localState = /* ... */
    }
}
```

### 6. Over-Mocking
```swift
// ❌ DON'T: Mock everything
@Test func test() {
    let mockA = MockA()
    let mockB = MockB()
    let mockC = MockC()
    let mockD = MockD()
    // Too many mocks
}

// ✅ DO: Use real implementations where possible
@Test func test() {
    let realA = RealA()
    let realB = RealB()
    let mockC = MockC() // Only mock external dependencies
}
```

### 7. Unclear Test Names
```swift
// ❌ DON'T: Vague test names
@Test("Test 1")
func test1() { }

// ✅ DO: Descriptive test names
@Test("Fetches user successfully from remote API")
func fetchesUserSuccessfully() { }
```

### 8. Inconsistent Error Testing
```swift
// ❌ DON'T: Mix error testing patterns
@Test func test1() {
    #expect(throws: Error.self) { try operation() }
}

@Test func test2() {
    do {
        try operation()
        Issue.record("Expected error")
    } catch { /* verify */ }
}

// ✅ DO: Use centralized error assertion helpers
@Test func test1() {
    ErrorAssertions.assertThrowsWithMessage(containing: "expected") {
        try operation()
    }
}

@Test func test2() {
    ErrorAssertions.assertThrows(.specific(Error.case)) {
        try operation()
    }
}
```

## 📊 Test Metrics

### Coverage Goals
- **Mappers**: 100% - All transformations and error cases
- **Data Sources**: 90%+ - All public methods and error paths
- **Repositories**: 90%+ - All coordination logic and fallbacks
- **Integration**: 80%+ - Key user stories and error scenarios
- **Edge Cases**: 70%+ - Boundary conditions and special cases

### Test Distribution
- **Unit Tests**: 60-70% of total tests
- **Integration Tests**: 20-30% of total tests
- **Edge Case Tests**: 10-20% of total tests

## 🔄 Test Maintenance

### When to Update Tests
1. Feature requirements change
2. API contracts change
3. Error handling strategy changes
4. New edge cases discovered
5. Performance requirements change

### Test Refactoring Triggers
1. Duplicate test setup code
2. Tests becoming too complex
3. Brittleness (frequent false failures)
4. Poor test organization
5. Unclear test intent

---

*This template follows the Swift Testing framework patterns and Life Organizer iOS project conventions.*

*Last updated: 2025-11-08*
*Based on ActionHandlerFeature test implementation*
