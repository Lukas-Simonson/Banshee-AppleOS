import Core
import Foundation

public protocol RemotePodcastDataSourceContract: Sendable {
    func getPodcasts(baseURL: String, token: String) async throws(RemotePodcastDataSourceError) -> [Podcast]
    
    func getPodcast(with id: UUID, baseURL: String, token: String) async throws(RemotePodcastDataSourceError) -> Podcast
}

public enum RemotePodcastDataSourceError: String, LocalizedError {
    case invalidURL = "Server URL is Invalid"
    case unauthorized = "Authentication required"
    case forbidden = "Access forbidden"
    case notFound = "Podcast not found"
    case rateLimited = "Too many requests"
    case serverError = "Server error"
    case invalidResponseFormat = "Invalid response format"
    case networkUnavailable = "Network unavailable"
    case requestTimeout = "Request timeout"
    case unexpectedResponse = "Unexpected response from server"
    case unexpected = "An unexpected error was encountered"

    public var errorDescription: String? { self.rawValue }
}
