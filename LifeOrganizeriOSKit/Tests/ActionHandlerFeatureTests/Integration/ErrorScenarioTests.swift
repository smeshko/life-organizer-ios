import Testing
import Dependencies
import Foundation
import Framework
import Entities
import NetworkService
@testable import ActionHandlerFeature

@Suite("Error Scenario Tests")
struct ErrorScenarioTests {
    let repository = DependencyValues.live.actionHandlerRepository

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
                // Force all dependencies to use live values
                $0.actionHandlerRemoteDataSource = DependencyValues.live.actionHandlerRemoteDataSource
                $0.networkService = mockNetworkService
            } operation: {
                try await self.repository.processAction(input: "test")
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
                // Force all dependencies to use live values
                $0.actionHandlerRemoteDataSource = DependencyValues.live.actionHandlerRemoteDataSource
                $0.networkService = MockNetworkService(mockData: invalidJSON)
            } operation: {
                try await self.repository.processAction(input: "test")
            }
        }
    }

    @Test("Valid response is successfully processed through full stack")
    func successfulEndToEndProcessing() async throws {
        // Arrange: Load valid mock response
        let validJSON = try TestResources.loadMockResponse("valid_budget_action")

        // Act: Process through live repository with mocked network
        let result = try await withDependencies {
            // Force all dependencies to use live values
            $0.actionHandlerRemoteDataSource = DependencyValues.live.actionHandlerRemoteDataSource
            $0.networkService = MockNetworkService(mockData: validJSON)
        } operation: {
            try await self.repository.processAction(input: "test")
        }

        // Assert: Verify successful processing
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.message == "Logged expenses: 234.6 BGN in Clothes")

        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(action.amount == Decimal(string: "234.6"))
        #expect(action.category == .clothes)
    }
}
