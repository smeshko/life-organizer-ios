import Foundation
import NetworkService
import Framework
import Dependencies

// MARK: - Test Helpers

extension MockNetworkService {
    init(mockData: Data) {
        self.init(mockResponseProvider: { _ in mockData })
    }
}

// MARK: - JSON Resource Loader

enum TestResources {
    static func loadMockResponse(_ key: String) throws -> Data {
        // Use SPM's generated Bundle.module
        guard let url = Bundle.module.url(forResource: "mock-responses", withExtension: "json") else {
            throw TestResourceError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseDict = json[key] as? [String: Any] else {
            throw TestResourceError.responseNotFound(key)
        }

        return try JSONSerialization.data(withJSONObject: responseDict)
    }
}

enum TestResourceError: Error, LocalizedError {
    case fileNotFound
    case responseNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "mock-responses.json not found"
        case .responseNotFound(let key):
            return "Response key '\(key)' not found in mock-responses.json"
        }
    }
}

