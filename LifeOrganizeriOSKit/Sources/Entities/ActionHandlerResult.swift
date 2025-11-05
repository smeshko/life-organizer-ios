import Foundation

/// Result of action handler execution
public struct ActionHandlerResult: Sendable, Equatable {
    public let success: Bool
    public let message: String
    
    public init(success: Bool, message: String) {
        self.success = success
        self.message = message
    }
}

