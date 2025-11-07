import Foundation

/// Polymorphic action data container from backend
public enum ActionDTO: Codable, Sendable {
    case logBudgetEntry(LogBudgetEntryActionDTO)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "log_budget_entry":
            let action = try LogBudgetEntryActionDTO(from: decoder)
            self = .logBudgetEntry(action)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown action type: \(type)"
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .logBudgetEntry(let action):
            try action.encode(to: encoder)
        }
    }
}

