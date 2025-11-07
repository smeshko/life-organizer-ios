import Foundation

/// Backend URL configuration
public struct BackendConfiguration {
    /// Base backend URL (environment-dependent)
    public static let baseURL: URL = {
        #if DEBUG
        // Dev environment: local backend
        return URL(string: "http://localhost:8000")!
        #else
        // Production: to be configured in future phase
        fatalError("Production backend URL not configured. Set via environment or config file.")
        #endif
    }()
    
    /// API base URL with versioning
    public static var apiBaseURL: URL {
        baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("v1")
    }
}

