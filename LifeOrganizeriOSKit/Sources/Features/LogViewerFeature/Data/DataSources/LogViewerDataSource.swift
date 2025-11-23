import Entities
import Foundation
import Framework

public actor LogViewerDataSource {
    private let fileManager: FileManager
    private let decoder: JSONDecoder

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func listSessions() async throws -> [LogSession] {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AppError.persistence(.loadFailed("Documents directory not found"))
        }

        let logsURL = documentsURL.appendingPathComponent("activity-logs")

        guard fileManager.fileExists(atPath: logsURL.path) else {
            return []  // No logs yet
        }

        let files = try fileManager.contentsOfDirectory(at: logsURL, includingPropertiesForKeys: [.creationDateKey])
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }  // Reverse chronological

        var sessions: [LogSession] = []
        for fileURL in files {
            do {
                let data = try Data(contentsOf: fileURL)
                let session = try decoder.decode(LogSession.self, from: data)
                sessions.append(session)
            } catch {
                // Skip corrupted files
                print("Failed to decode session at \(fileURL): \(error)")
            }
        }

        return sessions
    }

    public func loadSession(id: UUID) async throws -> LogSession {
        let sessions = try await listSessions()
        guard let session = sessions.first(where: { $0.id == id }) else {
            throw AppError.persistence(.loadFailed("Session not found: \(id)"))
        }
        return session
    }
}
