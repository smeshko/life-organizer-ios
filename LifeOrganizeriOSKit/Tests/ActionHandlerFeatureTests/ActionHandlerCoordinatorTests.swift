import Testing
import Foundation
@testable import ActionHandlerFeature
@testable import Entities
@testable import Framework

@Suite("Action Handler Coordinator Tests")
struct ActionHandlerCoordinatorTests {
    
    @Test("Coordinator routes budget action to budget handler")
    func coordinatorRoutesBudgetAction() async throws {
        let coordinator = ActionHandlerCoordinator()
        
        let budgetAction = BudgetAction(
            amount: 150.0,
            date: Date(),
            transactionType: .expense,
            category: "Transport",
            details: "Taxi ride"
        )
        
        let action = Action.budget(budgetAction)
        let result = try await coordinator.route(action)
        
        #expect(result.success == true)
        #expect(result.message.contains("150.0"))
    }
    
    @Test("Coordinator propagates validation errors from handler")
    func coordinatorPropagatesValidationErrors() async {
        let coordinator = ActionHandlerCoordinator()
        
        let invalidBudgetAction = BudgetAction(
            amount: -100.0, // Invalid: negative amount
            date: Date(),
            transactionType: .expense,
            category: "Test",
            details: nil
        )
        
        let action = Action.budget(invalidBudgetAction)
        
        await #expect(throws: AppError.self) {
            try await coordinator.route(action)
        }
    }
    
    @Test("Coordinator handles income budget actions")
    func coordinatorHandlesIncomeActions() async throws {
        let coordinator = ActionHandlerCoordinator()
        
        let incomeAction = BudgetAction(
            amount: 3000.0,
            date: Date(),
            transactionType: .income,
            category: "Freelance",
            details: "Project payment"
        )
        
        let action = Action.budget(incomeAction)
        let result = try await coordinator.route(action)
        
        #expect(result.success == true)
        #expect(result.message.contains("income"))
    }
    
    @Test("Coordinator can be initialized with default handlers")
    func coordinatorInitializesWithDefaults() async throws {
        let coordinator = ActionHandlerCoordinator()
        
        let budgetAction = BudgetAction(
            amount: 50.0,
            date: Date(),
            transactionType: .expense,
            category: "Coffee",
            details: nil
        )
        
        let action = Action.budget(budgetAction)
        let result = try await coordinator.route(action)
        
        #expect(result.success == true)
    }
    
    @Test("Coordinator handles multiple sequential actions")
    func coordinatorHandlesMultipleActions() async throws {
        let coordinator = ActionHandlerCoordinator()
        
        // First action
        let action1 = Action.budget(BudgetAction(
            amount: 100.0,
            date: Date(),
            transactionType: .expense,
            category: "Food",
            details: nil
        ))
        
        let result1 = try await coordinator.route(action1)
        #expect(result1.success == true)
        
        // Second action
        let action2 = Action.budget(BudgetAction(
            amount: 200.0,
            date: Date(),
            transactionType: .income,
            category: "Salary",
            details: nil
        ))
        
        let result2 = try await coordinator.route(action2)
        #expect(result2.success == true)
    }
    
    @Test("Coordinator respects actor isolation for concurrent access")
    func coordinatorHandlesConcurrentAccess() async throws {
        let coordinator = ActionHandlerCoordinator()
        
        // Create multiple actions
        let actions = (0..<5).map { index in
            Action.budget(BudgetAction(
                amount: Double(index + 1) * 10.0,
                date: Date(),
                transactionType: .expense,
                category: "Test \(index)",
                details: nil
            ))
        }
        
        // Process concurrently
        await withTaskGroup(of: Bool.self) { group in
            for action in actions {
                group.addTask {
                    do {
                        let result = try await coordinator.route(action)
                        return result.success
                    } catch {
                        return false
                    }
                }
            }
            
            // Verify all succeeded
            for await success in group {
                #expect(success == true)
            }
        }
    }
}

