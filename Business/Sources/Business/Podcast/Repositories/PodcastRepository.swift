import Core
import Foundation
import Logging
import Overflow

public final class PodcastRepository: PodcastRepositoryContract {
    
    // MARK: - Private Properties
    private let logger: Logger
    private let serverProvider: ServerProviderContract
    private let remote: RemotePodcastDataSourceContract
    
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
        remote: RemotePodcastDataSourceContract
    ) {
        self.logger = logger
        self.serverProvider = serverProvider
        self.remote = remote
    }
    
    // MARK: - Podcast Management
    public func refresh() async throws(PodcastRepositoryError) {
        guard let token = await serverProvider.token,
              let server = await serverProvider.server
        else { throw PodcastRepositoryError.missingAuthorization }
        
        logger.info("Pulling podcasts from server")
        
        do {
            let podcasts = try await remote.getPodcasts(baseURL: server, token: token.token)
            logger.info("Successfully loaded \(podcasts.count) podcasts from server.")
            await podcastsFlow.emit(podcasts)
        } catch let error as RemotePodcastDataSourceError {
            fatalError()
        }
    }
    
    public func details(for podcast: Podcast) async throws(PodcastRepositoryError) -> Podcast {
        guard let token = await serverProvider.token,
              let server = await serverProvider.server
        else { throw PodcastRepositoryError.missingAuthorization }
        
        do {
            return try await remote.getPodcast(with: podcast.id, baseURL: server, token: token.token)
        } catch let error as RemotePodcastDataSourceError {
            logger.error("Failed to get podcast information", for: error)
            throw PodcastRepositoryError.couldntGetPodcast
        }
    }
}
