import Foundation
import Entities
import Framework

public struct MockReminderService: ReminderServiceProtocol, Sendable {
    public let shouldSimulateError: Bool
    public let errorToThrow: AppError?
    public let simulatedDelay: UInt64

    public init(
        shouldSimulateError: Bool = false,
        errorToThrow: AppError? = nil,
        simulatedDelay: UInt64 = 100_000_000  // 100ms
    ) {
        self.shouldSimulateError = shouldSimulateError
        self.errorToThrow = errorToThrow
        self.simulatedDelay = simulatedDelay
    }

    public func createReminder(_ action: ReminderAction) async throws {
        try await Task.sleep(nanoseconds: simulatedDelay)

        if shouldSimulateError {
            throw errorToThrow ?? AppError.reminder(.saveFailed("Mock error"))
        }
        // Success - no-op in mock
    }
}
