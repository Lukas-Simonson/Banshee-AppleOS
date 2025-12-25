import Core
import Foundation

/// Contract for local database caching of podcast data.
/// Implementations handle persistence, retrieval, and expiration checking.
public protocol LocalPodcastDataSourceContract: Sendable {

    // MARK: - Podcasts

    /// Retrieves all cached podcasts if not expired.
    /// Returns nil if cache is empty or expired.
    func getCachedPodcasts() async throws(LocalPodcastDataSourceError) -> [Podcast]?

    /// Saves podcasts to local cache with current timestamp.
    func savePodcasts(_ podcasts: [Podcast]) async throws(LocalPodcastDataSourceError)

    /// Checks if podcast cache has expired based on first item's cachedAt.
    func isPodcastCacheExpired() async throws(LocalPodcastDataSourceError) -> Bool

    // MARK: - Podcast Details with Episodes

    /// Retrieves a cached podcast with its episodes.
    /// Returns nil if not found or expired.
    func getCachedPodcast(id: UUID) async throws(LocalPodcastDataSourceError) -> Podcast?

    /// Saves a podcast with its episodes.
    func savePodcastWithEpisodes(_ podcast: Podcast) async throws(LocalPodcastDataSourceError)

    // MARK: - Audio Progress

    /// Retrieves cached progress for a specific episode.
    func getCachedProgress(for episodeId: UUID) async throws(LocalPodcastDataSourceError) -> AudioProgress?

    /// Saves audio progress for an episode.
    func saveProgress(_ progress: AudioProgress, for episodeId: UUID) async throws(LocalPodcastDataSourceError)

    // MARK: - Cache Management

    /// Clears all cached podcast data.
    func clearCache() async throws(LocalPodcastDataSourceError)

    /// Clears cached data for a specific podcast and its episodes.
    func clearPodcastCache(id: UUID) async throws(LocalPodcastDataSourceError)
}

public enum LocalPodcastDataSourceError: String, LocalizedError {
    case databaseError = "Failed to access local database"
    case dataCorruption = "Cached data is corrupted"
    case migrationFailed = "Database migration failed"

    public var errorDescription: String? { self.rawValue }
}
