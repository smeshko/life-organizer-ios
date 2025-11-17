import Foundation
import Framework

/// Mock implementation of ClassifierServiceProtocol for testing.
///
/// Allows configuring predicted category, confidence scores, errors, and delays
/// to test various classification scenarios without depending on the CoreML model.
///
/// **Example Usage:**
/// ```swift
/// // Test high-confidence classification
/// let mockHigh = MockClassifierService(
///     predictedCategory: .BUDGET,
///     confidence: 0.92
/// )
/// let result = try await mockHigh.classify("test")
/// // result.category == .BUDGET, result.confidence == 0.92
///
/// // Test low-confidence fallback
/// let mockLow = MockClassifierService(
///     predictedCategory: .SHOPPING,
///     confidence: 0.65
/// )
/// let result = try await mockLow.classify("test")
/// // result.shouldUseFallback == true
///
/// // Test error simulation
/// let mockError = MockClassifierService(
///     shouldSimulateError: true,
///     errorToThrow: .classifier(.inferenceFailed("Mock error"))
/// )
/// // try await mockError.classify("test") throws error
/// ```
public struct MockClassifierService: ClassifierServiceProtocol, Sendable {
    /// The category to return in classification results
    public let predictedCategory: TextCategory

    /// The confidence score to return (0.0 - 1.0)
    public let confidence: Float

    /// All category scores to return (if empty, generates from confidence)
    public let allScores: [TextCategory: Float]

    /// Whether to simulate an error instead of returning a result
    public let shouldSimulateError: Bool

    /// The error to throw when shouldSimulateError is true
    public let errorToThrow: AppError?

    /// Simulated delay in nanoseconds (default: 100ms)
    public let simulatedDelay: UInt64

    public init(
        predictedCategory: TextCategory = .budget,
        confidence: Float = 0.85,
        allScores: [TextCategory: Float] = [:],
        shouldSimulateError: Bool = false,
        errorToThrow: AppError? = nil,
        simulatedDelay: UInt64 = 100_000_000  // 100ms
    ) {
        self.predictedCategory = predictedCategory
        self.confidence = confidence
        self.allScores = allScores.isEmpty ? Self.generateScores(
            predicted: predictedCategory,
            confidence: confidence
        ) : allScores
        self.shouldSimulateError = shouldSimulateError
        self.errorToThrow = errorToThrow
        self.simulatedDelay = simulatedDelay
    }

    public func classify(_ text: String) async throws -> ClassificationResult {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: simulatedDelay)

        // Simulate error if configured
        if shouldSimulateError {
            throw errorToThrow ?? AppError.classifier(.inferenceFailed("Mock error"))
        }

        // Return configured result
        return ClassificationResult(
            category: predictedCategory,
            confidence: confidence,
            allScores: allScores
        )
    }

    /// Generates realistic score distribution from predicted category and confidence
    private static func generateScores(
        predicted: TextCategory,
        confidence: Float
    ) -> [TextCategory: Float] {
        var scores: [TextCategory: Float] = [:]
        let remaining = 1.0 - confidence
        let otherCategories = TextCategory.allCases.filter { $0 != predicted }
        let scorePerOther = remaining / Float(otherCategories.count)

        scores[predicted] = confidence
        for category in otherCategories {
            scores[category] = scorePerOther
        }

        return scores
    }
}
