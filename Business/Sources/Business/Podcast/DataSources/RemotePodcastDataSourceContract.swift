import Core
import Foundation

public protocol RemotePodcastDataSourceContract: Sendable {
    func getPodcasts(baseURL: String, token: String) async throws(CoreError) -> [Podcast]

    func getPodcast(with id: UUID, baseURL: String, token: String) async throws(CoreError) -> Podcast
    
    func getConfig(podcastID: UUID, baseURL: String, token: String) async throws(CoreError) -> (Podcast, PodcastConfig)
    
    func postConfig(_ config: PodcastConfig, baseURL: String, token: String) async throws(CoreError)
}
