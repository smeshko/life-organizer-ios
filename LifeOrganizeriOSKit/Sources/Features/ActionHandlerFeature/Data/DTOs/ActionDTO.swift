import Foundation

/// Polymorphic action DTO - discriminates based on "type" field
public enum ActionDTO: Codable, Sendable {
    case budget(BudgetActionDTO)
    case unknown(String)  // For graceful handling of future/unknown types

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        // Read the type discriminator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        // Decode the entire container as the appropriate DTO
        switch type {
        case "log_budget_entry":
            let budgetAction = try BudgetActionDTO(from: decoder)
            self = .budget(budgetAction)
        default:
            // Gracefully handle unknown types
            self = .unknown(type)
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .budget(let budgetAction):
            try budgetAction.encode(to: encoder)
        case .unknown:
            // Cannot encode unknown type
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("unknown", forKey: .type)
        }
    }
}
