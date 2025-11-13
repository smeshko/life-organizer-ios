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
        ZStack {
            ActionHandlerView(
                store: store.scope(state: \.actionHandler, action: \.actionHandler)
            )

            // Connection status indicator
            if store.showConnectionIndicator {
                VStack {
                    HStack {
                        Spacer()

                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 20))

                            Text("Connected")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.15))
                        )
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 60)

                    Spacer()
                }
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
