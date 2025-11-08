import Foundation
import Testing
import NetworkService
import Framework
import Dependencies
import Entities
@testable import ActionHandlerFeature

// MARK: - Test Helpers

extension MockNetworkService {
    init(mockData: Data) {
        self.init(mockResponseProvider: { _ in mockData })
    }
}

// MARK: - JSON Resource Loader

enum TestResources {
    static func loadMockResponse(_ key: String) throws -> Data {
        // Use SPM's generated Bundle.module
        guard let url = Bundle.module.url(forResource: "mock-responses", withExtension: "json") else {
            throw TestResourceError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseDict = json[key] as? [String: Any] else {
            throw TestResourceError.responseNotFound(key)
        }

        return try JSONSerialization.data(withJSONObject: responseDict)
    }
}

enum TestResourceError: Error, LocalizedError {
    case fileNotFound
    case responseNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "mock-responses.json not found"
        case .responseNotFound(let key):
            return "Response key '\(key)' not found in mock-responses.json"
        }
    }
}

// MARK: - Centralized Test Data

enum TestData {
    enum BudgetDTOs {
        /// Valid budget action DTO for expenses
        static let validExpense = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 234.6,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Clothes",
            details: "next"
        )

        /// Valid budget action DTO for income
        static let validIncome = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 5000.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Income",
            category: "Salary Ivo",
            details: "Monthly salary"
        )

        /// Valid budget action DTO for savings
        static let validSavings = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 1000.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Savings",
            category: "Savings",
            details: "Emergency fund"
        )

        /// Budget DTO with nil details
        static let withNilDetails = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Income",
            category: "Salary Ivo",
            details: nil
        )

        /// Budget DTO with invalid date format
        static let invalidDate = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "invalid-date",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )

        /// Budget DTO with invalid transaction type
        static let invalidTransactionType = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 100.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "InvalidType",
            category: "Food",
            details: nil
        )

        /// Budget DTO with negative amount
        static let negativeAmount = BudgetActionDTO(
            type: "log_budget_entry",
            amount: -50.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )

        /// Budget DTO with zero amount
        static let zeroAmount = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 0.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Food",
            details: nil
        )

        /// Budget DTO with large amount
        static let largeAmount = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 999999.99,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Other",
            details: nil
        )

        /// Budget DTO with fractional amount
        static let fractionalAmount = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 0.01,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "Other",
            details: nil
        )

        /// Budget DTO with unknown category (for graceful degradation)
        static let unknownCategory = BudgetActionDTO(
            type: "log_budget_entry",
            amount: 50.0,
            date: "2025-01-15T00:00:00Z",
            transactionType: "Expenses",
            category: "UnknownCategory",
            details: nil
        )
    }

    enum ActionDTOs {
        /// Valid budget ActionDTO (wrapped)
        static let validBudget: ActionDTO = .budget(BudgetDTOs.validExpense)

        /// Valid income ActionDTO (wrapped)
        static let validIncome: ActionDTO = .budget(BudgetDTOs.validIncome)

        /// Valid savings ActionDTO (wrapped)
        static let validSavings: ActionDTO = .budget(BudgetDTOs.validSavings)

        /// Unknown action type
        static let unknown: ActionDTO = .unknown("future_action_type")
    }

    enum ProcessingResponseDTOs {
        /// Valid app action required response
        static let appActionRequired = ProcessingResponseDTO(
            success: true,
            actionType: "app_action_required",
            appAction: .budget(BudgetDTOs.validExpense),
            message: "Logged expenses: 234.6 BGN in Clothes"
        )

        /// Backend handled response
        static let backendHandled = ProcessingResponseDTO(
            success: true,
            actionType: "backend_handled",
            appAction: nil,
            message: "Request processed by backend"
        )

        /// Error response
        static let error = ProcessingResponseDTO(
            success: false,
            actionType: "error",
            appAction: nil,
            message: "Failed to process request"
        )

        /// Unknown processing result type
        static let unknownType = ProcessingResponseDTO(
            success: true,
            actionType: "unknown_type",
            appAction: nil,
            message: "Some message"
        )
    }
}

// MARK: - Standardized Error Assertions

/// Helper for asserting errors with detailed verification
enum ErrorAssertions {
    /// Assert that a throwing closure throws a specific AppError with expected details
    static func assertThrows<T>(
        _ expectedError: AppError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ block: () throws -> T
    ) {
        do {
            _ = try block()
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard error == expectedError else {
                Issue.record("Expected \(expectedError), got \(error)")
                return
            }
        } catch {
            Issue.record("Expected AppError, got \(type(of: error)): \(error)")
        }
    }

    /// Assert that a throwing closure throws and verify error message contains expected string
    static func assertThrowsWithMessage<T>(
        containing expected: String,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ block: () throws -> T
    ) {
        do {
            _ = try block()
            Issue.record("Expected error to be thrown")
        } catch {
            let message = error.localizedDescription
            guard message.contains(expected) else {
                Issue.record("Expected error message to contain '\(expected)', got: '\(message)'")
                return
            }
        }
    }
}

