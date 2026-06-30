import Foundation

public protocol PodcastRepositoryContract: Sendable {
    func observePodcast(with id: UUID) -> any AsyncResultSequence<Podcast, CoreError>
    func observePodcasts() -> any AsyncResultSequence<[Podcast], CoreError>
    
    func refreshPodcast(with id: UUID, force: Bool) async throws(CoreError)
    func refreshPodcasts(force: Bool) async throws(CoreError)
    
    func addPodcast(fromRSS rssURL: URL, downloadMode: DownloadMode) async throws(CoreError)
}
