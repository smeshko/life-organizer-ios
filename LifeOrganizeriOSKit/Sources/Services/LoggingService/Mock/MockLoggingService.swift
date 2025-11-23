import Foundation
import Entities
import Framework

/// Mock implementation of LoggingService for testing.
public struct MockLoggingService: LoggingServiceProtocol, Sendable {
    public let shouldSimulateError: Bool
    public let simulatedError: Error?

    public init(
        shouldSimulateError: Bool = false,
        simulatedError: Error? = nil
    ) {
        self.shouldSimulateError = shouldSimulateError
        self.simulatedError = simulatedError
    }

    public func saveSession(_ session: LogSession) async throws {
        if shouldSimulateError {
            throw simulatedError ?? AppError.persistence(.saveFailed("Mock save failure"))
        }
        // Success - no-op in mock
    }

    public func ensureLogDirectory() async throws -> URL {
        if shouldSimulateError {
            throw simulatedError ?? AppError.persistence(.saveFailed("Mock directory failure"))
        }
        return URL(fileURLWithPath: "/tmp/activity-logs")
    }
}
