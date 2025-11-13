import SwiftUI
import ComposableArchitecture
import CoreUI

/// SwiftUI view for ActionHandlerFeature that displays input field with voice and text input.
public struct ActionHandlerView: View {
    @Bindable var store: StoreOf<ActionHandlerFeature>
    
    public init(store: StoreOf<ActionHandlerFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            // Background
            Color.lifeBackground
                .ignoresSafeArea()
            
            VStack(spacing: .lifeSpacingLG) {
                Spacer()
                
                // Greeting headline
                Text("How can I help you today?")
                    .font(.lifeTitle1)
                    .foregroundColor(.lifeTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .lifeSpacingXL)
                
                // Input field container
                HStack(alignment: .center, spacing: .lifeSpacingSM) {
                    TextField(
                        "Message",
                        text: Binding(
                            get: { store.inputText },
                            set: { store.send(.inputTextChanged($0)) }
                        ),
                        axis: .vertical
                    )
                    .lineLimit(1...4)
                    .font(.lifeBody)
                    .foregroundColor(.lifeTextPrimary)
                    .background(Color.clear)
                    
                    // Show loading spinner, send button, or mic button
                    if store.isLoading {
                        // Loading spinner
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.lifePrimary)
                            .frame(width: 40, height: 40)
                            .padding(.trailing, .lifeSpacingXS)
                    } else if !store.inputText.isEmpty {
                        // Send button
                        Button {
                            store.send(.sendButtonTapped)
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.lifePrimary)
                        }
                        .padding(.trailing, .lifeSpacingXS)
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
                    }
                }
                .padding(.vertical, .lifeSpacingSM)
                .padding(.leading, .lifeSpacingMD)
                .background(
                    RoundedRectangle(cornerRadius: .lifeRadiusXL)
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
    }
}

#Preview {
    ActionHandlerView(
        store: Store(initialState: ActionHandlerFeature.State()) {
            ActionHandlerFeature()
        }
    )
}

#Preview("Loading State") {
    ActionHandlerView(
        store: Store(
            initialState: {
                var state = ActionHandlerFeature.State()
                state.inputText = "Test message"
                state.isLoading = true
                return state
            }()
        ) {
            ActionHandlerFeature()
        }
    )
}

#Preview("Error State") {
    ActionHandlerView(
        store: Store(
            initialState: {
                var state = ActionHandlerFeature.State()
                state.errorMessage = "Network error occurred"
                return state
            }()
        ) {
            ActionHandlerFeature()
        }
    )
}

#Preview("Recording State") {
    ActionHandlerView(
        store: Store(
            initialState: {
                var state = ActionHandlerFeature.State()
                state.isRecording = true
                return state
            }()
        ) {
            ActionHandlerFeature()
        }
    )
}
