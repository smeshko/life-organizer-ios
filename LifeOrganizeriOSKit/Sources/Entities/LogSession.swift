import Foundation

/// Represents a complete activity log session
public struct LogSession: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let entries: [LogEntry]
    public let metadata: SessionMetadata

    public struct SessionMetadata: Equatable, Codable, Sendable {
        public let requestType: String
        public let entryCount: Int
        public let userInput: String?

        public init(requestType: String, entryCount: Int, userInput: String? = nil) {
            self.requestType = requestType
            self.entryCount = entryCount
            self.userInput = userInput
        }
    }

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        entries: [LogEntry],
        requestType: String,
        userInput: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.entries = entries
        self.metadata = SessionMetadata(
            requestType: requestType,
            entryCount: entries.count,
            userInput: userInput
        )
    }
}
