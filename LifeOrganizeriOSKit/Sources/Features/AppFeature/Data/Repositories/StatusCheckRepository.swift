import Foundation
import NetworkService

/// Repository for checking backend API status
public struct StatusCheckRepository: StatusCheckRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func checkStatus() async throws -> StatusResponseDTO {
        try await networkService.sendRequest(to: AppEndpoint.status)
    }
}
