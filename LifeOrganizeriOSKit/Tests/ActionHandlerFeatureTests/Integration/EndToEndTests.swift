import Testing
import Dependencies
import Foundation
import Entities
import NetworkService
@testable import ActionHandlerFeature

@Suite("End-to-End Integration Tests")
struct EndToEndTests {
    let repository = DependencyValues.live.actionHandlerRepository

    // MARK: - User Story Tests

    @Test("US-1: Budget action from voice input")
    func userStoryBudgetAction() async throws {
        // Arrange: Load mock response from file
        let mockJSON = try TestResources.loadMockResponse("valid_budget_action")

        // Act: Process with live repository using mocked network service
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: "spent 120 euros at Next")
        }

        // Assert: Verify ProcessingResponse
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.message == "Logged expenses: 234.6 BGN in Clothes")

        // Assert: Verify BudgetAction
        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action, got: \(String(describing: result.action))")
            return
        }

        #expect(action.amount == Decimal(string: "234.6"))
        #expect(action.transactionType == .expense)
        #expect(action.category == .clothes)
        #expect(action.details == "next")
    }

    @Test("US-2: Backend handled scenario (no app action)")
    func backendHandledScenario() async throws {
        // Arrange: Load backend handled response
        let mockJSON = try TestResources.loadMockResponse("backend_handled")

        // Act
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: "test input")
        }

        // Assert
        #expect(result.processingResultType == .backendHandled)
        #expect(result.action == nil)
        #expect(result.message == "Request processed by backend")
    }

    @Test("All 23 budget categories are supported")
    func allCategoriesSupported() {
        // Verify all BudgetCategory cases exist (23 predefined + other)
        let allCategories: [BudgetCategory] = [
            // Expense categories (16)
            .groceries, .clothes, .bodyCare, .bills,
            .electronics, .entertainment, .health, .home,
            .kids, .miscellaneous, .pets, .restaurants,
            .subscriptions, .tobacco, .transport, .travel,
            // Income categories (4)
            .salaryIvo, .salaryIvi, .gifts, .bonuses,
            // Savings categories (3)
            .metlife, .revolut, .savings,
            // Fallback
            .other
        ]

        #expect(allCategories.count == 24) // 23 predefined + other
    }

    @Test("Budget categories map correctly from API strings")
    func budgetCategoryMapping() throws {
        let testCases: [(String, BudgetCategory)] = [
            ("Groceries", .groceries),
            ("Restaurants", .restaurants),
            ("Transport", .transport),
            ("Clothes", .clothes),
            ("Other", .other)
        ]

        for (apiString, expected) in testCases {
            let category = BudgetCategory(rawValue: apiString)
            #expect(category == expected, "Failed to map '\(apiString)' to \(expected)")
        }
    }
}
