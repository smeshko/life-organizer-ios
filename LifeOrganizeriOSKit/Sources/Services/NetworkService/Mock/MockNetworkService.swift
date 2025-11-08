import Foundation
import Framework

public struct MockNetworkService: NetworkServiceProtocol, Sendable {
    private let mockResponseProvider: (@Sendable (any Endpoint) throws -> Data?)?

    public init() {
        self.mockResponseProvider = nil
    }

    public init(mockResponseProvider: @escaping @Sendable (any Endpoint) throws -> Data?) {
        self.mockResponseProvider = mockResponseProvider
    }

    public func sendRequest<T>(to endpoint: any Endpoint) async throws -> T where T: Decodable {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000)

        // Return mock data based on endpoint
        if let mockData = try mockResponse(for: endpoint) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
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

        if let mockData = try mockResponse(for: endpoint) {
            return mockData
        }

        throw MockNetworkError.noMockData
    }

    // MARK: - Mock Data Generation

    private func mockResponse(for endpoint: any Endpoint) throws -> Data? {
        // Use custom provider if available
        if let provider = mockResponseProvider {
            return try provider(endpoint)
        }

        // Default: return empty JSON object
        return "{}".data(using: .utf8)
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
