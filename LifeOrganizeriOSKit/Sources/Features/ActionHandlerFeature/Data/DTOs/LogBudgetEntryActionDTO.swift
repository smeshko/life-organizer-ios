import Foundation

/// Action to log a budget entry (expense/income/savings) in Excel sheet
public struct LogBudgetEntryActionDTO: Codable, Sendable {
    /// Action type discriminator (always "log_budget_entry")
    let type: String

    /// Amount in BGN (after EUR conversion if needed)
    let amount: Double

    /// Transaction date in ISO format (YYYY-MM-DD)
    let date: String

    /// Type of transaction ("Expenses", "Income", "Savings")
    let transactionType: String

    /// Budget category name (from predefined categories)
    let category: String

    /// Optional merchant/description (e.g., "next", "dm", "ibkr")
    let details: String?

    enum CodingKeys: String, CodingKey {
        case type
        case amount
        case date
        case transactionType = "transaction_type"
        case category
        case details
    }
}

