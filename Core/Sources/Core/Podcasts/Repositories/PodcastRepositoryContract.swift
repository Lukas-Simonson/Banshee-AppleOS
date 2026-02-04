import Foundation

public protocol PodcastRepositoryContract: Sendable {
    
    var podcasts: [Podcast] { get async }
    var podcastsStream: AsyncSequence<[Podcast], Never> { get }
    
    func refresh(force: Bool) async throws(CoreError)

    /// Fetches extra details about a podcast, including its episodes.
    func details(for podcast: Podcast, refresh: Bool) -> AsyncResultSequence<Podcast, CoreError>
    
    /// Fetches config details about a podcast.
    func config(for podcast: Podcast) async throws(CoreError) -> (Podcast, PodcastConfig)
}
