import Core
import Foundation

/// Business layer DTO for cached podcast data.
/// Includes caching metadata and expiration logic.
public struct CachedPodcast: Sendable {
    public let podcast: Podcast
    public let cachedAt: Date

    /// Default cache expiration for podcasts: 1 hour
    public static var cacheExpiration: TimeInterval { 3600 }

    public init(podcast: Podcast, cachedAt: Date = Date()) {
        self.podcast = podcast
        self.cachedAt = cachedAt
    }

    /// Checks if this cached podcast has expired
    public func isExpired() -> Bool {
        Date().timeIntervalSince(cachedAt) > Self.cacheExpiration
    }

    /// Converts to Core domain model
    public func toCore() -> Podcast {
        podcast
    }
}
