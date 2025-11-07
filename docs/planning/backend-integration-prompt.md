# Backend Integration: Structured Implementation Prompt

**Created**: 2025-11-05
**Purpose**: Structured prompt for generating implementation plan for backend action processing integration

---

## Problem Statement

Integrate the iOS app with the backend API to enable natural language processing of user input (text/voice) into actionable items. The backend classifies user input and returns structured action data that the app must handle appropriately based on action type.

### Example Flow
```
User Input: "120eur at next"
    ↓
Backend POST /api/v1/process
    ↓
Response: {
  "success": true,
  "action_type": "app_action_required",
  "message": "Logged expenses: 234.6 BGN in Clothes",
  "app_action": {
    "type": "log_budget_entry",
    "amount": 234.6,
    "date": "2025-11-03",
    "transaction_type": "Expenses",
    "category": "Clothes",
    "details": "next"
  }
}
    ↓
iOS: BudgetHandler processes the app_action
    ↓
UI: Feature state updated to reflect new budget entry
```

---

## Backend API Contract

### Endpoint
```
POST /api/v1/process
Content-Type: application/json
```

### Request Schema
```json
{
  "input": "string (user's natural language input)"
}
```

### Response Schema (ActionResult)
```json
{
  "success": boolean,
  "action_type": "app_action_required" | "backend_handled" | "error",
  "message": "string (human-readable confirmation)",
  "app_action": {
    "type": "log_budget_entry" | "create_calendar_event" | "create_reminder" | ...,
    // ... type-specific properties
  }
}
```

### Action Types & Properties

**Budget Actions** (`log_budget_entry`):
- `amount`: number
- `date`: ISO 8601 date string
- `transaction_type`: "Expenses" | "Income" | "Savings"
- `category`: string
- `details`: string (optional)

**Calendar Actions** (`create_calendar_event`):
- TBD - define properties

**Reminder Actions** (`create_reminder`):
- TBD - define properties

**Task Actions** (`create_task`):
- TBD - define properties

---

## Architectural Constraints

### Existing Architecture Patterns

1. **Service Architecture Pattern**
   - Location: `Sources/Services/{ServiceName}/`
   - Structure: `Interface/`, `Live/`, `Mock/`, `{ServiceName}Dependency.swift`
   - Purpose: Infrastructure concerns (networking, persistence, device features)
   - Registration: TCA dependency system
   - **Do NOT create new services for action handling**

2. **Repository Pattern**
   - Location: `Sources/Features/{Feature}Feature/Data/Repositories/`
   - Purpose: Feature-specific business logic + data access
   - Pattern: Uses services internally, provides domain operations
   - **Action handling should use this pattern**

3. **Feature-Scoped Architecture**
   - Self-contained feature modules
   - Structure:
     ```
     {Feature}Feature/
     ├── Data/
     │   ├── DTOs/           # API request/response types
     │   ├── DataSources/    # Remote/local data sources
     │   └── Repositories/   # Business logic + data access
     ├── Domain/
     │   ├── Errors/         # Feature-specific errors
     │   └── Protocols/      # Repository/DataSource protocols
     ├── Infrastructure/
     │   ├── Endpoints.swift # API endpoints
     │   └── Mappers/        # DTO ↔ Entity mapping
     └── Presentation/
         └── {Feature}Feature.swift  # TCA reducer
     ```

4. **Entity-First Design**
   - Domain entities in `Sources/Entities/`
   - Entities are global, shared across features
   - DTOs stay in feature scope
   - Mappers transform DTO ↔ Entity

5. **Error Handling**
   - All errors → `AppError` enum in `Sources/Framework/AppError.swift`
   - Feature-specific errors in feature's `Domain/Errors/`
   - Transform external errors at boundaries

6. **TCA Dependency Injection**
   ```swift
   @Dependency(\.networkService) var networkService
   @Dependency(\.actionHandlerRepository) var repository
   ```

### Existing Services

