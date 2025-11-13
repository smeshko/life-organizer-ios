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
        ActionHandlerView(
            store: store.scope(state: \.actionHandler, action: \.actionHandler)
        )
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
