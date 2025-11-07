import Foundation
import Entities

/// Protocol for budget action handler
public protocol BudgetActionHandlerProtocol: Sendable {
    /// Handles a budget action
    /// - Parameter action: Budget action to handle
    /// - Returns: Result of handling the action
    /// - Throws: AppError if handling fails
    func handle(_ action: BudgetAction) async throws -> ActionHandlerResult
}
