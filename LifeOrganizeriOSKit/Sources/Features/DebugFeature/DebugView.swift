import ComposableArchitecture
import SwiftUI
import AppFeature
import LogViewerFeature

public struct DebugView: View {
    @Bindable var store: StoreOf<DebugFeature>

    public init(store: StoreOf<DebugFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            List {
                Button {
                    store.send(.classifierTestTapped)
                } label: {
                    HStack {
                        Label("Test Classifier", systemImage: "brain")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)

                Button {
                    store.send(.logViewerTapped)
                } label: {
                    HStack {
                        Label("View Logs", systemImage: "doc.text")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)
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

#Preview {
    DebugView(
        store: Store(initialState: DebugFeature.State()) {
            DebugFeature()
        }
    )
}
