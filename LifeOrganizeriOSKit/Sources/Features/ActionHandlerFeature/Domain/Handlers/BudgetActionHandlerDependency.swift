import ComposableArchitecture

private enum BudgetActionHandlerKey: DependencyKey {
    static let liveValue: any BudgetActionHandlerProtocol = BudgetActionHandler()
    static let testValue: any BudgetActionHandlerProtocol = BudgetActionHandler()
}

public extension DependencyValues {
    var budgetActionHandler: any BudgetActionHandlerProtocol {
        get { self[BudgetActionHandlerKey.self] }
        set { self[BudgetActionHandlerKey.self] = newValue }
    }
}
