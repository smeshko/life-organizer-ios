import Foundation

/// Response DTO from POST /api/v1/process
public struct ActionResultDTO: Codable, Sendable {
    let actionType: String
    let action: ActionDTO?
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case actionType = "action_type"
        case action
        case message
    }
}

