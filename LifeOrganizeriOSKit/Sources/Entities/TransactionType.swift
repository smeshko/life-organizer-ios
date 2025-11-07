import Foundation

/// Transaction type for budget actions
public enum TransactionType: String, Sendable, Equatable, Codable {
    case expense
    case income
    case savings
}

