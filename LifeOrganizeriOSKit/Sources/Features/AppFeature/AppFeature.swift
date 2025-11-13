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

        public init() {
            self.actionHandler = ActionHandlerFeature.State()
        }
    }

    /// The actions that can be performed in the app.
    public enum Action {
        case actionHandler(ActionHandlerFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.actionHandler, action: \.actionHandler) {
            ActionHandlerFeature()
        }
    }
}
