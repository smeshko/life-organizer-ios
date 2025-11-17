import Foundation
import Dependencies
import Entities
import ClassifierService

actor ActionHandlerRepository: ActionHandlerRepositoryProtocol {
    @Dependency(\.actionHandlerRemoteDataSource) private var remoteDataSource

    func processAction(input: String, category: TextCategory) async throws -> [ProcessingResponse] {
        try await remoteDataSource.processAction(input: input, category: category.rawValue.lowercased())
    }
}

// MARK: - Dependency Key
struct ActionHandlerRepositoryKey: DependencyKey {
    static let liveValue: any ActionHandlerRepositoryProtocol = ActionHandlerRepository()
    static let testValue: any ActionHandlerRepositoryProtocol = MockActionHandlerRepository()
    static let previewValue: any ActionHandlerRepositoryProtocol = MockActionHandlerRepository()
}

extension DependencyValues {
    var actionHandlerRepository: any ActionHandlerRepositoryProtocol {
        get { self[ActionHandlerRepositoryKey.self] }
        set { self[ActionHandlerRepositoryKey.self] = newValue }
    }
}
