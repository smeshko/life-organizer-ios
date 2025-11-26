import ComposableArchitecture
import SwiftUI
import CoreUI
import LogViewerFeature

public struct DebugView: View {
    @Bindable var store: StoreOf<DebugFeature>

    public init(store: StoreOf<DebugFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            List {
                DebugNavigationButton(
                    title: "Test Classifier",
                    icon: "brain",
                    action: { store.send(.classifierTestTapped) }
                )

                DebugNavigationButton(
                    title: "View Logs",
                    icon: "doc.text",
                    action: { store.send(.logViewerTapped) }
                )
            }
            .navigationTitle("Debug")
            .navigationDestination(
                item: $store.scope(state: \.destination?.classifierTest, action: \.destination.classifierTest)
            ) { store in
                ClassifierTestView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.logViewer, action: \.destination.logViewer)
            ) { store in
                LogViewerView(store: store)
            }
        }
    }
}

// MARK: - Private Components

/// Reusable navigation button for debug menu items
private struct DebugNavigationButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label {
                    Text(title)
                        .foregroundStyle(Color.lifeTextPrimary)
                        .font(.lifeBody)
                } icon: {
                    Image(systemName: icon)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.lifeTextSecondary)
                    .font(.lifeIconSM)
            }
        }
    }
}

#Preview {
    DebugView(
        store: Store(initialState: DebugFeature.State()) {
            DebugFeature()
        }
    )
}
