import Foundation
import Entities
import ClassifierService

protocol ActionHandlerRepositoryProtocol: Sendable {
    func processAction(input: String, category: TextCategory) async throws -> [ProcessingResponse]
}
