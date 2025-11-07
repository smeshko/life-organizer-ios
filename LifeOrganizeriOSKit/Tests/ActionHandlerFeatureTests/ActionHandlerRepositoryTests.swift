import Testing
import Foundation
@testable import ActionHandlerFeature
@testable import Entities
@testable import Framework

@Suite("Action Handler Repository Tests")
struct ActionHandlerRepositoryTests {
    
    // Mock RemoteDataSource for testing
    actor MockRemoteDataSource: ActionHandlerRemoteDataSourceProtocol {
        var shouldThrowError = false
        var mockResponse: ActionResultDTO?
        
        init(shouldThrowError: Bool = false, mockResponse: ActionResultDTO? = nil) {
            self.shouldThrowError = shouldThrowError
            self.mockResponse = mockResponse
        }
        
        func processAction(input: String) async throws -> ActionResultDTO {
            if shouldThrowError {
                throw AppError.network(.noConnection)
            }
            
            if let response = mockResponse {
                return response
            }
            
            // Default mock response
            return ActionResultDTO(
                actionType: "app_action_required",
                action: ActionDTO(
                    type: "log_budget_entry",
                    data: BudgetActionDTO(
                        amount: 100.0,
                        date: "2025-11-05T12:00:00Z",
                        transactionType: "expense",
                        category: "Test",
                        details: nil
                    )
                ),
                message: "Test message"
            )
        }
    }
    
    @Test("Repository successfully processes action through remote data source")
    func repositoryProcessesActionSuccessfully() async throws {
        let mockDataSource = MockRemoteDataSource()
        let repository = ActionHandlerRepository(remoteDataSource: mockDataSource)
        
        let result = try await repository.processAction(input: "100eur for food")
        
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.action != nil)
        #expect(result.message == "Test message")
    }
    
    @Test("Repository transforms DTO to domain entity correctly")
    func repositoryTransformsDTOToEntity() async throws {
        let mockDataSource = MockRemoteDataSource()
        let repository = ActionHandlerRepository(remoteDataSource: mockDataSource)
        
        let result = try await repository.processAction(input: "test input")
        
        // Verify it's a proper ActionResult entity
        #expect(result.processingResultType != nil)
        
        // Verify nested action was properly mapped
        if let action = result.action {
            guard case .budget(let budgetAction) = action else {
                Issue.record("Expected budget action")
                return
            }
            
            #expect(budgetAction.amount == 100.0)
            #expect(budgetAction.category == "Test")
        }
    }
    
    @Test("Repository propagates network errors as AppError")
    func repositoryPropagatesNetworkErrors() async {
        let mockDataSource = MockRemoteDataSource(shouldThrowError: true)
        let repository = ActionHandlerRepository(remoteDataSource: mockDataSource)
        
        await #expect(throws: AppError.self) {
            try await repository.processAction(input: "test input")
        }
    }
    
    @Test("Repository handles clarification required response")
    func repositoryHandlesClarificationRequired() async throws {
        let mockResponse = ActionResultDTO(
            actionType: "clarification_required",
            action: nil,
            message: "Please provide more details"
        )
        
        let mockDataSource = MockRemoteDataSource(mockResponse: mockResponse)
        let repository = ActionHandlerRepository(remoteDataSource: mockDataSource)
        
        let result = try await repository.processAction(input: "unclear input")
        
        #expect(result.processingResultType == .clarificationRequired)
        #expect(result.action == nil)
        #expect(result.message == "Please provide more details")
    }
    
    @Test("Repository handles invalid message response")
    func repositoryHandlesInvalidMessage() async throws {
        let mockResponse = ActionResultDTO(
            actionType: "invalid_message",
            action: nil,
            message: "Invalid input format"
        )
        
        let mockDataSource = MockRemoteDataSource(mockResponse: mockResponse)
        let repository = ActionHandlerRepository(remoteDataSource: mockDataSource)
        
        let result = try await repository.processAction(input: "invalid")
        
        #expect(result.processingResultType == .invalidMessage)
        #expect(result.action == nil)
    }
    
    @Test("Repository handles income budget actions")
    func repositoryHandlesIncomeBudgetActions() async throws {
        let mockResponse = ActionResultDTO(
            actionType: "app_action_required",
            action: ActionDTO(
                type: "log_budget_entry",
                data: BudgetActionDTO(
                    amount: 5000.0,
                    date: "2025-11-05T12:00:00Z",
                    transactionType: "income",
                    category: "Salary",
                    details: "Monthly salary"
                )
            ),
            message: "Income logged"
        )
        
        let mockDataSource = MockRemoteDataSource(mockResponse: mockResponse)
        let repository = ActionHandlerRepository(remoteDataSource: mockDataSource)
        
        let result = try await repository.processAction(input: "5000eur salary")
        
        guard let action = result.action,
              case .budget(let budgetAction) = action else {
            Issue.record("Expected budget action")
            return
        }
        
        #expect(budgetAction.transactionType == .income)
        #expect(budgetAction.amount == 5000.0)
    }
    
    @Test("MockActionHandlerRepository returns configured result")
    func mockRepositoryReturnsConfiguredResult() async throws {
        let mockResult = ActionResult(
            processingResultType: .appActionRequired,
            action: .budget(BudgetAction(
                amount: 200.0,
                date: Date(),
                transactionType: .expense,
                category: "Mock",
                details: nil
            )),
            message: "Mock success"
        )
        
        let mockRepository = MockActionHandlerRepository(result: .success(mockResult))
        let result = try await mockRepository.processAction(input: "any input")
        
        #expect(result.processingResultType == .appActionRequired)
        #expect(result.message == "Mock success")
    }
    
    @Test("MockActionHandlerRepository throws configured error")
    func mockRepositoryThrowsConfiguredError() async {
        let mockError = AppError.network(.timeout)
        let mockRepository = MockActionHandlerRepository(result: .failure(mockError))
        
        await #expect(throws: AppError.self) {
            try await mockRepository.processAction(input: "any input")
        }
    }
    
    @Test("MockActionHandlerRepository simulates delay")
    func mockRepositorySimulatesDelay() async throws {
        let startTime = Date()
        let mockRepository = MockActionHandlerRepository()
        
        _ = try await mockRepository.processAction(input: "test")
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        // Should have at least some delay (50ms configured)
        #expect(elapsed > 0.04) // Allow some margin
    }
}

