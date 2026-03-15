import Core
import Foundation

public protocol RemoteEpisodeConfigDataSourceContract: Sendable {
    func getConfig(with episodeID: UUID, baseURL: String, token: String) async throws(CoreError) -> (Episode, EpisodeConfig)
    func postConfig(_ config: EpisodeConfig, baseURL: String, token: String) async throws(CoreError)
}
