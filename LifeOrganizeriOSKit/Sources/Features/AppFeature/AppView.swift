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
        ZStack {
            // Background
            Color.lifeBackground
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss keyboard on tap
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }

            VStack(spacing: .lifeSpacingLG) {
                Spacer()

                // Greeting headline
                Text("How can I help you today?")
                    .font(.lifeTitle1)
                    .foregroundColor(.lifeTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .lifeSpacingXL)

                // Input field container
                HStack(spacing: .lifeSpacingSM) {
                    // Text field
                    TextField(
                        "Message",
                        text: Binding(
                            get: { store.inputText },
                            set: { store.send(.inputTextChanged($0)) }
                        )
                    )
                    .font(.lifeBody)
                    .foregroundColor(.lifeTextPrimary)
                    .padding(.horizontal, .lifeSpacingMD)
                    .frame(height: 44)

                    // Show send button when text exists, mic button otherwise
                    if !store.inputText.isEmpty {
                        // Send button
                        Button {
                            store.send(.sendButtonTapped)
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.lifePrimary)
                        }
                        .padding(.trailing, .lifeSpacingXS)
                        .padding(.vertical, 4)
                    } else {
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
                        .padding(.vertical, 4)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: .lifeRadiusPill)
                        .fill(Color.lifeSurface)
                )
                .lifeShadowSubtle()
                .padding(.horizontal, .lifeSpacingMD)

                Spacer()
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
