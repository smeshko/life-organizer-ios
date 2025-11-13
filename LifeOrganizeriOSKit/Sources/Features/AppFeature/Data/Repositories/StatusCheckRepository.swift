import Foundation
import NetworkService
import Dependencies

/// Repository for checking backend API status
public struct StatusCheckRepository: StatusCheckRepositoryProtocol {
    @Dependency(\.networkService) var networkService

    public init() {}

    public func checkStatus() async throws -> StatusResponseDTO {
        try await networkService.sendRequest(to: AppEndpoint.status)
    }
}
