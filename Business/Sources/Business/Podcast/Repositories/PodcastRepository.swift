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
    public func refresh() async throws(PodcastRepositoryError) {
        guard let token = await serverProvider.token,
              let server = await serverProvider.server
        else { throw PodcastRepositoryError.missingAuthorization }

        // Cache-first strategy
        do {
            // Try to get cached data first
            if let cachedPodcasts = try await local.getCachedPodcasts() {
                logger.info("Serving \(cachedPodcasts.count) podcasts from cache")
                await podcastsFlow.emit(cachedPodcasts)

                // Check if cache is expired
                let isExpired = try await local.isPodcastCacheExpired()
                if !isExpired {
                    logger.info("Cache is still valid, skipping network request")
                    return
                }
                logger.info("Cache expired, fetching fresh data from network")
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
        } catch let error as RemotePodcastDataSourceError {
            logger.error("Failed to fetch podcasts from remote", for: error)
            throw PodcastRepositoryError.couldntGetPodcast
        }
    }
    
    public func details(for podcast: Podcast) async throws(PodcastRepositoryError) -> Podcast {
        guard let token = await serverProvider.token,
              let server = await serverProvider.server
        else { throw PodcastRepositoryError.missingAuthorization }

        do {
            if let cachedPodcast = try await local.getCachedPodcast(id: podcast.id),
               let episodes = cachedPodcast.episodes, !episodes.isEmpty {
                logger.info("Serving podcast details from cache (id: \(podcast.id))")
                return cachedPodcast
            }
        } catch {
            logger.warning("Failed to read podcast details from cache", for: error)
        }

        // Fetch from network
        do {
            let detailedPodcast = try await remote.getPodcast(with: podcast.id, baseURL: server, token: token.token)

            // Update cache
            do {
                try await local.savePodcastWithEpisodes(detailedPodcast)
            } catch {
                logger.warning("Failed to cache podcast details", for: error)
            }

            return detailedPodcast
        } catch let error as RemotePodcastDataSourceError {
            logger.error("Failed to get podcast information", for: error)
            throw PodcastRepositoryError.couldntGetPodcast
        }
    }
}
