import Foundation
import Entities

struct MockActionHandlerRemoteDataSource: ActionHandlerRemoteDataSourceProtocol {
    func processAction(input: String) async throws -> [ProcessingResponse] {
        // Return default mock response (single-element array)
        [ProcessingResponse(
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
