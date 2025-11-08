import Foundation
import NetworkService
import Framework

// MARK: - Test Helpers

extension MockNetworkService {
    init(mockData: Data) {
        self.init(mockResponseProvider: { _ in mockData })
    }
}
