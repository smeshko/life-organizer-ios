import Foundation

/// Discriminator for backend processing result types
public enum ProcessingResultType: String, Sendable, Equatable, Codable {
    case appActionRequired = "app_action_required"
    case backendHandled = "backend_handled"
    case error = "error"
}
