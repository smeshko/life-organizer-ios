import Foundation
import Framework

public struct NetworkService: NetworkServiceProtocol, Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchData(at endpoint: any Endpoint) async throws -> Data {
        let request = try URLRequest.from(endpoint: endpoint)

        do {
            let (data, response) = try await session.data(for: request)
            try validateResponse(response)
            return data
        } catch let error as AppError {
            throw error
        } catch is URLError {
            throw AppError.network(.noConnection)
        } catch {
            throw AppError.network(.requestFailed(error.localizedDescription))
        }
    }

    public func sendAndForget(to endpoint: any Endpoint) async throws {
        let request = try URLRequest.from(endpoint: endpoint)

        do {
            let (_, response) = try await session.data(for: request)
            try validateResponse(response)
        } catch let error as AppError {
            throw error
        } catch is URLError {
            throw AppError.network(.noConnection)
        } catch {
            throw AppError.network(.requestFailed(error.localizedDescription))
        }
    }

    public func sendRequest<T>(to endpoint: any Endpoint) async throws -> T where T: Decodable {
        let request = try URLRequest.from(endpoint: endpoint)

        do {
            let (data, response) = try await session.data(for: request)
            try validateResponse(response)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch let error as AppError {
            throw error
        } catch is URLError {
            throw AppError.network(.noConnection)
        } catch is DecodingError {
            throw AppError.network(.decodingFailed("Failed to decode \(T.self)"))
        } catch {
            throw AppError.network(.requestFailed(error.localizedDescription))
        }
    }

    // MARK: - Private Helpers

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.network(.invalidResponse)
        }

        switch httpResponse.statusCode {
        case 200...299:
            // Success range - no error
            break
        case 400...499:
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw AppError.network(.clientError(statusCode: httpResponse.statusCode, message: message))
        case 500...599:
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw AppError.network(.serverError(statusCode: httpResponse.statusCode, message: message))
        default:
            throw AppError.network(.requestFailed("Unexpected status code: \(httpResponse.statusCode)"))
        }
    }
}
