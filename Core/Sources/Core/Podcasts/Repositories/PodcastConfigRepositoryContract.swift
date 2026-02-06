import Foundation

public protocol PodcastConfigRepositoryContract: Sendable {
    func config(for podcast: Podcast) async throws(CoreError) -> (Podcast, PodcastConfig)
    func update(_ config: PodcastConfig) async throws(CoreError)
}
