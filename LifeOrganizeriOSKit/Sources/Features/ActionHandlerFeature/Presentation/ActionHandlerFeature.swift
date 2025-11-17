import Foundation
import Framework
import ComposableArchitecture
import Entities
import SpeechToTextService
import ClassifierService

/// TCA reducer for handling user input (text and voice) and processing via backend API.
///
/// ActionHandlerFeature is a self-contained module responsible for:
/// - Capturing text input from the user
/// - Recording and transcribing voice input via SpeechToTextService
/// - Sending processed input to the backend via ActionHandlerRepository
/// - Managing loading states and error handling
@Reducer
public struct ActionHandlerFeature {
    public init() {}

    @Dependency(\.speechToTextService) var speechToTextService
    @Dependency(\.actionHandlerRepository) var actionHandlerRepository
    @Dependency(\.classifierService) var classifierService

    @ObservableState
    public struct State: Equatable {
        public var inputText: String = ""
        public var isRecording: Bool = false
        public var isLoading: Bool = false
        public var transcribedText: String = ""
        public var errorMessage: String?
        public var processingResult: ProcessingResponse?

        public init() {}
    }

    public enum Action {
        case inputTextChanged(String)
        case sendButtonTapped
        case startRecordingButtonTapped
        case stopRecordingButtonTapped
        case recognitionResultReceived(String, isFinal: Bool)
        case recognitionError(Error)
        case recognitionCompleted
        case processingSuccess(ProcessingResponse)
        case processingFailure(Error)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .inputTextChanged(let text):
                state.inputText = text
                state.processingResult = nil
                return .none

            case .sendButtonTapped:
                guard !state.inputText.isEmpty else { return .none }
                state.isLoading = true
                state.errorMessage = nil
                state.processingResult = nil

                let inputText = state.inputText
                return .run { send in
                    @Dependency(\.actionHandlerRepository) var repository
                    @Dependency(\.classifierService) var classifier

                    do {
                        // Classify input to get category
                        let classification = try await classifier.classify(inputText)
                        let category = classification.category
                        
                        let responses = try await repository.processAction(input: inputText, category: category)
                        // TODO: Handle multiple responses in UI - for now, show first result
                        // Multi-transaction UI support requires updating State to store [ProcessingResponse]
                        if let firstResponse = responses.first {
                            await send(.processingSuccess(firstResponse))
                        }
                    } catch {
                        await send(.processingFailure(error))
                    }
                }
                .cancellable(id: "processing")

            case .startRecordingButtonTapped:
                state.isRecording = true
                state.errorMessage = nil
                state.transcribedText = ""

                return .run { send in
                    @Dependency(\.speechToTextService) var speechService

                    do {
                        let status = await speechService.authorizationStatus()
                        if status != .authorized {
                            let newStatus = try await speechService.requestAuthorization()
                            guard newStatus == .authorized else {
                                throw AppError.speechRecognition(.authorizationDenied)
                            }
                        }

                        for try await result in speechService.recognizeFromMicrophone() {
                            await send(.recognitionResultReceived(result.text, isFinal: result.isFinal))
                        }

                        await send(.recognitionCompleted)
                    } catch {
                        await send(.recognitionError(error))
                    }
                }
                .cancellable(id: "recording")

            case .stopRecordingButtonTapped:
                state.isRecording = false
                return .cancel(id: "recording")

            case let .recognitionResultReceived(text, isFinal):
                state.inputText = text
                state.transcribedText = text
                return .none

            case .recognitionCompleted:
                state.isRecording = false
                return .none

            case let .recognitionError(error):
                state.isRecording = false
                state.errorMessage = "Error: \(error.localizedDescription)"
                return .none

            case .processingSuccess(let response):
                state.inputText = ""
                state.isLoading = false
                state.processingResult = response
                return .none

            case .processingFailure(let error):
                state.isLoading = false
                state.errorMessage = "Error: \(error.localizedDescription)"
                return .none
            }
        }
    }
}
