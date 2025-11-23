import Dependencies
import Foundation

// MARK: - Dependency Key
private enum LoggingServiceKey: DependencyKey {
    static let liveValue: any LoggingServiceProtocol = LoggingService()
    static let testValue: any LoggingServiceProtocol = MockLoggingService()
}

// MARK: - Dependency Values Extension
public extension DependencyValues {
    var loggingService: any LoggingServiceProtocol {
        get { self[LoggingServiceKey.self] }
        set { self[LoggingServiceKey.self] = newValue }
    }
}
