import ComposableArchitecture
import NetworkService

extension StatusCheckRepository: DependencyKey {
    public static var liveValue: StatusCheckRepository {
        StatusCheckRepository(networkService: NetworkService())
    }

    public static var testValue: StatusCheckRepository {
        StatusCheckRepository(networkService: NetworkService())
    }
}

extension DependencyValues {
    public var statusCheckRepository: StatusCheckRepositoryProtocol {
        get { self[StatusCheckRepository.self] }
        set { self[StatusCheckRepository.self] = newValue as! StatusCheckRepository }
    }
}
