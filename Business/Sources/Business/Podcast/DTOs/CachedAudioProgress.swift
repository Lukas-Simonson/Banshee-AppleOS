import Core
import Foundation

/// Business layer DTO for cached audio progress data.
/// Includes caching metadata and expiration logic.
public struct CachedAudioProgress: Sendable {
    public let progress: AudioProgress
    public let cachedAt: Date

    /// Custom cache expiration for audio progress: 30 minutes
    /// (shorter than default since progress updates more frequently)
    public static var cacheExpiration: TimeInterval { 1800 }

    public init(progress: AudioProgress, cachedAt: Date = Date()) {
        self.progress = progress
        self.cachedAt = cachedAt
    }

    /// Checks if this cached progress has expired
    public func isExpired() -> Bool {
        Date().timeIntervalSince(cachedAt) > Self.cacheExpiration
    }

    /// Converts to Core domain model
    public func toCore() -> AudioProgress {
        progress
    }
}
