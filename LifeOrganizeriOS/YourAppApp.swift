import SwiftUI
import ComposableArchitecture
import MainNavigationFeature

@main
struct LifeOrganizeriOSApp: App {
    let store = Store(initialState: MainNavigationFeature.State()) {
        MainNavigationFeature()
    }

    var body: some Scene {
        WindowGroup {
            MainNavigationView(store: store)
        }
    }
}
