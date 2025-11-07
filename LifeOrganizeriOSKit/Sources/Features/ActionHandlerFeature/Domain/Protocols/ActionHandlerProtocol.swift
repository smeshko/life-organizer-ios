import Foundation
import Entities

/// Protocol for action handlers
/// Each handler processes a specific action type
public protocol ActionHandlerProtocol: Sendable {
    associatedtype ActionDataType: Sendable
    
    /// Handles the given action
    /// - Parameter action: The action data to process
    /// - Returns: Result of the handler execution
    /// - Throws: AppError if handling fails
    func handle(_ action: ActionDataType) async throws -> ActionHandlerResult
}

