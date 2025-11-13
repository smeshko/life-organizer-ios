import Foundation

/// DTO for /api/v1/status endpoint response
/// Matches the OpenAPI spec for backend status information
/// NetworkService uses convertFromSnakeCase, so no custom CodingKeys needed
public struct StatusResponseDTO: Codable, Sendable {
    public let apiVersion: String
    public let debug: Bool
    public let endpoints: StatusEndpoints
}

/// Available endpoints returned by status endpoint
public struct StatusEndpoints: Codable, Sendable {
    public let health: String
    public let docs: String
}
