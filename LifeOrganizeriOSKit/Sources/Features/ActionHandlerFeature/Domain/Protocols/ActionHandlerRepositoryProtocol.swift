import Foundation
import Entities

protocol ActionHandlerRepositoryProtocol: Sendable {
    func processAction(input: String) async throws -> ProcessingResponse
}
