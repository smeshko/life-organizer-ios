import Foundation

/// DTO for /api/v1/status endpoint response
/// Matches the OpenAPI spec for backend status information
public struct StatusResponseDTO: Codable, Sendable {
    public let apiVersion: String
    public let debug: Bool
    public let endpoints: StatusEndpoints

    enum CodingKeys: String, CodingKey {
        case apiVersion = "api_version"
        case debug
        case endpoints
    }
}

/// Available endpoints returned by status endpoint
public struct StatusEndpoints: Codable, Sendable {
    public let health: String
    public let docs: String
}
