import Foundation

/// Service protocol for on-device text classification using CoreML and DistilBERT.
///
/// ## Design Principles
///
/// The ClassifierService performs on-device text classification to categorize user input
/// into one of six categories (budget, shopping, reminder, calendar, note, quote).
/// This reduces backend costs by 5x and improves response time to <100ms for high-confidence
/// classifications.
///
/// **Key Features:**
/// - On-device inference using CoreML with Neural Engine acceleration
/// - DistilBERT tokenization via swift-transformers for accuracy
/// - Confidence-based fallback to backend for low-confidence predictions
/// - 91.84% accuracy on training set
///
/// **Performance:**
/// - Inference time: <100ms on iPhone 8+ with Neural Engine
/// - Memory: ~100-150MB (model) + ~1-2MB (tokenizer)
/// - Offline capability: Works without network connection
///
/// ## Typical Usage
///
/// ```swift
/// @Dependency(\.classifierService) var classifier
///
/// let result = try await classifier.classify("spent 50 dollars at whole foods")
/// print("Category: \(result.category)")  // budget
/// print("Confidence: \(result.confidence)")  // 0.92
///
/// if result.shouldUseFallback {
///     // Confidence < 0.75, fallback to backend classification
/// } else {
///     // Use on-device classification result
/// }
/// ```
///
/// ## Error Handling
///
/// The service may throw `AppError.classifier` in these cases:
/// - `modelLoadFailed`: CoreML model failed to load from bundle
/// - `tokenizerLoadFailed`: AutoTokenizer initialization failed
/// - `tokenizationFailed`: Input text tokenization failed (e.g., empty input)
/// - `inferenceFailed`: CoreML inference failed
/// - `invalidCategory`: Model returned invalid category index
public protocol ClassifierServiceProtocol: Sendable {
    /// Classifies text into one of six categories using on-device CoreML inference.
    ///
    /// - Parameter text: The text to classify
    /// - Returns: ClassificationResult with predicted category, confidence, and all scores
    /// - Throws: `AppError.classifier` if classification fails
    ///
    /// **Example:**
    /// ```swift
    /// let result = try await classify("milk eggs and bread")
    /// // result.category == .SHOPPING
    /// // result.confidence == 0.88
    /// ```
    func classify(_ text: String) async throws -> ClassificationResult
}
