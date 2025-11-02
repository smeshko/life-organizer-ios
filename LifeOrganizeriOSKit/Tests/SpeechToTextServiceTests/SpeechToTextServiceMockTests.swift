import Testing
import Speech
import Framework
@testable import SpeechToTextService

@Suite("SpeechToTextService Mock Configuration Tests")
struct SpeechToTextServiceMockTests {

    @Test("Mock service can be configured with custom text")
    func mockServiceCanBeConfiguredWithCustomText() async {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            recognizedText: "Custom text"
        )

        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")
        let result = try? await service.recognize(audioFileURL: testURL)

        #expect(result == "Custom text")
    }

    @Test("Mock service has default simulated delay")
    func mockServiceHasDefaultDelay() async {
        let service = MockSpeechToTextService()

        let startTime = Date()
        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")
        _ = try? await service.recognize(audioFileURL: testURL)
        let elapsed = Date().timeIntervalSince(startTime)

        // Expect at least 0.1 seconds delay (100_000_000 nanoseconds)
        #expect(elapsed >= 0.09)
    }

    @Test("Mock service can customize delay")
    func mockServiceCanCustomizeDelay() async {
        // 50ms delay
        let service = MockSpeechToTextService(simulatedDelay: 50_000_000)

        let startTime = Date()
        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")
        _ = try? await service.recognize(audioFileURL: testURL)
        let elapsed = Date().timeIntervalSince(startTime)

        // Expect at least 0.05 seconds delay
        #expect(elapsed >= 0.04)
        // But less than 0.1 seconds
        #expect(elapsed < 0.1)
    }

    @Test("Mock service authorization status is configurable")
    func mockServiceAuthorizationStatusConfigurable() async {
        let service = MockSpeechToTextService(authorizationStatus: .notDetermined)

        let status = service.authorizationStatus()

        #expect(status == .notDetermined)
    }

    @Test("Mock service recognized text is configurable")
    func mockServiceRecognizedTextConfigurable() async throws {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            recognizedText: "Custom recognition result"
        )

        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")
        let result = try await service.recognize(audioFileURL: testURL)

        #expect(result == "Custom recognition result")
    }

    @Test("Mock service can simulate errors")
    func mockServiceSimulatesErrors() async {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            shouldSimulateError: true,
            errorToThrow: AppError.speechRecognition(.audioEngineUnavailable)
        )

        let testURL = URL(fileURLWithPath: "/tmp/test.m4a")

        await #expect(throws: AppError.self) {
            try await service.recognize(audioFileURL: testURL)
        }
    }

    @Test("Mock service can be configured for different states")
    func mockServiceCanBeConfiguredForDifferentStates() async {
        // Test authorization denied configuration
        let deniedService = MockSpeechToTextService(authorizationStatus: .denied)
        #expect(deniedService.authorizationStatus() == .denied)

        // Test success configuration
        let successService = MockSpeechToTextService(
            authorizationStatus: .authorized,
            recognizedText: "New text"
        )
        #expect(successService.authorizationStatus() == .authorized)

        // Test recognizer unavailable configuration
        let unavailableService = MockSpeechToTextService(
            authorizationStatus: .authorized,
            shouldSimulateError: true,
            errorToThrow: AppError.speechRecognition(.recognizerUnavailable)
        )
        #expect(unavailableService.authorizationStatus() == .authorized)
    }

    @Test("Mock service provides realistic partial results")
    func mockServiceProvidesRealisticPartialResults() async throws {
        let service = MockSpeechToTextService(
            authorizationStatus: .authorized,
            recognizedText: "One two three",
            simulatedDelay: 10_000_000  // Fast for testing
        )

        var partialResults: [String] = []
        var finalResults: [String] = []

        let stream = service.recognizeFromMicrophone()
        for try await result in stream {
            if result.isFinal {
                finalResults.append(result.text)
            } else {
                partialResults.append(result.text)
            }
        }

        // Expect incremental partial results
        #expect(partialResults.count == 2)
        #expect(partialResults[0] == "One")
        #expect(partialResults[1] == "One two")

        // Expect one final result
        #expect(finalResults.count == 1)
        #expect(finalResults[0] == "One two three")
    }
}
