import Foundation
import Framework

/// API endpoints for action handler feature
public enum ActionHandlerEndpoints {
    case processAction(ProcessActionRequestDTO)
}

extension ActionHandlerEndpoints: Endpoint {
    public var path: String {
        switch self {
        case .processAction:
            return "/process"
        }
    }
    
    public var url: URL? {
        BackendConfiguration.apiBaseURL
            .appendingPathComponent(path)
    }
    
    public var method: HTTPMethod {
        switch self {
        case .processAction:
            return .post
        }
    }
    
    public var body: Data? {
        switch self {
        case .processAction(let request):
            let encoder = JSONEncoder()
            return try? encoder.encode(request)
        }
    }
}

