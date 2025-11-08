import Foundation
import Dependencies

/// Live repository implementation using NetworkService
public struct ActionHandlerRepository: ActionHandlerRepositoryProtocol {
    @Dependency(\.networkService) var networkService
    let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func processAction(input: String) async throws -> ProcessingResponse {
        // Create request DTO
        let requestDTO = ProcessActionRequestDTO(input: input)

        // Create endpoint
        let endpoint = ProcessActionEndpoint(baseURL: baseURL, request: requestDTO)

        // Call network service (returns DTO)
        let responseDTO: ProcessingResponseDTO = try await networkService.sendRequest(to: endpoint)

        // Map DTO to entity
        let response = try ProcessingResponseMapper.toDomain(responseDTO)

        return response
    }
}
