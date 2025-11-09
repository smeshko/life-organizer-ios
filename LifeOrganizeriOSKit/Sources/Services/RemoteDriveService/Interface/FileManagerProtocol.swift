import Foundation

/// Protocol abstracting file manager functionality.
///
/// This protocol wraps `FileManager` to enable dependency injection
/// and testing. In production, `FileManager` conforms to this protocol.
/// In tests, mock implementations can be injected.
public protocol FileManagerProtocol: Sendable {
    /// The temporary directory for the current user.
    var temporaryDirectory: URL { get }

    /// Returns a Boolean value that indicates whether a file or directory exists at a specified path.
    ///
    /// - Parameter path: The path of a file or directory. If path begins with a tilde (~),
    ///   it must first be expanded with expandingTildeInPath, or this method returns false.
    /// - Returns: true if a file at the specified path exists or false if the file doesn't exist or
    ///   its existence couldn't be determined.
    func fileExists(atPath path: String) -> Bool

    /// Returns the URL for the iCloud container associated with the specified identifier.
    ///
    /// - Parameter containerIdentifier: The fully-qualified container identifier for an iCloud container
    ///   directory. The string you specify must not contain wildcards and must be of the form
    ///   <TEAMID>.<CONTAINER>, where <TEAMID> is your development team ID and <CONTAINER> is the
    ///   bundle identifier of the container you want to access. If you specify nil for this parameter,
    ///   this method uses the first container listed in the com.apple.developer.ubiquity-container-identifiers
    ///   array of the .entitlements property list file.
    /// - Returns: The URL for the container directory or nil if the container could not be located or
    ///   if iCloud storage is unavailable for the current user or the current app.
    func url(forUbiquityContainerIdentifier containerIdentifier: String?) -> URL?

    /// Copies the item at the specified URL to a new location synchronously.
    ///
    /// - Parameters:
    ///   - srcURL: The URL that identifies the file or directory you want to copy.
    ///   - dstURL: The URL at which to place the copy of srcURL.
    /// - Throws: An error if the item cannot be copied.
    func copyItem(at srcURL: URL, to dstURL: URL) throws
}

/// Extension making FileManager conform to FileManagerProtocol.
extension FileManager: FileManagerProtocol {}
