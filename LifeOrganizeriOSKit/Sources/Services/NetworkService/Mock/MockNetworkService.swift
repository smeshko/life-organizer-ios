import Foundation
import Framework

public struct MockNetworkService: NetworkServiceProtocol, Sendable {
    public init() {}

    public func sendRequest<T>(to endpoint: any Endpoint) async throws -> T where T: Decodable {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000)

        // Return mock data based on endpoint
        if let mockData = mockResponse(for: endpoint) {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: mockData)
        }

        throw MockNetworkError.noMockData
    }

    public func sendAndForget(to endpoint: any Endpoint) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 50_000_000)
    }

    public func fetchData(at endpoint: any Endpoint) async throws -> Data {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000)

        if let mockData = mockResponse(for: endpoint) {
            return mockData
        }

        throw MockNetworkError.noMockData
    }

    // MARK: - Mock Data Generation

    private func mockResponse(for endpoint: any Endpoint) -> Data? {
        // This would typically be configured based on the endpoint path/type
        // For now, return empty JSON object
        "{}".data(using: .utf8)
    }
}

public enum MockNetworkError: Error {
    case noMockData
    case simulatedError
}

extension MockNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noMockData:
            return "No mock data configured for this endpoint"
        case .simulatedError:
            return "Simulated network error for testing"
        }
    }
}
