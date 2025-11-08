import Dependencies
import Foundation

private enum ActionHandlerRepositoryKey: DependencyKey {
    static let liveValue: any ActionHandlerRepositoryProtocol = {
        // TODO: Get baseURL from configuration
        let baseURL = URL(string: "http://localhost:8000")!
        return ActionHandlerRepository(baseURL: baseURL)
    }()

    static let testValue: any ActionHandlerRepositoryProtocol = MockActionHandlerRepository()
}

public extension DependencyValues {
    var actionHandlerRepository: any ActionHandlerRepositoryProtocol {
        get { self[ActionHandlerRepositoryKey.self] }
        set { self[ActionHandlerRepositoryKey.self] = newValue }
    }
}
