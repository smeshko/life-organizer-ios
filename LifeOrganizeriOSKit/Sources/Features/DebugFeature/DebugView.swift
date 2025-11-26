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
                classifierTestButton
                logViewerButton
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

    private var classifierTestButton: some View {
        Button {
            store.send(.classifierTestTapped)
        } label: {
            HStack {
                Label {
                    Text("Test Classifier")
                        .foregroundStyle(Color.lifeTextPrimary)
                        .font(.lifeBody)
                } icon: {
                    Image(systemName: "brain")
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.lifeTextSecondary)
                    .font(.lifeIconSM)
            }
        }
    }

    private var logViewerButton: some View {
        Button {
            store.send(.logViewerTapped)
        } label: {
            HStack {
                Label {
                    Text("View Logs")
                        .foregroundStyle(Color.lifeTextPrimary)
                        .font(.lifeBody)
                } icon: {
                    Image(systemName: "doc.text")
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
