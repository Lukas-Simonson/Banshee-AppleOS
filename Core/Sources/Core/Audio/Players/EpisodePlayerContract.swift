import Foundation

public protocol EpisodePlayerContract: Sendable {
    
    var playerState: AudioPlayerState? { get async }
    var playerStateStream: AsyncSequence<AudioPlayerState?, Never> { get }
    
    // Player Controls
    func enqueue(_ audioQueue: AudioQueue, startPlaying: Bool) async throws(EpisodePlayerError)
    
    func play() async
    func pause() async
    func stop() async
    
    func next() async
    func prev() async
    
    func skipForward() async
    func skipBackward() async
    
    func seek(to seconds: Int) async
}

public enum EpisodePlayerError: CoreError {
    case unexpectedError
    case userNotAuthenticated
    
    public var errorCode: UInt16 {
        switch self {
            case .unexpectedError: 301
            case .userNotAuthenticated: 302
        }
    }

    public var localizeableKey: LocalizedStringResource {
        switch self {
            case .unexpectedError: "error.audio.unexpected"
            case .userNotAuthenticated: "error.audio.userNotAuthenticated"
        }
    }

    public var logMessage: String {
        switch self {
            case .unexpectedError: 
                "Recieved an unexpected error that could not be processed."
            case .userNotAuthenticated:
                "User authentication required to access audio streaming service"
        }
    }
}
