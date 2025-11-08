import Testing
import Dependencies
import Foundation
import Framework
import Entities
@testable import ActionHandlerFeature

@Suite("Error Scenario Tests")
struct ErrorScenarioTests {

    @Test("Repository throws error when mock error is set")
    func repositoryErrorHandling() async throws {
        // Arrange
        let expectedError = AppError.network(.invalidResponse)
        let mockRepo = MockActionHandlerRepository(mockError: expectedError)

        // Act & Assert
        await #expect(throws: (any Error).self) {
            try await mockRepo.processAction(input: "test")
        }
    }

    @Test("Default mock response is returned when no error")
    func defaultMockResponse() async throws {
        // Arrange
        let mockRepo = MockActionHandlerRepository()

        // Act
        let result = try await mockRepo.processAction(input: "test")

        // Assert
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.message == "Mock action processed successfully")

        guard case .budget(let action) = result.action else {
            Issue.record("Expected budget action")
            return
        }

        #expect(action.amount == Decimal(100))
        #expect(action.category == .groceries)
    }

    @Test("Custom mock response overrides default")
    func customMockResponse() async throws {
        // Arrange
        let customResponse = ProcessingResponse(
            processingResultType: .backendHandled,
            action: nil,
            message: "Custom message"
        )
        let mockRepo = MockActionHandlerRepository(mockResponse: customResponse)

        // Act
        let result = try await mockRepo.processAction(input: "test")

        // Assert
        #expect(result.processingResultType == .backendHandled)
        #expect(result.action == nil)
        #expect(result.message == "Custom message")
    }
}