**NetworkService** (use this, don't create a new one):
- Location: `Sources/Services/NetworkService/`
- Protocol methods:
  ```swift
  func sendRequest<T: Decodable>(to endpoint: any Endpoint) async throws -> T
  func sendAndForget(to endpoint: any Endpoint) async throws
  func fetchData(at endpoint: any Endpoint) async throws -> Data
  ```
- Endpoint protocol location: `Sources/Framework/Endpoint.swift`
- All network errors transformed to `AppError.network(NetworkError)`

---

## Requirements

### 1. Domain Entities (Global)

Create in `Sources/Entities/`:

**Base Action Model**:
- Minimal base class/protocol with common properties
- `type: String` - discriminator for deserialization
- Consider using protocol + enum or sealed class pattern

**Action Subtypes** (polymorphic based on `type`):
- `BudgetAction` - budget-specific properties
- `CalendarAction` - calendar-specific properties (future)
- `ReminderAction` - reminder-specific properties (future)
- `TaskAction` - task-specific properties (future)

**ActionResult Model**:
- `success: Bool`
- `actionType: ActionType` enum
- `message: String`
- `appAction: Action?` - polymorphic action

**Deserialization Strategy**:
- Use `type` field to determine concrete action subtype
- Custom `Decodable` implementation or JSON decoder with type discrimination
- Handle unknown action types gracefully

### 2. Feature: ActionHandlerFeature

Create feature in `Sources/Features/ActionHandlerFeature/` following feature-scoped architecture.

**Feature Responsibilities**:
- Accept user input (text or transcribed speech)
- Call repository to classify and process input
- Handle repository responses (success/error)
- Update UI state to reflect processing status
- Delegate action execution to appropriate handlers
- Display user feedback messages

**TCA State**:
- Input text
- Processing status
- Action result
- Error state
- Alert state for user feedback

**TCA Actions**:
- Input changed
- Submit for processing
- Response received (success/error)
- Action executed (from handler)
- Alert presentation

### 3. Data Layer Components

**DTOs** (`Data/DTOs/`):
- `ClassifyRequestDTO` - matches backend request schema
- `ActionResultDTO` - matches backend response schema
- `AppActionDTO` - base DTO for app_action
- `BudgetActionDTO`, `CalendarActionDTO`, etc. - specific DTOs

**Mappers** (`Infrastructure/`):
- `ActionResultMapper` - DTO → Domain entity transformation
- Handle deserialization of polymorphic actions
- Transform error cases appropriately

**Endpoints** (`Infrastructure/Endpoints.swift`):
- Enum conforming to `Endpoint` protocol
- Case: `process(input: String)`
- Method: POST
- Path: `/api/v1/process`
- Body: JSON with `input` field

**Remote Data Source** (`Data/DataSources/`):
- Protocol: `ActionHandlerRemoteDataSourceProtocol`
- Implementation: Uses `@Dependency(\.networkService)`
- Method: `classify(input: String) async throws -> ActionResultDTO`
- Transforms network errors to feature errors

**Repository** (`Data/Repositories/`):
- Protocol: `ActionHandlerRepositoryProtocol`
- Implementation: Uses remote data source
- Method: `processInput(_ input: String) async throws -> ActionResult`
- Maps DTOs to domain entities
- Handles business logic if needed

### 4. Action Handler System

**Design Decision**: Handlers should be **separate, focused classes** (not services, not repositories)

**Rationale**:
- Each handler has single responsibility (one action type)
- Not infrastructure (so not a service)
- Not data access (so not a repository)
- Pure business logic for executing actions
- Can be simple classes/actors without dependency registration

**Handler Architecture**:

**Base Handler Protocol**:
```swift
protocol ActionHandler: Sendable {
    associatedtype ActionType: Action
    func handle(_ action: ActionType) async throws -> ActionHandlerResult
}
```

**Concrete Handlers** (in `ActionHandlerFeature/Domain/Handlers/`):
- `BudgetActionHandler` - handles `BudgetAction`
- `CalendarActionHandler` - handles `CalendarAction` (future)
- `ReminderActionHandler` - handles `ReminderAction` (future)
- `TaskActionHandler` - handles `TaskAction` (future)

**Handler Coordinator/Router**:
- Central component that routes actions to appropriate handlers
- Pattern: switch on action type → call specific handler
- Location: `ActionHandlerFeature/Domain/ActionHandlerCoordinator.swift`
- Used by TCA feature to execute actions

**Handler Responsibilities**:
- Validate action data
- Execute action (update local state, persist data, etc.)
- Return success/failure result
- May use other services (e.g., persistence service for budget)
- **For now**: Budget handler can just return success, actual persistence comes later

**Integration with Feature**:
```swift
@Reducer
struct ActionHandlerFeature {
    @Dependency(\.actionHandlerRepository) var repository

    let coordinator = ActionHandlerCoordinator()  // or inject as dependency

    case .processResponse(let result):
        if let action = result.appAction {
            return .run { send in
                let handlerResult = try await coordinator.handle(action)
                await send(.actionExecuted(handlerResult))
            }
        }
}
```

### 5. Error Handling

**AppError Extension** (`Sources/Framework/AppError.swift`):
```swift
case actionHandler(ActionHandlerError)
```

**Feature Errors** (`Domain/Errors/ActionHandlerError.swift`):
- `classificationFailed(String)`
- `executionFailed(String)`
- `invalidActionType(String)`
- `backendUnavailable`
- `invalidResponse`
- Conform to `LocalizedError` for user-friendly messages

**Error Transformation**:
- Network errors → `ActionHandlerError.backendUnavailable`
- Decoding errors → `ActionHandlerError.invalidResponse`
- Handler failures → `ActionHandlerError.executionFailed(reason)`

### 6. Testing Requirements

**Mock Repository** (`Infrastructure/Mocks/`):
```swift
public actor MockActionHandlerRepository: ActionHandlerRepositoryProtocol {
    public var shouldFail: Bool = false
    public var mockResult: ActionResult?
    public var recordedInputs: [String] = []

    public func processInput(_ input: String) async throws -> ActionResult {
        recordedInputs.append(input)
        if shouldFail { throw ActionHandlerError.classificationFailed("Mock failure") }
        return mockResult ?? ActionResult(...)
    }
}
```

**Test Coverage**:
- Repository tests: successful classification, error handling, DTO mapping
- Handler tests: each handler with valid/invalid inputs
- Coordinator tests: routing to correct handlers
- Feature tests: TCA reducer logic with mock repository
- Integration tests: end-to-end flow with mock network responses

### 7. Configuration

**Backend URL Configuration**:
- Should be configurable (dev/staging/production)
- Consider using `Sources/Framework/Config.swift` or similar
- Endpoints should use base URL from config
- **For initial implementation**: Can hardcode dev URL, extract to config later

---

## Success Criteria

### Phase 1: Core Infrastructure
- [ ] Domain entities created (Action, ActionResult, subtypes)
- [ ] ActionHandlerFeature scaffolded with TCA structure
- [ ] DTOs defined for request/response
- [ ] Endpoints created for /api/v1/process
- [ ] Repository + data source implemented
- [ ] Basic error handling in place
- [ ] Mock repository for testing

### Phase 2: Action Handler System
- [ ] Handler protocol defined
- [ ] BudgetActionHandler implemented (stub, returns success)
- [ ] ActionHandlerCoordinator implemented
- [ ] Coordinator routes budget actions correctly
- [ ] Error handling for unknown action types

### Phase 3: Feature Integration
- [ ] TCA reducer handles input submission
- [ ] Network calls through repository
- [ ] Response handling and state updates
- [ ] Action execution through coordinator
- [ ] User feedback (alerts/messages)
- [ ] Loading states during processing

### Phase 4: Testing
- [ ] Unit tests for handlers
- [ ] Unit tests for coordinator
- [ ] Unit tests for repository
- [ ] TCA feature tests with mock repository
- [ ] Error case coverage

### Phase 5: Polish
- [ ] User-friendly error messages
- [ ] Loading indicators
- [ ] Success confirmations
- [ ] Input validation
- [ ] Documentation

---

## Future Considerations

### Extensibility
- Adding new action types should be straightforward:
  1. Create new domain entity (e.g., `ReminderAction`)
  2. Create corresponding DTO
  3. Update mapper to handle new type
  4. Create new handler (e.g., `ReminderActionHandler`)
  5. Add case to coordinator routing

### Additional Features
- Action history/logging
- Offline support with queued actions
- Action retry mechanism
- Analytics for action types
- User preferences for action handling

### Integration Points
- Speech recognition input (existing SpeechRecognitionService)
- Budget feature integration (when budget feature exists)
- Calendar integration (when calendar feature exists)
- Reminders integration (when reminders feature exists)

---

## Dependencies & Prerequisites

### Required Services
- NetworkService (exists) ✓
- Configuration system (may need to create)

### Future Service Needs
- Budget persistence service (for BudgetActionHandler)
- Calendar service (for CalendarActionHandler)
- Reminder service (for ReminderActionHandler)

### External Dependencies
- Backend API at `/api/v1/process` must be running
- Backend must return JSON matching documented schema

---

## Implementation Notes

### Polymorphic Action Deserialization

**Challenge**: The `app_action` field in the response has different properties based on `type`.

**Solutions**:

**Option A: Enum with associated values**
```swift
public enum Action: Codable {
    case budget(BudgetAction)
    case calendar(CalendarAction)
    case reminder(ReminderAction)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "log_budget_entry":
            self = try .budget(BudgetAction(from: decoder))
        case "create_calendar_event":
            self = try .calendar(CalendarAction(from: decoder))
        // ... etc
        default:
            throw DecodingError.dataCorrupted(...)
        }
    }
}
```

**Option B: Protocol + factory**
```swift
public protocol Action: Codable {
    var type: String { get }
}

public struct BudgetAction: Action {
    public let type: String = "log_budget_entry"
    public let amount: Double
    // ... etc
}

// Factory in mapper
func decodeAction(from data: Data) throws -> Action {
    // Peek at type field, then decode to specific type
}
```

**Recommendation**: Option A for type safety and exhaustiveness checking.

### Handler Registration

**Pattern**: Coordinator maintains dictionary of handlers
```swift
actor ActionHandlerCoordinator {
    private let handlers: [String: any ActionHandlerProtocol] = [
        "log_budget_entry": BudgetActionHandler(),
        "create_calendar_event": CalendarActionHandler(),
        // ... etc
    ]

    func handle(_ action: Action) async throws -> ActionHandlerResult {
        guard let handler = handlers[action.type] else {
            throw ActionHandlerError.invalidActionType(action.type)
        }
        return try await handler.handle(action)
    }
}
```

### Repository vs Service Decision

**Chosen**: Repository pattern within feature scope

**Why**:
- Services are for infrastructure (network, persistence, device APIs)
- Repositories are for business logic + data orchestration
- Action handling is feature-specific, not infrastructure
- Repositories compose services (NetworkService) with business logic
- Follows existing patterns in the codebase

**Handler Decision**: Simple classes/actors, not services

**Why**:
- Single responsibility: one action type per handler
- No need for Interface/Live/Mock pattern (can just mock the handlers directly)
- No need for TCA dependency registration (coordinator holds them)
- Keeps things simple and focused

---

## Open Questions to Resolve

1. **Base URL Configuration**: Where should backend base URL be configured?
   - Environment variables?
   - Config file?
   - Build configuration?

2. **Error Recovery**: Should failed actions be retryable?
   - Store failed actions?
   - Automatic retry logic?
   - User-initiated retry?

3. **Action Validation**: Should validation happen client-side before sending?
   - Pre-flight validation?
   - Or rely on backend validation?

4. **Response Caching**: Should action results be cached?
   - For offline support?
   - For history/audit trail?

5. **Handler Dependencies**: When handlers need services (e.g., BudgetHandler needs persistence):
   - Inject services via initializer?
   - Use TCA dependencies in handlers?
   - Pass services through coordinator?

---

## Example Usage Flow

```swift
// User types or speaks: "120eur at next"
// 1. Feature receives input
state.input = "120eur at next"

// 2. User submits
case .submit:
    state.isProcessing = true
    return .run { [input = state.input] send in
        await send(.processResponse(
            await TaskResult {
                try await repository.processInput(input)
            }
        ))
    }

// 3. Repository calls backend via NetworkService
let dto: ActionResultDTO = try await networkService.sendRequest(
    to: ActionHandlerEndpoint.process(input: input)
)

// 4. Mapper transforms DTO to domain entity
let result = mapper.toDomain(dto)  // ActionResult with BudgetAction

// 5. Feature receives response
case .processResponse(.success(let result)):
    state.isProcessing = false
    state.message = result.message

    if let action = result.appAction {
        return .run { send in
            let handlerResult = try await coordinator.handle(action)
            await send(.actionExecuted(handlerResult))
        }
    }

// 6. Coordinator routes to BudgetActionHandler
func handle(_ action: Action) async throws -> ActionHandlerResult {
    switch action {
    case .budget(let budgetAction):
        return try await budgetHandler.handle(budgetAction)
    // ...
    }
}

// 7. BudgetActionHandler processes the action
func handle(_ action: BudgetAction) async throws -> ActionHandlerResult {
    // Validate action data
    // Persist to budget system (future)
    // Return success
    return ActionHandlerResult(success: true)
}

// 8. Feature updates UI with final result
case .actionExecuted(.success(let result)):
    state.alert = AlertState {
        TextState("Success!")
    } message: {
        TextState(state.message)
    }
```

---

## Deliverables Checklist

Use this checklist when generating the implementation plan:

### Code Artifacts
- [ ] `Sources/Entities/Action.swift` - domain entities
- [ ] `Sources/Entities/ActionResult.swift`
- [ ] `Sources/Features/ActionHandlerFeature/` - complete feature structure
- [ ] Feature DTOs, endpoints, mappers, repository
- [ ] Domain handlers and coordinator
- [ ] Feature errors
- [ ] Mock repository
- [ ] Unit tests for all components

### Documentation
- [ ] API integration documentation
- [ ] Handler extension guide (how to add new action types)
- [ ] Architecture decision record for repository vs service choice
- [ ] Error handling guide

### Testing
- [ ] Unit tests for repository
- [ ] Unit tests for each handler
- [ ] Unit tests for coordinator
- [ ] TCA feature tests
- [ ] Integration test with mock backend

### Configuration
- [ ] Backend URL configuration
- [ ] Error message localization (if needed)

---

**End of Structured Prompt**

---

## How to Use This Prompt

1. **Review and refine**: Adjust any requirements or architectural decisions
2. **Resolve open questions**: Answer the questions in "Open Questions to Resolve"
3. **Generate implementation plan**: Use this prompt to create detailed phases and tasks
4. **Follow your workflow**: Break into phases, create feature branches, iterate with PRs

This prompt should serve as the single source of truth for the backend integration implementation.
