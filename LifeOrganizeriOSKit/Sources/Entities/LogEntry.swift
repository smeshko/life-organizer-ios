import Foundation

/// Log level for activity logging
public enum LogLevel: String, Codable, Sendable, Equatable {
    case info
    case success
    case error
    case separator
}

/// Represents a single log entry in the activity log
public struct LogEntry: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let level: LogLevel
    public let source: String
    public let message: String
    public let responseData: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        level: LogLevel,
        source: String,
        message: String,
        responseData: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.source = source
        self.message = message
        self.responseData = responseData
    }
}
