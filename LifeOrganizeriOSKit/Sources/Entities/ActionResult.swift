import Foundation

/// Backend response wrapper for action processing
public struct ActionResult: Sendable, Equatable {
    public let processingResultType: ProcessingResultType
    public let action: Action?
    public let message: String
    
    public init(
        processingResultType: ProcessingResultType,
        action: Action? = nil,
        message: String
    ) {
        self.processingResultType = processingResultType
        self.action = action
        self.message = message
    }
}

