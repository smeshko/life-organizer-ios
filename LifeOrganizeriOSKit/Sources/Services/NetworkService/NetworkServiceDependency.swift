import Dependencies

// MARK: - Dependency Key
private enum NetworkServiceKey: DependencyKey {
    static let liveValue: any NetworkServiceProtocol = NetworkService()
    static let testValue: any NetworkServiceProtocol = MockNetworkService()
}

// MARK: - Dependency Values Extension
public extension DependencyValues {
    var networkService: any NetworkServiceProtocol {
        get { self[NetworkServiceKey.self] }
        set { self[NetworkServiceKey.self] = newValue }
    }
}
