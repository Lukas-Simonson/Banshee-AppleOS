import Core
import Foundation
import Logging
import Overflow

public struct EpisodeRepository: EpisodeRepositoryContract {
    
    // MARK: - Dependencies
    private let logger: Logger
    private let serverProvider: ServerProviderContract
    private let local: LocalEpisodeDataSourceContract
    private let remote: RemoteEpisodeDataSourceContract
    
    public init(logger: Logger, serverProvider: ServerProviderContract, local: LocalEpisodeDataSourceContract, remote: RemoteEpisodeDataSourceContract) {
        self.logger = logger
        self.serverProvider = serverProvider
        self.local = local
        self.remote = remote
    }
    
    public func observeEpisodes(of podcast: Podcast, order: Episode.Order) -> AsyncResultSequence<[Episode], CoreError> {
        ColdFlow { emit in
            do {
                let observer = try await local.observeEpisodes(with: podcast.id, order: order)
                for try await update in observer {
                    guard !Task.isCancelled else { return }
                    await emit(.success(update.map{ $0.toCore() }))
                }
            } catch let error as CoreError {
                await emit(.failure(error))
            } catch {
                await emit(.failure(CoreError.unexpected(layer: .business, feature: .episodes)))
            }
        }
    }
    
    public func refreshEpisodes(of podcast: Podcast, force: Bool) async throws(CoreError) {
        if !force {
            let cached = try await local.episodes(with: podcast.id)
            if let first = cached.first, !first.isExpired() {
                logger.info("Attempted to refresh unexpired episodes")
                return
            }
        }
        
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .episodes) }
        
        logger.info("Refreshing expired episodes of podcast with id: \(podcast.id)")
        
        let refreshed = try await remote.episodes(with: podcast.id, baseURL: server, token: token)
        try await local.upsert(refreshed, with: podcast.id)
    }
    
    public func toggleEpisodeComplete(_ episode: Episode) async throws(CoreError) {
        
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .episodes) }
        
        try await remote.updateEpisodeCompletion(
            with: episode.id,
            isComplete: !(episode.progress?.isCompleted ?? false),
            baseURL: server,
            token: token
        )
        
        try await local.updateEpisodeCompletion(with: episode.id, isComplete: !(episode.progress?.isCompleted ?? false))
    }
}

public protocol LocalEpisodeDataSourceContract: Sendable {
    func observeEpisodes(with podcastID: UUID, order: Episode.Order) async throws(CoreError) -> AsyncSequence<[CachedEpisode], any Error>
    
    func episodes(with podcastID: UUID) async throws(CoreError) -> [CachedEpisode]
    
    func upsert(_ episodes: [Episode], with podcastID: UUID) async throws(CoreError)
    
    func updateEpisodeCompletion(with id: UUID, isComplete: Bool) async throws(CoreError)
}

public protocol RemoteEpisodeDataSourceContract: Sendable {
    func episodes(with podcastID: UUID, baseURL: String, token: String) async throws(CoreError) -> [Episode]
    
    func updateEpisodeCompletion(with id: UUID, isComplete: Bool, baseURL: String, token: String) async throws(CoreError)
}
