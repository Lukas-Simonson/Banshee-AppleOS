import Foundation

public protocol PodcastDetailInteractor: Sendable {
    
    var podcast: Podcast { get async }
    var podcastStream: AsyncSequence<Podcast, Never> { get }
    
    var episodes: [Episode] { get async }
    var episodesStream: AsyncSequence<[Episode], Never> { get }
    
    func refresh(force: Bool) async throws(CoreError)
    
    func config() async throws(CoreError) -> (Podcast, PodcastConfig)
    
    func update(_ config: PodcastConfig) async throws(CoreError)
}
