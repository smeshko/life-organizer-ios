import Foundation

/// Reminder action DTO (includes type discriminator and data fields)
public struct ReminderActionDTO: Codable, Sendable {
    public let type: String  // "create_reminder"
    public let title: String
    public let dueDate: String?  // ISO 8601: "2025-11-25T17:00:00"
    public let listId: String?   // Ignored - use default list
    public let notes: String?

    public init(
        type: String,
        title: String,
        dueDate: String? = nil,
        listId: String? = nil,
        notes: String? = nil
    ) {
        self.type = type
        self.title = title
        self.dueDate = dueDate
        self.listId = listId
        self.notes = notes
    }

    // No CodingKeys needed - JSONDecoder.keyDecodingStrategy handles conversion
}
