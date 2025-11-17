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
    case BUDGET
    case SHOPPING
    case REMINDER
    case CALENDAR
    case NOTE
    case QUOTE

    /// Index mapping for CoreML model output
    /// BUDGET=0, SHOPPING=1, REMINDER=2, CALENDAR=3, NOTE=4, QUOTE=5
    public var index: Int {
        switch self {
        case .BUDGET: return 0
        case .SHOPPING: return 1
        case .REMINDER: return 2
        case .CALENDAR: return 3
        case .NOTE: return 4
        case .QUOTE: return 5
        }
    }

    /// Create category from model output index
    public static func from(index: Int) -> TextCategory? {
        Self.allCases.first { $0.index == index }
    }
    
    /// Convert iOS TextCategory to backend API category string format
    /// Maps: BUDGET->budget, SHOPPING->shopping, REMINDER->reminder, CALENDAR->calendar, NOTE->note, QUOTE->quote
    public var toBackendCategory: String {
        return self.rawValue.lowercased()
    }
}
