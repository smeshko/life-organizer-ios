import Foundation

/// Protocol for checking backend API status
public protocol StatusCheckRepositoryProtocol: Sendable {
    /// Check the backend API status
    /// - Returns: StatusResponseDTO with API version and available endpoints
    /// - Throws: Network errors if connection fails
    func checkStatus() async throws -> StatusResponseDTO
}
