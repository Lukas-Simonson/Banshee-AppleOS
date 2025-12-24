import Foundation

public protocol PodcastRepositoryContract: Sendable {
    
    var podcasts: [Podcast] { get async }
    var podcastsStream: AsyncSequence<[Podcast], Never> { get }
    
    func refresh() async throws(PodcastRepositoryError)
    
    /// Fetches extra details about a podcast, including its episodes.
    func details(for podcast: Podcast) async throws(PodcastRepositoryError) -> Podcast
}

public enum PodcastRepositoryError: String, LocalizedError {
    case missingAuthorization = "User is unauthorized, token is missing."
    case couldntGetPodcast = "Failed to retrieve podcast information from server."
}
