import Foundation
import Framework
import ComposableArchitecture
import CoreUI
import ActionHandlerFeature

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

    /// The root application state.
    @ObservableState
    public struct State: Equatable {
        public var actionHandler: ActionHandlerFeature.State
        public var isConnectedToBackend: Bool = false
        public var backendConnectionError: String?
        public var showConnectionIndicator: Bool = false

        public init() {
            self.actionHandler = ActionHandlerFeature.State()
        }
    }

    /// The actions that can be performed in the app.
    public enum Action {
        case actionHandler(ActionHandlerFeature.Action)
        case onAppear
        case statusCheckCompleted(Result<StatusResponseDTO, Error>)
        case hideConnectionIndicator
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Check backend connection status at app startup
                return .run { send in
                    @Dependency(\.networkService) var networkService
                    do {
                        let status: StatusResponseDTO = try await networkService.sendRequest(
                            to: AppEndpoint.status
                        )
                        await send(.statusCheckCompleted(.success(status)))
                    } catch {
                        await send(.statusCheckCompleted(.failure(error)))
                    }
                }

            case .statusCheckCompleted(.success(let status)):
                state.isConnectedToBackend = true
                state.backendConnectionError = nil
                state.showConnectionIndicator = true
                print("✅ Connected to backend API v\(status.apiVersion)")

                // Hide indicator after 2.5 seconds
                return .run { send in
                    try await Task.sleep(for: .seconds(2.5))
                    await send(.hideConnectionIndicator)
                }

            case .statusCheckCompleted(.failure(let error)):
                state.isConnectedToBackend = false
                state.backendConnectionError = error.localizedDescription
                print("❌ Backend connection failed: \(error.localizedDescription)")
                return .none

            case .hideConnectionIndicator:
                state.showConnectionIndicator = false
                return .none

            case .actionHandler:
                return .none
            }
        }

        Scope(state: \.actionHandler, action: \.actionHandler) {
            ActionHandlerFeature()
        }
    }
}
