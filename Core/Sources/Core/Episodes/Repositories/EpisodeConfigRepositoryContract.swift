import Foundation

public protocol EpisodeConfigRepositoryContract: Sendable {
    func config(for episode: Episode) async throws(CoreError) -> (Episode, EpisodeConfig)
    func update(_ config: EpisodeConfig, for episode: Episode) async throws(CoreError)
}
