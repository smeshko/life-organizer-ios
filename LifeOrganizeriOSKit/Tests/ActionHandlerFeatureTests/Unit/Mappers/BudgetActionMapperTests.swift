import Testing
import Foundation
import Entities
import Framework
@testable import ActionHandlerFeature

@Suite("BudgetActionMapper Tests")
struct BudgetActionMapperTests {

    // MARK: - Valid Mapping Tests

    @Test("Maps valid budget DTO to domain entity")
    func mapsValidBudgetDTO() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 234.6,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Clothes",
            details: "next"
        )

        // Act
        let result = try BudgetActionMapper.toDomain(dto)

        // Assert
        #expect(result.amount == Decimal(234.6))
        #expect(result.transactionType == .expense)
        #expect(result.category == .clothes)
        #expect(result.details == "next")

        // Verify date parsing
        let expectedDate = ISO8601DateFormatter().date(from: "2025-01-15T00:00:00Z")
        #expect(result.date == expectedDate)
    }

    @Test("Maps budget DTO with nil details")
    func mapsWithNilDetails() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Income",
            category: "Salary Ivo",
            details: nil
        )

        // Act
        let result = try BudgetActionMapper.toDomain(dto)

        // Assert
        #expect(result.details == nil)
        #expect(result.transactionType == .income)
        #expect(result.category == .salaryIvo)
    }

    @Test("Maps budget DTO with savings transaction type")
    func mapsSavingsTransactionType() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 500.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Savings",
            category: "Savings",
            details: "Monthly savings"
        )

        // Act
        let result = try BudgetActionMapper.toDomain(dto)

        // Assert
        #expect(result.transactionType == .savings)
        #expect(result.category == .savings)
    }

    @Test("Maps unknown category to .other with graceful degradation")
    func mapsUnknownCategoryToOther() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 50.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "UnknownCategory",
            details: "test"
        )

        // Act
        let result = try BudgetActionMapper.toDomain(dto)

        // Assert
        #expect(result.category == .other)
    }

    @Test("Converts Double to Decimal for financial precision")
    func convertsToDecimalPrecision() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 123.45,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )

        // Act
        let result = try BudgetActionMapper.toDomain(dto)

        // Assert
        #expect(result.amount == Decimal(123.45))
        #expect(result.amount.description == "123.45")
    }

    // MARK: - Error Handling Tests

    @Test("Throws error for invalid date format")
    func throwsErrorForInvalidDateFormat() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "2025/01/15", // Invalid format (should be YYYY-MM-DD)
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )

        // Act & Assert
        #expect(throws: AppError.self) {
            try BudgetActionMapper.toDomain(dto)
        }
    }

    @Test("Throws specific error message for invalid date")
    func throwsSpecificErrorForInvalidDate() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "invalid-date",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )

        // Act & Assert
        do {
            _ = try BudgetActionMapper.toDomain(dto)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .actionHandler(let handlerError) = error,
                  case .invalidAction(let message) = handlerError else {
                Issue.record("Expected actionHandler.invalidAction error")
                return
            }
            #expect(message.contains("Invalid date format"))
            #expect(message.contains("invalid-date"))
            #expect(message.contains("ISO 8601"))
        }
    }

    @Test("Throws error for invalid transaction type")
    func throwsErrorForInvalidTransactionType() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "InvalidType",
            category: "Food",
            details: nil
        )

        // Act & Assert
        #expect(throws: AppError.self) {
            try BudgetActionMapper.toDomain(dto)
        }
    }

    @Test("Throws specific error message for invalid transaction type")
    func throwsSpecificErrorForInvalidTransactionType() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Purchase",
            category: "Food",
            details: nil
        )

        // Act & Assert
        do {
            _ = try BudgetActionMapper.toDomain(dto)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .actionHandler(let handlerError) = error,
                  case .invalidAction(let message) = handlerError else {
                Issue.record("Expected actionHandler.invalidAction error")
                return
            }
            #expect(message.contains("Invalid transaction type"))
            #expect(message.contains("Purchase"))
            #expect(message.contains("Expenses"))
            #expect(message.contains("Income"))
            #expect(message.contains("Savings"))
        }
    }

    @Test("Throws error for zero amount")
    func throwsErrorForZeroAmount() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 0.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )

        // Act & Assert
        #expect(throws: AppError.self) {
            try BudgetActionMapper.toDomain(dto)
        }
    }

    @Test("Throws error for negative amount")
    func throwsErrorForNegativeAmount() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: -50.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )

        // Act & Assert
        do {
            _ = try BudgetActionMapper.toDomain(dto)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .actionHandler(let handlerError) = error,
                  case .invalidAction(let message) = handlerError else {
                Issue.record("Expected actionHandler.invalidAction error")
                return
            }
            #expect(message.contains("Amount must be positive"))
            #expect(message.contains("-50.0"))
        }
    }

    // MARK: - Edge Case Tests

    @Test("Maps very large amounts correctly")
    func mapsLargeAmounts() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 999999.99,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Other",
            details: nil
        )

        // Act
        let result = try BudgetActionMapper.toDomain(dto)

        // Assert
        #expect(result.amount == Decimal(999999.99))
    }

    @Test("Maps fractional amounts with precision")
    func mapsFractionalAmounts() throws {
        // Arrange
        let dto = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 0.01,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Other",
            details: nil
        )

        // Act
        let result = try BudgetActionMapper.toDomain(dto)

        // Assert
        #expect(result.amount == Decimal(0.01))
    }

    @Test("Maps all valid expense categories")
    func mapsAllExpenseCategories() throws {
        let categories = ["Groceries", "Clothes", "Body care", "Bills", "Electronics", "Entertainment",
                         "Health", "Home", "Kids", "Miscellaneous", "Pets", "Restaurants",
                         "Subscriptions", "Tobacco", "Transport", "Travel"]

        for category in categories {
            let dto = BudgetActionDTO(
                type: "log_budget_entry",
                amount: 100.0,
                date: "2025-01-15T00:00:00Z",
                transactionType: "Expenses",
                category: category,
                details: nil
            )

            let result = try BudgetActionMapper.toDomain(dto)
            #expect(result.category.rawValue == category)
        }
    }

    @Test("Maps all valid income categories")
    func mapsAllIncomeCategories() throws {
        let categories = ["Salary Ivo", "Salary Ivi", "Gifts", "Bonuses"]

        for category in categories {
            let dto = BudgetActionDTO(
                type: "log_budget_entry",
                amount: 100.0,
                date: "2025-01-15T00:00:00Z",
                transactionType: "Income",
                category: category,
                details: nil
            )

            let result = try BudgetActionMapper.toDomain(dto)
            #expect(result.category.rawValue == category)
        }
    }
}
