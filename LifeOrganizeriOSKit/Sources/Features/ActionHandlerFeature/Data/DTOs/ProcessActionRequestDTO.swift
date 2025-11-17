import Foundation

/// Request DTO for POST /api/v1/process
public struct ProcessActionRequestDTO: Codable, Sendable {
    public let input: String
    public let category: String?

    public init(input: String, category: String? = nil) {
        self.input = input
        self.category = category
    }
}
