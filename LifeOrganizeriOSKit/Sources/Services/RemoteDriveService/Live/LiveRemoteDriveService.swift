import Foundation
import Framework

public struct LiveRemoteDriveService: RemoteDriveServiceProtocol, Sendable {
    private let fileManager: any FileManagerProtocol
    private let containerIdentifier: String?

    public init(
        fileManager: any FileManagerProtocol = FileManager.default,
        containerIdentifier: String? = nil
    ) {
        self.fileManager = fileManager
        self.containerIdentifier = containerIdentifier
    }

    // MARK: - Public API

    public func isAvailable() async -> Bool {
        do {
            _ = try await getContainerURL()
            return true
        } catch {
            return false
        }
    }

    public func downloadFile(at path: String) async throws -> URL {
        // Validate path
        try validatePath(path)

        // Get container URL
        let containerURL = try await getContainerURL()

        // Construct full iCloud URL
        let cloudURL = containerURL.appendingPathComponent(path)

        // Read file using coordinated access
        let data = try await coordinatedRead(at: cloudURL)

        // Save to temp directory with UUID naming
        let tempDirectory = fileManager.temporaryDirectory
        let tempFileName = UUID().uuidString + "-" + (path as NSString).lastPathComponent
        let tempURL = tempDirectory.appendingPathComponent(tempFileName)

        try data.write(to: tempURL)

        return tempURL
    }

    public func uploadFile(from localURL: URL, to cloudPath: String) async throws {
        // Validate cloudPath
        try validatePath(cloudPath)

        // Verify local file exists
        guard fileManager.fileExists(atPath: localURL.path) else {
            throw AppError.remoteDriveSync(.fileNotFound("Local file not found"))
        }

        // Get container URL
        let containerURL = try await getContainerURL()

        // Construct full iCloud URL
        let cloudURL = containerURL.appendingPathComponent(cloudPath)

        // Upload using coordinated write
        try await coordinatedWrite(from: localURL, to: cloudURL)
    }

    public func downloadFileWithProgress(at path: String) -> AsyncThrowingStream<DownloadProgress, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    try validatePath(path)

                    let containerURL = try await getContainerURL()
                    let cloudURL = containerURL.appendingPathComponent(path)

                    // Get file size for progress tracking
                    let totalBytes = try getFileSize(at: cloudURL)

                    // Yield initial progress
                    continuation.yield(DownloadProgress(bytesDownloaded: 0, totalBytes: totalBytes))

                    // Perform coordinated read
                    let data = try await coordinatedRead(at: cloudURL)

                    // Save to temp directory
                    let tempDirectory = self.fileManager.temporaryDirectory
                    let tempFileName = UUID().uuidString + "-" + (path as NSString).lastPathComponent
                    let tempURL = tempDirectory.appendingPathComponent(tempFileName)
                    try data.write(to: tempURL)

                    // Yield final 100% progress
                    continuation.yield(DownloadProgress(bytesDownloaded: totalBytes, totalBytes: totalBytes))

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                // Cleanup if needed
            }
        }
    }

    public func uploadFileWithProgress(from localURL: URL, to cloudPath: String) -> AsyncThrowingStream<UploadProgress, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    try validatePath(cloudPath)

                    guard self.fileManager.fileExists(atPath: localURL.path) else {
                        throw AppError.remoteDriveSync(.fileNotFound("Local file not found"))
                    }

                    // Get local file size
                    let totalBytes = try getFileSize(at: localURL)

                    // Yield initial progress
                    continuation.yield(UploadProgress(bytesUploaded: 0, totalBytes: totalBytes))

                    let containerURL = try await getContainerURL()
                    let cloudURL = containerURL.appendingPathComponent(cloudPath)

                    // Perform coordinated write
                    try await coordinatedWrite(from: localURL, to: cloudURL)

                    // Yield final 100% progress
                    continuation.yield(UploadProgress(bytesUploaded: totalBytes, totalBytes: totalBytes))

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                // Cleanup if needed
            }
        }
    }

    // MARK: - Private Helpers

    private func getContainerURL() async throws -> URL {
        try await Task.detached {
            guard let url = self.fileManager.url(
                forUbiquityContainerIdentifier: self.containerIdentifier
            ) else {
                throw AppError.remoteDriveSync(.containerNotFound)
            }
            return url.appendingPathComponent("Documents")
        }.value
    }

    private func coordinatedRead(at url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            let coordinator = NSFileCoordinator()
            var error: NSError?

            coordinator.coordinate(
                readingItemAt: url,
                options: .withoutChanges,
                error: &error
            ) { coordURL in
                do {
                    let data = try Data(contentsOf: coordURL)
                    continuation.resume(returning: data)
                } catch {
                    continuation.resume(throwing: AppError.remoteDriveSync(.downloadFailed(error.localizedDescription)))
                }
            }

            if let error = error {
                continuation.resume(throwing: AppError.remoteDriveSync(.coordinationFailed(error.localizedDescription)))
            }
        }
    }

    private func coordinatedWrite(from sourceURL: URL, to targetURL: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let coordinator = NSFileCoordinator()
            var error: NSError?

            coordinator.coordinate(
                writingItemAt: targetURL,
                options: .forReplacing,
                error: &error
            ) { tempURL in
                do {
                    try self.fileManager.copyItem(at: sourceURL, to: tempURL)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: AppError.remoteDriveSync(.uploadFailed(error.localizedDescription)))
                }
            }

            if let error = error {
                continuation.resume(throwing: AppError.remoteDriveSync(.coordinationFailed(error.localizedDescription)))
            }
        }
    }

    private func validatePath(_ path: String) throws {
        // Validate path doesn't contain "../" (security)
        if path.contains("../") {
            throw AppError.remoteDriveSync(.invalidPath("Path contains invalid '../' sequence"))
        }

        // Validate path is not absolute
        if path.hasPrefix("/") {
            throw AppError.remoteDriveSync(.invalidPath("Path must be relative, not absolute"))
        }
    }

    private func getFileSize(at url: URL) throws -> Int64 {
        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
        guard let fileSize = resourceValues.fileSize else {
            throw AppError.remoteDriveSync(.downloadFailed("Unable to determine file size"))
        }
        return Int64(fileSize)
    }
}
