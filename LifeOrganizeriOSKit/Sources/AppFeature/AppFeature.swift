import Foundation
import Framework
import ComposableArchitecture
import CoreUI

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
        public var message: String = "Welcome to your iOS app!"

        public init() {}
    }

    /// The actions that can be performed in the app.
    public enum Action {
        case onAppear
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Initialize app-level logic here
                return .none
            }
        }
    }
}
