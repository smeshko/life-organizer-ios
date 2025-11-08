import Foundation

/// Endpoint for POST /api/v1/process
struct ProcessActionEndpoint: Endpoint {
    let baseURL: URL
    let request: ProcessActionRequestDTO

    var url: URL? {
        baseURL.appendingPathComponent("/api/v1/process")
    }

    var path: String {
        "/api/v1/process"
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        let encoder = JSONEncoder()
        // Note: No need to set encoder.keyEncodingStrategy since request uses exact field names
        return try? encoder.encode(request)
    }

    // headers and queryParameters use default implementation from Endpoint extension
    // Default headers: ["Content-Type": "application/json; charset=utf-8"]
}
