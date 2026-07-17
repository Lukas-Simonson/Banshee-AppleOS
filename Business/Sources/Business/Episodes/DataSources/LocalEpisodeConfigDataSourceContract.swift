import Core
import Foundation

public protocol LocalEpisodeConfigDataSourceContract: Sendable {
    func updateEpisode(with config: EpisodeConfig) async throws(CoreError)
    func updateEpisodes(_ episodes: [Episode]) async throws(CoreError)
}
