import Foundation

public protocol EpisodeRepositoryContract: Sendable {
    
    var episode: Episode { get async }
    var episodeStream: AsyncSequence<Episode, Never> { get }
    
}
