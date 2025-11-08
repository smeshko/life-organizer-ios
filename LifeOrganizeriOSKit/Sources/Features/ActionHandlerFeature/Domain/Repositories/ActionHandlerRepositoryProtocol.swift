import Foundation

/// Repository for backend action processing
public protocol ActionHandlerRepositoryProtocol: Sendable {
    /// Process user input via backend API
    /// - Parameter input: Natural language input (voice transcription or text)
    /// - Returns: ProcessingResponse with action and message
    /// - Throws: AppError.network or AppError.actionHandler
    func processAction(input: String) async throws -> ProcessingResponse
}
