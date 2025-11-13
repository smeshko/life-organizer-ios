import SwiftUI
import ComposableArchitecture
import CoreUI
import ActionHandlerFeature

/// The root view of the application.
public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack(alignment: .top) {
            ActionHandlerView(
                store: store.scope(state: \.actionHandler, action: \.actionHandler)
            )

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
