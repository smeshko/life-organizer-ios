import Foundation
import Entities
import Framework

/// Maps ActionDTO to Action domain entity
struct ActionMapper {
    /// Transforms DTO to domain entity
    /// - Parameter dto: Action DTO from backend
    /// - Returns: Action domain entity
    /// - Throws: AppError.actionHandler if mapping fails
    static func toDomain(_ dto: ActionDTO) throws -> Action {
        switch dto {
        case .logBudgetEntry(let budgetData):
            let budgetAction = try BudgetActionMapper.toDomain(budgetData)
            return .budget(budgetAction)

        case .createReminder:
            // TODO: Implement when reminder schema is finalized
            throw AppError.actionHandler(.handlerNotFound("Reminder actions not yet implemented"))

        case .addToShoppingList:
            // TODO: Implement when shopping list schema is finalized
            throw AppError.actionHandler(.handlerNotFound("Shopping list actions not yet implemented"))

        case .createCalendarEvent:
            // TODO: Implement when calendar event schema is finalized
            throw AppError.actionHandler(.handlerNotFound("Calendar event actions not yet implemented"))
        }
    }
}

