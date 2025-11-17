import Entities
import Foundation

/// Result of on-device text classification containing predicted category and confidence scores.
public struct ClassificationResult: Sendable, Equatable {
    /// The predicted category with highest confidence
    public let category: TextCategory

    /// Confidence score for the predicted category (0.0 - 1.0)
    public let confidence: Float

    /// All category scores as a dictionary
    public let allScores: [TextCategory: Float]

    /// Whether this result should fall back to backend classification
    /// Returns true if confidence is below the threshold (0.75)
    public var shouldUseFallback: Bool {
        confidence < 0.75
    }

    public init(category: TextCategory, confidence: Float, allScores: [TextCategory: Float]) {
        self.category = category
        self.confidence = confidence
        self.allScores = allScores
    }
}
