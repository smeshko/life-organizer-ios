import Dependencies

// MARK: - Dependency Key
private enum SpeechToTextServiceKey: DependencyKey {
    static let liveValue: any SpeechToTextServiceProtocol = SpeechToTextService()
    static let testValue: any SpeechToTextServiceProtocol = MockSpeechToTextService()
}

// MARK: - Dependency Values Extension
public extension DependencyValues {
    var speechToTextService: any SpeechToTextServiceProtocol {
        get { self[SpeechToTextServiceKey.self] }
        set { self[SpeechToTextServiceKey.self] = newValue }
    }
}
