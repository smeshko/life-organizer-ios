import Foundation
import Framework

/// Mock implementation of SpeechToTextServiceProtocol for testing.
///
/// Provides configurable behavior for testing various scenarios including
/// successful recognition, authorization states, and error conditions.
public struct MockSpeechToTextService: SpeechToTextServiceProtocol, Sendable {
    // MARK: - Configuration

    /// The authorization status to return
    public let authorizationStatusToReturn: AuthorizationStatus

    /// The text to return for successful recognition
    public let recognizedText: String

    /// Whether to simulate an error during recognition
    public let shouldSimulateError: Bool

    /// The error to throw when simulating errors
    public let errorToThrow: AppError?

    /// Delay in nanoseconds to simulate processing time
    public let simulatedDelay: UInt64

    // MARK: - Initialization

    public init(
        authorizationStatus: AuthorizationStatus = .authorized,
        recognizedText: String = "Mock recognized text",
        shouldSimulateError: Bool = false,
        errorToThrow: AppError? = nil,
        simulatedDelay: UInt64 = 100_000_000
    ) {
        self.authorizationStatusToReturn = authorizationStatus
        self.recognizedText = recognizedText
        self.shouldSimulateError = shouldSimulateError
        self.errorToThrow = errorToThrow
        self.simulatedDelay = simulatedDelay
    }

    // MARK: - SpeechToTextServiceProtocol

    public func authorizationStatus() -> AuthorizationStatus {
        return authorizationStatusToReturn
    }

    public func requestAuthorization() async throws -> AuthorizationStatus {
        // Simulate async delay
        try await Task.sleep(nanoseconds: simulatedDelay)

        if shouldSimulateError, let error = errorToThrow {
            throw error
        }

        return authorizationStatusToReturn
    }

    public func recognize(audioFileURL: URL) async throws -> String {
        // Simulate async delay
        try await Task.sleep(nanoseconds: simulatedDelay)

        // Check authorization
        guard authorizationStatusToReturn == .authorized else {
            throw AppError.speechRecognition(.notAuthorized)
        }

        if shouldSimulateError, let error = errorToThrow {
            throw error
        }

        return recognizedText
    }

    public func recognizeFromMicrophone() -> AsyncThrowingStream<RecognitionResult, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                // Simulate initial delay
                try await Task.sleep(nanoseconds: simulatedDelay)

                // Check authorization
                guard authorizationStatusToReturn == .authorized else {
                    continuation.finish(throwing: AppError.speechRecognition(.notAuthorized))
                    return
                }

                if shouldSimulateError, let error = errorToThrow {
                    continuation.finish(throwing: error)
                    return
                }

                // Simulate partial results
                let words = recognizedText.split(separator: " ")
                for (index, word) in words.enumerated() {
                    let partialText = words[0...index].joined(separator: " ")
                    let isFinal = index == words.count - 1

                    continuation.yield(RecognitionResult(text: partialText, isFinal: isFinal))

                    // Small delay between partial results
                    if !isFinal {
                        try await Task.sleep(nanoseconds: 50_000_000)
                    }
                }

                continuation.finish()
            }
        }
    }
}
