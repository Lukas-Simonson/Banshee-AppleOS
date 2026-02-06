import Core
import Foundation

public protocol LocalPodcastDataSourceContract: Sendable {
    
    func podcast(with id: UUID) async throws(CoreError) -> CachedPodcast?
    
    func observePodcast(with id: UUID) async throws(CoreError) -> AsyncSequence<CachedPodcast?, any Error>
    
    func podcasts() async throws(CoreError) -> [CachedPodcast]
    
    func observePodcasts() async throws(CoreError) -> AsyncSequence<[CachedPodcast], any Error>
    
    func upsert(_ podcasts: [Podcast]) async throws(CoreError)
}
