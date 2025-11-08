import Foundation
import Entities

protocol ActionHandlerRemoteDataSourceProtocol: Sendable {
    func processAction(input: String) async throws -> ProcessingResponse
}
