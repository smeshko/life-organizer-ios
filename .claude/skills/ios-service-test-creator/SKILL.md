---
name: iOS Service Test Creator
description: Write comprehensive tests for services in the Rulebook iOS project following the test architecture pattern from NetworkService tests. This skill should be used when creating test suites for services, implementing mock protocols, or writing method-specific tests with proper organization. Uses Swift Testing framework and Swift 6 concurrency.
---

# iOS Service Test Creator

Write comprehensive, well-organized tests for services following the Rulebook iOS project's test architecture pattern established in NetworkService tests (PR #74).

## When to Use

Use this skill when:
- Writing tests for a new service
- Creating comprehensive test coverage for service methods
- Implementing thread-safe mock protocols
- Organizing tests into focused, maintainable files

## Test Architecture

All service tests follow this structure:
```
Tests/{ServiceName}Tests/
├── Helpers/
│   ├── Mock{Protocol}.swift          # Thread-safe mock implementation
│   ├── Test{Domain}Models.swift      # Test data models with samples
│   └── Test{Service}Fixtures.swift   # Reusable test objects
├── {Service}{Method}Tests.swift      # One file per public method
└── {Service}ErrorHandlingTests.swift # Cross-method consistency
```

## Quick Start

### 1. Analyze Service Under Test

Document:
- **Public Methods**: What are all the public methods to test?
- **Dependencies**: What external protocols does it use?
- **Error Cases**: What errors can each method throw?
- **Data Types**: What inputs/outputs does it work with?

### 2. Create Directory Structure

Use the helper script to create the standard structure:

```bash
scripts/create_test_structure.sh {ServiceName}
```

This creates the test directory with Helpers/ subdirectory.

### 3. Follow Implementation Steps

Refer to `references/test-implementation.md` for the detailed step-by-step guide covering:

1. Analyze service under test
2. Create directory structure
3. Create mock protocol implementation (thread-safe)
4. Create test data models
5. Create reusable test fixtures
6. Create method-specific test files
7. Create error handling consistency tests
8. Update Package.swift

### 4. Use Code Templates

All code templates are in `references/code-templates.md`:
- Thread-safe mock protocol pattern
- Test data models with sample data
- Test fixtures for reusable objects
- Method-specific test structure
- Error handling test patterns
- Given-When-Then test structure

### 5. Verify Test Quality

Before completing, check against `references/checklist.md` to ensure:
- Coverage (success, error, edge cases)
- Code quality (organization, independence, clarity)
- Infrastructure (reusable mocks, sample data, thread-safety, Swift 6 compliance)

### 6. Avoid Common Pitfalls

Review `references/pitfalls.md` for patterns to avoid:
- Shared test state
- Testing mocks instead of implementation
- Monolithic test files
- Duplicating test infrastructure

## Key Principles

- **One File Per Method**: Keep test files focused (<200 lines each)
- **Thread-Safe Mocks**: Use NSLock for Sendable compliance
- **Test Independence**: Each test uses unique identifiers/keys
- **Given-When-Then**: Clear test structure for readability
- **Validate Implementation**: Test the service, not the mocks
- **Reusable Infrastructure**: Share mocks, models, and fixtures

## Test Organization

Tests are organized by:
- **Helpers/**: Shared infrastructure (mocks, models, fixtures)
- **Method Tests**: One file per public method with success, error, and edge cases
- **Error Tests**: Cross-method consistency verification

Each test file should be:
- Focused on a single method or concern
- Under 200 lines (split if larger)
- Independent and runnable in any order
- Using descriptive test names
