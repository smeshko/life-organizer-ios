import Foundation

/// Transaction type for budget actions (matches backend capitalization)
public enum TransactionType: String, Sendable, Equatable, Codable {
    case expense = "Expenses"
    case income = "Income"
    case savings = "Savings"
}
