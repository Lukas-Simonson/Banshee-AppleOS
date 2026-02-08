import Core
import Foundation
import Logging
import Overflow

public struct PodcastRepository: PodcastRepositoryContract {
    
    // MARK: - Dependencies
    private let logger: Logger
    private let serverProvider: ServerProviderContract
    private let local: LocalPodcastDataSourceContract
    private let remote: RemotePodcastDataSourceContract
    
    public init(logger: Logger, serverProvider: ServerProviderContract, local: LocalPodcastDataSourceContract, remote: RemotePodcastDataSourceContract) {
        self.logger = logger
        self.serverProvider = serverProvider
        self.local = local
        self.remote = remote
    }
}

// MARK: Podcasts
extension PodcastRepository {
    public func observePodcasts() -> AsyncResultSequence<[Podcast], CoreError> {
        ColdFlow { emit in
            do {
                let observer = try await local.observePodcasts()
                for try await update in observer {
                    guard !Task.isCancelled else { return }
                    await emit(.success(update.map { $0.toCore() }))
                }
            }  catch let error as CoreError {
                await emit(.failure(error))
            } catch {
                await emit(.failure(CoreError.unexpected(layer: .business, feature: .podcasts)))
            }
        }
    }
    
    public func refreshPodcasts(force: Bool) async throws(CoreError) {
        if !force {
            let cached = try await local.podcasts()
            if let first = cached.first, !first.isExpired() {
                logger.info("Attempted to refresh unexpired podcasts")
                return
            }
        }
        
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .podcasts) }
        
        let refreshed = try await remote.podcasts(baseURL: server, token: token)
        try await local.upsert(refreshed)
    }
}

// MARK: Podcast with ID
extension PodcastRepository {
    public func observePodcast(with id: UUID) -> AsyncResultSequence<Podcast, CoreError> {
        ColdFlow { emit in
            do {
                let observer = try await local.observePodcast(with: id)
                for try await update in observer {
                    guard !Task.isCancelled else { return }
                    if let update {
                        await emit(.success(update.toCore()))
                    }
                }
            }  catch let error as CoreError {
                await emit(.failure(error))
            } catch {
                await emit(.failure(CoreError.unexpected(layer: .business, feature: .podcasts)))
            }
        }
    }
    
    public func refreshPodcast(with id: UUID, force: Bool) async throws(CoreError) {
        if !force {
            let cached = try await local.podcast(with: id)
            if let cached, !cached.isExpired() {
                logger.info("Attempted to refresh unexpired podcast with id: \(id)")
                return
            }
        }
        
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .podcasts) }
        
        // TODO: Refreshes all podcasts, may want to change later.
        let refreshed = try await remote.podcasts(baseURL: server, token: token)
        try await local.upsert(refreshed)
    }
}

// MARK: RSS Feed
extension PodcastRepository {
    public func addPodcast(fromRSS rssURL: URL) async throws(CoreError) {
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .podcasts) }
        
        let podcast = try await remote.registerFeed(from: rssURL, baseURL: server, token: token)
        try await local.upsert([podcast])
    }
}
