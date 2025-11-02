import Foundation
@preconcurrency import Speech

/// Protocol abstracting speech recognition functionality.
///
/// This protocol wraps `SFSpeechRecognizer` to enable dependency injection
/// and testing. In production, `SFSpeechRecognizer` conforms to this protocol.
/// In tests, mock implementations can be injected.
public protocol SpeechRecognizerProtocol: Sendable {
    /// Whether the speech recognizer is currently available.
    var isAvailable: Bool { get }

    /// Creates a recognition task for the given request.
    ///
    /// - Parameters:
    ///   - request: The speech recognition request to process
    ///   - resultHandler: Handler called with recognition results or errors
    /// - Returns: A recognition task that can be used to monitor or cancel the operation
    func recognitionTask(
        with request: SFSpeechRecognitionRequest,
        resultHandler: @escaping @Sendable (SFSpeechRecognitionResult?, Error?) -> Void
    ) -> SFSpeechRecognitionTask
}

/// Extension making SFSpeechRecognizer conform to SpeechRecognizerProtocol.
extension SFSpeechRecognizer: SpeechRecognizerProtocol {}
