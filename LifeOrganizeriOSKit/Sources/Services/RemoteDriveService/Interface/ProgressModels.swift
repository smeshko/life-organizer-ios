import Foundation

/// Progress information for file downloads from iCloud Drive
public struct DownloadProgress: Sendable, Equatable {
    public let bytesDownloaded: Int64
    public let totalBytes: Int64

    /// Download progress as a percentage (0-100)
    public var percentage: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytesDownloaded) / Double(totalBytes) * 100
    }

    public init(bytesDownloaded: Int64, totalBytes: Int64) {
        self.bytesDownloaded = bytesDownloaded
        self.totalBytes = totalBytes
    }
}

/// Progress information for file uploads to iCloud Drive
public struct UploadProgress: Sendable, Equatable {
    public let bytesUploaded: Int64
    public let totalBytes: Int64

    /// Upload progress as a percentage (0-100)
    public var percentage: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytesUploaded) / Double(totalBytes) * 100
    }

    public init(bytesUploaded: Int64, totalBytes: Int64) {
        self.bytesUploaded = bytesUploaded
        self.totalBytes = totalBytes
    }
}
