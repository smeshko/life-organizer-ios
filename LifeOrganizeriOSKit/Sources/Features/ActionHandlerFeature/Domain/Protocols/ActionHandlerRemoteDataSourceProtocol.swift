import Foundation

/// Protocol for action handler remote data source
public protocol ActionHandlerRemoteDataSourceProtocol: Sendable {
    /// Sends user input to backend for processing
    /// - Parameter input: Natural language user input
    /// - Returns: ActionResultDTO from backend
    /// - Throws: AppError if network or parsing fails
    func processAction(input: String) async throws -> ActionResultDTO
}

