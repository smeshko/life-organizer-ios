import Foundation

/// Budget category that combines all transaction type categories
public enum BudgetCategory: String, Sendable, Equatable, Codable, CaseIterable {
    // Expense categories
    case baby = "Baby"
    case bodyCare = "Body care"
    case clothes = "Clothes"
    case eatOut = "Eat out"
    case fun = "Fun"
    case groceries = "Groceries"
    case hobbies = "Hobbies"
    case homeImprovements = "Home improvements"
    case maya = "Maya"
    case medical = "Medical"
    case mortgage = "Mortgage"
    case expenseOther = "Expense Other"
    case subscriptions = "Subscriptions"
    case transport = "Transport"
    case utilities = "Utilities"
    case vacation = "Vacation"

    // Income categories
    case salaryIvo = "Salary Ivo"
    case salaryKalina = "Salary Kalina"
    case rent = "Rent"
    case incomeOther = "Income Other"

    // Savings categories
    case aviSavings = "Avi Savings"
    case metlife = "Metlife"
    case savings = "Savings"

    /// Returns all expense categories
    public static var expenseCategories: [BudgetCategory] {
        [.baby, .bodyCare, .clothes, .eatOut, .fun, .groceries, .hobbies,
         .homeImprovements, .maya, .medical, .mortgage, .expenseOther, .subscriptions,
         .transport, .utilities, .vacation]
    }

    /// Returns all income categories
    public static var incomeCategories: [BudgetCategory] {
        [.salaryIvo, .salaryKalina, .rent, .incomeOther]
    }

    /// Returns all savings categories
    public static var savingsCategories: [BudgetCategory] {
        [.aviSavings, .metlife, .savings]
    }

    /// Returns categories for a specific transaction type
    public static func categories(for transactionType: TransactionType) -> [BudgetCategory] {
        switch transactionType {
        case .expense:
            return expenseCategories
        case .income:
            return incomeCategories
        case .savings:
            return savingsCategories
        }
    }
}
