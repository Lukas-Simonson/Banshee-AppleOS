import Foundation

public protocol EpisodePlayerContract: Sendable {
    
    var playerState: AudioPlayerState? { get async }
    var playerStateStream: AsyncSequence<AudioPlayerState?, Never> { get }
    
    // Player Controls
    func enqueue(_ episodeIDs: [UUID]) async throws(EpisodePlayerError)
    
    func play() async
    func pause() async
    func stop() async
    
    func next() async
    func prev() async
    
    func skipForward() async
    func skipBackward() async
}

public enum EpisodePlayerError: String, Error {
    case userNotAuthenticated = "User is not authenticated, unable to connect to server."
}
