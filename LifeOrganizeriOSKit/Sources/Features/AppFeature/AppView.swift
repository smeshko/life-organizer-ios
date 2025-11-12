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
        ZStack(alignment: .bottom) {
            // Background
            Color.lifeBackground
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Input field container
                HStack(spacing: .lifeSpacingSM) {
                    // Text field
                    TextField(
                        "Message",
                        text: Binding(
                            get: { store.inputText },
                            set: { store.send(.inputTextChanged($0)) }
                        ),
                        axis: .vertical
                    )
                    .font(.lifeBody)
                    .foregroundColor(.lifeTextPrimary)
                    .padding(.lifeSpacingMD)
                    .lineLimit(1...6)

                    // Microphone button
                    Button {
                        if store.isRecording {
                            store.send(.stopRecordingButtonTapped)
                        } else {
                            store.send(.startRecordingButtonTapped)
                        }
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(store.isRecording ? .white : .lifeIconDefault)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(store.isRecording ? Color.lifePrimary : Color.lifeSurface)
                            )
                    }
                    .padding(.trailing, .lifeSpacingXS)
                }
                .padding(.horizontal, .lifeSpacingMD)
                .padding(.vertical, .lifeSpacingSM)
                .background(
                    RoundedRectangle(cornerRadius: .lifeRadiusLG)
                        .fill(Color.lifeSurface)
                )
                .lifeShadowSubtle()
                .padding(.horizontal, .lifeSpacingMD)
                .padding(.bottom, .lifeSpacingMD)
            }

            // Error overlay (if needed)
            if let errorMessage = store.errorMessage {
                VStack {
                    Text(errorMessage)
                        .font(.lifeCaption)
                        .foregroundColor(.red)
                        .padding(.lifeSpacingSM)
                        .background(
                            RoundedRectangle(cornerRadius: .lifeRadiusSM)
                                .fill(Color.red.opacity(0.1))
                        )
                        .padding(.lifeSpacingMD)
                    Spacer()
                }
            }
        }
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
