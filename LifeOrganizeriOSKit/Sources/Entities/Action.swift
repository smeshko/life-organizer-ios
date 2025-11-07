import Foundation

/// Polymorphic action enum representing different action types
public enum Action: Sendable, Equatable {
    case budget(BudgetAction)
    // Future: calendar, reminder, task cases
    
    enum CodingKeys: String, CodingKey {
        case type
        case data
    }
    
    enum ActionTypeKey: String, CodingKey {
        case logBudgetEntry = "log_budget_entry"
        // Future action type keys
    }
}

// MARK: - Codable
extension Action: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "log_budget_entry":
            let budgetAction = try container.decode(BudgetAction.self, forKey: .data)
            self = .budget(budgetAction)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown action type: \(type)"
            )
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .budget(let budgetAction):
            try container.encode("log_budget_entry", forKey: .type)
            try container.encode(budgetAction, forKey: .data)
        }
    }
}

