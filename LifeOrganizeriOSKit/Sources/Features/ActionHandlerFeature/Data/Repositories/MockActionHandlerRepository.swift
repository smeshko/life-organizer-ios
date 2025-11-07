import Foundation
import Entities

/// Mock repository for testing
public struct MockActionHandlerRepository: ActionHandlerRepositoryProtocol {
    public var result: Result<ActionResult, any Error>
    
    public init(result: Result<ActionResult, any Error> = .success(Self.successResult)) {
        self.result = result
    }
    
    public func processAction(input: String) async throws -> ActionResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 50_000_000)  // 50ms
        
        switch result {
        case .success(let actionResult):
            return actionResult
        case .failure(let error):
            throw error
        }
    }
    
    // Default success result
    public static var successResult: ActionResult {
        ActionResult(
            processingResultType: .appActionRequired,
            action: .budget(BudgetAction(
                amount: 100.0,
                date: Date(),
                transactionType: .expense,
                category: .groceries,
                details: "Test details"
            )),
            message: "Mock action processed successfully"
        )
    }
}

