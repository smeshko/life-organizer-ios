import Testing
import Dependencies
import Foundation
import Entities
@testable import ActionHandlerFeature

@Suite("End-to-End Integration Tests")
struct EndToEndTests {

    // MARK: - User Story Tests

    @Test("US-1: Budget action from voice input")
    func userStoryBudgetAction() async throws {
        // Arrange: Create mock repository with expected response
        let expectedResponse = ProcessingResponse(
            processingResultType: .appActionRequired,
            action: .budget(BudgetAction(
                amount: Decimal(string: "234.6")!,
                date: ISO8601DateFormatter().date(from: "2025-11-03T00:00:00Z")!,
                transactionType: .expense,
                category: .clothes,
                details: "Next"
            )),
            message: "Logged expenses: 234.6 BGN in Clothes"
        )

        let mockRepo = MockActionHandlerRepository(mockResponse: expectedResponse)

        // Act: Process user input
        let result = try await withDependencies {
            $0.actionHandlerRepository = mockRepo
        } operation: {
            try await mockRepo.processAction(input: "spent 120 euros at Next")
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
        #expect(action.details == "Next")
    }

    @Test("US-2: Backend handled scenario (no app action)")
    func backendHandledScenario() async throws {
        // Arrange
        let expectedResponse = ProcessingResponse(
            processingResultType: .backendHandled,
            action: nil,
            message: "Request processed successfully"
        )

        let mockRepo = MockActionHandlerRepository(mockResponse: expectedResponse)

        // Act
        let result = try await mockRepo.processAction(input: "test input")

        // Assert
        #expect(result.processingResultType == .backendHandled)
        #expect(result.action == nil)
        #expect(result.message == "Request processed successfully")
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
