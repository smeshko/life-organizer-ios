import Foundation
import Entities

protocol ActionHandlerRemoteDataSourceProtocol: Sendable {
    func processAction(input: String) async throws -> [ProcessingResponse]
    func processAction(input: String, category: String?) async throws -> [ProcessingResponse]
}
