# Service Implementation Checklist

Use this checklist to ensure complete and correct service implementation.

## Protocol Definition

- [ ] **Comprehensive documentation with examples**
  - Include header documentation explaining service purpose
  - Add detailed description of service responsibilities
  - Provide design philosophy explanation

- [ ] **Design principles clearly stated**
  - List key architectural principles
  - Explain design decisions
  - Document simplicity and focus areas

- [ ] **All methods documented with parameters and return values**
  - Document each parameter with description
  - Document return value with type and description
  - Include usage examples for each method

- [ ] **Error cases documented**
  - Document all possible thrown errors
  - Explain when each error occurs
  - Provide error handling examples

- [ ] **`Sendable` conformance for concurrency safety**
  - Protocol marked as `Sendable`
  - All associated types are `Sendable`
  - Thread safety implications documented

## Live Implementation

- [ ] **Consistent error handling using `AppError`**
  - All errors transformed to `AppError` types
  - External errors properly caught and transformed
  - Unknown errors handled with descriptive messages

- [ ] **Proper async/await usage**
  - All asynchronous operations use async/await
  - Proper error propagation with `throws`
  - No callback-based patterns

- [ ] **Dependencies injected through initializer**
  - External services injected via `@Dependency`
  - No direct instantiation of dependencies
  - Dependencies are protocol-based

- [ ] **Private helper methods organized**
  - Helper methods marked as `private`
  - Clear `// MARK: - Private Helpers` section
  - Logical organization of helper functions

- [ ] **`Sendable` conformance**
  - Service struct marked as `Sendable`
  - All stored properties are `Sendable`
  - No mutable shared state

## Mock Implementation

- [ ] **`actor` for thread safety**
  - Mock implemented as `actor`
  - All mutable state protected by actor isolation
  - Proper async access to mock state

- [ ] **Test helper methods provided**
  - `setMockResult<T>(_ result: T, forMethod method: String)` implemented
  - `simulateError(_ shouldError: Bool = true)` implemented
  - `reset()` implemented for test cleanup

- [ ] **Error simulation capabilities**
  - Can simulate error conditions
  - Error simulation toggle available
  - Custom mock errors defined

- [ ] **Realistic delay simulation**
  - Includes `Task.sleep` for realistic timing
  - Delays are configurable if needed
  - Typical delay: 100ms (100_000_000 nanoseconds)

- [ ] **Clean reset functionality**
  - `reset()` clears all mock state
  - Reset between tests supported
  - No state leakage between tests

- [ ] **Custom mock error types**
  - Mock-specific error enum defined
  - Errors conform to `LocalizedError`
  - Clear error descriptions provided

## Dependency Registration

- [ ] **Private dependency key enum**
  - Dependency key is private enum
  - Implements `DependencyKey` protocol
  - Clear naming convention (`YourServiceKey`)

- [ ] **Live, test, and preview values configured**
  - `liveValue` uses real implementation
  - `testValue` uses mock implementation
  - `previewValue` uses mock implementation

- [ ] **Public extension on `DependencyValues`**
  - Extension is public
  - Computed property with getter and setter
  - Clear property naming (e.g., `yourService`)

- [ ] **Consistent naming conventions**
  - Service name follows project conventions
  - Dependency accessor name is clear
  - File names match service name

## Integration

- [ ] **Service used in at least one feature**
  - Feature imports and uses service
  - Service accessed via `@Dependency`
  - Feature handles service errors

- [ ] **Unit tests written for service**
  - Test suite created for service
  - All methods have test coverage
  - Error cases tested
  - Edge cases tested

- [ ] **Integration tests with features**
  - Feature tests use mock service
  - Mock configured for test scenarios
  - Error handling verified in features

- [ ] **Error handling tested**
  - All error paths tested
  - Error transformation verified
  - Error propagation tested

## Code Quality Checks

- [ ] **No over-abstraction**
  - Service doesn't wrap existing services unnecessarily
  - Direct use of underlying frameworks
  - No speculative interfaces

- [ ] **Single responsibility**
  - Service has one clear purpose
  - No mixing of unrelated concerns
  - Focused on essential functionality

- [ ] **Essential operations only**
  - No speculative methods
  - All methods actively used by features
  - No "might need later" functionality

- [ ] **Simple state management**
  - Minimal state complexity
  - Essential states only
  - No over-engineered state machines

- [ ] **Performance optimized**
  - No unnecessary complexity
  - Efficient implementations
  - Fast initialization

## Documentation Checks

- [ ] **Protocol documentation complete**
  - All public APIs documented
  - Examples provided
  - Design principles stated

- [ ] **Implementation notes added**
  - Complex logic explained
  - Design decisions documented
  - Performance considerations noted

- [ ] **Test documentation provided**
  - Test purpose documented
  - Test scenarios explained
  - Expected behavior described

## Final Verification

- [ ] **Project builds successfully**
  - No compilation errors
  - No warnings
  - All imports resolved

- [ ] **All tests pass**
  - Unit tests pass
  - Integration tests pass
  - No test failures

- [ ] **Code follows project conventions**
  - Formatting matches project style
  - Naming conventions followed
  - File organization correct

- [ ] **No breaking changes**
  - Existing features still work
  - Backward compatibility maintained
  - Migration path provided if needed

- [ ] **Performance verified**
  - No performance regressions
  - Initialization time acceptable
  - Memory usage reasonable

## Camera Service Success Checklist

The CameraService demonstrates these best practices:

- [x] 83% code reduction achieved
- [x] Essential error types only (4 instead of 14)
- [x] Simple state management (3 states instead of 7)
- [x] Direct framework usage (AVFoundation)
- [x] Comprehensive test helpers
- [x] All functionality preserved
- [x] Improved performance
- [x] Enhanced maintainability
