import Testing
import Speech
import Framework
@testable import SpeechToTextService

@Suite("SpeechToTextService Authorization Tests")
struct SpeechToTextServiceAuthorizationTests {

    @Test("Authorization status returns current status")
    func authorizationStatusReturnsCurrentStatus() async {
        let service = MockSpeechToTextService(authorizationStatus: .authorized)

        let status = service.authorizationStatus()

        #expect(status == .authorized)
    }

    @Test("Authorization status returns denied when configured")
    func authorizationStatusReturnsDenied() async {
        let service = MockSpeechToTextService(authorizationStatus: .denied)

        let status = service.authorizationStatus()

        #expect(status == .denied)
    }

    @Test("Request authorization succeeds when authorized")
    func requestAuthorizationSucceeds() async throws {
        let service = MockSpeechToTextService(authorizationStatus: .authorized)

        let status = try await service.requestAuthorization()

        #expect(status == .authorized)
    }

    @Test("Request authorization fails when denied")
    func requestAuthorizationFailsWhenDenied() async {
        let service = MockSpeechToTextService(
            authorizationStatus: .denied,
            shouldSimulateError: true,
            errorToThrow: AppError.speechRecognition(.authorizationDenied)
        )

        await #expect(throws: AppError.self) {
            try await service.requestAuthorization()
        }
    }

    @Test("Request authorization fails when restricted")
    func requestAuthorizationFailsWhenRestricted() async {
        let service = MockSpeechToTextService(
            authorizationStatus: .restricted,
            shouldSimulateError: true,
            errorToThrow: AppError.speechRecognition(.authorizationRestricted)
        )

        await #expect(throws: AppError.self) {
            try await service.requestAuthorization()
        }
    }
}
