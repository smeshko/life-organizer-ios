import Foundation

/// DTO for confirmation requests when classification is uncertain
struct ConfirmationDataDTO: Sendable, Equatable, Codable {
    /// Question to ask user for clarification
    let question: String

    /// List of possible answers the user can choose from
    let options: [String]

    /// System's initial classification guess
    let originalClassification: String

    /// Confidence score (0.0-1.0) of original classification
    let confidence: Double

    enum CodingKeys: String, CodingKey {
        case question
        case options
        case originalClassification = "original_classification"
        case confidence
    }
}
