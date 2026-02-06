import Core
import Foundation

public protocol CachedAudioProgress: Sendable {
    static var expiration: TimeInterval { get }
    
    func isExpired() -> Bool
    func toCore() -> AudioProgress
}

public extension CachedAudioProgress {
    static var expiration: TimeInterval { 3600 }
}
