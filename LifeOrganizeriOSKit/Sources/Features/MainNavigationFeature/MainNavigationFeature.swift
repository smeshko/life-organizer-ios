import ComposableArchitecture
import AppFeature
import DebugFeature

@Reducer
public struct MainNavigationFeature {

    @ObservableState
    public struct State: Equatable {
        public enum Tab: String, Hashable, Sendable {
            case main = "Main"
            case debug = "Debug"
        }

        public var selectedTab: Tab = .main
        public var app = AppFeature.State()
        public var debug = DebugFeature.State()

        public init() {}
    }

    public enum Action {
        case tabSelected(State.Tab)
        case app(AppFeature.Action)
        case debug(DebugFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .app, .debug:
                return .none
            }
        }

        Scope(state: \.app, action: \.app) {
            AppFeature()
        }

        Scope(state: \.debug, action: \.debug) {
            DebugFeature()
        }
    }
}
