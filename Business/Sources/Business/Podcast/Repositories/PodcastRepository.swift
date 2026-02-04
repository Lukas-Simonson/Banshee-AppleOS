import Core
import Foundation
import Logging
import Overflow

public final class PodcastRepository: PodcastRepositoryContract {

    // MARK: - Private Properties
    private let logger: Logger
    private let serverProvider: ServerProviderContract
    private let remote: RemotePodcastDataSourceContract
    private let local: LocalPodcastDataSourceContract

    private let podcastsFlow = MutableStateFlow(initial: [Podcast]())

    // MARK: - Shared State
    public var podcasts: [Podcast] {
        get async { await podcastsFlow.value }
    }

    public var podcastsStream: AsyncSequence<[Podcast], Never> {
        podcastsFlow
    }

    public init(
        logger: Logger,
        serverProvider: ServerProviderContract,
        remote: RemotePodcastDataSourceContract,
        local: LocalPodcastDataSourceContract,
    ) {
        self.logger = logger
        self.serverProvider = serverProvider
        self.remote = remote
        self.local = local
    }
    
    // MARK: - Podcast Management
    public func refresh(force: Bool) async throws(CoreError) {
        guard let token = await serverProvider.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .podcasts) }

        // Cache-first strategy
        do {
            // Try to get cached data first
            if !force, let cachedPodcasts = try await local.getCachedPodcasts() {
                logger.info("Serving \(cachedPodcasts.count) podcasts from cache")

                // Check if cache is expired (using first podcast as representative)
                if let firstCached = cachedPodcasts.first, !firstCached.isExpired() {
                    logger.info("Cache is still valid, skipping network request")
                    await podcastsFlow.emit(cachedPodcasts.map { $0.toCore() })
                    return
                }

                logger.info("Cache expired, fetching fresh data from network")
                // Still emit cached data while fetching fresh
                await podcastsFlow.emit(cachedPodcasts.map { $0.toCore() })
            }
        } catch {
            logger.warning("Failed to read from cache, falling back to network", for: error)
        }

        // Fetch from network
        logger.info("Pulling podcasts from server")
        do {
            let podcasts = try await remote.getPodcasts(baseURL: server, token: token.token)
            logger.info("Successfully loaded \(podcasts.count) podcasts from server.")

            // Update cache
            do {
                try await local.savePodcasts(podcasts)
            } catch {
                logger.warning("Failed to cache podcasts", for: error)
            }

            await podcastsFlow.emit(podcasts)
        } catch let error as CoreError {
            logger.error("Failed to fetch podcasts from remote", for: error)
            throw error
        }
    }
    
    public func details(for podcast: Podcast, refresh: Bool) -> AsyncResultSequence<Podcast, CoreError> {
        ColdFlow { [self] emit in
            guard let token = await serverProvider.token,
                  let server = await serverProvider.server
            else { await emit(.failure(.notAuthenticated(layer: .business, feature: .podcasts))); return }

            do {
                if !refresh, let cachedPodcast = try await local.getCachedPodcast(id: podcast.id) {
                    await emit(.success(cachedPodcast.toCore()))
                    
                    if !cachedPodcast.isExpired(), let episodes = cachedPodcast.podcast.episodes, !episodes.isEmpty {
                        logger.info("Serving podcast details from cache (id: \(podcast.id))")
                        return
                    }
                }
            } catch {
                logger.warning("Failed to read podcast details from cache", for: error)
            }
            
            do {
                let details = try await remote.getPodcast(with: podcast.id, baseURL: server, token: token.token)
                try await local.savePodcastWithEpisodes(details)
                await emit(.success(details))
            } catch let error as CoreError {
                await emit(.failure(error))
            } catch {
                await emit(.failure(.unexpected(layer: .business, feature: .podcasts)))
            }
        }
    }
    
    public func config(for podcast: Podcast) async throws(CoreError) -> (Podcast, PodcastConfig) {
        // get config from API
        guard let token = await serverProvider.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .podcasts) }
        
        return try await remote.getConfig(podcastID: podcast.id, baseURL: server, token: token.token)
    }
    
    public func update(_ config: PodcastConfig) async throws(CoreError) {
        // get config from API
        guard let token = await serverProvider.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .podcasts) }
        
        return try await remote.postConfig(config, baseURL: server, token: token.token)
    }
}
