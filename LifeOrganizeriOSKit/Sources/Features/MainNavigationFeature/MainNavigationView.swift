import ComposableArchitecture
import SwiftUI
import AppFeature
import DebugFeature

public struct MainNavigationView: View {
    @Bindable var store: StoreOf<MainNavigationFeature>

    public init(store: StoreOf<MainNavigationFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            AppView(
                store: store.scope(state: \.app, action: \.app)
            )
            .tabItem {
                Label("Main", systemImage: "house")
            }
            .tag(MainNavigationFeature.State.Tab.main)

            DebugView(
                store: store.scope(state: \.debug, action: \.debug)
            )
            .tabItem {
                Label("Debug", systemImage: "ant")
            }
            .tag(MainNavigationFeature.State.Tab.debug)
        }
    }
}

#Preview {
    MainNavigationView(
        store: Store(initialState: MainNavigationFeature.State()) {
            MainNavigationFeature()
        }
    )
}
