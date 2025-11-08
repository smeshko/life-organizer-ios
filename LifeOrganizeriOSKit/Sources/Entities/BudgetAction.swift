import Foundation

/// Budget-specific action data with financial precision
public struct BudgetAction: Sendable, Equatable {
    public let amount: Decimal
    public let date: Date
    public let transactionType: TransactionType
    public let category: BudgetCategory
    public let details: String?

    public init(
        amount: Decimal,
        date: Date,
        transactionType: TransactionType,
        category: BudgetCategory,
        details: String? = nil
    ) {
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.category = category
        self.details = details
    }
}
