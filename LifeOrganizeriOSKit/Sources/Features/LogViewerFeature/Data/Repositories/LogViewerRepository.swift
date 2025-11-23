import Dependencies
import Entities
import Foundation

public actor LogViewerRepository: LogViewerRepositoryProtocol {
    private let dataSource: LogViewerDataSource

    public init(dataSource: LogViewerDataSource = LogViewerDataSource()) {
        self.dataSource = dataSource
    }

    public func listSessions() async throws -> [LogSession] {
        try await dataSource.listSessions()
    }

    public func loadSession(id: UUID) async throws -> LogSession {
        try await dataSource.loadSession(id: id)
    }
}

// TCA Dependency Registration
extension LogViewerRepository: DependencyKey {
    public static let liveValue: LogViewerRepositoryProtocol = LogViewerRepository()
}

extension DependencyValues {
    public var logViewerRepository: LogViewerRepositoryProtocol {
        get { self[LogViewerRepository.self] }
        set { self[LogViewerRepository.self] = newValue }
    }
}
