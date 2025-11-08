import Foundation

/// Budget categories (23 predefined + other for graceful degradation)
public enum BudgetCategory: String, Sendable, Equatable, Codable {
    // Expense categories (16)
    case groceries = "Groceries"
    case clothes = "Clothes"
    case bodyCare = "Body care"
    case bills = "Bills"
    case electronics = "Electronics"
    case entertainment = "Entertainment"
    case health = "Health"
    case home = "Home"
    case kids = "Kids"
    case miscellaneous = "Miscellaneous"
    case pets = "Pets"
    case restaurants = "Restaurants"
    case subscriptions = "Subscriptions"
    case tobacco = "Tobacco"
    case transport = "Transport"
    case travel = "Travel"

    // Income categories (4)
    case salaryIvo = "Salary Ivo"
    case salaryIvi = "Salary Ivi"
    case gifts = "Gifts"
    case bonuses = "Bonuses"

    // Savings categories (3)
    case metlife = "Metlife"
    case revolut = "Revolut"
    case savings = "Savings"

    // Unknown category fallback
    case other = "Other"
}
