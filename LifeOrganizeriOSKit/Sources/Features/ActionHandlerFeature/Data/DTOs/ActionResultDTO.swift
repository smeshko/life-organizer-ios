import Foundation

/// Response DTO from POST /api/v1/process
public struct ActionResultDTO: Codable, Sendable {
    /// Whether the action was successful
    let success: Bool

    /// Type of action (backend_handled, app_action_required)
    let actionType: String

    /// Human-readable message about the result
    let message: String

    /// Optional app action (when action_type is app_action_required)
    let appAction: ActionDTO?

    enum CodingKeys: String, CodingKey {
        case success
        case actionType = "action_type"
        case message
        case appAction = "app_action"
    }
}

