import Foundation

/// Action to create a calendar event in iOS Calendar app
public struct CreateCalendarEventActionDTO: Codable, Sendable {
    /// Action type discriminator (always "create_calendar_event")
    let type: String

    // TODO: Add specific fields when backend schema is finalized

    enum CodingKeys: String, CodingKey {
        case type
    }
}
