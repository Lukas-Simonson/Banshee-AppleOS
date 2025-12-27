import Foundation

public protocol PodcastRepositoryContract: Sendable {
    
    var podcasts: [Podcast] { get async }
    var podcastsStream: AsyncSequence<[Podcast], Never> { get }
    
    func refresh(force: Bool) async throws(PodcastRepositoryError)
    
    /// Fetches extra details about a podcast, including its episodes.
    func details(for podcast: Podcast, refresh: Bool) -> AsyncResultSequence<Podcast, PodcastRepositoryError>
}

public enum PodcastRepositoryError: CoreError {
    case missingAuthorization
    case couldntGetPodcast
    case couldntPersistPodcast

    public var errorCode: UInt16 {
        switch self {
            case .missingAuthorization: 201
            case .couldntGetPodcast: 202
            case .couldntPersistPodcast: 203
        }
    }

    public var localizeableKey: LocalizedStringResource {
        switch self {
            case .missingAuthorization: "error.podcast.missingAuthorization"
            case .couldntGetPodcast: "error.podcast.couldntGetPodcast"
            case .couldntPersistPodcast: "error.podcast.couldntPersistPodcast"
        }
    }

    public var logMessage: String {
        switch self {
            case .missingAuthorization:
                "Missing authentication token - user session may have expired"
            case .couldntGetPodcast:
                "Failed to fetch podcast data from remote server"
            case .couldntPersistPodcast:
                "Failed to save podcast data to local database"
        }
    }
}
