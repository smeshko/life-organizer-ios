import SwiftUI
import ComposableArchitecture
import CoreUI

/// The root view of the application.
public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "swift")
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            Text(store.message)
                .font(.title)
                .multilineTextAlignment(.center)

            Text("Start building your features!")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
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
