import Foundation

public protocol PodcastListInteractor: Sendable {
    
    var podcasts: [Podcast] { get async }
    var podcastsStream: AsyncSequence<[Podcast], Never> { get }
    
    func refresh(force: Bool) async throws(CoreError)
}
