import ComposableArchitecture

private enum ActionHandlerRepositoryKey: DependencyKey {
    static let liveValue: any ActionHandlerRepositoryProtocol = ActionHandlerRepository()
    static let testValue: any ActionHandlerRepositoryProtocol = MockActionHandlerRepository()
}

public extension DependencyValues {
    var actionHandlerRepository: any ActionHandlerRepositoryProtocol {
        get { self[ActionHandlerRepositoryKey.self] }
        set { self[ActionHandlerRepositoryKey.self] = newValue }
    }
}

