import ComposableArchitecture
import Foundation
import Entities

/// Feature for processing natural language input and executing actions
///
/// This feature coordinates the complete flow:
/// 1. User submits input (text or voice transcription)
/// 2. Input is sent to backend for classification
/// 3. Backend returns structured action data
/// 4. Action is routed to appropriate handler for execution
/// 5. User receives feedback (success message or error)
///
/// **Dependencies**:
/// - `actionHandlerRepository`: For backend communication
/// - `actionHandlerCoordinator`: For action execution
///
/// **Usage**:
/// ```swift
/// let store = Store(initialState: ActionHandlerFeature.State()) {
///     ActionHandlerFeature()
/// }
/// ```
@Reducer
public struct ActionHandlerFeature {
    public init() {}

    @Dependency(\.actionHandlerRepository) var repository
    @Dependency(\.actionHandlerCoordinator) var coordinator
    
    @ObservableState
    public struct State: Equatable {
        public var input: String = ""
        public var isProcessing: Bool = false
        public var result: ActionResult?
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action {
        // User actions
        case inputChanged(String)
        case submitButtonTapped
        
        // Internal actions
        case actionResultReceived(ActionResult)
        case actionError(any Error)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .inputChanged(input):
                state.input = input
                state.errorMessage = nil
                return .none
                
            case .submitButtonTapped:
                // Clear previous state
                state.isProcessing = true
                state.errorMessage = nil
                state.result = nil
                
                let input = state.input
                let repository = self.repository
                let coordinator = self.coordinator

                return .run { send in
                    do {
                        // Step 1: Process input through repository
                        let actionResult = try await repository.processAction(input: input)

                        // Step 2: Execute action through coordinator (if needed)
                        if actionResult.processingResultType == .appActionRequired,
                           let action = actionResult.action {
                            _ = try await coordinator.route(action)
                        }

                        // Step 3: Send result back to reducer
                        await send(.actionResultReceived(actionResult))
                    } catch {
                        await send(.actionError(error))
                    }
                }
                
            case let .actionResultReceived(result):
                state.isProcessing = false
                state.result = result
                // Clear input on success
                state.input = ""
                return .none
                
            case let .actionError(error):
                state.isProcessing = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}

