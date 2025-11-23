import Foundation
import Entities

/// Service protocol for persisting activity log sessions to the file system.
public protocol LoggingServiceProtocol: Sendable {
    /// Saves a log session to a timestamped JSON file in the activity-logs directory.
    ///
    /// - Parameter session: The log session to persist
    /// - Throws: `AppError.persistence(.saveFailed)` if file write fails
    func saveSession(_ session: LogSession) async throws

    /// Ensures the activity-logs directory exists in the documents directory.
    ///
    /// - Returns: URL of the activity-logs directory
    /// - Throws: `AppError.persistence(.saveFailed)` if directory creation fails
    func ensureLogDirectory() async throws -> URL
}
