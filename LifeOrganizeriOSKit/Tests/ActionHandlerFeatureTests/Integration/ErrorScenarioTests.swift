import Testing
import Dependencies
import Foundation
import Framework
import Entities
import NetworkService
@testable import ActionHandlerFeature

@Suite("Error Scenario Tests")
struct ErrorScenarioTests {

    @Test("Network error propagates correctly")
    func networkErrorHandling() async throws {
        // Arrange: Create mock network service that throws an error
        let expectedError = AppError.network(.invalidResponse)
        let mockNetworkService = MockNetworkService(mockResponseProvider: { _ in
            throw expectedError
        })

        // Act & Assert: Verify error propagates through the full stack
        await #expect(throws: (any Error).self) {
            try await withDependencies {
                $0.networkService = mockNetworkService
            } operation: {
                @Dependency(\.actionHandlerRepository) var repository
                try await repository.processAction(input: "test")
            }
        }
    }

    @Test("Invalid JSON response throws decoding error")
    func invalidJSONResponse() async throws {
        // Arrange: Return invalid JSON
        let invalidJSON = "{ invalid json }".data(using: .utf8)!

        // Act & Assert
        await #expect(throws: (any Error).self) {
            try await withDependencies {
                $0.networkService = MockNetworkService(mockData: invalidJSON)
            } operation: {
                @Dependency(\.actionHandlerRepository) var repository
                try await repository.processAction(input: "test")
            }
        }
    }

    @Test("Valid response is successfully processed through full stack")
    func successfulEndToEndProcessing() async throws {
        // Arrange
        let validJSON = """
        {
            "success": true,
            "action_type": "app_action_required",
            "app_action": {
                "type": "log_budget_entry",
                "amount": 100,
                "date": "2025-11-03",
                "transaction_type": "Expenses",
                "category": "Groceries",
                "details": null
            },
            "message": "Mock action processed successfully"
        }
        """.data(using: .utf8)!

        // Act: Process through live repository with mocked network
        let result = try await withDependencies {
            $0.networkService = MockNetworkService(mockData: validJSON)
        } operation: {
            @Dependency(\.actionHandlerRepository) var repository
            return try await repository.processAction(input: "test")
        }

        // Assert: Verify successful processing
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.message == "Mock action processed successfully")

        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(action.amount == Decimal(100))
        #expect(action.category == .groceries)
    }
}
