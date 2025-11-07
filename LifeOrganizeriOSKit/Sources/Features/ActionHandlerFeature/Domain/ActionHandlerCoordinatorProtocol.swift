import Foundation
import Entities

/// Protocol for action handler coordinator
public protocol ActionHandlerCoordinatorProtocol: Sendable {
    /// Routes action to appropriate handler
    /// - Parameter action: The action to execute
    /// - Returns: Result of action execution
    /// - Throws: AppError if routing or execution fails
    func route(_ action: Action) async throws -> ActionHandlerResult
}
