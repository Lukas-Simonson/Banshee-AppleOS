import Core
import Foundation

public protocol RemotePodcastConfigDataSourceContract: Sendable {
    func getConfig(with podcastID: UUID, baseURL: String, token: String) async throws(CoreError) -> (Podcast, PodcastConfig)
    func postConfig(_ config: PodcastConfig, baseURL: String, token: String) async throws(CoreError)
}
