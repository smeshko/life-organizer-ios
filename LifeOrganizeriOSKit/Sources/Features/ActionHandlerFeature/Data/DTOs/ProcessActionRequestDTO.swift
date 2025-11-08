import Foundation

/// Request DTO for POST /api/v1/process
public struct ProcessActionRequestDTO: Codable, Sendable {
    public let input: String

    public init(input: String) {
        self.input = input
    }
}
