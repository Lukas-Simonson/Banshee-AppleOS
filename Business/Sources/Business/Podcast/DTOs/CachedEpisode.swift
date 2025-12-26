import Core
import Foundation

/// Business layer DTO for cached episode data.
/// Includes caching metadata and expiration logic.
public struct CachedEpisode: Sendable {
    public let episode: Episode
    public let cachedAt: Date

    /// Default cache expiration for episodes: 1 hour
    public static var cacheExpiration: TimeInterval { 3600 }

    public init(episode: Episode, cachedAt: Date = Date()) {
        self.episode = episode
        self.cachedAt = cachedAt
    }

    /// Checks if this cached episode has expired
    public func isExpired() -> Bool {
        Date().timeIntervalSince(cachedAt) > Self.cacheExpiration
    }

    /// Converts to Core domain model
    public func toCore() -> Episode {
        episode
    }
}
