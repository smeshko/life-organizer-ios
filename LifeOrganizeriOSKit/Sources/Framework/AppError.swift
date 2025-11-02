import Foundation

/// Centralized error type for the application
public enum AppError: Error, Equatable {
    case network(NetworkError)
    case persistence(PersistenceError)
    case speechRecognition(SpeechRecognitionError)
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
        case .recognitionFailed(let message):
            return "Speech recognition failed: \(message)"
        case .invalidAudioFile:
            return "Invalid audio file"
        case .microphoneAccessDenied:
            return "Microphone access denied"
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
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
