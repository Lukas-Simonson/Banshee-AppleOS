import Foundation

public protocol PodcastRepositoryContract: Sendable {
    func observePodcast(with id: UUID) -> AsyncResultSequence<Podcast, CoreError>
    func observePodcasts() -> AsyncResultSequence<[Podcast], CoreError>
    
    func refreshPodcast(with id: UUID, force: Bool) async throws(CoreError)
    func refreshPodcasts(force: Bool) async throws(CoreError)
}
