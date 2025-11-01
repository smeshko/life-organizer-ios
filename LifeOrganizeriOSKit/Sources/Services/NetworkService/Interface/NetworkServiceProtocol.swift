import Foundation
import Framework

/// Protocol defining the network communication interface.
///
/// `NetworkServiceProtocol` provides a clean abstraction over HTTP networking,
/// designed for communication with backend APIs and services.
///
/// ## Design Principles
/// - **Type-safe**: Generic methods ensure compile-time safety for response types
/// - **Async-first**: Built for Swift's modern concurrency model
/// - **Endpoint-driven**: Uses strongly-typed endpoint definitions
/// - **Error-transparent**: Allows detailed error handling at call sites
///
/// ## Typical Usage
/// ```swift
/// let data: MyResponse = try await networkService.sendRequest(to: MyEndpoint.getData)
/// ```
public protocol NetworkServiceProtocol: Sendable {
    /// Sends a request to the specified endpoint and decodes the response.
    ///
    /// This is the primary method for making network requests that expect structured
    /// data responses. The method handles JSON decoding automatically based on the
    /// generic type parameter.
    ///
    /// - Parameter endpoint: The endpoint to send the request to
    /// - Returns: The decoded response of type `T`
    /// - Throws: Network errors, decoding errors, or HTTP errors
    func sendRequest<T>(to endpoint: any Endpoint) async throws -> T where T: Decodable

    /// Sends a request without expecting or processing a response body.
    ///
    /// Useful for fire-and-forget operations like analytics events or logging.
    ///
    /// - Parameter endpoint: The endpoint to send the request to
    /// - Throws: Network errors or HTTP errors
    func sendAndForget(to endpoint: any Endpoint) async throws

    /// Fetches raw data from the specified endpoint without decoding.
    ///
    /// Used when you need access to the raw response data, such as for
    /// binary content or custom parsing.
    ///
    /// - Parameter endpoint: The endpoint to fetch data from
    /// - Returns: The raw response data
    /// - Throws: Network errors or HTTP errors
    func fetchData(at endpoint: any Endpoint) async throws -> Data
}
