import Foundation
@preconcurrency import Speech

/// Authorization status for speech recognition.
public enum AuthorizationStatus: Sendable, Equatable {
    /// The user has not yet been asked for permission.
    case notDetermined

    /// The user has denied permission.
    case denied

    /// The user has granted permission.
    case authorized

    /// Speech recognition is restricted (e.g., by parental controls).
    case restricted

    /// Creates an AuthorizationStatus from SFSpeechRecognizerAuthorizationStatus.
    init(from status: SFSpeechRecognizerAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .authorized:
            self = .authorized
        case .restricted:
            self = .restricted
        @unknown default:
            self = .notDetermined
        }
    }
}

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
    func authorizationStatus() -> AuthorizationStatus

    /// Requests authorization for speech recognition.
    ///
    /// This method prompts the user for permission to use speech recognition.
    /// The result will be either `.authorized` or `.denied`.
    ///
    /// - Returns: The authorization status after the request completes
    /// - Throws: `AppError` if authorization fails or is denied
    func requestAuthorization() async throws -> AuthorizationStatus

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
}
