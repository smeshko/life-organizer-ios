# Testing Strategy Guide - Life Organizer iOS

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
// ❌ DON'T: Test private methods
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

*This guide complements the test creation template with comprehensive testing strategies.*

*Last updated: 2025-11-08*
*Based on Life Organizer iOS project testing experience*
