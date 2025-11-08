---
type: feature
status: draft
priority: P1
created: 2025-11-07
slug: backend-api-implementation
feature_branch: feature/backend-api-implementation
---

# Backend API Integration - Process Endpoint Implementation

## Overview

**Context**: The iOS app needs to communicate with the Life Organizer backend API to process natural language input (voice transcriptions or text) and receive structured actions to execute.

**Objective**: Implement complete integration with the `/api/v1/process` endpoint, including request/response models, data transformation, error handling, and action routing infrastructure.

**Impact**: Enables the core voice-first functionality of the app by connecting user input to backend processing and translating API responses into actionable items (budget entries, reminders, calendar events, shopping lists).

## User Stories

### Primary Stories (P1)

**US-1**: As a user, I want to speak or type budget expenses so that they are automatically categorized and logged to my budget tracking sheet.

**Acceptance Scenario**:
- **Given** I say "spent 120 euros at Next"
- **When** the app sends this to the backend API
- **Then** I receive a structured budget action with amount (234.6 BGN), date, transaction type (Expenses), category (Clothes), and details (next)

**US-2**: As a user, I want to see a human-readable confirmation message so that I know my input was processed correctly.

**Acceptance Scenario**:
- **Given** the backend successfully processes my input
- **When** the API returns a response
- **Then** I see a message like "Logged expenses: 234.6 BGN in Clothes"

### Secondary Stories (P2)

**US-3**: As a user, I want clear error messages when processing fails so that I understand what went wrong and can try again.

**Acceptance Scenario**:
- **Given** I provide invalid input or the backend encounters an error
- **When** the API returns an error response
- **Then** I see a user-friendly error message explaining the issue

## Requirements

1. **REQ-001**: System must send POST requests to `/api/v1/process` with JSON body containing user input
   - Rationale: Backend expects structured requests with an "input" field

2. **REQ-002**: System must correctly decode ProcessingResponse with action_type, success, message, and optional app_action fields
   - Rationale: Backend returns discriminated union responses that must be parsed correctly

3. **REQ-003**: System must support two action types: backend_handled and app_action_required
   - Rationale: Backend may either handle actions itself or delegate to the iOS app

4. **REQ-004**: System must decode LogBudgetEntryAction with type discriminator, amount, date (ISO 8601 string), transaction_type, category, and optional details
   - Rationale: Budget actions are the primary app action type in Phase 1

5. **REQ-005**: System must transform API TransactionType values (Expenses/Income/Savings) to internal enum cases
   - Rationale: API uses capitalized strings; app uses Swift enums with different casing

6. **REQ-006**: System must validate BudgetCategory values match one of 23 predefined categories (16 expense, 4 income, 3 savings), mapping unknown categories to "Other"
   - Rationale: Backend enforces strict category validation; app must match and handle graceful degradation for future category additions

7. **REQ-007**: System must parse ISO 8601 date strings (YYYY-MM-DD format) to Date objects
   - Rationale: API returns dates as strings; app needs Date objects for processing

8. **REQ-008**: System must convert amount values from BGN (Bulgarian Lev) to Decimal type
   - Rationale: Decimal provides exact decimal arithmetic for financial values without floating-point rounding errors

9. **REQ-009**: System must handle nullable details field for budget actions
   - Rationale: Merchant/description information is optional

10. **REQ-010**: System must map DTO layer to domain entity layer with clear separation of concerns
    - Rationale: DTOs match API contract; entities represent business domain

11. **REQ-011**: System must handle API errors (422, 500, 501) with appropriate error types
    - Rationale: Backend returns specific HTTP status codes for different failure scenarios

12. **REQ-012**: System must support future action types (shopping, reminder, calendar) through extensible architecture
    - Rationale: Phase 1 focuses on budget; Phase 2 will add more action types

## Acceptance Criteria

### Functional Acceptance

