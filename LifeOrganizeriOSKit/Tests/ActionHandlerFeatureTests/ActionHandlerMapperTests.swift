import Testing
import Foundation
@testable import ActionHandlerFeature
@testable import Entities
@testable import Framework

@Suite("Action Handler Mapper Tests")
struct ActionHandlerMapperTests {
    
    // MARK: - BudgetActionMapper Tests
    
    @Test("BudgetActionMapper converts valid DTO to entity")
    func budgetActionMapperConvertsValidDTO() throws {
        let dto = BudgetActionDTO(
            amount: 234.6,
            date: "2025-11-05T12:00:00Z",
            transactionType: "expense",
            category: "Clothes",
            details: "Shopping"
        )
        
        let result = try BudgetActionMapper.toDomain(dto)
        
        #expect(result.amount == 234.6)
        #expect(result.transactionType == .expense)
        #expect(result.category == "Clothes")
        #expect(result.details == "Shopping")
        #expect(result.date != nil)
    }
    
    @Test("BudgetActionMapper handles income transaction type")
    func budgetActionMapperHandlesIncomeType() throws {
        let dto = BudgetActionDTO(
            amount: 1000.0,
            date: "2025-11-05T12:00:00Z",
            transactionType: "income",
            category: "Salary",
            details: nil
        )
        
        let result = try BudgetActionMapper.toDomain(dto)
        
        #expect(result.transactionType == .income)
        #expect(result.category == "Salary")
        #expect(result.details == nil)
    }
    
    @Test("BudgetActionMapper throws error for invalid date format")
    func budgetActionMapperThrowsErrorForInvalidDate() {
        let dto = BudgetActionDTO(
            amount: 100.0,
            date: "invalid-date",
            transactionType: "expense",
            category: "Test",
            details: nil
        )
        
        #expect(throws: AppError.self) {
            try BudgetActionMapper.toDomain(dto)
        }
    }
    
    @Test("BudgetActionMapper throws error for invalid transaction type")
    func budgetActionMapperThrowsErrorForInvalidTransactionType() {
        let dto = BudgetActionDTO(
            amount: 100.0,
            date: "2025-11-05T12:00:00Z",
            transactionType: "invalid_type",
            category: "Test",
            details: nil
        )
        
        #expect(throws: AppError.self) {
            try BudgetActionMapper.toDomain(dto)
        }
    }
    
    @Test("BudgetActionMapper throws error for negative amount")
    func budgetActionMapperThrowsErrorForNegativeAmount() {
        let dto = BudgetActionDTO(
            amount: -50.0,
            date: "2025-11-05T12:00:00Z",
            transactionType: "expense",
            category: "Test",
            details: nil
        )
        
        #expect(throws: AppError.self) {
            try BudgetActionMapper.toDomain(dto)
        }
    }
    
    @Test("BudgetActionMapper throws error for zero amount")
    func budgetActionMapperThrowsErrorForZeroAmount() {
        let dto = BudgetActionDTO(
            amount: 0.0,
            date: "2025-11-05T12:00:00Z",
            transactionType: "expense",
            category: "Test",
            details: nil
        )
        
        #expect(throws: AppError.self) {
            try BudgetActionMapper.toDomain(dto)
        }
    }
    
    // MARK: - ActionMapper Tests
    
    @Test("ActionMapper converts budget action DTO to Action.budget")
    func actionMapperConvertsBudgetAction() throws {
        let budgetDTO = BudgetActionDTO(
            amount: 100.0,
            date: "2025-11-05T12:00:00Z",
            transactionType: "expense",
            category: "Food",
            details: nil
        )
        
        let actionDTO = ActionDTO(
            type: "log_budget_entry",
            data: budgetDTO
        )
        
        let result = try ActionMapper.toDomain(actionDTO)
        
        guard case .budget(let budgetAction) = result else {
            Issue.record("Expected Action.budget, got different case")
            return
        }
        
        #expect(budgetAction.amount == 100.0)
        #expect(budgetAction.category == "Food")
    }
    
    @Test("ActionMapper throws error for unknown action type")
    func actionMapperThrowsErrorForUnknownType() {
        let actionDTO = ActionDTO(
            type: "unknown_action_type",
            data: nil
        )
        
        #expect(throws: AppError.self) {
            try ActionMapper.toDomain(actionDTO)
        }
    }
    
    @Test("ActionMapper throws error for missing budget data")
    func actionMapperThrowsErrorForMissingBudgetData() {
        let actionDTO = ActionDTO(
            type: "log_budget_entry",
            data: nil
        )
        
        #expect(throws: AppError.self) {
            try ActionMapper.toDomain(actionDTO)
        }
    }
    
    // MARK: - ActionResultMapper Tests
    
    @Test("ActionResultMapper converts complete result DTO")
    func actionResultMapperConvertsCompleteDTO() throws {
        let budgetDTO = BudgetActionDTO(
            amount: 150.0,
            date: "2025-11-05T12:00:00Z",
            transactionType: "expense",
            category: "Transport",
            details: "Taxi"
        )
        
        let actionDTO = ActionDTO(
            type: "log_budget_entry",
            data: budgetDTO
        )
        
        let resultDTO = ActionResultDTO(
            actionType: "app_action_required",
            action: actionDTO,
            message: "Budget entry logged"
        )
        
        let result = try ActionResultMapper.toDomain(resultDTO)
        
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.action != nil)
        #expect(result.message == "Budget entry logged")
    }
    
    @Test("ActionResultMapper handles nil action")
    func actionResultMapperHandlesNilAction() throws {
        let resultDTO = ActionResultDTO(
            actionType: "clarification_required",
            action: nil,
            message: "Please provide more details"
        )
        
        let result = try ActionResultMapper.toDomain(resultDTO)
        
        #expect(result.processingResultType == .clarificationRequired)
        #expect(result.action == nil)
        #expect(result.message == "Please provide more details")
    }
    
    @Test("ActionResultMapper throws error for unknown processing result type")
    func actionResultMapperThrowsErrorForUnknownType() {
        let resultDTO = ActionResultDTO(
            actionType: "unknown_type",
            action: nil,
            message: "Test"
        )
        
        #expect(throws: AppError.self) {
            try ActionResultMapper.toDomain(resultDTO)
        }
    }
    
    @Test("ActionResultMapper handles invalid message result")
    func actionResultMapperHandlesInvalidMessageResult() throws {
        let resultDTO = ActionResultDTO(
            actionType: "invalid_message",
            action: nil,
            message: "Invalid input format"
        )
        
        let result = try ActionResultMapper.toDomain(resultDTO)
        
        #expect(result.processingResultType == .invalidMessage)
        #expect(result.action == nil)
    }
}

