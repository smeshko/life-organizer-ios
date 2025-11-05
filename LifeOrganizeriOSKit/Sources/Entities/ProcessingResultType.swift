import Foundation

/// Discriminator enum for backend processing results
public enum ProcessingResultType: String, Sendable, Equatable, Codable {
    case appActionRequired = "app_action_required"
    case backendHandled = "backend_handled"
    case error = "error"
}

