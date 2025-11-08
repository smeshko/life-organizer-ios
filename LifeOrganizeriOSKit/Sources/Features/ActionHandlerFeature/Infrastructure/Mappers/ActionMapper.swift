import Foundation
import Entities
import Framework

/// Maps polymorphic ActionDTO to Action entity enum
struct ActionMapper {
    static func toDomain(_ dto: ActionDTO) throws -> Action {
        switch dto {
        case .budget(let budgetDTO):
            // Map budget DTO to budget entity
            let budgetAction = try BudgetActionMapper.toDomain(budgetDTO)
            return .budget(budgetAction)

        case .unknown(let type):
            // Unknown action types are not supported
            throw AppError.actionHandler(.handlerNotFound("Unknown action type: '\(type)'"))
        }
    }
}
