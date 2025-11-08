import Foundation

// MARK: - Action Handler Errors
public enum ActionHandlerError: Error, Equatable {
    case invalidAction(String)
    case handlerNotFound(String)
    case unknownProcessingResultType(String)
    case invalidResponse(String)
}

extension ActionHandlerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAction(let message):
            return "Invalid action: \(message)"
        case .handlerNotFound(let message):
            return "Handler not found: \(message)"
        case .unknownProcessingResultType(let type):
            return "Unknown processing result type: \(type)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        }
    }
}

/// Centralized error type for the application
public enum AppError: Error, Equatable {
    case network(NetworkError)
    case persistence(PersistenceError)
    case speechRecognition(SpeechRecognitionError)
    case xlsx(XLSXError)
    case actionHandler(ActionHandlerError)
    case iCloudSync(iCloudSyncError)
    // Add your custom service errors here
    // case yourService(YourServiceError)

    case unknown(String)
}

// MARK: - Network Errors
public enum NetworkError: Error, Equatable {
    case invalidURL
    case noConnection
    case timeout
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case clientError(statusCode: Int, message: String)
    case decodingFailed(String)
    case requestFailed(String)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .clientError(let statusCode, let message):
            return "Client error (\(statusCode)): \(message)"
        case .decodingFailed(let message):
            return "Failed to decode response: \(message)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        }
    }
}

// MARK: - Persistence Errors
public enum PersistenceError: Error, Equatable {
    case notFound
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case databaseError(String)
}

extension PersistenceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "Data not found"
        case .saveFailed(let message):
            return "Failed to save: \(message)"
        case .loadFailed(let message):
            return "Failed to load: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        }
    }
}

// MARK: - Speech Recognition Errors
public enum SpeechRecognitionError: Error, Equatable {
    case notAuthorized
    case authorizationDenied
    case authorizationRestricted
    case recognizerUnavailable
    case audioEngineUnavailable
    case audioSessionFailed(String)
    case recognitionFailed(String)
    case invalidAudioFile
    case microphoneAccessDenied
}

extension SpeechRecognitionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition not authorized"
        case .authorizationDenied:
            return "Speech recognition authorization denied by user"
        case .authorizationRestricted:
            return "Speech recognition restricted on this device"
        case .recognizerUnavailable:
            return "Speech recognizer unavailable"
        case .audioEngineUnavailable:
            return "Audio engine unavailable"
        case .audioSessionFailed(let message):
            return "Audio session configuration failed: \(message)"
        case .recognitionFailed(let message):
            return "Speech recognition failed: \(message)"
        case .invalidAudioFile:
            return "Invalid audio file"
        case .microphoneAccessDenied:
            return "Microphone access denied"
        }
    }
}

// MARK: - iCloud Sync Errors

/// Errors that can occur during iCloud file synchronization
public enum iCloudSyncError: Error, Equatable {
    /// iCloud Drive is not available (user not signed in or iCloud disabled)
    case iCloudUnavailable

    /// iCloud container not found (app entitlements issue)
    case containerNotFound

    /// File not found at the specified path
    case fileNotFound(String)

    /// Insufficient storage space in iCloud Drive
    case insufficientStorage

    /// File coordination failed (conflict or lock issue)
    case coordinationFailed(String)

    /// Upload operation failed
    case uploadFailed(String)

    /// Download operation failed
    case downloadFailed(String)
}

extension iCloudSyncError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .iCloudUnavailable:
            return "iCloud Drive is not available. Please sign in to iCloud in Settings."
        case .containerNotFound:
            return "iCloud container not found. Check app entitlements."
        case .fileNotFound(let path):
            return "File not found at path: \(path)"
        case .insufficientStorage:
            return "Insufficient storage space in iCloud Drive"
        case .coordinationFailed(let message):
            return "File coordination failed: \(message)"
        case .uploadFailed(let message):
            return "Upload to iCloud failed: \(message)"
        case .downloadFailed(let message):
            return "Download from iCloud failed: \(message)"
        }
    }
}

// MARK: - XLSX Errors

/// Errors that can occur during XLSX file operations
public enum XLSXError: Error, Equatable {
    /// The specified file was not found or is not accessible
    case fileNotFound

    /// The file is not a valid XLSX format or is corrupted
    case invalidXLSXFormat

    /// The requested sheet name does not exist in the workbook
    case sheetNotFound(String)

    /// ZIP archive operation failed (unzip or zip)
    case zipOperationFailed(String)

    /// XML parsing or structure validation failed
    case xmlParsingFailed(String)

    /// Worksheet modification operation failed
    case worksheetModificationFailed(String)

    /// Invalid input parameters provided to the service
    case invalidInputParameters(String)
}

extension XLSXError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "XLSX file not found or is not accessible"
        case .invalidXLSXFormat:
            return "Invalid XLSX file format or corrupted file"
        case .sheetNotFound(let name):
            return "Sheet '\(name)' not found in workbook"
        case .zipOperationFailed(let message):
            return "ZIP operation failed: \(message)"
        case .xmlParsingFailed(let message):
            return "XML parsing failed: \(message)"
        case .worksheetModificationFailed(let message):
            return "Failed to modify worksheet: \(message)"
        case .invalidInputParameters(let message):
            return "Invalid parameters: \(message)"
        }
    }
}

// MARK: - LocalizedError Conformance
extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.errorDescription
        case .persistence(let error):
            return error.errorDescription
        case .speechRecognition(let error):
            return error.errorDescription
        case .xlsx(let error):
            return error.errorDescription
        case .actionHandler(let error):
            return error.errorDescription
        case .iCloudSync(let error):
            return error.errorDescription
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
