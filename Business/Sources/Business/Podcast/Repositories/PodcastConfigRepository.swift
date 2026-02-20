import Core
import Foundation
import Logging
import Overflow

public struct PodcastConfigRepository: PodcastConfigRepositoryContract {
    
    // MARK: - Dependencies
    private let logger: Logger
    private let serverProvider: ServerProviderContract
    private let local: LocalPodcastConfigDataSourceContract
    private let remote: RemotePodcastConfigDataSourceContract
    
    public init(logger: Logger, serverProvider: ServerProviderContract, local: LocalPodcastConfigDataSourceContract, remote: RemotePodcastConfigDataSourceContract) {
        self.logger = logger
        self.serverProvider = serverProvider
        self.local = local
        self.remote = remote
    }
    
    public func config(for podcast: Podcast) async throws(CoreError) -> (Podcast, PodcastConfig) {
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .podcasts) }
        
        return try await remote.getConfig(with: podcast.id, baseURL: server, token: token)
    }
    
    public func update(_ config: PodcastConfig, for podcast: Podcast) async throws(CoreError) {
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .podcasts) }
        
        try await remote.postConfig(config, baseURL: server, token: token)
        
        // Provide default values for non-overridden config values.
        try await local.updatePodcast(
            with: PodcastConfig(
                title: config.title ?? podcast.title,
                imageURL: config.imageURL ?? podcast.imageURL,
                description: config.description ?? podcast.description,
                podcastID: config.podcastID
            )
        )
    }
}
