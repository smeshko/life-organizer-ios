import Foundation
import Entities
import Framework

/// Live implementation of LoggingService using FileManager for persistence.
public actor LoggingService: LoggingServiceProtocol {
    private let fileManager: FileManager
    private let encoder: JSONEncoder

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = .prettyPrinted
    }

    public func ensureLogDirectory() async throws -> URL {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AppError.persistence(.saveFailed("Documents directory not found"))
        }

        let logsURL = documentsURL.appendingPathComponent("activity-logs")

        if !fileManager.fileExists(atPath: logsURL.path) {
            try fileManager.createDirectory(at: logsURL, withIntermediateDirectories: true)
        }

        return logsURL
    }

    public func saveSession(_ session: LogSession) async throws {
        let logsDirectory = try await ensureLogDirectory()

        // Format: YYYY-MM-DD_HH-mm-ss-SSS.json
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss-SSS"
        let filename = "\(formatter.string(from: session.timestamp)).json"

        let fileURL = logsDirectory.appendingPathComponent(filename)

        do {
            let data = try encoder.encode(session)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw AppError.persistence(.saveFailed("Failed to write log session: \(error.localizedDescription)"))
        }
    }
}
