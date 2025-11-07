import Foundation

/// Polymorphic action data container from backend
public enum ActionDTO: Codable, Sendable {
    case logBudgetEntry(LogBudgetEntryActionDTO)
    case createReminder(CreateReminderActionDTO)
    case addToShoppingList(AddToShoppingListActionDTO)
    case createCalendarEvent(CreateCalendarEventActionDTO)

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
        case "create_reminder":
            let action = try CreateReminderActionDTO(from: decoder)
            self = .createReminder(action)
        case "add_to_shopping_list":
            let action = try AddToShoppingListActionDTO(from: decoder)
            self = .addToShoppingList(action)
        case "create_calendar_event":
            let action = try CreateCalendarEventActionDTO(from: decoder)
            self = .createCalendarEvent(action)
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
        case .createReminder(let action):
            try action.encode(to: encoder)
        case .addToShoppingList(let action):
            try action.encode(to: encoder)
        case .createCalendarEvent(let action):
            try action.encode(to: encoder)
        }
    }
}

