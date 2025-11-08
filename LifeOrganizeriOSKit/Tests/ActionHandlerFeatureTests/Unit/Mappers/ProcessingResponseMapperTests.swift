import Testing
import Foundation
import Entities
import Framework
@testable import ActionHandlerFeature

@Suite("ProcessingResponseMapper Tests")
struct ProcessingResponseMapperTests {

    // MARK: - App Action Required Mapping Tests

    @Test("Maps app_action_required response with budget action")
    func mapsAppActionRequiredWithBudgetAction() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 234.6,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Clothes",
            details: "next"
        )
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: "app_action_required",
            appAction: .budget(budgetDTO),
            message: "Logged expenses: 234.6 BGN in Clothes"
        )

        // Act
        let result = try ProcessingResponseMapper.toDomain(dto)

        // Assert
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.message == "Logged expenses: 234.6 BGN in Clothes")

        guard case .budget(let budgetAction) = result.action else {
            Issue.record("Expected budget action, got: \(String(describing: result.action))")
            return
        }

        #expect(budgetAction.amount == Decimal(234.6))
        #expect(budgetAction.transactionType == .expense)
        #expect(budgetAction.category == .clothes)
        #expect(budgetAction.details == "next")
    }

    @Test("Maps app_action_required with income budget action")
    func mapsAppActionRequiredWithIncome() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 5000.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Income",
            category: "Salary",
            details: "January salary"
        )
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: "app_action_required",
            appAction: .budget(budgetDTO),
            message: "Logged income: 5000.0 BGN in Salary"
        )

        // Act
        let result = try ProcessingResponseMapper.toDomain(dto)

        // Assert
        #expect(result.processingResultType == .appActionRequired)
        guard case .budget(let budgetAction) = result.action else {
            Issue.record("Expected budget action")
            return
        }
        #expect(budgetAction.transactionType == .income)
    }

    // MARK: - Backend Handled Mapping Tests

    @Test("Maps backend_handled response without action")
    func mapsBackendHandledWithoutAction() throws {
        // Arrange
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: "backend_handled",
            appAction: nil,
            message: "Request processed successfully on backend"
        )

        // Act
        let result = try ProcessingResponseMapper.toDomain(dto)

        // Assert
        #expect(result.processingResultType == .backendHandled)
        #expect(result.action == nil)
        #expect(result.message == "Request processed successfully on backend")
    }

    @Test("Maps backend_handled with various messages")
    func mapsBackendHandledWithVariousMessages() throws {
        let messages = [
            "Task completed",
            "Data saved successfully",
            "Operation executed on server",
            ""
        ]

        for message in messages {
            let dto = ProcessingResponseDTO(
                success: true,
                actionType: "backend_handled",
                appAction: nil,
                message: message
            )

            let result = try ProcessingResponseMapper.toDomain(dto)

            #expect(result.processingResultType == .backendHandled)
            #expect(result.action == nil)
            #expect(result.message == message)
        }
    }

    // MARK: - Error Response Mapping Tests

    @Test("Maps error response without action")
    func mapsErrorResponse() throws {
        // Arrange
        let dto = ProcessingResponseDTO(
            success: false,
            actionType: "error",
            appAction: nil,
            message: "Failed to process request"
        )

        // Act
        let result = try ProcessingResponseMapper.toDomain(dto)

        // Assert
        #expect(result.processingResultType == .error)
        #expect(result.action == nil)
        #expect(result.message == "Failed to process request")
    }

    @Test("Maps error response with detailed message")
    func mapsErrorWithDetailedMessage() throws {
        // Arrange
        let errorMessage = "Backend service unavailable: Connection timeout after 30s"
        let dto = ProcessingResponseDTO(
            success: false,
            actionType: "error",
            appAction: nil,
            message: errorMessage
        )

        // Act
        let result = try ProcessingResponseMapper.toDomain(dto)

        // Assert
        #expect(result.processingResultType == .error)
        #expect(result.message == errorMessage)
    }

    // MARK: - Error Handling Tests

    @Test("Throws error for unknown action type")
    func throwsErrorForUnknownActionType() throws {
        // Arrange
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: "unknown_type",
            appAction: nil,
            message: "Some message"
        )

        // Act & Assert
        #expect(throws: AppError.self) {
            try ProcessingResponseMapper.toDomain(dto)
        }
    }

    @Test("Throws specific error message for unknown processing result type")
    func throwsSpecificErrorForUnknownType() throws {
        // Arrange
        let unknownType = "future_result_type"
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: unknownType,
            appAction: nil,
            message: "Test message"
        )

        // Act & Assert
        do {
            _ = try ProcessingResponseMapper.toDomain(dto)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .actionHandler(let handlerError) = error,
                  case .unknownProcessingResultType(let message) = handlerError else {
                Issue.record("Expected actionHandler.unknownProcessingResultType error")
                return
            }
            #expect(message.contains("Unknown result type"))
            #expect(message.contains(unknownType))
            #expect(message.contains("app_action_required"))
            #expect(message.contains("backend_handled"))
            #expect(message.contains("error"))
        }
    }

    @Test("Propagates invalid action errors from nested ActionMapper")
    func propagatesInvalidActionErrors() throws {
        // Arrange - Create invalid budget action with bad date
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "invalid-date",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: "app_action_required",
            appAction: .budget(budgetDTO),
            message: "Test"
        )

        // Act & Assert
        do {
            _ = try ProcessingResponseMapper.toDomain(dto)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .actionHandler(let handlerError) = error,
                  case .invalidAction(let message) = handlerError else {
                Issue.record("Expected actionHandler.invalidAction error")
                return
            }
            #expect(message.contains("Invalid date format"))
        }
    }

    @Test("Propagates unknown action type errors from ActionMapper")
    func propagatesUnknownActionTypeErrors() throws {
        // Arrange
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: "app_action_required",
            appAction: .unknown("future_action"),
            message: "Test"
        )

        // Act & Assert
        do {
            _ = try ProcessingResponseMapper.toDomain(dto)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .actionHandler(let handlerError) = error,
                  case .handlerNotFound(let message) = handlerError else {
                Issue.record("Expected actionHandler.handlerNotFound error")
                return
            }
            #expect(message.contains("Unknown action type"))
        }
    }

    // MARK: - Optional Action Tests

    @Test("Maps app_action_required with nil action gracefully")
    func mapsAppActionRequiredWithNilAction() throws {
        // Arrange - This is technically an invalid state, but mapper should handle it
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: "app_action_required",
            appAction: nil,
            message: "Action required but no action provided"
        )

        // Act
        let result = try ProcessingResponseMapper.toDomain(dto)

        // Assert
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.action == nil)
    }

    @Test("Maps backend_handled with unexpected action gracefully")
    func mapsBackendHandledWithUnexpectedAction() throws {
        // Arrange - Backend handled should not have action, but mapper should handle it
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: "backend_handled",
            appAction: .budget(budgetDTO),
            message: "Processed on backend"
        )

        // Act
        let result = try ProcessingResponseMapper.toDomain(dto)

        // Assert - Should map the action even though it's unexpected
        #expect(result.processingResultType == .backendHandled)
        #expect(result.action != nil)
    }

    // MARK: - Integration Tests

    @Test("Maps complete processing response with all valid fields")
    func mapsCompleteProcessingResponse() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 456.78,
            date: "2025-03-20T00:00:00Z",
            transactionType: "Income",
            category: "Bonuses",
            details: "Project payment"
        )
        let dto = ProcessingResponseDTO(
            success: true,
            actionType: "app_action_required",
            appAction: .budget(budgetDTO),
            message: "Logged income: 456.78 BGN in Bonuses"
        )

        // Act
        let result = try ProcessingResponseMapper.toDomain(dto)

        // Assert - Verify all fields are correctly mapped
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.message == "Logged income: 456.78 BGN in Bonuses")

        guard case .budget(let budgetAction) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(budgetAction.amount == Decimal(456.78))
        #expect(budgetAction.transactionType == .income)
        #expect(budgetAction.category == .bonuses)
        #expect(budgetAction.details == "Project payment")

        let expectedDate = ISO8601DateFormatter().date(from: "2025-03-20T00:00:00Z")
        #expect(budgetAction.date == expectedDate)
    }

    @Test("Maps all three processing result types correctly")
    func mapsAllProcessingResultTypes() throws {
        // Test app_action_required
        let appActionDTO = ProcessingResponseDTO(
            success: true,
            actionType: "app_action_required",
            appAction: nil,
            message: "App action"
        )
        let appActionResult = try ProcessingResponseMapper.toDomain(appActionDTO)
        #expect(appActionResult.processingResultType == .appActionRequired)

        // Test backend_handled
        let backendDTO = ProcessingResponseDTO(
            success: true,
            actionType: "backend_handled",
            appAction: nil,
            message: "Backend handled"
        )
        let backendResult = try ProcessingResponseMapper.toDomain(backendDTO)
        #expect(backendResult.processingResultType == .backendHandled)

        // Test error
        let errorDTO = ProcessingResponseDTO(
            success: false,
            actionType: "error",
            appAction: nil,
            message: "Error occurred"
        )
        let errorResult = try ProcessingResponseMapper.toDomain(errorDTO)
        #expect(errorResult.processingResultType == .error)
    }
}
