import Foundation
import Entities

/// Protocol for action handler repository
public protocol ActionHandlerRepositoryProtocol: Sendable {
    /// Processes user input and returns structured action result
    /// - Parameter input: Natural language user input
    /// - Returns: ActionResult domain entity
    /// - Throws: AppError if processing fails
    func processAction(input: String) async throws -> ActionResult
}

