import Entities
import Foundation
import Framework

public actor MockLogViewerRepository: LogViewerRepositoryProtocol {
    private var mockSessions: [LogSession]
    private var shouldThrowError: Bool

    public init(mockSessions: [LogSession] = [], shouldThrowError: Bool = false) {
        self.mockSessions = mockSessions
        self.shouldThrowError = shouldThrowError
    }

    public func listSessions() async throws -> [LogSession] {
        if shouldThrowError {
            throw AppError.persistence(.loadFailed("Mock error"))
        }
        return mockSessions.sorted { $0.timestamp > $1.timestamp }
    }

    public func loadSession(id: UUID) async throws -> LogSession {
        if shouldThrowError {
            throw AppError.persistence(.loadFailed("Mock error"))
        }
        guard let session = mockSessions.first(where: { $0.id == id }) else {
            throw AppError.persistence(.loadFailed("Session not found: \(id)"))
        }
        return session
    }

    // Test helper methods
    public func setMockSessions(_ sessions: [LogSession]) {
        self.mockSessions = sessions
    }

    public func setShouldThrowError(_ shouldThrow: Bool) {
        self.shouldThrowError = shouldThrow
    }
}
