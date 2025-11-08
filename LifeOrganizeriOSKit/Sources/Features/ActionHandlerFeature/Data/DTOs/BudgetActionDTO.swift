import Foundation

/// Budget action DTO (includes type discriminator and data fields)
public struct BudgetActionDTO: Codable, Sendable {
    public let type: String  // "log_budget_entry"
    public let amount: Double
    public let date: String  // ISO 8601: "YYYY-MM-DD"
    public let transactionType: String  // Backend "transaction_type" → Swift "transactionType"
    public let category: String
    public let details: String?

    public init(
        type: String,
        amount: Double,
        date: String,
        transactionType: String,
        category: String,
        details: String? = nil
    ) {
        self.type = type
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.category = category
        self.details = details
    }

    // No CodingKeys needed - JSONDecoder.keyDecodingStrategy handles conversion
}
