import SwiftUI
import ComposableArchitecture
import AppFeature

@main
struct LifeOrganizeriOSApp: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
