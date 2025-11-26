import ComposableArchitecture
import CoreUI
import Entities
import Framework
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
        VStack(alignment: .leading, spacing: .lifeSpacingXS) {
            // Timestamp
            Text(session.timestamp, style: .date)
                .font(.lifeCallout)
            Text(session.timestamp, style: .time)
                .font(.lifeBody)
                .foregroundColor(.lifeTextSecondary)

            // Summary
            HStack(spacing: .lifeSpacingXS) {
                Text("\(session.entries.count) logs")
                    .font(.lifeCaption)
                    .foregroundColor(.lifeTextSecondary)

                Text("•")
                    .foregroundColor(.lifeTextSecondary)

                Text(session.metadata.requestType)
                    .font(.lifeCaption)
                    .foregroundColor(.lifeTextSecondary)
            }

            // First entry preview
            if let firstEntry = session.entries.first {
                Text(firstEntry.message)
                    .font(.lifeCaption)
                    .foregroundColor(.lifeTextPrimary)
                    .lineLimit(2)
                    .padding(.top, .lifeSpacingXS)
            }
        }
        .padding(.vertical, .lifeSpacingXS)
    }
}

// Detail view for single session
public struct LogSessionDetailView: View {
    let session: LogSession

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .lifeSpacingSM) {
                // Session metadata header
                VStack(alignment: .leading, spacing: .lifeSpacingXS) {
                    Text("Session Details")
                        .font(.lifeCallout)
                    Text(session.timestamp, style: .date)
                        .font(.lifeBody)
                        .foregroundColor(.lifeTextSecondary)
                    Text(session.timestamp, style: .time)
                        .font(.lifeBody)
                        .foregroundColor(.lifeTextSecondary)
                    Text("\(session.entries.count) entries • \(session.metadata.requestType)")
                        .font(.lifeCaption)
                        .foregroundColor(.lifeTextSecondary)
                }
                .padding(.lifeSpacingMD)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.lifeSurface)
                .cornerRadius(.lifeRadiusMD)

                // Log entries
                ForEach(session.entries) { entry in
                    LogEntryRow(entry: entry)
                }
            }
            .padding(.lifeSpacingMD)
        }
        .navigationTitle("Log Session")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Log entry row (shared with ActionHandlerView)
private struct LogEntryRow: View {
    let entry: LogEntry

    var body: some View {
        if entry.level == .separator {
            // Separator row
            HStack(spacing: .lifeSpacingSM) {
                VStack { Divider() }
                Text("New Request")
                    .font(.lifeCaption)
                    .foregroundColor(.lifeTextSecondary)
                VStack { Divider() }
            }
            .padding(.vertical, .lifeSpacingSM)
            .padding(.horizontal, .lifeSpacingSM)
        } else {
            VStack(alignment: .leading, spacing: .lifeSpacingXS) {
                HStack(alignment: .top, spacing: .lifeSpacingSM) {
                    // Timestamp
                    Text(entry.timestamp, style: .time)
                        .font(.lifeCaption)
                        .foregroundColor(.lifeTextSecondary)
                        .frame(width: 50, alignment: .leading)

                    // Source
                    Text(entry.source)
                        .font(.lifeCaption)
                        .fontWeight(.medium)
                        .foregroundColor(colorForLevel(entry.level))
                        .frame(width: 100, alignment: .leading)

                    // Message
                    Text(entry.message)
                        .font(.lifeCaption)
                        .foregroundColor(.lifeTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Response data (if available)
                if let responseData = entry.responseData {
                    Text(responseData)
                        .font(.lifeCaption)
                        .foregroundColor(.lifeTextSecondary)
                        .padding(.leading, 158) // Align with message column
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, .lifeSpacingXS)
            .padding(.horizontal, .lifeSpacingSM)
            .background(colorForLevel(entry.level).opacity(0.1))
            .cornerRadius(.lifeRadiusSM)
        }
    }

    private func colorForLevel(_ level: LogLevel) -> Color {
        switch level {
        case .info:
            return .blue
        case .success:
            return .lifeSuccess
        case .error:
            return .lifeError
        case .separator:
            return .clear
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
        store: Store(initialState: LogViewerFeature.State()) {
            LogViewerFeature()
        } withDependencies: {
            $0.logViewerRepository = PreviewLogViewerRepository(sessions: LogSession.previewSessions)
        }
    )
}

#Preview("Empty State") {
    LogViewerView(
        store: Store(initialState: LogViewerFeature.State()) {
            LogViewerFeature()
        } withDependencies: {
            $0.logViewerRepository = PreviewLogViewerRepository(sessions: [])
        }
    )
}

#Preview("Loading State") {
    LogViewerView(
        store: Store(
            initialState: LogViewerFeature.State(isLoading: true)
        ) {
            LogViewerFeature()
        } withDependencies: {
            // Simulate slow loading
            $0.logViewerRepository = PreviewLogViewerRepository(sessions: [], delay: 10)
        }
    )
}

#Preview("Session Detail") {
    NavigationStack {
        LogSessionDetailView(session: LogSession.previewSessions[0])
    }
}

// MARK: - Preview Repository

private struct PreviewLogViewerRepository: LogViewerRepositoryProtocol {
    let sessions: [LogSession]
    let delay: UInt64

    init(sessions: [LogSession], delay: UInt64 = 0) {
        self.sessions = sessions
        self.delay = delay
    }

    func listSessions() async throws -> [LogSession] {
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }
        return sessions.sorted { $0.timestamp > $1.timestamp }
    }

    func loadSession(id: UUID) async throws -> LogSession {
        guard let session = sessions.first(where: { $0.id == id }) else {
            throw AppError.persistence(.loadFailed("Session not found"))
        }
        return session
    }
}
