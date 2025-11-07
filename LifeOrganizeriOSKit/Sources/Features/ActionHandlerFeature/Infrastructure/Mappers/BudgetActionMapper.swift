import Foundation
import Entities
import Framework

/// Maps LogBudgetEntryActionDTO to BudgetAction domain entity
struct BudgetActionMapper {
    /// Transforms DTO to domain entity
    /// - Parameter dto: Log budget entry action DTO from backend
    /// - Returns: BudgetAction domain entity
    /// - Throws: AppError.actionHandler if mapping fails
    static func toDomain(_ dto: LogBudgetEntryActionDTO) throws -> BudgetAction {
        // Parse date
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dto.date) else {
            throw AppError.actionHandler(.invalidAction("Invalid date format: \(dto.date)"))
        }

        // Map transaction type - normalize to lowercase to match enum cases
        let normalizedType = dto.transactionType.lowercased()
        guard let transactionType = TransactionType(rawValue: normalizedType) else {
            throw AppError.actionHandler(.invalidAction("Invalid transaction type: \(dto.transactionType)"))
        }

        // Map category enum - handle "Other" based on transaction type context
        let category: BudgetCategory
        if dto.category == "Other" {
            // Backend uses "Other" for both expense and income, disambiguate based on transaction type
            switch transactionType {
            case .expense:
                category = .expenseOther
            case .income:
                category = .incomeOther
            case .savings:
                throw AppError.actionHandler(.invalidAction("Savings transactions should not have 'Other' category"))
            }
        } else {
            guard let mappedCategory = BudgetCategory(rawValue: dto.category) else {
                throw AppError.actionHandler(.invalidAction("Invalid category: \(dto.category)"))
            }
            category = mappedCategory
        }

        // Validate amount
        guard dto.amount > 0 else {
            throw AppError.actionHandler(.invalidAction("Amount must be positive"))
        }

        return BudgetAction(
            amount: dto.amount,
            date: date,
            transactionType: transactionType,
            category: category,
            details: dto.details
        )
    }
}

