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
        }
    }
}

