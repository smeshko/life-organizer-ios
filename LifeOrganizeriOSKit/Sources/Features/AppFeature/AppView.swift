import SwiftUI
import ComposableArchitecture
import CoreUI
import MainNavigationFeature

/// The root view of the application.
public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Connection status indicator at top
            if store.showConnectionIndicator {
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
                    .padding(.top, .lifeSpacingSM)
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
                    .padding(.top, .lifeSpacingSM)
                }
            }

            // Main navigation content
            MainNavigationView(
                store: store.scope(state: \.mainNavigation, action: \.mainNavigation)
            )
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
