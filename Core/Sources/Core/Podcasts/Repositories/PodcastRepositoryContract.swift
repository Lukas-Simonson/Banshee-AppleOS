import Foundation

public protocol PodcastRepositoryContract: Sendable {
    
    var podcasts: [Podcast] { get async }
    var podcastsStream: AsyncSequence<[Podcast], Never> { get }
    
    func refresh() async throws(PodcastRepositoryError)
}

public enum PodcastRepositoryError: LocalizedError {
    
}
