import Foundation
import Framework
import NetworkService
import ComposableArchitecture
import Dependencies

/// Remote data source for action handler operations
public struct ActionHandlerRemoteDataSource: ActionHandlerRemoteDataSourceProtocol {
    @Dependency(\.networkService) var networkService
    
    public init() {}
    
    public func processAction(input: String) async throws -> ActionResultDTO {
        let request = ProcessActionRequestDTO(input: input)

        // Encode the request to Data
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)

        let endpoint = ActionHandlerEndpoints.processAction(data)

        let response: ActionResultDTO = try await networkService.sendRequest(to: endpoint)
        return response
    }
}

