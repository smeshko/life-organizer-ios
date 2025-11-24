import Foundation

/// Polymorphic action enum representing different action types from backend
public enum Action: Sendable, Equatable {
    case budget(BudgetAction)
    case reminder(ReminderAction)
    // Future: case calendar(CalendarAction)
    // Future: case shopping(ShoppingAction)
}

// MARK: - Codable
// NOTE: Polymorphic decoding is handled in the mapper layer, not here
// Entities remain simple value types without complex Codable logic
