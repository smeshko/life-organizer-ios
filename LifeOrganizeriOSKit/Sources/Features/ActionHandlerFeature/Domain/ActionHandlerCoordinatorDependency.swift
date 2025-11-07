import ComposableArchitecture

private enum ActionHandlerCoordinatorKey: DependencyKey {
    static let liveValue: any ActionHandlerCoordinatorProtocol = ActionHandlerCoordinator()
    static let testValue: any ActionHandlerCoordinatorProtocol = ActionHandlerCoordinator()
}

public extension DependencyValues {
    var actionHandlerCoordinator: any ActionHandlerCoordinatorProtocol {
        get { self[ActionHandlerCoordinatorKey.self] }
        set { self[ActionHandlerCoordinatorKey.self] = newValue }
    }
}
