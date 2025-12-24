import Core
import Foundation
import Logging
import Overflow

public actor EpisodePlayer: EpisodePlayerContract {
    
    // Private State
    private let audio: AudioServiceContract
    private let logger: Logger
    private let serverProvider: ServerProviderContract
    private let remote: RemotePlayerDataSourceContract
    
    private let playerStateFlow = MutableStateFlow<AudioPlayerState?>(initial: nil)
    private var queue = [UUID]()
    
    // Shared State
    public var playerState: AudioPlayerState? {
        get async { await playerStateFlow.value }
    }
    
    nonisolated public var playerStateStream: AsyncSequence<AudioPlayerState?, Never> {
        playerStateFlow
    }
    
    public init(
        audio: AudioServiceContract,
        logger: Logger,
        serverProvider: ServerProviderContract,
        remote: RemotePlayerDataSourceContract,
    ) {
        self.audio = audio
        self.logger = logger
        self.serverProvider = serverProvider
        self.remote = remote
    }
    
    // Player Management
    public func enqueue(_ episodeIDs: [UUID]) async throws(EpisodePlayerError) {
        if self.queue.isEmpty, !episodeIDs.isEmpty {
            logger.info("Filling empty queue with \(episodeIDs.count) episodes.")
            self.queue = episodeIDs
            
            guard let server = await serverProvider.server,
                  let token = await serverProvider.token,
                  let url = URL(string: "\(server)/api/episodes/\(episodeIDs[0])/audio")
            else { throw EpisodePlayerError.userNotAuthenticated }
            
            await playerStateFlow.emit(.loading(size: episodeIDs.count))
            
            async let fetchEpisode = remote.episode(with: episodeIDs[0], baseURL: server, token: token.token)
            async let startPlaying = audio.start(url, token: token.token)
            
            do {
                let (episode, _) = try await (fetchEpisode, startPlaying)
                let newState = AudioPlayerState(
                    title: episode.title,
                    imageURL: episode.imageURL,
                    current: 0,
                    duration: episode.duration ?? 1,
                    queueSize: episodeIDs.count,
                    queuePosition: 1,
                    mode: .playing
                )
                
                await audio.setMedia(with: AudioData(image: nil, title: episode.title))
                await playerStateFlow.emit(newState)
            } catch {
                logger.error("Error playing episode", for: error)
            }
        }
    }
}

// - MARK: Audio Passthrough Functions
extension EpisodePlayer {
    public func play() async { await audio.play() }
    
    public func pause() async { await audio.pause() }
    
    public func stop() async { await audio.stop() }
    
    public func next() async { fatalError() }
    
    public func prev() async { fatalError() }
    
    public func skipForward() async { await audio.skipForward() }
    
    public func skipBackward() async { await audio.skipBackward() }
}
