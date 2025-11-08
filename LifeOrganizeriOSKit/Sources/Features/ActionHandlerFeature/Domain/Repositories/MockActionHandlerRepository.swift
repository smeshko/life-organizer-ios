import Foundation

/// Mock repository for testing
public struct MockActionHandlerRepository: ActionHandlerRepositoryProtocol {
    public var mockResponse: ProcessingResponse?
    public var mockError: Error?

    public init(
        mockResponse: ProcessingResponse? = nil,
        mockError: Error? = nil
    ) {
        self.mockResponse = mockResponse
        self.mockError = mockError
    }

    public func processAction(input: String) async throws -> ProcessingResponse {
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
