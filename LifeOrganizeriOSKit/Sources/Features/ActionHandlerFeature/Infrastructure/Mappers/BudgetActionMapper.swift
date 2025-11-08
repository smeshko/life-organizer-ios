import Foundation
import Entities
import Framework

/// Maps BudgetActionDTO (API primitives) to BudgetAction (domain entity)
struct BudgetActionMapper {
    static func toDomain(_ dto: BudgetActionDTO) throws -> BudgetAction {
        // Parse ISO 8601 date string
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dto.date) else {
            throw AppError.actionHandler(.invalidAction("Invalid date format: '\(dto.date)'. Expected ISO 8601 (YYYY-MM-DD)"))
        }

        // Map transaction type string to enum
        guard let transactionType = TransactionType(rawValue: dto.transactionType) else {
            throw AppError.actionHandler(.invalidAction("Invalid transaction type: '\(dto.transactionType)'. Expected 'Expenses', 'Income', or 'Savings'"))
        }

        // Map category with graceful degradation to .other
        let category = BudgetCategory(rawValue: dto.category) ?? .other

        // Validate amount is positive
        guard dto.amount > 0 else {
            throw AppError.actionHandler(.invalidAction("Amount must be positive, got: \(dto.amount)"))
        }

        // Convert Double to Decimal for financial precision
        let amount = Decimal(dto.amount)

        return BudgetAction(
            amount: amount,
            date: date,
            transactionType: transactionType,
            category: category,
            details: dto.details
        )
    }
}
