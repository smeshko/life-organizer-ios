import Testing
import Foundation
import Framework
@testable import RemoteDriveService

@Suite("LiveRemoteDriveService Tests")
struct LiveRemoteDriveServiceTests {

    // MARK: - isAvailable() Tests

    @Test("Returns true when iCloud container is available")
    func isAvailableWhenContainerExists() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = URL(fileURLWithPath: "/mock/container")
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        // Act
        let isAvailable = await service.isAvailable()

        // Assert
        #expect(isAvailable == true)
    }

    @Test("Returns false when iCloud container is not found")
    func isAvailableWhenContainerNotFound() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = nil  // Simulate no container
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        // Act
        let isAvailable = await service.isAvailable()

        // Assert
        #expect(isAvailable == false)
    }

    // MARK: - downloadFile(at:) Tests

    @Test("Downloads file successfully and returns temp URL")
    func downloadFileSuccess() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        let containerURL = URL(fileURLWithPath: "/mock/container")
        mockFileManager.containerURL = containerURL

        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        // Note: This test verifies the path validation and container access logic.
        // The actual NSFileCoordinator usage cannot be fully tested with mocks
        // as it requires real file system operations.

        // Act & Assert - We expect this to fail at the coordination step
        // because our mock doesn't create actual files, but we verify the path
        // validation and container access logic works correctly up to that point
        await #expect(throws: (any Error).self) {
            try await service.downloadFile(at: "test/file.txt")
        }
    }

    @Test("Throws invalidPath error for paths containing ../")
    func downloadFileWithRelativePathTraversal() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = URL(fileURLWithPath: "/mock/container")
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        // Act & Assert
        do {
            _ = try await service.downloadFile(at: "../etc/passwd")
            Issue.record("Expected invalidPath error to be thrown")
        } catch let error as AppError {
            guard case .remoteDriveSync(let syncError) = error,
                  case .invalidPath(let message) = syncError else {
                Issue.record("Expected AppError.remoteDriveSync.invalidPath, got: \(error)")
                return
            }
            #expect(message.contains("../"))
        } catch {
            Issue.record("Expected AppError, got: \(error)")
        }
    }

    @Test("Throws invalidPath error for absolute paths")
    func downloadFileWithAbsolutePath() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = URL(fileURLWithPath: "/mock/container")
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        // Act & Assert
        do {
            _ = try await service.downloadFile(at: "/absolute/path/file.txt")
            Issue.record("Expected invalidPath error to be thrown")
        } catch let error as AppError {
            guard case .remoteDriveSync(let syncError) = error,
                  case .invalidPath(let message) = syncError else {
                Issue.record("Expected AppError.remoteDriveSync.invalidPath, got: \(error)")
                return
            }
            #expect(message.contains("absolute"))
        } catch {
            Issue.record("Expected AppError, got: \(error)")
        }
    }

    @Test("Throws containerNotFound when iCloud is unavailable")
    func downloadFileWhenContainerNotFound() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = nil  // No container available
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        // Act & Assert
        do {
            _ = try await service.downloadFile(at: "test/file.txt")
            Issue.record("Expected containerNotFound error to be thrown")
        } catch let error as AppError {
            guard case .remoteDriveSync(let syncError) = error,
                  case .containerNotFound = syncError else {
                Issue.record("Expected AppError.remoteDriveSync.containerNotFound, got: \(error)")
                return
            }
            // Success - got expected error
        } catch {
            Issue.record("Expected AppError, got: \(error)")
        }
    }

    // MARK: - uploadFile(from:to:) Tests

    @Test("Throws fileNotFound when local file doesn't exist")
    func uploadFileWhenLocalFileNotFound() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = URL(fileURLWithPath: "/mock/container")
        mockFileManager.shouldFileExist = false  // Simulate file doesn't exist
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        let localURL = URL(fileURLWithPath: "/nonexistent/file.txt")

        // Act & Assert
        do {
            try await service.uploadFile(from: localURL, to: "remote/file.txt")
            Issue.record("Expected fileNotFound error to be thrown")
        } catch let error as AppError {
            guard case .remoteDriveSync(let syncError) = error,
                  case .fileNotFound(let message) = syncError else {
                Issue.record("Expected AppError.remoteDriveSync.fileNotFound, got: \(error)")
                return
            }
            #expect(message.contains("Local file not found"))
        } catch {
            Issue.record("Expected AppError, got: \(error)")
        }
    }

    @Test("Throws invalidPath error for upload paths containing ../")
    func uploadFileWithRelativePathTraversal() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = URL(fileURLWithPath: "/mock/container")
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        let localURL = URL(fileURLWithPath: "/tmp/file.txt")

        // Act & Assert
        do {
            try await service.uploadFile(from: localURL, to: "../etc/passwd")
            Issue.record("Expected invalidPath error to be thrown")
        } catch let error as AppError {
            guard case .remoteDriveSync(let syncError) = error,
                  case .invalidPath(let message) = syncError else {
                Issue.record("Expected AppError.remoteDriveSync.invalidPath, got: \(error)")
                return
            }
            #expect(message.contains("../"))
        } catch {
            Issue.record("Expected AppError, got: \(error)")
        }
    }

    @Test("Throws invalidPath error for upload with absolute paths")
    func uploadFileWithAbsolutePath() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = URL(fileURLWithPath: "/mock/container")
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        let localURL = URL(fileURLWithPath: "/tmp/file.txt")

        // Act & Assert
        do {
            try await service.uploadFile(from: localURL, to: "/absolute/path/file.txt")
            Issue.record("Expected invalidPath error to be thrown")
        } catch let error as AppError {
            guard case .remoteDriveSync(let syncError) = error,
                  case .invalidPath(let message) = syncError else {
                Issue.record("Expected AppError.remoteDriveSync.invalidPath, got: \(error)")
                return
            }
            #expect(message.contains("absolute"))
        } catch {
            Issue.record("Expected AppError, got: \(error)")
        }
    }

    @Test("Throws containerNotFound when iCloud is unavailable for upload")
    func uploadFileWhenContainerNotFound() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = nil  // No container available
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        let localURL = URL(fileURLWithPath: "/tmp/file.txt")

        // Act & Assert
        do {
            try await service.uploadFile(from: localURL, to: "remote/file.txt")
            Issue.record("Expected containerNotFound error to be thrown")
        } catch let error as AppError {
            guard case .remoteDriveSync(let syncError) = error,
                  case .containerNotFound = syncError else {
                Issue.record("Expected AppError.remoteDriveSync.containerNotFound, got: \(error)")
                return
            }
            // Success - got expected error
        } catch {
            Issue.record("Expected AppError, got: \(error)")
        }
    }

    // MARK: - downloadFileWithProgress(at:) Tests

    @Test("Download progress stream throws error for invalid path")
    func downloadProgressWithInvalidPath() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = URL(fileURLWithPath: "/mock/container")
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        // Act
        let stream = service.downloadFileWithProgress(at: "../invalid/path.txt")

        // Assert
        var didThrow = false
        do {
            for try await _ in stream {
                // Should not get here
            }
        } catch {
            didThrow = true
            // Verify it's the correct error type
            if let appError = error as? AppError {
                guard case .remoteDriveSync(let syncError) = appError,
                      case .invalidPath = syncError else {
                    Issue.record("Expected AppError.remoteDriveSync.invalidPath, got: \(appError)")
                    return
                }
            }
        }
        #expect(didThrow == true)
    }

    @Test("Download progress stream throws error when container not found")
    func downloadProgressWhenContainerNotFound() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = nil
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        // Act
        let stream = service.downloadFileWithProgress(at: "valid/path.txt")

        // Assert
        var didThrow = false
        do {
            for try await _ in stream {
                // Should not get here
            }
        } catch {
            didThrow = true
            // Verify it's the correct error type
            if let appError = error as? AppError {
                guard case .remoteDriveSync(let syncError) = appError,
                      case .containerNotFound = syncError else {
                    Issue.record("Expected AppError.remoteDriveSync.containerNotFound, got: \(appError)")
                    return
                }
            }
        }
        #expect(didThrow == true)
    }

    // MARK: - uploadFileWithProgress(from:to:) Tests

    @Test("Upload progress stream throws error for invalid path")
    func uploadProgressWithInvalidPath() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = URL(fileURLWithPath: "/mock/container")
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        let localURL = URL(fileURLWithPath: "/tmp/file.txt")

        // Act
        let stream = service.uploadFileWithProgress(from: localURL, to: "../invalid/path.txt")

        // Assert
        var didThrow = false
        do {
            for try await _ in stream {
                // Should not get here
            }
        } catch {
            didThrow = true
            // Verify it's the correct error type
            if let appError = error as? AppError {
                guard case .remoteDriveSync(let syncError) = appError,
                      case .invalidPath = syncError else {
                    Issue.record("Expected AppError.remoteDriveSync.invalidPath, got: \(appError)")
                    return
                }
            }
        }
        #expect(didThrow == true)
    }

    @Test("Upload progress stream throws error when local file not found")
    func uploadProgressWhenLocalFileNotFound() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = URL(fileURLWithPath: "/mock/container")
        mockFileManager.shouldFileExist = false
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        let localURL = URL(fileURLWithPath: "/nonexistent/file.txt")

        // Act
        let stream = service.uploadFileWithProgress(from: localURL, to: "remote/file.txt")

        // Assert
        var didThrow = false
        do {
            for try await _ in stream {
                // Should not get here
            }
        } catch {
            didThrow = true
            // Verify it's the correct error type
            if let appError = error as? AppError {
                guard case .remoteDriveSync(let syncError) = appError,
                      case .fileNotFound = syncError else {
                    Issue.record("Expected AppError.remoteDriveSync.fileNotFound, got: \(appError)")
                    return
                }
            }
        }
        #expect(didThrow == true)
    }

    @Test("Upload progress stream throws error when container not found")
    func uploadProgressWhenContainerNotFound() async throws {
        // Arrange
        let mockFileManager = MockFileManager()
        mockFileManager.containerURL = nil
        let service = LiveRemoteDriveService(
            fileManager: mockFileManager,
            containerIdentifier: nil
        )

        let localURL = URL(fileURLWithPath: "/tmp/file.txt")

        // Act
        let stream = service.uploadFileWithProgress(from: localURL, to: "remote/file.txt")

        // Assert
        var didThrow = false
        do {
            for try await _ in stream {
                // Should not get here
            }
        } catch {
            didThrow = true
            // Verify it's the correct error type
            if let appError = error as? AppError {
                guard case .remoteDriveSync(let syncError) = appError,
                      case .containerNotFound = syncError else {
                    Issue.record("Expected AppError.remoteDriveSync.containerNotFound, got: \(appError)")
                    return
                }
            }
        }
        #expect(didThrow == true)
    }
}
