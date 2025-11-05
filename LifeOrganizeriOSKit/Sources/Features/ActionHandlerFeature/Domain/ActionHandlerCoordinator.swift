import Foundation
import Entities
import Framework

/// Coordinates action routing to appropriate handlers
///
/// The coordinator manages handler instances and routes actions based on their type.
/// This provides a single entry point for action execution and simplifies adding new
/// action types in the future.
///
/// **Usage**:
/// ```swift
/// let coordinator = ActionHandlerCoordinator()
/// let action = Action.budget(budgetAction)
/// let result = try await coordinator.route(action)
/// ```
///
/// **Future Extension**:
/// To add a new action type:
/// 1. Add handler property (e.g., `calendarHandler`)
/// 2. Add parameter to initializer
/// 3. Add new case to `route()` switch statement
public actor ActionHandlerCoordinator {
    private let budgetHandler: BudgetActionHandler
    // Future: private let calendarHandler: CalendarActionHandler
    // Future: private let reminderHandler: ReminderActionHandler
    
    /// Initialize coordinator with handler instances
    /// - Parameter budgetHandler: Handler for budget actions (default: BudgetActionHandler())
    public init(budgetHandler: BudgetActionHandler = BudgetActionHandler()) {
        self.budgetHandler = budgetHandler
    }
    
    /// Routes action to appropriate handler
    /// - Parameter action: The action to execute
    /// - Returns: Result of action execution
    /// - Throws: AppError if routing or execution fails
    public func route(_ action: Action) async throws -> ActionHandlerResult {
        switch action {
        case .budget(let budgetAction):
            return try await budgetHandler.handle(budgetAction)
        
        // Future action type cases:
        // case .calendar(let calendarAction):
        //     return try await calendarHandler.handle(calendarAction)
        // case .reminder(let reminderAction):
        //     return try await reminderHandler.handle(reminderAction)
        }
    }
}

