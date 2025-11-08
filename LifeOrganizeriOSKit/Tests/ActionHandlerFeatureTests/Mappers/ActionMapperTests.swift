import Testing
import Foundation
import Entities
import Framework
@testable import ActionHandlerFeature

@Suite("ActionMapper Tests")
struct ActionMapperTests {

    // MARK: - Valid Budget Action Mapping Tests

    @Test("Maps budget ActionDTO to budget Action domain enum")
    func mapsBudgetActionDTO() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 234.6,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Clothes",
            details: "next"
        )
        let actionDTO = ActionDTO.budget(budgetDTO)

        // Act
        let result = try ActionMapper.toDomain(actionDTO)

        // Assert
        guard case .budget(let budgetAction) = result else {
            Issue.record("Expected .budget action, got: \(result)")
            return
        }

        #expect(budgetAction.amount == Decimal(234.6))
        #expect(budgetAction.transactionType == .expense)
        #expect(budgetAction.category == .clothes)
        #expect(budgetAction.details == "next")
    }

    @Test("Maps budget ActionDTO with income transaction")
    func mapsBudgetActionWithIncome() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 5000.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Income",
            category: "Salary Ivo",
            details: "Monthly salary"
        )
        let actionDTO = ActionDTO.budget(budgetDTO)

        // Act
        let result = try ActionMapper.toDomain(actionDTO)

        // Assert
        guard case .budget(let budgetAction) = result else {
            Issue.record("Expected .budget action, got: \(result)")
            return
        }

        #expect(budgetAction.transactionType == .income)
        #expect(budgetAction.category == .salaryIvo)
    }

    @Test("Maps budget ActionDTO with savings transaction")
    func mapsBudgetActionWithSavings() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 1000.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Savings",
            category: "Savings",
            details: "Emergency fund"
        )
        let actionDTO = ActionDTO.budget(budgetDTO)

        // Act
        let result = try ActionMapper.toDomain(actionDTO)

        // Assert
        guard case .budget(let budgetAction) = result else {
            Issue.record("Expected .budget action, got: \(result)")
            return
        }

        #expect(budgetAction.transactionType == .savings)
        #expect(budgetAction.category == .savings)
    }

    // MARK: - Error Propagation Tests

    @Test("Propagates invalid date error from BudgetActionMapper")
    func propagatesInvalidDateError() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "invalid-date",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )
        let actionDTO = ActionDTO.budget(budgetDTO)

        // Act & Assert
        do {
            _ = try ActionMapper.toDomain(actionDTO)
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

    @Test("Propagates invalid transaction type error from BudgetActionMapper")
    func propagatesInvalidTransactionTypeError() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "InvalidType",
            category: "Food",
            details: nil
        )
        let actionDTO = ActionDTO.budget(budgetDTO)

        // Act & Assert
        do {
            _ = try ActionMapper.toDomain(actionDTO)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .actionHandler(let handlerError) = error,
                  case .invalidAction(let message) = handlerError else {
                Issue.record("Expected actionHandler.invalidAction error")
                return
            }
            #expect(message.contains("Invalid transaction type"))
        }
    }

    @Test("Propagates negative amount error from BudgetActionMapper")
    func propagatesNegativeAmountError() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: -50.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )
        let actionDTO = ActionDTO.budget(budgetDTO)

        // Act & Assert
        do {
            _ = try ActionMapper.toDomain(actionDTO)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .actionHandler(let handlerError) = error,
                  case .invalidAction(let message) = handlerError else {
                Issue.record("Expected actionHandler.invalidAction error")
                return
            }
            #expect(message.contains("Amount must be positive"))
        }
    }

    // MARK: - Unknown Action Type Tests

    @Test("Throws error for unknown action type")
    func throwsErrorForUnknownActionType() throws {
        // Arrange
        let actionDTO = ActionDTO.unknown("future_action_type")

        // Act & Assert
        #expect(throws: AppError.self) {
            try ActionMapper.toDomain(actionDTO)
        }
    }

    @Test("Throws specific error message for unknown action type")
    func throwsSpecificErrorForUnknownActionType() throws {
        // Arrange
        let unknownType = "schedule_reminder"
        let actionDTO = ActionDTO.unknown(unknownType)

        // Act & Assert
        do {
            _ = try ActionMapper.toDomain(actionDTO)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .actionHandler(let handlerError) = error,
                  case .handlerNotFound(let message) = handlerError else {
                Issue.record("Expected actionHandler.handlerNotFound error")
                return
            }
            #expect(message.contains("Unknown action type"))
            #expect(message.contains(unknownType))
        }
    }

    @Test("Throws handlerNotFound error for various unknown types")
    func throwsHandlerNotFoundForVariousUnknownTypes() throws {
        let unknownTypes = ["reminder", "calendar_event", "note", "task"]

        for type in unknownTypes {
            let actionDTO = ActionDTO.unknown(type)

            do {
                _ = try ActionMapper.toDomain(actionDTO)
                Issue.record("Expected error for type: \(type)")
            } catch let error as AppError {
                guard case .actionHandler(let handlerError) = error,
                      case .handlerNotFound = handlerError else {
                    Issue.record("Expected handlerNotFound error for type: \(type)")
                    continue
                }
                // Test passes for this type
            }
        }
    }

    // MARK: - Integration Tests with BudgetActionMapper

    @Test("Correctly delegates to BudgetActionMapper for all fields")
    func delegatesToBudgetActionMapper() throws {
        // Arrange - Create a comprehensive budget DTO
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 456.78,
            date: "2025-03-20T00:00:00Z",
            transactionType: "Income",
            category: "Bonuses",
            details: "Project X payment"
        )
        let actionDTO = ActionDTO.budget(budgetDTO)

        // Act
        let result = try ActionMapper.toDomain(actionDTO)

        // Assert - Verify all fields are correctly mapped
        guard case .budget(let budgetAction) = result else {
            Issue.record("Expected .budget action")
            return
        }

        #expect(budgetAction.amount == Decimal(456.78))
        #expect(budgetAction.transactionType == .income)
        #expect(budgetAction.category == .bonuses)
        #expect(budgetAction.details == "Project X payment")

        let expectedDate = ISO8601DateFormatter().date(from: "2025-03-20T00:00:00Z")
        #expect(budgetAction.date == expectedDate)
    }

    @Test("Maps budget action with unknown category using graceful degradation")
    func mapsUnknownCategoryGracefully() throws {
        // Arrange
        let budgetDTO = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 50.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "UnrecognizedCategory",
            details: nil
        )
        let actionDTO = ActionDTO.budget(budgetDTO)

        // Act
        let result = try ActionMapper.toDomain(actionDTO)

        // Assert
        guard case .budget(let budgetAction) = result else {
            Issue.record("Expected .budget action")
            return
        }

        // BudgetActionMapper should gracefully degrade to .other
        #expect(budgetAction.category == .other)
    }
}
