import Foundation
import Framework

/// Mock implementation of XLSXAppendService for testing
public struct MockXLSXAppendService: XLSXAppendServiceProtocol, Sendable {
    /// Simulated delay in nanoseconds (default: 100ms)
    public let simulatedDelay: UInt64

    /// Whether to simulate an error
    public let shouldSimulateError: Bool

    /// The error to throw when simulating failure
    public let errorToThrow: AppError?

    /// Creates a mock XLSX append service
    /// - Parameters:
    ///   - simulatedDelay: Delay in nanoseconds (default: 100ms for realistic async behavior)
    ///   - shouldSimulateError: Whether to throw an error (default: false)
    ///   - errorToThrow: Custom error to throw (default: worksheetModificationFailed)
    public init(
        simulatedDelay: UInt64 = 100_000_000, // 100ms
        shouldSimulateError: Bool = false,
        errorToThrow: AppError? = nil
    ) {
        self.simulatedDelay = simulatedDelay
        self.shouldSimulateError = shouldSimulateError
        self.errorToThrow = errorToThrow
    }

    public func appendRow(
        to fileURL: URL,
        sheetName: String,
        values: [String]
    ) async throws -> URL {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: simulatedDelay)

        // Simulate error if configured
        if shouldSimulateError {
            throw errorToThrow ?? AppError.xlsx(
                .worksheetModificationFailed("Simulated error")
            )
        }

        // Return the input URL (mock doesn't actually modify files)
        // In tests, you can verify this URL matches expectations
        return fileURL
    }
}
