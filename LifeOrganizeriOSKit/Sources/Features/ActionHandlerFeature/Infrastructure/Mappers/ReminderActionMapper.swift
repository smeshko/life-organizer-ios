import Foundation
import Entities

/// Maps ReminderActionDTO (API primitives) to ReminderAction (domain entity)
struct ReminderActionMapper {
    static func toDomain(_ dto: ReminderActionDTO) -> ReminderAction {
        // Parse optional ISO 8601 date string
        var dueDate: Date? = nil
        if let dueDateString = dto.dueDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            dueDate = formatter.date(from: dueDateString)

            // Try without fractional seconds if first attempt fails
            if dueDate == nil {
                formatter.formatOptions = [.withInternetDateTime]
                dueDate = formatter.date(from: dueDateString)
            }
        }

        return ReminderAction(
            title: dto.title,
            dueDate: dueDate,
            notes: dto.notes
        )
    }
}
