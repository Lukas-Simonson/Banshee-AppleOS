import Core
import Foundation
import Logging

public struct EpisodeConfigRepository: EpisodeConfigRepositoryContract {
    // MARK: - Dependencies
    private let logger: Logger
    private let serverProvider: ServerProviderContract
    private let local: LocalEpisodeConfigDataSourceContract
    private let remote: RemoteEpisodeConfigDataSourceContract
    
    public init(logger: Logger, serverProvider: ServerProviderContract, local: LocalEpisodeConfigDataSourceContract, remote: RemoteEpisodeConfigDataSourceContract) {
        self.logger = logger
        self.serverProvider = serverProvider
        self.local = local
        self.remote = remote
    }
    
    public func config(for episode: Episode) async throws(CoreError) -> (Episode, EpisodeConfig) {
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .episodes) }
        
        return try await remote.getConfig(with: episode.id, baseURL: server, token: token)
    }
    
    public func update(_ config: EpisodeConfig, for episode: Episode) async throws(CoreError) {
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .episodes) }
        
        try await remote.postConfig(config, baseURL: server, token: token)
        
        // Provide default values for non-overridden config values.
        try await local.updateEpisode(
            with: EpisodeConfig(
                title: config.title ?? episode.title,
                description: config.description ?? episode.description,
                season: config.season ?? episode.season,
                episode: config.episode ?? episode.episode,
                episodeID: episode.id
            )
        )
    }
}
