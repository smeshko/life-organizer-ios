import Testing
import Foundation
@testable import ActionHandlerFeature
@testable import Entities
@testable import Framework

@Suite("Budget Action Handler Tests")
struct BudgetActionHandlerTests {
    
    @Test("Handler validates and processes valid budget action")
    func handlerProcessesValidAction() async throws {
        let handler = BudgetActionHandler()
        
        let action = BudgetAction(
            amount: 100.0,
            date: Date(),
            transactionType: .expense,
            category: "Food",
            details: "Lunch"
        )
        
        let result = try await handler.handle(action)
        
        #expect(result.success == true)
        #expect(result.message.contains("100.0"))
        #expect(result.message.contains("expense"))
    }
    
    @Test("Handler rejects negative amount")
    func handlerRejectsNegativeAmount() async {
        let handler = BudgetActionHandler()
        
        let action = BudgetAction(
            amount: -50.0,
            date: Date(),
            transactionType: .expense,
            category: "Test",
            details: nil
        )
        
        await #expect(throws: AppError.self) {
            try await handler.handle(action)
        }
    }
    
    @Test("Handler rejects zero amount")
    func handlerRejectsZeroAmount() async {
        let handler = BudgetActionHandler()
        
        let action = BudgetAction(
            amount: 0.0,
            date: Date(),
            transactionType: .expense,
            category: "Test",
            details: nil
        )
        
        await #expect(throws: AppError.self) {
            try await handler.handle(action)
        }
    }
    
    @Test("Handler rejects future date")
    func handlerRejectsFutureDate() async {
        let handler = BudgetActionHandler()
        
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow
        let action = BudgetAction(
            amount: 100.0,
            date: futureDate,
            transactionType: .expense,
            category: "Test",
            details: nil
        )
        
        await #expect(throws: AppError.self) {
            try await handler.handle(action)
        }
    }
    
    @Test("Handler rejects empty category string")
    func handlerRejectsEmptyCategory() async {
        let handler = BudgetActionHandler()
        
        let action = BudgetAction(
            amount: 100.0,
            date: Date(),
            transactionType: .expense,
            category: "   ",
            details: nil
        )
        
        await #expect(throws: AppError.self) {
            try await handler.handle(action)
        }
    }
    
    @Test("Handler accepts nil category")
    func handlerAcceptsNilCategory() async throws {
        let handler = BudgetActionHandler()
        
        let action = BudgetAction(
            amount: 100.0,
            date: Date(),
            transactionType: .expense,
            category: nil,
            details: nil
        )
        
        let result = try await handler.handle(action)
        
        #expect(result.success == true)
    }
    
    @Test("Handler accepts valid category")
    func handlerAcceptsValidCategory() async throws {
        let handler = BudgetActionHandler()
        
        let action = BudgetAction(
            amount: 100.0,
            date: Date(),
            transactionType: .expense,
            category: "Food",
            details: nil
        )
        
        let result = try await handler.handle(action)
        
        #expect(result.success == true)
    }
    
    @Test("Handler processes income transaction type")
    func handlerProcessesIncomeType() async throws {
        let handler = BudgetActionHandler()
        
        let action = BudgetAction(
            amount: 5000.0,
            date: Date(),
            transactionType: .income,
            category: "Salary",
            details: "Monthly salary"
        )
        
        let result = try await handler.handle(action)
        
        #expect(result.success == true)
        #expect(result.message.contains("income"))
    }
    
    @Test("Handler accepts past date")
    func handlerAcceptsPastDate() async throws {
        let handler = BudgetActionHandler()
        
        let pastDate = Date().addingTimeInterval(-86400) // Yesterday
        let action = BudgetAction(
            amount: 100.0,
            date: pastDate,
            transactionType: .expense,
            category: "Test",
            details: nil
        )
        
        let result = try await handler.handle(action)
        
        #expect(result.success == true)
    }
    
    @Test("Handler accepts current date")
    func handlerAcceptsCurrentDate() async throws {
        let handler = BudgetActionHandler()
        
        let action = BudgetAction(
            amount: 100.0,
            date: Date(),
            transactionType: .expense,
            category: "Test",
            details: nil
        )
        
        let result = try await handler.handle(action)
        
        #expect(result.success == true)
    }
    
    @Test("Handler preserves all action details in validation")
    func handlerPreservesActionDetails() async throws {
        let handler = BudgetActionHandler()
        
        let action = BudgetAction(
            amount: 234.56,
            date: Date(),
            transactionType: .expense,
            category: "Shopping",
            details: "Bought groceries at Whole Foods"
        )
        
        let result = try await handler.handle(action)
        
        #expect(result.success == true)
        #expect(result.message.contains("234.56"))
    }
}

