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

            Divider()
                .padding(.vertical)

            // Speech-to-Text Test Section
            VStack(spacing: 16) {
                Text("Speech-to-Text Test")
                    .font(.headline)

                // Recording button
                Button {
                    if store.isRecording {
                        store.send(.stopRecordingButtonTapped)
                    } else {
                        store.send(.startRecordingButtonTapped)
                    }
                } label: {
                    HStack {
                        Image(systemName: store.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title2)
                        Text(store.isRecording ? "Stop Recording" : "Start Recording")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(store.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                // Transcribed text display
                if !store.transcribedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Transcription:")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(store.transcribedText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                // Error message display
                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
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
