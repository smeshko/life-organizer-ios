import Foundation
import Framework

/// App-level API endpoints for health checks, status, and system-wide operations
public enum AppEndpoint {
    case status
}

extension AppEndpoint: Endpoint {
    public var url: URL? {
        let baseURL = APIConfiguration.baseURL
        return baseURL.appendingPathComponent(path)
    }

    public var path: String {
        switch self {
        case .status:
            return "/api/v1/status"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .status:
            return .get
        }
    }

    public var headers: [String: String] {
        return [
            "Accept": "application/json"
        ]
    }

    public var body: Data? {
        return nil
    }
}
