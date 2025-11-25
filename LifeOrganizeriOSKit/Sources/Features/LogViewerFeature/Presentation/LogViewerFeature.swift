import ComposableArchitecture
import Entities
import Foundation

@Reducer
public struct LogViewerFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var sessions: [LogSession]
        public var selectedSession: LogSession?
        public var isLoading: Bool
        public var errorMessage: String?

        public init(
            sessions: [LogSession] = [],
            selectedSession: LogSession? = nil,
            isLoading: Bool = false,
            errorMessage: String? = nil
        ) {
            self.sessions = sessions
            self.selectedSession = selectedSession
            self.isLoading = isLoading
            self.errorMessage = errorMessage
        }
    }

    public enum Action: Equatable {
        case onAppear
        case loadSessions
        case sessionsLoaded([LogSession])
        case selectSession(UUID)
        case sessionLoaded(LogSession)
        case loadingFailed(String)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadSessions)

            case .loadSessions:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    @Dependency(\.logViewerRepository) var repository
                    do {
                        let sessions = try await repository.listSessions()
                        await send(.sessionsLoaded(sessions))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }

            case .sessionsLoaded(let sessions):
                state.isLoading = false
                state.sessions = sessions
                return .none

            case .selectSession(let id):
                state.isLoading = true
                return .run { send in
                    @Dependency(\.logViewerRepository) var repository
                    do {
                        let session = try await repository.loadSession(id: id)
                        await send(.sessionLoaded(session))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }

            case .sessionLoaded(let session):
                state.isLoading = false
                state.selectedSession = session
                return .none

            case .loadingFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                return .none
            }
        }
    }

    public init() {}
}
