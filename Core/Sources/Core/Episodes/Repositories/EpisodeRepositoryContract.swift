import Foundation

public protocol EpisodeRepositoryContract: Sendable {
    func observeEpisodes(of podcast: Podcast, order: Episode.Order) -> AsyncResultSequence<[Episode], CoreError>
    
    func refreshEpisodes(of podcast: Podcast, force: Bool) async throws(CoreError)
}
