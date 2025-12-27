import Core
import Foundation

public protocol RemotePlayerDataSourceContract: Sendable {
    func episode(with id: UUID, baseURL: String, token: String) async throws(RemotePlayerDataSourceError) -> Episode

    func updateProgress(
        episodeId: UUID,
        baseURL: String,
        token: String,
        isCompleted: Bool,
        duration: Int
    ) async throws(RemotePlayerDataSourceError)
}

public enum RemotePlayerDataSourceError: String, LocalizedError {
    case invalidURL = "Invalid URL"
    case unauthorized = "Authentication required"
    case forbidden = "Access forbidden"
    case notFound = "Episode not found"
    case rateLimited = "Too many requests"
    case serverError = "Server error"
    case invalidResponseFormat = "Invalid response format"
    case networkUnavailable = "Network unavailable"
    case requestTimeout = "Request timeout"
    case unexpectedResponse = "Unexpected server response"
    case networkError = "Network error occurred"

    public var errorDescription: String? { self.rawValue }
}
