import ComposableArchitecture
import ActionHandlerFeature
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
        public var actionHandler = ActionHandlerFeature.State()
        public var debug = DebugFeature.State()

        public init() {}
    }

    public enum Action {
        case tabSelected(State.Tab)
        case actionHandler(ActionHandlerFeature.Action)
        case debug(DebugFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .actionHandler, .debug:
                return .none
            }
        }

        Scope(state: \.actionHandler, action: \.actionHandler) {
            ActionHandlerFeature()
        }

        Scope(state: \.debug, action: \.debug) {
            DebugFeature()
        }
    }
}
