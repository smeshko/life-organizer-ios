import Foundation
import Testing
@testable import RemoteDriveService

// MARK: - MockFileManager

final class MockFileManager: FileManagerProtocol, @unchecked Sendable {
    // Configuration
    var containerURL: URL?
    var shouldFileExist: Bool = true
    var shouldCopySucceed: Bool = true
    var copyError: Error?
    private(set) var copiedFiles: [(from: URL, to: URL)] = []

    // File size tracking for specific URLs
    var fileSizes: [URL: Int64] = [:]

    var temporaryDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test-temp-\(UUID().uuidString)")
    }

    func fileExists(atPath path: String) -> Bool {
        shouldFileExist
    }

    func url(forUbiquityContainerIdentifier containerIdentifier: String?) -> URL? {
        containerURL
    }

    func copyItem(at srcURL: URL, to dstURL: URL) throws {
        copiedFiles.append((from: srcURL, to: dstURL))

        if let error = copyError {
            throw error
        }

        if !shouldCopySucceed {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Copy failed"])
        }

        // Actually create a file at the destination for testing
        try "test content".write(to: dstURL, atomically: true, encoding: .utf8)
    }

    // Helper to reset state between tests
    func reset() {
        containerURL = nil
        shouldFileExist = true
        shouldCopySucceed = true
        copyError = nil
        copiedFiles.removeAll()
        fileSizes.removeAll()
    }
}

// MARK: - Test Helpers

enum TestHelpers {
    /// Create a test file with known content and size
    static func createTestFile(content: String = "Test file content", name: String = "test.txt") throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(name)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    /// Collect all progress values from an AsyncThrowingStream
    static func collectProgress<T>(from stream: AsyncThrowingStream<T, Error>) async throws -> [T] {
        var results: [T] = []
        for try await progress in stream {
            results.append(progress)
        }
        return results
    }

    /// Clean up a test file
    static func cleanup(fileURL: URL) {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
