import SwiftUI
import ComposableArchitecture
import CoreUI
import Entities

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

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Activity Log")
                            .font(.headline)

                        Spacer()

                        if !store.activityLogs.isEmpty {
                            Button {
                                store.send(.clearLogs)
                            } label: {
                                Text("Clear")
                                    .font(.caption)
                                    .foregroundColor(.lifePrimary)
                            }
                        }
                    }
                    .padding(.horizontal)

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(store.activityLogs) { entry in
                                LogEntryRow(entry: entry)
                            }
                        }
                    }
                    #if os(iOS)
                    .background(Color(.systemGray6))
                    #else
                    .background(Color.gray.opacity(0.1))
                    #endif
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Log Entry Row

private struct LogEntryRow: View {
    let entry: LogEntry

    var body: some View {
        if entry.level == .separator {
            // Separator row
            HStack {
                VStack { Divider() }
                Text("New Request")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                VStack { Divider() }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 8) {
                    // Timestamp
                    Text(entry.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 50, alignment: .leading)

                    // Source
                    Text(entry.source)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(colorForLevel(entry.level))
                        .frame(width: 100, alignment: .leading)

                    // Message
                    Text(entry.message)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Response data (if available)
                if let responseData = entry.responseData {
                    Text(responseData)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 158) // Align with message column
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(colorForLevel(entry.level).opacity(0.1))
            .cornerRadius(4)
        }
    }

    private func colorForLevel(_ level: LogLevel) -> Color {
        switch level {
        case .info:
            return .blue
        case .success:
            return .green
        case .error:
            return .red
        case .separator:
            return .clear
        }
    }
}

// MARK: - Previews

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

#Preview("With Activity Logs") {
    ActionHandlerView(
        store: Store(
            initialState: {
                var state = ActionHandlerFeature.State()
                state.activityLogs = [
                    LogEntry(level: .info, source: "ActionHandler", message: "Processing text request"),
                    LogEntry(level: .info, source: "Classifier", message: "Classifying text: 'Add groceries to shopping list'"),
                    LogEntry(level: .success, source: "Classifier", message: "Category: todo (confidence: 0.95)"),
                    LogEntry(level: .info, source: "Network", message: "Sending request to backend"),
                    LogEntry(level: .success, source: "Network", message: "Response received: 200 OK"),
                    LogEntry(level: .success, source: "ActionHandler", message: "Request completed successfully")
                ]
                return state
            }()
        ) {
            ActionHandlerFeature()
        }
    )
}

#Preview("With Error Log") {
    ActionHandlerView(
        store: Store(
            initialState: {
                var state = ActionHandlerFeature.State()
                state.activityLogs = [
                    LogEntry(level: .info, source: "ActionHandler", message: "Processing voice request"),
                    LogEntry(level: .info, source: "Speech", message: "Recording started"),
                    LogEntry(level: .info, source: "Speech", message: "Transcribed: 'Buy milk and eggs'"),
                    LogEntry(level: .error, source: "Network", message: "Connection timeout - please try again")
                ]
                return state
            }()
        ) {
            ActionHandlerFeature()
        }
    )
}
