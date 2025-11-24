import Foundation
import EventKit
import Entities
import Framework

public struct ReminderService: ReminderServiceProtocol, Sendable {
    private nonisolated(unsafe) let eventStore: EKEventStore

    public init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    public func createReminder(_ action: ReminderAction) async throws {
        // Request permission (iOS 17+)
        let granted = try await eventStore.requestFullAccessToReminders()
        guard granted else {
            throw AppError.reminder(.permissionDenied)
        }

        // Create reminder
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = action.title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()

        // Set due date if provided
        if let dueDate = action.dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
        }

        // Set notes if provided
        if let notes = action.notes {
            reminder.notes = notes
        }

        // Save reminder
        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            throw AppError.reminder(.saveFailed(error.localizedDescription))
        }
    }
}
