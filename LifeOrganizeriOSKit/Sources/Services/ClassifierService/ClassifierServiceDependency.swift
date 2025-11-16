import Dependencies
import Foundation

// MARK: - Dependency Key
private enum ClassifierServiceKey: DependencyKey {
    static let liveValue: any ClassifierServiceProtocol = {
        // Synchronously block waiting for async initialization
        // This is safe because DependencyKey values are lazily evaluated
        let semaphore = DispatchSemaphore(value: 0)

        // Use a class to hold mutable state (classes are reference types and can be captured)
        final class ResultBox: @unchecked Sendable {
            var service: ClassifierService?
            var error: (any Error)?
        }

        let box = ResultBox()

        Task.detached {
            do {
                box.service = try await ClassifierService()
            } catch {
                box.error = error
            }
            semaphore.signal()
        }

        semaphore.wait()

        if let error = box.error {
            fatalError("Failed to initialize ClassifierService: \(error)")
        }

        return box.service!
    }()

    static let testValue: any ClassifierServiceProtocol = MockClassifierService()
}

// MARK: - Dependency Values Extension
public extension DependencyValues {
    var classifierService: any ClassifierServiceProtocol {
        get { self[ClassifierServiceKey.self] }
        set { self[ClassifierServiceKey.self] = newValue }
    }
}
