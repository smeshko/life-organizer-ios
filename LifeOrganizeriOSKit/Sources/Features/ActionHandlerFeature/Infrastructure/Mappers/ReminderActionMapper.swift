import Foundation
import Entities

/// Maps ReminderActionDTO (API primitives) to ReminderAction (domain entity)
struct ReminderActionMapper {
    static func toDomain(_ dto: ReminderActionDTO) -> ReminderAction {
        // Parse optional ISO 8601 date string
        var dueDate: Date? = nil
        if let dueDateString = dto.dueDate {
            dueDate = parseDate(dueDateString)
        }

        return ReminderAction(
            title: dto.title,
            dueDate: dueDate,
            notes: dto.notes
        )
    }

    /// Parses ISO 8601 date strings with various formats
    private static func parseDate(_ dateString: String) -> Date? {
        // Try with timezone and fractional seconds: "2025-11-25T17:00:00.000Z"
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        // Try with timezone only: "2025-11-25T17:00:00Z"
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        // Try without timezone (backend format): "2025-11-25T17:00:00"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        if let date = dateFormatter.date(from: dateString) {
            return date
        }

        return nil
    }
}
