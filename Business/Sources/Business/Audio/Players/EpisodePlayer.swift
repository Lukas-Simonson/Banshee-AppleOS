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
    private let localQueue: LocalQueueDataSourceContract
    
    private let playerStateFlow = MutableStateFlow<AudioPlayerState?>(initial: nil)
    private var queue: AudioQueue?
    
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
        localQueue: LocalQueueDataSourceContract
    ) {
        self.audio = audio
        self.logger = logger
        self.serverProvider = serverProvider
        self.remote = remote
        self.localQueue = localQueue
        
        self.audio.delegate = self
        
        Task {
            if let savedQueue = localQueue.get() {
                try? await enqueue(savedQueue, startPlaying: false)
            }
        }
    }
    
    // Player Management
    public func enqueue(_ newQueue: AudioQueue, startPlaying: Bool = true) async throws(EpisodePlayerError) {
        // if (self.queue == nil || self.queue!.isEmpty) && !newQueue.isEmpty {
            logger.info("Filling queue with \(newQueue.count) episodes.")
            self.queue = newQueue
            
            guard let server = await serverProvider.server,
                  let token = await serverProvider.token,
                  let url = URL(string: "\(server)/api/episodes/\(newQueue.queue[0])/audio")
            else { throw EpisodePlayerError.userNotAuthenticated }
            
            await playerStateFlow.emit(.loading(size: newQueue.count))
            
            async let fetchEpisode = remote.episode(with: newQueue.queue[0], baseURL: server, token: token.token)
            async let loadAudio = audio.start(url, token: token.token)
            
            do {
                try await startPlaying
                let (episode, _) = try await (fetchEpisode, loadAudio)
                let newState = AudioPlayerState(
                    title: episode.title,
                    imageURL: episode.imageURL ?? newQueue.podcastImageURL,
                    current: episode.progress?.duration ?? 0,
                    duration: episode.duration ?? 1,
                    queueSize: newQueue.count,
                    queuePosition: 1,
                    mode: startPlaying ? .playing : .paused
                )
                
                if let progress = episode.progress {
                    await audio.seek(to: progress.duration)
                }
                
                // Persist queue to local storage.
                localQueue.save(newQueue)
                
                await playerStateFlow.emit(newState)
                await audio.setMedia(with: AudioData(image: nil, title: episode.title))
                
                if startPlaying {
                    await audio.play()
                }
            } catch {
                logger.error("Error playing episode", for: error)
            }
        // }
    }
}

// MARK: - Audio Player Delegate
extension EpisodePlayer: AudioServiceDelegateContract {
    nonisolated public func playerDidUpdateTimePlayed(_ time: Int) {
        Task {
            if let state = await self.playerState {
                await playerStateFlow.emit(state.copy(current: time))
            }
        }
    }
    
    nonisolated public func playerDidResume() {
        Task {
            if let state = await self.playerState {
                await playerStateFlow.emit(state.copy(mode: .playing))
            }
        }
    }
    
    nonisolated public func playerDidPause() {
        Task {
            if let state = await self.playerState {
                await playerStateFlow.emit(state.copy(mode: .paused))
            }
        }
    }
    
    nonisolated public func playerDidStop() {
        Task {
            if let state = await self.playerState {
                await playerStateFlow.emit(nil)
            }
        }
    }
    
    nonisolated public func playerDidFinish() {
        // TODO: Go to next item in queue.
    }
    
    nonisolated public func playerDidEncounterError(_ error: Error?) {
        // TODO: Handle somehow
    }
}

// MARK: - Audio Passthrough Functions
extension EpisodePlayer {
    public func play() async { await audio.play() }
    
    public func pause() async { await audio.pause() }
    
    public func stop() async { await audio.stop() }
    
    public func next() async { fatalError() }
    
    public func prev() async { fatalError() }
    
    public func skipForward() async { await audio.skipForward() }
    
    public func skipBackward() async { await audio.skipBackward() }
}

extension AudioPlayerState {
    func copy(
        current: Int? = nil,
        duration: Int? = nil,
        mode: Mode? = nil
    ) -> AudioPlayerState {
        AudioPlayerState(
            title: title,
            imageURL: imageURL,
            current: current ?? self.current,
            duration: duration ?? self.duration,
            queueSize: queueSize,
            queuePosition: queuePosition,
            mode: mode ?? self.mode
        )
    }
}
