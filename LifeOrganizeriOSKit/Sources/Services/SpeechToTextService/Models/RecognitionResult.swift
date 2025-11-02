import Foundation

/// Represents a speech recognition result.
///
/// Contains the transcribed text and metadata about whether this is
/// a final or partial result.
public struct RecognitionResult: Sendable, Equatable {
    /// The transcribed text from the speech recognition.
    public let text: String

    /// Indicates whether this is the final result for the current utterance.
    ///
    /// When `true`, the recognition for this utterance is complete and the
    /// text will not change. When `false`, the text may be updated as more
    /// audio is processed.
    public let isFinal: Bool

    /// Creates a new recognition result.
    ///
    /// - Parameters:
    ///   - text: The recognized text
    ///   - isFinal: Whether this is the final result
    public init(text: String, isFinal: Bool) {
        self.text = text
        self.isFinal = isFinal
    }
}
