import Core
import Foundation

public protocol RemotePodcastDataSourceContract: Sendable {
    func getPodcasts(baseURL: String, token: String) async throws(RemotePodcastDataSourceError) -> [Podcast]
}

public enum RemotePodcastDataSourceError: String, LocalizedError {
    case invalidURL = "Server URL is Invalid"
    case unexpectedResponse = "Unexpected response from server"
    case unexpected = "An Unexpected error was encountered."
}
