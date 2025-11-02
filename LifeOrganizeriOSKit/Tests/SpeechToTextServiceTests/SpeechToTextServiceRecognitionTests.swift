import Testing
import Speech
import Framework
@testable import SpeechToTextService

@Suite("SpeechToTextService Recognition Tests")
struct SpeechToTextServiceRecognitionTests {

    // MARK: - Audio File Recognition

    @Test("Recognize from audio file succeeds")
    func recognizeFromAudioFileSucceeds() async throws {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            recognizedText: "Hello world"
        )
        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")

        let result = try await service.recognize(audioFileURL: testURL)

        #expect(result == "Hello world")
    }

    @Test("Recognize from audio file fails when not authorized")
    func recognizeFromAudioFileFailsWhenNotAuthorized() async {
        let service = MockSpeechToTextService(authorizationStatus: .denied)
        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")

        await #expect(throws: AppError.self) {
            try await service.recognize(audioFileURL: testURL)
        }
    }

    @Test("Recognize from audio file handles recognition error")
    func recognizeFromAudioFileHandlesError() async {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            shouldSimulateError: true,
            errorToThrow: AppError.speechRecognition(.recognitionFailed("Test error"))
        )
        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")

        await #expect(throws: AppError.self) {
            try await service.recognize(audioFileURL: testURL)
        }
    }

    // MARK: - Microphone Recognition

    @Test("Recognize from microphone yields partial results")
    func recognizeFromMicrophoneYieldsPartialResults() async throws {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            recognizedText: "Hello world test"
        )

        var results: [RecognitionResult] = []
        let stream = service.recognizeFromMicrophone()

        for try await result in stream {
            results.append(result)
        }

        // Expect partial results for each word
        #expect(results.count == 3)
        #expect(results[0].text == "Hello")
        #expect(results[0].isFinal == false)
        #expect(results[1].text == "Hello world")
        #expect(results[1].isFinal == false)
        #expect(results[2].text == "Hello world test")
        #expect(results[2].isFinal == true)
    }

    @Test("Recognize from microphone fails when not authorized")
    func recognizeFromMicrophoneFailsWhenNotAuthorized() async {
        let service = MockSpeechToTextService(authorizationStatus: .denied)
        let stream = service.recognizeFromMicrophone()

        await #expect(throws: AppError.self) {
            for try await _ in stream {}
        }
    }

    @Test("Recognize from microphone handles recognition error")
    func recognizeFromMicrophoneHandlesError() async {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            shouldSimulateError: true,
            errorToThrow: AppError.speechRecognition(.recognitionFailed("Test error"))
        )
        let stream = service.recognizeFromMicrophone()

        await #expect(throws: AppError.self) {
            for try await _ in stream {}
        }
    }

    // MARK: - Buffer Recognition

    @Test("Recognize from buffer yields partial results")
    func recognizeFromBufferYieldsPartialResults() async throws {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            recognizedText: "Test message"
        )
        let request = SFSpeechAudioBufferRecognitionRequest()

        var results: [RecognitionResult] = []
        let stream = service.recognize(request: request)

        for try await result in stream {
            results.append(result)
        }

        // Expect partial results for each word
        #expect(results.count == 2)
        #expect(results[0].text == "Test")
        #expect(results[0].isFinal == false)
        #expect(results[1].text == "Test message")
        #expect(results[1].isFinal == true)
    }

    @Test("Recognize from buffer fails when not authorized")
    func recognizeFromBufferFailsWhenNotAuthorized() async {
        let service = MockSpeechToTextService(authorizationStatus: .denied)
        let request = SFSpeechAudioBufferRecognitionRequest()
        let stream = service.recognize(request: request)

        await #expect(throws: AppError.self) {
            for try await _ in stream {}
        }
    }

    // MARK: - Recognition Result

    @Test("Recognition result has correct properties")
    func recognitionResultHasCorrectProperties() {
        let result = RecognitionResult(text: "Test", isFinal: false)

        #expect(result.text == "Test")
        #expect(result.isFinal == false)
    }

    @Test("Recognition result is equatable")
    func recognitionResultIsEquatable() {
        let result1 = RecognitionResult(text: "Test", isFinal: true)
        let result2 = RecognitionResult(text: "Test", isFinal: true)
        let result3 = RecognitionResult(text: "Different", isFinal: true)

        #expect(result1 == result2)
        #expect(result1 != result3)
    }
}
