import Foundation

public protocol EpisodePlayerContract: Sendable {
    
    var playerState: AudioPlayerState? { get async }
    var playerStateStream: AsyncSequence<AudioPlayerState?, Never> { get }
    
    // Player Controls
    func enqueue(_ audioQueue: AudioQueue, startPlaying: Bool) async throws(CoreError)

    func play() async
    func pause() async
    func stop() async
    
    func next() async
    func prev() async
    
    func skipForward() async
    func skipBackward() async
    
    func seek(to seconds: Int) async
}
