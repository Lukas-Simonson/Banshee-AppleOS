import Core
import Foundation

public protocol CachedPodcast: Sendable {
    static var expiration: TimeInterval { get }
    
    func isExpired() -> Bool
    func toCore() -> Podcast
}

public extension CachedPodcast {
    static var expiration: TimeInterval { 3600 }
}
