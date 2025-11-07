import Foundation
import Entities
import Framework

/// Maps ActionResultDTO to ActionResult domain entity
struct ActionResultMapper {
    /// Transforms DTO to domain entity
    /// - Parameter dto: Action result DTO from backend
    /// - Returns: ActionResult domain entity
    /// - Throws: AppError.actionHandler if mapping fails
    static func toDomain(_ dto: ActionResultDTO) throws -> ActionResult {
        // Map processing result type
        guard let processingResultType = ProcessingResultType(rawValue: dto.actionType) else {
            throw AppError.actionHandler(.unknownProcessingResultType(dto.actionType))
        }
        
        // Map nested action if present
        let action: Action? = try dto.appAction.map { actionDTO in
            try ActionMapper.toDomain(actionDTO)
        }
        
        return ActionResult(
            processingResultType: processingResultType,
            action: action,
            message: dto.message
        )
    }
}

