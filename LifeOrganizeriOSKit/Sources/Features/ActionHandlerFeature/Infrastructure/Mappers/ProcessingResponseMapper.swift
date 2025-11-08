import Foundation
import Entities
import Framework

/// Maps ProcessingResponseDTO to ProcessingResponse entity
struct ProcessingResponseMapper {
    static func toDomain(_ dto: ProcessingResponseDTO) throws -> ProcessingResponse {
        // Map action type string to enum
        guard let processingResultType = ProcessingResultType(rawValue: dto.actionType) else {
            throw AppError.actionHandler(.unknownProcessingResultType("Unknown result type: '\(dto.actionType)'. Expected 'app_action_required', 'backend_handled', or 'error'"))
        }

        // Optionally map nested app_action
        let action: Action? = try dto.appAction.map { actionDTO in
            try ActionMapper.toDomain(actionDTO)
        }

        return ProcessingResponse(
            processingResultType: processingResultType,
            action: action,
            message: dto.message
        )
    }
}
