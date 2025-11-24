import Dependencies

// MARK: - Dependency Key
private enum ReminderServiceKey: DependencyKey {
    static let liveValue: any ReminderServiceProtocol = ReminderService()
    static let testValue: any ReminderServiceProtocol = MockReminderService()
}

// MARK: - Dependency Values Extension
public extension DependencyValues {
    var reminderService: any ReminderServiceProtocol {
        get { self[ReminderServiceKey.self] }
        set { self[ReminderServiceKey.self] = newValue }
    }
}
