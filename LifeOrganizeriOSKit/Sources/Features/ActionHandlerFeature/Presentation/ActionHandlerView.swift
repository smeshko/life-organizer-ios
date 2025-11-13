import SwiftUI
import ComposableArchitecture
import CoreUI

/// SwiftUI view for ActionHandlerFeature that displays input field with voice and text input.
public struct ActionHandlerView: View {
    @Bindable var store: StoreOf<ActionHandlerFeature>

    public init(store: StoreOf<ActionHandlerFeature>) {
        self.store = store
    }

    /// Calculate dynamic height for text editor based on content
    /// - 1 line: 44pt (minimum)
    /// - 2 lines: 66pt
    /// - 3+ lines: 88pt (maximum, enables scrolling)
    private var textEditorHeight: CGFloat {
        let lineHeight: CGFloat = 22
        let verticalPadding: CGFloat = 10

        let lineCount = store.inputText.components(separatedBy: .newlines).count
        let cappedLineCount = min(lineCount, 3)

        return CGFloat(cappedLineCount) * lineHeight + verticalPadding * 2
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
                HStack(alignment: .bottom, spacing: .lifeSpacingSM) {
                    // Multi-line text editor
                    ZStack(alignment: .topLeading) {
                        // Placeholder text
                        if store.inputText.isEmpty {
                            Text("Message")
                                .font(.lifeBody)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, .lifeSpacingMD)
                                .padding(.top, 12)
                        }

                        TextEditor(
                            text: Binding(
                                get: { store.inputText },
                                set: { store.send(.inputTextChanged($0)) }
                            )
                        )
                        .font(.lifeBody)
                        .foregroundColor(.lifeTextPrimary)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.horizontal, .lifeSpacingMD - 5) // Adjust for TextEditor default padding
                        .frame(minHeight: 44, maxHeight: textEditorHeight)
                    }

                    // Show loading spinner, send button, or mic button
                    if store.isLoading {
                        // Loading spinner
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.lifePrimary)
                            .frame(width: 40, height: 40)
                            .padding(.trailing, .lifeSpacingXS)
                            .padding(.vertical, 4)
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
