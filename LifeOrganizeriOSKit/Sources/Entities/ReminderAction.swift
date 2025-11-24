import Foundation

/// Reminder-specific action data for creating reminders in iOS Reminders app
public struct ReminderAction: Sendable, Equatable {
    public let title: String
    public let dueDate: Date?
    public let notes: String?

    public init(
        title: String,
        dueDate: Date? = nil,
        notes: String? = nil
    ) {
        self.title = title
        self.dueDate = dueDate
        self.notes = notes
    }
}
