import Testing
import Speech
import Framework
@testable import SpeechToTextService

@Suite("SpeechToTextService Error Handling Tests")
struct SpeechToTextServiceErrorHandlingTests {

    // MARK: - Authorization Errors

    @Test("Not authorized error has correct description")
    func notAuthorizedErrorHasCorrectDescription() {
        let error = AppError.speechRecognition(.notAuthorized)

        #expect(error.localizedDescription.contains("not authorized"))
    }

    @Test("Authorization denied error has correct description")
    func authorizationDeniedErrorHasCorrectDescription() {
        let error = AppError.speechRecognition(.authorizationDenied)

        #expect(error.localizedDescription.contains("denied"))
    }

    @Test("Authorization restricted error has correct description")
    func authorizationRestrictedErrorHasCorrectDescription() {
        let error = AppError.speechRecognition(.authorizationRestricted)

        #expect(error.localizedDescription.contains("restricted"))
    }

    // MARK: - Recognition Errors

    @Test("Recognizer unavailable error has correct description")
    func recognizerUnavailableErrorHasCorrectDescription() {
        let error = AppError.speechRecognition(.recognizerUnavailable)

        #expect(error.localizedDescription.contains("unavailable"))
    }

    @Test("Audio engine unavailable error has correct description")
    func audioEngineUnavailableErrorHasCorrectDescription() {
        let error = AppError.speechRecognition(.audioEngineUnavailable)

        #expect(error.localizedDescription.contains("Audio engine"))
    }

    @Test("Recognition failed error includes message")
    func recognitionFailedErrorIncludesMessage() {
        let error = AppError.speechRecognition(.recognitionFailed("Custom error message"))

        #expect(error.localizedDescription.contains("Custom error message"))
    }

    @Test("Invalid audio file error has correct description")
    func invalidAudioFileErrorHasCorrectDescription() {
        let error = AppError.speechRecognition(.invalidAudioFile)

        #expect(error.localizedDescription.contains("Invalid audio"))
    }

    @Test("Microphone access denied error has correct description")
    func microphoneAccessDeniedErrorHasCorrectDescription() {
        let error = AppError.speechRecognition(.microphoneAccessDenied)

        #expect(error.localizedDescription.contains("Microphone"))
    }

    // MARK: - Error Scenarios

    @Test("Mock service can simulate recognizer unavailable")
    func mockServiceSimulatesRecognizerUnavailable() async {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            shouldSimulateError: true,
            errorToThrow: AppError.speechRecognition(.recognizerUnavailable)
        )

        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")

        do {
            _ = try await service.recognize(audioFileURL: testURL)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .speechRecognition(.recognizerUnavailable) = error else {
                Issue.record("Expected recognizerUnavailable error")
                return
            }
        } catch {
            Issue.record("Expected AppError")
        }
    }

    @Test("Mock service can simulate recognition failure")
    func mockServiceSimulatesRecognitionFailure() async {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            shouldSimulateError: true,
            errorToThrow: AppError.speechRecognition(.recognitionFailed("Test failure"))
        )

        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")

        do {
            _ = try await service.recognize(audioFileURL: testURL)
            Issue.record("Expected error to be thrown")
        } catch let error as AppError {
            guard case .speechRecognition(.recognitionFailed(let message)) = error else {
                Issue.record("Expected recognitionFailed error")
                return
            }
            #expect(message == "Test failure")
        } catch {
            Issue.record("Expected AppError")
        }
    }

    @Test("Mock service can simulate authorization denied")
    func mockServiceSimulatesAuthorizationDenied() async {
        let service = MockSpeechToTextService(
            authorizationStatus: .denied,
            shouldSimulateError: true,
            errorToThrow: AppError.speechRecognition(.authorizationDenied)
        )

        await #expect(throws: AppError.self) {
            _ = try await service.requestAuthorization()
        }
    }
}
