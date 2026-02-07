import Foundation

public protocol EpisodeListInteractorContract: AnyObject, Sendable {
    var order: Episode.Order { get }
    var episodeStream: AsyncSequence<[Episode], Never> { get }
    
    func updateOrder(_ newOrder: Episode.Order)
    func refresh(force: Bool) async throws(CoreError)
    func stream(podcast: Podcast)
}
