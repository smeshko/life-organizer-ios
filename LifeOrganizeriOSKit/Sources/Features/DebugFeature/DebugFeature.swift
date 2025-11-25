import ComposableArchitecture
import AppFeature
import LogViewerFeature

@Reducer
public struct DebugFeature {

    @Reducer
    public enum Destination {
        case classifierTest(ClassifierTestFeature)
        case logViewer(LogViewerFeature)
    }

    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?

        public init() {}
    }

    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case classifierTestTapped
        case logViewerTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .classifierTestTapped:
                state.destination = .classifierTest(ClassifierTestFeature.State())
                return .none

            case .logViewerTapped:
                state.destination = .logViewer(LogViewerFeature.State())
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// Explicit Equatable conformance for Destination.State
extension DebugFeature.Destination.State: Equatable {
    public static func == (lhs: DebugFeature.Destination.State, rhs: DebugFeature.Destination.State) -> Bool {
        switch (lhs, rhs) {
        case let (.classifierTest(lhsState), .classifierTest(rhsState)):
            return lhsState == rhsState
        case let (.logViewer(lhsState), .logViewer(rhsState)):
            return lhsState == rhsState
        default:
            return false
        }
    }
}
