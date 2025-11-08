import Foundation
import Dependencies
import Entities
import NetworkService
import Framework

actor ActionHandlerRemoteDataSource: ActionHandlerRemoteDataSourceProtocol {
    @Dependency(\.networkService) private var networkService

    init() {}

    func processAction(input: String) async throws -> ProcessingResponse {
        // Create request DTO
        let requestDTO = ProcessActionRequestDTO(input: input)

        // Encode DTO to Data
        let encoder = JSONEncoder()
        let requestData = try encoder.encode(requestDTO)

        // Call network service with endpoint
        let responseDTO: ProcessingResponseDTO = try await networkService.sendRequest(
            to: ActionHandlerEndpoint.processAction(requestData)
        )

        // Map DTO to entity
        let response = try ProcessingResponseMapper.toDomain(responseDTO)

        return response
    }
}

// MARK: - Dependency Key
struct ActionHandlerRemoteDataSourceKey: DependencyKey {
    static let liveValue: any ActionHandlerRemoteDataSourceProtocol = ActionHandlerRemoteDataSource()
    static let testValue: any ActionHandlerRemoteDataSourceProtocol = MockActionHandlerRemoteDataSource()
    static let previewValue: any ActionHandlerRemoteDataSourceProtocol = MockActionHandlerRemoteDataSource()
}

extension DependencyValues {
    var actionHandlerRemoteDataSource: any ActionHandlerRemoteDataSourceProtocol {
        get { self[ActionHandlerRemoteDataSourceKey.self] }
        set { self[ActionHandlerRemoteDataSourceKey.self] = newValue }
    }
}
