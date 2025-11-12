import Foundation
import Framework
import ComposableArchitecture
import CoreUI
import SpeechToTextService

/// The root TCA reducer that coordinates the entire application.
///
/// `AppFeature` serves as the top-level coordinator for the app, managing the primary
/// navigation state and delegating to feature-specific reducers.
///
/// ## Usage
/// This reducer is typically used at the app level:
/// ```swift
/// @main
/// struct LifeOrganizeriOS: App {
///     let store = Store(initialState: AppFeature.State()) {
///         AppFeature()
///     }
/// }
/// ```
@Reducer
public struct AppFeature {
    /// Creates a new instance of the app feature reducer.
    public init() {}

    @Dependency(\.speechToTextService) var speechToTextService

    private enum CancelID { case recording }

    /// The root application state.
    @ObservableState
    public struct State: Equatable {
        public var message: String = "Welcome to your iOS app!"
        public var inputText: String = ""
        public var isRecording: Bool = false
        public var transcribedText: String = ""
        public var errorMessage: String?

        public init() {}
    }

    /// The actions that can be performed in the app.
    public enum Action {
        case onAppear
        case inputTextChanged(String)
        case sendButtonTapped
        case startRecordingButtonTapped
        case stopRecordingButtonTapped
        case recognitionResultReceived(String, isFinal: Bool)
        case recognitionError(Error)
        case recognitionCompleted
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Initialize app-level logic here
                return .none

            case .inputTextChanged(let text):
                state.inputText = text
                return .none

            case .sendButtonTapped:
                // TODO: Send message to backend/AI service
                // For now, just clear the input and show in transcription
                state.transcribedText = "You sent: \(state.inputText)"
                state.inputText = ""
                return .none

            case .startRecordingButtonTapped:
                state.isRecording = true
                state.errorMessage = nil
                state.transcribedText = ""

                return .run { send in
                    @Dependency(\.speechToTextService) var speechService

                    do {
                        // Check authorization status
                        let status = await speechService.authorizationStatus()
                        if status != .authorized {
                            let newStatus = try await speechService.requestAuthorization()
                            guard newStatus == .authorized else {
                                throw AppError.speechRecognition(.authorizationDenied)
                            }
                        }

                        // Start recognition
                        for try await result in speechService.recognizeFromMicrophone() {
                            await send(.recognitionResultReceived(result.text, isFinal: result.isFinal))
                        }

                        // When the stream completes naturally, notify that recording is done
                        await send(.recognitionCompleted)
                    } catch {
                        await send(.recognitionError(error))
                    }
                }
                .cancellable(id: CancelID.recording)

            case .stopRecordingButtonTapped:
                state.isRecording = false
                return .cancel(id: CancelID.recording)

            case let .recognitionResultReceived(text, isFinal):
                state.inputText = text
                state.transcribedText = text
                // Don't stop recording on final results - wait for stream completion
                return .none

            case .recognitionCompleted:
                state.isRecording = false
                return .none

            case let .recognitionError(error):
                state.isRecording = false
                state.errorMessage = "Error: \(error.localizedDescription)"
                return .none
            }
        }
    }
}
