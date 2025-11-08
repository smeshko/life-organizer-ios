import Foundation

/// Service for downloading and uploading files to/from iCloud Drive
///
/// This service handles bidirectional file synchronization between iCloud Drive
/// and the local app sandbox using NSFileCoordinator for safe concurrent access.
///
/// Example usage:
/// ```swift
/// @Dependency(\.remoteDriveService) var remoteDriveService
///
/// // Download file
/// let localURL = try await remoteDriveService.downloadFile(at: "MyApp/data.json")
///
/// // Upload file
/// try await remoteDriveService.uploadFile(from: localURL, to: "MyApp/data.json")
/// ```
public protocol RemoteDriveServiceProtocol: Sendable {
    /// Downloads a file from iCloud Drive to local temporary storage
    ///
    /// The file is downloaded using NSFileCoordinator for safe access and stored
    /// in the app's temporary directory. The caller is responsible for cleaning up
    /// the returned temporary file when no longer needed.
    ///
    /// - Parameter path: Relative path from iCloud Documents folder (e.g., "MyApp/file.txt")
    /// - Returns: URL to the downloaded file in local temporary storage
    /// - Throws: `AppError.iCloudSync` if download fails
    ///
    /// Example:
    /// ```swift
    /// let localURL = try await downloadFile(at: "MyApp/config.json")
    /// let data = try Data(contentsOf: localURL)
    /// ```
    func downloadFile(at path: String) async throws -> URL

    /// Uploads a local file to iCloud Drive, replacing any existing file
    ///
    /// The file is uploaded using NSFileCoordinator with atomic replacement to ensure
    /// the iCloud file is never in a partial state. The original local file is not modified.
    ///
    /// - Parameters:
    ///   - localURL: URL to the local file to upload
    ///   - cloudPath: Relative path in iCloud Documents folder (e.g., "MyApp/file.txt")
    /// - Throws: `AppError.iCloudSync` if upload fails
    ///
    /// Example:
    /// ```swift
    /// try await uploadFile(from: tempURL, to: "MyApp/config.json")
    /// ```
    func uploadFile(from localURL: URL, to cloudPath: String) async throws

    /// Checks if iCloud Drive is currently available
    ///
    /// This method verifies that:
    /// - The user is signed in to iCloud
    /// - iCloud Drive is enabled
    /// - The app's iCloud container is accessible
    ///
    /// - Returns: `true` if iCloud is available, `false` otherwise
    ///
    /// Example:
    /// ```swift
    /// guard await remoteDriveService.isAvailable() else {
    ///     // Show "Sign in to iCloud" message
    ///     return
    /// }
    /// ```
    func isAvailable() async -> Bool

    /// Downloads a file from iCloud Drive with progress reporting
    ///
    /// Returns an async stream that yields progress updates during the download.
    /// The stream completes after the file is successfully downloaded and returns
    /// the URL to the downloaded file in local temporary storage.
    ///
    /// - Parameter path: Relative path from iCloud Documents folder (e.g., "MyApp/file.txt")
    /// - Returns: AsyncThrowingStream that yields DownloadProgress updates
    /// - Throws: `AppError.iCloudSync` if download fails
    ///
    /// Example:
    /// ```swift
    /// for try await progress in remoteDriveService.downloadFileWithProgress(at: "MyApp/data.json") {
    ///     print("Downloaded: \(progress.percentage)%")
    /// }
    /// ```
    func downloadFileWithProgress(at path: String) -> AsyncThrowingStream<DownloadProgress, Error>

    /// Uploads a local file to iCloud Drive with progress reporting
    ///
    /// Returns an async stream that yields progress updates during the upload.
    /// The stream completes after the file is successfully uploaded.
    ///
    /// - Parameters:
    ///   - localURL: URL to the local file to upload
    ///   - cloudPath: Relative path in iCloud Documents folder (e.g., "MyApp/file.txt")
    /// - Returns: AsyncThrowingStream that yields UploadProgress updates
    /// - Throws: `AppError.iCloudSync` if upload fails
    ///
    /// Example:
    /// ```swift
    /// for try await progress in remoteDriveService.uploadFileWithProgress(from: tempURL, to: "MyApp/data.json") {
    ///     print("Uploaded: \(progress.percentage)%")
    /// }
    /// ```
    func uploadFileWithProgress(from localURL: URL, to cloudPath: String) -> AsyncThrowingStream<UploadProgress, Error>
}
