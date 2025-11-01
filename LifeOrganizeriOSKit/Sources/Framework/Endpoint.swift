import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// An object that represents an API endpoint.
/// Contains all properties needed to build a request to an endpoint.
public protocol Endpoint: Sendable {
    var path: String { get }
    var url: URL? { get }
    var method: HTTPMethod { get }
    var body: Data? { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String]? { get }
}

public extension Endpoint {
    var headers: [String: String] {
        ["Content-Type": "application/json; charset=utf-8"]
    }

    var queryParameters: [String: String]? { nil }
    var method: HTTPMethod { .get }
    var body: Data? { nil }
}
