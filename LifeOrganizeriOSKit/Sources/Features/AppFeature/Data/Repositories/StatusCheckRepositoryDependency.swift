import ComposableArchitecture

extension StatusCheckRepository: DependencyKey {
    public static var liveValue: StatusCheckRepository {
        StatusCheckRepository()
    }

    public static var testValue: StatusCheckRepository {
        StatusCheckRepository()
    }
}

extension DependencyValues {
    public var statusCheckRepository: StatusCheckRepositoryProtocol {
        get { self[StatusCheckRepository.self] }
        set { self[StatusCheckRepository.self] = newValue as! StatusCheckRepository }
    }
}
