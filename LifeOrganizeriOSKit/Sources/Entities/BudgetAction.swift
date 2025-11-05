import Foundation

/// Budget-specific action data
public struct BudgetAction: Sendable, Equatable, Codable {
    public let amount: Double
    public let date: Date
    public let transactionType: TransactionType
    public let category: String?
    public let details: String?
    
    public init(
        amount: Double,
        date: Date,
        transactionType: TransactionType,
        category: String? = nil,
        details: String? = nil
    ) {
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.category = category
        self.details = details
    }
}

