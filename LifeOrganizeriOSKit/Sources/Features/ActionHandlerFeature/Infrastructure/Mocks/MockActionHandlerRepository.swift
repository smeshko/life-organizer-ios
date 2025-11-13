import Foundation
import Entities

actor MockActionHandlerRepository: ActionHandlerRepositoryProtocol {
    var mockResponses: [ProcessingResponse]?
    var mockError: (any Error)?

    init(
        mockResponses: [ProcessingResponse]? = nil,
        mockError: (any Error)? = nil
    ) {
        self.mockResponses = mockResponses
        self.mockError = mockError
    }

    func processAction(input: String) async throws -> [ProcessingResponse] {
        if let error = mockError {
            throw error
        }

        if let responses = mockResponses {
            return responses
        }

        // Default success response (single-element array)
        return [ProcessingResponse(
            processingResultType: .appActionRequired,
            action: .budget(BudgetAction(
                amount: Decimal(100),
                date: Date(),
                transactionType: .expense,
                category: .groceries,
                details: "Mock budget action"
            )),
            message: "Mock action processed successfully"
        )]
    }
}
