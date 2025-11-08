import Testing
import Dependencies
import Foundation
import Entities
@testable import ActionHandlerFeature

@Suite("Edge Case Tests")
struct EdgeCaseTests {

    @Test("Missing optional details field is handled")
    func missingDetailsField() async throws {
        // Arrange
        let response = ProcessingResponse(
            processingResultType: .appActionRequired,
            action: .budget(BudgetAction(
                amount: Decimal(100),
                date: Date(),
                transactionType: .expense,
                category: .groceries,
                details: nil  // Optional field
            )),
            message: "Action without details"
        )
        let mockRepo = MockActionHandlerRepository(mockResponse: response)

        // Act
        let result = try await mockRepo.processAction(input: "test")

        // Assert
        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(action.details == nil)
    }

    @Test("Unknown category returns nil from rawValue")
    func unknownCategoryMapping() throws {
        // Act
        let unknownCategory = BudgetCategory(rawValue: "UnknownCategory")

        // Assert - Unknown categories return nil, not .other
        #expect(unknownCategory == nil)
    }

    @Test("Zero amount is accepted")
    func zeroAmountHandling() async throws {
        // Arrange
        let response = ProcessingResponse(
            processingResultType: .appActionRequired,
            action: .budget(BudgetAction(
                amount: Decimal(0),
                date: Date(),
                transactionType: .expense,
                category: .groceries,
                details: nil
            )),
            message: "Zero amount action"
        )
        let mockRepo = MockActionHandlerRepository(mockResponse: response)

        // Act
        let result = try await mockRepo.processAction(input: "test")

        // Assert
        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(action.amount == Decimal(0))
    }

    @Test("Very large amount is handled")
    func veryLargeAmount() async throws {
        // Arrange
        let largeAmount = Decimal(string: "999999999.99")!
        let response = ProcessingResponse(
            processingResultType: .appActionRequired,
            action: .budget(BudgetAction(
                amount: largeAmount,
                date: Date(),
                transactionType: .income,
                category: .other,
                details: nil
            )),
            message: "Large amount action"
        )
        let mockRepo = MockActionHandlerRepository(mockResponse: response)

        // Act
        let result = try await mockRepo.processAction(input: "test")

        // Assert
        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(action.amount == largeAmount)
    }

    @Test("Empty input string is processed")
    func emptyInputString() async throws {
        // Arrange
        let mockRepo = MockActionHandlerRepository()

        // Act
        let result = try await mockRepo.processAction(input: "")

        // Assert - Mock should still return default response
        #expect(result.processingResultType == .appActionRequired)
    }

    @Test("Very long input string is processed")
    func veryLongInputString() async throws {
        // Arrange
        let longInput = String(repeating: "a", count: 10000)
        let mockRepo = MockActionHandlerRepository()

        // Act
        let result = try await mockRepo.processAction(input: longInput)

        // Assert
        #expect(result.processingResultType == .appActionRequired)
    }

    @Test("Special characters in input are handled")
    func specialCharactersInInput() async throws {
        // Arrange
        let specialInput = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
        let mockRepo = MockActionHandlerRepository()

        // Act
        let result = try await mockRepo.processAction(input: specialInput)

        // Assert
        #expect(result.processingResultType == .appActionRequired)
    }

    @Test("Unicode characters in details field")
    func unicodeInDetails() async throws {
        // Arrange
        let response = ProcessingResponse(
            processingResultType: .appActionRequired,
            action: .budget(BudgetAction(
                amount: Decimal(100),
                date: Date(),
                transactionType: .expense,
                category: .groceries,
                details: "Café ☕️ 中文 émoji"
            )),
            message: "Unicode action"
        )
        let mockRepo = MockActionHandlerRepository(mockResponse: response)

        // Act
        let result = try await mockRepo.processAction(input: "test")

        // Assert
        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(action.details == "Café ☕️ 中文 émoji")
    }

    @Test("Transaction types are handled correctly")
    func transactionTypes() {
        // Test all transaction types
        let expense = TransactionType.expense
        let income = TransactionType.income

        #expect(expense.rawValue == "Expenses")
        #expect(income.rawValue == "Income")
    }

    @Test("Processing result types are handled correctly")
    func processingResultTypes() {
        // Test all processing result types
        let appAction = ProcessingResultType.appActionRequired
        let backendHandled = ProcessingResultType.backendHandled

        #expect(appAction.rawValue == "app_action_required")
        #expect(backendHandled.rawValue == "backend_handled")
    }
}
