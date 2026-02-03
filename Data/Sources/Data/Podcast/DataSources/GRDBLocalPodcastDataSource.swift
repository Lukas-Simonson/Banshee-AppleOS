import Business
import Core
import Foundation
import GRDB
import Logging

/// GRDB implementation of LocalPodcastDataSourceContract.
public final class GRDBLocalPodcastDataSource: LocalPodcastDataSourceContract {

    private let dbManager: DatabaseManager
    private let logger: Logger

    public init(dbManager: DatabaseManager, logger: Logger) {
        self.dbManager = dbManager
        self.logger = logger
    }

    // MARK: - Podcasts

    public func getCachedPodcasts() async throws(CoreError) -> [CachedPodcast]? {
        do {
            return try await dbManager.dbQueue.read { db in
                let records = try PodcastRecord.fetchAll(db)
                guard !records.isEmpty else { return nil }

                // Convert to Business DTOs (cached podcasts)
                return records.map { $0.toCached() }
            }
        } catch let error as DatabaseError {
            logger.error("Failed to fetch cached podcasts", for: error)
            throw error.toCoreError(for: .podcasts)
        } catch {
            logger.error("Encountered an unexpected error when retrieving cached podcasts", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }

    public func savePodcasts(_ podcasts: [Podcast]) async throws(CoreError) {
        do {
            let cachedAt = Date()
            try await dbManager.dbQueue.write { db in
                for podcast in podcasts {
                    try PodcastRecord(from: CachedPodcast(podcast: podcast, cachedAt: cachedAt))
                        .upsert(db)
                }
            }
            logger.info("Saved \(podcasts.count) podcasts to cache")
        } catch let error as DatabaseError {
            logger.error("Failed to save podcasts to cache", for: error)
            throw error.toCoreError(for: .podcasts)
        } catch {
            logger.error("Encountered an unexpected error when retrieving cached podcasts", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }

    // MARK: - Podcast Details with Episodes

    public func getCachedPodcast(id: UUID) async throws(CoreError) -> CachedPodcast? {
        do {
            return try await dbManager.dbQueue.read { db in
                guard let podcastRecord = try PodcastRecord.fetchOne(db, key: id.uuidString) else {
                    return nil
                }

                let cachedPodcast = podcastRecord.toCached()

                // Fetch episodes with their progress
                let episodeRecords = try EpisodeRecord
                    .filter(Column("podcastId") == id.uuidString)
                    .fetchAll(db)

                // Fetch progress for each episode
                var cachedEpisodes: [CachedEpisode] = []
                for episodeRecord in episodeRecords {
                    let progressRecord = try AudioProgressRecord.fetchOne(db, key: episodeRecord.id)
                    let cachedProgress = progressRecord?.toCached()
                    cachedEpisodes.append(episodeRecord.toCached(with: cachedProgress))
                }

                // Build podcast with episodes
                let podcast = cachedPodcast.podcast
                let podcastWithEpisodes = Podcast(
                    id: podcast.id,
                    title: podcast.title,
                    link: podcast.link,
                    language: podcast.language,
                    imageURL: podcast.imageURL,
                    description: podcast.description,
                    episodes: cachedEpisodes.map { $0.toCore() }
                )

                // Return as CachedPodcast with original cached timestamp
                return CachedPodcast(podcast: podcastWithEpisodes, cachedAt: cachedPodcast.cachedAt)
            }
        } catch let error as DatabaseError {
            logger.error("Failed to fetch podcast with id: \(id)", for: error)
            throw error.toCoreError(for: .podcasts)
        } catch {
            logger.error("Encountered an unexpected error when retrieving cached podcast with id: \(id)", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }

    public func savePodcastWithEpisodes(_ podcast: Podcast) async throws(CoreError) {
        do {
            let cachedAt = Date()
            try await dbManager.dbQueue.write { db in
                // Save/update podcast
                let cachedPodcast = CachedPodcast(podcast: podcast, cachedAt: cachedAt)
                let podcastRecord = PodcastRecord(from: cachedPodcast)
                try podcastRecord.save(db)

                // Save episodes if present
                if let episodes = podcast.episodes {
                    // Delete old episodes for this podcast
                    try EpisodeRecord
                        .filter(Column("podcastId") == podcast.id.uuidString)
                        .deleteAll(db)

                    // Insert new episodes
                    for episode in episodes {
                        let cachedEpisode = CachedEpisode(episode: episode, cachedAt: cachedAt)
                        let episodeRecord = EpisodeRecord(from: cachedEpisode, podcastId: podcast.id)
                        try episodeRecord.insert(db)

                        // Save progress if present
                        if let progress = episode.progress {
                            let cachedProgress = CachedAudioProgress(progress: progress, cachedAt: cachedAt)
                            let progressRecord = AudioProgressRecord(from: cachedProgress, episodeId: episode.id)
                            try progressRecord.save(db)
                        }
                    }
                }
            }
            logger.info("Saved podcast \(podcast.id) with \(podcast.episodes?.count ?? 0) episodes")
        } catch let error as DatabaseError {
            logger.error("Failed to save a podcast", for: error)
            throw error.toCoreError(for: .podcasts)
        } catch {
            logger.error("Encountered an unexpected error when saving a podcast", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }

    // MARK: - Audio Progress

    public func getCachedProgress(for episodeID: UUID) async throws(CoreError) -> AudioProgress? {
        do {
            return try await dbManager.dbQueue.read { db in
                guard let record = try AudioProgressRecord.fetchOne(db, key: episodeID.uuidString) else {
                    return nil
                }

                let cachedProgress = record.toCached()

                // Check expiration
                if cachedProgress.isExpired() {
                    return nil
                }

                return cachedProgress.toCore()
            }
        } catch let error as DatabaseError {
            logger.error("Failed to fetch progress for episode with id: \(episodeID)", for: error)
            throw error.toCoreError(for: .podcasts)
        } catch {
            logger.error("Encountered an unexpected error when retrieving progress for episode with id: \(episodeID)", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }

    public func saveProgress(_ progress: AudioProgress, for episodeID: UUID) async throws(CoreError) {
        do {
            try await dbManager.dbQueue.write { db in
                let cachedProgress = CachedAudioProgress(progress: progress, cachedAt: Date())
                let record = AudioProgressRecord(from: cachedProgress, episodeId: episodeID)
                try record.save(db)
            }
            logger.info("Saved progress for episode \(episodeID)")
        } catch let error as DatabaseError {
            logger.error("Failed to fetch save progress for episode with id: \(episodeID)", for: error)
            throw error.toCoreError(for: .podcasts)
        } catch {
            logger.error("Encountered an unexpected error when saving progress for episode with id: \(episodeID)", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }

    // MARK: - Cache Management

    public func clearCache() async throws(CoreError) {
        do {
            try await dbManager.dbQueue.write { db in
                // Delete in order to respect foreign key constraints
                try AudioProgressRecord.deleteAll(db)
                try EpisodeRecord.deleteAll(db)
                try PodcastRecord.deleteAll(db)
            }
            logger.info("Cleared all podcast cache")
        }  catch let error as DatabaseError {
            logger.error("Failed to clear cached data", for: error)
            throw error.toCoreError(for: .podcasts)
        } catch {
            logger.error("Encountered an unexpected error when clearing cached data", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }

    public func clearPodcastCache(id: UUID) async throws(CoreError) {
        do {
            try await dbManager.dbQueue.write { db in
                // Cascade delete will handle episodes and progress
                try PodcastRecord.deleteOne(db, key: id.uuidString)
            }
            logger.info("Cleared cache for podcast \(id)")
        }  catch let error as DatabaseError {
            logger.error("Failed to clear cache for podcast with id: \(id)", for: error)
            throw error.toCoreError(for: .podcasts)
        } catch {
            logger.error("Encountered an unexpected error when deleting podcast with id: \(id)", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }
}
