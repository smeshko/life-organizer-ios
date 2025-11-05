import Foundation

/// Polymorphic action data container from backend
public struct ActionDTO: Codable, Sendable {
    let type: String
    let data: BudgetActionDTO?  // Polymorphic based on type
    
    enum CodingKeys: String, CodingKey {
        case type
        case data
    }
}

