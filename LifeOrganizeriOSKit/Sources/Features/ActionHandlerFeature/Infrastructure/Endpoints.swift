import Foundation
import Framework

/// API endpoints for ActionHandler feature
public enum ActionHandlerEndpoint {
    case processAction(Data)
}

extension ActionHandlerEndpoint: Endpoint {
    public var url: URL? {
        let baseURL = APIConfiguration.baseURL
        return baseURL.appendingPathComponent(path)
    }

    public var path: String {
        switch self {
        case .processAction:
            return "/api/v1/process"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .processAction:
            return .post
        }
    }

    public var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    public var body: Data? {
        switch self {
        case .processAction(let data):
            return data
        }
    }
}
