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
        let endpoint = ActionHandlerEndpoints.processAction(request)
        
        let response: ActionResultDTO = try await networkService.sendRequest(to: endpoint)
        return response
    }
}

