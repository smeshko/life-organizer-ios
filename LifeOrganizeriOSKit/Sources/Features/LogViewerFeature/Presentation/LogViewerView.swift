import ComposableArchitecture
import Entities
import SwiftUI

public struct LogViewerView: View {
    let store: StoreOf<LogViewerFeature>

    public init(store: StoreOf<LogViewerFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Group {
                if store.isLoading && store.sessions.isEmpty {
                    ProgressView("Loading sessions...")
                } else if let errorMessage = store.errorMessage {
                    ContentUnavailableView(
                        "Error Loading Logs",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if store.sessions.isEmpty {
                    ContentUnavailableView(
                        "No Logs Yet",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Activity logs will appear here after you process requests")
                    )
                } else {
                    sessionList
                }
            }
            .navigationTitle("Activity Logs")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }

    private var sessionList: some View {
        List {
            ForEach(store.sessions) { session in
                NavigationLink {
                    LogSessionDetailView(session: session)
                } label: {
                    SessionRow(session: session)
                }
            }
        }
    }
}

// Session row in list
private struct SessionRow: View {
    let session: LogSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Timestamp
            Text(session.timestamp, style: .date)
                .font(.headline)
            Text(session.timestamp, style: .time)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Summary
            HStack {
                Text("\(session.entries.count) logs")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("•")
                    .foregroundColor(.secondary)

                Text(session.metadata.requestType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // First entry preview
            if let firstEntry = session.entries.first {
                Text(firstEntry.message)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

// Detail view for single session
public struct LogSessionDetailView: View {
    let session: LogSession

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                // Session metadata header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session Details")
                        .font(.headline)
                    Text(session.timestamp, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(session.timestamp, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(session.entries.count) entries • \(session.metadata.requestType)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                // Log entries
                ForEach(session.entries) { entry in
                    LogEntryRow(entry: entry)
                }
            }
            .padding()
        }
        .navigationTitle("Log Session")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Log entry row (shared with ActionHandlerView)
private struct LogEntryRow: View {
    let entry: LogEntry

    var body: some View {
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
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(colorForLevel(entry.level).opacity(0.1))
        .cornerRadius(4)
    }

    private func colorForLevel(_ level: LogLevel) -> Color {
        switch level {
        case .info:
            return .blue
        case .success:
            return .green
        case .error:
            return .red
        }
    }
}

// MARK: - Preview Helpers

extension LogEntry {
    static func preview(
        level: LogLevel,
        source: String,
        message: String,
        secondsAgo: TimeInterval = 0
    ) -> LogEntry {
        LogEntry(
            timestamp: Date().addingTimeInterval(-secondsAgo),
            level: level,
            source: source,
            message: message
        )
    }
}

extension LogSession {
    static var previewSessions: [LogSession] {
        [
            LogSession(
                timestamp: Date().addingTimeInterval(-300),
                entries: [
                    .preview(level: .info, source: "ActionHandler", message: "Processing text request", secondsAgo: 305),
                    .preview(level: .info, source: "Classifier", message: "Classifying text: 'Add groceries to shopping list'", secondsAgo: 304),
                    .preview(level: .success, source: "Classifier", message: "Category: todo (confidence: 0.95)", secondsAgo: 303),
                    .preview(level: .info, source: "Network", message: "Sending request to backend", secondsAgo: 302),
                    .preview(level: .success, source: "Network", message: "Response received: 200 OK", secondsAgo: 300),
                    .preview(level: .success, source: "ActionHandler", message: "Request completed successfully", secondsAgo: 299)
                ],
                requestType: "text"
            ),
            LogSession(
                timestamp: Date().addingTimeInterval(-3600),
                entries: [
                    .preview(level: .info, source: "ActionHandler", message: "Starting voice recording", secondsAgo: 3605),
                    .preview(level: .info, source: "Speech", message: "Recording started", secondsAgo: 3604),
                    .preview(level: .info, source: "Speech", message: "Transcribed: 'Buy milk and eggs'", secondsAgo: 3602),
                    .preview(level: .error, source: "Network", message: "Connection timeout", secondsAgo: 3600)
                ],
                requestType: "voice"
            ),
            LogSession(
                timestamp: Date().addingTimeInterval(-86400),
                entries: [
                    .preview(level: .info, source: "ActionHandler", message: "Processing budget request", secondsAgo: 86405),
                    .preview(level: .success, source: "ActionHandler", message: "Budget updated: +$50.00", secondsAgo: 86400)
                ],
                requestType: "text"
            )
        ]
    }
}

#Preview("Session List") {
    LogViewerView(
        store: Store(
            initialState: LogViewerFeature.State(
                sessions: LogSession.previewSessions
            )
        ) {
            LogViewerFeature()
        }
    )
}

#Preview("Empty State") {
    LogViewerView(
        store: Store(initialState: LogViewerFeature.State()) {
            LogViewerFeature()
        }
    )
}

#Preview("Loading State") {
    LogViewerView(
        store: Store(
            initialState: LogViewerFeature.State(isLoading: true)
        ) {
            LogViewerFeature()
        }
    )
}

#Preview("Session Detail") {
    NavigationStack {
        LogSessionDetailView(session: LogSession.previewSessions[0])
    }
}
