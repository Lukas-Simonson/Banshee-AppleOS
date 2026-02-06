import Core
import Foundation

public protocol CachedEpisode: Sendable {
    static var expiration: TimeInterval { get }
    
    func isExpired() -> Bool
    func toCore() -> Episode
}

public extension CachedEpisode {
    static var expiration: TimeInterval { 3600 }
}
