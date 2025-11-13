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
                VStack(spacing: 0) {
                    if store.isConnectedToBackend {
                        // Success indicator
                        HStack(spacing: .lifeSpacingSM) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.lifeSuccess)
                                .font(.system(size: 20))

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
                                .font(.system(size: 20))

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
                }
                .padding(.top, .lifeSpacingSM)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.showConnectionIndicator)
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
