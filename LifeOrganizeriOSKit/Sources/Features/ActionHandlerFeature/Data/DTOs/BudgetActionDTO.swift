import Foundation

/// Budget action data from backend (DTO layer)
public struct BudgetActionDTO: Codable, Sendable {
    let amount: Double
    let date: String  // ISO 8601 format
    let transactionType: String
    let category: String?
    let details: String?
    
    enum CodingKeys: String, CodingKey {
        case amount
        case date
        case transactionType = "transaction_type"
        case category
        case details
    }
}