- [ ] **Given** user input "spent 120eur at next", **When** sent to `/api/v1/process`, **Then** receives ProcessingResponse with app_action_required and LogBudgetEntryAction
- [ ] **Given** successful API response, **When** action_type is "backend_handled", **Then** displays message and no app action is present
- [ ] **Given** successful API response, **When** action_type is "app_action_required", **Then** app_action field contains valid action data
- [ ] **Given** LogBudgetEntryAction received, **When** parsed, **Then** all required fields (type, amount, date, transaction_type, category) are present
- [ ] **Given** date string "2025-11-03", **When** parsed, **Then** converts to valid Date object
- [ ] **Given** transaction_type "Expenses", **When** mapped, **Then** converts to TransactionType.expense enum case
- [ ] **Given** category "Clothes", **When** validated, **Then** confirms it matches one of 16 expense categories
- [ ] **Given** category "Salary Ivo", **When** validated, **Then** confirms it matches one of 4 income categories
- [ ] **Given** category "Metlife", **When** validated, **Then** confirms it matches one of 3 savings categories

### Edge Cases

- [ ] Handles missing app_action field when action_type is "backend_handled"
- [ ] Handles unknown action_type values with appropriate error
- [ ] Handles unknown budget category with validation error
- [ ] Handles invalid date format with parsing error
- [ ] Handles negative or zero amount values with validation error
- [ ] Handles network failures with appropriate error messages
- [ ] Handles malformed JSON responses with decoding errors
- [ ] Handles empty or whitespace-only input with validation error (422)
- [ ] Handles unsupported category responses (501) gracefully
- [ ] Handles server errors (500) with user-friendly messages

## Affected Areas

**Components**:
- ActionHandlerFeature - New feature module for backend integration
- Entities - Domain models shared across app
- NetworkService - Existing service for HTTP communication
- Framework - Error handling and configuration

**Files** (New):
- `ProcessActionRequestDTO.swift` - Request model with input field
- `ProcessingResponseDTO.swift` - Response wrapper with action_type, success, message, app_action
- `ActionDTO.swift` - Discriminated union for different action types
- `LogBudgetEntryActionDTO.swift` - Budget action DTO with amount, date string, transaction_type, category, details
- `ProcessingResponse.swift` - Domain entity for API response
- `Action.swift` - Domain entity enum for different action types
- `BudgetAction.swift` - Domain entity for budget actions
- `TransactionType.swift` - Enum for Expenses/Income/Savings
- `BudgetCategory.swift` - Enum with 23 predefined categories
- `ProcessingResultType.swift` - Enum for app_action_required/backend_handled/error
- `ActionHandlerResult.swift` - Result wrapper for action execution
- `ProcessingResponseMapper.swift` - Maps ProcessingResponseDTO to ProcessingResponse entity
- `ActionMapper.swift` - Routes action DTOs to appropriate mappers
- `BudgetActionMapper.swift` - Maps LogBudgetEntryActionDTO to BudgetAction entity
- `ActionHandlerRepository.swift` - Coordinates API calls and data transformation
- `ActionHandlerEndpoints.swift` - Endpoint configuration for /api/v1/process

**Files** (Updated):
- `AppError.swift` - Add actionHandler error case with ActionHandlerError enum

**Related Systems**:
- XLSXAppendService - Will consume budget actions to write to Excel (Phase 2)
- SpeechToTextService - Provides voice input that feeds into this system

## Assumptions

- Backend API is accessible at configured base URL (http://localhost:8000 for development)
- NetworkService is already implemented and supports POST requests with JSON bodies
- EUR to BGN conversion is handled by backend; app only receives BGN amounts
- Date validation (not in future) is handled by backend; app trusts received dates
- Category validation is enforced by backend; app validates against known enum cases
- Authentication is not required in Phase 1 (added in future version)
- Action execution (writing to Excel, creating reminders) is out of scope for this implementation
- BudgetCategory enum uses exact string values from OpenAPI spec (e.g., "Body care", "Salary Ivo", not camelCase)
- Unknown budget categories from backend are mapped to "Other" for graceful degradation
- Amount values use Decimal type for financial precision and proper currency formatting

## Resolved Questions

- [x] **Should the app cache budget categories or always rely on enum definition?**
  - **Decision**: Always rely on enum definition. Budget categories are stable and defined in code.

- [x] **What should happen if backend returns a category not in the app's enum?**
  - **Decision**: Map unknown categories to "Other" category. This provides graceful degradation if backend adds new categories before app is updated.

- [x] **Should amount precision be Double or Decimal for financial accuracy?**
  - **Decision**: Use Decimal type for proper currency formatting and financial precision. Decimal provides exact decimal arithmetic without floating-point rounding errors.

---

**Next Steps**: Review requirements, clarify open questions, then proceed to implementation planning with detailed file-by-file breakdown.
