import Foundation

/// Central API configuration for the application
public enum APIConfiguration {
    /// Base URL for the backend API
    public static var baseURL: URL {
        // Production backend on Railway
        URL(string: "https://life-organizer-be-production.up.railway.app")!

        // For local development, uncomment this line instead:
        // URL(string: "http://localhost:8000")!
    }
}
