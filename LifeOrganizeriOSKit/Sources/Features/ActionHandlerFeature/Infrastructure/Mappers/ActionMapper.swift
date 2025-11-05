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
        switch dto.type {
        case "log_budget_entry":
            guard let budgetData = dto.data else {
                throw AppError.actionHandler(.invalidAction("Missing budget action data"))
            }
            let budgetAction = try BudgetActionMapper.toDomain(budgetData)
            return .budget(budgetAction)
            
        // Future: Add calendar, reminder, task cases
        // case "create_calendar_event":
        //     guard let calendarData = dto.calendarData else { ... }
        //     return .calendar(try CalendarActionMapper.toDomain(calendarData))
            
        default:
            throw AppError.actionHandler(.handlerNotFound("Unknown action type: \(dto.type)"))
        }
    }
}

