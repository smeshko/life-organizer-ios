import Foundation

/// Request DTO for POST /api/v1/process
public struct ProcessActionRequestDTO: Codable, Sendable {
    let input: String
    
    enum CodingKeys: String, CodingKey {
        case input
    }
    
    public init(input: String) {
        self.input = input
    }
}

