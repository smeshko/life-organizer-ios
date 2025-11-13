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
        let results = try await withDependencies {
            // Force all dependencies to use live values
            $0.actionHandlerRemoteDataSource = DependencyValues.live.actionHandlerRemoteDataSource
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: "spent 120 euros at Next")
        }

        // Assert: Verify array structure
        #expect(results.count == 1)

        // Extract first element for existing assertions
        let result = results[0]

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
        let results = try await withDependencies {
            // Force all dependencies to use live values
            $0.actionHandlerRemoteDataSource = DependencyValues.live.actionHandlerRemoteDataSource
            $0.networkService = MockNetworkService(mockData: mockJSON)
        } operation: {
            try await self.repository.processAction(input: "test input")
        }

        // Assert: Verify array structure
        #expect(results.count == 1)

        // Extract first element for existing assertions
        let result = results[0]

        // Assert
        #expect(result.processingResultType == .backendHandled)
        #expect(result.action == nil)
        #expect(result.message == "Request processed by backend")
    }

    // MARK: - Multi-Transaction Tests

    @Test("Multi-transaction response parsing")
    func multiTransactionResponse() async throws {
        // Arrange: Create mock JSON with 3 transactions
        let multiTransactionJSON = try JSONEncoder().encode(TestData.ProcessingResponseArrays.multipleSuccesses)

        // Act
        let results = try await withDependencies {
            $0.actionHandlerRemoteDataSource = DependencyValues.live.actionHandlerRemoteDataSource
            $0.networkService = MockNetworkService(mockData: multiTransactionJSON)
        } operation: {
            try await self.repository.processAction(input: "test")
        }

        // Assert: Verify array structure
        #expect(results.count == 3)

        // Verify first element (expense)
        #expect(results[0].processingResultType == .appActionRequired)
        guard case .budget(let action1) = results[0].action else {
            Issue.record("Expected budget action in first result")
            return
        }
        #expect(action1.transactionType == .expense)

        // Verify second element (income)
        #expect(results[1].processingResultType == .appActionRequired)
        guard case .budget(let action2) = results[1].action else {
            Issue.record("Expected budget action in second result")
            return
        }
        #expect(action2.transactionType == .income)

        // Verify third element (backend handled)
        #expect(results[2].processingResultType == .backendHandled)
        #expect(results[2].action == nil)
    }

    @Test("Mixed success/failure responses")
    func mixedSuccessFailureResponse() async throws {
        // Arrange: Create mock JSON with mixed results
        let mixedJSON = try JSONEncoder().encode(TestData.ProcessingResponseArrays.mixedSuccessFailure)

        // Act
        let results = try await withDependencies {
            $0.actionHandlerRemoteDataSource = DependencyValues.live.actionHandlerRemoteDataSource
            $0.networkService = MockNetworkService(mockData: mixedJSON)
        } operation: {
            try await self.repository.processAction(input: "test")
        }

        // Assert: Verify array structure
        #expect(results.count == 3)

        // Verify first element - success with app action
        #expect(results[0].processingResultType == .appActionRequired)
        #expect(results[0].action != nil)

        // Verify second element - error
        #expect(results[1].processingResultType == .error)
        #expect(results[1].action == nil)

        // Verify third element - backend handled success
        #expect(results[2].processingResultType == .backendHandled)
        #expect(results[2].action == nil)
    }
}
