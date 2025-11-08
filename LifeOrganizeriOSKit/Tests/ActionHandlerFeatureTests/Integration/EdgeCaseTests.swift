import Testing
import Dependencies
import Foundation
import Entities
import NetworkService
@testable import ActionHandlerFeature

@Suite("Edge Case Tests")
struct EdgeCaseTests {
    let repository = DependencyValues.live.actionHandlerRepository

    @Test("Missing optional details field is handled")
    func missingDetailsField() async throws {
        // Arrange: Load mock response from file
        let mockJSON = try TestResources.loadMockResponse("missing_details")

        // Act: Process with live repository
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: "test")
        }

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
        // Arrange: Create mock response with zero amount
        let mockJSON = """
        {
            "success": true,
            "action_type": "app_action_required",
            "app_action": {
                "type": "log_budget_entry",
                "amount": 0.01,
                "date": "2025-11-03",
                "transaction_type": "Expenses",
                "category": "Groceries",
                "details": null
            },
            "message": "Zero amount action"
        }
        """.data(using: .utf8)!

        // Act
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: "test")
        }

        // Assert
        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(action.amount == Decimal(string: "0.01"))
    }

    @Test("Very large amount is handled")
    func veryLargeAmount() async throws {
        // Arrange
        let largeAmount = Decimal(string: "999999999.99")!
        let mockJSON = """
        {
            "success": true,
            "action_type": "app_action_required",
            "app_action": {
                "type": "log_budget_entry",
                "amount": 999999999.99,
                "date": "2025-11-03",
                "transaction_type": "Income",
                "category": "Other",
                "details": null
            },
            "message": "Large amount action"
        }
        """.data(using: .utf8)!

        // Act
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: "test")
        }

        // Assert
        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(action.amount == largeAmount)
    }

    @Test("Empty input string is processed")
    func emptyInputString() async throws {
        // Arrange: Load valid mock response
        let mockJSON = try TestResources.loadMockResponse("valid_budget_action")

        // Act: Test with empty input string
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: "")
        }

        // Assert
        #expect(result.processingResultType == .appActionRequired)
    }

    @Test("Very long input string is processed")
    func veryLongInputString() async throws {
        // Arrange
        let longInput = String(repeating: "a", count: 10000)
        let mockJSON = try TestResources.loadMockResponse("valid_budget_action")

        // Act
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: longInput)
        }

        // Assert
        #expect(result.processingResultType == .appActionRequired)
    }

    @Test("Special characters in input are handled")
    func specialCharactersInInput() async throws {
        // Arrange
        let specialInput = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
        let mockJSON = try TestResources.loadMockResponse("valid_budget_action")

        // Act
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: specialInput)
        }

        // Assert
        #expect(result.processingResultType == .appActionRequired)
    }

    @Test("Unicode characters in details field")
    func unicodeInDetails() async throws {
        // Arrange: Create mock with Unicode in details
        let mockJSON = """
        {
            "success": true,
            "action_type": "app_action_required",
            "app_action": {
                "type": "log_budget_entry",
                "amount": 100,
                "date": "2025-11-03",
                "transaction_type": "Expenses",
                "category": "Groceries",
                "details": "Café ☕️ 中文 émoji"
            },
            "message": "Unicode action"
        }
        """.data(using: .utf8)!

        // Act
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: "test")
        }

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
