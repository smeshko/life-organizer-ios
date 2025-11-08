import Foundation
import Entities

actor MockActionHandlerRepository: ActionHandlerRepositoryProtocol {
    var mockResponse: ProcessingResponse?
    var mockError: (any Error)?

    init(
        mockResponse: ProcessingResponse? = nil,
        mockError: (any Error)? = nil
    ) {
        self.mockResponse = mockResponse
        self.mockError = mockError
    }

    func processAction(input: String) async throws -> ProcessingResponse {
        if let error = mockError {
            throw error
        }

        if let response = mockResponse {
            return response
        }

        // Default success response
        return ProcessingResponse(
            processingResultType: .appActionRequired,
            action: .budget(BudgetAction(
                amount: Decimal(100),
                date: Date(),
                transactionType: .expense,
                category: .groceries,
                details: "Mock budget action"
            )),
            message: "Mock action processed successfully"
        )
    }
}
