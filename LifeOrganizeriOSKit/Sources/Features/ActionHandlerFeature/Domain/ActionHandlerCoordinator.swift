import Foundation
import Entities
import Framework
import ComposableArchitecture
import Dependencies

/// Coordinates action routing to appropriate handlers
///
/// The coordinator manages handler instances and routes actions based on their type.
/// This provides a single entry point for action execution.
///
/// **Usage**:
/// ```swift
/// @Dependency(\.actionHandlerCoordinator) var coordinator
/// let action = Action.budget(budgetAction)
/// let result = try await coordinator.route(action)
/// ```
public struct ActionHandlerCoordinator: ActionHandlerCoordinatorProtocol {
    @Dependency(\.budgetActionHandler) var budgetHandler

    public init() {}

    /// Routes action to appropriate handler
    /// - Parameter action: The action to execute
    /// - Returns: Result of action execution
    /// - Throws: AppError if routing or execution fails
    public func route(_ action: Action) async throws -> ActionHandlerResult {
        switch action {
        case .budget(let budgetAction):
            return try await budgetHandler.handle(budgetAction)
        }
    }
}

