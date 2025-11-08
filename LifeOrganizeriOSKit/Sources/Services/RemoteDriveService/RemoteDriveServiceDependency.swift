import Dependencies
import Foundation

private enum RemoteDriveServiceKey: DependencyKey {
    static let liveValue: any RemoteDriveServiceProtocol = LiveRemoteDriveService()
    static let testValue: any RemoteDriveServiceProtocol = MockRemoteDriveService()
}

public extension DependencyValues {
    var remoteDriveService: any RemoteDriveServiceProtocol {
        get { self[RemoteDriveServiceKey.self] }
        set { self[RemoteDriveServiceKey.self] = newValue }
    }
}
