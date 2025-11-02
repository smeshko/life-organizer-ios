import Foundation
@preconcurrency import Speech
@preconcurrency import AVFoundation
import Framework

public struct SpeechToTextService: SpeechToTextServiceProtocol, Sendable {
    /// The speech recognizer instance used for all recognition tasks.
    ///
    /// Marked as `nonisolated(unsafe)` because:
    /// - The recognizer instance is immutable after initialization
    /// - All operations are thread-safe as per Apple's documentation
    /// - The recognizer is created once during init and never modified
    private nonisolated(unsafe) let recognizer: (any SpeechRecognizerProtocol)?

    public init(recognizer: (any SpeechRecognizerProtocol)? = SFSpeechRecognizer(locale: .current)) {
        self.recognizer = recognizer
    }

    public func authorizationStatus() -> AuthorizationStatus {
        return AuthorizationStatus(from: SFSpeechRecognizer.authorizationStatus())
    }

    public func requestAuthorization() async throws -> AuthorizationStatus {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        return AuthorizationStatus(from: status)
    }

    public func recognize(audioFileURL: URL) async throws -> String {
        // Check authorization
        guard authorizationStatus() == .authorized else {
            throw AppError.speechRecognition(.notAuthorized)
        }

        // Check recognizer availability
        guard let recognizer = recognizer, recognizer.isAvailable else {
            throw AppError.speechRecognition(.recognizerUnavailable)
        }

        // Create recognition request
        let request = SFSpeechURLRecognitionRequest(url: audioFileURL)
        request.shouldReportPartialResults = false

        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: AppError.speechRecognition(.recognitionFailed(error.localizedDescription)))
                    return
                }

                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }

    public func recognizeFromMicrophone() -> AsyncThrowingStream<RecognitionResult, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                // Check authorization
                guard authorizationStatus() == .authorized else {
                    continuation.finish(throwing: AppError.speechRecognition(.notAuthorized))
                    return
                }

                // Check recognizer availability
                guard let recognizer = recognizer, recognizer.isAvailable else {
                    continuation.finish(throwing: AppError.speechRecognition(.recognizerUnavailable))
                    return
                }

                // Configure audio session (iOS only)
                #if !os(macOS)
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    continuation.finish(throwing: AppError.speechRecognition(.audioSessionFailed(error.localizedDescription)))
                    return
                }
                #endif

                let audioEngine = AVAudioEngine()
                let request = SFSpeechAudioBufferRecognitionRequest()
                request.shouldReportPartialResults = true

                let inputNode = audioEngine.inputNode
                let recordingFormat = inputNode.outputFormat(forBus: 0)

                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    request.append(buffer)
                }

                audioEngine.prepare()

                do {
                    try audioEngine.start()
                } catch {
                    continuation.finish(throwing: AppError.speechRecognition(.audioEngineUnavailable))
                    return
                }

                let recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                    if let error = error {
                        audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        request.endAudio()
                        #if !os(macOS)
                        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                        #endif
                        continuation.finish(throwing: AppError.speechRecognition(.recognitionFailed(error.localizedDescription)))
                        return
                    }

                    if let result = result {
                        let recognitionResult = RecognitionResult(
                            text: result.bestTranscription.formattedString,
                            isFinal: result.isFinal
                        )
                        continuation.yield(recognitionResult)

                        if result.isFinal {
                            audioEngine.stop()
                            inputNode.removeTap(onBus: 0)
                            request.endAudio()
                            #if !os(macOS)
                            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                            #endif
                            continuation.finish()
                        }
                    }
                }

                continuation.onTermination = { @Sendable _ in
                    recognitionTask.cancel()
                    audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    request.endAudio()
                    #if !os(macOS)
                    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                    #endif
                }
            }
        }
    }
}
