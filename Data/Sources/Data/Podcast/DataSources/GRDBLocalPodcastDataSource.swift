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

    public func getCachedPodcasts() async throws(LocalPodcastDataSourceError) -> [CachedPodcast]? {
        do {
            return try await dbManager.dbQueue.read { db in
                let records = try PodcastRecord.fetchAll(db)
                guard !records.isEmpty else { return nil }

                // Convert to Business DTOs (cached podcasts)
                return records.map { $0.toCached() }
            }
        } catch {
            logger.error("Failed to fetch cached podcasts", for: error)
            throw mapDatabaseError(error)
        }
    }

    public func savePodcasts(_ podcasts: [Podcast]) async throws(LocalPodcastDataSourceError) {
        do {
            let cachedAt = Date()
            try await dbManager.dbQueue.write { db in
                for podcast in podcasts {
                    try PodcastRecord(from: CachedPodcast(podcast: podcast, cachedAt: cachedAt))
                        .upsert(db)
                }
            }
            logger.info("Saved \(podcasts.count) podcasts to cache")
        } catch {
            logger.error("Failed to save podcasts to cache", for: error)
            throw mapDatabaseError(error)
        }
    }

    // MARK: - Podcast Details with Episodes

    public func getCachedPodcast(id: UUID) async throws(LocalPodcastDataSourceError) -> CachedPodcast? {
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
        } catch {
            logger.error("Failed to fetch cached podcast \(id)", for: error)
            throw mapDatabaseError(error)
        }
    }

    public func savePodcastWithEpisodes(_ podcast: Podcast) async throws(LocalPodcastDataSourceError) {
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
        } catch {
            logger.error("Failed to save podcast with episodes", for: error)
            throw mapDatabaseError(error)
        }
    }

    // MARK: - Audio Progress

    public func getCachedProgress(for episodeId: UUID) async throws(LocalPodcastDataSourceError) -> AudioProgress? {
        do {
            return try await dbManager.dbQueue.read { db in
                guard let record = try AudioProgressRecord.fetchOne(db, key: episodeId.uuidString) else {
                    return nil
                }

                let cachedProgress = record.toCached()

                // Check expiration
                if cachedProgress.isExpired() {
                    return nil
                }

                return cachedProgress.toCore()
            }
        } catch {
            logger.error("Failed to fetch cached progress for episode \(episodeId)", for: error)
            throw mapDatabaseError(error)
        }
    }

    public func saveProgress(_ progress: AudioProgress, for episodeId: UUID) async throws(LocalPodcastDataSourceError) {
        do {
            try await dbManager.dbQueue.write { db in
                let cachedProgress = CachedAudioProgress(progress: progress, cachedAt: Date())
                let record = AudioProgressRecord(from: cachedProgress, episodeId: episodeId)
                try record.save(db)
            }
            logger.info("Saved progress for episode \(episodeId)")
        } catch {
            logger.error("Failed to save progress for episode \(episodeId)", for: error)
            throw mapDatabaseError(error)
        }
    }

    // MARK: - Cache Management

    public func clearCache() async throws(LocalPodcastDataSourceError) {
        do {
            try await dbManager.dbQueue.write { db in
                // Delete in order to respect foreign key constraints
                try AudioProgressRecord.deleteAll(db)
                try EpisodeRecord.deleteAll(db)
                try PodcastRecord.deleteAll(db)
            }
            logger.info("Cleared all podcast cache")
        } catch {
            logger.error("Failed to clear cache", for: error)
            throw mapDatabaseError(error)
        }
    }

    public func clearPodcastCache(id: UUID) async throws(LocalPodcastDataSourceError) {
        do {
            try await dbManager.dbQueue.write { db in
                // Cascade delete will handle episodes and progress
                try PodcastRecord.deleteOne(db, key: id.uuidString)
            }
            logger.info("Cleared cache for podcast \(id)")
        } catch {
            logger.error("Failed to clear cache for podcast \(id)", for: error)
            throw mapDatabaseError(error)
        }
    }

    // MARK: - Error Mapping

    /// Maps GRDB errors to specific LocalPodcastDataSourceError cases
    private func mapDatabaseError(_ error: Error) -> LocalPodcastDataSourceError {
        if let dbError = error as? DatabaseError {
            switch dbError.resultCode {
            case .SQLITE_FULL, .SQLITE_IOERR:
                return .diskFull
            case .SQLITE_BUSY, .SQLITE_LOCKED:
                return .databaseLocked
            case .SQLITE_CONSTRAINT:
                return .constraintViolation
            case .SQLITE_READONLY:
                return .readOnlyDatabase
            case .SQLITE_CORRUPT, .SQLITE_NOTADB:
                return .dataCorruption
            default:
                return .databaseError
            }
        }
        return .databaseError
    }
}
