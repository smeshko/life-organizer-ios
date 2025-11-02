import Foundation
@preconcurrency import Speech

/// Protocol defining the speech-to-text conversion interface.
///
/// `SpeechToTextServiceProtocol` provides a clean abstraction over Apple's Speech framework,
/// designed for converting spoken audio into text with support for real-time transcription.
///
/// ## Design Principles
/// - **Privacy-first**: Uses on-device recognition when possible
/// - **Async-first**: Built for Swift's modern concurrency model
/// - **Authorization-aware**: Explicit authorization management
/// - **Flexible input**: Supports microphone, audio files, and audio buffers
///
/// ## Typical Usage
/// ```swift
/// // Check authorization
/// let status = await speechService.authorizationStatus()
/// guard status == .authorized else {
///     try await speechService.requestAuthorization()
/// }
///
/// // One-shot recognition
/// let text = try await speechService.recognize(audioFileURL: fileURL)
///
/// // Real-time recognition
/// for try await result in speechService.recognizeFromMicrophone() {
///     print("Partial: \(result.text)")
///     if result.isFinal {
///         print("Final: \(result.text)")
///         break
///     }
/// }
/// ```
public protocol SpeechToTextServiceProtocol: Sendable {
    /// Returns the current speech recognition authorization status.
    ///
    /// - Returns: The authorization status for speech recognition
    func authorizationStatus() -> SFSpeechRecognizerAuthorizationStatus

    /// Requests authorization for speech recognition.
    ///
    /// This method prompts the user for permission to use speech recognition.
    /// The result will be either `.authorized` or `.denied`.
    ///
    /// - Returns: The authorization status after the request completes
    /// - Throws: `AppError` if authorization fails or is denied
    func requestAuthorization() async throws -> SFSpeechRecognizerAuthorizationStatus

    /// Recognizes speech from an audio file.
    ///
    /// Performs one-shot speech recognition on a pre-recorded audio file.
    /// This is ideal for processing recorded audio that's already been captured.
    ///
    /// - Parameter audioFileURL: The URL of the audio file to recognize
    /// - Returns: The recognized text from the audio file
    /// - Throws: `AppError` if recognition fails or authorization is denied
    func recognize(audioFileURL: URL) async throws -> String

    /// Recognizes speech from the microphone in real-time.
    ///
    /// Provides an asynchronous stream of recognition results as the user speaks.
    /// Each result contains partial transcription text and a flag indicating
    /// whether it's the final result.
    ///
    /// The stream continues until:
    /// - The user stops speaking (silence detected)
    /// - The stream is cancelled
    /// - An error occurs
    ///
    /// - Returns: An async stream of recognition results
    /// - Throws: `AppError` if recognition fails or authorization is denied
    func recognizeFromMicrophone() -> AsyncThrowingStream<RecognitionResult, Error>

    /// Recognizes speech from an audio buffer request.
    ///
    /// Provides real-time recognition from a custom audio buffer source.
    /// This is useful for advanced use cases where you're managing audio capture
    /// yourself or need fine-grained control over the audio input.
    ///
    /// - Parameter request: The speech recognition request with audio buffer
    /// - Returns: An async stream of recognition results
    /// - Throws: `AppError` if recognition fails or authorization is denied
    func recognize(request: SFSpeechAudioBufferRecognitionRequest) -> AsyncThrowingStream<RecognitionResult, Error>
}

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
