import Entities
import Foundation

public protocol LogViewerRepositoryProtocol: Sendable {
    func listSessions() async throws -> [LogSession]
    func loadSession(id: UUID) async throws -> LogSession
}
