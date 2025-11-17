import CoreML
import Entities
import Foundation
import Framework
import Tokenizers

public struct ClassifierService: ClassifierServiceProtocol, Sendable {
    /// The CoreML model used for classification inference.
    ///
    /// Marked as `nonisolated(unsafe)` because:
    /// - The model instance is immutable after initialization
    /// - CoreML operations are thread-safe as per Apple's documentation
    /// - The model is loaded once during init and never modified
    private nonisolated(unsafe) let mlModel: MLModel

    /// The tokenizer for converting text to input_ids.
    ///
    /// Marked as `nonisolated(unsafe)` because:
    /// - The tokenizer instance is immutable after initialization
    /// - Caching saves 20-50ms per classification
    /// - Created once during init and never modified
    private nonisolated(unsafe) let tokenizer: any Tokenizer

    public init() async throws {
        // Load CoreML model with Neural Engine configuration
        do {
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all  // Neural Engine + GPU + CPU

            guard let modelURL = Bundle.main.url(
                forResource: "TextClassifier",
                withExtension: "mlmodelc"
            ) else {
                throw AppError.classifier(.modelLoadFailed("TextClassifier.mlmodelc not found in bundle"))
            }

            self.mlModel = try MLModel(contentsOf: modelURL, configuration: configuration)
        } catch {
            throw AppError.classifier(.modelLoadFailed("Failed to load CoreML model: \(error.localizedDescription)"))
        }

        // Load AutoTokenizer
        do {
            self.tokenizer = try await AutoTokenizer.from(pretrained: "distilbert-base-uncased")
        } catch {
            throw AppError.classifier(.tokenizerLoadFailed("Failed to load distilbert-base-uncased tokenizer: \(error.localizedDescription)"))
        }
    }

    public func classify(_ text: String) async throws -> ClassificationResult {
        let startTime = Date()

        // Step 1: Tokenization
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.classifier(.tokenizationFailed("Empty input"))
        }

        let inputIds = tokenizer(text)

        // Step 2: Truncate/pad to 128 tokens
        let maxLength = 128
        let truncatedIds = Array(inputIds.prefix(maxLength))
        let paddingLength = max(0, maxLength - truncatedIds.count)
        let paddedIds = truncatedIds + Array(repeating: 0, count: paddingLength)

        // Step 3: Generate attention mask (1 for tokens, 0 for padding)
        let attentionMask = Array(repeating: 1, count: truncatedIds.count) +
                           Array(repeating: 0, count: paddingLength)

        // Step 4: Create MLMultiArray inputs
        let inputIdsArray: MLMultiArray
        let attentionMaskArray: MLMultiArray

        do {
            inputIdsArray = try MLMultiArray(shape: [1, maxLength as NSNumber], dataType: .int32)
            attentionMaskArray = try MLMultiArray(shape: [1, maxLength as NSNumber], dataType: .int32)

            for i in 0..<maxLength {
                inputIdsArray[i] = NSNumber(value: paddedIds[i])
                attentionMaskArray[i] = NSNumber(value: attentionMask[i])
            }
        } catch {
            throw AppError.classifier(.inferenceFailed("Failed to create input arrays: \(error.localizedDescription)"))
        }

        // Step 5: Run inference
        let prediction: any MLFeatureProvider
        do {
            let input = try MLDictionaryFeatureProvider(dictionary: [
                "input_ids": inputIdsArray,
                "attention_mask": attentionMaskArray
            ])
            prediction = try await mlModel.prediction(from: input)
        } catch {
            throw AppError.classifier(.inferenceFailed("CoreML prediction failed: \(error.localizedDescription)"))
        }

        // Step 6: Extract logits and apply softmax
        guard let logitsValue = prediction.featureValue(for: "logits"),
              let logitsArray = logitsValue.multiArrayValue else {
            throw AppError.classifier(.inferenceFailed("Failed to extract logits from prediction"))
        }

        let logits = (0..<6).map { Float(truncating: logitsArray[$0]) }
        let probabilities = softmax(logits)

        // Step 7: Find max probability and map to category
        guard let (maxIndex, maxConfidence) = probabilities.enumerated().max(by: { $0.1 < $1.1 }),
              let category = TextCategory.from(index: maxIndex) else {
            throw AppError.classifier(.invalidCategory("Invalid category index"))
        }

        // Step 8: Create result with all scores
        let allScores = Dictionary(uniqueKeysWithValues:
            TextCategory.allCases.map { ($0, probabilities[$0.index]) }
        )

        let duration = Date().timeIntervalSince(startTime) * 1000  // ms
        print("🔍 Classification - Category: \(category.rawValue), Confidence: \(maxConfidence), Time: \(String(format: "%.1f", duration))ms")

        return ClassificationResult(
            category: category,
            confidence: maxConfidence,
            allScores: allScores
        )
    }

    /// Applies softmax to convert logits to probabilities
    private func softmax(_ logits: [Float]) -> [Float] {
        let maxLogit = logits.max() ?? 0
        let exps = logits.map { exp($0 - maxLogit) }
        let sumExps = exps.reduce(0, +)
        return exps.map { $0 / sumExps }
    }
}
