import Foundation

/// Text classification categories supported by the on-device classifier.
///
/// Each category represents a type of user input that requires different processing:
/// - BUDGET: Financial transactions and expense tracking
/// - SHOPPING: Shopping lists and items to purchase
/// - REMINDER: Tasks and reminders with optional due dates
/// - CALENDAR: Calendar events with specific dates/times
/// - NOTE: General notes and thoughts
/// - QUOTE: Inspirational quotes and sayings
public enum TextCategory: String, CaseIterable, Sendable, Equatable {
    case budget
    case shopping
    case reminder
    case calendar
    case note
    case quote

    /// Index mapping for CoreML model output
    /// budget=0, shopping=1, reminder=2, calendar=3, note=4, quote=5
    public var index: Int {
        switch self {
        case .budget: return 0
        case .shopping: return 1
        case .reminder: return 2
        case .calendar: return 3
        case .note: return 4
        case .quote: return 5
        }
    }

    /// Create category from model output index
    public static func from(index: Int) -> TextCategory? {
        Self.allCases.first { $0.index == index }
    }
    
    /// Convert iOS TextCategory to backend API category string format
    /// Maps: budget->budget, shopping->shopping, reminder->reminder, calendar->calendar, note->note, quote->quote
    public var toBackendCategory: String {
        return self.rawValue
    }
}
