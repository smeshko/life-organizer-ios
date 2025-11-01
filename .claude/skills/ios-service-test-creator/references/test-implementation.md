# Test Implementation Guide

This guide provides a step-by-step process for implementing tests for services in the Rulebook iOS project, following the patterns established in NetworkService tests (PR #74).

## Test Architecture Pattern

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

## Step-by-Step Implementation Process

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

Create the directory structure for your test files:
- A main test directory named `{ServiceName}Tests`
- A `Helpers/` subdirectory for shared test infrastructure

### Step 3: Create Mock Protocol Implementation

**File Location**: `Tests/{ServiceName}Tests/Helpers/Mock{Protocol}.swift`

**Purpose**: Create a thread-safe mock implementation of the protocol that your service depends on.

**Key Requirements:**
- Thread-safe with NSLock for Swift 6 concurrency
- `Sendable` conformance for Swift 6
- Support both success and error simulation
- Reset functionality for test isolation
- Static methods for test configuration

**Pattern**: Use a nested `Storage` class with NSLock to manage mock responses in a thread-safe manner. The storage maps string keys to mock responses, allowing tests to register specific responses for specific scenarios.

### Step 4: Create Test Data Models

**File Location**: `Tests/{ServiceName}Tests/Helpers/Test{Domain}Models.swift`

**Purpose**: Define lightweight test models that represent the data your service works with.

**Components:**
- **Test Models**: Simple `Codable`, `Equatable`, `Sendable` structs representing domain entities
- **Sample Data Helpers**: Static methods that return pre-configured test instances
- **Sample JSON Helpers**: Methods that return valid JSON data for testing
- **Invalid Data Helpers**: Methods that return malformed data for error testing

### Step 5: Create Reusable Test Fixtures

**File Location**: `Tests/{ServiceName}Tests/Helpers/Test{Service}Fixtures.swift`

**Purpose**: Create reusable test objects that conform to protocols your service requires.

**Types of Fixtures:**
- **Simple fixtures**: Basic implementations with default values
- **Custom fixtures**: Implementations with configurable properties
- **Invalid fixtures**: Implementations that fail validation or return nil values

These fixtures help avoid duplicating test object creation across multiple test files.

### Step 6: Create Method-Specific Test Files

**File Location**: `Tests/{ServiceName}Tests/{Service}{Method}Tests.swift`

**Purpose**: Create one test file per public method to keep tests focused and maintainable.

**File Structure:**
- Suite-level documentation explaining what's being tested
- MARK comments organizing tests by category
- Given-When-Then structure in each test
- Success tests, error tests, and edge case tests

**Naming Convention:**
- Suite name: `{ServiceName} {method} Tests`
- Test names: Descriptive, starting with method name
- Example: `sendRequestParsesValidResponse()`

**Test Organization:**
- **Success Tests**: Test normal operation with valid inputs
- **Error Tests**: Test error handling and error transformation
- **Edge Cases**: Test boundary conditions, empty data, concurrent calls

### Step 7: Create Error Handling Consistency Tests

**File Location**: `Tests/{ServiceName}Tests/{Service}ErrorHandlingTests.swift`

**Purpose**: Verify that all methods handle similar errors consistently across the service.

**Pattern**: Create tests that verify the same error from a dependency is transformed the same way across different service methods. This ensures a consistent error handling strategy.

**Focus Areas:**
- Common dependency errors are handled uniformly
- Error types are transformed consistently to AppError
- Error messages and codes follow the same patterns
- All methods use the same error handling approach

### Step 8: Update Package.swift

**Location**: Root `Package.swift` file

**Add Test Target**: Add a new test target to the `targets` array:

```swift
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

**Required Dependencies:**
- The service module being tested
- Any framework modules the service depends on
- Swift Testing framework package

**Verification**: Run `swift test` to ensure the new test target is recognized and all tests pass.

## File Size Guidelines

- **Method-specific test files**: Keep under 200 lines when possible
- **Helper files**: Can be larger as they contain reusable infrastructure
- **Error handling tests**: Usually concise, around 50-100 lines

## Test Independence

Each test must be independent:
- Use unique identifier keys for mock registration
- No shared state between tests
- Tests can run in any order
- Each test sets up its own mock responses

## Documentation Standards

- Add doc comments to test suites explaining coverage
- Use descriptive test function names
- Include MARK comments to organize test categories
- Document any complex test setup or expectations
