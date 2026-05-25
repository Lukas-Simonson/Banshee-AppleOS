import Core
import Foundation

public protocol LocalEpisodeDataSourceContract: Sendable {
    func observeEpisodes(with podcastID: UUID, order: Episode.Order) async throws(CoreError) -> AsyncSequence<[CachedEpisode], any Error>
    
    func episodes(with podcastID: UUID) async throws(CoreError) -> [CachedEpisode]
    
    func upsert(_ episodes: [Episode], with podcastID: UUID) async throws(CoreError)
    
    func updateEpisodeCompletion(with id: UUID, isComplete: Bool) async throws(CoreError)
}
