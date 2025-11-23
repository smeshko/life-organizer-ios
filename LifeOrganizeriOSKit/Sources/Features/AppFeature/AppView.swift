import SwiftUI
import ComposableArchitecture
import CoreUI
import ActionHandlerFeature
import LogViewerFeature

/// The root view of the application.
public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ActionHandlerView(
                    store: store.scope(state: \.actionHandler, action: \.actionHandler)
                )

                // Navigation buttons - positioned at top right
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            store.send(.showLogViewer)
                        } label: {
                            Text("View Logs")
                                .font(.lifeCaption)
                                .foregroundColor(.lifePrimary)
                                .padding(.horizontal, .lifeSpacingMD)
                                .padding(.vertical, .lifeSpacingSM)
                                .background(
                                    Capsule()
                                        .fill(Color.lifePrimary.opacity(0.1))
                                )
                        }
                        Button {
                            store.send(.showClassifierTest)
                        } label: {
                            Text("Test Classifier")
                                .font(.lifeCaption)
                                .foregroundColor(.lifePrimary)
                                .padding(.horizontal, .lifeSpacingMD)
                                .padding(.vertical, .lifeSpacingSM)
                                .background(
                                    Capsule()
                                        .fill(Color.lifePrimary.opacity(0.1))
                                )
                        }
                        .padding(.top, .lifeSpacingSM)
                        .padding(.trailing, .lifeSpacingMD)
                    }
                    Spacer()
                }

                // Connection status indicator - centered below safe area
                if store.showConnectionIndicator {
                    VStack {
                        if store.isConnectedToBackend {
                            // Success indicator
                            HStack(spacing: .lifeSpacingSM) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.lifeSuccess)
                                    .font(.lifeIconMD)

                                Text("Connected")
                                    .font(.lifeCaption)
                                    .foregroundColor(.lifeSuccess)
                            }
                            .padding(.horizontal, .lifeSpacingMD)
                            .padding(.vertical, .lifeSpacingSM)
                            .background(
                                Capsule()
                                    .fill(Color.lifeSuccess.opacity(0.15))
                            )
                        } else {
                            // Error indicator
                            HStack(spacing: .lifeSpacingSM) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.lifeError)
                                    .font(.lifeIconMD)

                                Text("Connection Failed")
                                    .font(.lifeCaption)
                                    .foregroundColor(.lifeError)
                            }
                            .padding(.horizontal, .lifeSpacingMD)
                            .padding(.vertical, .lifeSpacingSM)
                            .background(
                                Capsule()
                                    .fill(Color.lifeError.opacity(0.15))
                            )
                        }

                        Spacer()
                    }
                    .padding(.top, .lifeSpacingSM)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.classifierTest, action: \.classifierTest)
            ) { store in
                ClassifierTestView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.logViewer, action: \.logViewer)
            ) { store in
                LogViewerView(store: store)
            }
        }
        .animation(.lifeSpring, value: store.showConnectionIndicator)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
