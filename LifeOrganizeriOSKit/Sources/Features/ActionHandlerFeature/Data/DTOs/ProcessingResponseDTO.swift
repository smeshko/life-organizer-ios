import Foundation

/// Response DTO for POST /api/v1/process
public struct ProcessingResponseDTO: Codable, Sendable {
    public let success: Bool
    public let actionType: String      // Backend "action_type" → Swift "actionType"
    public let appAction: ActionDTO?   // Backend "app_action" → Swift "appAction" (polymorphic)
    public let message: String

    public init(
        success: Bool,
        actionType: String,
        appAction: ActionDTO? = nil,
        message: String
    ) {
        self.success = success
        self.actionType = actionType
        self.appAction = appAction
        self.message = message
    }

    // No CodingKeys needed - decoder handles conversion automatically
}
