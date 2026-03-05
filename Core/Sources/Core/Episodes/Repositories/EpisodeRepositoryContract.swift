import Foundation

public protocol EpisodeRepositoryContract: Sendable {
    func observeEpisodes(of podcast: Podcast, order: Episode.Order) -> any AsyncResultSequence<[Episode], CoreError>
    
    func refreshEpisodes(of podcast: Podcast, force: Bool) async throws(CoreError)
    
    func toggleEpisodeComplete(_ episode: Episode) async throws(CoreError)
}
