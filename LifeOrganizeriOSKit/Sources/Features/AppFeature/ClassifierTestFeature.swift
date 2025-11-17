import Foundation
import ComposableArchitecture
import ClassifierService

/// TCA feature for testing the ClassifierService
@Reducer
public struct ClassifierTestFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var inputText: String = ""
        public var isClassifying: Bool = false
        public var classificationResult: ClassificationResult?
        public var errorMessage: String?

        public init() {}
    }

    public enum Action {
        case inputTextChanged(String)
        case classifyButtonTapped
        case classificationCompleted(Result<ClassificationResult, Error>)
    }

    @Dependency(\.classifierService) var classifierService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .inputTextChanged(let text):
                state.inputText = text
                state.errorMessage = nil
                return .none

            case .classifyButtonTapped:
                state.isClassifying = true
                state.errorMessage = nil
                state.classificationResult = nil

                let text = state.inputText

                return .run { [classifierService] send in
                    do {
                        let result = try await classifierService.classify(text)
                        await send(.classificationCompleted(.success(result)))
                    } catch {
                        await send(.classificationCompleted(.failure(error)))
                    }
                }

            case .classificationCompleted(.success(let result)):
                state.isClassifying = false
                state.classificationResult = result
                state.errorMessage = nil
                return .none

            case .classificationCompleted(.failure(let error)):
                state.isClassifying = false
                state.classificationResult = nil
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
