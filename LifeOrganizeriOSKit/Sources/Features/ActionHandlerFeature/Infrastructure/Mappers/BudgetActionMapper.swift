import Foundation
import Entities
import Framework

/// Maps BudgetActionDTO to BudgetAction domain entity
struct BudgetActionMapper {
    /// Transforms DTO to domain entity
    /// - Parameter dto: Budget action DTO from backend
    /// - Returns: BudgetAction domain entity
    /// - Throws: AppError.actionHandler if mapping fails
    static func toDomain(_ dto: BudgetActionDTO) throws -> BudgetAction {
        // Parse date
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dto.date) else {
            throw AppError.actionHandler(.invalidAction("Invalid date format: \(dto.date)"))
        }
        
        // Map transaction type
        guard let transactionType = TransactionType(rawValue: dto.transactionType) else {
            throw AppError.actionHandler(.invalidAction("Invalid transaction type: \(dto.transactionType)"))
        }
        
        // Validate amount
        guard dto.amount > 0 else {
            throw AppError.actionHandler(.invalidAction("Amount must be positive"))
        }
        
        return BudgetAction(
            amount: dto.amount,
            date: date,
            transactionType: transactionType,
            category: dto.category,
            details: dto.details
        )
    }
}

