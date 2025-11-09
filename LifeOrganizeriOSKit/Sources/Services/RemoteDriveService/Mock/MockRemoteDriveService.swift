import Foundation

public struct MockRemoteDriveService: RemoteDriveServiceProtocol, Sendable {
    public let shouldSimulateError: Bool
    public let errorToThrow: AppError?
    public let simulatedDelay: UInt64
    private let mockFileProvider: (@Sendable (String) throws -> URL)?

    public init() {
        self.shouldSimulateError = false
        self.errorToThrow = nil
        self.simulatedDelay = 100_000_000
        self.mockFileProvider = nil
    }

    public init(
        shouldSimulateError: Bool = false,
        errorToThrow: AppError? = nil,
        simulatedDelay: UInt64 = 100_000_000,
        mockFileProvider: (@Sendable (String) throws -> URL)? = nil
    ) {
        self.shouldSimulateError = shouldSimulateError
        self.errorToThrow = errorToThrow
        self.simulatedDelay = simulatedDelay
        self.mockFileProvider = mockFileProvider
    }

    public func isAvailable() async -> Bool {
        // Simulate iCloud unavailable when errors are enabled
        return !shouldSimulateError
    }

    public func downloadFile(at path: String) async throws -> URL {
        // Simulate network delay
        try await Task.sleep(nanoseconds: simulatedDelay)

        // Simulate error if configured
        if shouldSimulateError {
            throw errorToThrow ?? AppError.remoteDriveSync(.downloadFailed("Mock error"))
        }

        // Use custom provider if available
        if let provider = mockFileProvider {
            return try provider(path)
        }

        // Default: create temp file with mock content
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let filename = path.split(separator: "/").last.map(String.init) ?? "mock.txt"
        let tempURL = tempDir.appendingPathComponent(filename)

        let mockContent = "Mock content for \(path)"
        try mockContent.write(to: tempURL, atomically: true, encoding: .utf8)

        return tempURL
    }

    public func uploadFile(from localURL: URL, to cloudPath: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: simulatedDelay)

        // Simulate error if configured
        if shouldSimulateError {
            throw errorToThrow ?? AppError.remoteDriveSync(.uploadFailed("Mock error"))
        }

        // Verify local file exists
        guard FileManager.default.fileExists(atPath: localURL.path) else {
            throw AppError.remoteDriveSync(.fileNotFound("Local file not found"))
        }

        // Success - no actual upload in mock
    }

    public func downloadFileWithProgress(at path: String) -> AsyncThrowingStream<DownloadProgress, Error> {
        AsyncThrowingStream { continuation in
            Task {
                let simulatedSize: Int64 = 10_000_000  // 10MB

                // Simulate progressive download
                let progressSteps: [Int64] = [0, 25, 50, 75, 100]

                for step in progressSteps {
                    // Check for error simulation at 50%
                    if shouldSimulateError && step == 50 {
                        continuation.finish(throwing: errorToThrow ?? AppError.remoteDriveSync(.downloadFailed("Mock error at 50%")))
                        return
                    }

                    // Yield progress
                    let bytesDownloaded = (simulatedSize * step) / 100
                    let progress = DownloadProgress(
                        bytesDownloaded: bytesDownloaded,
                        totalBytes: simulatedSize
                    )
                    continuation.yield(progress)

                    // Sleep between updates (except after 100%)
                    if step < 100 {
                        try await Task.sleep(nanoseconds: simulatedDelay / 5)
                    }
                }

                continuation.finish()
            }
        }
    }

    public func uploadFileWithProgress(from localURL: URL, to cloudPath: String) -> AsyncThrowingStream<UploadProgress, Error> {
        AsyncThrowingStream { continuation in
            Task {
                // Get real file size if file exists, otherwise simulate
                let fileSize: Int64
                if FileManager.default.fileExists(atPath: localURL.path) {
                    let resourceValues = try? localURL.resourceValues(forKeys: [.fileSizeKey])
                    fileSize = Int64(resourceValues?.fileSize ?? 10_000_000)
                } else {
                    fileSize = 10_000_000  // 10MB default
                }

                // Simulate progressive upload
                let progressSteps: [Int64] = [0, 25, 50, 75, 100]

                for step in progressSteps {
                    // Check for error simulation at 50%
                    if shouldSimulateError && step == 50 {
                        continuation.finish(throwing: errorToThrow ?? AppError.remoteDriveSync(.uploadFailed("Mock error at 50%")))
                        return
                    }

                    // Yield progress
                    let bytesUploaded = (fileSize * step) / 100
                    let progress = UploadProgress(
                        bytesUploaded: bytesUploaded,
                        totalBytes: fileSize
                    )
                    continuation.yield(progress)

                    // Sleep between updates (except after 100%)
                    if step < 100 {
                        try await Task.sleep(nanoseconds: simulatedDelay / 5)
                    }
                }

                continuation.finish()
            }
        }
    }
}
