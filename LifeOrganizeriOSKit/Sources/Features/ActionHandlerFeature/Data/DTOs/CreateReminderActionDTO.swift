import Foundation

/// Action to create a reminder in iOS Reminders app
public struct CreateReminderActionDTO: Codable, Sendable {
    /// Action type discriminator (always "create_reminder")
    let type: String

    // TODO: Add specific fields when backend schema is finalized

    enum CodingKeys: String, CodingKey {
        case type
    }
}
