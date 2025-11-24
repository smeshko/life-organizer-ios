import Foundation
import Entities

public protocol ReminderServiceProtocol: Sendable {
    /// Creates a reminder in the iOS Reminders app.
    /// - Parameter action: The reminder action containing title, optional due date, and notes
    /// - Throws: If permission denied or reminder creation fails
    func createReminder(_ action: ReminderAction) async throws
}
