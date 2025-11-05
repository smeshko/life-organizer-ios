import Foundation
import Entities
import Framework
import ComposableArchitecture

/// Repository for action handler operations
/// Orchestrates data access and transforms DTOs to domain entities
public struct ActionHandlerRepository: ActionHandlerRepositoryProtocol {
    private let remoteDataSource: any ActionHandlerRemoteDataSourceProtocol
    
    public init(remoteDataSource: any ActionHandlerRemoteDataSourceProtocol = ActionHandlerRemoteDataSource()) {
        self.remoteDataSource = remoteDataSource
    }
    
    public func processAction(input: String) async throws -> ActionResult {
        do {
            // Fetch DTO from remote
            let resultDTO = try await remoteDataSource.processAction(input: input)
            
            // Transform DTO to domain entity
            let result = try ActionResultMapper.toDomain(resultDTO)
            
            return result
        } catch let error as AppError {
            // Already an AppError (from network or mapper)
            throw error
        } catch {
            // Wrap unexpected errors
            throw AppError.actionHandler(.executionFailed(error.localizedDescription))
        }
    }
}

